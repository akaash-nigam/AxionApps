import Foundation
import RealityKit

/// Represents a complete investigation case
struct Case: Codable, Identifiable {
    let id: UUID
    let title: String
    let description: String
    let difficulty: DifficultyLevel
    let estimatedDuration: TimeInterval
    let genre: CaseGenre

    var evidence: [Evidence]
    var suspects: [Suspect]
    var locations: [CrimeSceneLocation]
    var solution: CaseSolution
    var timeline: CaseTimeline

    // Metadata
    let author: String
    let createdDate: Date
    var tags: [String]

    enum CaseGenre: String, Codable {
        case classicMystery
        case modernThriller
        case historical
        case sciFi
        case noir
        case trueCrimeInspired
        case educational
        case comedy
    }
}

/// Represents a piece of evidence in the investigation
struct Evidence: Codable, Identifiable {
    let id: UUID
    let type: EvidenceType
    let name: String
    let description: String
    let discoveryLocation: SpatialCoordinate

    var forensicData: ForensicData
    var relatedSuspects: [UUID]
    var timelineRelevance: TimelinePoint?
    var isRedHerring: Bool
    var requiredTools: [ForensicToolType]
    var difficulty: DiscoveryDifficulty

    // 3D Model Reference
    var modelName: String
    var scale: Float = 1.0

    enum EvidenceType: String, Codable {
        case weapon
        case document
        case biological  // Blood, DNA
        case trace       // Fibers, hair
        case fingerprint
        case photograph
        case electronic  // Phone, computer
        case personal    // Belongings
        case environmental  // Room condition
        case testimony
    }

    enum DiscoveryDifficulty: Float, Codable {
        case obvious = 0.5
        case moderate = 1.0
        case challenging = 1.5
        case expert = 2.0
    }
}

/// Spatial coordinate system for evidence placement
struct SpatialCoordinate: Codable {
    let x: Float  // meters from origin
    let y: Float  // meters from floor
    let z: Float  // meters from origin
    var anchorID: UUID?  // ARKit anchor reference

    func toRealityKitTransform() -> Transform {
        Transform(translation: SIMD3(x, y, z))
    }

    func toSIMD() -> SIMD3<Float> {
        SIMD3(x, y, z)
    }
}

/// Forensic analysis data
struct ForensicData: Codable {
    var fingerprints: [Fingerprint]?
    var dnaProfiles: [DNAProfile]?
    var bloodSpatter: BloodSpatterAnalysis?
    var traces: [TraceEvidence]?
    var photographs: [EvidencePhoto]?
    var documentAnalysis: DocumentAnalysis?
}

struct Fingerprint: Codable, Identifiable {
    let id: UUID
    let pattern: FingerprintPattern
    let quality: Float  // 0.0 - 1.0
    let matchingSuspect: UUID?

    enum FingerprintPattern: String, Codable {
        case loop, whorl, arch, composite
    }
}

struct DNAProfile: Codable, Identifiable {
    let id: UUID
    let profileData: String  // Simplified representation
    let matchConfidence: Float  // 0.0 - 1.0
    let matchingSuspect: UUID?
}

struct BloodSpatterAnalysis: Codable {
    let pattern: SpatterPattern
    let impactAngle: Float
    let originPoint: SpatialCoordinate
    let bloodType: String

    enum SpatterPattern: String, Codable {
        case impact, cast-off, arterial, transfer
    }
}

struct TraceEvidence: Codable, Identifiable {
    let id: UUID
    let type: TraceType
    let description: String
    let matchingSuspect: UUID?

    enum TraceType: String, Codable {
        case fiber, hair, glass, soil, gunpowder
    }
}

struct EvidencePhoto: Codable, Identifiable {
    let id: UUID
    let imageName: String
    let timestamp: Date
    let location: SpatialCoordinate
}

struct DocumentAnalysis: Codable {
    let content: String
    let handwritingMatch: UUID?  // Matching suspect
    let dateWritten: Date?
    let significance: String
}

/// Represents a suspect or witness
struct Suspect: Codable, Identifiable {
    let id: UUID
    let name: String
    let age: Int
    let occupation: String
    let relationship: String  // Relationship to victim/case

    var alibi: Alibi
    var behaviorProfile: BehaviorProfile
    var dialogue: DialogueTree
    var appearance: CharacterAppearance

    // Investigation data
    var guiltyConfidenceScore: Float = 0.5  // AI-calculated
    var interrogationHistory: [InterrogationSession] = []
    var isActualCulprit: Bool = false
}

struct Alibi: Codable {
    let statement: String
    let timeframe: DateInterval
    let witnesses: [UUID]  // Other suspects who can verify
    let isVerifiable: Bool
    let consistencyScore: Float  // How consistent their story is
}

struct BehaviorProfile: Codable {
    let baselineStress: Float  // Normal stress level (0.0 - 1.0)
    let personality: PersonalityType
    let lyingTendency: Float  // How likely to lie (0.0 - 1.0)
    let cooperationLevel: Float  // Willingness to help (0.0 - 1.0)

    enum PersonalityType: String, Codable {
        case calm, nervous, aggressive, charming, defensive, helpful
    }
}

struct CharacterAppearance: Codable {
    let modelName: String
    let height: Float  // meters
    let buildType: BuildType
    let distinctiveFeatures: [String]

    enum BuildType: String, Codable {
        case slim, average, athletic, heavy
    }
}

/// Crime scene location
struct CrimeSceneLocation: Codable, Identifiable {
    let id: UUID
    let name: String
    let description: String
    let type: LocationType
    let spatialBounds: SpatialBounds

    enum LocationType: String, Codable {
        case indoor, outdoor, vehicle, publicSpace, residence
    }
}

struct SpatialBounds: Codable {
    let minX: Float
    let maxX: Float
    let minY: Float
    let maxY: Float
    let minZ: Float
    let maxZ: Float

    func contains(_ point: SIMD3<Float>) -> Bool {
        return point.x >= minX && point.x <= maxX &&
               point.y >= minY && point.y <= maxY &&
               point.z >= minZ && point.z <= maxZ
    }
}

/// Case solution
struct CaseSolution: Codable {
    let culpritID: UUID
    let motive: String
    let methodDescription: String
    let relevantEvidenceIDs: [UUID]
    let timelineOfEvents: [TimelineEvent]

    func evaluate(against proposed: CaseSolution) -> SolutionEvaluation {
        // Check if culprit is correct
        let correctCulprit = proposed.culpritID == self.culpritID

        // Calculate evidence accuracy
        let correctEvidence = Set(proposed.relevantEvidenceIDs).intersection(Set(self.relevantEvidenceIDs))
        let evidenceAccuracy = Float(correctEvidence.count) / Float(max(1, self.relevantEvidenceIDs.count))

        // Overall accuracy
        let accuracy = correctCulprit ? (0.7 + evidenceAccuracy * 0.3) : (evidenceAccuracy * 0.3)

        return SolutionEvaluation(
            isCorrect: correctCulprit && accuracy > 0.8,
            accuracy: accuracy,
            correctCulprit: correctCulprit,
            missingEvidence: self.relevantEvidenceIDs.filter { !proposed.relevantEvidenceIDs.contains($0) },
            extraneousEvidence: proposed.relevantEvidenceIDs.filter { !self.relevantEvidenceIDs.contains($0) }
        )
    }
}

struct SolutionEvaluation {
    let isCorrect: Bool
    let accuracy: Float
    let correctCulprit: Bool
    let missingEvidence: [UUID]
    let extraneousEvidence: [UUID]
}

/// Timeline of case events
struct CaseTimeline: Codable {
    var events: [TimelineEvent]

    func reconstruct() -> [TimelineEvent] {
        return events.sorted { $0.timestamp < $1.timestamp }
    }
}

struct TimelineEvent: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let description: String
    let location: UUID  // Location ID
    let involvedSuspects: [UUID]
    let relatedEvidence: [UUID]
    let significance: EventSignificance

    enum EventSignificance: String, Codable {
        case critical  // Key to solving case
        case important  // Relevant but not critical
        case background  // Context only
    }
}

struct TimelinePoint: Codable {
    let eventID: UUID
    let relevance: String
}

/// Investigation state
class InvestigationState: ObservableObject, Codable {
    @Published var currentCase: Case?
    @Published var discoveredEvidence: [Evidence] = []
    @Published var collectedEvidence: [Evidence] = []
    @Published var hypotheses: [Hypothesis] = []
    @Published var interrogationNotes: [InterrogationSession] = []
    @Published var timelineReconstruction: CaseTimeline?
    @Published var investigationProgress: Float = 0.0

    init(currentCase: Case? = nil) {
        self.currentCase = currentCase
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case currentCase
        case discoveredEvidence
        case collectedEvidence
        case hypotheses
        case interrogationNotes
        case timelineReconstruction
        case investigationProgress
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        currentCase = try container.decodeIfPresent(Case.self, forKey: .currentCase)
        discoveredEvidence = try container.decode([Evidence].self, forKey: .discoveredEvidence)
        collectedEvidence = try container.decode([Evidence].self, forKey: .collectedEvidence)
        hypotheses = try container.decode([Hypothesis].self, forKey: .hypotheses)
        interrogationNotes = try container.decode([InterrogationSession].self, forKey: .interrogationNotes)
        timelineReconstruction = try container.decodeIfPresent(CaseTimeline.self, forKey: .timelineReconstruction)
        investigationProgress = try container.decode(Float.self, forKey: .investigationProgress)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(currentCase, forKey: .currentCase)
        try container.encode(discoveredEvidence, forKey: .discoveredEvidence)
        try container.encode(collectedEvidence, forKey: .collectedEvidence)
        try container.encode(hypotheses, forKey: .hypotheses)
        try container.encode(interrogationNotes, forKey: .interrogationNotes)
        try container.encodeIfPresent(timelineReconstruction, forKey: .timelineReconstruction)
        try container.encode(investigationProgress, forKey: .investigationProgress)
    }
}

/// Player hypothesis
struct Hypothesis: Codable, Identifiable {
    let id: UUID
    var title: String
    var description: String
    var supportingEvidence: [UUID]
    var contradictingEvidence: [UUID]
    var confidenceScore: Float
    var isCorrect: Bool?
}

/// Interrogation session record
struct InterrogationSession: Codable, Identifiable {
    let id: UUID
    let suspectID: UUID
    let startTime: Date
    let endTime: Date
    let questionsAsked: [DialogueResponse]
    let responses: [DialogueNode]
    let finalStressLevel: Float
    let contradictionsFound: Int
}
