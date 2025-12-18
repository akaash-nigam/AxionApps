# Contributing to Spatial Arena Championship

Thank you for your interest in contributing to Spatial Arena Championship! This document provides guidelines and instructions for contributing to the project.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Pull Request Process](#pull-request-process)
- [Reporting Bugs](#reporting-bugs)
- [Suggesting Features](#suggesting-features)

---

## 📜 Code of Conduct

This project adheres to a Code of Conduct that all contributors are expected to follow. Please read [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) before contributing.

**In short:**
- Be respectful and inclusive
- Welcome newcomers
- Focus on constructive feedback
- Respect differing viewpoints
- Report unacceptable behavior

---

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have:

- **macOS** 14.0+ (Sonoma or later)
- **Xcode** 15.4+ with visionOS SDK
- **Git** for version control
- **Apple Developer Account** (for device testing)
- Basic knowledge of Swift and SwiftUI

### First-Time Setup

1. **Fork the repository**
   ```bash
   # Click "Fork" button on GitHub
   ```

2. **Clone your fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/visionOS_Gaming_spatial-arena-championship.git
   cd visionOS_Gaming_spatial-arena-championship
   ```

3. **Add upstream remote**
   ```bash
   git remote add upstream https://github.com/ORIGINAL_OWNER/visionOS_Gaming_spatial-arena-championship.git
   ```

4. **Open in Xcode**
   ```bash
   open SpatialArenaChampionship.xcodeproj
   ```

5. **Build and run**
   ```bash
   ⌘ + R in Xcode
   ```

---

## 🛠️ Development Setup

### Xcode Configuration

1. **Select your Development Team**
   - Project Settings → Signing & Capabilities
   - Select your team for code signing

2. **Choose Target Device**
   - Select "Vision Pro Simulator" for development
   - Or connect your Vision Pro device

3. **Build the Project**
   - `⌘ + B` to build
   - `⌘ + R` to run
   - `⌘ + U` to run tests

### Recommended Xcode Settings

```
Editor → Font Size: 12-14pt
Editor → Show Minimap: Enabled
Editor → Line Numbers: Enabled
Editor → Code Folding Ribbon: Enabled
Editor → Indentation Width: 4 spaces
```

---

## 💡 How to Contribute

### Types of Contributions

We welcome many types of contributions:

1. **Bug Fixes** 🐛
   - Fix existing issues
   - Improve error handling
   - Resolve crashes

2. **Features** ✨
   - New game modes
   - Additional abilities
   - UI improvements
   - Performance optimizations

3. **Documentation** 📚
   - Improve README
   - Add code comments
   - Write guides
   - Fix typos

4. **Tests** 🧪
   - Increase test coverage
   - Add missing tests
   - Improve test quality

5. **Performance** ⚡
   - Optimize algorithms
   - Reduce memory usage
   - Improve frame rate

### Finding an Issue

- Check [Issues](https://github.com/OWNER/REPO/issues) for open tasks
- Look for `good-first-issue` label for beginner-friendly tasks
- Look for `help-wanted` label for issues needing attention
- Ask in Discord if you're unsure what to work on

---

## 📝 Coding Standards

### Swift Style Guide

We follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/).

#### Naming Conventions

```swift
// ✅ Good
class PlayerController { }
func calculateDamage(from attacker: Player) -> Float { }
var playerHealth: Float = 100.0

// ❌ Bad
class player_controller { }
func calc_dmg(attacker: Player) -> Float { }
var HP: Float = 100.0
```

#### Code Organization

```swift
// MARK: - Properties
private var playerHealth: Float = 100.0
private var shields: Float = 50.0

// MARK: - Initialization
init() { }

// MARK: - Public Methods
func takeDamage(_ amount: Float) { }

// MARK: - Private Methods
private func regenerateShields() { }
```

#### Comments

```swift
// Use comments to explain "why", not "what"

// ✅ Good
// Clamp health to prevent negative values which break death detection
health = max(0, health - damage)

// ❌ Bad
// Set health to maximum of 0 and health minus damage
health = max(0, health - damage)
```

#### Documentation Comments

```swift
/// Calculates damage with headshot multiplier
///
/// - Parameters:
///   - baseDamage: Base damage amount
///   - isHeadshot: Whether this was a headshot
/// - Returns: Final damage value
func calculateDamage(baseDamage: Float, isHeadshot: Bool) -> Float {
    return isHeadshot ? baseDamage * 2.0 : baseDamage
}
```

### SwiftUI Best Practices

```swift
// Extract complex views into separate components
struct ComplexView: View {
    var body: some View {
        VStack {
            HeaderSection()  // ✅ Extracted
            ContentSection() // ✅ Extracted
            FooterSection()  // ✅ Extracted
        }
    }
}

// Use @Observable for state management (Swift 6.0+)
@Observable
class GameState {
    var score: Int = 0
    var isPlaying: Bool = false
}
```

### RealityKit / ECS Patterns

```swift
// Components should be simple data containers
struct HealthComponent: Component, Codable {
    var current: Float
    var maximum: Float
}

// Systems should contain logic
class HealthSystem {
    func update(deltaTime: TimeInterval) {
        // Process all entities with HealthComponent
    }
}
```

---

## 🧪 Testing Guidelines

### Test Requirements

All code contributions must include appropriate tests:

- **New Features:** Add unit tests and integration tests
- **Bug Fixes:** Add regression tests
- **UI Changes:** Add UI tests if applicable

### Writing Good Tests

```swift
func testPlayerTakeDamage() {
    // Arrange
    let player = Player(username: "Test", skillRating: 1500, team: .blue)
    let initialHealth = player.health

    // Act
    player.takeDamage(25.0, from: UUID())

    // Assert
    XCTAssertEqual(player.health, initialHealth - 25.0)
}
```

### Running Tests

```bash
# Run all tests
⌘ + U

# Run specific test
⌘ + U on test method

# Command line
xcodebuild test -scheme SpatialArenaChampionship \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

### Test Coverage

Aim for:
- **Models:** 80%+ coverage
- **Systems:** 70%+ coverage
- **UI:** 60%+ coverage

---

## 🔄 Pull Request Process

### Before Submitting

1. **Sync with upstream**
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Write clean, documented code
   - Follow coding standards
   - Add tests

4. **Test your changes**
   ```bash
   ⌘ + U  # Run all tests
   ```

5. **Commit with clear messages**
   ```bash
   git commit -m "Add ability to dash through shields"
   ```

### Pull Request Template

When creating a PR, include:

```markdown
## Description
Brief description of your changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation
- [ ] Performance improvement

## Testing
- [ ] All tests pass
- [ ] Added new tests
- [ ] Tested on simulator
- [ ] Tested on device

## Screenshots (if applicable)
Add screenshots of UI changes

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No new warnings
```

### Review Process

1. Automated checks run (build, tests, linting)
2. Maintainers review your code
3. Address feedback if needed
4. Once approved, maintainer will merge

---

## 🐛 Reporting Bugs

### Before Reporting

1. **Check existing issues** - Your bug might already be reported
2. **Try latest version** - Bug might be fixed in main branch
3. **Reproduce the issue** - Ensure it's consistent

### Bug Report Template

```markdown
**Describe the Bug**
Clear description of what the bug is

**To Reproduce**
Steps to reproduce:
1. Go to '...'
2. Click on '...'
3. See error

**Expected Behavior**
What you expected to happen

**Actual Behavior**
What actually happened

**Screenshots**
If applicable

**Environment:**
- visionOS Version: [e.g. 2.0]
- Device: [Vision Pro / Simulator]
- App Version: [e.g. 1.0.1]

**Additional Context**
Any other context
```

---

## 💡 Suggesting Features

We love feature suggestions! Here's how to suggest one:

### Feature Request Template

```markdown
**Feature Description**
Clear description of the feature

**Problem it Solves**
What problem does this solve?

**Proposed Solution**
How would you implement it?

**Alternatives Considered**
Other solutions you considered

**Additional Context**
Mockups, diagrams, etc.
```

### Feature Evaluation Criteria

Features are evaluated based on:
1. **Alignment** with project vision
2. **Value** to users
3. **Feasibility** of implementation
4. **Maintenance** burden
5. **Performance** impact

---

## 📊 Development Workflow

### Branch Naming

- `feature/description` - New features
- `bugfix/description` - Bug fixes
- `docs/description` - Documentation
- `perf/description` - Performance improvements
- `test/description` - Test additions

### Commit Messages

Follow conventional commits:

```
feat: add new dash ability
fix: correct damage calculation
docs: update README installation steps
test: add player respawn tests
perf: optimize collision detection
```

### Code Review Checklist

When reviewing code, check:
- [ ] Code follows style guidelines
- [ ] Tests are included and passing
- [ ] Documentation is updated
- [ ] No console warnings
- [ ] Performance impact considered
- [ ] Accessibility maintained
- [ ] Security implications reviewed

---

## 🎯 Priority Areas

We especially welcome contributions in:

1. **Performance Optimization** - Help us maintain 90 FPS
2. **Test Coverage** - Increase from 70% to 80%+
3. **Accessibility** - VoiceOver, reduced motion, colorblind modes
4. **Documentation** - Player guides, code comments
5. **Bug Fixes** - Check issues tab

---

## 📞 Getting Help

Stuck? We're here to help!

- 💬 **Discord**: https://discord.gg/spatialarena
- 📧 **Email**: dev@spatialarena.com
- 📖 **Docs**: [docs/](docs/)
- 🐛 **Issues**: [GitHub Issues](https://github.com/OWNER/REPO/issues)

---

## 🙏 Recognition

Contributors are recognized in:
- README contributors section
- In-game credits
- Release notes

Top contributors may receive:
- Early access to features
- Input on roadmap
- Special in-game badge

---

## 📜 License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for contributing to Spatial Arena Championship!** 🎮

Together, we're building the future of competitive spatial gaming.
