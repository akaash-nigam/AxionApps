//
//  ExperimentManager.swift
//  Science Lab Sandbox
//
//  Manages experiment lifecycle, data collection, and validation
//

import Foundation
import Combine

@MainActor
class ExperimentManager: ObservableObject {

    // MARK: - Published Properties

    @Published var currentExperiment: Experiment?
    @Published var currentSession: ExperimentSession?
    @Published var experimentLibrary: [Experiment] = []

    @Published var currentStep: Int = 0
    @Published var isExperimentActive: Bool = false

    // MARK: - Private Properties

    private var experimentTimer: Timer?
    private var startTime: Date?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init() {
        loadExperimentLibrary()
    }

    // MARK: - Experiment Lifecycle

    func setupExperiment(_ experiment: Experiment) async throws {
        guard !isExperimentActive else {
            throw ExperimentError.experimentAlreadyActive
        }

        currentExperiment = experiment
        currentSession = ExperimentSession(
            experimentID: experiment.id,
            startTime: Date()
        )

        currentStep = 0
        isExperimentActive = true
        startTime = Date()

        print("🧪 Experiment setup: \(experiment.name)")
    }

    func startExperiment() {
        guard let experiment = currentExperiment else { return }
        guard !experiment.instructions.isEmpty else { return }

        isExperimentActive = true

        print("▶️ Experiment started: \(experiment.name)")
    }

    func pauseExperiment() {
        isExperimentActive = false
        print("⏸️ Experiment paused")
    }

    func resumeExperiment() {
        isExperimentActive = true
        print("▶️ Experiment resumed")
    }

    func completeCurrentStep() {
        guard let experiment = currentExperiment else { return }
        guard currentStep < experiment.instructions.count else { return }

        let step = experiment.instructions[currentStep]
        currentSession?.completeStep(step.id)

        currentStep += 1

        if currentStep >= experiment.instructions.count {
            // All steps completed
            print("✅ All experiment steps completed")
        }
    }

    func endExperiment() async {
        guard var session = currentSession else { return }

        session.endTime = Date()
        currentSession = session

        isExperimentActive = false
        currentStep = 0

        print("🏁 Experiment ended: \(session.duration ?? 0)s")
    }

    // MARK: - Data Collection

    func recordObservation(_ text: String, category: ObservationCategory = .general) {
        currentSession?.addObservation(text, category: category)
        print("📝 Observation recorded: \(text)")
    }

    func recordMeasurement(parameter: String, value: Double, unit: String) {
        currentSession?.addMeasurement(parameter: parameter, value: value, unit: unit)
        print("📊 Measurement recorded: \(parameter) = \(value) \(unit)")
    }

    func recordDataPoint(x: Double, y: Double, category: String? = nil) {
        let dataPoint = DataPoint(x: x, y: y, category: category)
        currentSession?.addDataPoint(dataPoint)
    }

    func setHypothesis(_ hypothesis: String) {
        currentSession?.hypothesis = hypothesis
        print("💡 Hypothesis set: \(hypothesis)")
    }

    func setConclusion(_ conclusion: String) {
        currentSession?.conclusion = conclusion
        print("📋 Conclusion set: \(conclusion)")
    }

    // MARK: - Safety Monitoring

    func recordSafetyViolation() {
        currentSession?.recordSafetyViolation()
        print("⚠️ Safety violation recorded")
    }

    func checkSafety(for chemicals: [Chemical]) -> SafetyLevel {
        let maxHazard = chemicals.map { chemical -> Int in
            switch chemical.hazardClass {
            case .safe: return 0
            case .irritant: return 1
            case .corrosive, .flammable, .oxidizer: return 2
            case .toxic, .explosive, .radioactive: return 3
            }
        }.max() ?? 0

        switch maxHazard {
        case 0: return .safe
        case 1: return .caution
        case 2: return .dangerous
        default: return .extreme
        }
    }

    // MARK: - Experiment Library

    private func loadExperimentLibrary() {
        // Load experiments from resources
        // For now, create some default experiments

        let acidBaseTitration = Experiment(
            name: "Acid-Base Titration",
            discipline: .chemistry,
            difficulty: .intermediate,
            description: "Learn about neutralization reactions by titrating an acid with a base.",
            learningObjectives: [
                "Understand acid-base neutralization",
                "Learn to use pH indicators",
                "Practice precise measurement techniques"
            ],
            requiredEquipment: [.beaker, .burner, .pipette, .pHMeter],
            safetyLevel: .caution,
            estimatedDuration: 900,  // 15 minutes
            instructions: [
                ExperimentStep(
                    stepNumber: 1,
                    title: "Prepare the Solution",
                    instruction: "Add 50 mL of HCl to the beaker using a pipette.",
                    expectedDuration: 60
                ),
                ExperimentStep(
                    stepNumber: 2,
                    title: "Add Indicator",
                    instruction: "Add 2-3 drops of phenolphthalein indicator to the acid.",
                    expectedDuration: 30
                ),
                ExperimentStep(
                    stepNumber: 3,
                    title: "Begin Titration",
                    instruction: "Slowly add NaOH while swirling the beaker. Stop when the solution turns pink.",
                    expectedDuration: 300,
                    safetyWarnings: ["Wear safety goggles", "Handle acids and bases carefully"]
                ),
                ExperimentStep(
                    stepNumber: 4,
                    title: "Record Results",
                    instruction: "Record the volume of NaOH used and calculate the concentration.",
                    expectedDuration: 120
                )
            ],
            hints: [
                "The solution will turn pink at the equivalence point (pH 7)",
                "Swirl gently to ensure proper mixing",
                "If you overshoot, start again with a fresh sample"
            ]
        )

        let projectileMotion = Experiment(
            name: "Projectile Motion",
            discipline: .physics,
            difficulty: .beginner,
            description: "Explore the physics of projectile motion by launching objects at different angles.",
            learningObjectives: [
                "Understand parabolic trajectories",
                "Learn about velocity components",
                "Calculate range and height"
            ],
            requiredEquipment: [.forceSensor, .motionTracker],
            safetyLevel: .safe,
            estimatedDuration: 600,  // 10 minutes
            instructions: [
                ExperimentStep(
                    stepNumber: 1,
                    title: "Set Launch Angle",
                    instruction: "Adjust the launcher to 45 degrees.",
                    expectedDuration: 30
                ),
                ExperimentStep(
                    stepNumber: 2,
                    title: "Set Initial Velocity",
                    instruction: "Set the initial velocity to 10 m/s.",
                    expectedDuration: 30
                ),
                ExperimentStep(
                    stepNumber: 3,
                    title: "Launch and Observe",
                    instruction: "Launch the projectile and observe its trajectory.",
                    expectedDuration: 60
                ),
                ExperimentStep(
                    stepNumber: 4,
                    title: "Measure and Calculate",
                    instruction: "Measure the range and compare to calculated values.",
                    expectedDuration: 180
                )
            ]
        )

        let cellObservation = Experiment(
            name: "Cell Structure Observation",
            discipline: .biology,
            difficulty: .beginner,
            description: "Observe plant and animal cells under a microscope and identify cellular structures.",
            learningObjectives: [
                "Identify cell organelles",
                "Distinguish plant and animal cells",
                "Use a microscope properly"
            ],
            requiredEquipment: [.microscope, .slide, .coverSlip],
            safetyLevel: .safe,
            estimatedDuration: 720,  // 12 minutes
            instructions: [
                ExperimentStep(
                    stepNumber: 1,
                    title: "Prepare Slide",
                    instruction: "Place a small sample of onion skin on the slide.",
                    expectedDuration: 60
                ),
                ExperimentStep(
                    stepNumber: 2,
                    title: "Add Cover Slip",
                    instruction: "Carefully place a cover slip over the sample.",
                    expectedDuration: 30
                ),
                ExperimentStep(
                    stepNumber: 3,
                    title: "Focus Microscope",
                    instruction: "Start with low magnification (40x) and focus on the cells.",
                    expectedDuration: 120
                ),
                ExperimentStep(
                    stepNumber: 4,
                    title: "Identify Structures",
                    instruction: "Identify the cell wall, nucleus, and other organelles.",
                    expectedDuration: 300
                )
            ]
        )

        experimentLibrary = [
            acidBaseTitration,
            projectileMotion,
            cellObservation
        ]

        print("📚 Loaded \(experimentLibrary.count) experiments")
    }

    func getExperiment(id: UUID) -> Experiment? {
        return experimentLibrary.first { $0.id == id }
    }

    func getExperiments(for discipline: ScientificDiscipline) -> [Experiment] {
        return experimentLibrary.filter { $0.discipline == discipline }
    }

    func getExperiments(for difficulty: DifficultyLevel) -> [Experiment] {
        return experimentLibrary.filter { $0.difficulty == difficulty }
    }

    // MARK: - Update Loop

    func update(deltaTime: TimeInterval) {
        guard isExperimentActive else { return }

        // Update experiment-specific logic here
    }
}

// MARK: - Experiment Error

enum ExperimentError: Error {
    case experimentNotFound
    case experimentAlreadyActive
    case noActiveExperiment
    case invalidStep

    var localizedDescription: String {
        switch self {
        case .experimentNotFound:
            return "Experiment not found in library"
        case .experimentAlreadyActive:
            return "An experiment is already active"
        case .noActiveExperiment:
            return "No active experiment"
        case .invalidStep:
            return "Invalid experiment step"
        }
    }
}
