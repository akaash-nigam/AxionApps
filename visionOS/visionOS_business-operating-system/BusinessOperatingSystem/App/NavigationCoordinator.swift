//
//  NavigationCoordinator.swift
//  BusinessOperatingSystem
//
//  Created by BOS Team on 2025-01-20.
//

import SwiftUI
import Observation

// MARK: - Navigation Destination

/// All possible navigation destinations in the app
enum NavigationDestination: Hashable, Identifiable {
    case dashboard
    case department(Department.ID)
    case departmentVolume(Department.ID)
    case report(Report.ID)
    case visualization(Visualization.ID)
    case employee(Employee.ID)
    case settings
    case businessUniverse

    var id: String {
        switch self {
        case .dashboard:
            return "dashboard"
        case .department(let id):
            return "department-\(id)"
        case .departmentVolume(let id):
            return "department-volume-\(id)"
        case .report(let id):
            return "report-\(id)"
        case .visualization(let id):
            return "visualization-\(id)"
        case .employee(let id):
            return "employee-\(id)"
        case .settings:
            return "settings"
        case .businessUniverse:
            return "business-universe"
        }
    }

    /// Window identifier for this destination
    var windowID: String {
        switch self {
        case .dashboard:
            return "dashboard"
        case .department:
            return "department"
        case .departmentVolume:
            return "department-volume"
        case .report:
            return "report"
        case .visualization:
            return "visualization-volume"
        case .employee:
            return "employee"
        case .settings:
            return "settings"
        case .businessUniverse:
            return "business-universe"
        }
    }

    /// Whether this destination opens as an immersive space
    var isImmersive: Bool {
        switch self {
        case .businessUniverse:
            return true
        default:
            return false
        }
    }

    /// Whether this destination opens as a volumetric window
    var isVolumetric: Bool {
        switch self {
        case .departmentVolume, .visualization:
            return true
        default:
            return false
        }
    }
}

// MARK: - Navigation Coordinator

/// Centralized navigation management for the app
@Observable
@MainActor
final class NavigationCoordinator {
    // MARK: - Properties

    /// Navigation path for NavigationStack-based navigation
    var navigationPath = NavigationPath()

    /// Currently open windows
    private(set) var openWindows: Set<NavigationDestination> = []

    /// Whether an immersive space is currently open
    private(set) var isImmersiveSpaceOpen: Bool = false

    /// Current immersive space destination
    private(set) var currentImmersiveSpace: NavigationDestination?

    /// Navigation history for back navigation
    private var navigationHistory: [NavigationDestination] = []

    /// Maximum history size
    private let maxHistorySize = 50

    // MARK: - Environment Actions

    /// These are set by the root view using environment values
    var openWindowAction: OpenWindowAction?
    var dismissWindowAction: DismissWindowAction?
    var openImmersiveSpaceAction: OpenImmersiveSpaceAction?
    var dismissImmersiveSpaceAction: DismissImmersiveSpaceAction?

    // MARK: - Initialization

    nonisolated init() {
        // Initialize with empty state
    }

    // MARK: - Navigation Methods

    /// Navigate to a destination
    func navigate(to destination: NavigationDestination) {
        // Add to history
        addToHistory(destination)

        if destination.isImmersive {
            openImmersiveSpace(destination)
        } else {
            openWindow(destination)
        }
    }

    /// Navigate back to the previous destination
    func navigateBack() {
        guard navigationHistory.count > 1 else { return }

        // Remove current
        navigationHistory.removeLast()

        // Navigate to previous
        if let previous = navigationHistory.last {
            if previous.isImmersive {
                openImmersiveSpace(previous)
            } else {
                openWindow(previous)
            }
        }
    }

    /// Close a specific window
    func closeWindow(_ destination: NavigationDestination) {
        openWindows.remove(destination)

        // Use dismiss action if available
        // Note: SwiftUI doesn't have a direct dismiss by ID,
        // so we track state and let views respond
    }

    /// Close all windows except dashboard
    func closeAllWindows() {
        openWindows = openWindows.filter { $0 == .dashboard }
    }

    /// Exit immersive space
    func exitImmersiveSpace() async {
        guard isImmersiveSpaceOpen else { return }

        if let dismissAction = dismissImmersiveSpaceAction {
            await dismissAction()
        }

        isImmersiveSpaceOpen = false
        currentImmersiveSpace = nil
    }

    // MARK: - Convenience Navigation

    /// Show a department window
    func showDepartment(_ id: Department.ID) {
        navigate(to: .department(id))
    }

    /// Show a department in volumetric mode
    func showDepartmentVolume(_ id: Department.ID) {
        navigate(to: .departmentVolume(id))
    }

    /// Show a report
    func showReport(_ id: Report.ID) {
        navigate(to: .report(id))
    }

    /// Show an employee profile
    func showEmployee(_ id: Employee.ID) {
        navigate(to: .employee(id))
    }

    /// Enter the business universe immersive space
    func enterBusinessUniverse() {
        navigate(to: .businessUniverse)
    }

    /// Show settings
    func showSettings() {
        navigate(to: .settings)
    }

    /// Return to dashboard
    func returnToDashboard() async {
        // Exit immersive space if open
        if isImmersiveSpaceOpen {
            await exitImmersiveSpace()
        }

        // Close all other windows
        closeAllWindows()

        // Clear navigation path
        navigationPath = NavigationPath()

        // Clear history and add dashboard
        navigationHistory = [.dashboard]
    }

    // MARK: - Private Methods

    private func openWindow(_ destination: NavigationDestination) {
        openWindows.insert(destination)

        guard let openAction = openWindowAction else { return }

        switch destination {
        case .dashboard:
            openAction(id: "dashboard")
        case .department(let id):
            openAction(id: "department", value: id)
        case .departmentVolume(let id):
            openAction(id: "department-volume", value: id)
        case .report(let id):
            openAction(id: "report", value: id)
        case .visualization(let id):
            openAction(id: "visualization-volume", value: id)
        case .employee(let id):
            openAction(id: "employee", value: id)
        case .settings:
            openAction(id: "settings")
        case .businessUniverse:
            // Handled by openImmersiveSpace
            break
        }
    }

    private func openImmersiveSpace(_ destination: NavigationDestination) {
        guard destination.isImmersive else { return }

        Task {
            // Exit current immersive space if any
            if isImmersiveSpaceOpen {
                await exitImmersiveSpace()
            }

            // Open new immersive space
            if let openAction = openImmersiveSpaceAction {
                switch await openAction(id: destination.windowID) {
                case .opened:
                    isImmersiveSpaceOpen = true
                    currentImmersiveSpace = destination
                case .error, .userCancelled:
                    isImmersiveSpaceOpen = false
                    currentImmersiveSpace = nil
                @unknown default:
                    break
                }
            }
        }
    }

    private func addToHistory(_ destination: NavigationDestination) {
        // Don't add duplicates consecutively
        if navigationHistory.last != destination {
            navigationHistory.append(destination)

            // Trim history if too long
            if navigationHistory.count > maxHistorySize {
                navigationHistory.removeFirst(navigationHistory.count - maxHistorySize)
            }
        }
    }

    // MARK: - Query Methods

    /// Check if a window is open
    func isWindowOpen(_ destination: NavigationDestination) -> Bool {
        openWindows.contains(destination)
    }

    /// Get the current navigation depth
    var navigationDepth: Int {
        navigationHistory.count
    }

    /// Check if we can navigate back
    var canNavigateBack: Bool {
        navigationHistory.count > 1
    }
}

// MARK: - Environment Key

private struct NavigationCoordinatorKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue = NavigationCoordinator()
}

extension EnvironmentValues {
    var navigationCoordinator: NavigationCoordinator {
        get { self[NavigationCoordinatorKey.self] }
        set { self[NavigationCoordinatorKey.self] = newValue }
    }
}

// MARK: - View Extension for Easy Access

extension View {
    /// Inject the navigation coordinator into the environment
    func withNavigationCoordinator(_ coordinator: NavigationCoordinator) -> some View {
        self.environment(\.navigationCoordinator, coordinator)
    }
}

// MARK: - Navigation Link Helper

/// A button that navigates using the coordinator
struct CoordinatedNavigationButton<Label: View>: View {
    @Environment(\.navigationCoordinator) private var coordinator

    let destination: NavigationDestination
    let label: () -> Label

    init(destination: NavigationDestination, @ViewBuilder label: @escaping () -> Label) {
        self.destination = destination
        self.label = label
    }

    var body: some View {
        Button {
            coordinator.navigate(to: destination)
        } label: {
            label()
        }
    }
}

// MARK: - Back Button

struct NavigationBackButton: View {
    @Environment(\.navigationCoordinator) private var coordinator

    var body: some View {
        Button {
            coordinator.navigateBack()
        } label: {
            Label("Back", systemImage: "chevron.left")
        }
        .disabled(!coordinator.canNavigateBack)
    }
}

// MARK: - Home Button

struct NavigationHomeButton: View {
    @Environment(\.navigationCoordinator) private var coordinator

    var body: some View {
        Button {
            Task {
                await coordinator.returnToDashboard()
            }
        } label: {
            Label("Home", systemImage: "house")
        }
    }
}
