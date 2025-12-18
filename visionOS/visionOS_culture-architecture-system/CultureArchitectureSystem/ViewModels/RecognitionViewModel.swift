//
//  RecognitionViewModel.swift
//  CultureArchitectureSystem
//
//  Created on 2025-01-20
//

import Foundation
import Observation

@Observable
final class RecognitionViewModel {
    var searchText: String = ""
    var selectedValue: ValueType?
    var message: String = ""
    var visibility: RecognitionVisibility = .team
    var isSubmitting: Bool = false
    var error: Error?

    var canSend: Bool {
        selectedValue != nil && !message.isEmpty
    }

    @MainActor
    func sendRecognition(service: RecognitionService) async {
        guard canSend else { return }
        guard selectedValue != nil else { return }

        isSubmitting = true
        defer { isSubmitting = false }

        do {
            let recognition = Recognition(
                giverAnonymousId: UUID(), // Current user
                receiverAnonymousId: UUID(), // Selected team member
                valueId: UUID(), // Value ID from selection
                message: message,
                visibility: visibility
            )

            // Extract values before crossing actor boundary
            let recognitionId = recognition.id

            try await service.giveRecognition(recognition)

            // Post notification for celebration (using ID only to avoid data race)
            NotificationCenter.default.post(
                name: .recognitionGiven,
                object: recognitionId
            )

            // Reset form
            resetForm()

        } catch {
            self.error = error
        }
    }

    private func resetForm() {
        searchText = ""
        selectedValue = nil
        message = ""
        visibility = .team
    }
}
