import Foundation
import RealityKit

/// Manages evidence discovery, collection, and analysis
@MainActor
class EvidenceManager {
    // MARK: - Properties

    private var evidenceEntities: [UUID: Entity] = [:]
    private var discoveryStates: [UUID: DiscoveryState] = [:]

    // MARK: - Evidence Discovery

    func checkDiscovery(
        evidence: Evidence,
        playerPosition: SIMD3<Float>,
        gazeDirection: SIMD3<Float>?,
        gazeDuration: TimeInterval,
        activeTool: ForensicToolType?
    ) -> Bool {
        let currentState = discoveryStates[evidence.id] ?? .undiscovered

        guard currentState == .undiscovered else {
            return false  // Already discovered
        }

        // Proximity-based discovery
        let evidencePos = evidence.discoveryLocation.toSIMD()
        let distance = simd_distance(playerPosition, evidencePos)
        let discoveryRadius = 0.5 * evidence.difficulty.rawValue

        if distance <= discoveryRadius {
            return true
        }

        // Gaze-based discovery
        if let gaze = gazeDirection {
            let toEvidence = simd_normalize(evidencePos - playerPosition)
            let dotProduct = simd_dot(gaze, toEvidence)

            if dotProduct > 0.95 {  // Looking directly at evidence
                let requiredDuration = TimeInterval(evidence.difficulty.rawValue)
                if gazeDuration >= requiredDuration {
                    return true
                }
            }
        }

        // Tool-based discovery
        if let tool = activeTool {
            if evidence.requiredTools.contains(tool) {
                return true
            }
        }

        return false
    }

    func markDiscovered(_ evidence: Evidence) {
        discoveryStates[evidence.id] = .discovered
        print("Evidence discovered: \(evidence.name)")
    }

    func markCollected(_ evidence: Evidence) {
        discoveryStates[evidence.id] = .collected
        print("Evidence collected: \(evidence.name)")
    }

    // MARK: - Forensic Analysis

    func analyzeEvidence(_ evidence: Evidence, using tool: ForensicToolType) -> ForensicResult {
        switch tool {
        case .magnifyingGlass:
            return enhanceDetails(of: evidence)

        case .fingerprintKit:
            return extractFingerprints(from: evidence)

        case .uvLight:
            return revealHiddenStains(from: evidence)

        case .swabKit:
            return collectDNA(from: evidence)

        case .cameraEvidence:
            return photographEvidence(evidence)

        case .measurementTape:
            return measureEvidence(evidence)

        case .bloodDetection:
            return detectBlood(in: evidence)

        case .spectrometer:
            return analyzeChemicals(in: evidence)

        case .scanner3D:
            return scan3D(evidence)

        case .notepad:
            return ForensicResult.noResult  // Notes are manual
        }
    }

    // MARK: - Private Analysis Methods

    private func enhanceDetails(of evidence: Evidence) -> ForensicResult {
        var findings: [ForensicResult.Finding] = []
        var clues: [String] = []

        // Check for fine details based on evidence type
        switch evidence.type {
        case .document:
            if let docAnalysis = evidence.forensicData.documentAnalysis {
                clues.append("Document dated: \(docAnalysis.dateWritten?.formatted() ?? "Unknown")")
                clues.append(docAnalysis.significance)
            }

        case .weapon:
            clues.append("Surface shows signs of recent use")
            clues.append("Handle material: synthetic grip")

        case .photograph:
            clues.append("Image shows location at specific time")

        default:
            clues.append("No additional details visible at this magnification")
        }

        return ForensicResult(
            findings: findings,
            confidence: 0.8,
            additionalClues: clues,
            visualData: nil
        )
    }

    private func extractFingerprints(from evidence: Evidence) -> ForensicResult {
        guard let prints = evidence.forensicData.fingerprints, !prints.isEmpty else {
            return ForensicResult(
                findings: [],
                confidence: 1.0,
                additionalClues: ["No fingerprints detected on this surface"],
                visualData: nil
            )
        }

        let findings = prints.map { print in
            ForensicResult.Finding.fingerprint(
                id: print.id.uuidString,
                matchConfidence: print.quality,
                suspectID: print.matchingSuspect
            )
        }

        return ForensicResult(
            findings: findings,
            confidence: prints.first?.quality ?? 0.5,
            additionalClues: ["Fingerprint analysis complete"],
            visualData: "fingerprint_visualization"
        )
    }

    private func revealHiddenStains(from evidence: Evidence) -> ForensicResult {
        var findings: [ForensicResult.Finding] = []
        var clues: [String] = []

        // Check for blood under UV
        if let blood = evidence.forensicData.bloodSpatter {
            findings.append(.bloodSpatter(
                pattern: blood.pattern.rawValue,
                angle: blood.impactAngle
            ))
            clues.append("Blood type: \(blood.bloodType)")
            clues.append("Spatter pattern indicates \(blood.pattern.rawValue) impact")
        }

        // Check for other traces
        if let traces = evidence.forensicData.traces {
            for trace in traces {
                findings.append(.trace(description: trace.description))
            }
        }

        if findings.isEmpty {
            clues.append("No fluorescent materials detected")
        }

        return ForensicResult(
            findings: findings,
            confidence: findings.isEmpty ? 1.0 : 0.9,
            additionalClues: clues,
            visualData: findings.isEmpty ? nil : "uv_glow"
        )
    }

    private func collectDNA(from evidence: Evidence) -> ForensicResult {
        guard let dnaProfiles = evidence.forensicData.dnaProfiles, !dnaProfiles.isEmpty else {
            return ForensicResult(
                findings: [],
                confidence: 1.0,
                additionalClues: ["No DNA sample could be collected from this evidence"],
                visualData: nil
            )
        }

        let findings = dnaProfiles.map { profile in
            ForensicResult.Finding.dna(
                profile: profile.profileData,
                matchSuspect: profile.matchingSuspect
            )
        }

        return ForensicResult(
            findings: findings,
            confidence: dnaProfiles.first?.matchConfidence ?? 0.5,
            additionalClues: ["DNA sample collected and analyzed"],
            visualData: "dna_profile"
        )
    }

    private func photographEvidence(_ evidence: Evidence) -> ForensicResult {
        return ForensicResult(
            findings: [],
            confidence: 1.0,
            additionalClues: [
                "Evidence photograph added to case file",
                "Location: \(evidence.discoveryLocation.x), \(evidence.discoveryLocation.y), \(evidence.discoveryLocation.z)"
            ],
            visualData: "photo_\(evidence.id.uuidString)"
        )
    }

    private func measureEvidence(_ evidence: Evidence) -> ForensicResult {
        // Generate realistic measurements based on evidence type
        let dimensions = generateMeasurements(for: evidence)

        return ForensicResult(
            findings: dimensions,
            confidence: 1.0,
            additionalClues: ["Measurements recorded"],
            visualData: nil
        )
    }

    private func detectBlood(in evidence: Evidence) -> ForensicResult {
        guard let blood = evidence.forensicData.bloodSpatter else {
            return ForensicResult(
                findings: [],
                confidence: 1.0,
                additionalClues: ["No blood traces detected"],
                visualData: nil
            )
        }

        let findings: [ForensicResult.Finding] = [
            .bloodSpatter(pattern: blood.pattern.rawValue, angle: blood.impactAngle),
            .trace(description: "Blood type: \(blood.bloodType)")
        ]

        return ForensicResult(
            findings: findings,
            confidence: 0.95,
            additionalClues: [
                "Luminol reaction positive",
                "Pattern suggests \(blood.pattern.rawValue) type impact"
            ],
            visualData: "luminol_glow"
        )
    }

    private func analyzeChemicals(in evidence: Evidence) -> ForensicResult {
        // Simulate chemical analysis
        let chemicals = ["Sodium", "Carbon compounds", "Organic residue"]
        let randomChemical = chemicals.randomElement() ?? "Unknown"

        return ForensicResult(
            findings: [.chemical(compound: randomChemical, concentration: Float.random(in: 0.1...0.9))],
            confidence: 0.85,
            additionalClues: ["Spectroscopic analysis complete"],
            visualData: "spectrum_graph"
        )
    }

    private func scan3D(_ evidence: Evidence) -> ForensicResult {
        return ForensicResult(
            findings: [],
            confidence: 1.0,
            additionalClues: [
                "3D scan complete",
                "Model saved to case file",
                "Detailed reconstruction available for review"
            ],
            visualData: "3d_model_\(evidence.id.uuidString)"
        )
    }

    private func generateMeasurements(for evidence: Evidence) -> [ForensicResult.Finding] {
        switch evidence.type {
        case .weapon:
            return [
                .measurement(dimension: "Length", value: Float.random(in: 0.15...0.4)),
                .measurement(dimension: "Width", value: Float.random(in: 0.02...0.05))
            ]

        case .trace:
            return [
                .measurement(dimension: "Particle size", value: Float.random(in: 0.001...0.01))
            ]

        default:
            return [
                .measurement(dimension: "Size", value: Float.random(in: 0.05...0.3))
            ]
        }
    }

    // MARK: - Evidence State

    enum DiscoveryState {
        case undiscovered
        case discovered
        case collected
        case analyzed
    }
}
