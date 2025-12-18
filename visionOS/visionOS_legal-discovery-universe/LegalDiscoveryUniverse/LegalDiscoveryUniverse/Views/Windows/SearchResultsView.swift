//
//  SearchResultsView.swift
//  Legal Discovery Universe
//
//  Created on 2025-11-17.
//

import SwiftUI
import SwiftData

struct SearchResultsView: View {
    @State private var searchQuery = ""
    @State private var selectedFilters: Set<DocumentType> = []

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search header
                searchHeader

                Divider()

                HStack(spacing: 0) {
                    // Filters sidebar
                    filtersSidebar
                        .frame(width: 250)

                    Divider()

                    // Results
                    resultsView
                }
            }
            .navigationTitle("Search Results")
        }
    }

    private var searchHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search documents...", text: $searchQuery)
                    .textFieldStyle(.plain)

                Button("Search") {
                    performSearch()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

            if !searchQuery.isEmpty {
                HStack {
                    Text("347 results found in 0.43 seconds")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Picker("Sort", selection: .constant("Relevance")) {
                        Text("Relevance").tag("Relevance")
                        Text("Date").tag("Date")
                        Text("Title").tag("Title")
                    }
                    .pickerStyle(.menu)
                }
            }
        }
        .padding()
    }

    private var filtersSidebar: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Filters")
                    .font(.headline)

                // Document type filters
                VStack(alignment: .leading, spacing: 8) {
                    Text("Document Type")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    ForEach([DocumentType.pdf, .word, .email, .spreadsheet], id: \.self) { type in
                        Toggle(type.rawValue, isOn: Binding(
                            get: { selectedFilters.contains(type) },
                            set: { isOn in
                                if isOn {
                                    selectedFilters.insert(type)
                                } else {
                                    selectedFilters.remove(type)
                                }
                            }
                        ))
                        .toggleStyle(.checkbox)
                    }
                }

                Divider()

                // More filters...
                Text("Date Range")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // Placeholder for date picker
            }
            .padding()
        }
        .background(.ultraThinMaterial)
    }

    private var resultsView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                // Placeholder results
                ForEach(0..<10) { index in
                    SearchResultCard(
                        title: "Example Document \(index + 1)",
                        relevance: Double.random(in: 0.7...0.99),
                        excerpt: "...termination clause shall apply in the event of..."
                    )
                }
            }
            .padding()
        }
    }

    private func performSearch() {
        // Search implementation
    }
}

struct SearchResultCard: View {
    let title: String
    let relevance: Double
    let excerpt: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "doc.fill")
                    .foregroundStyle(.blue)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)

                    HStack {
                        Text("Relevance: \(Int(relevance * 100))%")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("• Page 14")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Text("\(Int(relevance * 100))%")
                    .font(.title3)
                    .bold()
                    .foregroundStyle(.blue)
            }

            Text(excerpt)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.yellow.opacity(0.2), in: RoundedRectangle(cornerRadius: 4))
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    SearchResultsView()
}
