//
//  AnalyticsService.swift
//  CorporateUniversity
//

import Foundation

@Observable
class AnalyticsService: @unchecked Sendable {
    private let networkClient: NetworkClient
    private var eventQueue: [AnalyticsEvent] = []

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func trackEvent(_ event: AnalyticsEvent) async {
        // Store locally
        eventQueue.append(event)

        // Batch send to server (simplified)
        if eventQueue.count >= 10 {
            await sendEvents()
        }
    }

    func getLearnerAnalytics(learnerId: UUID) async throws -> LearnerAnalytics {
        // Mock implementation
        return LearnerAnalytics(
            userId: learnerId,
            coursesEnrolled: 5,
            coursesCompleted: 2,
            totalTimeSpent: 72000, // 20 hours
            averageScore: 88.5,
            achievements: 8
        )
    }

    private func sendEvents() async {
        // In production: send to analytics endpoint
        print("Sending \(eventQueue.count) analytics events")
        eventQueue.removeAll()
    }
}

struct AnalyticsEvent {
    let type: EventType
    let timestamp: Date
    let data: [String: Any]

    enum EventType {
        case lessonStarted
        case lessonCompleted
        case assessmentStarted
        case assessmentCompleted
        case courseEnrolled
        case spatialInteraction
    }
}

struct LearnerAnalytics: Codable {
    let userId: UUID
    let coursesEnrolled: Int
    let coursesCompleted: Int
    let totalTimeSpent: TimeInterval
    let averageScore: Double
    let achievements: Int
}
