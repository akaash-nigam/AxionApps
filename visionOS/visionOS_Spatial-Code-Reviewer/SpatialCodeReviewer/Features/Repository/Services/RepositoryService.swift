//
//  RepositoryService.swift
//  SpatialCodeReviewer
//
//  Created by Claude on 2025-11-24.
//

import Foundation

@MainActor
class RepositoryService: ObservableObject {
    @Published var repositories: [Repository] = []
    @Published var isLoading = false
    @Published var currentPage = 1
    @Published var hasMorePages = true

    private let apiClient = GitHubAPIClient.shared
    private let authService: AuthService

    init(authService: AuthService = AuthService()) {
        self.authService = authService
    }

    // MARK: - Token Management

    private func getToken() throws -> String {
        guard let token = authService.currentToken else {
            throw APIError.noToken
        }
        return token.accessToken
    }

    // MARK: - Fetch Repositories

    func fetchRepositories(
        page: Int = 1,
        perPage: Int = 30,
        sort: RepositorySort = .updated
    ) async throws -> [Repository] {
        isLoading = true
        defer { isLoading = false }

        let token = try getToken()

        let response = try await apiClient.fetchRepositories(
            token: token,
            page: page,
            perPage: perPage,
            sort: sort,
            direction: .desc
        )

        currentPage = page
        hasMorePages = response.pagination?.nextPage != nil

        if page == 1 {
            repositories = response.repositories
        } else {
            repositories.append(contentsOf: response.repositories)
        }

        return response.repositories
    }

    func loadMoreRepositories() async throws {
        guard hasMorePages, !isLoading else { return }

        let nextPage = currentPage + 1
        _ = try await fetchRepositories(page: nextPage)
    }

    func refreshRepositories() async throws {
        currentPage = 1
        hasMorePages = true
        _ = try await fetchRepositories(page: 1)
    }

    // MARK: - Search Repositories

    func searchRepositories(
        query: String,
        page: Int = 1,
        perPage: Int = 30
    ) async throws -> [Repository] {
        isLoading = true
        defer { isLoading = false }

        let token = try getToken()

        let response = try await apiClient.searchRepositories(
            query: query,
            token: token,
            page: page,
            perPage: perPage
        )

        currentPage = page
        hasMorePages = response.pagination?.nextPage != nil

        if page == 1 {
            repositories = response.repositories
        } else {
            repositories.append(contentsOf: response.repositories)
        }

        return response.repositories
    }

    // MARK: - Fetch Single Repository

    func fetchRepository(owner: String, name: String) async throws -> Repository {
        isLoading = true
        defer { isLoading = false }

        let token = try getToken()

        let repository = try await apiClient.fetchRepository(
            owner: owner,
            name: name,
            token: token
        )

        return repository
    }

    // MARK: - Repository Contents

    func fetchRepositoryContents(
        owner: String,
        repo: String,
        path: String = "",
        ref: String? = nil
    ) async throws -> [RepositoryContent] {
        let token = try getToken()

        let contents = try await apiClient.fetchRepositoryContents(
            owner: owner,
            repo: repo,
            path: path,
            ref: ref,
            token: token
        )

        return contents
    }

    func fetchBranches(owner: String, repo: String) async throws -> [Branch] {
        let token = try getToken()

        let branches = try await apiClient.fetchBranches(
            owner: owner,
            repo: repo,
            token: token
        )

        return branches
    }
}

// MARK: - Repository Errors

enum RepositoryError: LocalizedError {
    case notFound
    case fetchFailed(String)
    case cloneFailed(String)

    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Repository not found"
        case .fetchFailed(let message):
            return "Failed to fetch repository: \(message)"
        case .cloneFailed(let message):
            return "Failed to clone repository: \(message)"
        }
    }
}
