# Contributing to AI Agent Coordinator

Thank you for your interest in contributing to AI Agent Coordinator! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
3. [Development Setup](#development-setup)
4. [How to Contribute](#how-to-contribute)
5. [Coding Standards](#coding-standards)
6. [Commit Guidelines](#commit-guidelines)
7. [Pull Request Process](#pull-request-process)
8. [Testing Requirements](#testing-requirements)
9. [Documentation](#documentation)
10. [Community](#community)

---

## Code of Conduct

This project adheres to a Code of Conduct that all contributors are expected to follow. Please read [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) before contributing.

### Our Pledge

We are committed to providing a welcoming and inclusive experience for everyone, regardless of:
- Gender identity and expression
- Sexual orientation
- Disability
- Physical appearance
- Age
- Race or ethnicity
- Religion or belief system
- Experience level

---

## Getting Started

### Prerequisites

Before you begin, ensure you have:
- **macOS 14.0 (Sonoma) or later**
- **Xcode 16.0 or later** with visionOS SDK
- **Vision Pro device or simulator**
- **Swift 6.0 knowledge**
- **Git** installed and configured

### Finding Issues to Work On

Good first issues are labeled with:
- `good first issue` - Beginner-friendly tasks
- `help wanted` - Issues where we need assistance
- `documentation` - Documentation improvements
- `bug` - Bug fixes needed

Browse [open issues](https://github.com/yourusername/visionOS_ai-agent-coordinator/issues) to find something that interests you.

---

## Development Setup

### 1. Fork and Clone

```bash
# Fork the repository on GitHub, then clone your fork
git clone https://github.com/YOUR_USERNAME/visionOS_ai-agent-coordinator.git
cd visionOS_ai-agent-coordinator

# Add upstream remote
git remote add upstream https://github.com/ORIGINAL_OWNER/visionOS_ai-agent-coordinator.git
```

### 2. Install Dependencies

```bash
# Swift Package Manager will automatically resolve dependencies
# when you open the project in Xcode

# Open the project
open AIAgentCoordinator.xcodeproj
```

### 3. Configure Xcode

1. **Select your Team**: Xcode > Settings > Accounts
2. **Choose Simulator or Device**: Product > Destination > Vision Pro
3. **Build the Project**: Cmd + B

### 4. Run Tests

```bash
# From Xcode
Cmd + U

# Or from command line
xcodebuild test -scheme AIAgentCoordinator -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

### 5. Run the App

```bash
# From Xcode
Cmd + R

# The app will launch in Vision Pro simulator or device
```

---

## How to Contribute

### Reporting Bugs

Before creating a bug report:
1. **Search existing issues** to avoid duplicates
2. **Use the latest version** to verify the bug still exists
3. **Collect relevant information** (version, OS, steps to reproduce)

When creating a bug report, include:
```markdown
**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
A clear description of what you expected to happen.

**Screenshots**
If applicable, add screenshots or screen recordings.

**Environment:**
- Vision Pro Model: [e.g., AVP1]
- visionOS Version: [e.g., 2.0]
- App Version: [e.g., 1.0.0]

**Additional context**
Add any other context about the problem here.
```

### Suggesting Enhancements

Enhancement suggestions are welcome! Please:
1. **Check existing feature requests** first
2. **Provide clear use cases**
3. **Explain the expected behavior**
4. **Consider implementation complexity**

### Contributing Code

1. **Create a Branch**
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   ```

2. **Make Your Changes**
   - Follow coding standards (see below)
   - Add tests for new functionality
   - Update documentation as needed

3. **Test Your Changes**
   ```bash
   # Run all tests
   xcodebuild test -scheme AIAgentCoordinator

   # Run specific test
   xcodebuild test -scheme AIAgentCoordinator -only-testing:AIAgentCoordinatorTests/YourTestClass
   ```

4. **Commit Your Changes**
   ```bash
   git add .
   git commit -m "feat: add amazing new feature"
   ```

5. **Push to Your Fork**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create Pull Request**
   - Go to GitHub and create a PR from your fork
   - Fill out the PR template completely
   - Link related issues

---

## Coding Standards

### Swift Style Guide

We follow the [Swift Style Guide](SWIFT_STYLE_GUIDE.md). Key points:

#### Naming Conventions

```swift
// Types: UpperCamelCase
class AgentCoordinator { }
struct AgentMetrics { }
enum AgentStatus { }

// Functions and variables: lowerCamelCase
func loadAgents() { }
var agentCount: Int = 0
let maxConcurrency = 10

// Constants: lowerCamelCase
let maxRetries = 3
private let defaultTimeout: TimeInterval = 30

// Booleans: Use is/has/should prefix
var isConnected: Bool
var hasError: Bool
var shouldRetry: Bool
```

#### Code Organization

```swift
// MARK: - Type Definition
class AgentCoordinator {

    // MARK: - Properties

    // Public properties first
    var agents: [UUID: AIAgent] = [:]

    // Private properties
    private let repository: AgentRepository
    private var cache: NSCache<NSUUID, AIAgent>

    // MARK: - Initialization

    init(repository: AgentRepository) {
        self.repository = repository
        self.cache = NSCache()
    }

    // MARK: - Public Methods

    func loadAgents() async throws -> [AIAgent] {
        // Implementation
    }

    // MARK: - Private Methods

    private func validateAgent(_ agent: AIAgent) -> Bool {
        // Implementation
    }
}
```

#### Documentation

All public APIs must have documentation comments:

```swift
/// Loads all agents from the repository and updates the cache.
///
/// This method fetches agents from both local storage and remote sources,
/// merging the results and updating the in-memory cache.
///
/// - Returns: An array of all available agents
/// - Throws: `AgentError.loadFailed` if the operation fails
///
/// # Example
/// ```swift
/// let agents = try await coordinator.loadAgents()
/// print("Loaded \(agents.count) agents")
/// ```
func loadAgents() async throws -> [AIAgent] {
    // Implementation
}
```

#### Error Handling

```swift
// Good: Specific error types
enum AgentError: Error {
    case notFound(UUID)
    case invalidConfiguration(String)
    case networkError(Error)
}

// Use do-catch for error handling
do {
    let agent = try await repository.fetch(id: agentId)
    return agent
} catch let error as RepositoryError {
    throw AgentError.notFound(agentId)
} catch {
    throw AgentError.networkError(error)
}
```

#### Async/Await

```swift
// Always use async/await for asynchronous operations
func loadData() async throws {
    let agents = try await coordinator.loadAgents()
    let metrics = try await metricsCollector.getLatestMetrics(agentId: agents[0].id)
}

// Use Task for concurrent operations
async let agents = coordinator.loadAgents()
async let metrics = metricsCollector.getAllMetrics()

let (loadedAgents, loadedMetrics) = await (try agents, try metrics)
```

#### SwiftUI

```swift
// Use Observable for view models
@Observable
class AgentViewModel {
    var agents: [AIAgent] = []
    var isLoading = false
}

// Keep views focused and small
struct AgentListView: View {
    @Environment(AppModel.self) var appModel

    var body: some View {
        List(appModel.agents) { agent in
            AgentRow(agent: agent)
        }
    }
}

// Extract subviews for clarity
struct AgentRow: View {
    let agent: AIAgent

    var body: some View {
        HStack {
            AgentIcon(type: agent.type)
            Text(agent.name)
            Spacer()
            AgentStatusIndicator(status: agent.status)
        }
    }
}
```

### Testing Standards

```swift
// Use descriptive test names
func testAgentCoordinator_whenLoadingAgents_returnsAllAgents() async throws {
    // Given
    let coordinator = AgentCoordinator(repository: mockRepository)

    // When
    let agents = try await coordinator.loadAgents()

    // Then
    XCTAssertEqual(agents.count, 5)
    XCTAssertTrue(agents.allSatisfy { $0.status != .terminated })
}

// Test error conditions
func testAgentCoordinator_whenRepositoryFails_throwsError() async {
    // Given
    let failingRepository = FailingMockRepository()
    let coordinator = AgentCoordinator(repository: failingRepository)

    // When/Then
    do {
        _ = try await coordinator.loadAgents()
        XCTFail("Should have thrown an error")
    } catch {
        XCTAssertTrue(error is AgentError)
    }
}
```

---

## Commit Guidelines

We follow [Conventional Commits](https://www.conventionalcommits.org/).

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, no logic change)
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Examples

```bash
# Feature
git commit -m "feat(visualization): add performance landscape view"

# Bug fix
git commit -m "fix(metrics): correct CPU usage calculation"

# Documentation
git commit -m "docs(api): update AgentCoordinator documentation"

# Refactoring
git commit -m "refactor(repository): simplify agent fetching logic"

# Breaking change
git commit -m "feat(api)!: change loadAgents return type

BREAKING CHANGE: loadAgents now returns Result<[AIAgent], Error> instead of throwing"
```

### Commit Message Body

Provide context and reasoning:

```
feat(collaboration): add SharePlay integration

Implemented SharePlay support for real-time collaboration:
- Added CollaborationManager service
- Created shared workspace synchronization
- Implemented participant tracking
- Added spatial audio for voice chat

This enables multiple users to view and interact with
the same agent network simultaneously.

Closes #123
```

---

## Pull Request Process

### Before Submitting

- [ ] Code follows the style guide
- [ ] All tests pass (`xcodebuild test`)
- [ ] New tests added for new features
- [ ] Documentation updated
- [ ] No compiler warnings
- [ ] Commit messages follow conventions
- [ ] Branch is up to date with main

### PR Template

When creating a PR, fill out the template:

```markdown
## Description
Brief description of the changes.

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## How Has This Been Tested?
Describe the tests you ran and how to reproduce.

## Checklist
- [ ] My code follows the style guidelines
- [ ] I have performed a self-review
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally
- [ ] Any dependent changes have been merged and published

## Screenshots (if applicable)
Add screenshots or screen recordings.

## Related Issues
Closes #issue_number
```

### Review Process

1. **Automated Checks**: CI/CD runs tests and linting
2. **Code Review**: At least one maintainer reviews
3. **Feedback**: Address review comments
4. **Approval**: Maintainer approves the PR
5. **Merge**: Maintainer merges (usually squash merge)

### After Merge

- Delete your branch
- Update your local repository:
  ```bash
  git checkout main
  git pull upstream main
  ```

---

## Testing Requirements

### Test Coverage

- **Unit Tests**: Required for all new services and utilities
- **Integration Tests**: Required for platform adapters
- **UI Tests**: Recommended for critical user flows
- **Minimum Coverage**: 80% for new code

### Writing Tests

```swift
import XCTest
@testable import AIAgentCoordinator

final class AgentCoordinatorTests: XCTestCase {
    var sut: AgentCoordinator!
    var mockRepository: MockAgentRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockAgentRepository()
        sut = AgentCoordinator(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    func testLoadAgents_whenSuccessful_returnsAgents() async throws {
        // Given
        let expectedAgents = [
            AIAgent(name: "Test1", type: .llm),
            AIAgent(name: "Test2", type: .autonomous)
        ]
        mockRepository.agentsToReturn = expectedAgents

        // When
        let agents = try await sut.loadAgents()

        // Then
        XCTAssertEqual(agents.count, 2)
        XCTAssertEqual(agents[0].name, "Test1")
    }
}
```

### Running Tests

```bash
# All tests
xcodebuild test -scheme AIAgentCoordinator

# Specific test class
xcodebuild test -scheme AIAgentCoordinator \
  -only-testing:AIAgentCoordinatorTests/AgentCoordinatorTests

# With code coverage
xcodebuild test -scheme AIAgentCoordinator -enableCodeCoverage YES
```

---

## Documentation

### Code Documentation

- All public APIs must have doc comments
- Use `///` for documentation comments
- Include examples where helpful
- Document parameters, returns, and throws

### README Updates

Update README.md if your change:
- Adds new features
- Changes installation process
- Modifies usage instructions
- Adds new dependencies

### Architecture Documentation

Update ARCHITECTURE.md if you:
- Add new services or layers
- Modify data models
- Change system interactions
- Introduce new patterns

---

## Community

### Getting Help

- **GitHub Discussions**: For questions and discussions
- **GitHub Issues**: For bug reports and feature requests
- **Email**: contribute@aiagentcoordinator.dev

### Recognition

Contributors are recognized in:
- CHANGELOG.md for each release
- Contributors page in documentation
- GitHub contributors graph

### Maintainers

Current maintainers:
- @maintainer1 - Lead maintainer
- @maintainer2 - Core contributor
- @maintainer3 - Documentation lead

---

## Additional Resources

- [Swift Style Guide](SWIFT_STYLE_GUIDE.md)
- [Architecture Documentation](ARCHITECTURE.md)
- [Technical Specifications](TECHNICAL_SPEC.md)
- [API Reference](API_REFERENCE.md)
- [Testing Strategy](TESTING_STRATEGY.md)

---

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (see LICENSE file).

---

**Thank you for contributing to AI Agent Coordinator!**

Your contributions help make this tool better for everyone. We appreciate your time and effort!

Questions? Email contribute@aiagentcoordinator.dev
