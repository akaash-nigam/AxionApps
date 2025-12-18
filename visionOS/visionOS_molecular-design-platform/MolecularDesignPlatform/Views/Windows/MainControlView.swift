//
//  MainControlView.swift
//  Molecular Design Platform
//
//  Main control panel with project browser and molecule library
//

import SwiftUI
import SwiftData

struct MainControlView: View {
    @Environment(\.appState) private var appState
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Molecule.modifiedDate, order: .reverse) private var molecules: [Molecule]
    @Query(sort: \Project.modifiedDate, order: .reverse) private var projects: [Project]

    @State private var searchText = ""
    @State private var selectedMolecule: Molecule?
    @State private var showingImportPicker = false

    var body: some View {
        NavigationSplitView {
            // Sidebar: Project browser
            ProjectSidebarView(projects: projects)
        } detail: {
            // Main area: Molecule library
            VStack(spacing: 0) {
                // Toolbar
                HStack {
                    Text("Molecule Library")
                        .font(.title2)
                        .bold()

                    Spacer()

                    Button(action: { showingImportPicker = true }) {
                        Label("Import", systemImage: "square.and.arrow.down")
                    }

                    Button(action: createNewMolecule) {
                        Label("New", systemImage: "plus")
                    }
                }
                .padding()

                // Search bar
                TextField("Search molecules...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                Divider()

                // Molecule grid
                if filteredMolecules.isEmpty {
                    EmptyMoleculesView()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 150), spacing: 16)
                        ], spacing: 16) {
                            ForEach(filteredMolecules) { molecule in
                                MoleculeCard(molecule: molecule)
                                    .onTapGesture {
                                        selectedMolecule = molecule
                                        openMoleculeViewer(molecule)
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .fileImporter(
            isPresented: $showingImportPicker,
            allowedContentTypes: [.item],
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result)
        }
    }

    private var filteredMolecules: [Molecule] {
        if searchText.isEmpty {
            return molecules
        } else {
            return molecules.filter { molecule in
                molecule.name.localizedCaseInsensitiveContains(searchText) ||
                molecule.formula.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    private func openMoleculeViewer(_ molecule: Molecule) {
        appState?.sceneCoordinator.openMoleculeViewer(molecule: molecule)
        // In real implementation, use openWindow(id: "molecule-viewer")
    }

    private func createNewMolecule() {
        let newMolecule = Molecule(name: "New Molecule")
        modelContext.insert(newMolecule)
    }

    private func handleFileImport(_ result: Result<[URL], Error>) {
        Task {
            do {
                let urls = try result.get()
                guard let url = urls.first else { return }

                let molecule = try await appState?.services.fileService.importMolecule(from: url)
                if let molecule = molecule {
                    modelContext.insert(molecule)
                }
            } catch {
                print("Import failed: \(error)")
            }
        }
    }
}

// MARK: - Project Sidebar

struct ProjectSidebarView: View {
    let projects: [Project]

    var body: some View {
        List {
            Section("Projects") {
                if projects.isEmpty {
                    Text("No projects")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(projects) { project in
                        NavigationLink(value: project) {
                            Label(project.name, systemImage: "folder")
                        }
                    }
                }
            }

            Section("Recent") {
                Label("Recent Molecules", systemImage: "clock")
                Label("Favorites", systemImage: "star")
            }
        }
        .navigationTitle("Projects")
        .listStyle(.sidebar)
    }
}

// MARK: - Molecule Card

struct MoleculeCard: View {
    let molecule: Molecule

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Placeholder molecular visualization
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.blue.opacity(0.2))
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    Text(molecule.formula)
                        .font(.title3.monospaced())
                        .foregroundStyle(.secondary)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(molecule.name)
                    .font(.headline)
                    .lineLimit(1)

                Text(String(format: "MW: %.2f", molecule.molecularWeight))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("\(molecule.atoms.count) atoms")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Empty State

struct EmptyMoleculesView: View {
    var body: some View {
        ContentUnavailableView {
            Label("No Molecules", systemImage: "atom")
        } description: {
            Text("Import a molecule file or create a new molecule to get started")
        } actions: {
            Button("Create New Molecule") {
                // Action
            }
            .buttonStyle(.borderedProminent)

            Button("Import File") {
                // Action
            }
        }
    }
}
