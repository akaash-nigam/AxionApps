import SwiftUI
import Combine

/// Global application state manager
@MainActor
class AppState: ObservableObject {
    // MARK: - Published Properties

    @Published var currentGameState: GameState = .mainMenu
    @Published var isImmersiveSpaceOpen: Bool = false
    @Published var settings: GameSettings = GameSettings()
    @Published var playerProgress: PlayerProgress = PlayerProgress()

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()
    private let saveManager = SaveManager()

    // MARK: - Initialization

    init() {
        loadPlayerProgress()
        setupObservers()
    }

    // MARK: - Public Methods

    func transitionToState(_ newState: GameState) {
        print("Transitioning from \(currentGameState) to \(newState)")
        currentGameState = newState

        // Handle state-specific logic
        switch newState {
        case .investigating:
            openImmersiveSpace()
        case .mainMenu:
            closeImmersiveSpace()
        default:
            break
        }
    }

    func openImmersiveSpace() {
        Task {
            isImmersiveSpaceOpen = true
        }
    }

    func closeImmersiveSpace() {
        Task {
            isImmersiveSpaceOpen = false
        }
    }

    func saveProgress() {
        Task {
            do {
                try await saveManager.savePlayerProgress(playerProgress)
                print("Progress saved successfully")
            } catch {
                print("Failed to save progress: \(error)")
            }
        }
    }

    // MARK: - Private Methods

    private func loadPlayerProgress() {
        Task {
            do {
                if let loadedProgress = try await saveManager.loadPlayerProgress() {
                    playerProgress = loadedProgress
                    print("Progress loaded successfully")
                }
            } catch {
                print("No saved progress found or load failed: \(error)")
            }
        }
    }

    private func setupObservers() {
        // Auto-save when player progress changes
        $playerProgress
            .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.saveProgress()
            }
            .store(in: &cancellables)
    }
}

// MARK: - Game State Enum

enum GameState: String, Codable {
    case mainMenu
    case caseSelection
    case caseIntroduction
    case investigating
    case interrogating
    case analyzingEvidence
    case formingHypothesis
    case presentingSolution
    case caseResolution
    case paused
}

// MARK: - Game Settings

struct GameSettings: Codable {
    var difficulty: DifficultyLevel = .medium
    var hintFrequency: HintFrequency = .moderate
    var caseLength: CaseLength = .medium
    var goreLevel: GoreLevel = .mild

    // Accessibility
    var seatedMode: Bool = false
    var oneHandedMode: Bool = false
    var highContrastEvidence: Bool = false
    var audioDescriptions: Bool = false
    var reducedMotion: Bool = false
    var extendedTimeouts: Bool = false

    // Spatial
    var playAreaSize: PlayAreaSize = .medium
    var uiDistance: Float = 1.5  // meters
    var evidenceScale: Float = 1.0
}

enum DifficultyLevel: String, Codable, CaseIterable {
    case story, easy, medium, hard, expert

    var displayName: String {
        switch self {
        case .story: return "Story Mode"
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        case .expert: return "Expert"
        }
    }
}

enum HintFrequency: String, Codable, CaseIterable {
    case none, minimal, moderate, frequent
}

enum CaseLength: String, Codable, CaseIterable {
    case short, medium, long

    var duration: TimeInterval {
        switch self {
        case .short: return 1200  // 20 minutes
        case .medium: return 2700  // 45 minutes
        case .long: return 5400  // 90 minutes
        }
    }
}

enum GoreLevel: String, Codable, CaseIterable {
    case none, mild, moderate
}

enum PlayAreaSize: String, Codable, CaseIterable {
    case small, medium, large

    var dimensions: (width: Float, depth: Float) {
        switch self {
        case .small: return (2.0, 2.0)
        case .medium: return (3.0, 3.0)
        case .large: return (5.0, 5.0)
        }
    }
}

// MARK: - Player Progress

struct PlayerProgress: Codable {
    var solvedCases: [UUID] = []
    var totalPlayTime: TimeInterval = 0
    var deductionAccuracy: Float = 0.0
    var evidenceDiscoveryRate: Float = 0.0
    var unlockedTools: [ForensicToolType] = [.magnifyingGlass]  // Start with basic tool
    var achievements: [Achievement] = []
    var currentRank: DetectiveRank = .rookie
    var experience: Int = 0

    // Statistics
    var casesStarted: Int = 0
    var casesCompleted: Int = 0
    var totalEvidenceFound: Int = 0
    var totalInterrogationsCompleted: Int = 0
    var perfectSolutions: Int = 0
    var hintsUsed: Int = 0

    mutating func addExperience(_ amount: Int) {
        experience += amount
        updateRank()
    }

    private mutating func updateRank() {
        if experience >= 10000 {
            currentRank = .master
        } else if experience >= 5000 {
            currentRank = .leadInvestigator
        } else if experience >= 2000 {
            currentRank = .seniorDetective
        } else if experience >= 500 {
            currentRank = .detective
        } else {
            currentRank = .rookie
        }
    }
}

enum DetectiveRank: String, Codable {
    case rookie = "Rookie Detective"
    case detective = "Detective"
    case seniorDetective = "Senior Detective"
    case leadInvestigator = "Lead Investigator"
    case master = "Master Detective"
}

struct Achievement: Codable, Identifiable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let earnedDate: Date
}
