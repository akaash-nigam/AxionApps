//
//  RepositoryListView.swift
//  SpatialCodeReviewer
//
//  Created by Claude on 2025-11-24.
//

import SwiftUI

struct RepositoryListView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = RepositoryListViewModel()
    @State private var searchText = ""
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Your Repositories")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Select a repository to start reviewing")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()

            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("Search repositories...", text: $searchText)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        performSearch()
                    }

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                        Task {
                            try? await viewModel.loadRepositories()
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            .background(.regularMaterial)
            .cornerRadius(10)
            .padding(.horizontal)

            // Repository list
            if viewModel.isLoading && viewModel.repositories.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.repositories.isEmpty {
                ContentUnavailableView(
                    "No Repositories",
                    systemImage: "folder",
                    description: Text("No repositories found")
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.repositories) { repo in
                            RepositoryRow(repository: repo)
                                .onTapGesture {
                                    selectRepository(repo)
                                }
                                .onAppear {
                                    // Load more when approaching the end
                                    if repo.id == viewModel.repositories.last?.id {
                                        loadMoreIfNeeded()
                                    }
                                }
                        }

                        // Load more indicator
                        if viewModel.hasMorePages {
                            HStack {
                                Spacer()
                                if viewModel.isLoading {
                                    ProgressView()
                                        .padding()
                                } else {
                                    Button("Load More") {
                                        loadMore()
                                    }
                                    .buttonStyle(.bordered)
                                    .padding()
                                }
                                Spacer()
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .task {
            await loadInitialData()
        }
        .refreshable {
            await refreshRepositories()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    private func loadInitialData() async {
        do {
            try await viewModel.loadRepositories()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    private func refreshRepositories() async {
        do {
            try await viewModel.refreshRepositories()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    private func loadMoreIfNeeded() {
        guard viewModel.hasMorePages, !viewModel.isLoading else { return }

        Task {
            do {
                try await viewModel.loadMoreRepositories()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }

    private func loadMore() {
        Task {
            do {
                try await viewModel.loadMoreRepositories()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }

    private func performSearch() {
        guard !searchText.isEmpty else {
            Task {
                try? await viewModel.loadRepositories()
            }
            return
        }

        Task {
            do {
                try await viewModel.searchRepositories(query: searchText)
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }

    private func selectRepository(_ repository: Repository) {
        appState.selectedRepository = repository
        // TODO: Navigate to repository detail or 3D view
    }
}

// MARK: - Repository Row

struct RepositoryRow: View {
    let repository: Repository

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(repository.name)
                        .font(.headline)

                    Text(repository.fullName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if repository.isPrivate {
                    Label("Private", systemImage: "lock.fill")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.yellow.opacity(0.2))
                        .cornerRadius(6)
                }
            }

            // Description
            if let description = repository.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            // Metadata
            HStack(spacing: 16) {
                if let language = repository.language {
                    Label(language, systemImage: "chevron.left.forwardslash.chevron.right")
                        .font(.caption)
                }

                Label("\(repository.stargazersCount)", systemImage: "star")
                    .font(.caption)

                Label("\(repository.forksCount)", systemImage: "tuningfork")
                    .font(.caption)

                if repository.openIssuesCount > 0 {
                    Label("\(repository.openIssuesCount)", systemImage: "exclamationmark.circle")
                        .font(.caption)
                }

                Spacer()

                Text("Updated \(repository.updatedAt.formatted(.relative(presentation: .named)))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
        .hoverEffect()
    }
}

// MARK: - View Model

@MainActor
class RepositoryListViewModel: ObservableObject {
    @Published var repositories: [Repository] = []
    @Published var isLoading = false
    @Published var hasMorePages = true

    private let repositoryService: RepositoryService

    init(repositoryService: RepositoryService? = nil) {
        self.repositoryService = repositoryService ?? RepositoryService()
    }

    func loadRepositories() async throws {
        repositories = try await repositoryService.fetchRepositories(page: 1)
        hasMorePages = repositoryService.hasMorePages
    }

    func refreshRepositories() async throws {
        try await repositoryService.refreshRepositories()
        repositories = repositoryService.repositories
        hasMorePages = repositoryService.hasMorePages
    }

    func loadMoreRepositories() async throws {
        try await repositoryService.loadMoreRepositories()
        repositories = repositoryService.repositories
        hasMorePages = repositoryService.hasMorePages
    }

    func searchRepositories(query: String) async throws {
        repositories = try await repositoryService.searchRepositories(query: query, page: 1)
        hasMorePages = repositoryService.hasMorePages
    }
}

#Preview {
    RepositoryListView()
        .environmentObject(AppState())
}
