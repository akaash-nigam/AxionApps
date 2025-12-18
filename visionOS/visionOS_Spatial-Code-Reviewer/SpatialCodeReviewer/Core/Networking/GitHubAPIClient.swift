//
//  GitHubAPIClient.swift
//  SpatialCodeReviewer
//
//  Created by Claude on 2025-11-24.
//

import Foundation

/// GitHub API client for making authenticated requests
@MainActor
class GitHubAPIClient {
    static let shared = GitHubAPIClient()

    private let baseURL = "https://api.github.com"
    private let session: URLSession

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: configuration)
    }

    // MARK: - Request Builder

    private func buildRequest(
        endpoint: String,
        method: String = "GET",
        queryItems: [URLQueryItem]? = nil,
        body: Data? = nil
    ) throws -> URLRequest {
        var urlComponents = URLComponents(string: "\(baseURL)\(endpoint)")!

        if let queryItems = queryItems {
            urlComponents.queryItems = queryItems
        }

        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body

        // GitHub API headers
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")

        return request
    }

    private func authenticatedRequest(
        endpoint: String,
        method: String = "GET",
        queryItems: [URLQueryItem]? = nil,
        body: Data? = nil,
        token: String
    ) throws -> URLRequest {
        var request = try buildRequest(
            endpoint: endpoint,
            method: method,
            queryItems: queryItems,
            body: body
        )

        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return request
    }

    // MARK: - Network Execution

    private func execute<T: Decodable>(
        request: URLRequest,
        responseType: T.Type
    ) async throws -> (T, PaginationInfo?) {
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        // Handle rate limiting
        if httpResponse.statusCode == 403,
           let remaining = httpResponse.value(forHTTPHeaderField: "X-RateLimit-Remaining"),
           remaining == "0" {
            throw APIError.rateLimitExceeded
        }

        guard httpResponse.statusCode == 200 else {
            // Try to parse error message from GitHub
            if let errorResponse = try? JSONDecoder().decode(GitHubError.self, from: data) {
                throw APIError.githubError(message: errorResponse.message)
            }
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let decoded = try decoder.decode(T.self, from: data)

        // Extract pagination info from Link header
        let paginationInfo = PaginationInfo.from(linkHeader: httpResponse.value(forHTTPHeaderField: "Link"))

        return (decoded, paginationInfo)
    }

    // MARK: - User API

    func fetchCurrentUser(token: String) async throws -> User {
        let request = try authenticatedRequest(
            endpoint: "/user",
            token: token
        )

        let (user, _) = try await execute(request: request, responseType: User.self)
        return user
    }

    // MARK: - Repository API

    func fetchRepositories(
        token: String,
        page: Int = 1,
        perPage: Int = 30,
        sort: RepositorySort = .updated,
        direction: SortDirection = .desc
    ) async throws -> RepositoryListResponse {
        let queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)"),
            URLQueryItem(name: "sort", value: sort.rawValue),
            URLQueryItem(name: "direction", value: direction.rawValue)
        ]

        let request = try authenticatedRequest(
            endpoint: "/user/repos",
            queryItems: queryItems,
            token: token
        )

        let (repositories, paginationInfo) = try await execute(
            request: request,
            responseType: [Repository].self
        )

        return RepositoryListResponse(
            repositories: repositories,
            pagination: paginationInfo
        )
    }

    func searchRepositories(
        query: String,
        token: String,
        page: Int = 1,
        perPage: Int = 30
    ) async throws -> RepositorySearchResponse {
        let queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]

        let request = try authenticatedRequest(
            endpoint: "/search/repositories",
            queryItems: queryItems,
            token: token
        )

        let (response, paginationInfo) = try await execute(
            request: request,
            responseType: GitHubSearchResponse.self
        )

        return RepositorySearchResponse(
            repositories: response.items,
            totalCount: response.totalCount,
            pagination: paginationInfo
        )
    }

    func fetchRepository(
        owner: String,
        name: String,
        token: String
    ) async throws -> Repository {
        let request = try authenticatedRequest(
            endpoint: "/repos/\(owner)/\(name)",
            token: token
        )

        let (repository, _) = try await execute(request: request, responseType: Repository.self)
        return repository
    }

    // MARK: - Repository Content API

    func fetchRepositoryContents(
        owner: String,
        repo: String,
        path: String = "",
        ref: String? = nil,
        token: String
    ) async throws -> [RepositoryContent] {
        var queryItems: [URLQueryItem] = []
        if let ref = ref {
            queryItems.append(URLQueryItem(name: "ref", value: ref))
        }

        let request = try authenticatedRequest(
            endpoint: "/repos/\(owner)/\(repo)/contents/\(path)",
            queryItems: queryItems.isEmpty ? nil : queryItems,
            token: token
        )

        let (contents, _) = try await execute(
            request: request,
            responseType: [RepositoryContent].self
        )

        return contents
    }

    func fetchBranches(
        owner: String,
        repo: String,
        token: String
    ) async throws -> [Branch] {
        let request = try authenticatedRequest(
            endpoint: "/repos/\(owner)/\(repo)/branches",
            token: token
        )

        let (branches, _) = try await execute(request: request, responseType: [Branch].self)
        return branches
    }
}

// MARK: - Response Types

struct RepositoryListResponse {
    let repositories: [Repository]
    let pagination: PaginationInfo?
}

struct RepositorySearchResponse {
    let repositories: [Repository]
    let totalCount: Int
    let pagination: PaginationInfo?
}

struct GitHubSearchResponse: Codable {
    let totalCount: Int
    let incompleteResults: Bool
    let items: [Repository]
}

struct PaginationInfo {
    let nextPage: Int?
    let lastPage: Int?
    let firstPage: Int?
    let prevPage: Int?

    static func from(linkHeader: String?) -> PaginationInfo? {
        guard let linkHeader = linkHeader else { return nil }

        var nextPage: Int?
        var lastPage: Int?
        var firstPage: Int?
        var prevPage: Int?

        let links = linkHeader.components(separatedBy: ",")
        for link in links {
            let components = link.components(separatedBy: ";")
            guard components.count == 2 else { continue }

            let urlString = components[0]
                .trimmingCharacters(in: .whitespaces)
                .trimmingCharacters(in: CharacterSet(charactersIn: "<>"))

            let rel = components[1]
                .trimmingCharacters(in: .whitespaces)
                .replacingOccurrences(of: "rel=", with: "")
                .trimmingCharacters(in: CharacterSet(charactersIn: "\""))

            if let url = URL(string: urlString),
               let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let pageString = components.queryItems?.first(where: { $0.name == "page" })?.value,
               let page = Int(pageString) {

                switch rel {
                case "next":
                    nextPage = page
                case "last":
                    lastPage = page
                case "first":
                    firstPage = page
                case "prev":
                    prevPage = page
                default:
                    break
                }
            }
        }

        return PaginationInfo(
            nextPage: nextPage,
            lastPage: lastPage,
            firstPage: firstPage,
            prevPage: prevPage
        )
    }
}

// MARK: - Repository Content Model

struct RepositoryContent: Codable, Identifiable {
    let name: String
    let path: String
    let sha: String
    let size: Int
    let type: ContentType
    let downloadUrl: URL?
    let gitUrl: URL?
    let htmlUrl: URL?

    var id: String { sha }

    enum ContentType: String, Codable {
        case file
        case dir
        case symlink
        case submodule
    }
}

// MARK: - Branch Model

struct Branch: Codable, Identifiable {
    let name: String
    let commit: BranchCommit
    let protected: Bool

    var id: String { name }

    struct BranchCommit: Codable {
        let sha: String
        let url: URL
    }
}

// MARK: - Sort Options

enum RepositorySort: String {
    case created
    case updated
    case pushed
    case fullName = "full_name"
}

enum SortDirection: String {
    case asc
    case desc
}

// MARK: - API Errors

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case rateLimitExceeded
    case githubError(message: String)
    case noToken
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from GitHub API"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .rateLimitExceeded:
            return "GitHub API rate limit exceeded. Please try again later."
        case .githubError(let message):
            return "GitHub API error: \(message)"
        case .noToken:
            return "No authentication token available"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}

struct GitHubError: Codable {
    let message: String
    let documentationUrl: String?
}
