import Foundation
import SwiftData
import Observation

/// ViewModel for the Control Panel window
@Observable
@MainActor
public class ControlPanelViewModel {

    // MARK: - Dependencies

    private let modelContext: ModelContext
    private let designService: DesignService

    // MARK: - State

    /// All available projects
    public var projects: [DesignProject] = []

    /// Currently selected project
    public var selectedProject: DesignProject?

    /// Search query for filtering projects
    public var searchQuery: String = "" {
        didSet {
            filterProjects()
        }
    }

    /// Filtered projects based on search
    public var filteredProjects: [DesignProject] = []

    /// Loading state
    public var isLoading: Bool = false

    /// Error message
    public var errorMessage: String?

    /// Show new project sheet
    public var showingNewProjectSheet: Bool = false

    /// Show delete confirmation
    public var showingDeleteConfirmation: Bool = false

    /// Project to delete (for confirmation)
    public var projectToDelete: DesignProject?

    // MARK: - Sorting

    public enum SortOption: String, CaseIterable {
        case name = "Name"
        case dateModified = "Date Modified"
        case dateCreated = "Date Created"
        case partCount = "Part Count"

        var displayName: String {
            return rawValue
        }
    }

    public var sortOption: SortOption = .dateModified {
        didSet {
            sortProjects()
        }
    }

    public var sortAscending: Bool = false {
        didSet {
            sortProjects()
        }
    }

    // MARK: - Initialization

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.designService = DesignService(modelContext: modelContext)
    }

    // MARK: - Loading

    /// Load all projects
    public func loadProjects() async {
        isLoading = true
        errorMessage = nil

        do {
            projects = try await designService.loadProjects()
            filterProjects()
            sortProjects()
        } catch {
            errorMessage = "Failed to load projects: \(error.localizedDescription)"
        }

        isLoading = false
    }

    /// Refresh projects
    public func refresh() async {
        await loadProjects()
    }

    // MARK: - Project Management

    /// Create new project
    /// - Parameters:
    ///   - name: Project name
    ///   - description: Project description
    public func createProject(name: String, description: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let project = try await designService.createProject(
                name: name,
                description: description
            )

            projects.append(project)
            selectedProject = project
            filterProjects()
            sortProjects()

            showingNewProjectSheet = false
        } catch {
            errorMessage = "Failed to create project: \(error.localizedDescription)"
        }

        isLoading = false
    }

    /// Select project
    /// - Parameter project: Project to select
    public func selectProject(_ project: DesignProject) {
        selectedProject = project
    }

    /// Delete project
    /// - Parameter project: Project to delete
    public func deleteProject(_ project: DesignProject) {
        projectToDelete = project
        showingDeleteConfirmation = true
    }

    /// Confirm project deletion
    public func confirmDelete() async {
        guard let project = projectToDelete else { return }

        isLoading = true
        errorMessage = nil

        do {
            modelContext.delete(project)
            try modelContext.save()

            projects.removeAll { $0.id == project.id }

            if selectedProject?.id == project.id {
                selectedProject = nil
            }

            filterProjects()
            sortProjects()

            projectToDelete = nil
            showingDeleteConfirmation = false
        } catch {
            errorMessage = "Failed to delete project: \(error.localizedDescription)"
        }

        isLoading = false
    }

    /// Cancel project deletion
    public func cancelDelete() {
        projectToDelete = nil
        showingDeleteConfirmation = false
    }

    /// Duplicate project
    /// - Parameter project: Project to duplicate
    public func duplicateProject(_ project: DesignProject) async {
        isLoading = true
        errorMessage = nil

        do {
            let newProject = DesignProject(
                name: "\(project.name) Copy",
                description: project.projectDescription
            )
            newProject.units = project.units
            newProject.status = "draft"

            modelContext.insert(newProject)
            try modelContext.save()

            projects.append(newProject)
            selectedProject = newProject
            filterProjects()
            sortProjects()
        } catch {
            errorMessage = "Failed to duplicate project: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Filtering

    private func filterProjects() {
        if searchQuery.isEmpty {
            filteredProjects = projects
        } else {
            filteredProjects = projects.filter { project in
                project.name.localizedCaseInsensitiveContains(searchQuery) ||
                project.projectDescription.localizedCaseInsensitiveContains(searchQuery)
            }
        }
    }

    // MARK: - Sorting

    private func sortProjects() {
        filteredProjects.sort { project1, project2 in
            let comparison: Bool

            switch sortOption {
            case .name:
                comparison = project1.name < project2.name
            case .dateModified:
                comparison = project1.modifiedDate > project2.modifiedDate
            case .dateCreated:
                comparison = project1.createdDate > project2.createdDate
            case .partCount:
                comparison = project1.partCount > project2.partCount
            }

            return sortAscending ? !comparison : comparison
        }
    }

    // MARK: - Computed Properties

    /// Total number of projects
    public var projectCount: Int {
        return projects.count
    }

    /// Number of active projects
    public var activeProjectCount: Int {
        return projects.filter { $0.status == "active" }.count
    }

    /// Number of draft projects
    public var draftProjectCount: Int {
        return projects.filter { $0.status == "draft" }.count
    }

    /// Total number of parts across all projects
    public var totalPartCount: Int {
        return projects.reduce(0) { $0 + $1.partCount }
    }

    /// Has projects
    public var hasProjects: Bool {
        return !projects.isEmpty
    }

    /// Has filtered results
    public var hasFilteredResults: Bool {
        return !filteredProjects.isEmpty
    }

    /// Is searching
    public var isSearching: Bool {
        return !searchQuery.isEmpty
    }
}
