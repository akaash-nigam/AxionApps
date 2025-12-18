//
//  InputManager.swift
//  RhythmFlow
//
//  Manages hand tracking and gesture input
//

import Foundation
import ARKit
import RealityKit
import simd

@MainActor
class InputManager {
    // MARK: - Properties
    private var arKitSession: ARKitSession?
    private var handTrackingProvider: HandTrackingProvider?

    // MARK: - State
    private(set) var isHandTrackingActive: Bool = false
    private(set) var currentHandState: HandState?

    // MARK: - Gesture Recognition
    private let gestureRecognizer = GestureRecognizer()

    // MARK: - Initialization
    init() {
        print("🖐️ Input Manager initialized")
    }

    // MARK: - Setup
    func requestHandTrackingAuthorization() async -> Bool {
        let auth = await ARKitSession.requestAuthorization(for: [.handTracking])
        return auth[.handTracking] == .allowed
    }

    func requestWorldSensingAuthorization() async -> Bool {
        let auth = await ARKitSession.requestAuthorization(for: [.worldSensing])
        return auth[.worldSensing] == .allowed
    }

    func startHandTracking() async throws {
        print("🖐️ Starting hand tracking")

        arKitSession = ARKitSession()
        handTrackingProvider = HandTrackingProvider()

        try await arKitSession?.run([handTrackingProvider!])

        isHandTrackingActive = true

        // Start processing hand updates
        startHandTrackingLoop()
    }

    func stopHandTracking() {
        isHandTrackingActive = false
        arKitSession = nil
        handTrackingProvider = nil
        print("🖐️ Hand tracking stopped")
    }

    // MARK: - Hand Tracking Loop
    private func startHandTrackingLoop() {
        Task {
            guard let provider = handTrackingProvider else { return }

            for await update in provider.anchorUpdates where isHandTrackingActive {
                let anchor = update.anchor

                // Update hand state
                if currentHandState == nil {
                    currentHandState = HandState()
                }

                switch anchor.chirality {
                case .left:
                    updateHandState(for: .left, anchor: anchor)
                case .right:
                    updateHandState(for: .right, anchor: anchor)
                }
            }
        }
    }

    private func updateHandState(for hand: Hand, anchor: HandAnchor) {
        guard let skeleton = anchor.handSkeleton else { return }

        // Get key joint positions
        guard let wrist = skeleton.joint(.wrist),
              let indexTip = skeleton.joint(.indexFingerTip),
              let thumbTip = skeleton.joint(.thumbTip) else {
            return
        }

        let wristTransform = anchor.originFromAnchorTransform * wrist.anchorFromJointTransform
        let indexTransform = anchor.originFromAnchorTransform * indexTip.anchorFromJointTransform

        let handData = HandData(
            position: SIMD3<Float>(
                wristTransform.columns.3.x,
                wristTransform.columns.3.y,
                wristTransform.columns.3.z
            ),
            indexTipPosition: SIMD3<Float>(
                indexTransform.columns.3.x,
                indexTransform.columns.3.y,
                indexTransform.columns.3.z
            ),
            isTracked: anchor.isTracked
        )

        // Update state
        switch hand {
        case .left:
            currentHandState?.leftHand = handData
        case .right:
            currentHandState?.rightHand = handData
        case .both:
            break
        }

        // Detect gestures
        if let gesture = gestureRecognizer.detectGesture(from: anchor) {
            handleGesture(gesture, hand: hand)
        }
    }

    private func handleGesture(_ gesture: DetectedGesture, hand: Hand) {
        // TODO: Notify game engine of detected gesture
        print("👋 Detected \(gesture.type) with \(hand) hand")
    }

    // MARK: - Cleanup
    func cleanup() {
        stopHandTracking()
    }
}

// MARK: - Hand State

struct HandState {
    var leftHand: HandData = HandData.zero
    var rightHand: HandData = HandData.zero
}

struct HandData {
    var position: SIMD3<Float>
    var indexTipPosition: SIMD3<Float>
    var isTracked: Bool

    static var zero: HandData {
        HandData(
            position: .zero,
            indexTipPosition: .zero,
            isTracked: false
        )
    }
}

// MARK: - Gesture Recognizer

class GestureRecognizer {
    private var gestureHistory: [GestureSnapshot] = []
    private let historyDuration: TimeInterval = 0.5

    func detectGesture(from handAnchor: HandAnchor) -> DetectedGesture? {
        guard let skeleton = handAnchor.handSkeleton else { return nil }

        // Record snapshot
        let snapshot = GestureSnapshot(
            timestamp: CACurrentMediaTime(),
            handAnchor: handAnchor
        )
        gestureHistory.append(snapshot)

        // Maintain history window
        let cutoffTime = snapshot.timestamp - historyDuration
        gestureHistory.removeAll { $0.timestamp < cutoffTime }

        // Detect punch
        if let punch = detectPunch() {
            return punch
        }

        // Detect swipe
        if let swipe = detectSwipe() {
            return swipe
        }

        return nil
    }

    private func detectPunch() -> DetectedGesture? {
        guard gestureHistory.count >= 3 else { return nil }

        let recent = Array(gestureHistory.suffix(3))

        // Check for rapid forward movement
        // TODO: Implement actual punch detection logic

        return nil
    }

    private func detectSwipe() -> DetectedGesture? {
        guard gestureHistory.count >= 5 else { return nil }

        // TODO: Implement swipe detection logic

        return nil
    }
}

struct GestureSnapshot {
    let timestamp: TimeInterval
    let handAnchor: HandAnchor
}

struct DetectedGesture {
    let type: GestureType
    let confidence: Float
    let direction: SIMD3<Float>
}
