//
//  ProcedureViewModel.swift
//  SurgicalTrainingUniverse
//
//  ViewModel for active procedure session - manages procedure lifecycle and real-time data
//

import Foundation
import SwiftData
import Observation

@Observable
final class ProcedureViewModel {

    // MARK: - Dependencies

    private let procedureService: ProcedureService
    private let aiCoach: SurgicalCoachAI
    private let modelContext: ModelContext

    // MARK: - Published State

    var currentSession: ProcedureSession?
    var currentUser: SurgeonProfile?
    var isActive = false
    var isPaused = false
    var isLoading = false
    var errorMessage: String?

    // Real-time metrics
    var elapsedTime: TimeInterval = 0
    var currentAccuracy: Double = 0
    var currentEfficiency: Double = 0
    var currentSafety: Double = 100 // Start at 100%, decreases with complications
    var recentInsights: [AIInsight] = []
    var complications: [Complication] = []

    // Procedure state
    var selectedInstrument: InstrumentType?
    var currentPhase: ProcedurePhase = .preparation
    var completedSteps: Set<String> = []

    // MARK: - Computed Properties

    var canStart: Bool {
        currentUser != nil && !isActive && !isLoading
    }

    var canPause: Bool {
        isActive && !isPaused
    }

    var canResume: Bool {
        isActive && isPaused
    }

    var canComplete: Bool {
        isActive && !isPaused
    }

    var canAbort: Bool {
        isActive
    }

    var formattedElapsedTime: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = (Int(elapsedTime) % 3600) / 60
        let seconds = Int(elapsedTime) % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    var formattedAccuracy: String {
        String(format: "%.1f%%", currentAccuracy)
    }

    var formattedEfficiency: String {
        String(format: "%.1f%%", currentEfficiency)
    }

    var formattedSafety: String {
        String(format: "%.1f%%", currentSafety)
    }

    var overallScore: Double {
        (currentAccuracy + currentEfficiency + currentSafety) / 3.0
    }

    var hasComplications: Bool {
        !complications.isEmpty
    }

    var criticalInsights: [AIInsight] {
        recentInsights.filter { $0.severity == .high || $0.severity == .critical }
    }

    var phaseProgress: Double {
        // Calculate progress based on completed steps
        let totalSteps = getProcedureSteps().count
        guard totalSteps > 0 else { return 0 }
        return Double(completedSteps.count) / Double(totalSteps)
    }

    // MARK: - Initialization

    init(
        procedureService: ProcedureService,
        aiCoach: SurgicalCoachAI,
        modelContext: ModelContext,
        currentUser: SurgeonProfile? = nil
    ) {
        self.procedureService = procedureService
        self.aiCoach = aiCoach
        self.modelContext = modelContext
        self.currentUser = currentUser
    }

    // MARK: - Procedure Lifecycle

    /// Start a new procedure
    @MainActor
    func startProcedure(type: ProcedureType) async {
        guard let user = currentUser else {
            errorMessage = "No user logged in"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            currentSession = try await procedureService.startProcedure(
                type: type,
                surgeon: user
            )

            isActive = true
            isPaused = false
            currentPhase = .incision
            elapsedTime = 0

            // Start timer
            startTimer()

        } catch {
            errorMessage = "Failed to start procedure: \(error.localizedDescription)"
        }

        isLoading = false
    }

    /// Pause the current procedure
    @MainActor
    func pauseProcedure() async {
        guard let session = currentSession, canPause else { return }

        do {
            try await procedureService.pauseProcedure(session)
            isPaused = true
            stopTimer()

        } catch {
            errorMessage = "Failed to pause procedure: \(error.localizedDescription)"
        }
    }

    /// Resume the paused procedure
    @MainActor
    func resumeProcedure() async {
        guard let session = currentSession, canResume else { return }

        do {
            try await procedureService.resumeProcedure(session)
            isPaused = false
            startTimer()

        } catch {
            errorMessage = "Failed to resume procedure: \(error.localizedDescription)"
        }
    }

    /// Complete the procedure
    @MainActor
    func completeProcedure() async {
        guard let session = currentSession, canComplete else { return }

        isLoading = true
        stopTimer()

        do {
            let report = try await procedureService.completeProcedure(session)

            // Update final scores
            currentAccuracy = session.accuracyScore
            currentEfficiency = session.efficiencyScore
            currentSafety = session.safetyScore

            isActive = false
            isPaused = false

        } catch {
            errorMessage = "Failed to complete procedure: \(error.localizedDescription)"
        }

        isLoading = false
    }

    /// Abort the procedure
    @MainActor
    func abortProcedure(reason: String) async {
        guard let session = currentSession, canAbort else { return }

        isLoading = true
        stopTimer()

        do {
            try await procedureService.abortProcedure(session, reason: reason)

            isActive = false
            isPaused = false
            currentSession = nil

        } catch {
            errorMessage = "Failed to abort procedure: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Procedure Actions

    /// Record a surgical movement
    @MainActor
    func recordMovement(
        position: SIMD3<Float>,
        velocity: Float,
        force: Float,
        instrument: InstrumentType
    ) async {
        guard let session = currentSession, isActive && !isPaused else { return }

        let movement = SurgicalMovement(
            timestamp: Date(),
            position: position,
            velocity: velocity,
            forceApplied: force,
            precisionScore: calculatePrecision(velocity: velocity, force: force),
            instrumentType: instrument,
            targetReached: false
        )

        await procedureService.recordMovement(session, movement: movement)

        // Get AI feedback
        if let insight = await aiCoach.analyzeMovement(movement) {
            recentInsights.append(insight)
            // Keep only last 10 insights
            if recentInsights.count > 10 {
                recentInsights.removeFirst()
            }
        }

        // Update real-time metrics
        await updateMetrics()
    }

    /// Record a complication
    @MainActor
    func recordComplication(
        type: ComplicationType,
        severity: SeverityLevel,
        description: String
    ) async {
        guard let session = currentSession, isActive else { return }

        let complication = Complication(
            timestamp: Date(),
            type: type,
            severity: severity,
            description: description,
            resolved: false
        )

        complications.append(complication)
        await procedureService.recordComplication(session, complication: complication)

        // Reduce safety score based on severity
        currentSafety -= complication.safetyImpact

        // Get AI guidance
        let insight = AIInsight(
            timestamp: Date(),
            category: .safety,
            severity: .high,
            message: "Complication detected: \(description)",
            suggestedAction: "Review procedure technique and ensure proper instrument use"
        )
        recentInsights.append(insight)
    }

    /// Select an instrument
    func selectInstrument(_ instrument: InstrumentType) {
        selectedInstrument = instrument
    }

    /// Mark a procedure step as complete
    func completeStep(_ stepId: String) {
        completedSteps.insert(stepId)
        updatePhaseIfNeeded()
    }

    // MARK: - Private Methods

    private var timer: Task<Void, Never>?

    private func startTimer() {
        timer = Task {
            while isActive && !isPaused {
                try? await Task.sleep(for: .seconds(1))
                elapsedTime += 1
            }
        }
    }

    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }

    private func updateMetrics() async {
        guard let session = currentSession else { return }

        // Recalculate current scores based on movements
        let movements = session.movements

        if !movements.isEmpty {
            currentAccuracy = movements.reduce(0.0) { $0 + $1.precisionScore } / Double(movements.count)
        }

        // Efficiency based on time and movements
        let expectedMovements = Double(elapsedTime / 5.0) // Expected 1 movement per 5 seconds
        let actualMovements = Double(movements.count)
        currentEfficiency = min(100, (actualMovements / max(expectedMovements, 1.0)) * 100)
    }

    private func calculatePrecision(velocity: Float, force: Float) -> Double {
        // Lower velocity and appropriate force = higher precision
        let velocityScore = max(0, 100 - Double(velocity * 100))
        let forceScore = 100 - abs(Double(force - 0.5) * 100) // Optimal force around 0.5
        return (velocityScore + forceScore) / 2.0
    }

    private func updatePhaseIfNeeded() {
        let progress = phaseProgress

        if progress >= 1.0 {
            advanceToNextPhase()
        }
    }

    private func advanceToNextPhase() {
        switch currentPhase {
        case .preparation:
            currentPhase = .incision
        case .incision:
            currentPhase = .dissection
        case .dissection:
            currentPhase = .procedure
        case .procedure:
            currentPhase = .closure
        case .closure:
            currentPhase = .completion
        case .completion:
            break // Already at final phase
        }
    }

    private func getProcedureSteps() -> [String] {
        // Return steps based on current procedure type
        guard let session = currentSession else { return [] }

        switch session.procedureType {
        case .appendectomy:
            return ["prepare", "incision", "locate_appendix", "dissection", "removal", "closure"]
        case .cholecystectomy:
            return ["prepare", "ports", "insufflation", "identify", "dissect", "remove", "closure"]
        case .laparoscopicSurgery:
            return ["prepare", "ports", "camera", "procedure", "closure"]
        default:
            return ["prepare", "incision", "procedure", "closure"]
        }
    }
}

// MARK: - Supporting Types

enum ProcedurePhase {
    case preparation
    case incision
    case dissection
    case procedure
    case closure
    case completion

    var displayName: String {
        switch self {
        case .preparation: return "Preparation"
        case .incision: return "Incision"
        case .dissection: return "Dissection"
        case .procedure: return "Main Procedure"
        case .closure: return "Closure"
        case .completion: return "Completion"
        }
    }
}

extension Complication {
    var safetyImpact: Double {
        switch severity {
        case .low: return 5.0
        case .medium: return 10.0
        case .high: return 20.0
        case .critical: return 30.0
        }
    }
}
