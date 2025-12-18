//
//  HapticManager.swift
//  PhysicalDigitalTwins
//
//  Manages haptic feedback for user actions
//

import UIKit

@MainActor
class HapticManager {
    static let shared = HapticManager()

    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()

    private init() {
        // Prepare generators for lower latency
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        notificationGenerator.prepare()
        selectionGenerator.prepare()
    }

    // MARK: - Impact Feedback

    func light() {
        impactLight.impactOccurred()
        impactLight.prepare()
    }

    func medium() {
        impactMedium.impactOccurred()
        impactMedium.prepare()
    }

    func heavy() {
        impactHeavy.impactOccurred()
        impactHeavy.prepare()
    }

    // MARK: - Notification Feedback

    func success() {
        notificationGenerator.notificationOccurred(.success)
        notificationGenerator.prepare()
    }

    func warning() {
        notificationGenerator.notificationOccurred(.warning)
        notificationGenerator.prepare()
    }

    func error() {
        notificationGenerator.notificationOccurred(.error)
        notificationGenerator.prepare()
    }

    // MARK: - Selection Feedback

    func selection() {
        selectionGenerator.selectionChanged()
        selectionGenerator.prepare()
    }

    // MARK: - Contextual Feedback

    func itemAdded() {
        success()
    }

    func itemDeleted() {
        medium()
    }

    func itemScanned() {
        success()
    }

    func photoAdded() {
        light()
    }

    func photoDeleted() {
        medium()
    }

    func buttonTap() {
        light()
    }
}
