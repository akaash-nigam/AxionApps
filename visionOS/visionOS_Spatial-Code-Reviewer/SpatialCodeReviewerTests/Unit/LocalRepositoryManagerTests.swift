//
//  LocalRepositoryManagerTests.swift
//  SpatialCodeReviewerTests
//
//  Created by Claude on 2025-11-24.
//

import XCTest
@testable import SpatialCodeReviewer

@MainActor
final class LocalRepositoryManagerTests: XCTestCase {

    var sut: LocalRepositoryManager!
    let testOwner = "test_owner"
    let testRepo = "test_repo"

    override func setUp() async throws {
        try await super.setUp()
        sut = LocalRepositoryManager.shared

        // Clean up any existing test data
        try? sut.deleteRepository(owner: testOwner, name: testRepo)
    }

    override func tearDown() async throws {
        // Clean up test data
        try? sut.deleteRepository(owner: testOwner, name: testRepo)

        sut = nil
        try await super.tearDown()
    }

    // MARK: - Repository Path Tests

    func testRepositoryPath_ReturnsCorrectPath() {
        // When
        let path = sut.repositoryPath(owner: testOwner, name: testRepo)

        // Then
        XCTAssertTrue(path.path.contains("Repositories"))
        XCTAssertTrue(path.path.contains(testOwner))
        XCTAssertTrue(path.path.contains(testRepo))
    }

    func testRepositoryPath_IsConsistent() {
        // When
        let path1 = sut.repositoryPath(owner: testOwner, name: testRepo)
        let path2 = sut.repositoryPath(owner: testOwner, name: testRepo)

        // Then
        XCTAssertEqual(path1, path2)
    }

    // MARK: - Repository Download Status Tests

    func testIsRepositoryDownloaded_BeforeDownload_ReturnsFalse() {
        // When
        let isDownloaded = sut.isRepositoryDownloaded(owner: testOwner, name: testRepo)

        // Then
        XCTAssertFalse(isDownloaded)
    }

    func testIsRepositoryDownloaded_AfterCreatingDirectory_ReturnsTrue() throws {
        // Given
        let repoPath = sut.repositoryPath(owner: testOwner, name: testRepo)
        try FileManager.default.createDirectory(at: repoPath, withIntermediateDirectories: true)

        // When
        let isDownloaded = sut.isRepositoryDownloaded(owner: testOwner, name: testRepo)

        // Then
        XCTAssertTrue(isDownloaded)
    }

    // MARK: - Repository Deletion Tests

    func testDeleteRepository_RemovesDirectory() throws {
        // Given
        let repoPath = sut.repositoryPath(owner: testOwner, name: testRepo)
        try FileManager.default.createDirectory(at: repoPath, withIntermediateDirectories: true)
        XCTAssertTrue(sut.isRepositoryDownloaded(owner: testOwner, name: testRepo))

        // When
        try sut.deleteRepository(owner: testOwner, name: testRepo)

        // Then
        XCTAssertFalse(sut.isRepositoryDownloaded(owner: testOwner, name: testRepo))
    }

    func testDeleteRepository_WhenNotExists_DoesNotThrow() {
        // When/Then
        XCTAssertNoThrow(try sut.deleteRepository(owner: "nonexistent", name: "repo"))
    }

    // MARK: - List Downloaded Repositories Tests

    func testListDownloadedRepositories_InitiallyEmpty() {
        // Given
        try? sut.deleteAllRepositories()

        // When
        let repos = sut.listDownloadedRepositories()

        // Then
        XCTAssertTrue(repos.isEmpty)
    }

    func testListDownloadedRepositories_AfterCreatingRepo_ReturnsRepo() throws {
        // Given
        let repoPath = sut.repositoryPath(owner: testOwner, name: testRepo)
        try FileManager.default.createDirectory(at: repoPath, withIntermediateDirectories: true)

        // When
        let repos = sut.listDownloadedRepositories()

        // Then
        XCTAssertTrue(repos.contains(where: { $0.owner == testOwner && $0.name == testRepo }))
    }

    func testListDownloadedRepositories_WithMultipleRepos() throws {
        // Given
        let repo1Path = sut.repositoryPath(owner: "owner1", name: "repo1")
        let repo2Path = sut.repositoryPath(owner: "owner2", name: "repo2")
        try FileManager.default.createDirectory(at: repo1Path, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: repo2Path, withIntermediateDirectories: true)

        // When
        let repos = sut.listDownloadedRepositories()

        // Then
        XCTAssertGreaterThanOrEqual(repos.count, 2)
        XCTAssertTrue(repos.contains(where: { $0.owner == "owner1" && $0.name == "repo1" }))
        XCTAssertTrue(repos.contains(where: { $0.owner == "owner2" && $0.name == "repo2" }))

        // Cleanup
        try? sut.deleteRepository(owner: "owner1", name: "repo1")
        try? sut.deleteRepository(owner: "owner2", name: "repo2")
    }

    // MARK: - Metadata Tests

    func testSaveAndLoadRepositoryMetadata() throws {
        // Given
        let repoPath = sut.repositoryPath(owner: testOwner, name: testRepo)
        try FileManager.default.createDirectory(at: repoPath, withIntermediateDirectories: true)

        let metadata = RepositoryMetadata(
            id: 123,
            name: testRepo,
            fullName: "\(testOwner)/\(testRepo)",
            owner: testOwner,
            branch: "main",
            downloadedAt: Date(),
            lastAccessedAt: Date()
        )

        let metadataPath = repoPath.appendingPathComponent(".metadata.json")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(metadata)
        try data.write(to: metadataPath)

        // When
        let loaded = try sut.loadRepositoryMetadata(owner: testOwner, name: testRepo)

        // Then
        XCTAssertEqual(loaded.id, metadata.id)
        XCTAssertEqual(loaded.name, metadata.name)
        XCTAssertEqual(loaded.owner, metadata.owner)
        XCTAssertEqual(loaded.branch, metadata.branch)
    }

    func testLoadRepositoryMetadata_WhenNotExists_ThrowsError() {
        // When/Then
        XCTAssertThrowsError(try sut.loadRepositoryMetadata(owner: "nonexistent", name: "repo"))
    }

    // MARK: - File Tree Tests

    func testBuildFileTree_WithSimpleStructure() throws {
        // Given
        let repoPath = sut.repositoryPath(owner: testOwner, name: testRepo)
        try FileManager.default.createDirectory(at: repoPath, withIntermediateDirectories: true)

        // Create test files
        let file1 = repoPath.appendingPathComponent("README.md")
        try "# README".write(to: file1, atomically: true, encoding: .utf8)

        let srcDir = repoPath.appendingPathComponent("src")
        try FileManager.default.createDirectory(at: srcDir, withIntermediateDirectories: true)

        let file2 = srcDir.appendingPathComponent("index.js")
        try "console.log('hello');".write(to: file2, atomically: true, encoding: .utf8)

        // When
        let tree = try sut.buildFileTree(owner: testOwner, name: testRepo)

        // Then
        XCTAssertEqual(tree.name, testRepo)
        XCTAssertTrue(tree.isDirectory)
        XCTAssertNotNil(tree.children)
        XCTAssertGreaterThan(tree.children?.count ?? 0, 0)
    }

    func testBuildFileTree_WhenRepositoryNotExists_ThrowsError() {
        // When/Then
        XCTAssertThrowsError(try sut.buildFileTree(owner: "nonexistent", name: "repo")) { error in
            guard let repoError = error as? LocalRepositoryError else {
                XCTFail("Expected LocalRepositoryError")
                return
            }
            XCTAssertEqual(repoError, LocalRepositoryError.repositoryNotFound)
        }
    }

    // MARK: - File Content Tests

    func testReadFileContent_Success() throws {
        // Given
        let repoPath = sut.repositoryPath(owner: testOwner, name: testRepo)
        try FileManager.default.createDirectory(at: repoPath, withIntermediateDirectories: true)

        let testFile = repoPath.appendingPathComponent("test.txt")
        let testContent = "Hello, World!"
        try testContent.write(to: testFile, atomically: true, encoding: .utf8)

        // When
        let content = try sut.readFileContent(at: testFile.path)

        // Then
        XCTAssertEqual(content, testContent)
    }

    func testReadFileContent_NonexistentFile_ThrowsError() {
        // When/Then
        XCTAssertThrowsError(try sut.readFileContent(at: "/nonexistent/file.txt"))
    }

    func testFileExists_WhenExists_ReturnsTrue() throws {
        // Given
        let repoPath = sut.repositoryPath(owner: testOwner, name: testRepo)
        try FileManager.default.createDirectory(at: repoPath, withIntermediateDirectories: true)

        let testFile = repoPath.appendingPathComponent("test.txt")
        try "content".write(to: testFile, atomically: true, encoding: .utf8)

        // When
        let exists = sut.fileExists(at: testFile.path)

        // Then
        XCTAssertTrue(exists)
    }

    func testFileExists_WhenNotExists_ReturnsFalse() {
        // When
        let exists = sut.fileExists(at: "/nonexistent/file.txt")

        // Then
        XCTAssertFalse(exists)
    }

    func testFileSize_ReturnsCorrectSize() throws {
        // Given
        let repoPath = sut.repositoryPath(owner: testOwner, name: testRepo)
        try FileManager.default.createDirectory(at: repoPath, withIntermediateDirectories: true)

        let testFile = repoPath.appendingPathComponent("test.txt")
        let testContent = "Hello, World!" // 13 bytes
        try testContent.write(to: testFile, atomically: true, encoding: .utf8)

        // When
        let size = sut.fileSize(at: testFile.path)

        // Then
        XCTAssertEqual(size, 13)
    }

    func testFileSize_NonexistentFile_ReturnsNil() {
        // When
        let size = sut.fileSize(at: "/nonexistent/file.txt")

        // Then
        XCTAssertNil(size)
    }

    // MARK: - FileNode Tests

    func testFileNode_Identifiable() {
        // Given
        let node1 = FileNode(name: "test", path: "/test", type: .file, children: nil)
        let node2 = FileNode(name: "test", path: "/test", type: .file, children: nil)

        // Then
        XCTAssertNotEqual(node1.id, node2.id, "Each FileNode should have unique ID")
    }

    func testFileNode_IsDirectory() {
        // Given
        let dirNode = FileNode(name: "dir", path: "/dir", type: .directory, children: [])
        let fileNode = FileNode(name: "file", path: "/file", type: .file, children: nil)

        // Then
        XCTAssertTrue(dirNode.isDirectory)
        XCTAssertFalse(fileNode.isDirectory)
    }

    func testFileNode_IsFile() {
        // Given
        let dirNode = FileNode(name: "dir", path: "/dir", type: .directory, children: [])
        let fileNode = FileNode(name: "file", path: "/file", type: .file, children: nil)

        // Then
        XCTAssertFalse(dirNode.isFile)
        XCTAssertTrue(fileNode.isFile)
    }

    // MARK: - Error Handling Tests

    func testLocalRepositoryError_HasDescriptiveMessages() {
        // Given
        let errors: [LocalRepositoryError] = [
            .repositoryNotFound,
            .fileNotFound(path: "/path/to/file"),
            .fileNotReadable(path: "/path/to/file"),
            .downloadFailed(url: "https://example.com/file"),
            .directoryCreationFailed,
            .metadataNotFound
        ]

        // When/Then
        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertFalse(error.errorDescription!.isEmpty)
        }
    }

    // MARK: - Performance Tests

    func testListDownloadedRepositories_Performance() throws {
        // Setup: Create multiple test repositories
        for i in 1...10 {
            let path = sut.repositoryPath(owner: "owner\(i)", name: "repo\(i)")
            try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true)
        }

        // Measure
        measure {
            _ = sut.listDownloadedRepositories()
        }

        // Cleanup
        for i in 1...10 {
            try? sut.deleteRepository(owner: "owner\(i)", name: "repo\(i)")
        }
    }
}
