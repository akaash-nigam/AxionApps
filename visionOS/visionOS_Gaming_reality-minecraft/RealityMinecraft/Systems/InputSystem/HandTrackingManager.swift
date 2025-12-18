//
//  HandTrackingManager.swift
//  Reality Minecraft
//
//  Manages hand tracking and gesture recognition
//

import Foundation
import ARKit
import simd

/// Manages hand tracking for visionOS
@MainActor
class HandTrackingManager: ObservableObject {
    @Published private(set) var leftHand: HandState?
    @Published private(set) var rightHand: HandState?
    @Published private(set) var detectedGesture: Gesture?

    private var handTrackingProvider: HandTrackingProvider?
    private var isTracking: Bool = false

    // Gesture recognition
    private let gestureRecognizer = HandGestureRecognizer()

    // MARK: - Lifecycle

    /// Start hand tracking
    func startHandTracking() async {
        print("👋 Starting hand tracking...")

        handTrackingProvider = HandTrackingProvider()

        guard let provider = handTrackingProvider else { return }

        isTracking = true

        // Monitor hand tracking updates
        Task {
            for await update in provider.anchorUpdates {
                handleHandUpdate(update.anchor)
            }
        }

        print("✅ Hand tracking started")
    }

    /// Stop hand tracking
    func stopHandTracking() {
        isTracking = false
        print("⏹ Hand tracking stopped")
    }

    // MARK: - Hand Updates

    private func handleHandUpdate(_ handAnchor: HandAnchor) {
        let handState = HandState(
            chirality: handAnchor.chirality,
            skeleton: handAnchor.handSkeleton
        )

        // Update appropriate hand
        switch handAnchor.chirality {
        case .left:
            leftHand = handState
        case .right:
            rightHand = handState
        }

        // Detect gestures
        detectGestures(handAnchor: handAnchor)
    }

    // MARK: - Gesture Detection

    private func detectGestures(handAnchor: HandAnchor) {
        // Detect pinch
        if gestureRecognizer.detectPinch(hand: handAnchor) {
            detectedGesture = .pinch(chirality: handAnchor.chirality)
            return
        }

        // Detect punch (mining gesture)
        if let previousHand = getPreviousHandState(for: handAnchor.chirality) {
            if gestureRecognizer.detectPunch(
                hand: handAnchor,
                previousPosition: previousHand.wristPosition
            ) {
                detectedGesture = .punch(chirality: handAnchor.chirality)
                return
            }
        }

        // Detect spread (open inventory)
        if gestureRecognizer.detectSpread(hand: handAnchor) {
            detectedGesture = .spread(chirality: handAnchor.chirality)
            return
        }

        detectedGesture = nil
    }

    private func getPreviousHandState(for chirality: HandAnchor.Chirality) -> HandState? {
        switch chirality {
        case .left: return leftHand
        case .right: return rightHand
        }
    }

    // MARK: - Public Interface

    /// Get current hand position
    func getHandPosition(chirality: HandAnchor.Chirality) -> SIMD3<Float>? {
        let handState = chirality == .left ? leftHand : rightHand
        return handState?.wristPosition
    }

    /// Check if specific gesture is detected
    func isGestureDetected(_ gestureType: Gesture) -> Bool {
        return detectedGesture == gestureType
    }
}

// MARK: - Hand State

/// Represents the state of a hand
struct HandState {
    let chirality: HandAnchor.Chirality
    let skeleton: HandSkeleton?

    var wristPosition: SIMD3<Float> {
        guard let wrist = skeleton?.joint(.wrist)?.anchorFromJointTransform else {
            return .zero
        }
        return SIMD3<Float>(wrist.columns.3.x, wrist.columns.3.y, wrist.columns.3.z)
    }

    var indexTipPosition: SIMD3<Float> {
        guard let indexTip = skeleton?.joint(.indexFingerTip)?.anchorFromJointTransform else {
            return .zero
        }
        return SIMD3<Float>(indexTip.columns.3.x, indexTip.columns.3.y, indexTip.columns.3.z)
    }

    var thumbTipPosition: SIMD3<Float> {
        guard let thumbTip = skeleton?.joint(.thumbTip)?.anchorFromJointTransform else {
            return .zero
        }
        return SIMD3<Float>(thumbTip.columns.3.x, thumbTip.columns.3.y, thumbTip.columns.3.z)
    }
}

// MARK: - Gesture Types

/// Hand gesture types
enum Gesture: Equatable {
    case pinch(chirality: HandAnchor.Chirality)
    case punch(chirality: HandAnchor.Chirality)
    case grab(chirality: HandAnchor.Chirality)
    case point(chirality: HandAnchor.Chirality)
    case swipe(direction: SwipeDirection, chirality: HandAnchor.Chirality)
    case spread(chirality: HandAnchor.Chirality)
}

enum SwipeDirection {
    case left, right, up, down
}

// MARK: - Gesture Recognizer

/// Recognizes specific hand gestures
class HandGestureRecognizer {
    // Gesture thresholds
    private let pinchThreshold: Float = 0.02 // 2cm
    private let punchVelocityThreshold: Float = 0.15 // m/s
    private let spreadThreshold: Float = 0.15 // 15cm between fingers

    /// Detect pinch gesture
    func detectPinch(hand: HandAnchor) -> Bool {
        guard let skeleton = hand.handSkeleton else { return false }

        guard let thumbTip = skeleton.joint(.thumbTip)?.anchorFromJointTransform,
              let indexTip = skeleton.joint(.indexFingerTip)?.anchorFromJointTransform else {
            return false
        }

        let thumbPos = SIMD3<Float>(thumbTip.columns.3.x, thumbTip.columns.3.y, thumbTip.columns.3.z)
        let indexPos = SIMD3<Float>(indexTip.columns.3.x, indexTip.columns.3.y, indexTip.columns.3.z)

        let distance = simd_distance(thumbPos, indexPos)
        return distance < pinchThreshold
    }

    /// Detect punch/mining gesture
    func detectPunch(hand: HandAnchor, previousPosition: SIMD3<Float>) -> Bool {
        guard let wrist = hand.handSkeleton?.joint(.wrist)?.anchorFromJointTransform else {
            return false
        }

        let currentPos = SIMD3<Float>(wrist.columns.3.x, wrist.columns.3.y, wrist.columns.3.z)
        let velocity = currentPos - previousPosition

        // Check for forward motion with sufficient speed
        return velocity.z < -0.1 && simd_length(velocity) > punchVelocityThreshold
    }

    /// Detect spread gesture (open hand)
    func detectSpread(hand: HandAnchor) -> Bool {
        guard let skeleton = hand.handSkeleton else { return false }

        guard let thumbTip = skeleton.joint(.thumbTip)?.anchorFromJointTransform,
              let pinkyTip = skeleton.joint(.littleFingerTip)?.anchorFromJointTransform else {
            return false
        }

        let thumbPos = SIMD3<Float>(thumbTip.columns.3.x, thumbTip.columns.3.y, thumbTip.columns.3.z)
        let pinkyPos = SIMD3<Float>(pinkyTip.columns.3.x, pinkyTip.columns.3.y, pinkyTip.columns.3.z)

        let distance = simd_distance(thumbPos, pinkyPos)
        return distance > spreadThreshold
    }

    /// Detect grab gesture
    func detectGrab(hand: HandAnchor) -> Bool {
        guard let skeleton = hand.handSkeleton else { return false }

        // Check if all fingers are close to palm
        let fingerJoints: [HandSkeleton.JointName] = [
            .indexFingerTip,
            .middleFingerTip,
            .ringFingerTip,
            .littleFingerTip
        ]

        guard let palm = skeleton.joint(.wrist)?.anchorFromJointTransform else {
            return false
        }

        let palmPos = SIMD3<Float>(palm.columns.3.x, palm.columns.3.y, palm.columns.3.z)

        let allFingersClosed = fingerJoints.allSatisfy { jointName in
            guard let fingerTip = skeleton.joint(jointName)?.anchorFromJointTransform else {
                return false
            }

            let fingerPos = SIMD3<Float>(fingerTip.columns.3.x, fingerTip.columns.3.y, fingerTip.columns.3.z)
            let distance = simd_distance(fingerPos, palmPos)
            return distance < 0.08 // 8cm threshold for closed fist
        }

        return allFingersClosed
    }
}
