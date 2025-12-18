//
//  KnowledgeSearchView.swift
//  Institutional Memory Vault
//
//  Search and discovery interface
//

import SwiftUI
import SwiftData

struct KnowledgeSearchView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow

    @Query private var allKnowledge: [KnowledgeEntity]

    @State private var searchText: String = ""
    @State private var selectedContentType: KnowledgeContentType?
    @State private var filteredResults: [KnowledgeEntity] = []

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // MARK: Search Bar
                searchBar

                // MARK: Filters
                filterSection

                // MARK: Results
                resultsList

                Spacer()
            }
            .padding()
            .navigationTitle("Search Knowledge")
        }
        .onChange(of: searchText) { _, newValue in
            performSearch()
        }
        .onChange(of: selectedContentType) { _, _ in
            performSearch()
        }
        .onAppear {
            filteredResults = allKnowledge
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Search institutional memory...", text: $searchText)
                .textFieldStyle(.plain)
                .font(.body)
        }
        .padding()
        .background(.quaternary.opacity(0.5))
        .cornerRadius(10)
    }

    // MARK: - Filters

    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                FilterChip(
                    title: "All",
                    isSelected: selectedContentType == nil
                ) {
                    selectedContentType = nil
                }

                ForEach([
                    KnowledgeContentType.decision,
                    .expertise,
                    .process,
                    .story,
                    .lesson,
                    .innovation
                ], id: \.self) { type in
                    FilterChip(
                        title: type.rawValue.capitalized,
                        isSelected: selectedContentType == type
                    ) {
                        selectedContentType = type
                    }
                }
            }
        }
    }

    // MARK: - Results List

    private var resultsList: some View {
        ScrollView {
            VStack(spacing: 10) {
                if filteredResults.isEmpty {
                    emptyResultsView
                } else {
                    ForEach(filteredResults) { knowledge in
                        KnowledgeRowView(knowledge: knowledge)
                            .onTapGesture {
                                openWindow(id: "detail", value: knowledge.id)
                            }
                    }
                }
            }
        }
    }

    private var emptyResultsView: some View {
        VStack(spacing: 15) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No results found")
                .font(.headline)

            Text("Try adjusting your search or filters")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(60)
    }

    // MARK: - Search Logic

    private func performSearch() {
        var results = allKnowledge

        // Filter by content type
        if let type = selectedContentType {
            results = results.filter { $0.contentType == type }
        }

        // Filter by search text
        if !searchText.isEmpty {
            results = results.filter { knowledge in
                knowledge.title.localizedCaseInsensitiveContains(searchText) ||
                knowledge.content.localizedCaseInsensitiveContains(searchText) ||
                knowledge.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            }
        }

        filteredResults = results
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.2))
                .foregroundStyle(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    KnowledgeSearchView()
        .environment(AppState())
}
