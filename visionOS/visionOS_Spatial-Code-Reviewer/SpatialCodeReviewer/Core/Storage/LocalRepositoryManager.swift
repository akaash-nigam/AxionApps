//
//  LocalRepositoryManager.swift
//  SpatialCodeReviewer
//
//  Created by Claude on 2025-11-24.
//

import Foundation

/// Manages local storage and access to cloned repository contents
@MainActor
class LocalRepositoryManager: ObservableObject {
    static let shared = LocalRepositoryManager()

    @Published var isDownloading = false
    @Published var downloadProgress: Double = 0.0

    private let fileManager = FileManager.default
    private let repositoriesDirectory: URL

    private init() {
        // Create repositories directory in app's document directory
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        repositoriesDirectory = documentsPath.appendingPathComponent("Repositories", isDirectory: true)

        // Create directory if it doesn't exist
        try? fileManager.createDirectory(at: repositoriesDirectory, withIntermediateDirectories: true)
    }

    // MARK: - Repository Path Management

    func repositoryPath(owner: String, name: String) -> URL {
        return repositoriesDirectory
            .appendingPathComponent(owner, isDirectory: true)
            .appendingPathComponent(name, isDirectory: true)
    }

    func isRepositoryDownloaded(owner: String, name: String) -> Bool {
        let path = repositoryPath(owner: owner, name: name)
        return fileManager.fileExists(atPath: path.path)
    }

    func deleteRepository(owner: String, name: String) throws {
        let path = repositoryPath(owner: owner, name: name)
        if fileManager.fileExists(atPath: path.path) {
            try fileManager.removeItem(at: path)
        }
    }

    func deleteAllRepositories() throws {
        if fileManager.fileExists(atPath: repositoriesDirectory.path) {
            try fileManager.removeItem(at: repositoriesDirectory)
            try fileManager.createDirectory(at: repositoriesDirectory, withIntermediateDirectories: true)
        }
    }

    func listDownloadedRepositories() -> [(owner: String, name: String)] {
        var repositories: [(owner: String, name: String)] = []

        guard let ownerDirs = try? fileManager.contentsOfDirectory(
            at: repositoriesDirectory,
            includingPropertiesForKeys: nil
        ) else {
            return repositories
        }

        for ownerDir in ownerDirs {
            guard let repoDirs = try? fileManager.contentsOfDirectory(
                at: ownerDir,
                includingPropertiesForKeys: nil
            ) else {
                continue
            }

            let owner = ownerDir.lastPathComponent
            for repoDir in repoDirs {
                let name = repoDir.lastPathComponent
                repositories.append((owner: owner, name: name))
            }
        }

        return repositories
    }

    // MARK: - Repository Download

    func downloadRepository(
        repository: Repository,
        branch: String,
        contents: [RepositoryContent],
        repositoryService: RepositoryService
    ) async throws {
        isDownloading = true
        downloadProgress = 0.0
        defer {
            isDownloading = false
            downloadProgress = 0.0
        }

        let repoPath = repositoryPath(owner: repository.owner.login, name: repository.name)

        // Clean up existing directory
        if fileManager.fileExists(atPath: repoPath.path) {
            try fileManager.removeItem(at: repoPath)
        }

        // Create repository directory
        try fileManager.createDirectory(at: repoPath, withIntermediateDirectories: true)

        // Save repository metadata
        try saveRepositoryMetadata(repository: repository, branch: branch, at: repoPath)

        // Download all files recursively
        var totalFiles = 0
        var downloadedFiles = 0

        // Count total files first
        totalFiles = try await countFiles(
            owner: repository.owner.login,
            repo: repository.name,
            contents: contents,
            branch: branch,
            repositoryService: repositoryService
        )

        // Download all files
        try await downloadContents(
            owner: repository.owner.login,
            repo: repository.name,
            contents: contents,
            branch: branch,
            basePath: repoPath,
            repositoryService: repositoryService,
            totalFiles: totalFiles,
            downloadedFiles: &downloadedFiles
        )

        downloadProgress = 1.0
    }

    private func countFiles(
        owner: String,
        repo: String,
        contents: [RepositoryContent],
        branch: String,
        repositoryService: RepositoryService
    ) async throws -> Int {
        var count = 0

        for content in contents {
            if content.type == .file {
                count += 1
            } else if content.type == .dir {
                let subContents = try await repositoryService.fetchRepositoryContents(
                    owner: owner,
                    repo: repo,
                    path: content.path,
                    ref: branch
                )
                count += try await countFiles(
                    owner: owner,
                    repo: repo,
                    contents: subContents,
                    branch: branch,
                    repositoryService: repositoryService
                )
            }
        }

        return count
    }

    private func downloadContents(
        owner: String,
        repo: String,
        contents: [RepositoryContent],
        branch: String,
        basePath: URL,
        repositoryService: RepositoryService,
        totalFiles: Int,
        downloadedFiles: inout Int
    ) async throws {
        for content in contents {
            switch content.type {
            case .file:
                if let downloadURL = content.downloadUrl {
                    let filePath = basePath.appendingPathComponent(content.name)
                    try await downloadFile(from: downloadURL, to: filePath)

                    downloadedFiles += 1
                    downloadProgress = Double(downloadedFiles) / Double(totalFiles)
                }

            case .dir:
                // Create directory
                let dirPath = basePath.appendingPathComponent(content.name, isDirectory: true)
                try fileManager.createDirectory(at: dirPath, withIntermediateDirectories: true)

                // Fetch and download contents recursively
                let subContents = try await repositoryService.fetchRepositoryContents(
                    owner: owner,
                    repo: repo,
                    path: content.path,
                    ref: branch
                )

                try await downloadContents(
                    owner: owner,
                    repo: repo,
                    contents: subContents,
                    branch: branch,
                    basePath: dirPath,
                    repositoryService: repositoryService,
                    totalFiles: totalFiles,
                    downloadedFiles: &downloadedFiles
                )

            case .symlink, .submodule:
                // Skip symlinks and submodules for MVP
                continue
            }
        }
    }

    private func downloadFile(from url: URL, to destination: URL) async throws {
        let (tempURL, response) = try await URLSession.shared.download(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw LocalRepositoryError.downloadFailed(url: url.absoluteString)
        }

        // Move temp file to destination
        try fileManager.moveItem(at: tempURL, to: destination)
    }

    private func saveRepositoryMetadata(repository: Repository, branch: String, at path: URL) throws {
        let metadata = RepositoryMetadata(
            id: repository.id,
            name: repository.name,
            fullName: repository.fullName,
            owner: repository.owner.login,
            branch: branch,
            downloadedAt: Date(),
            lastAccessedAt: Date()
        )

        let metadataPath = path.appendingPathComponent(".metadata.json")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(metadata)
        try data.write(to: metadataPath)
    }

    func loadRepositoryMetadata(owner: String, name: String) throws -> RepositoryMetadata {
        let repoPath = repositoryPath(owner: owner, name: name)
        let metadataPath = repoPath.appendingPathComponent(".metadata.json")

        let data = try Data(contentsOf: metadataPath)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(RepositoryMetadata.self, from: data)
    }

    // MARK: - File Tree Generation

    func buildFileTree(owner: String, name: String) throws -> FileNode {
        let repoPath = repositoryPath(owner: owner, name: name)

        guard fileManager.fileExists(atPath: repoPath.path) else {
            throw LocalRepositoryError.repositoryNotFound
        }

        return try buildFileTreeRecursive(at: repoPath, name: name, isRoot: true)
    }

    private func buildFileTreeRecursive(at path: URL, name: String, isRoot: Bool = false) throws -> FileNode {
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: path.path, isDirectory: &isDirectory) else {
            throw LocalRepositoryError.fileNotFound(path: path.path)
        }

        if isDirectory.boolValue {
            // Skip hidden files and .git directory
            if !isRoot && (name.hasPrefix(".") || name == "node_modules") {
                return FileNode(
                    name: name,
                    path: path.path,
                    type: .directory,
                    children: []
                )
            }

            let contents = try fileManager.contentsOfDirectory(
                at: path,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            )

            let children = try contents
                .sorted { $0.lastPathComponent < $1.lastPathComponent }
                .compactMap { url -> FileNode? in
                    // Skip .metadata.json
                    if url.lastPathComponent == ".metadata.json" {
                        return nil
                    }
                    return try? buildFileTreeRecursive(at: url, name: url.lastPathComponent)
                }

            return FileNode(
                name: name,
                path: path.path,
                type: .directory,
                children: children
            )
        } else {
            return FileNode(
                name: name,
                path: path.path,
                type: .file,
                children: nil
            )
        }
    }

    // MARK: - File Content

    func readFileContent(at path: String) throws -> String {
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)

        // Try to decode as UTF-8
        guard let content = String(data: data, encoding: .utf8) else {
            throw LocalRepositoryError.fileNotReadable(path: path)
        }

        return content
    }

    func fileExists(at path: String) -> Bool {
        return fileManager.fileExists(atPath: path)
    }

    func fileSize(at path: String) -> Int64? {
        guard let attributes = try? fileManager.attributesOfItem(atPath: path) else {
            return nil
        }
        return attributes[.size] as? Int64
    }
}

// MARK: - Models

struct RepositoryMetadata: Codable {
    let id: Int
    let name: String
    let fullName: String
    let owner: String
    let branch: String
    let downloadedAt: Date
    var lastAccessedAt: Date
}

struct FileNode: Identifiable {
    let id = UUID()
    let name: String
    let path: String
    let type: FileNodeType
    let children: [FileNode]?

    var isDirectory: Bool {
        return type == .directory
    }

    var isFile: Bool {
        return type == .file
    }

    enum FileNodeType {
        case file
        case directory
    }
}

// MARK: - Errors

enum LocalRepositoryError: LocalizedError {
    case repositoryNotFound
    case fileNotFound(path: String)
    case fileNotReadable(path: String)
    case downloadFailed(url: String)
    case directoryCreationFailed
    case metadataNotFound

    var errorDescription: String? {
        switch self {
        case .repositoryNotFound:
            return "Repository not found locally"
        case .fileNotFound(let path):
            return "File not found: \(path)"
        case .fileNotReadable(let path):
            return "Cannot read file: \(path)"
        case .downloadFailed(let url):
            return "Failed to download file: \(url)"
        case .directoryCreationFailed:
            return "Failed to create directory"
        case .metadataNotFound:
            return "Repository metadata not found"
        }
    }
}
