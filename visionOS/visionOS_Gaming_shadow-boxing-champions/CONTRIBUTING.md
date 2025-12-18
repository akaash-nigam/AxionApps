# Contributing to Shadow Boxing Champions

First off, thank you for considering contributing to Shadow Boxing Champions! It's people like you that make this project such a great tool for the Vision Pro community.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [What Should I Know Before I Get Started?](#what-should-i-know-before-i-get-started)
- [How Can I Contribute?](#how-can-i-contribute)
- [Style Guides](#style-guides)
- [Development Process](#development-process)
- [Community](#community)

---

## Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to conduct@shadowboxingchampions.com.

---

## What Should I Know Before I Get Started?

### Project Vision

Shadow Boxing Champions aims to revolutionize fitness training through spatial computing. Our goals are:

1. **Authenticity** - Provide professional-grade boxing training
2. **Accessibility** - Make championship-level instruction available to everyone
3. **Innovation** - Push the boundaries of what's possible with Vision Pro
4. **Community** - Build an engaged, supportive community of boxers and gamers

### Project Structure

Please review the following documents to understand the project:

- **[README.md](README.md)** - Project overview and quick start
- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** - Technical architecture
- **[TECHNICAL_SPEC.md](docs/TECHNICAL_SPEC.md)** - Implementation specifications
- **[DESIGN.md](docs/DESIGN.md)** - Game design and UX principles
- **[IMPLEMENTATION_PLAN.md](docs/IMPLEMENTATION_PLAN.md)** - Development roadmap

### Technology Stack

- Swift 6.0+ (strict concurrency)
- SwiftUI for UI
- RealityKit for 3D rendering
- ARKit for tracking
- Core ML for AI

---

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the [existing issues](../../issues) to avoid duplicates.

When creating a bug report, include as many details as possible:

**Use the bug report template** (it will be automatically loaded when you create a new issue)

Include:
- **Clear title and description**
- **Steps to reproduce** the issue
- **Expected behavior** vs **actual behavior**
- **Screenshots or videos** if applicable
- **Device information** (visionOS version, device model)
- **App version**

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

**Use the feature request template**

Include:
- **Clear title** describing the enhancement
- **Detailed description** of the proposed functionality
- **Rationale** - why this would be valuable
- **Alternatives** you've considered
- **Mockups or examples** if applicable

### Pull Requests

#### Before Submitting

1. **Check existing PRs** to avoid duplicate work
2. **Open an issue first** for major changes
3. **Read the code style guide** below
4. **Test your changes** thoroughly

#### Submitting a Pull Request

1. **Fork the repository** and create your branch from `main`
   ```bash
   git checkout -b feature/my-amazing-feature
   ```

2. **Make your changes**
   - Follow the code style guide
   - Add tests for new functionality
   - Update documentation as needed

3. **Commit your changes**
   ```bash
   git commit -m "Add amazing feature"
   ```
   Follow the [commit message conventions](#commit-messages)

4. **Push to your fork**
   ```bash
   git push origin feature/my-amazing-feature
   ```

5. **Open a Pull Request**
   - Use the PR template
   - Link related issues
   - Provide clear description
   - Request review

#### Pull Request Checklist

Before submitting your PR, verify:

- [ ] Code follows the style guide
- [ ] Self-review completed
- [ ] Comments added to complex code
- [ ] Documentation updated
- [ ] No new warnings introduced
- [ ] Tests added/updated and passing
- [ ] Builds successfully on visionOS
- [ ] Performance impact considered
- [ ] UI/UX reviewed (if applicable)

---

## Style Guides

### Git Commit Messages

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```bash
feat(combat): add uppercut detection

Implement uppercut punch detection using hand velocity
and trajectory analysis. Includes haptic feedback.

Closes #123
```

```bash
fix(ui): correct health bar animation

Health bar now animates smoothly when taking damage
instead of jumping directly to new value.
```

### Swift Code Style

Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/) and these additional conventions:

#### Naming

```swift
// Types: UpperCamelCase
class GameCoordinator { }
struct PlayerProfile { }
enum GameState { }

// Functions and variables: lowerCamelCase
func calculateDamage() { }
var punchVelocity: Float

// Constants: lowerCamelCase
let maxHealth: Float = 100.0
```

#### Organization

```swift
// MARK: - Type Definition

class GameManager {
    // MARK: - Properties

    private var players: [Player] = []

    // MARK: - Lifecycle

    init() { }

    // MARK: - Public Methods

    func startGame() { }

    // MARK: - Private Methods

    private func setupGame() { }
}
```

#### Concurrency

```swift
// Use async/await for asynchronous code
func loadOpponent() async throws -> Opponent {
    try await OpponentLoader.load()
}

// Use actors for shared mutable state
actor GameState {
    var score: Int = 0

    func updateScore(_ points: Int) {
        score += points
    }
}
```

#### Documentation

```swift
/// Calculates damage dealt by a punch
///
/// Damage is based on punch velocity, type, and player stats.
///
/// - Parameters:
///   - punch: The punch data to analyze
///   - player: The player throwing the punch
/// - Returns: Damage value in hit points
/// - Throws: `PunchError.invalidData` if punch data is incomplete
func calculateDamage(punch: Punch, player: Player) throws -> Float {
    // Implementation
}
```

### SwiftUI Code Style

```swift
struct HealthBar: View {
    // MARK: - Properties

    let health: Float
    let maxHealth: Float

    // MARK: - Computed Properties

    private var healthPercentage: Float {
        health / maxHealth
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                Rectangle()
                    .fill(.gray.opacity(0.3))

                // Health
                Rectangle()
                    .fill(.red)
                    .frame(width: geometry.size.width * CGFloat(healthPercentage))
            }
            .cornerRadius(8)
        }
    }
}
```

### Testing Style

```swift
@Test("Punch detection identifies jab correctly")
func testJabDetection() async throws {
    let detector = PunchDetectionSystem()
    let hand = createMockHand(velocity: SIMD3(0, 0, -3.0))

    let punch = try await detector.detectPunch(hand: hand)

    #expect(punch?.type == .jab)
    #expect(punch?.power > 0.5)
}
```

---

## Development Process

### Setting Up Development Environment

1. **Install Prerequisites**
   - Xcode 16.0+
   - macOS 14.0+
   - Git

2. **Clone and Configure**
   ```bash
   git clone https://github.com/akaash-nigam/visionOS_Gaming_shadow-boxing-champions.git
   cd visionOS_Gaming_shadow-boxing-champions

   # Install any dependencies (when project is created)
   # open ShadowBoxingChampions.xcodeproj
   ```

3. **Create Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

### Development Workflow

1. **Implement Feature**
   - Write code following style guide
   - Add unit tests
   - Update documentation

2. **Test Locally**
   - Run all tests: ⌘U
   - Test on simulator
   - Test on device (if available)

3. **Commit Changes**
   ```bash
   git add .
   git commit -m "feat(scope): description"
   ```

4. **Push and Create PR**
   ```bash
   git push origin feature/your-feature-name
   # Then create PR on GitHub
   ```

5. **Code Review**
   - Address review comments
   - Update PR as needed
   - Get approval

6. **Merge**
   - Squash and merge
   - Delete feature branch

### Testing Guidelines

#### Unit Tests

```swift
// Test business logic
@Test("Player takes damage correctly")
func testPlayerDamage() {
    let player = Player(health: 100)
    player.takeDamage(25)
    #expect(player.health == 75)
}
```

#### Integration Tests

```swift
// Test system interactions
@Test("Combat system processes punch")
func testCombatFlow() async {
    let combat = CombatSystem()
    let punch = Punch(type: .jab, power: 0.8)

    let result = await combat.processPunch(punch)

    #expect(result.hit == true)
    #expect(result.damage > 0)
}
```

#### Performance Tests

```swift
@Test("Punch detection runs at 90 FPS")
func testPunchDetectionPerformance() {
    measure {
        detector.detectPunch(mockHand)
    }
}
```

---

## Types of Contributions

### Code Contributions

- Implement new features
- Fix bugs
- Improve performance
- Refactor code
- Add tests

### Documentation Contributions

- Fix typos or errors
- Improve clarity
- Add examples
- Translate documentation
- Write tutorials

### Design Contributions

- Create UI/UX mockups
- Design icons or graphics
- Improve accessibility
- Conduct usability testing

### Community Contributions

- Answer questions in discussions
- Help other contributors
- Write blog posts
- Create video tutorials
- Organize events

---

## Recognition

Contributors will be recognized in:

- Repository README
- Release notes
- Hall of Fame page (coming soon)
- Social media shoutouts

Top contributors may receive:

- Early access to features
- Exclusive merchandise
- Free premium subscription
- Special role in Discord

---

## Getting Help

### Resources

- **Documentation**: Read the docs in this repository
- **Discussions**: [GitHub Discussions](../../discussions)
- **Discord**: [Join our server](#) (Coming Soon)
- **Email**: dev@shadowboxingchampions.com

### Common Questions

**Q: I'm new to visionOS. Where should I start?**
A: Check out Apple's [visionOS documentation](https://developer.apple.com/visionos/) and our [ARCHITECTURE.md](docs/ARCHITECTURE.md) for project-specific patterns.

**Q: How do I test without a Vision Pro?**
A: Use the visionOS Simulator in Xcode. While not perfect, it's sufficient for most development.

**Q: My PR was rejected. What now?**
A: Don't be discouraged! Address the feedback, make changes, and resubmit. We're here to help.

---

## License

By contributing to Shadow Boxing Champions, you agree that your contributions will be licensed under the same license as the project (see [LICENSE](LICENSE)).

---

## Thank You!

Your contributions make Shadow Boxing Champions better for everyone. We appreciate your time and effort! 🥊

Questions? Reach out to contribute@shadowboxingchampions.com

---

<p align="center">
  <strong>Happy Contributing!</strong>
  <br>
  <sub>Together, we're building the future of fitness training</sub>
</p>
