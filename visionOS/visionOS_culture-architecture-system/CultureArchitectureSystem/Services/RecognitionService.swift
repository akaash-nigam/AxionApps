//
//  RecognitionService.swift
//  CultureArchitectureSystem
//
//  Created on 2025-01-20
//

import Foundation
import SwiftData

actor RecognitionService {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    // MARK: - Public Methods

    func giveRecognition(_ recognition: Recognition) async throws {
        // Send to API
        print("Sending recognition: \(recognition.id)")

        // In production, would call:
        // try await apiClient.createRecognition(recognition)

        // Trigger celebration notification
        NotificationCenter.default.post(
            name: .recognitionGiven,
            object: recognition
        )
    }

    func fetchRecentRecognitions(for teamId: UUID, limit: Int = 10) async throws -> [Recognition] {
        // Mock data for MVP
        return (0..<limit).map { _ in
            Recognition.mock()
        }
    }

    func fetchRecognitionCount(for anonymousId: UUID) async throws -> Int {
        // Return count of recognitions received
        return Int.random(in: 5...25)
    }
}
