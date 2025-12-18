import Foundation
import Observation

/// Global app state using @Observable macro
@Observable
final class AppState {
    /// Currently selected briefing section
    var currentSection: BriefingSection?

    /// Navigation path for hierarchical navigation
    var navigationPath: [BriefingSection] = []

    /// Set of currently open volume window IDs
    var openVolumes: Set<UUID> = []

    /// Whether immersive space is currently open
    var immersiveSpaceOpen: Bool = false

    /// User progress tracking
    var userProgress: UserProgress?

    /// Currently selected use case (for detail view)
    var selectedUseCase: UseCase?

    /// Currently selected decision point
    var selectedDecisionPoint: DecisionPoint?

    /// Currently selected investment phase
    var selectedPhase: InvestmentPhase?

    /// Search query
    var searchQuery: String = ""

    /// Is searching
    var isSearching: Bool = false

    /// Sidebar visibility (for compact layouts)
    var sidebarVisible: Bool = true

    /// Selected executive role filter for action items
    var selectedRole: ExecutiveRole?

    /// Loading state
    var isLoading: Bool = false

    /// Error message to display
    var errorMessage: String?

    /// Time tracking for session
    var sessionStartTime: Date = Date()

    init() {
        // Initialize with default values
    }

    // MARK: - Navigation Actions

    /// Navigate to a specific section
    func navigateToSection(_ section: BriefingSection) {
        currentSection = section
        if !navigationPath.contains(where: { $0.id == section.id }) {
            navigationPath.append(section)
        }
    }

    /// Navigate back
    func navigateBack() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
        currentSection = navigationPath.last
    }

    /// Clear navigation
    func clearNavigation() {
        navigationPath.removeAll()
        currentSection = nil
    }

    // MARK: - Volume Management

    /// Open a visualization volume
    func openVolume(_ id: UUID) {
        openVolumes.insert(id)
    }

    /// Close a visualization volume
    func closeVolume(_ id: UUID) {
        openVolumes.remove(id)
    }

    /// Check if volume is open
    func isVolumeOpen(_ id: UUID) -> Bool {
        openVolumes.contains(id)
    }

    // MARK: - Session Management

    /// Calculate current session duration
    var sessionDuration: TimeInterval {
        Date().timeIntervalSince(sessionStartTime)
    }

    /// End current session
    func endSession() {
        sessionStartTime = Date()
    }

    // MARK: - Error Handling

    /// Show error message
    func showError(_ message: String) {
        errorMessage = message
    }

    /// Clear error
    func clearError() {
        errorMessage = nil
    }

    // MARK: - Search

    /// Update search query
    func updateSearchQuery(_ query: String) {
        searchQuery = query
        isSearching = !query.isEmpty
    }

    /// Clear search
    func clearSearch() {
        searchQuery = ""
        isSearching = false
    }
}
