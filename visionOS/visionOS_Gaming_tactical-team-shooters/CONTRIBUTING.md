# Contributing to Tactical Team Shooters

Thank you for your interest in contributing to **Tactical Team Shooters**! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Process](#development-process)
- [Coding Standards](#coding-standards)
- [Submitting Changes](#submitting-changes)
- [Testing Requirements](#testing-requirements)
- [Documentation](#documentation)
- [Community](#community)

## Code of Conduct

### Our Standards

- **Be Respectful**: Treat all contributors with respect and professionalism
- **Be Collaborative**: Work together to achieve the best results
- **Be Constructive**: Provide helpful feedback and suggestions
- **Be Inclusive**: Welcome contributors of all skill levels and backgrounds

### Unacceptable Behavior

- Harassment, discrimination, or offensive comments
- Trolling, insulting, or derogatory remarks
- Publishing private information without consent
- Any conduct that would be inappropriate in a professional setting

## Getting Started

### Prerequisites

- **macOS 14.0+** (Sonoma or later)
- **Xcode 16.0+** with visionOS SDK
- **Swift 6.0+**
- **Apple Vision Pro** (for hardware testing)
- **Git** for version control

### Setting Up Development Environment

1. **Fork the repository**
   ```bash
   # Click "Fork" on GitHub, then clone your fork
   git clone https://github.com/YOUR_USERNAME/visionOS_Gaming_tactical-team-shooters.git
   cd visionOS_Gaming_tactical-team-shooters
   ```

2. **Open in Xcode**
   ```bash
   open Package.swift
   # or
   open TacticalTeamShooters.xcodeproj
   ```

3. **Install dependencies** (if any)
   ```bash
   # Dependencies are managed via Swift Package Manager
   # Xcode will automatically resolve dependencies
   ```

4. **Build the project**
   ```bash
   xcodebuild -scheme TacticalTeamShooters -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
   ```

5. **Run tests**
   ```bash
   swift test
   ```

See [DEVELOPMENT_ENVIRONMENT.md](DEVELOPMENT_ENVIRONMENT.md) for detailed setup instructions.

## Development Process

### Branching Strategy

We use **Git Flow** with the following branches:

- `main` - Production-ready code
- `develop` - Integration branch for features
- `feature/*` - New features (e.g., `feature/hand-gestures`)
- `bugfix/*` - Bug fixes (e.g., `bugfix/networking-crash`)
- `hotfix/*` - Critical production fixes
- `release/*` - Release preparation

### Creating a Feature Branch

```bash
# Update your local repository
git checkout develop
git pull origin develop

# Create a feature branch
git checkout -b feature/your-feature-name

# Make your changes, commit regularly
git add .
git commit -m "Add feature: your feature description"

# Push to your fork
git push origin feature/your-feature-name
```

### Commit Message Guidelines

Follow the **Conventional Commits** specification:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, no logic changes)
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `test`: Adding or updating tests
- `chore`: Build process or auxiliary tool changes

**Examples**:
```bash
feat(weapons): add recoil pattern customization
fix(networking): resolve multiplayer desync on player death
docs(readme): update installation instructions
test(player): add unit tests for stats tracking
```

### Work-in-Progress Commits

For WIP commits during development:
```bash
git commit -m "WIP: implementing hand gesture recognition"
```

Squash WIP commits before submitting PR.

## Coding Standards

### Swift Style Guide

We follow the **Official Swift API Design Guidelines** and **Ray Wenderlich Swift Style Guide**.

**Key Conventions**:

1. **Naming**
   ```swift
   // Classes, Structs, Enums, Protocols: PascalCase
   class PlayerController { }
   struct WeaponStats { }
   enum GameState { }
   protocol Damageable { }

   // Variables, Functions: camelCase
   var playerHealth: Double
   func calculateDamage() -> Int

   // Constants: camelCase
   let maxPlayers = 10
   ```

2. **Indentation**
   - Use **4 spaces** (no tabs)
   - Configure Xcode: Preferences → Text Editing → Indentation

3. **Line Length**
   - Maximum **120 characters** per line
   - Break long lines logically

4. **Spacing**
   ```swift
   // YES
   if condition {
       doSomething()
   }

   // NO
   if condition{
       doSomething()
   }
   ```

5. **Type Inference**
   ```swift
   // YES
   let name = "Player1"
   let count = 42

   // NO (unless type is ambiguous)
   let name: String = "Player1"
   ```

6. **Access Control**
   - Always specify access control explicitly
   ```swift
   public class GameManager { }
   private var playerData: [Player]
   internal func updateState() { }
   ```

7. **Swift Concurrency**
   ```swift
   // Use async/await
   func loadGameData() async throws -> GameData {
       try await networkManager.fetchData()
   }

   // Use actors for shared mutable state
   actor PlayerManager {
       private var players: [Player] = []
   }
   ```

See [CODING_STANDARDS.md](CODING_STANDARDS.md) for complete style guide.

### SwiftLint

We use **SwiftLint** to enforce code style:

```bash
# Install SwiftLint
brew install swiftlint

# Run SwiftLint
swiftlint

# Auto-fix violations
swiftlint --fix
```

Configuration: `.swiftlint.yml`

## Submitting Changes

### Pull Request Process

1. **Ensure your code builds**
   ```bash
   xcodebuild -scheme TacticalTeamShooters
   ```

2. **Run all tests**
   ```bash
   swift test
   ```

3. **Run SwiftLint**
   ```bash
   swiftlint
   ```

4. **Update documentation**
   - Update README if needed
   - Add code comments
   - Update CHANGELOG.md

5. **Create Pull Request**
   - Go to your fork on GitHub
   - Click "New Pull Request"
   - Base: `develop`, Compare: `feature/your-feature`
   - Fill out PR template completely

6. **PR Title Format**
   ```
   [Feature/Fix/Docs] Brief description
   ```
   Example: `[Feature] Add hand gesture weapon switching`

7. **PR Description Template**
   ```markdown
   ## Summary
   Brief description of changes

   ## Changes Made
   - Change 1
   - Change 2

   ## Testing
   - [ ] Unit tests added/updated
   - [ ] Integration tests pass
   - [ ] Manual testing on Vision Pro

   ## Screenshots/Videos
   (if applicable)

   ## Checklist
   - [ ] Code follows style guidelines
   - [ ] Self-review completed
   - [ ] Comments added to complex code
   - [ ] Documentation updated
   - [ ] Tests added/updated
   - [ ] All tests pass
   ```

### Code Review Process

1. **Automated Checks**
   - GitHub Actions CI/CD runs
   - SwiftLint validation
   - Build verification
   - Test execution

2. **Peer Review**
   - At least **1 approval** required
   - Address all review comments
   - Make requested changes

3. **Maintainer Review**
   - Final review by project maintainers
   - Ensure alignment with project goals

4. **Merge**
   - Squash and merge to `develop`
   - Delete feature branch after merge

## Testing Requirements

### Test Coverage

- **Minimum 80% code coverage** required
- All new features must include tests
- Bug fixes must include regression tests

### Test Types

1. **Unit Tests**
   ```swift
   // TacticalTeamShooters/Tests/Models/PlayerTests.swift
   func testPlayerHealthCalculation() {
       var player = Player(username: "Test")
       player.takeDamage(30)
       XCTAssertEqual(player.health, 70)
   }
   ```

2. **Integration Tests**
   ```swift
   // TacticalTeamShooters/Tests/Integration/NetworkTests.swift
   func testMultiplayerSync() async throws {
       let client = NetworkClient()
       let data = try await client.syncGameState()
       XCTAssertNotNil(data)
   }
   ```

3. **UI Tests** (for Vision Pro)
   - Test in visionOS Simulator
   - Test on physical Apple Vision Pro
   - Document hardware-specific tests

### Running Tests

```bash
# All tests
swift test

# Specific test
swift test --filter PlayerTests

# With coverage
swift test --enable-code-coverage

# Generate coverage report
xcrun llvm-cov show .build/debug/TacticalTeamShootersPackageTests.xctest
```

See [TESTING_STRATEGY.md](TESTING_STRATEGY.md) for comprehensive testing guide.

## Documentation

### Code Documentation

Use **Swift DocC** format for documentation:

```swift
/// Calculates damage dealt to a player based on weapon and distance.
///
/// This function considers weapon stats, distance falloff, and armor mitigation.
///
/// - Parameters:
///   - weapon: The weapon used for the attack
///   - distance: Distance from attacker to target in meters
///   - armor: Target's current armor value
/// - Returns: The final damage value after all calculations
/// - Throws: `WeaponError.invalidStats` if weapon stats are malformed
func calculateDamage(weapon: Weapon, distance: Float, armor: Double) throws -> Int {
    // Implementation
}
```

### Documentation Files

Update relevant documentation:
- `README.md` - Project overview
- `ARCHITECTURE.md` - Architecture changes
- `API_DOCUMENTATION.md` - API changes
- `CHANGELOG.md` - Version history

### Inline Comments

```swift
// MARK: - Player Management

// TODO: Implement player ranking system
// FIXME: Memory leak in player cleanup
// NOTE: This uses client-side prediction
```

## Project Structure

```
TacticalTeamShooters/
├── App/                    # Application entry point
├── Models/                 # Data models
├── Views/                  # SwiftUI views
├── Scenes/                 # RealityKit scenes
├── Systems/                # Game systems (ECS)
├── Networking/             # Multiplayer networking
├── Resources/              # Assets and resources
└── Tests/                  # Test files
```

See [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) for detailed structure.

## Areas for Contribution

### High Priority

- 🔴 **Multiplayer Networking**: Improve lag compensation and server reconciliation
- 🔴 **Performance Optimization**: Achieve consistent 120 FPS on Vision Pro
- 🔴 **Hand Gesture Controls**: Expand gesture recognition system

### Medium Priority

- 🟡 **Weapon Balance**: Fine-tune weapon stats based on playtesting
- 🟡 **Map Design**: Create additional competitive maps
- 🟡 **Audio System**: Enhance spatial audio implementation

### Low Priority

- 🟢 **UI/UX Improvements**: Polish menus and HUD
- 🟢 **Accessibility**: Add more accessibility features
- 🟢 **Documentation**: Improve guides and tutorials

### Good First Issues

Look for issues labeled `good first issue` - these are beginner-friendly:
- Documentation improvements
- Simple bug fixes
- Code style cleanups
- Test coverage improvements

## Communication

### Channels

- **GitHub Issues**: Bug reports, feature requests
- **GitHub Discussions**: Questions, ideas, general discussion
- **Pull Requests**: Code review and collaboration

### Asking Questions

Before asking:
1. Check existing issues and discussions
2. Read documentation (README, guides)
3. Search closed issues

When asking:
- Be specific and provide context
- Include code snippets or screenshots
- Specify your environment (macOS version, Xcode version)

## Recognition

Contributors are recognized in:
- `CONTRIBUTORS.md` - List of all contributors
- Release notes - Major contributions highlighted
- README.md - Top contributors section

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.

## Questions?

- Read the [FAQ](FAQ.md)
- Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- Open a GitHub Discussion
- Review existing documentation

---

**Thank you for contributing to Tactical Team Shooters!**

We appreciate your time and effort in making this project better. Every contribution, no matter how small, makes a difference.

Happy coding! 🎮
