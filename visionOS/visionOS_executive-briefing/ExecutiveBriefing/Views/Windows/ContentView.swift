import SwiftUI
import SwiftData

/// Main content view - entry point for the app UI
struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \BriefingSection.order) private var sections: [BriefingSection]

    @State private var selectedSection: BriefingSection?

    var body: some View {
        @Bindable var appState = appState

        NavigationSplitView {
            // Sidebar
            SidebarView(
                sections: sections,
                selectedSection: $selectedSection
            )
            .frame(minWidth: 280)
        } detail: {
            // Content area
            if let section = selectedSection {
                SectionDetailView(section: section)
            } else {
                WelcomeView()
            }
        }
        .onChange(of: selectedSection) { oldValue, newValue in
            if let section = newValue {
                appState.navigateToSection(section)
            }
        }
        .onAppear {
            // Select first section by default
            if selectedSection == nil, let first = sections.first {
                selectedSection = first
            }
        }
    }
}

/// Welcome view shown when no section is selected
struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "visionpro")
                .font(.system(size: 80))
                .foregroundStyle(.accent)

            Text("Executive Briefing")
                .font(.system(size: 48, weight: .bold))

            Text("AR/VR in 2025")
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(.secondary)

            Text("Strategic Decisions for C-Suite Leaders")
                .font(.title3)
                .foregroundStyle(.tertiary)

            Spacer()
                .frame(height: 40)

            Text("Select a section from the sidebar to begin")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .padding(60)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
        .environment(AppState())
        .modelContainer(for: BriefingSection.self, inMemory: true)
}
