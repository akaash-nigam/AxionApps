# Contributing to Mystery Investigation

Thank you for your interest in contributing to Mystery Investigation! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Testing Requirements](#testing-requirements)
- [Documentation](#documentation)

---

## Code of Conduct

This project adheres to a Code of Conduct that all contributors are expected to follow. Please read [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) before contributing.

---

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce** the issue
- **Expected behavior** vs actual behavior
- **Screenshots or videos** if applicable
- **Environment details:**
  - visionOS version
  - Device (Vision Pro model)
  - App version
  - Xcode version (if development bug)

**Bug Report Template:**
```markdown
**Description:**
Clear description of the bug

**Steps to Reproduce:**
1. Launch app
2. Navigate to...
3. Perform action...
4. Observe error

**Expected Behavior:**
What should happen

**Actual Behavior:**
What actually happens

**Environment:**
- visionOS: 2.0
- Device: Apple Vision Pro
- App Version: 1.0.0

**Screenshots:**
[Attach screenshots]
```

### Suggesting Features

Feature suggestions are welcome! Please include:

- **Clear use case** - Why is this feature needed?
- **User benefit** - How does this improve the experience?
- **Implementation ideas** - Any thoughts on how to build it?
- **Mockups or examples** - Visual aids are helpful

### Contributing Code

1. **Fork the repository**
2. **Create a feature branch** from `main`
3. **Make your changes** following our coding standards
4. **Write or update tests** for your changes
5. **Update documentation** as needed
6. **Submit a pull request**

### Contributing Cases

We welcome community-created detective cases!

- Cases must be original content or properly licensed
- Follow the case schema in `docs/CASE_SCHEMA.md`
- Include all required evidence and suspect data
- Provide a complete solution with explanation
- Test the case thoroughly before submission

### Improving Documentation

- Fix typos and grammatical errors
- Clarify confusing sections
- Add missing information
- Improve code examples
- Translate to other languages

### Creating Assets

- 3D models for evidence
- Suspect character models
- Environment textures
- Sound effects and music
- UI icons and graphics

**Asset Guidelines:**
- Follow technical specs in `TECHNICAL_SPEC.md`
- Optimize for performance (polygon count, texture size)
- Use appropriate file formats
- Include source files when possible

---

## Development Setup

### Prerequisites

- macOS 14.0 (Sonoma) or later
- Xcode 16.0 or later with visionOS SDK
- Apple Developer account
- Git installed
- Apple Vision Pro (for device testing)

### Initial Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/visionOS_Gaming_mystery-investigation.git
cd visionOS_Gaming_mystery-investigation

# Add upstream remote
git remote add upstream https://github.com/[org]/visionOS_Gaming_mystery-investigation.git

# Open project in Xcode
cd MysteryInvestigation
open MysteryInvestigation.xcodeproj
```

### Keeping Your Fork Updated

```bash
# Fetch upstream changes
git fetch upstream

# Merge upstream main into your local main
git checkout main
git merge upstream/main

# Push updates to your fork
git push origin main
```

---

## Coding Standards

### Swift Style Guide

We follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/) with these additional rules:

**Naming Conventions:**
```swift
// Classes: PascalCase
class EvidenceManager { }

// Functions and variables: camelCase
func discoverEvidence() { }
let evidenceCount = 10

// Constants: camelCase with descriptive names
let maximumHints = 5

// Enums: PascalCase for type, camelCase for cases
enum EvidenceType {
    case fingerprint
    case bloodSample
    case weaponEvidence
}
```

**Code Organization:**
```swift
// MARK: - Properties
// Group related properties

// MARK: - Initialization
// Initializers

// MARK: - Public Methods
// Public API

// MARK: - Private Methods
// Internal helpers
```

**Documentation:**
```swift
/// Discovers evidence at the specified location
///
/// - Parameters:
///   - location: The spatial anchor where evidence is found
///   - type: The type of evidence being discovered
/// - Returns: The discovered Evidence object, or nil if already found
func discoverEvidence(at location: SpatialAnchor, type: EvidenceType) -> Evidence? {
    // Implementation
}
```

### SwiftUI Best Practices

- Use `@Observable` for state management (Swift 6.0)
- Prefer composition over complex views
- Extract reusable components
- Keep views focused on presentation
- Business logic belongs in managers/coordinators

```swift
// Good: Focused view
struct EvidenceCardView: View {
    let evidence: Evidence

    var body: some View {
        VStack {
            Image(evidence.iconName)
            Text(evidence.name)
        }
    }
}

// Bad: View with business logic
struct EvidenceCardView: View {
    @State private var isAnalyzed = false

    var body: some View {
        VStack {
            // Don't put analysis logic here
        }
        .onAppear {
            performForensicAnalysis() // NO
        }
    }
}
```

### RealityKit Best Practices

- Pool and reuse entities when possible
- Dispose of unused resources promptly
- Use LOD (Level of Detail) for complex models
- Optimize texture sizes
- Batch entity updates

### Performance Guidelines

- Target 90 FPS average, 60 FPS minimum
- Keep memory usage under 500 MB
- Profile regularly with Instruments
- Optimize hot paths
- Use async/await for concurrent work

---

## Commit Guidelines

### Commit Message Format

```
<type>: <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, no logic change)
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `test`: Adding or updating tests
- `chore`: Build process, dependencies, etc.

**Examples:**

```
feat: Add DNA analysis forensic tool

Implements DNA matching system that compares evidence samples to suspect
profiles. Includes visual representation of DNA sequences and match
percentage calculation.

Closes #123
```

```
fix: Correct hand tracking offset in evidence examination

The evidence manipulation was offset by 10cm due to incorrect anchor
positioning. This fixes the spatial anchor calculation to align with
the user's hand position.

Fixes #456
```

### Atomic Commits

- Each commit should represent a single logical change
- Commits should compile and pass tests
- Don't mix unrelated changes in one commit

---

## Pull Request Process

### Before Submitting

- [ ] Code follows our style guidelines
- [ ] All tests pass (`Cmd+U` in Xcode)
- [ ] New tests added for new functionality
- [ ] Documentation updated
- [ ] No merge conflicts with main branch
- [ ] Commit messages follow guidelines
- [ ] Performance benchmarks met (if applicable)

### PR Title Format

Use the same format as commit messages:
```
feat: Add new interrogation dialogue system
fix: Resolve crash when examining evidence
```

### PR Description Template

```markdown
## Description
Brief description of what this PR does

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
Describe testing performed:
- [ ] Unit tests added/updated
- [ ] Tested on visionOS Simulator
- [ ] Tested on Apple Vision Pro
- [ ] Performance tested

## Screenshots/Videos
[If applicable, add screenshots or videos]

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Tests pass
- [ ] No new warnings

## Related Issues
Closes #123
Related to #456
```

### Review Process

1. **Automated Checks** - CI runs tests and linters
2. **Code Review** - Maintainers review code quality
3. **Testing** - Reviewers test functionality
4. **Approval** - At least one maintainer approval required
5. **Merge** - Maintainer merges PR

### After PR is Merged

- Delete your feature branch
- Pull latest main to your fork
- Celebrate! 🎉

---

## Testing Requirements

### Unit Tests Required

All new code must include unit tests:

- **Data Models** - Test serialization, validation
- **Business Logic** - Test calculations, state changes
- **Managers** - Test public APIs

```swift
import XCTest
@testable import MysteryInvestigation

final class EvidenceManagerTests: XCTestCase {
    func testDiscoverEvidence() {
        let manager = EvidenceManager()
        let evidence = Evidence(type: .fingerprint, ...)

        manager.discoverEvidence(evidence)

        XCTAssertTrue(manager.discoveredEvidence.contains(evidence))
    }
}
```

### Integration Tests Recommended

For UI and complex workflows:

- Test navigation flows
- Test state persistence
- Test multi-component interactions

### Manual Testing Required

Before submitting PR, manually test on:

- **visionOS Simulator** - Basic functionality
- **Apple Vision Pro** (if available) - Full experience

### Performance Testing

For performance-critical changes:

- Profile with Instruments
- Measure FPS impact
- Check memory usage
- Verify thermal performance

---

## Documentation

### Code Documentation

Document all public APIs:

```swift
/// Manages the investigation process for a case
///
/// The `GameCoordinator` orchestrates all systems involved in solving
/// a mystery case, including evidence collection, suspect interrogation,
/// and solution validation.
@Observable
class GameCoordinator {
    /// The currently active case being investigated
    var activeCase: CaseData?

    /// Starts a new investigation
    /// - Parameter caseData: The case to investigate
    func startNewCase(_ caseData: CaseData) {
        // Implementation
    }
}
```

### Markdown Documentation

Update relevant docs when making changes:

- `README.md` - Major features or setup changes
- `ARCHITECTURE.md` - Architectural changes
- `TECHNICAL_SPEC.md` - Implementation details
- `DESIGN.md` - Game design changes

### Comments

Write comments for:

- Complex algorithms
- Non-obvious decisions
- Workarounds for platform limitations
- Performance optimizations

```swift
// Use a spatial anchor pool to avoid creating new anchors for each
// evidence item. ARKit has a limit of 1000 anchors per session, and
// creating/destroying anchors is expensive.
let anchor = anchorPool.acquire()
```

---

## Case Creation Guidelines

### Case Structure

Each case must include:

- **Narrative** - Compelling story with mystery
- **Suspects** - 3-5 suspects with motives
- **Evidence** - 10-15 pieces including red herrings
- **Solution** - Clear resolution with explanation
- **Difficulty Rating** - Appropriate complexity level

### Case JSON Schema

Follow the schema in `docs/CASE_SCHEMA.md`:

```json
{
  "id": "unique-case-id",
  "title": "The Missing Heirloom",
  "difficulty": "beginner",
  "suspects": [...],
  "evidence": [...],
  "solution": {...}
}
```

### Testing Your Case

- Solve it yourself multiple times
- Have others playtest it
- Verify all clues lead to solution
- Ensure red herrings are believable
- Check for logical consistency

---

## Getting Help

### Resources

- **Documentation:** `docs/` folder
- **Discord:** [Join our server](https://discord.gg/mystery-investigation)
- **Email:** dev@mysteryinvestigation.com
- **GitHub Issues:** Search existing issues first

### Questions

For questions about:

- **Code architecture** - Ask in GitHub Discussions
- **Bug reports** - Create an issue
- **Feature ideas** - Create a feature request
- **General help** - Join Discord

---

## Recognition

Contributors are recognized in:

- `CHANGELOG.md` - All contributions listed
- `README.md` - Special thanks section
- In-app credits (for major contributions)
- Social media shoutouts

---

## License

By contributing, you agree that your contributions will be licensed under the same proprietary license as the project. See [LICENSE](LICENSE) for details.

---

## Thank You!

Every contribution, no matter how small, makes Mystery Investigation better. We appreciate your time and effort! 🔍✨

For questions about contributing, reach out to dev@mysteryinvestigation.com
