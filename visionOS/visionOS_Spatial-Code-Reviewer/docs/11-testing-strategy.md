# Testing Strategy Document

## Document Information
- **Version**: 1.0
- **Last Updated**: 2025-11-24
- **Status**: Draft
- **Owner**: Engineering Team

## 1. Overview

This document defines the comprehensive testing strategy for Spatial Code Reviewer, including unit testing, integration testing, UI testing, performance testing, and quality assurance processes.

## 2. Testing Pyramid

```
        /\
       /  \  E2E Tests (5%)
      /────\
     /      \  Integration Tests (20%)
    /────────\
   /          \  Unit Tests (75%)
  /────────────\
```

### 2.1 Test Distribution

| Test Type | Target Coverage | Current Coverage |
|-----------|----------------|------------------|
| Unit Tests | 80%+ | TBD |
| Integration Tests | 60%+ | TBD |
| UI Tests | 40%+ | TBD |
| E2E Tests | Critical paths | TBD |

## 3. Unit Testing

### 3.1 Testing Framework

```swift
import XCTest
@testable import SpatialCodeReviewer

class ExampleTests: XCTestCase {
    var sut: SystemUnderTest!

    override func setUp() {
        super.setUp()
        sut = SystemUnderTest()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testExample() {
        // Given
        let input = "test"

        // When
        let result = sut.process(input)

        // Then
        XCTAssertEqual(result, "expected")
    }
}
```

### 3.2 Code Analysis Engine Tests

```swift
class CodeAnalysisEngineTests: XCTestCase {
    var parser: ParserManager!

    override func setUp() {
        super.setUp()
        parser = ParserManager()
    }

    // MARK: - JavaScript Parsing Tests

    func testJavaScriptFunctionParsing() async throws {
        let source = """
        function hello(name) {
            return `Hello, ${name}!`;
        }
        """

        let file = CodeFile(path: "test.js", content: source, language: .javascript)
        let result = try await parser.parseFile(file)

        XCTAssertEqual(result.symbols.count, 1)
        XCTAssertEqual(result.symbols[0].name, "hello")
        XCTAssertEqual(result.symbols[0].kind, .function)
    }

    func testJavaScriptClassParsing() async throws {
        let source = """
        class MyClass {
            constructor(value) {
                this.value = value;
            }

            getValue() {
                return this.value;
            }
        }
        """

        let file = CodeFile(path: "test.js", content: source, language: .javascript)
        let result = try await parser.parseFile(file)

        let classSymbol = result.symbols.first { $0.kind == .class }
        XCTAssertNotNil(classSymbol)
        XCTAssertEqual(classSymbol?.name, "MyClass")

        let methods = result.symbols.filter { $0.kind == .method }
        XCTAssertEqual(methods.count, 2) // constructor + getValue
    }

    func testJavaScriptImportExtraction() async throws {
        let source = """
        import React from 'react';
        import { Component } from './Component';
        """

        let file = CodeFile(path: "test.js", content: source, language: .javascript)
        let result = try await parser.parseFile(file)

        let imports = result.dependencies.filter { $0.type == .import }
        XCTAssertEqual(imports.count, 2)
        XCTAssertTrue(imports.contains { $0.targetFile == "react" })
        XCTAssertTrue(imports.contains { $0.targetFile == "./Component" })
    }

    // MARK: - Python Parsing Tests

    func testPythonFunctionParsing() async throws {
        let source = """
        def greet(name):
            return f"Hello, {name}!"
        """

        let file = CodeFile(path: "test.py", content: source, language: .python)
        let result = try await parser.parseFile(file)

        XCTAssertEqual(result.symbols.count, 1)
        XCTAssertEqual(result.symbols[0].name, "greet")
        XCTAssertEqual(result.symbols[0].kind, .function)
    }

    func testPythonClassParsing() async throws {
        let source = """
        class Calculator:
            def add(self, a, b):
                return a + b

            def subtract(self, a, b):
                return a - b
        """

        let file = CodeFile(path: "test.py", content: source, language: .python)
        let result = try await parser.parseFile(file)

        let classSymbol = result.symbols.first { $0.kind == .class }
        XCTAssertNotNil(classSymbol)
        XCTAssertEqual(classSymbol?.name, "Calculator")

        let methods = result.symbols.filter { $0.kind == .function }
        XCTAssertEqual(methods.count, 2)
    }

    // MARK: - Swift Parsing Tests

    func testSwiftStructParsing() async throws {
        let source = """
        struct User {
            let name: String
            let age: Int

            func greet() -> String {
                return "Hello, \\(name)"
            }
        }
        """

        let file = CodeFile(path: "test.swift", content: source, language: .swift)
        let result = try await parser.parseFile(file)

        let structSymbol = result.symbols.first { $0.kind == .struct }
        XCTAssertNotNil(structSymbol)
        XCTAssertEqual(structSymbol?.name, "User")
    }

    // MARK: - Performance Tests

    func testParsingPerformance() throws {
        let largeFile = generateLargeFile(lineCount: 1000)

        measure {
            _ = try? await parser.parseFile(largeFile)
        }
    }

    private func generateLargeFile(lineCount: Int) -> CodeFile {
        var content = ""
        for i in 0..<lineCount {
            content += "function test\(i)() { return \(i); }\n"
        }
        return CodeFile(path: "large.js", content: content, language: .javascript)
    }
}
```

### 3.3 Dependency Graph Tests

```swift
class DependencyGraphTests: XCTestCase {
    var graphBuilder: DependencyGraphBuilder!

    override func setUp() {
        super.setUp()
        graphBuilder = DependencyGraphBuilder()
    }

    func testSimpleGraph() {
        let fileA = createMockParseResult(path: "A.js", dependencies: ["B.js"])
        let fileB = createMockParseResult(path: "B.js", dependencies: [])

        let graph = graphBuilder.buildGraph(from: [fileA, fileB])

        XCTAssertEqual(graph.nodes.count, 2)
        XCTAssertEqual(graph.edges.count, 1)
        XCTAssertEqual(graph.edges[0].source, 0) // A -> B
    }

    func testCircularDependency() {
        let fileA = createMockParseResult(path: "A.js", dependencies: ["B.js"])
        let fileB = createMockParseResult(path: "B.js", dependencies: ["C.js"])
        let fileC = createMockParseResult(path: "C.js", dependencies: ["A.js"])

        let graph = graphBuilder.buildGraph(from: [fileA, fileB, fileC])

        let detector = CircularDependencyDetector()
        let cycles = detector.detectCycles(in: graph)

        XCTAssertFalse(cycles.isEmpty)
        XCTAssertEqual(cycles[0].count, 3) // A -> B -> C -> A
    }

    func testGraphSimplification() {
        // Create graph with transitive edge
        var graph = DependencyGraph(nodes: [], edges: [])

        // A -> B -> C and A -> C (transitive)
        graph.nodes = [
            DependencyGraph.Node(id: UUID(), filePath: "A", symbolCount: 0, language: .javascript, position: .zero),
            DependencyGraph.Node(id: UUID(), filePath: "B", symbolCount: 0, language: .javascript, position: .zero),
            DependencyGraph.Node(id: UUID(), filePath: "C", symbolCount: 0, language: .javascript, position: .zero)
        ]

        graph.edges = [
            DependencyGraph.Edge(id: UUID(), source: 0, target: 1, type: .import, weight: 1.0), // A -> B
            DependencyGraph.Edge(id: UUID(), source: 1, target: 2, type: .import, weight: 1.0), // B -> C
            DependencyGraph.Edge(id: UUID(), source: 0, target: 2, type: .import, weight: 1.0)  // A -> C (transitive)
        ]

        let simplifier = GraphSimplifier()
        let simplified = simplifier.reduceTransitiveEdges(graph: graph)

        XCTAssertEqual(simplified.edges.count, 2) // Should remove A -> C
    }
}
```

### 3.4 API Integration Tests

```swift
class GitHubAPIServiceTests: XCTestCase {
    var service: GitHubAPIService!
    var mockAuthManager: MockOAuthManager!

    override func setUp() {
        super.setUp()
        mockAuthManager = MockOAuthManager()
        service = GitHubAPIService(authManager: mockAuthManager)
    }

    func testFetchRepository() async throws {
        mockAuthManager.mockToken = Token(
            accessToken: "test_token",
            refreshToken: nil,
            expiresAt: Date().addingTimeInterval(3600),
            tokenType: "Bearer",
            scope: nil
        )

        let repo = try await service.fetchRepository(owner: "octocat", name: "Hello-World")

        XCTAssertEqual(repo.name, "Hello-World")
        XCTAssertEqual(repo.fullName, "octocat/Hello-World")
    }

    func testFetchPullRequests() async throws {
        let prs = try await service.fetchPullRequests(owner: "octocat", name: "Hello-World")

        XCTAssertFalse(prs.isEmpty)
        XCTAssertEqual(prs[0].state, "open")
    }

    func testRateLimitHandling() async throws {
        // Simulate rate limit
        for _ in 0..<10 {
            _ = try? await service.fetchRepository(owner: "octocat", name: "Hello-World")
        }

        // Should handle rate limiting gracefully
    }
}

class MockOAuthManager: OAuthManager {
    var mockToken: Token?

    override func refreshToken(for provider: AuthProvider) async throws -> Token {
        guard let token = mockToken else {
            throw AuthError.noTokenFound
        }
        return token
    }
}
```

## 4. Integration Testing

### 4.1 Repository Integration Tests

```swift
class RepositoryIntegrationTests: XCTestCase {
    var repositoryService: RepositoryService!
    var codeAnalysisService: CodeAnalysisService!
    var dependencyGraphManager: DependencyGraphManager!

    override func setUp() {
        super.setUp()

        repositoryService = LibGit2RepositoryService()
        codeAnalysisService = TreeSitterAnalysisService()
        dependencyGraphManager = DependencyGraphManager(
            codeAnalysisService: codeAnalysisService
        )
    }

    func testFullWorkflow() async throws {
        // 1. Clone repository
        let repoURL = URL(string: "https://github.com/example/test-repo")!
        let localPath = FileManager.default.temporaryDirectory.appendingPathComponent("test-repo")

        try await repositoryService.clone(repoURL, to: localPath)

        // 2. Parse files
        let files = try FileManager.default.contentsOfDirectory(at: localPath, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "js" }

        var parseResults: [ParseResult] = []

        for fileURL in files {
            let content = try String(contentsOf: fileURL)
            let file = CodeFile(path: fileURL.path, content: content, language: .javascript)

            let result = try await codeAnalysisService.parseFile(file)
            parseResults.append(result)
        }

        // 3. Build dependency graph
        let graph = dependencyGraphManager.buildGraph(from: parseResults)

        XCTAssertFalse(graph.nodes.isEmpty)
        XCTAssertFalse(graph.edges.isEmpty)

        // 4. Clean up
        try FileManager.default.removeItem(at: localPath)
    }
}
```

### 4.2 Collaboration Integration Tests

```swift
class CollaborationIntegrationTests: XCTestCase {
    var sessionManager: CollaborationManager!
    var syncService: SyncService!

    func testSessionCreation() async throws {
        let session = try await sessionManager.startSession()

        XCTAssertEqual(session.state, .active)
        XCTAssertTrue(session.participants.isEmpty)
    }

    func testParticipantJoin() async throws {
        let session = try await sessionManager.startSession()

        let participant = Participant(name: "Test User", isHost: false)
        try await sessionManager.addParticipant(participant, to: session)

        XCTAssertEqual(session.participants.count, 1)
    }

    func testStateSynchronization() async throws {
        let session = try await sessionManager.startSession()

        // Update state
        session.layoutType = "focus"
        session.openFileIDs = ["file1.js", "file2.js"]

        // Sync to CloudKit
        try await syncService.syncSessionState(session)

        // Fetch from CloudKit
        let fetchedSession = try await syncService.fetchLatestSessionState()

        XCTAssertEqual(fetchedSession.layoutType, "focus")
        XCTAssertEqual(fetchedSession.openFileIDs.count, 2)
    }
}
```

## 5. UI Testing

### 5.1 SwiftUI View Tests

```swift
class ViewTests: XCTestCase {
    func testCodeWindowViewRendering() {
        let file = CodeFile(
            path: "test.js",
            content: "function test() { return 42; }",
            language: .javascript
        )

        let view = CodeWindowView(
            file: file,
            scrollOffset: .constant(0),
            isFocused: .constant(false)
        )

        let hosting = UIHostingController(rootView: view)
        let snapshot = hosting.view.snapshot()

        // Assert snapshot matches reference
        // XCTAssertSnapshot(snapshot, reference: "code_window")
    }

    func testIssueCardExpansion() {
        let issue = Issue(
            number: 1,
            title: "Test Issue",
            severity: .major
        )

        let view = IssueCardView(issue: issue)

        // Test initial collapsed state
        // Test expansion on tap
        // Test action buttons
    }
}
```

### 5.2 Spatial Interaction Tests

```swift
class SpatialInteractionTests: XCTestCase {
    var arView: ARView!
    var spatialManager: SpatialManager!

    override func setUp() {
        super.setUp()

        arView = ARView(frame: CGRect(x: 0, y: 0, width: 800, height: 600))
        spatialManager = SpatialManager(arView: arView)
    }

    func testEntityTapGesture() {
        let codeWindow = CodeWindowEntity(
            file: CodeFile(path: "test.js", content: "", language: .javascript),
            position: SIMD3<Float>(0, 1.5, -2)
        )

        arView.scene.addAnchor(codeWindow)

        // Simulate tap
        let tapLocation = CGPoint(x: 400, y: 300)
        let gesture = UITapGestureRecognizer()

        // Verify focus behavior
        XCTAssertTrue(codeWindow.codeWindow.isFocused)
    }

    func testEntityDragGesture() {
        let initialPosition = SIMD3<Float>(0, 1.5, -2)

        let codeWindow = CodeWindowEntity(
            file: CodeFile(path: "test.js", content: "", language: .javascript),
            position: initialPosition
        )

        // Simulate drag
        let translation = SIMD3<Float>(0.5, 0, 0)

        // Apply drag
        codeWindow.position += translation

        XCTAssertEqual(codeWindow.position.x, initialPosition.x + translation.x)
    }
}
```

## 6. Performance Testing

### 6.1 Performance Benchmarks

```swift
class PerformanceBenchmarks: XCTestCase {
    func testParsingPerformance() throws {
        let files = generateTestFiles(count: 100, linesPerFile: 500)

        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            for file in files {
                _ = try? await parser.parseFile(file)
            }
        }
    }

    func testGraphLayoutPerformance() {
        let graph = generateLargeGraph(nodeCount: 100, edgeCount: 200)

        measure {
            let layout = ForceDirectedLayout()
            _ = layout.layout(graph: graph)
        }
    }

    func testRenderingPerformance() {
        let entities = generateEntities(count: 50)

        measure(metrics: [XCTClockMetric()]) {
            for entity in entities {
                arView.scene.addAnchor(entity)
            }

            // Force render
            arView.snapshot()
        }
    }
}
```

### 6.2 Memory Leak Tests

```swift
class MemoryLeakTests: XCTestCase {
    func testCodeWindowEntityLeak() {
        weak var weakEntity: CodeWindowEntity?

        autoreleasepool {
            let entity = CodeWindowEntity(
                file: CodeFile(path: "test.js", content: "", language: .javascript),
                position: .zero
            )

            weakEntity = entity

            arView.scene.addAnchor(entity)
            arView.scene.removeAnchor(entity)
        }

        XCTAssertNil(weakEntity, "CodeWindowEntity should be deallocated")
    }

    func testCollaborationSessionLeak() {
        weak var weakSession: CollaborationSession?

        autoreleasepool {
            let session = CollaborationSession(
                id: UUID(),
                state: .active,
                participants: [],
                host: Participant(name: "Host", isHost: true),
                repository: Repository(),
                branch: "main"
            )

            weakSession = session

            // Simulate session lifecycle
            session.state = .ended
        }

        XCTAssertNil(weakSession, "CollaborationSession should be deallocated")
    }
}
```

## 7. End-to-End Testing

### 7.1 Critical Path Tests

```swift
class E2ETests: XCTestCase {
    func testCompleteCodeReviewFlow() async throws {
        // 1. Launch app
        let app = XCUIApplication()
        app.launch()

        // 2. Authenticate with GitHub
        let authButton = app.buttons["Connect GitHub"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5))
        authButton.tap()

        // Wait for OAuth flow
        sleep(3)

        // 3. Select repository
        let repoList = app.collectionViews["Repository List"]
        XCTAssertTrue(repoList.waitForExistence(timeout: 10))

        let firstRepo = repoList.cells.firstMatch
        firstRepo.tap()

        // 4. Select pull request
        let prList = app.collectionViews["Pull Request List"]
        XCTAssertTrue(prList.waitForExistence(timeout: 10))

        let firstPR = prList.cells.firstMatch
        firstPR.tap()

        // 5. Wait for 3D view to load
        sleep(5)

        // 6. Interact with code
        let codeSpace = app.otherElements["Code Space"]
        XCTAssertTrue(codeSpace.exists)

        // 7. Add comment
        let commentButton = app.buttons["Add Comment"]
        commentButton.tap()

        let commentField = app.textFields["Comment Field"]
        commentField.tap()
        commentField.typeText("This looks good!")

        let submitButton = app.buttons["Submit Comment"]
        submitButton.tap()

        // 8. Verify comment added
        XCTAssertTrue(app.staticTexts["This looks good!"].waitForExistence(timeout: 5))
    }
}
```

## 8. Test Data Management

### 8.1 Test Fixtures

```swift
class TestFixtures {
    static func createMockRepository() -> Repository {
        Repository(
            name: "test-repo",
            url: URL(string: "https://github.com/test/repo")!,
            localPath: URL(fileURLWithPath: "/tmp/test-repo"),
            provider: .github
        )
    }

    static func createMockCodeFile(language: Language = .javascript) -> CodeFile {
        let content: String

        switch language {
        case .javascript:
            content = """
            function example() {
                return "Hello, World!";
            }
            """
        case .python:
            content = """
            def example():
                return "Hello, World!"
            """
        case .swift:
            content = """
            func example() -> String {
                return "Hello, World!"
            }
            """
        default:
            content = "// Example code"
        }

        return CodeFile(path: "test.\(language.rawValue)", content: content, language: language)
    }

    static func createMockPullRequest() -> PullRequest {
        PullRequest(
            number: 1,
            title: "Test PR",
            author: "testuser",
            remoteID: "1"
        )
    }
}
```

## 9. Continuous Integration

### 9.1 CI Pipeline

```yaml
# .github/workflows/test.yml
name: Test Suite

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v3

      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_15.0.app

      - name: Run Unit Tests
        run: xcodebuild test -scheme SpatialCodeReviewer -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

      - name: Generate Code Coverage
        run: xcodebuild test -scheme SpatialCodeReviewer -enableCodeCoverage YES

      - name: Upload Coverage
        uses: codecov/codecov-action@v3
```

## 10. Quality Gates

### 10.1 Pre-Commit Checks

- [ ] All unit tests pass
- [ ] Code coverage > 80%
- [ ] No SwiftLint warnings
- [ ] No memory leaks detected
- [ ] Performance benchmarks meet targets

### 10.2 Pre-Release Checks

- [ ] All integration tests pass
- [ ] UI tests pass on multiple devices
- [ ] E2E tests pass
- [ ] Security scan clean
- [ ] Performance regression tests pass
- [ ] Accessibility tests pass

## 11. References

- [System Architecture Document](./01-system-architecture.md)
- [Performance Optimization Strategy](./09-performance-optimization.md)
- XCTest Documentation
- XCUITest Best Practices

## 12. Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-11-24 | Engineering Team | Initial draft |
