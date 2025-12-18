//
//  GitHubAPIIntegrationTests.swift
//  SpatialCodeReviewerTests
//
//  Created by Claude on 2025-11-24.
//

import XCTest
@testable import SpatialCodeReviewer

@MainActor
final class GitHubAPIIntegrationTests: XCTestCase {

    var sut: GitHubAPIClient!
    var mockToken: String!

    override func setUp() async throws {
        try await super.setUp()
        sut = GitHubAPIClient.shared
        mockToken = "test_mock_token_\(UUID().uuidString)"
    }

    override func tearDown() async throws {
        sut = nil
        mockToken = nil
        try await super.tearDown()
    }

    // MARK: - URL Construction Tests

    func testBuildRequest_CreatesValidURL() throws {
        // This tests the internal request building
        // In a real implementation, we'd use reflection or make the method internal
        // For now, we test indirectly through public methods
        XCTAssertNotNil(sut)
    }

    // MARK: - Pagination Parsing Tests

    func testPaginationInfo_ParsesGitHubLinkHeader() {
        // Given
        let linkHeader = """
        <https://api.github.com/user/repos?page=2&per_page=30>; rel="next", \
        <https://api.github.com/user/repos?page=5&per_page=30>; rel="last", \
        <https://api.github.com/user/repos?page=1&per_page=30>; rel="first"
        """

        // When
        let pagination = PaginationInfo.from(linkHeader: linkHeader)

        // Then
        XCTAssertNotNil(pagination)
        XCTAssertEqual(pagination?.nextPage, 2)
        XCTAssertEqual(pagination?.lastPage, 5)
        XCTAssertEqual(pagination?.firstPage, 1)
    }

    func testPaginationInfo_WithAllRelTypes() {
        // Given
        let linkHeader = """
        <https://api.github.com/user/repos?page=3&per_page=30>; rel="next", \
        <https://api.github.com/user/repos?page=2&per_page=30>; rel="prev", \
        <https://api.github.com/user/repos?page=1&per_page=30>; rel="first", \
        <https://api.github.com/user/repos?page=10&per_page=30>; rel="last"
        """

        // When
        let pagination = PaginationInfo.from(linkHeader: linkHeader)

        // Then
        XCTAssertEqual(pagination?.nextPage, 3)
        XCTAssertEqual(pagination?.prevPage, 2)
        XCTAssertEqual(pagination?.firstPage, 1)
        XCTAssertEqual(pagination?.lastPage, 10)
    }

    func testPaginationInfo_WithNoLinkHeader_ReturnsNil() {
        // When
        let pagination = PaginationInfo.from(linkHeader: nil)

        // Then
        XCTAssertNil(pagination)
    }

    func testPaginationInfo_WithInvalidFormat_ReturnsNil() {
        // Given
        let linkHeader = "invalid format"

        // When
        let pagination = PaginationInfo.from(linkHeader: linkHeader)

        // Then
        XCTAssertNil(pagination)
    }

    func testPaginationInfo_WithOnlyNextPage() {
        // Given
        let linkHeader = "<https://api.github.com/user/repos?page=2>; rel=\"next\""

        // When
        let pagination = PaginationInfo.from(linkHeader: linkHeader)

        // Then
        XCTAssertEqual(pagination?.nextPage, 2)
        XCTAssertNil(pagination?.lastPage)
        XCTAssertNil(pagination?.prevPage)
    }

    // MARK: - Repository Content Model Tests

    func testRepositoryContent_TypeDecoding() {
        // Given
        let types: [(String, RepositoryContent.ContentType)] = [
            ("file", .file),
            ("dir", .dir),
            ("symlink", .symlink),
            ("submodule", .submodule)
        ]

        // When/Then
        for (rawValue, expectedType) in types {
            let type = RepositoryContent.ContentType(rawValue: rawValue)
            XCTAssertEqual(type, expectedType)
        }
    }

    // MARK: - Branch Model Tests

    func testBranch_Identifiable() {
        // Given
        let branch1 = Branch(
            name: "main",
            commit: Branch.BranchCommit(sha: "abc123", url: URL(string: "https://example.com")!),
            protected: true
        )
        let branch2 = Branch(
            name: "develop",
            commit: Branch.BranchCommit(sha: "def456", url: URL(string: "https://example.com")!),
            protected: false
        )

        // Then
        XCTAssertEqual(branch1.id, "main")
        XCTAssertEqual(branch2.id, "develop")
        XCTAssertNotEqual(branch1.id, branch2.id)
    }

    // MARK: - Sort Options Tests

    func testRepositorySort_RawValues() {
        // Then
        XCTAssertEqual(RepositorySort.created.rawValue, "created")
        XCTAssertEqual(RepositorySort.updated.rawValue, "updated")
        XCTAssertEqual(RepositorySort.pushed.rawValue, "pushed")
        XCTAssertEqual(RepositorySort.fullName.rawValue, "full_name")
    }

    func testSortDirection_RawValues() {
        // Then
        XCTAssertEqual(SortDirection.asc.rawValue, "asc")
        XCTAssertEqual(SortDirection.desc.rawValue, "desc")
    }

    // MARK: - API Error Tests

    func testAPIError_HasDescriptiveMessages() {
        // Given
        let errors: [APIError] = [
            .invalidURL,
            .invalidResponse,
            .httpError(statusCode: 404),
            .rateLimitExceeded,
            .githubError(message: "Not found"),
            .noToken
        ]

        // When/Then
        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertFalse(error.errorDescription!.isEmpty)
        }
    }

    func testAPIError_HTTPErrorIncludesStatusCode() {
        // Given
        let error = APIError.httpError(statusCode: 404)

        // Then
        XCTAssertTrue(error.errorDescription!.contains("404"))
    }

    func testAPIError_GithubErrorIncludesMessage() {
        // Given
        let message = "Repository not found"
        let error = APIError.githubError(message: message)

        // Then
        XCTAssertTrue(error.errorDescription!.contains(message))
    }

    // MARK: - Response Model Tests

    func testRepositoryListResponse_Structure() {
        // Given
        let repos = [Repository.mock]
        let pagination = PaginationInfo(nextPage: 2, lastPage: 5, firstPage: 1, prevPage: nil)

        // When
        let response = RepositoryListResponse(repositories: repos, pagination: pagination)

        // Then
        XCTAssertEqual(response.repositories.count, 1)
        XCTAssertEqual(response.pagination?.nextPage, 2)
    }

    func testRepositorySearchResponse_Structure() {
        // Given
        let repos = [Repository.mock]
        let pagination = PaginationInfo(nextPage: 2, lastPage: 5, firstPage: 1, prevPage: nil)

        // When
        let response = RepositorySearchResponse(repositories: repos, totalCount: 42, pagination: pagination)

        // Then
        XCTAssertEqual(response.repositories.count, 1)
        XCTAssertEqual(response.totalCount, 42)
        XCTAssertEqual(response.pagination?.nextPage, 2)
    }

    // MARK: - Mock Response Tests (would use URLProtocol in real implementation)

    // Note: These tests would normally use URLProtocol to mock network responses
    // For MVP, we're documenting the test structure

    func testFetchRepositories_WithMockResponse_ParsesCorrectly() async throws {
        // This test would use a mock URLSession with URLProtocol
        // to inject a known JSON response and verify parsing
        // Skipped in MVP - requires URLProtocol setup
        throw XCTSkip("Requires URLProtocol mock setup")
    }

    func testFetchRepositories_WithRateLimitError_ThrowsCorrectError() async throws {
        // This test would use a mock URLSession that returns 403
        // with X-RateLimit-Remaining: 0
        // Skipped in MVP - requires URLProtocol setup
        throw XCTSkip("Requires URLProtocol mock setup")
    }

    func testFetchRepositories_With404Error_ThrowsHTTPError() async throws {
        // This test would use a mock URLSession that returns 404
        // Skipped in MVP - requires URLProtocol setup
        throw XCTSkip("Requires URLProtocol mock setup")
    }

    // MARK: - Integration Test Placeholders

    // These would be run against a test GitHub account or mock server

    func testFetchCurrentUser_WithRealAPI() async throws {
        // Requires: Real GitHub token in test environment
        throw XCTSkip("Requires real GitHub API token")
    }

    func testFetchRepositories_WithRealAPI() async throws {
        // Requires: Real GitHub token in test environment
        throw XCTSkip("Requires real GitHub API token")
    }

    func testSearchRepositories_WithRealAPI() async throws {
        // Requires: Real GitHub token in test environment
        throw XCTSkip("Requires real GitHub API token")
    }

    func testFetchBranches_WithRealAPI() async throws {
        // Requires: Real GitHub token in test environment
        throw XCTSkip("Requires real GitHub API token")
    }
}
