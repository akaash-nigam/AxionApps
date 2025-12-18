//
//  SurgicalCoachAI.swift
//  Surgical Training Universe
//
//  AI coaching service for real-time feedback
//

import Foundation

/// AI-powered surgical coaching service
actor SurgicalCoachAI {

    // MARK: - Properties

    private var sessionHistory: [SurgicalMovement] = []
    private var insights: [AIInsight] = []

    // MARK: - Movement Analysis

    /// Analyze a surgical movement and provide real-time feedback
    func analyzeMovement(_ movement: SurgicalMovement) async -> AIInsight? {
        // Add to history
        sessionHistory.append(movement)

        // Analyze movement quality
        if movement.forceApplied > 0.9 {
            return AIInsight(
                category: .safety,
                severity: .high,
                message: "Excessive force detected. Reduce pressure to avoid tissue damage.",
                suggestedAction: "Apply lighter, more controlled pressure"
            )
        }

        if movement.velocity > 0.2 && movement.movementType.requiresPrecision {
            return AIInsight(
                category: .technique,
                severity: .medium,
                message: "Movement too fast for precise operation. Slow down for better control.",
                suggestedAction: "Reduce speed and focus on precision"
            )
        }

        if movement.precisionScore < 0.5 {
            return AIInsight(
                category: .accuracy,
                severity: .medium,
                message: "Imprecise movement detected. Focus on steady hand control.",
                suggestedAction: "Practice slower, more deliberate movements"
            )
        }

        // Positive feedback for good movements
        if movement.isPrecise && movement.movementType.requiresPrecision {
            return AIInsight(
                category: .achievement,
                severity: .info,
                message: "Excellent precision! Movement executed perfectly.",
                suggestedAction: nil
            )
        }

        return nil
    }

    /// Provide comprehensive feedback for a completed session
    func provideFeedback(for session: ProcedureSession) async -> [AIFeedback] {
        var feedback: [AIFeedback] = []

        // Analyze accuracy
        if session.accuracyScore >= 90 {
            feedback.append(AIFeedback(
                type: .positive,
                message: "Outstanding accuracy throughout the procedure",
                suggestion: nil
            ))
        } else if session.accuracyScore < 70 {
            feedback.append(AIFeedback(
                type: .improvement,
                message: "Accuracy needs improvement",
                suggestion: "Practice instrument control exercises to improve precision"
            ))
        }

        // Analyze efficiency
        if session.efficiencyScore >= 85 {
            feedback.append(AIFeedback(
                type: .positive,
                message: "Excellent time management and procedural flow",
                suggestion: nil
            ))
        } else if session.efficiencyScore < 65 {
            feedback.append(AIFeedback(
                type: .improvement,
                message: "Procedure took longer than expected",
                suggestion: "Review procedural steps and practice smooth transitions between phases"
            ))
        }

        // Analyze safety
        if session.safetyScore >= 95 {
            feedback.append(AIFeedback(
                type: .positive,
                message: "Perfect safety record with no complications",
                suggestion: nil
            ))
        } else if session.safetyScore < 80 {
            feedback.append(AIFeedback(
                type: .warning,
                message: "Multiple safety issues detected",
                suggestion: "Review safety protocols and take additional training on complication prevention"
            ))
        }

        // Analyze complications
        if !session.complications.isEmpty {
            let criticalComplications = session.complications.filter { $0.severity == .critical || $0.severity == .high }

            if !criticalComplications.isEmpty {
                feedback.append(AIFeedback(
                    type: .warning,
                    message: "Critical complications occurred during procedure",
                    suggestion: "Review each complication and understand prevention strategies"
                ))
            }
        }

        // Analyze movement patterns
        let preciseMovements = session.movements.filter { $0.isPrecise }
        let precisionRate = Double(preciseMovements.count) / Double(max(session.movements.count, 1))

        if precisionRate >= 0.9 {
            feedback.append(AIFeedback(
                type: .positive,
                message: "Consistently precise movements throughout procedure",
                suggestion: nil
            ))
        }

        return feedback
    }

    /// Predict potential complications based on current technique
    func predictComplications(basedOn movements: [SurgicalMovement]) async -> [PredictedComplication] {
        var predictions: [PredictedComplication] = []

        // Check for excessive force patterns
        let highForceMovements = movements.filter { $0.forceApplied > 0.8 }
        if highForceMovements.count > movements.count / 3 {
            predictions.append(PredictedComplication(
                type: .tissueDamage,
                probability: 0.7,
                severity: .high,
                warning: "Pattern of excessive force may lead to tissue damage"
            ))
        }

        // Check for imprecise movements near critical structures
        let impreciseNearCritical = movements.filter {
            !$0.isPrecise && ($0.affectedRegion == .heart || $0.affectedRegion == .brain)
        }
        if !impreciseNearCritical.isEmpty {
            predictions.append(PredictedComplication(
                type: .nerveDamage,
                probability: 0.6,
                severity: .critical,
                warning: "Imprecise movements near critical structures"
            ))
        }

        return predictions
    }

    /// Suggest next step in procedure
    func suggestNextStep(currentPhase: ProcedurePhase) async -> SuggestedAction {
        switch currentPhase {
        case .preparation:
            return SuggestedAction(
                action: "Begin incision at marked location",
                rationale: "Proper preparation complete, ready to proceed",
                visualCue: "Incision line highlighted"
            )
        case .incision:
            return SuggestedAction(
                action: "Proceed with careful dissection",
                rationale: "Incision complete, expose surgical field",
                visualCue: "Tissue layers highlighted"
            )
        case .dissection:
            return SuggestedAction(
                action: "Identify and isolate target anatomy",
                rationale: "Field exposed, ready for main procedure",
                visualCue: "Target structure highlighted"
            )
        case .mainProcedure:
            return SuggestedAction(
                action: "Perform primary surgical objective",
                rationale: "Anatomy isolated, proceed with main task",
                visualCue: "Procedure steps displayed"
            )
        case .closure:
            return SuggestedAction(
                action: "Begin tissue closure and suturing",
                rationale: "Main procedure complete, close surgical field",
                visualCue: "Closure pattern shown"
            )
        case .complete:
            return SuggestedAction(
                action: "Final inspection and documentation",
                rationale: "Closure complete, verify all objectives met",
                visualCue: "Checklist displayed"
            )
        }
    }

    // MARK: - Session Management

    /// Clear session history
    func clearHistory() {
        sessionHistory.removeAll()
        insights.removeAll()
    }
}

// MARK: - Supporting Types

struct PredictedComplication {
    let type: ComplicationType
    let probability: Double  // 0.0 to 1.0
    let severity: SeverityLevel
    let warning: String
}

struct SuggestedAction {
    let action: String
    let rationale: String
    let visualCue: String
}
