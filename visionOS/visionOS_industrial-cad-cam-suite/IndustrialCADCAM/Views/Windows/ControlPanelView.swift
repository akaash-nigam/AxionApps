import SwiftUI
import SwiftData

struct ControlPanelView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    @Query(sort: \DesignProject.modifiedDate, order: .reverse)
    private var projects: [DesignProject]

    @State private var selectedProject: DesignProject?
    @State private var showNewProjectSheet = false
    @State private var newProjectName = ""
    @State private var newProjectDescription = ""

    var body: some View {
        NavigationSplitView {
            // MARK: Project Browser Sidebar
            List(selection: $selectedProject) {
                Section("Recent Projects") {
                    ForEach(projects) { project in
                        ProjectRow(project: project)
                            .tag(project)
                    }
                    .onDelete(perform: deleteProjects)
                }

                Section {
                    Button {
                        showNewProjectSheet = true
                    } label: {
                        Label("New Project", systemImage: "plus.circle.fill")
                    }
                }
            }
            .navigationTitle("Industrial CAD/CAM")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button("New Project", systemImage: "doc.badge.plus") {
                            showNewProjectSheet = true
                        }
                        Button("Import STEP", systemImage: "arrow.down.doc") {
                            // Import functionality
                        }
                        Divider()
                        Button("Open Library", systemImage: "books.vertical") {
                            openWindow(id: "library")
                        }
                    } label: {
                        Label("File", systemImage: "folder")
                    }
                }
            }
        } detail: {
            // MARK: Detail View
            if let project = selectedProject {
                ProjectDetailView(project: project)
            } else {
                EmptyStateView()
            }
        }
        .sheet(isPresented: $showNewProjectSheet) {
            NewProjectSheet(
                name: $newProjectName,
                description: $newProjectDescription,
                onCreate: createNewProject
            )
        }
    }

    // MARK: - Actions
    private func deleteProjects(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(projects[index])
        }
        try? modelContext.save()
    }

    private func createNewProject() {
        let project = DesignProject(
            name: newProjectName,
            description: newProjectDescription
        )
        modelContext.insert(project)
        try? modelContext.save()

        selectedProject = project
        appState.currentProject = project

        newProjectName = ""
        newProjectDescription = ""
        showNewProjectSheet = false
    }
}

// MARK: - Project Row
struct ProjectRow: View {
    let project: DesignProject

    var body: some View {
        HStack {
            Image(systemName: "cube.box.fill")
                .font(.title2)
                .foregroundStyle(.blue)

            VStack(alignment: .leading, spacing: 4) {
                Text(project.name)
                    .font(.headline)

                HStack {
                    Text("\(project.partCount) parts")
                    Text("•")
                    Text(project.modifiedDate, style: .relative)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            StatusBadge(status: project.status)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Project Detail View
struct ProjectDetailView: View {
    let project: DesignProject
    @Environment(AppState.self) private var appState
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text(project.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text(project.projectDescription)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    StatusBadge(status: project.status)
                }

                // Quick Actions
                HStack(spacing: 16) {
                    ActionButton(
                        title: "Design Studio",
                        icon: "cube.transparent",
                        color: .blue
                    ) {
                        appState.currentProject = project
                        Task {
                            await openImmersiveSpace(id: "design-studio")
                        }
                    }

                    ActionButton(
                        title: "Part Viewer",
                        icon: "view.3d",
                        color: .green
                    ) {
                        openWindow(id: "part-viewer")
                    }

                    ActionButton(
                        title: "Inspector",
                        icon: "sidebar.right",
                        color: .orange
                    ) {
                        openWindow(id: "inspector")
                    }
                }

                Divider()

                // Project Stats
                ProjectStatsView(project: project)

                Divider()

                // Parts List
                PartsListView(parts: project.parts)

                // Assemblies List
                if !project.assemblies.isEmpty {
                    AssembliesListView(assemblies: project.assemblies)
                }
            }
            .padding()
        }
        .background(.regularMaterial)
    }
}

// MARK: - Empty State
struct EmptyStateView: View {
    var body: some View {
        ContentUnavailableView {
            Label("No Project Selected", systemImage: "cube.box")
        } description: {
            Text("Select a project from the sidebar or create a new one to get started")
        }
    }
}

// MARK: - Supporting Views
struct StatusBadge: View {
    let status: String

    var body: some View {
        Text(status.capitalized)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .foregroundStyle(statusColor)
            .clipShape(Capsule())
    }

    var statusColor: Color {
        switch status {
        case "draft": return .gray
        case "in_progress": return .orange
        case "review": return .purple
        case "approved": return .green
        default: return .gray
        }
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundStyle(color)

                Text(title)
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .hoverEffect()
    }
}

struct ProjectStatsView: View {
    let project: DesignProject

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Project Statistics")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatItem(title: "Parts", value: "\(project.partCount)", icon: "cube")
                StatItem(title: "Assemblies", value: "\(project.assemblyCount)", icon: "square.stack.3d.up")
                StatItem(title: "Version", value: project.version, icon: "number")
            }
        }
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct PartsListView: View {
    let parts: [Part]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Parts (\(parts.count))")
                .font(.headline)

            ForEach(parts.prefix(5)) { part in
                PartRowCompact(part: part)
            }

            if parts.count > 5 {
                Text("+ \(parts.count - 5) more parts")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct PartRowCompact: View {
    let part: Part

    var body: some View {
        HStack {
            Image(systemName: "cube")
                .foregroundStyle(.blue)

            VStack(alignment: .leading, spacing: 2) {
                Text(part.name)
                    .font(.subheadline)

                Text("\(part.partNumber) • \(part.materialName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(Int(part.mass))g")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct AssembliesListView: View {
    let assemblies: [Assembly]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Assemblies (\(assemblies.count))")
                .font(.headline)

            ForEach(assemblies) { assembly in
                AssemblyRowCompact(assembly: assembly)
            }
        }
    }
}

struct AssemblyRowCompact: View {
    let assembly: Assembly

    var body: some View {
        HStack {
            Image(systemName: "square.stack.3d.up.fill")
                .foregroundStyle(.green)

            VStack(alignment: .leading, spacing: 2) {
                Text(assembly.name)
                    .font(.subheadline)

                Text("\(assembly.partCount) components")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if assembly.hasInterferences {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - New Project Sheet
struct NewProjectSheet: View {
    @Binding var name: String
    @Binding var description: String
    let onCreate: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Project Details") {
                    TextField("Project Name", text: $name)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Settings") {
                    Picker("Units", selection: .constant("metric")) {
                        Text("Metric (mm)").tag("metric")
                        Text("Imperial (in)").tag("imperial")
                    }
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
                        onCreate()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
        .frame(width: 500, height: 400)
    }
}

#Preview {
    ControlPanelView()
        .environment(AppState())
}
