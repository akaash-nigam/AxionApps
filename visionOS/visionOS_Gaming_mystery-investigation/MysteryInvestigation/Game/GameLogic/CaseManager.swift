import Foundation

/// Manages loading and generation of investigation cases
@MainActor
class CaseManager {
    // MARK: - Properties

    private var loadedCases: [UUID: Case] = [:]
    private let caseLibrary: [Case]

    // MARK: - Initialization

    init() {
        // Load built-in cases
        self.caseLibrary = CaseManager.loadBuiltInCases()
    }

    // MARK: - Case Loading

    func loadCase(_ caseID: UUID) async throws -> Case? {
        // Check cache
        if let cached = loadedCases[caseID] {
            return cached
        }

        // Find in library
        if let caseData = caseLibrary.first(where: { $0.id == caseID }) {
            loadedCases[caseID] = caseData
            return caseData
        }

        // Try loading from file system
        if let loaded = try await loadCaseFromFile(caseID) {
            loadedCases[caseID] = loaded
            return loaded
        }

        return nil
    }

    func getAllCases() -> [Case] {
        return caseLibrary
    }

    func getCasesByDifficulty(_ difficulty: DifficultyLevel) -> [Case] {
        return caseLibrary.filter { $0.difficulty == difficulty }
    }

    func getCasesByGenre(_ genre: Case.CaseGenre) -> [Case] {
        return caseLibrary.filter { $0.genre == genre }
    }

    // MARK: - Private Methods

    private func loadCaseFromFile(_ caseID: UUID) async throws -> Case? {
        // Attempt to load from Resources/Levels directory
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        let casePath = documentsPath.appendingPathComponent("Cases/\(caseID.uuidString).json")

        guard FileManager.default.fileExists(atPath: casePath.path) else {
            return nil
        }

        let data = try Data(contentsOf: casePath)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(Case.self, from: data)
    }

    // MARK: - Built-in Cases

    private static func loadBuiltInCases() -> [Case] {
        return [
            createTutorialCase(),
            createSimpleHomicideCase(),
            createComplexTheftCase()
        ]
    }

    // MARK: - Tutorial Case

    private static func createTutorialCase() -> Case {
        let caseID = UUID()
        let suspect1ID = UUID()
        let locationID = UUID()

        // Evidence
        let watchEvidence = Evidence(
            id: UUID(),
            type: .personal,
            name: "Antique Watch",
            description: "A valuable gold watch, reported stolen",
            discoveryLocation: SpatialCoordinate(x: 1.5, y: 0.8, z: 2.0),
            forensicData: ForensicData(
                fingerprints: [
                    Fingerprint(
                        id: UUID(),
                        pattern: .loop,
                        quality: 0.9,
                        matchingSuspect: suspect1ID
                    )
                ]
            ),
            relatedSuspects: [suspect1ID],
            timelineRelevance: nil,
            isRedHerring: false,
            requiredTools: [.magnifyingGlass],
            difficulty: .obvious,
            modelName: "watch_model",
            scale: 0.1
        )

        let noteEvidence = Evidence(
            id: UUID(),
            type: .document,
            name: "Handwritten Note",
            description: "A note found near the scene",
            discoveryLocation: SpatialCoordinate(x: 2.0, y: 0.9, z: 1.5),
            forensicData: ForensicData(
                documentAnalysis: DocumentAnalysis(
                    content: "I need money urgently. The watch would help.",
                    handwritingMatch: suspect1ID,
                    dateWritten: Date().addingTimeInterval(-86400),
                    significance: "Indicates financial motive"
                )
            ),
            relatedSuspects: [suspect1ID],
            timelineRelevance: nil,
            isRedHerring: false,
            requiredTools: [],
            difficulty: .obvious,
            modelName: "note_paper",
            scale: 0.15
        )

        // Suspect
        let suspect = Suspect(
            id: suspect1ID,
            name: "Alex Thompson",
            age: 28,
            occupation: "House guest",
            relationship: "Friend of the family",
            alibi: Alibi(
                statement: "I was in my room reading all evening",
                timeframe: DateInterval(start: Date().addingTimeInterval(-7200), duration: 3600),
                witnesses: [],
                isVerifiable: false,
                consistencyScore: 0.3
            ),
            behaviorProfile: BehaviorProfile(
                baselineStress: 0.4,
                personality: .nervous,
                lyingTendency: 0.7,
                cooperationLevel: 0.5
            ),
            dialogue: createSimpleDialogueTree(suspectID: suspect1ID),
            appearance: CharacterAppearance(
                modelName: "male_character_1",
                height: 1.75,
                buildType: .slim,
                distinctiveFeatures: ["Nervous mannerisms", "Avoids eye contact"]
            ),
            guiltyConfidenceScore: 0.9,
            interrogationHistory: [],
            isActualCulprit: true
        )

        // Location
        let location = CrimeSceneLocation(
            id: locationID,
            name: "Living Room",
            description: "A well-furnished living room where the watch was kept",
            type: .residence,
            spatialBounds: SpatialBounds(minX: 0, maxX: 4, minY: 0, maxY: 3, minZ: 0, maxZ: 4)
        )

        // Solution
        let solution = CaseSolution(
            culpritID: suspect1ID,
            motive: "Financial desperation",
            methodDescription: "Stole the watch while the owner was away",
            relevantEvidenceIDs: [watchEvidence.id, noteEvidence.id],
            timelineOfEvents: [
                TimelineEvent(
                    id: UUID(),
                    timestamp: Date().addingTimeInterval(-7200),
                    description: "Suspect enters living room",
                    location: locationID,
                    involvedSuspects: [suspect1ID],
                    relatedEvidence: [],
                    significance: .important
                ),
                TimelineEvent(
                    id: UUID(),
                    timestamp: Date().addingTimeInterval(-7000),
                    description: "Watch stolen from display case",
                    location: locationID,
                    involvedSuspects: [suspect1ID],
                    relatedEvidence: [watchEvidence.id],
                    significance: .critical
                )
            ]
        )

        return Case(
            id: caseID,
            title: "The Missing Heirloom",
            description: "A valuable antique watch has been stolen from a private residence. Interview the suspect and examine the evidence to solve this introductory case.",
            difficulty: .easy,
            estimatedDuration: 900,  // 15 minutes
            genre: .classicMystery,
            evidence: [watchEvidence, noteEvidence],
            suspects: [suspect],
            locations: [location],
            solution: solution,
            timeline: CaseTimeline(events: solution.timelineOfEvents),
            author: "Mystery Investigation Team",
            createdDate: Date(),
            tags: ["tutorial", "theft", "simple"]
        )
    }

    // MARK: - Simple Homicide Case

    private static func createSimpleHomicideCase() -> Case {
        let caseID = UUID()
        let culpritID = UUID()
        let witnessID = UUID()
        let locationID = UUID()

        // Create more complex evidence and suspects
        let knifeEvidence = Evidence(
            id: UUID(),
            type: .weapon,
            name: "Kitchen Knife",
            description: "A bloodstained kitchen knife found at the scene",
            discoveryLocation: SpatialCoordinate(x: 2.5, y: 0.1, z: 3.0),
            forensicData: ForensicData(
                fingerprints: [
                    Fingerprint(id: UUID(), pattern: .whorl, quality: 0.85, matchingSuspect: culpritID)
                ],
                bloodSpatter: BloodSpatterAnalysis(
                    pattern: .impact,
                    impactAngle: 45.0,
                    originPoint: SpatialCoordinate(x: 2.5, y: 1.2, z: 3.0),
                    bloodType: "AB+"
                )
            ),
            relatedSuspects: [culpritID],
            timelineRelevance: nil,
            isRedHerring: false,
            requiredTools: [.fingerprintKit, .bloodDetection],
            difficulty: .moderate,
            modelName: "knife_bloody",
            scale: 0.2
        )

        // Create suspects
        let culprit = Suspect(
            id: culpritID,
            name: "Marcus Reid",
            age: 35,
            occupation: "Business partner",
            relationship: "Former business partner of victim",
            alibi: Alibi(
                statement: "I was at home alone working on documents",
                timeframe: DateInterval(start: Date().addingTimeInterval(-14400), duration: 7200),
                witnesses: [],
                isVerifiable: false,
                consistencyScore: 0.4
            ),
            behaviorProfile: BehaviorProfile(
                baselineStress: 0.5,
                personality: .defensive,
                lyingTendency: 0.8,
                cooperationLevel: 0.3
            ),
            dialogue: createComplexDialogueTree(suspectID: culpritID),
            appearance: CharacterAppearance(
                modelName: "male_character_2",
                height: 1.80,
                buildType: .athletic,
                distinctiveFeatures: ["Scar on left hand", "Defensive posture"]
            ),
            guiltyConfidenceScore: 0.95,
            interrogationHistory: [],
            isActualCulprit: true
        )

        let witness = Suspect(
            id: witnessID,
            name: "Sarah Chen",
            age: 29,
            occupation: "Neighbor",
            relationship: "Lives next door",
            alibi: Alibi(
                statement: "I heard shouting around 9 PM",
                timeframe: DateInterval(start: Date().addingTimeInterval(-14400), duration: 600),
                witnesses: [],
                isVerifiable: true,
                consistencyScore: 0.9
            ),
            behaviorProfile: BehaviorProfile(
                baselineStress: 0.3,
                personality: .helpful,
                lyingTendency: 0.1,
                cooperationLevel: 0.9
            ),
            dialogue: createWitnessDialogueTree(suspectID: witnessID),
            appearance: CharacterAppearance(
                modelName: "female_character_1",
                height: 1.65,
                buildType: .slim,
                distinctiveFeatures: ["Cooperative demeanor", "Good memory"]
            ),
            isActualCulprit: false
        )

        let location = CrimeSceneLocation(
            id: locationID,
            name: "Victim's Office",
            description: "A home office where the victim was found",
            type: .residence,
            spatialBounds: SpatialBounds(minX: 0, maxX: 5, minY: 0, maxY: 3, minZ: 0, maxZ: 5)
        )

        let solution = CaseSolution(
            culpritID: culpritID,
            motive: "Business dispute and financial gain",
            methodDescription: "Stabbing with kitchen knife during confrontation",
            relevantEvidenceIDs: [knifeEvidence.id],
            timelineOfEvents: [
                TimelineEvent(
                    id: UUID(),
                    timestamp: Date().addingTimeInterval(-14400),
                    description: "Suspect arrives at victim's residence",
                    location: locationID,
                    involvedSuspects: [culpritID],
                    relatedEvidence: [],
                    significance: .important
                ),
                TimelineEvent(
                    id: UUID(),
                    timestamp: Date().addingTimeInterval(-13800),
                    description: "Argument escalates to violence",
                    location: locationID,
                    involvedSuspects: [culpritID],
                    relatedEvidence: [knifeEvidence.id],
                    significance: .critical
                )
            ]
        )

        return Case(
            id: caseID,
            title: "The Midnight Murder",
            description: "A business executive has been found dead in their home office. Examine the evidence and interrogate suspects to identify the killer.",
            difficulty: .medium,
            estimatedDuration: 2700,  // 45 minutes
            genre: .modernThriller,
            evidence: [knifeEvidence],
            suspects: [culprit, witness],
            locations: [location],
            solution: solution,
            timeline: CaseTimeline(events: solution.timelineOfEvents),
            author: "Mystery Investigation Team",
            createdDate: Date(),
            tags: ["homicide", "forensics", "interrogation"]
        )
    }

    // MARK: - Complex Theft Case

    private static func createComplexTheftCase() -> Case {
        let caseID = UUID()

        // Placeholder for more complex case
        return createTutorialCase()  // Reuse tutorial for now
    }

    // MARK: - Dialogue Trees

    private static func createSimpleDialogueTree(suspectID: UUID) -> DialogueTree {
        let rootID = UUID()
        let node1ID = UUID()
        let node2ID = UUID()

        let rootNode = DialogueNode(
            id: rootID,
            text: "I... I don't know what you're talking about.",
            speaker: .suspect(suspectID),
            responses: [
                DialogueResponse(
                    id: UUID(),
                    text: "We found your fingerprints on the watch.",
                    nextNodeID: node1ID,
                    requiredEvidence: nil,
                    stressImpact: 0.3,
                    emotionalTone: .accusatory
                ),
                DialogueResponse(
                    id: UUID(),
                    text: "Can you tell me about your relationship with the family?",
                    nextNodeID: node2ID,
                    requiredEvidence: nil,
                    stressImpact: 0.0,
                    emotionalTone: .friendly
                )
            ],
            conditions: [],
            effects: []
        )

        let confessionNode = DialogueNode(
            id: node1ID,
            text: "Okay, okay! I took it! I needed the money!",
            speaker: .suspect(suspectID),
            responses: [],
            conditions: [],
            effects: [
                DialogueEffect(type: .triggerConfession, value: "true")
            ],
            emotionalState: .guilty
        )

        let deflectionNode = DialogueNode(
            id: node2ID,
            text: "They've been very kind to me. I would never betray their trust.",
            speaker: .suspect(suspectID),
            responses: [],
            conditions: [],
            effects: [
                DialogueEffect(type: .increaseStress, value: "0.1")
            ]
        )

        return DialogueTree(
            rootNodeID: rootID,
            nodes: [
                rootID: rootNode,
                node1ID: confessionNode,
                node2ID: deflectionNode
            ],
            currentNodeID: rootID
        )
    }

    private static func createComplexDialogueTree(suspectID: UUID) -> DialogueTree {
        // More complex tree for harder cases
        return createSimpleDialogueTree(suspectID: suspectID)
    }

    private static func createWitnessDialogueTree(suspectID: UUID) -> DialogueTree {
        let rootID = UUID()

        let rootNode = DialogueNode(
            id: rootID,
            text: "I heard shouting from next door around 9 PM. It sounded like an argument.",
            speaker: .witness(suspectID),
            responses: [
                DialogueResponse(
                    id: UUID(),
                    text: "Did you recognize any voices?",
                    nextNodeID: nil,
                    requiredEvidence: nil,
                    stressImpact: 0.0,
                    emotionalTone: .neutral
                )
            ],
            conditions: [],
            effects: []
        )

        return DialogueTree(
            rootNodeID: rootID,
            nodes: [rootID: rootNode],
            currentNodeID: rootID
        )
    }
}
