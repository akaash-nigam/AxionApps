//
//  AITutorSystem.swift
//  Science Lab Sandbox
//
//  AI-powered tutoring and guidance system
//

import Foundation

@MainActor
class AITutorSystem: ObservableObject {

    // MARK: - Published Properties

    @Published var currentGuidance: String?
    @Published var availableHints: [String] = []
    @Published var isActive: Bool = false

    // MARK: - Private Properties

    private var currentExperiment: Experiment?
    private var currentSession: ExperimentSession?
    private var guidanceHistory: [TutorMessage] = []

    // MARK: - Experiment Guidance

    func startExperimentGuidance(_ experiment: Experiment, session: ExperimentSession) {
        currentExperiment = experiment
        currentSession = session
        isActive = true

        availableHints = experiment.hints

        let welcome = "Welcome to the \(experiment.name) experiment. I'll be here to guide you through the process. Let's begin!"
        provideGuidance(welcome)
    }

    func stopGuidance() {
        isActive = false
        currentGuidance = nil
        availableHints = []
    }

    // MARK: - Contextual Guidance

    func provideGuidance(_ message: String, category: GuidanceCategory = .general) {
        currentGuidance = message

        let tutorMessage = TutorMessage(
            timestamp: Date(),
            message: message,
            category: category
        )

        guidanceHistory.append(tutorMessage)

        print("🤖 AI Tutor: \(message)")
    }

    func provideStepGuidance(_ step: ExperimentStep) {
        let guidance = """
        Step \(step.stepNumber): \(step.title)
        \(step.instruction)
        """

        provideGuidance(guidance, category: .stepInstruction)

        if !step.safetyWarnings.isEmpty {
            let safetyMessage = "⚠️ Safety: " + step.safetyWarnings.joined(separator: ", ")
            provideGuidance(safetyMessage, category: .safety)
        }
    }

    func provideHint(_ index: Int) {
        guard index < availableHints.count else { return }

        let hint = availableHints[index]
        provideGuidance("💡 Hint: \(hint)", category: .hint)
    }

    // MARK: - Adaptive Support

    func analyzePerformance(session: ExperimentSession) -> PerformanceAnalysis {
        let measurementAccuracy = analyzeMeasurementAccuracy(session.measurements)
        let procedureAdherence = analyzeProcedureAdherence(session)
        let safetyCompliance = session.safetyViolations == 0 ? 1.0 : 0.0

        let overallScore = (measurementAccuracy + procedureAdherence + safetyCompliance) / 3.0

        return PerformanceAnalysis(
            overallScore: overallScore,
            measurementAccuracy: measurementAccuracy,
            procedureAdherence: procedureAdherence,
            safetyCompliance: safetyCompliance,
            feedback: generateFeedback(overallScore)
        )
    }

    private func analyzeMeasurementAccuracy(_ measurements: [Measurement]) -> Double {
        // Simplified analysis
        // In real implementation, compare measurements to expected values
        return measurements.isEmpty ? 0.0 : 0.8
    }

    private func analyzeProcedureAdherence(_ session: ExperimentSession) -> Double {
        guard let experiment = currentExperiment else { return 0.0 }

        let totalSteps = experiment.instructions.count
        let completedSteps = session.stepsCompleted.count

        return Double(completedSteps) / Double(totalSteps)
    }

    private func generateFeedback(_ score: Double) -> String {
        switch score {
        case 0.9...:
            return "Excellent work! You demonstrated strong understanding of the scientific method."
        case 0.7..<0.9:
            return "Good job! You're showing solid grasp of the concepts."
        case 0.5..<0.7:
            return "You're making progress. Review the procedures and try to improve precision."
        default:
            return "Keep practicing! Don't hesitate to use hints when needed."
        }
    }

    // MARK: - Experiment Analysis

    func analyzeExperiment(_ session: ExperimentSession) -> ExperimentAnalysis {
        let performance = analyzePerformance(session: session)

        let methodologyScore = analyzeMethodology(session)
        let dataQualityScore = analyzeDataQuality(session)
        let conclusionScore = analyzeConclusion(session)

        return ExperimentAnalysis(
            performanceAnalysis: performance,
            methodologyScore: methodologyScore,
            dataQualityScore: dataQualityScore,
            conclusionScore: conclusionScore,
            recommendations: generateRecommendations(session)
        )
    }

    private func analyzeMethodology(_ session: ExperimentSession) -> Double {
        var score = 0.5  // Base score

        // Hypothesis formed
        if session.hypothesis != nil {
            score += 0.2
        }

        // Adequate observations
        if session.observations.count >= 3 {
            score += 0.15
        }

        // Adequate measurements
        if session.measurements.count >= 5 {
            score += 0.15
        }

        return min(score, 1.0)
    }

    private func analyzeDataQuality(_ session: ExperimentSession) -> Double {
        var score = 0.5  // Base score

        // Multiple measurements
        if session.measurements.count >= 10 {
            score += 0.2
        }

        // Detailed observations
        if session.observations.count >= 5 {
            score += 0.2
        }

        // Data points for graphs
        if session.dataPoints.count >= 10 {
            score += 0.1
        }

        return min(score, 1.0)
    }

    private func analyzeConclusion(_ session: ExperimentSession) -> Double {
        if let conclusion = session.conclusion, !conclusion.isEmpty {
            // In real implementation, analyze conclusion quality using NLP
            return 0.8
        }
        return 0.0
    }

    private func generateRecommendations(_ session: ExperimentSession) -> [String] {
        var recommendations: [String] = []

        if session.hypothesis == nil {
            recommendations.append("Always form a hypothesis before conducting an experiment")
        }

        if session.measurements.count < 5 {
            recommendations.append("Collect more measurements to improve data reliability")
        }

        if session.observations.count < 3 {
            recommendations.append("Record more detailed observations throughout the experiment")
        }

        if session.safetyViolations > 0 {
            recommendations.append("Review safety protocols to avoid violations in future experiments")
        }

        if session.conclusion == nil {
            recommendations.append("Always write a conclusion summarizing your findings")
        }

        return recommendations
    }

    // MARK: - Update Loop

    func update(deltaTime: TimeInterval) {
        guard isActive else { return }

        // Provide contextual guidance based on experiment state
    }
}

// MARK: - Tutor Message

struct TutorMessage {
    let timestamp: Date
    let message: String
    let category: GuidanceCategory
}

enum GuidanceCategory {
    case general
    case stepInstruction
    case hint
    case safety
    case encouragement
    case correction
}

// MARK: - Performance Analysis

struct PerformanceAnalysis {
    let overallScore: Double
    let measurementAccuracy: Double
    let procedureAdherence: Double
    let safetyCompliance: Double
    let feedback: String
}

// MARK: - Experiment Analysis

struct ExperimentAnalysis {
    let performanceAnalysis: PerformanceAnalysis
    let methodologyScore: Double
    let dataQualityScore: Double
    let conclusionScore: Double
    let recommendations: [String]

    var overallGrade: String {
        let score = (methodologyScore + dataQualityScore + conclusionScore) / 3.0

        switch score {
        case 0.9...: return "A"
        case 0.8..<0.9: return "B"
        case 0.7..<0.8: return "C"
        case 0.6..<0.7: return "D"
        default: return "F"
        }
    }
}
