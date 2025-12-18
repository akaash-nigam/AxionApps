//
//  HandTrackingManager.swift
//  Spatial Arena Championship
//
//  Hand tracking input manager
//

import Foundation
import ARKit
import simd

// MARK: - Hand Tracking Manager

@MainActor
class HandTrackingManager: ObservableObject {
    private var handTrackingProvider: HandTrackingProvider?
    private var arkitSession: ARKitSession?

    @Published var leftHand: HandAnchor?
    @Published var rightHand: HandAnchor?
    @Published var currentInput: HandInput = .zero

    init() {
        setupHandTracking()
    }

    // MARK: - Setup

    private func setupHandTracking() {
        guard HandTrackingProvider.isSupported else {
            print("Hand tracking not supported")
            return
        }

        arkitSession = ARKitSession()
        handTrackingProvider = HandTrackingProvider()
    }

    func start() async throws {
        guard let session = arkitSession,
              let provider = handTrackingProvider else {
            throw GameError.invalidGameState
        }

        try await session.run([provider])
    }

    func stop() async {
        arkitSession?.stop()
    }

    // MARK: - Update

    func update() async {
        guard let provider = handTrackingProvider else { return }

        // Update hand anchors
        for await update in provider.anchorUpdates {
            switch update.event {
            case .added, .updated:
                if update.anchor.chirality == .left {
                    leftHand = update.anchor
                } else {
                    rightHand = update.anchor
                }
            case .removed:
                if update.anchor.chirality == .left {
                    leftHand = nil
                } else {
                    rightHand = nil
                }
            }
        }

        // Process gestures
        updateCurrentInput()
    }

    private func updateCurrentInput() {
        guard let left = leftHand, let right = rightHand else {
            currentInput = .zero
            return
        }

        var input = HandInput()

        // Detect pointing gesture (right hand for firing)
        if isPointing(right) {
            input.aimDirection = getPointingDirection(right)
            input.firePressed = isPinching(right)
        }

        // Detect shield gesture (both palms forward)
        if isPalmForward(left) && isPalmForward(right) {
            input.shieldActive = true
        }

        // Detect ultimate gesture (both hands raised)
        if areHandsRaised(left, right) {
            input.ultimatePressed = true
        }

        // Detect dash gesture (swipe)
        if let swipeDirection = detectSwipe(right) {
            input.dashDirection = swipeDirection
            input.dashPressed = true
        }

        currentInput = input
    }

    // MARK: - Gesture Recognition

    private func isPointing(_ hand: HandAnchor) -> Bool {
        guard let skeleton = hand.handSkeleton else { return false }

        let indexTip = skeleton.joint(.indexFingerTip)
        let indexBase = skeleton.joint(.indexFingerMetacarpal)
        let middleTip = skeleton.joint(.middleFingerTip)
        let wrist = skeleton.joint(.wrist)

        // Index finger extended
        let indexExtended = distance(indexTip.anchorFromJointTransform.translation,
                                    indexBase.anchorFromJointTransform.translation) > 0.08

        // Middle finger curled
        let middleCurled = distance(middleTip.anchorFromJointTransform.translation,
                                   wrist.anchorFromJointTransform.translation) < 0.10

        return indexExtended && middleCurled
    }

    private func getPointingDirection(_ hand: HandAnchor) -> SIMD3<Float> {
        guard let skeleton = hand.handSkeleton else { return [0, 0, -1] }

        let indexTip = skeleton.joint(.indexFingerTip)
        let wrist = skeleton.joint(.wrist)

        let direction = indexTip.anchorFromJointTransform.translation -
                       wrist.anchorFromJointTransform.translation

        return normalize(direction)
    }

    private func isPinching(_ hand: HandAnchor) -> Bool {
        guard let skeleton = hand.handSkeleton else { return false }

        let thumbTip = skeleton.joint(.thumbTip)
        let indexTip = skeleton.joint(.indexFingerTip)

        let distance = distance(thumbTip.anchorFromJointTransform.translation,
                               indexTip.anchorFromJointTransform.translation)

        return distance < 0.02 // 2cm threshold
    }

    private func isPalmForward(_ hand: HandAnchor) -> Bool {
        guard let skeleton = hand.handSkeleton else { return false }

        let wrist = skeleton.joint(.wrist)
        let middleTip = skeleton.joint(.middleFingerTip)

        // Palm normal (approximate)
        let palmDirection = middleTip.anchorFromJointTransform.translation -
                           wrist.anchorFromJointTransform.translation

        let palmNormal = normalize(palmDirection)

        // Check if palm is facing forward (z-axis)
        let forwardDot = dot(palmNormal, SIMD3<Float>(0, 0, -1))

        return forwardDot > 0.7 // 45-degree threshold
    }

    private func areHandsRaised(_ left: HandAnchor, _ right: HandAnchor) -> Bool {
        guard let leftSkeleton = left.handSkeleton,
              let rightSkeleton = right.handSkeleton else { return false }

        let leftWrist = leftSkeleton.joint(.wrist)
        let rightWrist = rightSkeleton.joint(.wrist)

        // Check if both wrists are above a certain height
        let leftHeight = leftWrist.anchorFromJointTransform.translation.y
        let rightHeight = rightWrist.anchorFromJointTransform.translation.y

        return leftHeight > 1.6 && rightHeight > 1.6 // Above head height
    }

    private func detectSwipe(_ hand: HandAnchor) -> SIMD3<Float>? {
        // TODO: Implement swipe detection with velocity tracking
        // For now, return nil
        return nil
    }

    private func areHandsTogether(_ left: HandAnchor, _ right: HandAnchor) -> Bool {
        guard let leftSkeleton = left.handSkeleton,
              let rightSkeleton = right.handSkeleton else { return false }

        let leftWrist = leftSkeleton.joint(.wrist)
        let rightWrist = rightSkeleton.joint(.wrist)

        let distance = distance(leftWrist.anchorFromJointTransform.translation,
                               rightWrist.anchorFromJointTransform.translation)

        return distance < 0.15 // 15cm threshold
    }

    // MARK: - Utility

    private func distance(_ a: SIMD3<Float>, _ b: SIMD3<Float>) -> Float {
        return simd_distance(a, b)
    }
}

// MARK: - Hand Input

struct HandInput {
    var aimDirection: SIMD3<Float> = [0, 0, -1]
    var firePressed: Bool = false
    var shieldActive: Bool = false
    var dashPressed: Bool = false
    var dashDirection: SIMD3<Float> = .zero
    var ultimatePressed: Bool = false

    static let zero = HandInput()
}
