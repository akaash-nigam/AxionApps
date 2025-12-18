//
//  HandTrackingManager.swift
//  BusinessOperatingSystem
//
//  Created by BOS Team on 2025-01-20.
//

import Foundation
import ARKit
import RealityKit
import Observation

// MARK: - Hand Tracking Manager

/// Manages hand tracking using ARKit for visionOS spatial interactions
@Observable
@MainActor
final class HandTrackingManager {
    // MARK: - Properties

    /// Whether hand tracking is currently active
    private(set) var isTracking: Bool = false

    /// Whether hand tracking is available on this device
    private(set) var isAvailable: Bool = false

    /// Current state of the left hand
    private(set) var leftHand: HandState?

    /// Current state of the right hand
    private(set) var rightHand: HandState?

    /// Detected gestures
    private(set) var currentGesture: HandGesture?

    /// Error if hand tracking failed
    private(set) var trackingError: Error?

    // MARK: - Private Properties

    private var session: ARKitSession?
    private var handTracking: HandTrackingProvider?
    private var trackingTask: Task<Void, Never>?

    // MARK: - Hand State

    struct HandState: Sendable {
        let chirality: HandAnchor.Chirality
        let transform: simd_float4x4
        let joints: [HandSkeleton.JointName: JointState]

        /// Position of the wrist in world space
        var wristPosition: SIMD3<Float> {
            SIMD3<Float>(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
        }

        /// Get position of a specific joint
        func jointPosition(_ joint: HandSkeleton.JointName) -> SIMD3<Float>? {
            joints[joint]?.position
        }

        /// Index finger tip position
        var indexTipPosition: SIMD3<Float>? {
            jointPosition(.indexFingerTip)
        }

        /// Thumb tip position
        var thumbTipPosition: SIMD3<Float>? {
            jointPosition(.thumbTip)
        }

        /// Check if fingers are pinching
        var isPinching: Bool {
            guard let indexTip = indexTipPosition,
                  let thumbTip = thumbTipPosition else { return false }
            let distance = simd_distance(indexTip, thumbTip)
            return distance < 0.02  // 2cm threshold
        }
    }

    struct JointState: Sendable {
        let name: HandSkeleton.JointName
        let position: SIMD3<Float>
        let rotation: simd_quatf
        let isTracked: Bool
    }

    // MARK: - Hand Gestures

    enum HandGesture: String, Sendable {
        case none
        case pinch
        case point
        case openPalm
        case fist
        case thumbsUp

        var displayName: String {
            switch self {
            case .none: return "None"
            case .pinch: return "Pinch"
            case .point: return "Point"
            case .openPalm: return "Open Palm"
            case .fist: return "Fist"
            case .thumbsUp: return "Thumbs Up"
            }
        }
    }

    // MARK: - Initialization

    init() {
        checkAvailability()
    }

    // MARK: - Availability Check

    private func checkAvailability() {
        Task {
            isAvailable = HandTrackingProvider.isSupported
        }
    }

    // MARK: - Start/Stop Tracking

    /// Start hand tracking
    func startTracking() async throws {
        guard !isTracking else { return }

        guard HandTrackingProvider.isSupported else {
            throw HandTrackingError.notSupported
        }

        session = ARKitSession()
        handTracking = HandTrackingProvider()

        guard let session = session, let handTracking = handTracking else {
            throw HandTrackingError.initializationFailed
        }

        do {
            try await session.run([handTracking])
            isTracking = true
            trackingError = nil

            // Start processing hand updates
            trackingTask = Task {
                await processHandUpdates()
            }
        } catch {
            trackingError = error
            throw HandTrackingError.sessionFailed(error)
        }
    }

    /// Stop hand tracking
    func stopTracking() {
        trackingTask?.cancel()
        trackingTask = nil
        session?.stop()
        session = nil
        handTracking = nil
        isTracking = false
        leftHand = nil
        rightHand = nil
        currentGesture = nil
    }

    // MARK: - Hand Update Processing

    private func processHandUpdates() async {
        guard let handTracking = handTracking else { return }

        for await update in handTracking.anchorUpdates {
            guard !Task.isCancelled else { break }

            switch update.event {
            case .added, .updated:
                await processHandAnchor(update.anchor)
            case .removed:
                removeHand(update.anchor.chirality)
            }
        }
    }

    private func processHandAnchor(_ anchor: HandAnchor) async {
        guard anchor.isTracked else {
            removeHand(anchor.chirality)
            return
        }

        // Extract joint states
        var joints: [HandSkeleton.JointName: JointState] = [:]

        if let skeleton = anchor.handSkeleton {
            for jointName in HandSkeleton.JointName.allCases {
                let joint = skeleton.joint(jointName)
                let worldTransform = anchor.originFromAnchorTransform * joint.anchorFromJointTransform

                let position = SIMD3<Float>(
                    worldTransform.columns.3.x,
                    worldTransform.columns.3.y,
                    worldTransform.columns.3.z
                )

                let rotation = simd_quatf(worldTransform)

                joints[jointName] = JointState(
                    name: jointName,
                    position: position,
                    rotation: rotation,
                    isTracked: joint.isTracked
                )
            }
        }

        let handState = HandState(
            chirality: anchor.chirality,
            transform: anchor.originFromAnchorTransform,
            joints: joints
        )

        // Update the appropriate hand
        switch anchor.chirality {
        case .left:
            leftHand = handState
        case .right:
            rightHand = handState
        }

        // Detect gestures
        detectGesture()
    }

    private func removeHand(_ chirality: HandAnchor.Chirality) {
        switch chirality {
        case .left:
            leftHand = nil
        case .right:
            rightHand = nil
        }
        detectGesture()
    }

    // MARK: - Gesture Detection

    private func detectGesture() {
        // Check right hand first, then left
        let primaryHand = rightHand ?? leftHand

        guard let hand = primaryHand else {
            currentGesture = .none
            return
        }

        // Pinch detection
        if hand.isPinching {
            currentGesture = .pinch
            return
        }

        // Point detection (index extended, others curled)
        if isPointing(hand: hand) {
            currentGesture = .point
            return
        }

        // Open palm detection
        if isOpenPalm(hand: hand) {
            currentGesture = .openPalm
            return
        }

        // Fist detection
        if isFist(hand: hand) {
            currentGesture = .fist
            return
        }

        currentGesture = .none
    }

    private func isPointing(hand: HandState) -> Bool {
        guard let indexTip = hand.jointPosition(.indexFingerTip),
              let indexKnuckle = hand.jointPosition(.indexFingerKnuckle),
              let middleTip = hand.jointPosition(.middleFingerTip),
              let middleKnuckle = hand.jointPosition(.middleFingerKnuckle) else {
            return false
        }

        // Index finger should be extended
        let indexExtension = simd_distance(indexTip, indexKnuckle)

        // Middle finger should be curled
        let middleExtension = simd_distance(middleTip, middleKnuckle)

        return indexExtension > 0.06 && middleExtension < 0.04
    }

    private func isOpenPalm(hand: HandState) -> Bool {
        // Check if all fingers are extended
        let fingerTips: [HandSkeleton.JointName] = [
            .thumbTip, .indexFingerTip, .middleFingerTip, .ringFingerTip, .littleFingerTip
        ]
        let knuckles: [HandSkeleton.JointName] = [
            .thumbKnuckle, .indexFingerKnuckle, .middleFingerKnuckle, .ringFingerKnuckle, .littleFingerKnuckle
        ]

        var extendedCount = 0
        for (tip, knuckle) in zip(fingerTips, knuckles) {
            guard let tipPos = hand.jointPosition(tip),
                  let knucklePos = hand.jointPosition(knuckle) else { continue }

            if simd_distance(tipPos, knucklePos) > 0.05 {
                extendedCount += 1
            }
        }

        return extendedCount >= 4
    }

    private func isFist(hand: HandState) -> Bool {
        // Check if all fingers are curled
        let fingerTips: [HandSkeleton.JointName] = [
            .indexFingerTip, .middleFingerTip, .ringFingerTip, .littleFingerTip
        ]

        guard let wrist = hand.jointPosition(.wrist) else { return false }

        var curledCount = 0
        for tip in fingerTips {
            guard let tipPos = hand.jointPosition(tip) else { continue }

            if simd_distance(tipPos, wrist) < 0.08 {
                curledCount += 1
            }
        }

        return curledCount >= 3
    }

    // MARK: - Utility Methods

    /// Get the pointing ray from a hand (for raycasting)
    func getPointingRay(for chirality: HandAnchor.Chirality = .right) -> (origin: SIMD3<Float>, direction: SIMD3<Float>)? {
        let hand = chirality == .right ? rightHand : leftHand

        guard let indexTip = hand?.jointPosition(.indexFingerTip),
              let indexKnuckle = hand?.jointPosition(.indexFingerKnuckle) else {
            return nil
        }

        let direction = simd_normalize(indexTip - indexKnuckle)
        return (origin: indexTip, direction: direction)
    }

    /// Get pinch position (midpoint between thumb and index)
    func getPinchPosition(for chirality: HandAnchor.Chirality = .right) -> SIMD3<Float>? {
        let hand = chirality == .right ? rightHand : leftHand

        guard let thumbTip = hand?.thumbTipPosition,
              let indexTip = hand?.indexTipPosition else {
            return nil
        }

        return (thumbTip + indexTip) / 2
    }
}

// MARK: - Hand Tracking Errors

enum HandTrackingError: LocalizedError {
    case notSupported
    case initializationFailed
    case sessionFailed(Error)
    case authorizationDenied

    var errorDescription: String? {
        switch self {
        case .notSupported:
            return "Hand tracking is not supported on this device."
        case .initializationFailed:
            return "Failed to initialize hand tracking."
        case .sessionFailed(let error):
            return "Hand tracking session failed: \(error.localizedDescription)"
        case .authorizationDenied:
            return "Hand tracking permission was denied."
        }
    }
}

// MARK: - Hand Skeleton Joint Names Extension

extension HandSkeleton.JointName: CaseIterable {
    public static var allCases: [HandSkeleton.JointName] {
        [
            .wrist,
            .thumbKnuckle, .thumbIntermediateBase, .thumbIntermediateTip, .thumbTip,
            .indexFingerMetacarpal, .indexFingerKnuckle, .indexFingerIntermediateBase, .indexFingerIntermediateTip, .indexFingerTip,
            .middleFingerMetacarpal, .middleFingerKnuckle, .middleFingerIntermediateBase, .middleFingerIntermediateTip, .middleFingerTip,
            .ringFingerMetacarpal, .ringFingerKnuckle, .ringFingerIntermediateBase, .ringFingerIntermediateTip, .ringFingerTip,
            .littleFingerMetacarpal, .littleFingerKnuckle, .littleFingerIntermediateBase, .littleFingerIntermediateTip, .littleFingerTip,
            .forearmWrist, .forearmArm
        ]
    }
}

// MARK: - Hand Tracking Gesture Delegate

protocol HandTrackingDelegate: AnyObject {
    func handTrackingManager(_ manager: HandTrackingManager, didDetectGesture gesture: HandTrackingManager.HandGesture)
    func handTrackingManager(_ manager: HandTrackingManager, didUpdateHand hand: HandTrackingManager.HandState)
    func handTrackingManager(_ manager: HandTrackingManager, didLoseTrackingFor chirality: HandAnchor.Chirality)
}

// MARK: - SwiftUI Integration

import SwiftUI

/// View modifier that enables hand tracking and provides hand state
struct HandTrackingModifier: ViewModifier {
    @State private var handManager = HandTrackingManager()
    let onGesture: ((HandTrackingManager.HandGesture) -> Void)?
    let onPinch: ((SIMD3<Float>) -> Void)?

    func body(content: Content) -> some View {
        content
            .task {
                do {
                    try await handManager.startTracking()
                } catch {
                    print("Hand tracking error: \(error)")
                }
            }
            .onDisappear {
                handManager.stopTracking()
            }
            .onChange(of: handManager.currentGesture) { _, gesture in
                if let gesture = gesture {
                    onGesture?(gesture)
                }
            }
            .onChange(of: handManager.rightHand?.isPinching) { _, isPinching in
                if isPinching == true, let position = handManager.getPinchPosition() {
                    onPinch?(position)
                }
            }
    }
}

extension View {
    /// Enable hand tracking with gesture callbacks
    func handTracking(
        onGesture: ((HandTrackingManager.HandGesture) -> Void)? = nil,
        onPinch: ((SIMD3<Float>) -> Void)? = nil
    ) -> some View {
        modifier(HandTrackingModifier(onGesture: onGesture, onPinch: onPinch))
    }
}
