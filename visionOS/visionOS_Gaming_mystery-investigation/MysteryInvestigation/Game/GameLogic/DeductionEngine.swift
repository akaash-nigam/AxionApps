import Foundation

/// AI-powered deduction and evidence analysis engine
@MainActor
class DeductionEngine {
    // MARK: - Evidence Analysis

    func analyzeEvidence(_ evidence: [Evidence]) -> [EvidenceConnection] {
        var connections: [EvidenceConnection] = []

        // Find temporal connections (evidence from same time)
        connections.append(contentsOf: findTemporalConnections(evidence))

        // Find spatial connections (evidence found near each other)
        connections.append(contentsOf: findSpatialConnections(evidence))

        // Find forensic connections (DNA, fingerprints match)
        connections.append(contentsOf: findForensicConnections(evidence))

        // Find logical connections
        connections.append(contentsOf: findLogicalConnections(evidence))

        return connections.sorted { $0.confidence > $1.confidence }
    }

    // MARK: - Hypothesis Generation

    func generateHypotheses(
        from evidence: [Evidence],
        suspects: [Suspect]
    ) -> [Hypothesis] {
        var hypotheses: [Hypothesis] = []

        // Generate hypothesis for each suspect
        for suspect in suspects {
            let relevantEvidence = evidence.filter { ev in
                ev.relatedSuspects.contains(suspect.id)
            }

            guard !relevantEvidence.isEmpty else {
                continue
            }

            let hypothesis = Hypothesis(
                id: UUID(),
                title: "\(suspect.name) as culprit",
                description: generateMotiveDescription(for: suspect, evidence: relevantEvidence),
                supportingEvidence: relevantEvidence.map { $0.id },
                contradictingEvidence: findContradictingEvidence(suspect: suspect, allEvidence: evidence),
                confidenceScore: calculateSuspectGuiltScore(suspect: suspect, evidence: relevantEvidence),
                isCorrect: suspect.isActualCulprit
            )

            hypotheses.append(hypothesis)
        }

        return hypotheses.sorted { $0.confidenceScore > $1.confidenceScore }
    }

    // MARK: - Confidence Calculation

    func calculateConfidence(for evidence: [Evidence]) -> Float {
        guard !evidence.isEmpty else { return 0.0 }

        var totalWeight: Float = 0.0
        var totalConfidence: Float = 0.0

        for ev in evidence {
            let weight = evidenceWeight(for: ev.type)
            totalWeight += weight

            // Calculate evidence reliability
            var evidenceConfidence: Float = 1.0

            // Forensic evidence is highly reliable
            if ev.forensicData.fingerprints != nil || ev.forensicData.dnaProfiles != nil {
                evidenceConfidence *= 0.95
            }

            // Red herrings reduce confidence
            if ev.isRedHerring {
                evidenceConfidence *= 0.1
            }

            totalConfidence += evidenceConfidence * weight
        }

        return totalWeight > 0 ? totalConfidence / totalWeight : 0.0
    }

    // MARK: - Private Methods

    private func findTemporalConnections(_ evidence: [Evidence]) -> [EvidenceConnection] {
        var connections: [EvidenceConnection] = []

        for i in 0..<evidence.count {
            for j in (i+1)..<evidence.count {
                let ev1 = evidence[i]
                let ev2 = evidence[j]

                // Check if they have timeline relevance at similar times
                if let time1 = ev1.timelineRelevance?.eventID,
                   let time2 = ev2.timelineRelevance?.eventID,
                   time1 == time2 {
                    connections.append(EvidenceConnection(
                        evidence1: ev1.id,
                        evidence2: ev2.id,
                        relationshipType: .temporal,
                        confidence: 0.8
                    ))
                }
            }
        }

        return connections
    }

    private func findSpatialConnections(_ evidence: [Evidence]) -> [EvidenceConnection] {
        var connections: [EvidenceConnection] = []

        for i in 0..<evidence.count {
            for j in (i+1)..<evidence.count {
                let ev1 = evidence[i]
                let ev2 = evidence[j]

                let distance = simd_distance(
                    ev1.discoveryLocation.toSIMD(),
                    ev2.discoveryLocation.toSIMD()
                )

                // Evidence found within 1 meter of each other
                if distance < 1.0 {
                    let confidence = 1.0 - (distance / 1.0)  // Closer = higher confidence
                    connections.append(EvidenceConnection(
                        evidence1: ev1.id,
                        evidence2: ev2.id,
                        relationshipType: .spatial,
                        confidence: confidence
                    ))
                }
            }
        }

        return connections
    }

    private func findForensicConnections(_ evidence: [Evidence]) -> [EvidenceConnection] {
        var connections: [EvidenceConnection] = []

        for i in 0..<evidence.count {
            for j in (i+1)..<evidence.count {
                let ev1 = evidence[i]
                let ev2 = evidence[j]

                // Check for matching fingerprints
                if let prints1 = ev1.forensicData.fingerprints,
                   let prints2 = ev2.forensicData.fingerprints {
                    for p1 in prints1 {
                        for p2 in prints2 {
                            if p1.matchingSuspect == p2.matchingSuspect,
                               let _ = p1.matchingSuspect {
                                connections.append(EvidenceConnection(
                                    evidence1: ev1.id,
                                    evidence2: ev2.id,
                                    relationshipType: .forensic,
                                    confidence: min(p1.quality, p2.quality)
                                ))
                            }
                        }
                    }
                }

                // Check for matching DNA
                if let dna1 = ev1.forensicData.dnaProfiles,
                   let dna2 = ev2.forensicData.dnaProfiles {
                    for d1 in dna1 {
                        for d2 in dna2 {
                            if d1.matchingSuspect == d2.matchingSuspect,
                               let _ = d1.matchingSuspect {
                                connections.append(EvidenceConnection(
                                    evidence1: ev1.id,
                                    evidence2: ev2.id,
                                    relationshipType: .forensic,
                                    confidence: min(d1.matchConfidence, d2.matchConfidence)
                                ))
                            }
                        }
                    }
                }
            }
        }

        return connections
    }

    private func findLogicalConnections(_ evidence: [Evidence]) -> [EvidenceConnection] {
        var connections: [EvidenceConnection] = []

        for i in 0..<evidence.count {
            for j in (i+1)..<evidence.count {
                let ev1 = evidence[i]
                let ev2 = evidence[j]

                // Weapon and blood evidence
                if (ev1.type == .weapon && ev2.type == .biological) ||
                   (ev2.type == .weapon && ev1.type == .biological) {
                    connections.append(EvidenceConnection(
                        evidence1: ev1.id,
                        evidence2: ev2.id,
                        relationshipType: .logical,
                        confidence: 0.9
                    ))
                }

                // Document and related suspect
                let sharedSuspects = Set(ev1.relatedSuspects).intersection(Set(ev2.relatedSuspects))
                if !sharedSuspects.isEmpty {
                    connections.append(EvidenceConnection(
                        evidence1: ev1.id,
                        evidence2: ev2.id,
                        relationshipType: .logical,
                        confidence: 0.7
                    ))
                }
            }
        }

        return connections
    }

    private func generateMotiveDescription(for suspect: Suspect, evidence: [Evidence]) -> String {
        // Simple motive generation based on relationship and evidence
        let relationship = suspect.relationship.lowercased()

        if relationship.contains("business") || relationship.contains("partner") {
            return "Financial motive - business dispute or monetary gain"
        } else if relationship.contains("spouse") || relationship.contains("partner") {
            return "Personal motive - relationship conflict"
        } else if relationship.contains("friend") || relationship.contains("family") {
            return "Personal motive - betrayal or conflict"
        } else {
            return "Motive unclear - requires further investigation"
        }
    }

    private func findContradictingEvidence(suspect: Suspect, allEvidence: [Evidence]) -> [UUID] {
        // Find evidence that doesn't link to this suspect
        return allEvidence
            .filter { !$0.relatedSuspects.contains(suspect.id) && !$0.isRedHerring }
            .map { $0.id }
    }

    private func calculateSuspectGuiltScore(suspect: Suspect, evidence: [Evidence]) -> Float {
        var score: Float = 0.0

        // Base score from AI confidence
        score += suspect.guiltyConfidenceScore * 0.4

        // Evidence linking to suspect
        let evidenceCount = Float(evidence.count)
        score += min(0.3, evidenceCount * 0.1)

        // Weak alibi increases score
        if !suspect.alibi.isVerifiable {
            score += 0.15
        }

        score += (1.0 - suspect.alibi.consistencyScore) * 0.15

        return min(1.0, score)
    }

    private func evidenceWeight(for type: Evidence.EvidenceType) -> Float {
        switch type {
        case .weapon:
            return 1.0
        case .biological:
            return 0.95
        case .fingerprint:
            return 0.9
        case .document:
            return 0.7
        case .photograph:
            return 0.6
        case .trace:
            return 0.5
        case .testimony:
            return 0.4
        case .personal, .environmental, .electronic:
            return 0.5
        }
    }
}

// MARK: - Supporting Types

extension Hypothesis {
    func evaluate(against solution: CaseSolution) -> HypothesisEvaluation {
        let correctEvidence = supportingEvidence.filter { evidenceID in
            solution.relevantEvidenceIDs.contains(evidenceID)
        }

        let accuracy = Float(correctEvidence.count) / Float(max(1, supportingEvidence.count))

        return HypothesisEvaluation(
            accuracy: accuracy,
            missingEvidence: solution.relevantEvidenceIDs.filter { !supportingEvidence.contains($0) },
            extraneousEvidence: supportingEvidence.filter { !solution.relevantEvidenceIDs.contains($0) },
            isCorrect: accuracy > 0.8 && (isCorrect ?? false)
        )
    }
}

struct HypothesisEvaluation {
    let accuracy: Float
    let missingEvidence: [UUID]
    let extraneousEvidence: [UUID]
    let isCorrect: Bool
}
