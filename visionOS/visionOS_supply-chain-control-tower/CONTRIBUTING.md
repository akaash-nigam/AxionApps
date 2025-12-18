# Contributing to Supply Chain Control Tower

Thank you for your interest in contributing to the Supply Chain Control Tower for visionOS! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Environment](#development-environment)
- [Project Structure](#project-structure)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Pull Request Process](#pull-request-process)
- [Documentation](#documentation)
- [Getting Help](#getting-help)

---

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inspiring community for all. Please be respectful and professional in all interactions.

### Our Standards

- **Be respectful**: Treat everyone with respect and consideration
- **Be collaborative**: Work together to find the best solutions
- **Be constructive**: Provide helpful feedback and suggestions
- **Be inclusive**: Welcome newcomers and help them get started

---

## Getting Started

### Prerequisites

Before you begin, ensure you have:

- **macOS 14.0+** (Sonoma or later)
- **Xcode 16.0+** with visionOS SDK
- **Git** installed and configured
- **Apple Vision Pro** (device or simulator)
- Familiarity with Swift, SwiftUI, and RealityKit

### Fork and Clone

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/visionOS_supply-chain-control-tower.git
   cd visionOS_supply-chain-control-tower
   ```

3. **Add upstream remote**:
   ```bash
   git remote add upstream https://github.com/ORIGINAL_OWNER/visionOS_supply-chain-control-tower.git
   ```

4. **Verify remotes**:
   ```bash
   git remote -v
   ```

---

## Development Environment

### Xcode Setup

1. Open the project in Xcode:
   ```bash
   cd SupplyChainControlTower
   open SupplyChainControlTowerApp.swift
   ```

2. Select your development team in **Signing & Capabilities**

3. Choose a simulator or connected Vision Pro device

4. Build and run (⌘R)

### Required Tools

Install development tools:

```bash
# SwiftLint (code quality)
brew install swiftlint

# Swift-format (code formatting)
brew install swift-format

# Git hooks (optional but recommended)
brew install pre-commit
```

### IDE Configuration

**Recommended Xcode Settings**:
- Editor → Indent: 4 spaces
- Editor → Trim Trailing Whitespace: ON
- Editor → Include Whitespace-Only Lines: OFF
- Text Editing → Show: Line numbers, Code folding ribbon

---

## Project Structure

```
SupplyChainControlTower/
├── App/                      # App entry point
│   └── SupplyChainControlTowerApp.swift
├── Models/                   # Data models
│   └── DataModels.swift
├── Views/                    # UI components
│   ├── Windows/              # 2D windows
│   ├── Volumes/              # 3D volumes
│   └── ImmersiveViews/       # Immersive spaces
├── ViewModels/               # Business logic
│   ├── DashboardViewModel.swift
│   ├── AlertsViewModel.swift
│   ├── ControlPanelViewModel.swift
│   ├── InventoryViewModel.swift
│   ├── FlowViewModel.swift
│   └── NetworkVisualizationViewModel.swift
├── Services/                 # API & data services
│   └── NetworkService.swift
├── Utilities/                # Helper functions
├── Resources/                # Assets, 3D models
└── Tests/                    # Unit & integration tests
```

---

## Development Workflow

### Branching Strategy

We use **Git Flow** workflow:

- **main**: Production-ready code
- **develop**: Integration branch for features
- **feature/**: Feature branches (`feature/add-predictive-alerts`)
- **bugfix/**: Bug fix branches (`bugfix/fix-globe-rendering`)
- **hotfix/**: Urgent production fixes (`hotfix/crash-on-launch`)

### Creating a Feature Branch

1. **Update develop**:
   ```bash
   git checkout develop
   git pull upstream develop
   ```

2. **Create feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make changes** and commit regularly:
   ```bash
   git add .
   git commit -m "feat: add shipment tracking view"
   ```

4. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

### Commit Message Convention

We follow **Conventional Commits** specification:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style/formatting
- `refactor`: Code refactoring
- `test`: Adding/updating tests
- `chore`: Build/tooling changes
- `perf`: Performance improvements

**Examples**:
```bash
feat(dashboard): add real-time KPI updates
fix(globe): correct coordinate conversion for southern hemisphere
docs(readme): update installation instructions
test(viewmodels): add tests for AlertsViewModel
```

---

## Coding Standards

### Swift Style Guide

Follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/) and our [CODE_STYLE.md](CODE_STYLE.md).

**Key Principles**:
- Use clear, descriptive names
- Prefer `let` over `var` when possible
- Use type inference where appropriate
- Add documentation comments for public APIs
- Keep functions focused and small
- Use `guard` for early returns

**Example**:
```swift
/// Calculates the distance between two geographic coordinates
/// - Parameters:
///   - from: Starting coordinate
///   - to: Destination coordinate
/// - Returns: Distance in kilometers
func distance(from: GeographicCoordinate, to: GeographicCoordinate) -> Double {
    guard from != to else { return 0 }

    // Haversine formula implementation
    // ...
}
```

### SwiftLint Compliance

Run SwiftLint before committing:

```bash
cd SupplyChainControlTower
swiftlint lint
```

Auto-fix issues:
```bash
swiftlint lint --fix
```

### Modern Swift Practices

- **Use async/await** for asynchronous code
- **Use actors** for thread-safe shared state
- **Use `@Observable`** for reactive state
- **Avoid force unwrapping** (use optional binding)
- **Avoid force casting** (use conditional casting)

**Good**:
```swift
@Observable
class DashboardViewModel {
    var network: SupplyChainNetwork?

    func loadNetwork() async {
        do {
            network = try await networkService.fetchNetwork()
        } catch {
            handleError(error)
        }
    }
}
```

**Bad**:
```swift
class DashboardViewModel {
    var network: SupplyChainNetwork!

    func loadNetwork() {
        networkService.fetchNetwork { result in
            self.network = try! result.get()
        }
    }
}
```

---

## Testing Guidelines

### Test Requirements

- **New features**: Must include tests (80%+ coverage)
- **Bug fixes**: Must include regression tests
- **Refactoring**: Existing tests must pass
- **Public APIs**: Must have comprehensive tests

### Writing Tests

Use the Swift Testing framework:

```swift
import Testing
@testable import SupplyChainControlTower

@Suite("Feature Tests")
struct FeatureTests {

    @Test("Feature behaves correctly")
    func testFeature() async throws {
        // Arrange
        let sut = FeatureUnderTest()

        // Act
        let result = await sut.performAction()

        // Assert
        #expect(result == expectedValue)
    }
}
```

### Running Tests

```bash
# All tests
swift test

# Specific suite
swift test --filter DataModelsTests

# With coverage
xcodebuild test \
  -scheme SupplyChainControlTower \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -enableCodeCoverage YES
```

### Test Organization

- **Unit Tests**: Test individual components
- **Integration Tests**: Test component interactions
- **Performance Tests**: Validate performance targets
- **UI Tests**: Test user interface (requires visionOS)

---

## Pull Request Process

### Before Submitting

1. **Update from upstream**:
   ```bash
   git fetch upstream
   git rebase upstream/develop
   ```

2. **Run tests**:
   ```bash
   swift test
   ```

3. **Run linter**:
   ```bash
   swiftlint lint
   ```

4. **Build successfully**:
   ```bash
   xcodebuild build -scheme SupplyChainControlTower
   ```

### Creating a Pull Request

1. **Push your branch** to your fork

2. **Open a Pull Request** on GitHub

3. **Fill out the PR template**:
   - Description of changes
   - Related issues
   - Testing performed
   - Screenshots/videos (for UI changes)

4. **Request reviews** from maintainers

### PR Requirements

- ✅ All tests pass
- ✅ Code coverage ≥ 80%
- ✅ SwiftLint passes with no errors
- ✅ Documentation updated
- ✅ CHANGELOG.md updated (for significant changes)
- ✅ Approved by at least 1 maintainer

### Review Process

1. **Automated checks** run (tests, lint, build)
2. **Code review** by maintainers
3. **Requested changes** addressed
4. **Approval** and merge

---

## Documentation

### Code Documentation

Add documentation comments for:
- Public classes and structs
- Public functions and methods
- Complex algorithms
- Non-obvious code

**Example**:
```swift
/// Manages real-time disruption alerts and predictions
///
/// AlertsViewModel handles:
/// - Loading and filtering disruptions
/// - Sorting by severity and impact
/// - Dismissing alerts
/// - Accepting/rejecting recommendations
@Observable
@MainActor
class AlertsViewModel {
    // ...
}
```

### Updating Documentation

When making changes, update:
- Code comments
- README.md (if adding features)
- ARCHITECTURE.md (if changing architecture)
- TESTING.md (if adding new test patterns)
- API_INTEGRATION.md (if changing APIs)

---

## Getting Help

### Resources

- **Documentation**: See `/docs` folder
- **Architecture**: [ARCHITECTURE.md](ARCHITECTURE.md)
- **Testing Guide**: [SupplyChainControlTower/TESTING.md](SupplyChainControlTower/TESTING.md)
- **API Guide**: [API_INTEGRATION.md](API_INTEGRATION.md)

### Communication

- **GitHub Issues**: Report bugs or request features
- **GitHub Discussions**: Ask questions or discuss ideas
- **Pull Requests**: Submit code contributions

### Questions?

- Check existing [GitHub Issues](https://github.com/org/repo/issues)
- Search [GitHub Discussions](https://github.com/org/repo/discussions)
- Create a new issue if your question hasn't been answered

---

## Recognition

Contributors are recognized in:
- README.md contributors section
- Release notes
- Project documentation

Thank you for contributing to Supply Chain Control Tower! 🚀

---

*Last Updated: November 2025*
*Version: 1.0*
