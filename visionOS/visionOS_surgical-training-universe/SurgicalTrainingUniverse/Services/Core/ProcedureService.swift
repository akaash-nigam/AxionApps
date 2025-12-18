//
//  ProcedureService.swift
//  Surgical Training Universe
//
//  Core service for managing surgical procedures
//

import Foundation
import SwiftData

/// Service for managing surgical training procedures
@Observable
class ProcedureService {

    // MARK: - Properties

    private let modelContext: ModelContext
    private let analyticsService: AnalyticsService
    private let aiCoach: SurgicalCoachAI

    // MARK: - Current Session

    var currentSession: ProcedureSession?

    // MARK: - Initialization

    init(
        modelContext: ModelContext,
        analyticsService: AnalyticsService = AnalyticsService(),
        aiCoach: SurgicalCoachAI = SurgicalCoachAI()
    ) {
        self.modelContext = modelContext
        self.analyticsService = analyticsService
        self.aiCoach = aiCoach
    }

    // MARK: - Session Management

    /// Start a new procedure session
    func startProcedure(
        type: ProcedureType,
        surgeon: SurgeonProfile,
        model: AnatomicalModel? = nil
    ) async throws -> ProcedureSession {

        // End any existing session
        if let existing = currentSession, existing.status == .inProgress {
            try await abortProcedure(existing, reason: "New session started")
        }

        // Create new session
        let session = ProcedureSession(procedureType: type, surgeon: surgeon)
        modelContext.insert(session)

        // Save context
        try modelContext.save()

        currentSession = session

        print("✅ Started procedure: \(type.rawValue)")

        return session
    }

    /// Update procedure metrics during session
    func updateProcedureMetrics(
        _ session: ProcedureSession,
        movement: SurgicalMovement
    ) async {

        // Add movement to session
        session.addMovement(movement)

        // Get AI analysis
        if let insight = await aiCoach.analyzeMovement(movement) {
            session.addInsight(insight)
        }

        // Update elapsed time
        session.duration = Date().timeIntervalSince(session.startTime)

        // Save changes
        try? modelContext.save()
    }

    /// Complete a procedure session
    func completeProcedure(
        _ session: ProcedureSession
    ) async throws -> PerformanceReport {

        // Mark session as complete
        session.complete()

        // Generate AI feedback
        let feedback = await aiCoach.provideFeedback(for: session)

        // Update surgeon statistics
        session.surgeon.updateStatistics(from: session)

        // Save all changes
        try modelContext.save()

        // Generate performance report
        let report = PerformanceReport(session: session, feedback: feedback)

        // Clear current session
        currentSession = nil

        print("✅ Completed procedure: \(session.procedureType.rawValue)")
        print("   Overall Score: \(Int(session.overallScore))%")

        return report
    }

    /// Abort a procedure session
    func abortProcedure(
        _ session: ProcedureSession,
        reason: String
    ) async throws {

        session.abort(reason: reason)
        try modelContext.save()

        currentSession = nil

        print("⚠️ Aborted procedure: \(reason)")
    }

    /// Pause a procedure session
    func pauseProcedure(_ session: ProcedureSession) async throws {
        session.status = .paused
        try modelContext.save()

        print("⏸ Paused procedure")
    }

    /// Resume a paused procedure session
    func resumeProcedure(_ session: ProcedureSession) async throws {
        session.status = .inProgress
        try modelContext.save()

        print("▶️ Resumed procedure")
    }

    // MARK: - Movement Recording

    /// Record a surgical movement
    func recordMovement(
        type: MovementType,
        instrumentType: InstrumentType,
        startPosition: Position3D,
        endPosition: Position3D,
        forceApplied: Double,
        affectedRegion: AnatomicalRegion
    ) async {

        guard let session = currentSession else { return }

        let movement = SurgicalMovement(
            movementType: type,
            instrumentType: instrumentType,
            startPosition: startPosition,
            endPosition: endPosition,
            forceApplied: forceApplied,
            affectedRegion: affectedRegion
        )

        await updateProcedureMetrics(session, movement: movement)
    }

    /// Record a complication
    func recordComplication(
        type: ComplicationType,
        severity: SeverityLevel,
        description: String
    ) {

        guard let session = currentSession else { return }

        let complication = Complication(
            type: type,
            severity: severity,
            description: description
        )

        session.recordComplication(complication)

        // Generate AI insight for complication
        let insight = AIInsight(
            category: .warning,
            severity: severity,
            message: "Complication detected: \(description)",
            suggestedAction: "Review safety protocols and adjust technique"
        )
        session.addInsight(insight)

        try? modelContext.save()
    }

    // MARK: - Session Queries

    /// Get all sessions for a surgeon
    func getSessions(for surgeon: SurgeonProfile) -> [ProcedureSession] {
        return surgeon.sessions.sorted { $0.startTime > $1.startTime }
    }

    /// Get sessions by procedure type
    func getSessions(
        ofType type: ProcedureType,
        for surgeon: SurgeonProfile
    ) -> [ProcedureSession] {
        return surgeon.sessions
            .filter { $0.procedureType == type }
            .sorted { $0.startTime > $1.startTime }
    }

    /// Get recent sessions
    func getRecentSessions(
        for surgeon: SurgeonProfile,
        limit: Int = 10
    ) -> [ProcedureSession] {
        return Array(getSessions(for: surgeon).prefix(limit))
    }
}

// MARK: - Performance Report

/// Performance report generated after completing a procedure
struct PerformanceReport {
    let session: ProcedureSession
    let feedback: [AIFeedback]

    var overallScore: Double {
        session.overallScore
    }

    var accuracyScore: Double {
        session.accuracyScore
    }

    var efficiencyScore: Double {
        session.efficiencyScore
    }

    var safetyScore: Double {
        session.safetyScore
    }

    var duration: TimeInterval {
        session.duration
    }

    var improvementSuggestions: [String] {
        feedback.compactMap { $0.suggestion }
    }

    var strengths: [String] {
        feedback.filter { $0.type == .positive }.map { $0.message }
    }

    var areasForImprovement: [String] {
        feedback.filter { $0.type == .improvement }.map { $0.message }
    }
}

/// AI-generated feedback
struct AIFeedback {
    enum FeedbackType {
        case positive
        case improvement
        case warning
    }

    let type: FeedbackType
    let message: String
    let suggestion: String?
}
