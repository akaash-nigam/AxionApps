//
//  RepositoryDetailView.swift
//  SpatialCodeReviewer
//
//  Created by Claude on 2025-11-24.
//

import SwiftUI

struct RepositoryDetailView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel: RepositoryDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    let repository: Repository

    init(repository: Repository) {
        self.repository = repository
        _viewModel = StateObject(wrappedValue: RepositoryDetailViewModel(repository: repository))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                header

                Divider()

                // Repository Stats
                stats

                Divider()

                // Branch Selection
                branchSection

                Divider()

                // Download Status
                downloadSection

                // Actions
                actionsSection
            }
            .padding()
        }
        .navigationTitle(repository.name)
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadBranches()
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .alert("Download Complete", isPresented: $viewModel.showDownloadComplete) {
            Button("Start Review") {
                openImmersiveView()
            }
            Button("OK", role: .cancel) { }
        } message: {
            Text("Repository has been downloaded successfully")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Repository name and owner
            VStack(alignment: .leading, spacing: 4) {
                Text(repository.name)
                    .font(.title)
                    .fontWeight(.bold)

                Text(repository.fullName)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            // Description
            if let description = repository.description {
                Text(description)
                    .font(.body)
                    .foregroundStyle(.primary)
            }

            // Topics/Tags
            if !repository.topics.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(repository.topics, id: \.self) { topic in
                            Text(topic)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.blue.opacity(0.2))
                                .cornerRadius(12)
                        }
                    }
                }
            }

            // Links
            HStack(spacing: 16) {
                if repository.hasWiki {
                    Label("Wiki", systemImage: "book.fill")
                        .font(.caption)
                }

                if repository.hasIssues {
                    Label("Issues", systemImage: "exclamationmark.circle.fill")
                        .font(.caption)
                }

                if repository.hasProjects {
                    Label("Projects", systemImage: "square.grid.2x2.fill")
                        .font(.caption)
                }
            }
            .foregroundStyle(.secondary)
        }
    }

    private var stats: some View {
        HStack(spacing: 32) {
            StatItem(
                icon: "star.fill",
                value: "\(repository.stargazersCount)",
                label: "Stars",
                color: .yellow
            )

            StatItem(
                icon: "tuningfork",
                value: "\(repository.forksCount)",
                label: "Forks",
                color: .blue
            )

            if repository.openIssuesCount > 0 {
                StatItem(
                    icon: "exclamationmark.circle.fill",
                    value: "\(repository.openIssuesCount)",
                    label: "Issues",
                    color: .red
                )
            }

            if let language = repository.language {
                StatItem(
                    icon: "chevron.left.forwardslash.chevron.right",
                    value: language,
                    label: "Language",
                    color: .green
                )
            }
        }
    }

    private var branchSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Branch")
                .font(.headline)

            if viewModel.isLoadingBranches {
                HStack {
                    ProgressView()
                    Text("Loading branches...")
                        .foregroundStyle(.secondary)
                }
                .padding()
            } else if viewModel.branches.isEmpty {
                Text("No branches found")
                    .foregroundStyle(.secondary)
                    .padding()
            } else {
                Menu {
                    ForEach(viewModel.branches) { branch in
                        Button(branch.name) {
                            viewModel.selectedBranch = branch
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "chevron.branch")
                        Text(viewModel.selectedBranch?.name ?? "Select a branch")
                        Spacer()
                        Image(systemName: "chevron.down")
                    }
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(10)
                }

                if let branch = viewModel.selectedBranch {
                    HStack(spacing: 8) {
                        Image(systemName: branch.protected ? "lock.fill" : "lock.open.fill")
                            .font(.caption)
                        Text(branch.protected ? "Protected branch" : "Unprotected branch")
                            .font(.caption)
                        Spacer()
                        Text("SHA: \(branch.commit.sha.prefix(7))")
                            .font(.caption.monospaced())
                    }
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                }
            }
        }
    }

    private var downloadSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Download Status")
                .font(.headline)

            if viewModel.isDownloaded {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Repository downloaded")
                    Spacer()
                    if let metadata = viewModel.metadata {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Branch: \(metadata.branch)")
                                .font(.caption)
                            Text("Downloaded \(metadata.downloadedAt.formatted(.relative(presentation: .named)))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
                .background(.green.opacity(0.1))
                .cornerRadius(10)
            } else {
                HStack {
                    Image(systemName: "arrow.down.circle")
                        .foregroundStyle(.blue)
                    Text("Repository not downloaded")
                    Spacer()
                }
                .padding()
                .background(.blue.opacity(0.1))
                .cornerRadius(10)
            }

            if viewModel.isDownloading {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Downloading...")
                        Spacer()
                        Text("\(Int(viewModel.downloadProgress * 100))%")
                            .font(.caption.monospaced())
                    }

                    ProgressView(value: viewModel.downloadProgress)
                        .progressViewStyle(.linear)
                }
                .padding()
                .background(.blue.opacity(0.1))
                .cornerRadius(10)
            }
        }
    }

    private var actionsSection: some View {
        VStack(spacing: 12) {
            if viewModel.isDownloaded {
                // Start Review button
                Button {
                    openImmersiveView()
                } label: {
                    HStack {
                        Image(systemName: "cube.transparent")
                        Text("Start 3D Review")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
                }

                // Re-download button
                Button {
                    Task {
                        await viewModel.downloadRepository()
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Re-download Repository")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.orange.opacity(0.2))
                    .foregroundStyle(.orange)
                    .cornerRadius(12)
                }
                .disabled(viewModel.isDownloading || viewModel.selectedBranch == nil)

                // Delete button
                Button(role: .destructive) {
                    Task {
                        await viewModel.deleteRepository()
                    }
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete Local Copy")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.red.opacity(0.1))
                    .foregroundStyle(.red)
                    .cornerRadius(12)
                }
            } else {
                // Download button
                Button {
                    Task {
                        await viewModel.downloadRepository()
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                        Text("Download Repository")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
                }
                .disabled(viewModel.isDownloading || viewModel.selectedBranch == nil)
            }
        }
        .padding(.top)
    }

    private func openImmersiveView() {
        print("🚀 Opening immersive view for \(repository.name)")

        // Set the selected repository in app state
        appState.selectedRepository = repository

        // Open the immersive space
        Task {
            // Dismiss any existing immersive space first
            if appState.isImmersiveSpaceActive {
                await dismissImmersiveSpace()
            }

            // Open the new immersive space
            switch await openImmersiveSpace(id: "CodeReviewSpace") {
            case .opened:
                appState.isImmersiveSpaceActive = true
                print("✅ Immersive space opened successfully")
            case .error:
                print("❌ Failed to open immersive space")
            case .userCancelled:
                print("⚠️ User cancelled immersive space")
            @unknown default:
                print("⚠️ Unknown result from openImmersiveSpace")
            }
        }
    }
}

// MARK: - Stat Item

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.title2)

            Text(value)
                .font(.headline)
                .fontWeight(.bold)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - View Model

@MainActor
class RepositoryDetailViewModel: ObservableObject {
    @Published var branches: [Branch] = []
    @Published var selectedBranch: Branch?
    @Published var isLoadingBranches = false
    @Published var isDownloading = false
    @Published var downloadProgress: Double = 0.0
    @Published var isDownloaded = false
    @Published var metadata: RepositoryMetadata?
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var showDownloadComplete = false

    let repository: Repository
    private let repositoryService = RepositoryService()
    private let localRepoManager = LocalRepositoryManager.shared

    init(repository: Repository) {
        self.repository = repository
        checkIfDownloaded()
    }

    func loadBranches() async {
        isLoadingBranches = true
        defer { isLoadingBranches = false }

        do {
            branches = try await repositoryService.fetchBranches(
                owner: repository.owner.login,
                repo: repository.name
            )

            // Select default branch
            if let defaultBranch = branches.first(where: { $0.name == repository.defaultBranch }) {
                selectedBranch = defaultBranch
            } else if let first = branches.first {
                selectedBranch = first
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    func downloadRepository() async {
        guard let branch = selectedBranch else {
            errorMessage = "Please select a branch first"
            showError = true
            return
        }

        isDownloading = true
        defer { isDownloading = false }

        do {
            // Fetch repository contents
            let contents = try await repositoryService.fetchRepositoryContents(
                owner: repository.owner.login,
                repo: repository.name,
                path: "",
                ref: branch.name
            )

            // Download repository
            try await localRepoManager.downloadRepository(
                repository: repository,
                branch: branch.name,
                contents: contents,
                repositoryService: repositoryService
            )

            // Update download progress
            for await progress in AsyncStream<Double> { continuation in
                Task {
                    while localRepoManager.isDownloading {
                        continuation.yield(localRepoManager.downloadProgress)
                        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                    }
                    continuation.finish()
                }
            } {
                downloadProgress = progress
            }

            isDownloaded = true
            showDownloadComplete = true
            checkIfDownloaded()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    func deleteRepository() async {
        do {
            try localRepoManager.deleteRepository(
                owner: repository.owner.login,
                name: repository.name
            )
            isDownloaded = false
            metadata = nil
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    private func checkIfDownloaded() {
        isDownloaded = localRepoManager.isRepositoryDownloaded(
            owner: repository.owner.login,
            name: repository.name
        )

        if isDownloaded {
            metadata = try? localRepoManager.loadRepositoryMetadata(
                owner: repository.owner.login,
                name: repository.name
            )
        }
    }
}

#Preview {
    NavigationStack {
        RepositoryDetailView(repository: .mock)
            .environmentObject(AppState())
    }
}
