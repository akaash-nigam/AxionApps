//
//  KnowledgeDetailView.swift
//  Institutional Memory Vault
//
//  Detailed view of a knowledge entity
//

import SwiftUI
import SwiftData

struct KnowledgeDetailView: View {
    let knowledgeId: UUID

    @Environment(\.modelContext) private var modelContext
    @State private var knowledge: KnowledgeEntity?

    var body: some View {
        ScrollView {
            if let knowledge {
                VStack(alignment: .leading, spacing: 25) {
                    // MARK: Header
                    headerSection(knowledge)

                    Divider()

                    // MARK: Context
                    contextSection(knowledge)

                    Divider()

                    // MARK: Content
                    contentSection(knowledge)

                    Divider()

                    // MARK: Connections
                    connectionsSection(knowledge)

                    Divider()

                    // MARK: Actions
                    actionsSection
                }
                .padding(40)
            } else {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Knowledge Details")
        .onAppear {
            loadKnowledge()
        }
    }

    // MARK: - Sections

    private func headerSection(_ knowledge: KnowledgeEntity) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(knowledge.title)
                .font(.largeTitle)
                .fontWeight(.bold)

            HStack(spacing: 15) {
                Label(knowledge.contentType.rawValue.capitalized, systemImage: iconForType(knowledge.contentType))
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(colorForType(knowledge.contentType).opacity(0.2))
                    .foregroundStyle(colorForType(knowledge.contentType))
                    .cornerRadius(6)

                if !knowledge.tags.isEmpty {
                    ForEach(knowledge.tags.prefix(3), id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(.quaternary)
                            .cornerRadius(4)
                    }
                }
            }
        }
    }

    private func contextSection(_ knowledge: KnowledgeEntity) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Context")
                .font(.headline)

            Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 10) {
                if let author = knowledge.author {
                    GridRow {
                        Text("Author")
                            .foregroundStyle(.secondary)
                        Text(author.name)
                    }
                }

                if let department = knowledge.department {
                    GridRow {
                        Text("Department")
                            .foregroundStyle(.secondary)
                        Text(department.name)
                    }
                }

                GridRow {
                    Text("Created")
                        .foregroundStyle(.secondary)
                    Text(knowledge.createdDate, style: .date)
                }

                GridRow {
                    Text("Last Modified")
                        .foregroundStyle(.secondary)
                    Text(knowledge.lastModified, style: .date)
                }

                GridRow {
                    Text("Access Level")
                        .foregroundStyle(.secondary)
                    Text(knowledge.accessLevel.description)
                }
            }
        }
    }

    private func contentSection(_ knowledge: KnowledgeEntity) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Content")
                .font(.headline)

            Text(knowledge.content)
                .font(.body)
                .lineLimit(nil)
        }
    }

    private func connectionsSection(_ knowledge: KnowledgeEntity) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Connected Knowledge")
                .font(.headline)

            if knowledge.connections.isEmpty {
                Text("No connections yet")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(knowledge.connections.prefix(5), id: \.id) { connection in
                        HStack {
                            Image(systemName: "link")
                                .foregroundStyle(.blue)

                            if let target = connection.targetEntity {
                                Text(target.title)
                                    .font(.subheadline)
                            }

                            Spacer()

                            Text(connection.connectionType.rawValue)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }

    private var actionsSection: some View {
        HStack(spacing: 15) {
            Button("Explore in 3D") {
                // Open 3D view
            }
            .buttonStyle(.bordered)

            Button("Add Connection") {
                // Add connection
            }
            .buttonStyle(.bordered)

            Button("Edit") {
                // Edit knowledge
            }
            .buttonStyle(.bordered)
        }
    }

    // MARK: - Data Loading

    private func loadKnowledge() {
        let descriptor = FetchDescriptor<KnowledgeEntity>(
            predicate: #Predicate { $0.id == knowledgeId }
        )

        do {
            let results = try modelContext.fetch(descriptor)
            knowledge = results.first
        } catch {
            print("Failed to load knowledge: \(error)")
        }
    }

    // MARK: - Helpers

    private func iconForType(_ type: KnowledgeContentType) -> String {
        switch type {
        case .document: return "doc.text"
        case .expertise: return "brain"
        case .decision: return "bolt.circle"
        case .process: return "arrow.triangle.2.circlepath"
        case .story: return "book"
        case .lesson: return "graduationcap"
        case .innovation: return "lightbulb"
        }
    }

    private func colorForType(_ type: KnowledgeContentType) -> Color {
        switch type {
        case .document: return .gray
        case .expertise: return .orange
        case .decision: return .purple
        case .process: return .blue
        case .story: return .pink
        case .lesson: return .yellow
        case .innovation: return .cyan
        }
    }
}

extension AccessLevel {
    var description: String {
        switch self {
        case .publicOrg: return "Organization"
        case .department: return "Department"
        case .team: return "Team"
        case .confidential: return "Confidential"
        case .restricted: return "Restricted"
        }
    }
}

#Preview {
    KnowledgeDetailView(knowledgeId: UUID())
}
