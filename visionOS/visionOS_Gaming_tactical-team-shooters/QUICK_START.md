# Quick Start Guide

Get up and running with Tactical Team Shooters development in 10 minutes.

## Prerequisites

- macOS 14.0+ (Sonoma)
- Xcode 16.0+
- Apple Vision Pro or visionOS Simulator

## 5-Minute Setup

### 1. Clone Repository

```bash
git clone https://github.com/yourorg/visionOS_Gaming_tactical-team-shooters.git
cd visionOS_Gaming_tactical-team-shooters
```

### 2. Open in Xcode

```bash
open Package.swift
```

Xcode will automatically resolve dependencies.

### 3. Select Target

- Product → Destination → Apple Vision Pro (Simulator)

### 4. Build & Run

```bash
# Command line
swift build

# Or in Xcode
⌘R (Run)
```

## First Build

Expected build time: 2-3 minutes

If build fails, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

## Running Tests

```bash
# All tests
swift test

# Specific test
swift test --filter PlayerTests

# With coverage
swift test --enable-code-coverage
```

## Project Tour

### Key Files

```
TacticalTeamShooters/
├── App/TacticalTeamShootersApp.swift  # Start here
├── Models/Player.swift                 # Player data model
├── Views/UI/MainMenuView.swift        # Main menu
└── Tests/Models/PlayerTests.swift     # Example tests
```

### Try This

1. **Modify Main Menu**: Edit `MainMenuView.swift`
2. **Add Player Stat**: Edit `Player.swift`, add property
3. **Run Tests**: `swift test --filter PlayerTests`
4. **See It Work**: Build and run (⌘R)

## Development Workflow

```bash
# 1. Create feature branch
git checkout -b feature/my-feature

# 2. Make changes
# Edit files in Xcode

# 3. Run tests
swift test

# 4. Commit
git add .
git commit -m "feat: add my feature"

# 5. Push
git push origin feature/my-feature

# 6. Create PR on GitHub
```

## Common Commands

```bash
# Build
swift build

# Test
swift test

# Clean
rm -rf .build && swift build

# Lint
swiftlint

# Format
swiftlint --fix
```

## Next Steps

- [ ] Read [CONTRIBUTING.md](CONTRIBUTING.md)
- [ ] Review [CODING_STANDARDS.md](CODING_STANDARDS.md)
- [ ] Check [ARCHITECTURE.md](ARCHITECTURE.md)
- [ ] Join community discussions

## Need Help?

- 📖 [Full Documentation](README.md)
- 🐛 [Troubleshooting](TROUBLESHOOTING.md)
- ❓ [FAQ](FAQ.md)
- 💬 [GitHub Discussions](https://github.com/yourorg/repo/discussions)

## What's Next?

### Beginner Tasks

Look for issues labeled `good first issue`:
- Documentation improvements
- Test coverage additions
- Code comment additions

### Intermediate Tasks

- Bug fixes
- Small feature additions
- Performance improvements

### Advanced Tasks

- New game modes
- Multiplayer improvements
- Major features

Happy coding! 🎮
