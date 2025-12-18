# API Integration Specifications Document

## Document Information
- **Version**: 1.0
- **Last Updated**: 2025-11-24
- **Status**: Draft
- **Owner**: Engineering Team

## 1. Overview

This document specifies the integration architecture for external services including version control platforms (GitHub, GitLab, Bitbucket, Azure DevOps), issue tracking systems (Jira, Linear), and communication platforms (Slack, Teams, Discord).

## 2. Integration Architecture

### 2.1 Service Abstraction Layer

```
┌────────────────────────────────────────────────────────┐
│              Application Layer                          │
└────────────────────────────────────────────────────────┘
                         │
┌────────────────────────────────────────────────────────┐
│              Service Protocols                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │ Repository   │  │    Issue     │  │  Notification│ │
│  │   Service    │  │   Service    │  │   Service    │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
└────────────────────────────────────────────────────────┘
                         │
┌────────────────────────────────────────────────────────┐
│          Concrete Implementations                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │   GitHub     │  │    GitLab    │  │  Bitbucket   │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │     Jira     │  │    Linear    │  │    Slack     │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
└────────────────────────────────────────────────────────┘
                         │
┌────────────────────────────────────────────────────────┐
│              HTTP Client Layer                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │ URLSession   │  │   OAuth      │  │  Rate Limit  │ │
│  │              │  │   Manager    │  │   Handler    │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
└────────────────────────────────────────────────────────┘
```

## 3. Authentication System

### 3.1 OAuth 2.0 Manager

```swift
class OAuthManager {
    private let authService: AuthService
    private var providers: [AuthProvider: OAuthConfig] = [:]

    enum AuthProvider: String {
        case github = "github"
        case gitlab = "gitlab"
        case bitbucket = "bitbucket"
        case azureDevOps = "azure_devops"
        case jira = "jira"
    }

    struct OAuthConfig {
        let clientID: String
        let clientSecret: String
        let redirectURI: URL
        let scopes: [String]
        let authorizationEndpoint: URL
        let tokenEndpoint: URL
    }

    init() {
        self.authService = ServiceContainer.shared.authService
        setupProviders()
    }

    private func setupProviders() {
        // GitHub
        providers[.github] = OAuthConfig(
            clientID: loadFromConfig("GITHUB_CLIENT_ID"),
            clientSecret: loadFromConfig("GITHUB_CLIENT_SECRET"),
            redirectURI: URL(string: "spatialcodereviewer://oauth/github")!,
            scopes: ["repo", "read:user", "read:org"],
            authorizationEndpoint: URL(string: "https://github.com/login/oauth/authorize")!,
            tokenEndpoint: URL(string: "https://github.com/login/oauth/access_token")!
        )

        // GitLab
        providers[.gitlab] = OAuthConfig(
            clientID: loadFromConfig("GITLAB_CLIENT_ID"),
            clientSecret: loadFromConfig("GITLAB_CLIENT_SECRET"),
            redirectURI: URL(string: "spatialcodereviewer://oauth/gitlab")!,
            scopes: ["api", "read_user", "read_repository"],
            authorizationEndpoint: URL(string: "https://gitlab.com/oauth/authorize")!,
            tokenEndpoint: URL(string: "https://gitlab.com/oauth/token")!
        )

        // Bitbucket
        providers[.bitbucket] = OAuthConfig(
            clientID: loadFromConfig("BITBUCKET_CLIENT_ID"),
            clientSecret: loadFromConfig("BITBUCKET_CLIENT_SECRET"),
            redirectURI: URL(string: "spatialcodereviewer://oauth/bitbucket")!,
            scopes: ["repository", "pullrequest"],
            authorizationEndpoint: URL(string: "https://bitbucket.org/site/oauth2/authorize")!,
            tokenEndpoint: URL(string: "https://bitbucket.org/site/oauth2/access_token")!
        )

        // Azure DevOps
        providers[.azureDevOps] = OAuthConfig(
            clientID: loadFromConfig("AZURE_CLIENT_ID"),
            clientSecret: loadFromConfig("AZURE_CLIENT_SECRET"),
            redirectURI: URL(string: "spatialcodereviewer://oauth/azure")!,
            scopes: ["vso.code", "vso.work"],
            authorizationEndpoint: URL(string: "https://app.vssps.visualstudio.com/oauth2/authorize")!,
            tokenEndpoint: URL(string: "https://app.vssps.visualstudio.com/oauth2/token")!
        )

        // Jira
        providers[.jira] = OAuthConfig(
            clientID: loadFromConfig("JIRA_CLIENT_ID"),
            clientSecret: loadFromConfig("JIRA_CLIENT_SECRET"),
            redirectURI: URL(string: "spatialcodereviewer://oauth/jira")!,
            scopes: ["read:jira-work", "write:jira-work"],
            authorizationEndpoint: URL(string: "https://auth.atlassian.com/authorize")!,
            tokenEndpoint: URL(string: "https://auth.atlassian.com/oauth/token")!
        )
    }

    func startAuthorization(for provider: AuthProvider) async throws -> URL {
        guard let config = providers[provider] else {
            throw AuthError.unsupportedProvider
        }

        // Generate PKCE challenge
        let codeVerifier = generateCodeVerifier()
        let codeChallenge = generateCodeChallenge(from: codeVerifier)

        // Store verifier for later
        try storeCodeVerifier(codeVerifier, for: provider)

        // Build authorization URL
        var components = URLComponents(url: config.authorizationEndpoint, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: config.clientID),
            URLQueryItem(name: "redirect_uri", value: config.redirectURI.absoluteString),
            URLQueryItem(name: "scope", value: config.scopes.joined(separator: " ")),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "state", value: UUID().uuidString)
        ]

        return components.url!
    }

    func handleCallback(url: URL) async throws -> Token {
        // Parse provider from URL
        guard let provider = parseProvider(from: url) else {
            throw AuthError.invalidCallback
        }

        guard let config = providers[provider] else {
            throw AuthError.unsupportedProvider
        }

        // Extract authorization code
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        guard let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            throw AuthError.missingAuthorizationCode
        }

        // Retrieve code verifier
        let codeVerifier = try retrieveCodeVerifier(for: provider)

        // Exchange code for token
        let token = try await exchangeCodeForToken(
            code: code,
            codeVerifier: codeVerifier,
            config: config
        )

        // Store token securely
        try authService.storeToken(token, for: provider.rawValue)

        return token
    }

    private func exchangeCodeForToken(
        code: String,
        codeVerifier: String,
        config: OAuthConfig
    ) async throws -> Token {
        var request = URLRequest(url: config.tokenEndpoint)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": config.redirectURI.absoluteString,
            "client_id": config.clientID,
            "client_secret": config.clientSecret,
            "code_verifier": codeVerifier
        ]

        request.httpBody = body.percentEncoded()

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw AuthError.tokenExchangeFailed
        }

        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)

        return Token(
            accessToken: tokenResponse.access_token,
            refreshToken: tokenResponse.refresh_token,
            expiresAt: Date().addingTimeInterval(TimeInterval(tokenResponse.expires_in)),
            tokenType: tokenResponse.token_type,
            scope: tokenResponse.scope
        )
    }

    func refreshToken(for provider: AuthProvider) async throws -> Token {
        guard let config = providers[provider] else {
            throw AuthError.unsupportedProvider
        }

        guard let currentToken = try? authService.retrieveToken(for: provider.rawValue) else {
            throw AuthError.noTokenFound
        }

        guard let refreshToken = currentToken.refreshToken else {
            throw AuthError.noRefreshToken
        }

        var request = URLRequest(url: config.tokenEndpoint)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken,
            "client_id": config.clientID,
            "client_secret": config.clientSecret
        ]

        request.httpBody = body.percentEncoded()

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw AuthError.tokenRefreshFailed
        }

        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)

        let newToken = Token(
            accessToken: tokenResponse.access_token,
            refreshToken: tokenResponse.refresh_token ?? refreshToken,
            expiresAt: Date().addingTimeInterval(TimeInterval(tokenResponse.expires_in)),
            tokenType: tokenResponse.token_type,
            scope: tokenResponse.scope
        )

        try authService.storeToken(newToken, for: provider.rawValue)

        return newToken
    }

    // MARK: - Helper Methods

    private func generateCodeVerifier() -> String {
        var buffer = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)
        return Data(buffer).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    private func generateCodeChallenge(from verifier: String) -> String {
        let data = Data(verifier.utf8)
        let hashed = SHA256.hash(data: data)
        return Data(hashed).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    private func storeCodeVerifier(_ verifier: String, for provider: AuthProvider) throws {
        UserDefaults.standard.set(verifier, forKey: "code_verifier_\(provider.rawValue)")
    }

    private func retrieveCodeVerifier(for provider: AuthProvider) throws -> String {
        guard let verifier = UserDefaults.standard.string(forKey: "code_verifier_\(provider.rawValue)") else {
            throw AuthError.noCodeVerifier
        }
        return verifier
    }

    private func parseProvider(from url: URL) -> AuthProvider? {
        // Extract provider from redirect URI
        if url.absoluteString.contains("github") {
            return .github
        } else if url.absoluteString.contains("gitlab") {
            return .gitlab
        } else if url.absoluteString.contains("bitbucket") {
            return .bitbucket
        } else if url.absoluteString.contains("azure") {
            return .azureDevOps
        } else if url.absoluteString.contains("jira") {
            return .jira
        }
        return nil
    }

    private func loadFromConfig(_ key: String) -> String {
        // Load from secure configuration
        // In production, these would come from secure configuration
        return Bundle.main.object(forInfoDictionaryKey: key) as? String ?? ""
    }
}

struct TokenResponse: Codable {
    let access_token: String
    let refresh_token: String?
    let expires_in: Int
    let token_type: String
    let scope: String?
}

struct Token: Codable {
    let accessToken: String
    let refreshToken: String?
    let expiresAt: Date
    let tokenType: String
    let scope: String?

    var isExpired: Bool {
        return Date() >= expiresAt
    }
}

enum AuthError: LocalizedError {
    case unsupportedProvider
    case invalidCallback
    case missingAuthorizationCode
    case tokenExchangeFailed
    case tokenRefreshFailed
    case noTokenFound
    case noRefreshToken
    case noCodeVerifier

    var errorDescription: String? {
        switch self {
        case .unsupportedProvider:
            return "The authentication provider is not supported"
        case .invalidCallback:
            return "Invalid OAuth callback URL"
        case .missingAuthorizationCode:
            return "Authorization code not found in callback"
        case .tokenExchangeFailed:
            return "Failed to exchange authorization code for token"
        case .tokenRefreshFailed:
            return "Failed to refresh access token"
        case .noTokenFound:
            return "No stored token found"
        case .noRefreshToken:
            return "No refresh token available"
        case .noCodeVerifier:
            return "Code verifier not found"
        }
    }
}
```

## 4. GitHub Integration

### 4.1 GitHub API Service

```swift
class GitHubAPIService: RepositoryService, IssueService {
    private let baseURL = URL(string: "https://api.github.com")!
    private let authManager: OAuthManager
    private let rateLimiter: RateLimiter

    init(authManager: OAuthManager) {
        self.authManager = authManager
        self.rateLimiter = RateLimiter(maxRequests: 5000, perHour: 1)
    }

    // MARK: - Repository Operations

    func fetchRepository(owner: String, name: String) async throws -> RemoteRepository {
        let endpoint = "/repos/\(owner)/\(name)"
        let url = baseURL.appendingPathComponent(endpoint)

        let data: GitHubRepository = try await makeAuthenticatedRequest(url: url)

        return RemoteRepository(
            id: String(data.id),
            name: data.name,
            fullName: data.full_name,
            url: URL(string: data.html_url)!,
            cloneURL: URL(string: data.clone_url)!,
            defaultBranch: data.default_branch,
            description: data.description,
            language: data.language,
            starCount: data.stargazers_count,
            isPrivate: data.private
        )
    }

    func fetchBranches(owner: String, repo: String) async throws -> [RemoteBranch] {
        let endpoint = "/repos/\(owner)/\(repo)/branches"
        let url = baseURL.appendingPathComponent(endpoint)

        let data: [GitHubBranch] = try await makeAuthenticatedRequest(url: url)

        return data.map { branch in
            RemoteBranch(
                name: branch.name,
                commitSHA: branch.commit.sha,
                protected: branch.protected
            )
        }
    }

    func fetchPullRequests(
        owner: String,
        repo: String,
        state: String = "open"
    ) async throws -> [RemotePullRequest] {
        let endpoint = "/repos/\(owner)/\(repo)/pulls"
        var components = URLComponents(url: baseURL.appendingPathComponent(endpoint), resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "per_page", value: "100")
        ]

        let data: [GitHubPullRequest] = try await makeAuthenticatedRequest(url: components.url!)

        return data.map { pr in
            RemotePullRequest(
                id: String(pr.number),
                number: pr.number,
                title: pr.title,
                description: pr.body,
                state: pr.state,
                author: pr.user.login,
                authorAvatarURL: URL(string: pr.user.avatar_url),
                sourceBranch: pr.head.ref,
                targetBranch: pr.base.ref,
                createdAt: ISO8601DateFormatter().date(from: pr.created_at)!,
                updatedAt: ISO8601DateFormatter().date(from: pr.updated_at)!,
                mergedAt: pr.merged_at.flatMap { ISO8601DateFormatter().date(from: $0) },
                isDraft: pr.draft,
                url: URL(string: pr.html_url)!
            )
        }
    }

    func fetchPullRequestFiles(
        owner: String,
        repo: String,
        number: Int
    ) async throws -> [RemoteFileChange] {
        let endpoint = "/repos/\(owner)/\(repo)/pulls/\(number)/files"
        let url = baseURL.appendingPathComponent(endpoint)

        let data: [GitHubPullRequestFile] = try await makeAuthenticatedRequest(url: url)

        return data.map { file in
            RemoteFileChange(
                filename: file.filename,
                status: mapStatus(file.status),
                additions: file.additions,
                deletions: file.deletions,
                changes: file.changes,
                patch: file.patch,
                blobURL: URL(string: file.blob_url)!
            )
        }
    }

    func fetchCommits(
        owner: String,
        repo: String,
        branch: String? = nil,
        since: Date? = nil,
        until: Date? = nil
    ) async throws -> [RemoteCommit] {
        let endpoint = "/repos/\(owner)/\(repo)/commits"
        var components = URLComponents(url: baseURL.appendingPathComponent(endpoint), resolvingAgainstBaseURL: false)!

        var queryItems: [URLQueryItem] = []

        if let branch = branch {
            queryItems.append(URLQueryItem(name: "sha", value: branch))
        }

        if let since = since {
            let formatter = ISO8601DateFormatter()
            queryItems.append(URLQueryItem(name: "since", value: formatter.string(from: since)))
        }

        if let until = until {
            let formatter = ISO8601DateFormatter()
            queryItems.append(URLQueryItem(name: "until", value: formatter.string(from: until)))
        }

        components.queryItems = queryItems.isEmpty ? nil : queryItems

        let data: [GitHubCommit] = try await makeAuthenticatedRequest(url: components.url!)

        return data.map { commit in
            RemoteCommit(
                sha: commit.sha,
                message: commit.commit.message,
                author: commit.commit.author.name,
                authorEmail: commit.commit.author.email,
                date: ISO8601DateFormatter().date(from: commit.commit.author.date)!,
                url: URL(string: commit.html_url)!
            )
        }
    }

    // MARK: - Issue Operations

    func fetchIssues(
        owner: String,
        repo: String,
        state: String = "open"
    ) async throws -> [RemoteIssue] {
        let endpoint = "/repos/\(owner)/\(repo)/issues"
        var components = URLComponents(url: baseURL.appendingPathComponent(endpoint), resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "per_page", value: "100")
        ]

        let data: [GitHubIssue] = try await makeAuthenticatedRequest(url: components.url!)

        // Filter out pull requests (GitHub API returns both)
        return data.filter { $0.pull_request == nil }.map { issue in
            RemoteIssue(
                id: String(issue.number),
                number: issue.number,
                title: issue.title,
                body: issue.body,
                state: issue.state,
                author: issue.user.login,
                authorAvatarURL: URL(string: issue.user.avatar_url),
                labels: issue.labels.map { $0.name },
                assignees: issue.assignees?.map { $0.login } ?? [],
                createdAt: ISO8601DateFormatter().date(from: issue.created_at)!,
                updatedAt: ISO8601DateFormatter().date(from: issue.updated_at)!,
                closedAt: issue.closed_at.flatMap { ISO8601DateFormatter().date(from: $0) },
                url: URL(string: issue.html_url)!
            )
        }
    }

    func fetchComments(
        owner: String,
        repo: String,
        issueNumber: Int
    ) async throws -> [RemoteComment] {
        let endpoint = "/repos/\(owner)/\(repo)/issues/\(issueNumber)/comments"
        let url = baseURL.appendingPathComponent(endpoint)

        let data: [GitHubComment] = try await makeAuthenticatedRequest(url: url)

        return data.map { comment in
            RemoteComment(
                id: String(comment.id),
                body: comment.body,
                author: comment.user.login,
                authorAvatarURL: URL(string: comment.user.avatar_url),
                createdAt: ISO8601DateFormatter().date(from: comment.created_at)!,
                updatedAt: ISO8601DateFormatter().date(from: comment.updated_at)!
            )
        }
    }

    func createComment(
        owner: String,
        repo: String,
        issueNumber: Int,
        body: String
    ) async throws -> RemoteComment {
        let endpoint = "/repos/\(owner)/\(repo)/issues/\(issueNumber)/comments"
        let url = baseURL.appendingPathComponent(endpoint)

        let requestBody = ["body": body]

        let data: GitHubComment = try await makeAuthenticatedRequest(
            url: url,
            method: "POST",
            body: requestBody
        )

        return RemoteComment(
            id: String(data.id),
            body: data.body,
            author: data.user.login,
            authorAvatarURL: URL(string: data.user.avatar_url),
            createdAt: ISO8601DateFormatter().date(from: data.created_at)!,
            updatedAt: ISO8601DateFormatter().date(from: data.updated_at)!
        )
    }

    // MARK: - Review Operations

    func submitReview(
        owner: String,
        repo: String,
        pullRequestNumber: Int,
        event: ReviewEvent,
        body: String?,
        comments: [ReviewComment]
    ) async throws {
        let endpoint = "/repos/\(owner)/\(repo)/pulls/\(pullRequestNumber)/reviews"
        let url = baseURL.appendingPathComponent(endpoint)

        let requestBody: [String: Any] = [
            "event": event.rawValue,
            "body": body ?? "",
            "comments": comments.map { [
                "path": $0.path,
                "position": $0.position,
                "body": $0.body
            ]}
        ]

        let _: GitHubReview = try await makeAuthenticatedRequest(
            url: url,
            method: "POST",
            body: requestBody
        )
    }

    // MARK: - HTTP Client

    private func makeAuthenticatedRequest<T: Decodable>(
        url: URL,
        method: String = "GET",
        body: [String: Any]? = nil
    ) async throws -> T {
        // Rate limiting
        try await rateLimiter.waitIfNeeded()

        // Get token
        let token = try await authManager.refreshToken(for: .github)

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")

        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        // Update rate limiter
        if let remaining = httpResponse.value(forHTTPHeaderField: "X-RateLimit-Remaining"),
           let reset = httpResponse.value(forHTTPHeaderField: "X-RateLimit-Reset") {
            rateLimiter.update(
                remaining: Int(remaining) ?? 0,
                resetTime: Date(timeIntervalSince1970: TimeInterval(reset) ?? 0)
            )
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 401 {
                throw APIError.unauthorized
            } else if httpResponse.statusCode == 403 {
                throw APIError.rateLimitExceeded
            } else if httpResponse.statusCode == 404 {
                throw APIError.notFound
            }
            throw APIError.httpError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return try decoder.decode(T.self, from: data)
    }

    private func mapStatus(_ status: String) -> FileChangeStatus {
        switch status {
        case "added": return .added
        case "modified": return .modified
        case "removed": return .deleted
        case "renamed": return .renamed
        default: return .modified
        }
    }
}

// MARK: - GitHub Data Models

struct GitHubRepository: Codable {
    let id: Int
    let name: String
    let full_name: String
    let html_url: String
    let clone_url: String
    let default_branch: String
    let description: String?
    let language: String?
    let stargazers_count: Int
    let `private`: Bool
}

struct GitHubBranch: Codable {
    let name: String
    let commit: GitHubCommitRef
    let protected: Bool
}

struct GitHubCommitRef: Codable {
    let sha: String
}

struct GitHubPullRequest: Codable {
    let number: Int
    let title: String
    let body: String?
    let state: String
    let user: GitHubUser
    let head: GitHubRef
    let base: GitHubRef
    let created_at: String
    let updated_at: String
    let merged_at: String?
    let draft: Bool
    let html_url: String
}

struct GitHubUser: Codable {
    let login: String
    let avatar_url: String
}

struct GitHubRef: Codable {
    let ref: String
}

struct GitHubPullRequestFile: Codable {
    let filename: String
    let status: String
    let additions: Int
    let deletions: Int
    let changes: Int
    let patch: String?
    let blob_url: String
}

struct GitHubCommit: Codable {
    let sha: String
    let commit: GitHubCommitDetails
    let html_url: String
}

struct GitHubCommitDetails: Codable {
    let message: String
    let author: GitHubCommitAuthor
}

struct GitHubCommitAuthor: Codable {
    let name: String
    let email: String
    let date: String
}

struct GitHubIssue: Codable {
    let number: Int
    let title: String
    let body: String?
    let state: String
    let user: GitHubUser
    let labels: [GitHubLabel]
    let assignees: [GitHubUser]?
    let created_at: String
    let updated_at: String
    let closed_at: String?
    let html_url: String
    let pull_request: GitHubPullRequestRef?
}

struct GitHubLabel: Codable {
    let name: String
    let color: String
}

struct GitHubPullRequestRef: Codable {
    let url: String
}

struct GitHubComment: Codable {
    let id: Int
    let body: String
    let user: GitHubUser
    let created_at: String
    let updated_at: String
}

struct GitHubReview: Codable {
    let id: Int
    let body: String?
    let state: String
}
```

## 5. Rate Limiting

### 5.1 Rate Limiter Implementation

```swift
actor RateLimiter {
    private let maxRequests: Int
    private let perHour: Int
    private var remaining: Int
    private var resetTime: Date

    init(maxRequests: Int, perHour: Int) {
        self.maxRequests = maxRequests
        self.perHour = perHour
        self.remaining = maxRequests
        self.resetTime = Date().addingTimeInterval(3600)
    }

    func waitIfNeeded() async throws {
        if remaining <= 0 {
            let waitTime = resetTime.timeIntervalSinceNow

            if waitTime > 0 {
                print("Rate limit reached. Waiting \(waitTime)s")
                try await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
            }

            // Reset
            remaining = maxRequests
            resetTime = Date().addingTimeInterval(3600)
        }

        remaining -= 1
    }

    func update(remaining: Int, resetTime: Date) {
        self.remaining = remaining
        self.resetTime = resetTime
    }
}
```

## 6. Abstract Service Protocols

### 6.1 Repository Service Protocol

```swift
protocol RepositoryService {
    func fetchRepository(owner: String, name: String) async throws -> RemoteRepository
    func fetchBranches(owner: String, repo: String) async throws -> [RemoteBranch]
    func fetchPullRequests(owner: String, repo: String, state: String) async throws -> [RemotePullRequest]
    func fetchPullRequestFiles(owner: String, repo: String, number: Int) async throws -> [RemoteFileChange]
    func fetchCommits(owner: String, repo: String, branch: String?, since: Date?, until: Date?) async throws -> [RemoteCommit]
}

protocol IssueService {
    func fetchIssues(owner: String, repo: String, state: String) async throws -> [RemoteIssue]
    func fetchComments(owner: String, repo: String, issueNumber: Int) async throws -> [RemoteComment]
    func createComment(owner: String, repo: String, issueNumber: Int, body: String) async throws -> RemoteComment
}

enum ReviewEvent: String {
    case approve = "APPROVE"
    case requestChanges = "REQUEST_CHANGES"
    case comment = "COMMENT"
}

struct ReviewComment {
    let path: String
    let position: Int
    let body: String
}
```

## 7. Common Data Models

### 7.1 Remote Models

```swift
struct RemoteRepository {
    let id: String
    let name: String
    let fullName: String
    let url: URL
    let cloneURL: URL
    let defaultBranch: String
    let description: String?
    let language: String?
    let starCount: Int
    let isPrivate: Bool
}

struct RemoteBranch {
    let name: String
    let commitSHA: String
    let protected: Bool
}

struct RemotePullRequest {
    let id: String
    let number: Int
    let title: String
    let description: String?
    let state: String
    let author: String
    let authorAvatarURL: URL?
    let sourceBranch: String
    let targetBranch: String
    let createdAt: Date
    let updatedAt: Date
    let mergedAt: Date?
    let isDraft: Bool
    let url: URL
}

struct RemoteFileChange {
    let filename: String
    let status: FileChangeStatus
    let additions: Int
    let deletions: Int
    let changes: Int
    let patch: String?
    let blobURL: URL
}

enum FileChangeStatus {
    case added
    case modified
    case deleted
    case renamed
}

struct RemoteCommit {
    let sha: String
    let message: String
    let author: String
    let authorEmail: String
    let date: Date
    let url: URL
}

struct RemoteIssue {
    let id: String
    let number: Int
    let title: String
    let body: String?
    let state: String
    let author: String
    let authorAvatarURL: URL?
    let labels: [String]
    let assignees: [String]
    let createdAt: Date
    let updatedAt: Date
    let closedAt: Date?
    let url: URL
}

struct RemoteComment {
    let id: String
    let body: String
    let author: String
    let authorAvatarURL: URL?
    let createdAt: Date
    let updatedAt: Date
}
```

## 8. Error Handling

### 8.1 API Errors

```swift
enum APIError: LocalizedError {
    case invalidResponse
    case unauthorized
    case rateLimitExceeded
    case notFound
    case httpError(Int)
    case networkError(Error)
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Authentication required or token expired"
        case .rateLimitExceeded:
            return "API rate limit exceeded"
        case .notFound:
            return "Resource not found"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}
```

## 9. Testing

### 9.1 Mock Services

```swift
class MockGitHubService: RepositoryService, IssueService {
    var shouldFail = false
    var mockPullRequests: [RemotePullRequest] = []
    var mockIssues: [RemoteIssue] = []

    func fetchRepository(owner: String, name: String) async throws -> RemoteRepository {
        if shouldFail {
            throw APIError.notFound
        }

        return RemoteRepository(
            id: "1",
            name: name,
            fullName: "\(owner)/\(name)",
            url: URL(string: "https://github.com/\(owner)/\(name)")!,
            cloneURL: URL(string: "https://github.com/\(owner)/\(name).git")!,
            defaultBranch: "main",
            description: "Test repository",
            language: "Swift",
            starCount: 100,
            isPrivate: false
        )
    }

    func fetchPullRequests(owner: String, repo: String, state: String) async throws -> [RemotePullRequest] {
        if shouldFail {
            throw APIError.rateLimitExceeded
        }
        return mockPullRequests
    }

    // ... implement other methods
}
```

## 10. References

- [System Architecture Document](./01-system-architecture.md)
- [Security Architecture Document](./10-security-architecture.md)
- GitHub REST API Documentation
- GitLab API Documentation
- OAuth 2.0 RFC 6749

## 11. Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-11-24 | Engineering Team | Initial draft |
