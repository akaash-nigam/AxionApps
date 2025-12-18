# Git Operations Design Document

## Document Information
- **Version**: 1.0
- **Last Updated**: 2025-11-24
- **Status**: Draft
- **Owner**: Engineering Team

## 1. Overview

This document specifies the Git operations architecture for Spatial Code Reviewer, including repository management, commit history handling, diff visualization, and integration with libgit2.

## 2. Git Architecture

### 2.1 System Overview

```
┌──────────────────────────────────────────────────────┐
│              Application Layer                        │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────┐ │
│  │ GitHistory   │  │ DiffViewer   │  │   Blame    │ │
│  │  Manager     │  │              │  │  Service   │ │
│  └──────────────┘  └──────────────┘  └────────────┘ │
└──────────────────────────────────────────────────────┘
                         │
┌──────────────────────────────────────────────────────┐
│            Git Service Layer                          │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────┐ │
│  │  Repository  │  │   Commit     │  │    Diff    │ │
│  │   Service    │  │   Service    │  │  Service   │ │
│  └──────────────┘  └──────────────┘  └────────────┘ │
└──────────────────────────────────────────────────────┘
                         │
┌──────────────────────────────────────────────────────┐
│               libgit2 Layer                           │
│  ┌──────────────────────────────────────────────┐   │
│  │              libgit2 C Library                │   │
│  └──────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────┘
                         │
┌──────────────────────────────────────────────────────┐
│            File System Layer                          │
│  ┌──────────────────────────────────────────────┐   │
│  │   .git/ directory and working tree            │   │
│  └──────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────┘
```

## 3. Repository Service

### 3.1 Repository Operations

```swift
class GitRepositoryService {
    private var repository: OpaquePointer?
    private let repositoryPath: URL

    init(path: URL) {
        self.repositoryPath = path
        git_libgit2_init()
    }

    deinit {
        if let repo = repository {
            git_repository_free(repo)
        }
        git_libgit2_shutdown()
    }

    // MARK: - Repository Management

    func clone(from url: URL, to localPath: URL, progress: ((Double) -> Void)? = nil) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            var options = git_clone_options()
            git_clone_options_init(&options, UInt32(GIT_CLONE_OPTIONS_VERSION))

            // Configure clone options
            options.checkout_opts.checkout_strategy = GIT_CHECKOUT_SAFE.rawValue
            options.fetch_opts.callbacks.transfer_progress = { stats, _ in
                guard let stats = stats else { return 0 }

                let received = stats.pointee.received_objects
                let total = stats.pointee.total_objects

                if total > 0 {
                    let progress = Double(received) / Double(total)
                    DispatchQueue.main.async {
                        progress?(progress)
                    }
                }

                return 0
            }

            var repo: OpaquePointer?

            let result = url.absoluteString.withCString { urlCString in
                localPath.path.withCString { pathCString in
                    git_clone(&repo, urlCString, pathCString, &options)
                }
            }

            if result == 0 {
                self.repository = repo
                continuation.resume()
            } else {
                let error = self.getLastGitError()
                continuation.resume(throwing: GitError.cloneFailed(error))
            }
        }
    }

    func open() throws {
        var repo: OpaquePointer?

        let result = repositoryPath.path.withCString { path in
            git_repository_open(&repo, path)
        }

        guard result == 0, let repository = repo else {
            throw GitError.openFailed(getLastGitError())
        }

        self.repository = repository
    }

    func fetch(remote: String = "origin") async throws {
        guard let repo = repository else {
            throw GitError.repositoryNotOpen
        }

        return try await withCheckedThrowingContinuation { continuation in
            var remotePtr: OpaquePointer?

            // Get remote
            var result = remote.withCString { name in
                git_remote_lookup(&remotePtr, repo, name)
            }

            guard result == 0, let remote = remotePtr else {
                continuation.resume(throwing: GitError.remoteLookupFailed)
                return
            }

            defer {
                git_remote_free(remote)
            }

            // Fetch
            var options = git_fetch_options()
            git_fetch_options_init(&options, UInt32(GIT_FETCH_OPTIONS_VERSION))

            result = git_remote_fetch(remote, nil, &options, nil)

            if result == 0 {
                continuation.resume()
            } else {
                continuation.resume(throwing: GitError.fetchFailed(getLastGitError()))
            }
        }
    }

    func checkoutBranch(_ branchName: String) throws {
        guard let repo = repository else {
            throw GitError.repositoryNotOpen
        }

        // Find branch
        var reference: OpaquePointer?
        let refName = "refs/heads/\(branchName)"

        var result = refName.withCString { name in
            git_reference_lookup(&reference, repo, name)
        }

        guard result == 0, let ref = reference else {
            throw GitError.branchNotFound(branchName)
        }

        defer {
            git_reference_free(ref)
        }

        // Get commit
        var commit: OpaquePointer?
        result = git_reference_peel(&commit, ref, GIT_OBJECT_COMMIT)

        guard result == 0 else {
            throw GitError.checkoutFailed(getLastGitError())
        }

        defer {
            git_commit_free(commit)
        }

        // Checkout
        var options = git_checkout_options()
        git_checkout_options_init(&options, UInt32(GIT_CHECKOUT_OPTIONS_VERSION))
        options.checkout_strategy = GIT_CHECKOUT_SAFE.rawValue

        result = git_checkout_tree(repo, commit, &options)

        guard result == 0 else {
            throw GitError.checkoutFailed(getLastGitError())
        }

        // Update HEAD
        result = refName.withCString { name in
            git_repository_set_head(repo, name)
        }

        guard result == 0 else {
            throw GitError.checkoutFailed(getLastGitError())
        }
    }

    func listBranches() throws -> [Branch] {
        guard let repo = repository else {
            throw GitError.repositoryNotOpen
        }

        var branches: [Branch] = []
        var iterator: OpaquePointer?

        // Create branch iterator
        var result = git_branch_iterator_new(&iterator, repo, GIT_BRANCH_LOCAL)

        guard result == 0, let iter = iterator else {
            throw GitError.listBranchesFailed
        }

        defer {
            git_branch_iterator_free(iter)
        }

        // Iterate branches
        var reference: OpaquePointer?
        var branchType: git_branch_t = GIT_BRANCH_LOCAL

        while git_branch_next(&reference, &branchType, iter) == 0 {
            defer {
                git_reference_free(reference)
            }

            guard let ref = reference else { continue }

            // Get branch name
            var name: UnsafePointer<CChar>?
            git_branch_name(&name, ref)

            guard let branchName = name.map({ String(cString: $0) }) else {
                continue
            }

            // Get commit SHA
            let oid = git_reference_target(ref)
            var sha = ""

            if let oid = oid {
                var buffer = [CChar](repeating: 0, count: 41)
                git_oid_tostr(&buffer, 41, oid)
                sha = String(cString: buffer)
            }

            branches.append(Branch(
                name: branchName,
                commitSHA: sha,
                lastCommitDate: Date(),
                isActive: false,
                createdAt: Date()
            ))
        }

        return branches
    }

    // MARK: - Error Handling

    private func getLastGitError() -> String {
        if let error = git_error_last() {
            return String(cString: error.pointee.message)
        }
        return "Unknown error"
    }
}

enum GitError: LocalizedError {
    case repositoryNotOpen
    case cloneFailed(String)
    case openFailed(String)
    case fetchFailed(String)
    case checkoutFailed(String)
    case branchNotFound(String)
    case listBranchesFailed
    case remoteLookupFailed

    var errorDescription: String? {
        switch self {
        case .repositoryNotOpen:
            return "Repository is not open"
        case .cloneFailed(let message):
            return "Failed to clone repository: \(message)"
        case .openFailed(let message):
            return "Failed to open repository: \(message)"
        case .fetchFailed(let message):
            return "Failed to fetch: \(message)"
        case .checkoutFailed(let message):
            return "Failed to checkout: \(message)"
        case .branchNotFound(let branch):
            return "Branch '\(branch)' not found"
        case .listBranchesFailed:
            return "Failed to list branches"
        case .remoteLookupFailed:
            return "Failed to lookup remote"
        }
    }
}
```

## 4. Commit Service

### 4.1 Commit History

```swift
class GitCommitService {
    private let repository: OpaquePointer

    init(repository: OpaquePointer) {
        self.repository = repository
    }

    func listCommits(
        branch: String? = nil,
        limit: Int = 100,
        offset: Int = 0
    ) throws -> [Commit] {
        var commits: [Commit] = []
        var revwalk: OpaquePointer?

        // Create revision walker
        var result = git_revwalk_new(&revwalk, repository)

        guard result == 0, let walker = revwalk else {
            throw GitError.revwalkFailed
        }

        defer {
            git_revwalk_free(walker)
        }

        // Set sorting
        git_revwalk_sorting(walker, GIT_SORT_TIME.rawValue)

        // Push branch or HEAD
        if let branch = branch {
            let refName = "refs/heads/\(branch)"

            result = refName.withCString { name in
                var oid = git_oid()
                git_reference_name_to_id(&oid, repository, name)
                return git_revwalk_push(walker, &oid)
            }
        } else {
            result = git_revwalk_push_head(walker)
        }

        guard result == 0 else {
            throw GitError.revwalkFailed
        }

        // Walk commits
        var oid = git_oid()
        var count = 0
        var skipped = 0

        while git_revwalk_next(&oid, walker) == 0 {
            // Skip offset
            if skipped < offset {
                skipped += 1
                continue
            }

            // Check limit
            if count >= limit {
                break
            }

            // Lookup commit
            var commitPtr: OpaquePointer?
            result = git_commit_lookup(&commitPtr, repository, &oid)

            guard result == 0, let commit = commitPtr else {
                continue
            }

            defer {
                git_commit_free(commit)
            }

            // Extract commit data
            let sha = formatOid(oid)
            let message = String(cString: git_commit_message(commit))

            let author = git_commit_author(commit)
            let authorName = String(cString: author.pointee.name)
            let authorEmail = String(cString: author.pointee.email)
            let timestamp = author.pointee.when.time

            commits.append(Commit(
                sha: sha,
                message: message,
                author: authorName,
                authorEmail: authorEmail,
                date: Date(timeIntervalSince1970: TimeInterval(timestamp)),
                url: URL(string: "")!
            ))

            count += 1
        }

        return commits
    }

    func getCommit(_ sha: String) throws -> Commit {
        var oid = git_oid()

        var result = sha.withCString { shaStr in
            git_oid_fromstr(&oid, shaStr)
        }

        guard result == 0 else {
            throw GitError.invalidSHA
        }

        var commitPtr: OpaquePointer?
        result = git_commit_lookup(&commitPtr, repository, &oid)

        guard result == 0, let commit = commitPtr else {
            throw GitError.commitNotFound
        }

        defer {
            git_commit_free(commit)
        }

        let message = String(cString: git_commit_message(commit))

        let author = git_commit_author(commit)
        let authorName = String(cString: author.pointee.name)
        let authorEmail = String(cString: author.pointee.email)
        let timestamp = author.pointee.when.time

        return Commit(
            sha: sha,
            message: message,
            author: authorName,
            authorEmail: authorEmail,
            date: Date(timeIntervalSince1970: TimeInterval(timestamp)),
            url: URL(string: "")!
        )
    }

    private func formatOid(_ oid: git_oid) -> String {
        var buffer = [CChar](repeating: 0, count: 41)
        git_oid_tostr(&buffer, 41, &oid)
        return String(cString: buffer)
    }
}

extension GitError {
    static let revwalkFailed = GitError.openFailed("Failed to create revision walker")
    static let invalidSHA = GitError.openFailed("Invalid SHA")
    static let commitNotFound = GitError.openFailed("Commit not found")
}
```

## 5. Diff Service

### 5.1 Diff Calculation

```swift
class GitDiffService {
    private let repository: OpaquePointer

    init(repository: OpaquePointer) {
        self.repository = repository
    }

    func diff(from oldCommit: String, to newCommit: String) throws -> [FileDiff] {
        // Lookup commits
        let oldOid = try lookupOid(oldCommit)
        let newOid = try lookupOid(newCommit)

        var oldCommitPtr: OpaquePointer?
        var newCommitPtr: OpaquePointer?

        var result = git_commit_lookup(&oldCommitPtr, repository, &oldOid)
        guard result == 0, let oldCommit = oldCommitPtr else {
            throw GitError.commitNotFound
        }
        defer { git_commit_free(oldCommit) }

        result = git_commit_lookup(&newCommitPtr, repository, &newOid)
        guard result == 0, let newCommit = newCommitPtr else {
            throw GitError.commitNotFound
        }
        defer { git_commit_free(newCommit) }

        // Get trees
        var oldTreePtr: OpaquePointer?
        var newTreePtr: OpaquePointer?

        result = git_commit_tree(&oldTreePtr, oldCommit)
        guard result == 0, let oldTree = oldTreePtr else {
            throw GitError.diffFailed
        }
        defer { git_tree_free(oldTree) }

        result = git_commit_tree(&newTreePtr, newCommit)
        guard result == 0, let newTree = newTreePtr else {
            throw GitError.diffFailed
        }
        defer { git_tree_free(newTree) }

        // Create diff
        var diffPtr: OpaquePointer?
        result = git_diff_tree_to_tree(&diffPtr, repository, oldTree, newTree, nil)

        guard result == 0, let diff = diffPtr else {
            throw GitError.diffFailed
        }
        defer { git_diff_free(diff) }

        // Extract file diffs
        return try extractFileDiffs(from: diff)
    }

    func diffWorkingDirectory() throws -> [FileDiff] {
        // Get HEAD tree
        var headPtr: OpaquePointer?
        var result = git_repository_head(&headPtr, repository)

        guard result == 0, let head = headPtr else {
            throw GitError.headNotFound
        }
        defer { git_reference_free(head) }

        var commitPtr: OpaquePointer?
        result = git_reference_peel(&commitPtr, head, GIT_OBJECT_COMMIT)

        guard result == 0, let commit = commitPtr else {
            throw GitError.diffFailed
        }
        defer { git_commit_free(commit) }

        var treePtr: OpaquePointer?
        result = git_commit_tree(&treePtr, commit)

        guard result == 0, let tree = treePtr else {
            throw GitError.diffFailed
        }
        defer { git_tree_free(tree) }

        // Diff against working directory
        var diffPtr: OpaquePointer?
        result = git_diff_tree_to_workdir(&diffPtr, repository, tree, nil)

        guard result == 0, let diff = diffPtr else {
            throw GitError.diffFailed
        }
        defer { git_diff_free(diff) }

        return try extractFileDiffs(from: diff)
    }

    private func extractFileDiffs(from diff: OpaquePointer) throws -> [FileDiff] {
        var fileDiffs: [FileDiff] = []

        let numDeltas = git_diff_num_deltas(diff)

        for i in 0..<numDeltas {
            guard let delta = git_diff_get_delta(diff, i) else {
                continue
            }

            let oldPath = String(cString: delta.pointee.old_file.path)
            let newPath = String(cString: delta.pointee.new_file.path)

            let status = delta.pointee.status

            // Get patch
            var patchPtr: OpaquePointer?
            var result = git_patch_from_diff(&patchPtr, diff, i)

            var patch: String = ""
            var additions = 0
            var deletions = 0

            if result == 0, let patchObj = patchPtr {
                defer { git_patch_free(patchObj) }

                // Get patch text
                var buf = git_buf()
                result = git_patch_to_buf(&buf, patchObj)

                if result == 0 {
                    patch = String(cString: buf.ptr)
                    git_buf_dispose(&buf)
                }

                // Get line stats
                additions = git_patch_line_stats(nil, nil, &additions, patchObj)
                deletions = git_patch_line_stats(nil, nil, nil, &deletions)
            }

            fileDiffs.append(FileDiff(
                oldPath: oldPath,
                newPath: newPath,
                status: mapDiffStatus(status),
                additions: additions,
                deletions: deletions,
                patch: patch
            ))
        }

        return fileDiffs
    }

    private func lookupOid(_ sha: String) throws -> git_oid {
        var oid = git_oid()

        let result = sha.withCString { shaStr in
            git_oid_fromstr(&oid, shaStr)
        }

        guard result == 0 else {
            throw GitError.invalidSHA
        }

        return oid
    }

    private func mapDiffStatus(_ status: git_delta_t) -> DiffStatus {
        switch status {
        case GIT_DELTA_ADDED: return .added
        case GIT_DELTA_DELETED: return .deleted
        case GIT_DELTA_MODIFIED: return .modified
        case GIT_DELTA_RENAMED: return .renamed
        default: return .unmodified
        }
    }
}

struct FileDiff {
    let oldPath: String
    let newPath: String
    let status: DiffStatus
    let additions: Int
    let deletions: Int
    let patch: String
}

enum DiffStatus {
    case added
    case deleted
    case modified
    case renamed
    case unmodified
}

extension GitError {
    static let diffFailed = GitError.openFailed("Failed to create diff")
    static let headNotFound = GitError.openFailed("HEAD not found")
}
```

## 6. Blame Service

### 6.1 Blame Information

```swift
class GitBlameService {
    private let repository: OpaquePointer

    init(repository: OpaquePointer) {
        self.repository = repository
    }

    func blame(file: String) throws -> [BlameLine] {
        var blamePtr: OpaquePointer?

        let result = file.withCString { path in
            git_blame_file(&blamePtr, repository, path, nil)
        }

        guard result == 0, let blame = blamePtr else {
            throw GitError.blameFailed
        }

        defer {
            git_blame_free(blame)
        }

        var blameLines: [BlameLine] = []
        let hunkCount = git_blame_get_hunk_count(blame)

        for i in 0..<hunkCount {
            guard let hunk = git_blame_get_hunk_byindex(blame, UInt32(i)) else {
                continue
            }

            let sha = formatOid(hunk.pointee.final_commit_id)

            let signature = hunk.pointee.final_signature
            let author = String(cString: signature.pointee.name)
            let email = String(cString: signature.pointee.email)
            let timestamp = signature.pointee.when.time

            let startLine = Int(hunk.pointee.final_start_line_number)
            let lineCount = Int(hunk.pointee.lines_in_hunk)

            for line in 0..<lineCount {
                blameLines.append(BlameLine(
                    lineNumber: startLine + line,
                    commitSHA: sha,
                    author: author,
                    email: email,
                    date: Date(timeIntervalSince1970: TimeInterval(timestamp))
                ))
            }
        }

        return blameLines
    }

    private func formatOid(_ oid: git_oid) -> String {
        var buffer = [CChar](repeating: 0, count: 41)
        git_oid_tostr(&buffer, 41, &oid)
        return String(cString: buffer)
    }
}

struct BlameLine {
    let lineNumber: Int
    let commitSHA: String
    let author: String
    let email: String
    let date: Date
}

extension GitError {
    static let blameFailed = GitError.openFailed("Failed to blame file")
}
```

## 7. Git History Visualization

### 7.1 History Timeline

```swift
class GitHistoryManager {
    private let commitService: GitCommitService
    private let diffService: GitDiffService

    init(repository: OpaquePointer) {
        self.commitService = GitCommitService(repository: repository)
        self.diffService = GitDiffService(repository: repository)
    }

    func loadHistory(for file: String) async throws -> [FileHistoryEntry] {
        let commits = try commitService.listCommits(limit: 100)

        var history: [FileHistoryEntry] = []

        for i in 0..<commits.count {
            let commit = commits[i]

            // Get diff from previous commit
            if i < commits.count - 1 {
                let previousCommit = commits[i + 1]

                let diffs = try diffService.diff(
                    from: previousCommit.sha,
                    to: commit.sha
                )

                // Find diff for this file
                if let fileDiff = diffs.first(where: { $0.newPath == file }) {
                    history.append(FileHistoryEntry(
                        commit: commit,
                        diff: fileDiff
                    ))
                }
            }
        }

        return history
    }

    func animateHistory(
        _ history: [FileHistoryEntry],
        duration: TimeInterval,
        updateHandler: (FileHistoryEntry) -> Void
    ) {
        let interval = duration / Double(history.count)

        var index = 0
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            guard index < history.count else {
                timer.invalidate()
                return
            }

            updateHandler(history[index])
            index += 1
        }
    }
}

struct FileHistoryEntry {
    let commit: Commit
    let diff: FileDiff
}
```

## 8. Performance Optimization

### 8.1 Caching

```swift
class GitCache {
    private var commitCache: [String: Commit] = [:]
    private var diffCache: [String: [FileDiff]] = [:]

    func cacheCommit(_ commit: Commit) {
        commitCache[commit.sha] = commit
    }

    func getCommit(_ sha: String) -> Commit? {
        return commitCache[sha]
    }

    func cacheDiff(from: String, to: String, diffs: [FileDiff]) {
        let key = "\(from):\(to)"
        diffCache[key] = diffs
    }

    func getDiff(from: String, to: String) -> [FileDiff]? {
        let key = "\(from):\(to)"
        return diffCache[key]
    }

    func clear() {
        commitCache.removeAll()
        diffCache.removeAll()
    }
}
```

### 8.2 Background Loading

```swift
class BackgroundGitLoader {
    private let queue = DispatchQueue(
        label: "com.spatialcodereviewer.git",
        qos: .utility
    )

    func loadHistoryInBackground(
        repository: OpaquePointer,
        completion: @escaping (Result<[Commit], Error>) -> Void
    ) {
        queue.async {
            do {
                let commitService = GitCommitService(repository: repository)
                let commits = try commitService.listCommits()

                DispatchQueue.main.async {
                    completion(.success(commits))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
```

## 9. Testing

### 9.1 Git Operation Tests

```swift
class GitOperationsTests: XCTestCase {
    var testRepo: URL!
    var gitService: GitRepositoryService!

    override func setUp() async throws {
        testRepo = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)

        try FileManager.default.createDirectory(at: testRepo, withIntermediateDirectories: true)

        gitService = GitRepositoryService(path: testRepo)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: testRepo)
    }

    func testCloneRepository() async throws {
        let url = URL(string: "https://github.com/octocat/Hello-World")!

        try await gitService.clone(from: url, to: testRepo)

        XCTAssertTrue(FileManager.default.fileExists(atPath: testRepo.appendingPathComponent(".git").path))
    }

    func testListBranches() throws {
        try gitService.open()

        let branches = try gitService.listBranches()

        XCTAssertFalse(branches.isEmpty)
        XCTAssertTrue(branches.contains { $0.name == "main" || $0.name == "master" })
    }

    func testCheckoutBranch() throws {
        try gitService.open()

        let branches = try gitService.listBranches()
        guard let firstBranch = branches.first else {
            XCTFail("No branches found")
            return
        }

        try gitService.checkoutBranch(firstBranch.name)

        // Verify HEAD points to branch
        // Implementation...
    }

    func testDiffBetweenCommits() throws {
        try gitService.open()

        let commitService = GitCommitService(repository: gitService.repository!)
        let commits = try commitService.listCommits(limit: 2)

        guard commits.count == 2 else {
            XCTFail("Need at least 2 commits")
            return
        }

        let diffService = GitDiffService(repository: gitService.repository!)
        let diffs = try diffService.diff(from: commits[1].sha, to: commits[0].sha)

        XCTAssertFalse(diffs.isEmpty)
    }
}
```

## 10. Error Handling

### 10.1 Git Error Recovery

```swift
class GitErrorHandler {
    func handle(_ error: GitError) -> RecoveryAction {
        switch error {
        case .cloneFailed:
            return .retry(maxAttempts: 3)

        case .fetchFailed:
            return .retry(maxAttempts: 2)

        case .branchNotFound:
            return .prompt("Branch not found. Would you like to create it?")

        case .checkoutFailed:
            return .prompt("Checkout failed. Uncommitted changes may be present.")

        default:
            return .alert("An error occurred: \(error.localizedDescription)")
        }
    }

    enum RecoveryAction {
        case retry(maxAttempts: Int)
        case prompt(String)
        case alert(String)
        case ignore
    }
}
```

## 11. References

- [System Architecture Document](./01-system-architecture.md)
- [Data Models Document](./02-data-models.md)
- libgit2 Documentation: https://libgit2.org/
- Git Internals Documentation

## 12. Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-11-24 | Engineering Team | Initial draft |
