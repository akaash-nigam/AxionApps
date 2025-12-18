import Foundation
import SwiftData

@Model
class MeetingAnalytics {
    @Attribute(.unique) var id: UUID
    var meetingId: UUID

    // Participation metrics
    var totalParticipants: Int
    var peakParticipants: Int
    var averageParticipants: Double
    var participantDurations: [UUID: TimeInterval]

    // Engagement metrics
    var totalSpeakingTime: TimeInterval
    var speakingDistribution: [UUID: TimeInterval]
    var interactionCount: Int
    var contentShareCount: Int
    var annotationCount: Int

    // Content metrics
    var documentsShared: Int
    var whiteboardsCreated: Int
    var models3DViewed: Int

    // Meeting quality
    var averageEngagementScore: Double
    var meetingEffectivenessScore: Double
    var technicalIssuesCount: Int
    var audioQualityScore: Double

    // Outcomes
    var decisionsCount: Int
    var actionItemsCreated: Int
    var followUpMeetingsScheduled: Int

    var calculatedAt: Date

    init(meetingId: UUID) {
        self.id = UUID()
        self.meetingId = meetingId
        self.totalParticipants = 0
        self.peakParticipants = 0
        self.averageParticipants = 0
        self.participantDurations = [:]
        self.totalSpeakingTime = 0
        self.speakingDistribution = [:]
        self.interactionCount = 0
        self.contentShareCount = 0
        self.annotationCount = 0
        self.documentsShared = 0
        self.whiteboardsCreated = 0
        self.models3DViewed = 0
        self.averageEngagementScore = 0
        self.meetingEffectivenessScore = 0
        self.technicalIssuesCount = 0
        self.audioQualityScore = 0
        self.decisionsCount = 0
        self.actionItemsCreated = 0
        self.followUpMeetingsScheduled = 0
        self.calculatedAt = Date()
    }

    // Analytics calculations
    func updateEngagementScore() {
        // Calculate average engagement based on participation
        let totalTime = participantDurations.values.reduce(0, +)
        let avgTime = totalTime / Double(max(participantDurations.count, 1))
        averageEngagementScore = min(avgTime / 3600.0, 1.0) // Normalized to 1 hour
    }

    func updateEffectivenessScore() {
        // Calculate effectiveness based on multiple factors
        var score = 0.0

        // Participation factor (30%)
        if totalParticipants > 0 {
            score += 0.3 * (Double(peakParticipants) / Double(totalParticipants))
        }

        // Engagement factor (30%)
        score += 0.3 * averageEngagementScore

        // Collaboration factor (20%)
        let collaborationScore = Double(contentShareCount + annotationCount + whiteboardsCreated) / 10.0
        score += 0.2 * min(collaborationScore, 1.0)

        // Outcomes factor (20%)
        let outcomesScore = Double(decisionsCount + actionItemsCreated) / 5.0
        score += 0.2 * min(outcomesScore, 1.0)

        meetingEffectivenessScore = min(score, 1.0)
    }
}
