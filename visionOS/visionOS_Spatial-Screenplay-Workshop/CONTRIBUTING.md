# Contributing to Spatial Screenplay Workshop

Thank you for your interest in contributing! We welcome contributions from the community and are grateful for your support.

## 📜 Code of Conduct

This project adheres to a [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to conduct@spatialscreenplay.app.

## 🎯 How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the [existing issues](https://github.com/yourusername/visionOS_Spatial-Screenplay-Workshop/issues) to avoid duplicates.

When creating a bug report, include:
- Clear description of the issue
- Steps to reproduce
- Expected vs actual behavior
- Environment details (visionOS version, device type)
- Screenshots or recordings if applicable

Use the [bug report template](.github/ISSUE_TEMPLATE/bug_report.md).

### Suggesting Features

Feature suggestions are tracked as GitHub issues. When creating a feature request:
- Use a clear, descriptive title
- Provide detailed description of the proposed feature
- Explain why this feature would be useful
- Include mockups or examples if possible

Use the [feature request template](.github/ISSUE_TEMPLATE/feature_request.md).

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Make your changes** following our coding standards
3. **Test your changes** thoroughly
4. **Update documentation** as needed
5. **Submit a pull request** using our template

## 🛠️ Development Setup

### Prerequisites

- macOS 14.0+ (Sonoma or later)
- Xcode 16.0+ with visionOS SDK
- Apple Vision Pro device or simulator
- Git

### Setup Steps

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/visionOS_Spatial-Screenplay-Workshop.git
cd visionOS_Spatial-Screenplay-Workshop

# Add upstream remote
git remote add upstream https://github.com/ORIGINAL_OWNER/visionOS_Spatial-Screenplay-Workshop.git

# Open in Xcode
open SpatialScreenplayWorkshop.xcodeproj
```

### Building and Running

1. Select "Apple Vision Pro" simulator or device
2. Press `Cmd+R` to build and run
3. First build may take 2-3 minutes

### Running Tests

```bash
# Run all tests
xcodebuild test \
  -scheme SpatialScreenplayWorkshop \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

# Run specific test suite
xcodebuild test \
  -scheme SpatialScreenplayWorkshop \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:SpatialScreenplayWorkshopTests/SpatialLayoutEngineTests
```

## 📐 Coding Standards

### Swift Style Guide

We follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/) and use SwiftLint for enforcement.

**Key Conventions:**
- Use 4 spaces for indentation (no tabs)
- Maximum line length: 120 characters
- Use meaningful, descriptive names
- Prefer `let` over `var` when possible
- Use type inference where it improves readability
- Add documentation comments for public APIs

### Code Organization

```swift
// MARK: - Properties
var property: Type

// MARK: - Initialization
init() { }

// MARK: - Public Methods
func publicMethod() { }

// MARK: - Private Methods
private func privateMethod() { }
```

### SwiftUI Conventions

```swift
struct MyView: View {
    // State and bindings first
    @State private var isShowing = false
    @Binding var data: Data

    // Environment after state
    @Environment(\.modelContext) private var modelContext

    // Computed properties
    var body: some View {
        // View hierarchy
    }

    // Helper methods last
    private func helperMethod() { }
}
```

### RealityKit Conventions

```swift
final class MyEntity: Entity {
    // MARK: - Properties

    // MARK: - Initialization
    init() {
        super.init()
        setupComponents()
    }

    required init() {
        fatalError("Use init() instead")
    }

    // MARK: - Setup
    private func setupComponents() { }
}
```

## 🧪 Testing Guidelines

### Unit Tests

- Test all business logic thoroughly
- Use descriptive test names: `testCalculatePositions_GroupsByAct()`
- Follow Arrange-Act-Assert pattern
- Aim for 80%+ code coverage

```swift
func testFeatureName_Scenario() {
    // Arrange
    let input = createTestInput()

    // Act
    let result = performOperation(input)

    // Assert
    XCTAssertEqual(result, expectedValue)
}
```

### UI Tests

- Test critical user flows
- Use accessibility identifiers
- Keep tests maintainable and readable

### Performance Tests

- Use `measure` blocks for performance-critical code
- Document performance targets in tests
- Profile with Instruments before optimizing

## 📝 Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add character voice customization
fix: resolve crash when deleting scene
docs: update API documentation
test: add tests for PDF export
refactor: simplify layout calculation
perf: optimize scene card rendering
chore: update dependencies
```

**Good commit messages:**
- Use present tense ("add feature" not "added feature")
- Use imperative mood ("move cursor to..." not "moves cursor to...")
- Limit first line to 72 characters
- Reference issues and PRs liberally

## 🔄 Workflow

### Creating a Feature

```bash
# Update your fork
git checkout main
git pull upstream main

# Create feature branch
git checkout -b feature/my-feature

# Make changes and commit
git add .
git commit -m "feat: add my feature"

# Push to your fork
git push origin feature/my-feature

# Create pull request on GitHub
```

### Keeping Your Fork Updated

```bash
git checkout main
git pull upstream main
git push origin main
```

### Rebasing Your Branch

```bash
git checkout feature/my-feature
git rebase main
git push --force origin feature/my-feature
```

## 🎨 Design Guidelines

### Spatial UI Principles

1. **Depth Hierarchy**: Use Z-depth to show relationships
2. **Natural Gestures**: Design for tap, drag, and gaze
3. **Comfortable Distances**: 2-4 meters for primary content
4. **Glassmorphic UI**: Use .ultraThinMaterial for overlays
5. **Smooth Animations**: 60 FPS minimum

### Color and Typography

- Follow Apple's Human Interface Guidelines for visionOS
- Use semantic colors from SwiftUI
- Courier 12pt for screenplay text (industry standard)
- SF Pro Display for UI elements

## 📚 Documentation

### Code Comments

```swift
/// Calculates the spatial position for a scene card.
///
/// Scene cards are positioned in a 3D grid organized by acts.
/// Act I is at z=0, Act II at z=-0.5, Act III at z=-1.0.
///
/// - Parameters:
///   - scene: The scene to position
///   - containerSize: The size of the timeline container
/// - Returns: 3D position as SIMD3<Float>
func calculatePosition(for scene: Scene, in containerSize: CGSize) -> SIMD3<Float> {
    // Implementation
}
```

### README Updates

- Update features list when adding major features
- Update roadmap when planning changes
- Keep installation instructions current

### API Documentation

- Document all public APIs with DocC comments
- Include usage examples
- Specify parameter requirements and return values

## 🏆 Recognition

Contributors will be recognized in:
- README contributors section
- Release notes
- About screen in the app

## 🤝 Getting Help

- **Questions**: Use [GitHub Discussions](https://github.com/yourusername/visionOS_Spatial-Screenplay-Workshop/discussions)
- **Chat**: Join our [Discord community](https://discord.gg/spatialscreenplay)
- **Issues**: Search [existing issues](https://github.com/yourusername/visionOS_Spatial-Screenplay-Workshop/issues) first

## 📋 PR Review Process

### Review Timeline

- Initial review: Within 3 business days
- Feedback cycle: Respond within 2 business days
- Final approval: When all criteria met

### Review Criteria

✅ **Code Quality**
- Follows style guidelines
- Well-tested
- Properly documented

✅ **Functionality**
- Works as described
- No regressions
- Meets requirements

✅ **Performance**
- Maintains 60+ FPS
- Memory usage acceptable
- No unnecessary allocations

✅ **User Experience**
- Intuitive to use
- Accessible
- Follows design guidelines

## 🎓 Learning Resources

### visionOS Development
- [Apple Vision Pro Developer Documentation](https://developer.apple.com/visionos/)
- [RealityKit Documentation](https://developer.apple.com/documentation/realitykit)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)

### Screenwriting
- [Industry Standard Script Format](https://screencraft.org/blog/proper-screenplay-format/)
- [Fountain Markup Language](https://fountain.io/)

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to Spatial Screenplay Workshop! 🎬✨
