//
//  ProjectBrowserView.swift
//  IndustrialCADCAM
//
//  Project browser window - entry point for the application
//

import SwiftUI
import SwiftData

struct ProjectBrowserView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Environment(\.openWindow) private var openWindow

    @Query(sort: \Project.modifiedDate, order: .reverse)
    private var projects: [Project]

    @State private var searchText = ""
    @State private var selectedProject: Project?
    @State private var showingNewProjectSheet = false

    var body: some View {
        NavigationSplitView {
            // Sidebar
            List(selection: $selectedProject) {
                Section("Recent Projects") {
                    ForEach(recentProjects) { project in
                        ProjectRow(project: project)
                            .tag(project)
                    }
                }

                Section("All Projects") {
                    ForEach(filteredProjects) { project in
                        ProjectRow(project: project)
                            .tag(project)
                    }
                    .onDelete(perform: deleteProjects)
                }
            }
            .navigationTitle("Industrial CAD/CAM Suite")
            .searchable(text: $searchText, prompt: "Search projects...")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingNewProjectSheet = true }) {
                        Label("New Project", systemImage: "plus")
                    }
                }

                ToolbarItem(placement: .automatic) {
                    Button(action: {}) {
                        Label("Settings", systemImage: "gear")
                    }
                }
            }
        } detail: {
            if let project = selectedProject {
                ProjectDetailView(project: project)
            } else {
                ContentUnavailableView(
                    "No Project Selected",
                    systemImage: "tray",
                    description: Text("Select a project from the sidebar or create a new one")
                )
            }
        }
        .sheet(isPresented: $showingNewProjectSheet) {
            NewProjectSheet()
        }
    }

    // MARK: - Computed Properties

    private var recentProjects: [Project] {
        Array(projects.prefix(5))
    }

    private var filteredProjects: [Project] {
        if searchText.isEmpty {
            return projects
        } else {
            return projects.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    // MARK: - Methods

    private func deleteProjects(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(projects[index])
        }
    }
}

// MARK: - Project Row

struct ProjectRow: View {
    let project: Project

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "gearshape.2")
                    .foregroundStyle(.blue)

                Text(project.name)
                    .font(.headline)

                Spacer()
            }

            Text("Modified: \(project.modifiedDate.formatted(.relative(presentation: .named)))")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("\(project.parts.count) parts • \(project.assemblies.count) assemblies")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Project Detail View

struct ProjectDetailView: View {
    @Environment(\.openWindow) private var openWindow
    let project: Project

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "gearshape.2.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)

            Text(project.name)
                .font(.title)

            if let description = project.projectDescription {
                Text(description)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                InfoRow(label: "Created", value: project.createdDate.formatted(date: .abbreviated, time: .omitted))
                InfoRow(label: "Modified", value: project.modifiedDate.formatted(date: .abbreviated, time: .omitted))
                InfoRow(label: "Parts", value: "\(project.parts.count)")
                InfoRow(label: "Assemblies", value: "\(project.assemblies.count)")
            }
            .frame(maxWidth: 300)

            Spacer()

            // Action Buttons
            VStack(spacing: 12) {
                Button(action: { openProjectInDesignVolume() }) {
                    Label("Open in Design Volume", systemImage: "cube")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button(action: { openProjectInImmersiveMode() }) {
                    Label("Open in Immersive Mode", systemImage: "visionpro")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .frame(maxWidth: 300)
        }
        .padding()
    }

    private func openProjectInDesignVolume() {
        openWindow(id: "design-volume")
    }

    private func openProjectInImmersiveMode() {
        openWindow(id: "immersive-prototype")
    }
}

// MARK: - Info Row

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

// MARK: - New Project Sheet

struct NewProjectSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var projectName = ""
    @State private var projectDescription = ""
    @State private var selectedTemplate: ProjectTemplate?

    var body: some View {
        NavigationStack {
            Form {
                Section("Project Information") {
                    TextField("Project Name", text: $projectName)
                    TextField("Description (optional)", text: $projectDescription, axis: .vertical)
                        .lineLimit(3...5)
                }

                Section("Templates") {
                    ForEach(ProjectTemplate.allTemplates) { template in
                        TemplateRow(template: template, isSelected: selectedTemplate == template)
                            .onTapGesture {
                                selectedTemplate = template
                            }
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
                        createProject()
                    }
                    .disabled(projectName.isEmpty)
                }
            }
        }
        .frame(minWidth: 500, minHeight: 400)
    }

    private func createProject() {
        let newProject = Project(name: projectName, description: projectDescription.isEmpty ? nil : projectDescription)
        modelContext.insert(newProject)

        // Add template parts if selected
        if let template = selectedTemplate {
            // TODO: Add template-specific initialization
        }

        dismiss()
    }
}

// MARK: - Template Row

struct TemplateRow: View {
    let template: ProjectTemplate
    let isSelected: Bool

    var body: some View {
        HStack {
            Image(systemName: template.icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(template.name)
                    .font(.headline)
                Text(template.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.blue)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

// MARK: - Project Template

struct ProjectTemplate: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let description: String
    let icon: String

    static let allTemplates = [
        ProjectTemplate(name: "Blank Project", description: "Start from scratch", icon: "doc"),
        ProjectTemplate(name: "Sheet Metal", description: "Parts for sheet metal fabrication", icon: "rectangle.stack"),
        ProjectTemplate(name: "Cast Part", description: "Design for casting processes", icon: "drop.triangle"),
        ProjectTemplate(name: "Welded Assembly", description: "Multi-part welded structure", icon: "link"),
        ProjectTemplate(name: "Machined Part", description: "CNC machined component", icon: "gearshape.2"),
    ]
}

#Preview {
    ProjectBrowserView()
        .frame(width: 1000, height: 700)
        .modelContainer(for: [Project.self, Part.self, Assembly.self], inMemory: true)
}
