import Foundation
import ARKit
import RealityKit

/// System for recognizing and responding to player gestures
@MainActor
class GestureRecognitionSystem {

    // MARK: - Properties
    private var handTrackingProvider: HandTrackingProvider?
    private var currentGesture: NarrativeGesture?
    private var gestureCallbacks: [NarrativeGesture: () -> Void] = [:]

    // MARK: - Initialization
    init() {
        Task {
            await setupHandTracking()
        }
    }

    // MARK: - Setup

    private func setupHandTracking() async {
        do {
            let handTracking = HandTrackingProvider()
            self.handTrackingProvider = handTracking
        } catch {
            print("Failed to setup hand tracking: \(error)")
        }
    }

    // MARK: - Gesture Detection

    /// Detect pinch gesture for selection
    func detectPinch(hand: HandSkeleton) -> Bool {
        let thumbTip = hand.joint(.thumbTip)
        let indexTip = hand.joint(.indexFingerTip)

        guard thumbTip.isTracked && indexTip.isTracked else { return false }

        let distance = simd_distance(
            thumbTip.anchorFromJointTransform.columns.3.xyz,
            indexTip.anchorFromJointTransform.columns.3.xyz
        )

        return distance < 0.02 // 2cm threshold
    }

    /// Detect point gesture for targeting
    func detectPoint(hand: HandSkeleton) -> Bool {
        let indexTip = hand.joint(.indexFingerTip)
        let indexMiddle = hand.joint(.indexFingerIntermediateTip)
        let middleTip = hand.joint(.middleFingerTip)

        guard indexTip.isTracked && indexMiddle.isTracked && middleTip.isTracked else {
            return false
        }

        // Index extended, middle finger curled
        let indexExtended = isFingerExtended(hand, finger: .indexFinger)
        let middleCurled = !isFingerExtended(hand, finger: .middleFinger)

        return indexExtended && middleCurled
    }

    /// Detect grab gesture (closed fist)
    func detectGrab(hand: HandSkeleton) -> Bool {
        // All fingers curled
        let allFingersClosed = !isFingerExtended(hand, finger: .indexFinger) &&
                               !isFingerExtended(hand, finger: .middleFinger) &&
                               !isFingerExtended(hand, finger: .ringFinger) &&
                               !isFingerExtended(hand, finger: .littleFinger)

        return allFingersClosed
    }

    /// Detect wave gesture for greeting
    func detectWave(handHistory: [HandSnapshot]) -> Bool {
        guard handHistory.count >= 10 else { return false }

        // Check for lateral movement pattern
        var leftRightMovements = 0
        for i in 1..<handHistory.count {
            let delta = handHistory[i].wristPosition.x - handHistory[i-1].wristPosition.x
            if abs(delta) > 0.05 { // 5cm movement
                leftRightMovements += 1
            }
        }

        return leftRightMovements >= 5 // At least 5 lateral movements
    }

    /// Detect timeout gesture (both palms forward)
    func detectTimeout(leftHand: HandSkeleton?, rightHand: HandSkeleton?) -> Bool {
        guard let left = leftHand, let right = rightHand else { return false }

        // Both palms facing forward
        let leftPalm = isPalmForward(left)
        let rightPalm = isPalmForward(right)

        return leftPalm && rightPalm
    }

    // MARK: - Gesture Processing

    /// Process current hand state and detect gestures
    func processHandInput(
        leftHand: HandSkeleton?,
        rightHand: HandSkeleton?
    ) -> DetectedGesture? {
        // Right hand primary for most gestures
        if let right = rightHand {
            if detectPinch(hand: right) {
                return .pinch
            }
            if detectPoint(hand: right) {
                return .point
            }
            if detectGrab(hand: right) {
                return .grab
            }
        }

        // Two-hand gestures
        if detectTimeout(leftHand: leftHand, rightHand: rightHand) {
            return .timeout
        }

        return nil
    }

    /// Register callback for specific gesture
    func onGesture(_ gesture: NarrativeGesture, perform action: @escaping () -> Void) {
        gestureCallbacks[gesture] = action
    }

    /// Trigger registered callback for gesture
    func triggerGesture(_ gesture: NarrativeGesture) {
        gestureCallbacks[gesture]?()
    }

    // MARK: - Helper Methods

    private func isFingerExtended(_ hand: HandSkeleton, finger: FingerType) -> Bool {
        let tip: HandSkeleton.JointName
        let base: HandSkeleton.JointName

        switch finger {
        case .indexFinger:
            tip = .indexFingerTip
            base = .indexFingerKnuckle
        case .middleFinger:
            tip = .middleFingerTip
            base = .middleFingerKnuckle
        case .ringFinger:
            tip = .ringFingerTip
            base = .ringFingerKnuckle
        case .littleFinger:
            tip = .littleFingerTip
            base = .littleFingerKnuckle
        case .thumb:
            tip = .thumbTip
            base = .thumbKnuckle
        }

        let tipPos = hand.joint(tip).anchorFromJointTransform.columns.3.xyz
        let basePos = hand.joint(base).anchorFromJointTransform.columns.3.xyz

        let distance = simd_distance(tipPos, basePos)
        return distance > 0.08 // 8cm threshold for extended finger
    }

    private func isPalmForward(_ hand: HandSkeleton) -> Bool {
        let wrist = hand.joint(.wrist)
        let middle = hand.joint(.middleFingerKnuckle)

        guard wrist.isTracked && middle.isTracked else { return false }

        // Calculate palm normal
        let wristPos = wrist.anchorFromJointTransform.columns.3.xyz
        let middlePos = middle.anchorFromJointTransform.columns.3.xyz

        let palmNormal = normalize(middlePos - wristPos)
        let forward = SIMD3<Float>(0, 0, -1)

        // Check if palm normal points forward (within 45 degrees)
        let dot = simd_dot(palmNormal, forward)
        return dot > 0.7 // cos(45°) ≈ 0.7
    }
}

// MARK: - Supporting Types

enum NarrativeGesture: String, CaseIterable {
    case point
    case pinch
    case grab
    case push
    case pull
    case wave
    case handToHeart
    case defensivePosture
    case openPalm
    case timeout
    case rewind
}

enum DetectedGesture {
    case point
    case pinch
    case grab
    case wave
    case timeout
}

enum FingerType {
    case thumb
    case indexFinger
    case middleFinger
    case ringFinger
    case littleFinger
}

struct HandSnapshot {
    let timestamp: Date
    let wristPosition: SIMD3<Float>
    let palmOrientation: simd_quatf
}

// MARK: - Extensions

extension SIMD4 where Scalar == Float {
    var xyz: SIMD3<Float> {
        SIMD3<Float>(x, y, z)
    }
}
