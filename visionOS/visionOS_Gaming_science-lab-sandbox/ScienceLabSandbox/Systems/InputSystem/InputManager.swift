//
//  InputManager.swift
//  Science Lab Sandbox
//
//  Manages all input from hand tracking, eye tracking, and voice
//

import Foundation
import ARKit
import RealityKit

@MainActor
class InputManager: ObservableObject {

    // MARK: - Published Properties

    @Published var leftHandPose: HandPose?
    @Published var rightHandPose: HandPose?
    @Published var gazeTarget: Entity?
    @Published var currentGesture: HandGesture?

    // MARK: - Private Properties

    private var handTracking: HandTrackingProvider?
    private var gestureHistory: [HandGesture] = []
    private let maxGestureHistory = 30  // Keep last 30 gestures

    // MARK: - Initialization

    init() {
        Task {
            await setupHandTracking()
        }
    }

    // MARK: - Hand Tracking Setup

    private func setupHandTracking() async {
        // Hand tracking provider would be initialized here
        // For demonstration purposes, this is a placeholder

        print("✋ Hand tracking initialized")
    }

    // MARK: - Input Processing

    func processInput() {
        // Process hand tracking
        processHandTracking()

        // Process eye tracking
        processEyeTracking()

        // Detect gestures
        detectGestures()
    }

    private func processHandTracking() {
        // In real implementation, update hand poses from ARKit
        // This is a placeholder for the tracking logic
    }

    private func processEyeTracking() {
        // In real implementation, update gaze target from ARKit
        // This is a placeholder for the tracking logic
    }

    // MARK: - Gesture Detection

    private func detectGestures() {
        guard let leftHand = leftHandPose, let rightHand = rightHandPose else {
            return
        }

        // Detect pinch gesture
        if let pinch = detectPinch(leftHand) {
            currentGesture = .pinch(hand: .left, strength: pinch.strength, position: pinch.position)
            addToGestureHistory(currentGesture!)
        } else if let pinch = detectPinch(rightHand) {
            currentGesture = .pinch(hand: .right, strength: pinch.strength, position: pinch.position)
            addToGestureHistory(currentGesture!)
        }

        // Detect pour gesture
        if let pour = detectPour(rightHand) {
            currentGesture = .pour(hand: .right, angle: pour.angle, axis: pour.axis)
            addToGestureHistory(currentGesture!)
        }

        // Detect stir gesture
        if let stir = detectStir(gestureHistory) {
            currentGesture = .stir(radius: stir.radius, speed: stir.speed)
        }
    }

    private func detectPinch(_ hand: HandPose) -> (strength: Float, position: SIMD3<Float>)? {
        // Calculate distance between thumb and index finger
        let distance = simd_distance(hand.thumbTip, hand.indexTip)

        // Pinch threshold: < 2cm
        if distance < 0.02 {
            let strength = 1.0 - (distance / 0.02)
            let position = (hand.thumbTip + hand.indexTip) / 2
            return (strength, position)
        }

        return nil
    }

    private func detectPour(_ hand: HandPose) -> (angle: Float, axis: SIMD3<Float>)? {
        // Detect tilting motion (simplified)
        let upVector = SIMD3<Float>(0, 1, 0)
        let handUp = hand.palmNormal

        let angle = acos(simd_dot(upVector, handUp))

        // Pour threshold: > 30 degrees tilt
        if angle > .pi / 6 {
            let axis = simd_cross(upVector, handUp)
            return (angle, simd_normalize(axis))
        }

        return nil
    }

    private func detectStir(_ history: [HandGesture]) -> (radius: Float, speed: Float)? {
        // Detect circular motion in gesture history (simplified)
        // In real implementation, analyze motion patterns

        return nil
    }

    private func addToGestureHistory(_ gesture: HandGesture) {
        gestureHistory.append(gesture)

        if gestureHistory.count > maxGestureHistory {
            gestureHistory.removeFirst()
        }
    }

    // MARK: - Public Gesture Queries

    func isPinching(hand: HandSide) -> Bool {
        guard case .pinch(let gestureHand, _, _) = currentGesture else {
            return false
        }
        return gestureHand == hand
    }

    func getPinchPosition(hand: HandSide) -> SIMD3<Float>? {
        guard case .pinch(let gestureHand, _, let position) = currentGesture,
              gestureHand == hand else {
            return nil
        }
        return position
    }
}

// MARK: - Hand Pose

struct HandPose {
    var thumbTip: SIMD3<Float>
    var indexTip: SIMD3<Float>
    var middleTip: SIMD3<Float>
    var ringTip: SIMD3<Float>
    var littleTip: SIMD3<Float>
    var palmCenter: SIMD3<Float>
    var palmNormal: SIMD3<Float>
    var wrist: SIMD3<Float>
}

// MARK: - Hand Gesture

enum HandGesture {
    case pinch(hand: HandSide, strength: Float, position: SIMD3<Float>)
    case pour(hand: HandSide, angle: Float, axis: SIMD3<Float>)
    case stir(radius: Float, speed: Float)
    case grab(hand: HandSide, position: SIMD3<Float>)
    case point(hand: HandSide, direction: SIMD3<Float>)
}

enum HandSide {
    case left
    case right
}
