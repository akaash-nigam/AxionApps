import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @State private var showSettings = false

    var body: some View {
        @Bindable var appState = appState

        NavigationSplitView {
            // Sidebar
            SidebarView()
        } detail: {
            // Main content
            Group {
                switch appState.activeView {
                case .dashboard:
                    DashboardView()
                case .employees:
                    EmployeeListView()
                case .analytics:
                    Text("Analytics View")
                case .orgChart:
                    Text("Org Chart View")
                case .settings:
                    SettingsView()
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

// MARK: - Sidebar View
struct SidebarView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var appState = appState

        List(selection: $appState.activeView) {
            Section("Overview") {
                NavigationLink(value: AppView.dashboard) {
                    Label("Dashboard", systemImage: "square.grid.2x2")
                }

                NavigationLink(value: AppView.employees) {
                    Label("Employees", systemImage: "person.3")
                }

                NavigationLink(value: AppView.analytics) {
                    Label("Analytics", systemImage: "chart.bar")
                }
            }

            Section("Spatial Views") {
                Button {
                    openOrgChartVolume()
                } label: {
                    Label("3D Org Chart", systemImage: "cube")
                }

                Button {
                    openTalentGalaxy()
                } label: {
                    Label("Talent Galaxy", systemImage: "sparkles")
                }
            }

            Section {
                NavigationLink(value: AppView.settings) {
                    Label("Settings", systemImage: "gearshape")
                }
            }
        }
        .navigationTitle("Spatial HCM")
    }

    private func openOrgChartVolume() {
        Task {
            await openWindow(id: "org-chart-volume")
        }
    }

    private func openTalentGalaxy() {
        Task {
            await openImmersiveSpace(id: "talent-galaxy")
        }
    }
}

// MARK: - Helper Extensions
extension View {
    @MainActor
    func openWindow(id: String) async {
        #if os(visionOS)
        // In visionOS, use OpenWindowAction
        // For now, just print
        print("Opening window: \(id)")
        #endif
    }

    @MainActor
    func openImmersiveSpace(id: String) async {
        print("Opening immersive space: \(id)")
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
