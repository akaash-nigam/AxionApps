# Contributing to Living Building System

Thank you for your interest in contributing to Living Building System! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Process](#development-process)
- [Code Style](#code-style)
- [Testing Guidelines](#testing-guidelines)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Issue Guidelines](#issue-guidelines)

## Code of Conduct

This project adheres to a Code of Conduct that all contributors are expected to follow. By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

### Our Standards

- **Be respectful** of differing viewpoints and experiences
- **Be collaborative** and work together toward solutions
- **Be professional** in all interactions
- **Focus on what is best** for the community and the project
- **Show empathy** towards other community members

## Getting Started

### Prerequisites

- macOS 14.0 or later
- Xcode 15.2 or later
- Apple Vision Pro or visionOS Simulator
- Swift 6.0 or later
- Git

### Setting Up Your Development Environment

1. **Fork the repository**
   ```bash
   # Click the "Fork" button on GitHub
   ```

2. **Clone your fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/visionOS_Living-Building-System.git
   cd visionOS_Living-Building-System
   ```

3. **Add upstream remote**
   ```bash
   git remote add upstream https://github.com/ORIGINAL_OWNER/visionOS_Living-Building-System.git
   ```

4. **Install dependencies**
   ```bash
   brew install swiftlint
   brew install swift-format  # Optional
   ```

5. **Open the project in Xcode**
   ```bash
   cd LivingBuildingSystem
   open Package.swift
   ```

6. **Build the project**
   - Select "Living Building System" scheme
   - Choose "Apple Vision Pro" simulator
   - Press Cmd+B to build

### Project Structure

```
LivingBuildingSystem/
├── Sources/
│   └── LivingBuildingSystem/
│       ├── App/                    # App entry point
│       ├── Domain/                 # Business logic and models
│       ├── Application/            # Managers and business logic
│       ├── Integrations/           # External service integrations
│       ├── Presentation/           # UI layer
│       │   ├── WindowViews/        # Window-based views
│       │   └── ImmersiveViews/     # Immersive space views
│       └── Utilities/              # Helpers and utilities
├── Tests/                          # Test suite
└── docs/                           # Documentation

```

## Development Process

### Branching Strategy

We use a simplified Git Flow:

- `main` - Production-ready code
- `develop` - Development branch (if used)
- `feature/*` - New features
- `fix/*` - Bug fixes
- `docs/*` - Documentation updates
- `refactor/*` - Code refactoring

### Creating a Branch

```bash
# For new features
git checkout -b feature/your-feature-name

# For bug fixes
git checkout -b fix/issue-description

# For documentation
git checkout -b docs/what-you-are-documenting
```

### Keeping Your Fork Updated

```bash
# Fetch upstream changes
git fetch upstream

# Merge upstream/main into your main
git checkout main
git merge upstream/main

# Rebase your feature branch
git checkout feature/your-feature
git rebase main
```

## Code Style

### Swift Style Guide

We follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/) with some project-specific conventions:

#### Naming Conventions

- **Types**: PascalCase (`HomeViewController`, `EnergyReading`)
- **Variables/Functions**: camelCase (`deviceManager`, `calculateCost()`)
- **Constants**: camelCase (`maxRetryCount`, `defaultTimeout`)
- **Protocols**: Descriptive names, often ending in `Protocol` (`EnergyServiceProtocol`)

#### Code Organization

- Group related functionality with `// MARK: -` comments
- Keep functions focused and under 60 lines
- Limit file length to 500 lines (warning at 400)
- Use extensions to organize code by protocol conformance

#### Example

```swift
// MARK: - Initialization

init(appState: AppState, energyService: EnergyServiceProtocol) {
    self.appState = appState
    self.energyService = energyService
}

// MARK: - Public Methods

func loadEnergyData() async throws {
    let reading = try await energyService.getCurrentReading(type: .electricity)
    await updateState(with: reading)
}

// MARK: - Private Helpers

private func updateState(with reading: EnergyReading) async {
    // Implementation
}
```

### SwiftLint

All code must pass SwiftLint checks:

```bash
# Run SwiftLint
cd LivingBuildingSystem
swiftlint

# Auto-fix fixable violations
swiftlint --fix
```

### Important Rules

- ✅ **DO** use guard statements for early returns
- ✅ **DO** use meaningful variable names
- ✅ **DO** document public APIs with doc comments
- ✅ **DO** use Swift's type inference where appropriate
- ❌ **DON'T** use force unwrapping (`!`) in production code
- ❌ **DON'T** use `print()` statements (use `Logger` instead)
- ❌ **DON'T** leave commented-out code
- ❌ **DON'T** commit TODOs without assignees: `// TODO(username): description`

## Testing Guidelines

### Test Coverage Requirements

- **Minimum**: 80% code coverage
- **Models**: 90%+ coverage
- **Managers**: 85%+ coverage
- **UI**: 60%+ coverage (focus on critical paths)

### Writing Tests

#### Unit Tests

```swift
import XCTest
@testable import LivingBuildingSystem

final class EnergyReadingTests: XCTestCase {

    func testElectricityCostCalculation() {
        // Given
        let reading = EnergyReading(timestamp: Date(), energyType: .electricity)
        reading.cumulativeConsumption = 100.0

        let config = EnergyConfiguration()
        config.electricityRatePerKWh = 0.15

        // When
        let cost = reading.calculateCost(configuration: config)

        // Then
        XCTAssertEqual(cost, 15.0, accuracy: 0.01)
    }
}
```

#### Integration Tests

```swift
func testEnergyServiceMonitoring() async throws {
    // Given
    let service = EnergyService()
    try await service.connect(apiIdentifier: "test-001")

    let expectation = XCTestExpectation(description: "Receive reading")
    var receivedReading: EnergyReading?

    await service.setUpdateHandler { reading in
        receivedReading = reading
        expectation.fulfill()
    }

    // When
    try await service.startMonitoring()

    // Then
    await fulfillment(of: [expectation], timeout: 10.0)
    XCTAssertNotNil(receivedReading)
}
```

### Running Tests

```bash
# Run all tests
xcodebuild test -scheme LivingBuildingSystem \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

# Run specific test
xcodebuild test -scheme LivingBuildingSystem \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:LivingBuildingSystemTests/EnergyReadingTests

# Generate coverage report
xcodebuild test -scheme LivingBuildingSystem \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -enableCodeCoverage YES
```

## Commit Guidelines

We follow [Conventional Commits](https://www.conventionalcommits.org/):

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
- `ci`: CI/CD changes

### Examples

```bash
# Feature
git commit -m "feat(energy): add solar generation monitoring"

# Bug fix
git commit -m "fix(devices): resolve device discovery crash on iOS"

# Documentation
git commit -m "docs(readme): update installation instructions"

# With body
git commit -m "feat(spatial): implement look-to-control interaction

Add gaze detection for device highlighting
Implement air tap gesture for device control
Add haptic feedback on interaction

Closes #123"
```

### Best Practices

- Use imperative mood ("add feature" not "added feature")
- Keep subject line under 72 characters
- Capitalize first letter of subject
- Don't end subject with a period
- Include ticket/issue number in footer
- Explain *what* and *why*, not *how*

## Pull Request Process

### Before Submitting

1. **Update your branch**
   ```bash
   git checkout main
   git pull upstream main
   git checkout your-branch
   git rebase main
   ```

2. **Run tests**
   ```bash
   xcodebuild test -scheme LivingBuildingSystem
   ```

3. **Run SwiftLint**
   ```bash
   swiftlint
   ```

4. **Update documentation**
   - Update README if needed
   - Add/update inline documentation
   - Update CHANGELOG.md

5. **Self-review**
   - Review your own changes
   - Remove debug code
   - Check for TODO comments
   - Verify no sensitive data

### Submitting a Pull Request

1. **Push your branch**
   ```bash
   git push origin your-branch
   ```

2. **Create PR on GitHub**
   - Use the PR template
   - Fill out all sections
   - Add screenshots/videos if applicable
   - Link related issues

3. **Address review feedback**
   - Respond to all comments
   - Push updates to the same branch
   - Re-request review when ready

### PR Review Criteria

Your PR will be reviewed for:

- ✅ Code quality and style
- ✅ Test coverage
- ✅ Documentation completeness
- ✅ Performance impact
- ✅ Security considerations
- ✅ Breaking changes (if any)
- ✅ CI/CD passing

### Merging

- PRs require at least one approval
- All CI checks must pass
- No unresolved conversations
- Branch must be up to date with main
- Squash and merge is preferred

## Issue Guidelines

### Creating Issues

Use the appropriate issue template:

- **Bug Report**: For reporting bugs
- **Feature Request**: For suggesting features
- **Question**: For asking questions (use Discussions instead)

### Issue Lifecycle

1. **Triage**: Maintainers review and label
2. **Discussion**: Community discusses approach
3. **Assigned**: Developer picks up the issue
4. **In Progress**: Work begins
5. **Review**: PR under review
6. **Closed**: Issue resolved or declined

### Labels

- `bug`: Something isn't working
- `enhancement`: New feature or request
- `documentation`: Documentation improvements
- `good first issue`: Good for newcomers
- `help wanted`: Extra attention needed
- `priority: high`: High priority
- `priority: low`: Low priority
- `wontfix`: This will not be worked on

## Development Tips

### Debugging

- Use `Logger.shared.log()` instead of `print()`
- Set breakpoints in Xcode
- Use Instruments for performance profiling
- Check console for warnings

### Common Issues

**Issue**: Build fails with "Cannot find type"
**Solution**: Clean build folder (Shift+Cmd+K) and rebuild

**Issue**: SwiftLint warnings
**Solution**: Run `swiftlint --fix` to auto-fix

**Issue**: Tests failing on CI but passing locally
**Solution**: Ensure dependencies are committed, check CI logs

### Resources

- [Swift Documentation](https://swift.org/documentation/)
- [visionOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/visionos)
- [HomeKit Documentation](https://developer.apple.com/documentation/homekit)
- [Project Wiki](wiki-link)

## Questions?

- **GitHub Discussions**: For questions and general discussion
- **Issues**: For bugs and feature requests
- **Email**: For private inquiries

## Recognition

Contributors are recognized in:

- CONTRIBUTORS.md file
- Release notes
- Project README

Thank you for contributing to Living Building System! 🏠✨
