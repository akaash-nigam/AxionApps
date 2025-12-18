//
//  SpatialScreenplayWorkshopApp.swift
//  SpatialScreenplayWorkshop
//
//  Created on 2025-11-24
//

import SwiftUI
import SwiftData

@main
struct SpatialScreenplayWorkshopApp: App {
    // MARK: - Properties

    @State private var appState = AppState()

    // MARK: - Scene

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .onAppear {
                    setupInitialData()
                }
        }
        .modelContainer(appState.modelContainer)

        // Immersive space for script editor (future)
        ImmersiveSpace(id: "editor") {
            // TODO: Immersive script editor view
            Text("Immersive Editor")
                .font(.largeTitle)
        }
    }

    // MARK: - Setup

    private func setupInitialData() {
        #if DEBUG
        // In debug mode, populate with sample data if no projects exist
        Task { @MainActor in
            let context = appState.modelContainer.mainContext
            do {
                let count = try context.fetchCount(FetchDescriptor<Project>())
                if count == 0 {
                    try await SampleData.populateWithSamples(in: context)
                    print("✅ Sample data created")
                }
            } catch {
                print("❌ Failed to setup initial data: \(error)")
            }
        }
        #endif
    }
}

// MARK: - Content View

struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            Group {
                switch appState.currentView {
                case .projectList:
                    ProjectListView()
                case .timeline:
                    TimelineView()
                case .scriptEditor:
                    EditorPlaceholderView()
                }
            }
        }
    }
}

// MARK: - Placeholder Views

struct ProjectListView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Project.modifiedAt, order: .reverse) private var projects: [Project]

    @State private var showingNewProject = false

    var body: some View {
        VStack(spacing: 20) {
            if projects.isEmpty {
                emptyState
            } else {
                projectsList
            }
        }
        .padding()
        .navigationTitle("My Screenplays")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingNewProject = true
                } label: {
                    Label("New Project", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingNewProject) {
            NewProjectView()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text")
                .font(.system(size: 80))
                .foregroundStyle(.secondary)

            Text("No Projects Yet")
                .font(.title)

            Text("Create your first screenplay to get started")
                .foregroundStyle(.secondary)

            Button {
                showingNewProject = true
            } label: {
                Label("Create First Project", systemImage: "plus.circle.fill")
                    .font(.title3)
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var projectsList: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 300), spacing: 20)
            ], spacing: 20) {
                ForEach(projects) { project in
                    ProjectCard(project: project)
                }
            }
        }
    }
}

struct ProjectCard: View {
    @Environment(AppState.self) private var appState
    let project: Project

    var body: some View {
        Button {
            Task {
                await appState.loadProject(project)
                appState.navigateTo(.timeline)
            }
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Text(project.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(2)

                    Spacer()

                    Text(project.statusBadge)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(hex: project.statusColor).opacity(0.2))
                        .foregroundStyle(Color(hex: project.statusColor))
                        .cornerRadius(4)
                }

                // Logline
                if !project.logline.isEmpty {
                    Text(project.logline)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }

                Divider()

                // Stats
                HStack {
                    Label("\(String(format: "%.1f", project.currentPageCount)) pages",
                          systemImage: "doc.text")

                    Spacer()

                    Label("\(project.scenes?.count ?? 0) scenes",
                          systemImage: "square.stack.3d.up")

                    Spacer()

                    Text(project.lastModifiedText)
                        .foregroundStyle(.tertiary)
                }
                .font(.caption)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
        .buttonStyle(.plain)
    }
}

struct NewProjectView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    @State private var title = ""
    @State private var type: ProjectType = .featureFilm
    @State private var author = ""
    @State private var isCreating = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Project Details") {
                    TextField("Title", text: $title)
                    TextField("Author", text: $author)

                    Picker("Type", selection: $type) {
                        ForEach(ProjectType.allCases) { projectType in
                            Text(projectType.rawValue).tag(projectType)
                        }
                    }
                }

                Section {
                    Text(type.rawValue)
                        .font(.headline)
                    Text("Target: \(type.targetPageCount) pages")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("New Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createProject()
                    }
                    .disabled(title.isEmpty || isCreating)
                }
            }
        }
    }

    private func createProject() {
        isCreating = true

        Task {
            do {
                try await appState.createProject(
                    title: title,
                    type: type,
                    author: author.isEmpty ? "Unknown" : author
                )
                dismiss()
            } catch {
                print("Failed to create project: \(error)")
            }
            isCreating = false
        }
    }
}

struct TimelinePlaceholderView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(spacing: 20) {
            Text("Timeline View")
                .font(.largeTitle)
                .padding(.top, 40)

            if let project = appState.currentProject {
                VStack(spacing: 12) {
                    Text(project.title)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("\(project.scenes?.count ?? 0) scenes • \(String(format: "%.1f", project.currentPageCount)) pages")
                        .foregroundStyle(.secondary)
                }

                Divider()
                    .padding(.vertical)

                // Scene list
                if let scenes = project.scenes {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(scenes) { scene in
                                Button {
                                    appState.selectScene(scene)
                                    appState.navigateTo(.scriptEditor)
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Scene \(scene.sceneNumber)")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)

                                            Text(scene.slugLine.formatted)
                                                .font(.headline)

                                            Text("\(String(format: "%.2f", scene.pageLength)) pages")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding()
                                    .background(Color(.systemBackground))
                                    .cornerRadius(8)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }

                Button {
                    Task {
                        try? await appState.addScene()
                        appState.navigateTo(.scriptEditor)
                    }
                } label: {
                    Label("Add New Scene", systemImage: "plus.circle")
                }
                .buttonStyle(.borderedProminent)
            }

            Button("Back to Projects") {
                appState.goBack()
            }
            .padding(.top)
        }
        .padding()
        .navigationTitle("Timeline")
    }
}

struct EditorPlaceholderView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        if let scene = appState.currentScene {
            ScriptEditorView(scene: scene)
        } else {
            VStack(spacing: 20) {
                Text("No Scene Selected")
                    .font(.largeTitle)

                Button("Back to Timeline") {
                    appState.goBack()
                }
            }
            .padding()
            .navigationTitle("Editor")
        }
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
