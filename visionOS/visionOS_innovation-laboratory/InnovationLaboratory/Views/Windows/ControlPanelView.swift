import SwiftUI

struct ControlPanelView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedTab: SettingsTab = .profile

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(SettingsTab.allCases) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            Label(tab.title, systemImage: tab.icon)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

enum SettingsTab: String, CaseIterable, Identifiable {
    case profile
    case team
    case integrations
    case preferences

    var id: String { rawValue }

    var title: String {
        switch self {
        case .profile: return "Profile"
        case .team: return "Team"
        case .integrations: return "Integrations"
        case .preferences: return "Preferences"
        }
    }

    var icon: String {
        switch self {
        case .profile: return "person.circle"
        case .team: return "person.3"
        case .integrations: return "link.circle"
        case .preferences: return "gearshape"
        }
    }
}

#Preview {
    ControlPanelView()
        .environment(AppState())
}
