# Developer Onboarding Guide

Welcome to the Mystery Investigation development team! This guide will help you get set up and productive quickly.

## 🎯 Goals

By the end of this guide, you'll be able to:

- Set up your development environment
- Build and run the app
- Navigate the codebase
- Make your first contribution
- Understand our development workflow

**Estimated Time:** 2-3 hours

---

## ✅ Prerequisites

### Required Hardware
- **Mac** with Apple Silicon (M1/M2/M3) or Intel
- **macOS 14.0+** (Sonoma or later)
- **16 GB RAM minimum** (32 GB recommended)
- **20 GB free disk space**

### Required Software
- **Xcode 16.0+** - [Download from App Store](https://apps.apple.com/us/app/xcode/id497799835)
- **Git** - Pre-installed on macOS, or install via Xcode Command Line Tools
- **Apple Developer Account** - [Sign up](https://developer.apple.com)

### Optional Hardware
- **Apple Vision Pro** - For device testing (simulator works for most development)

### Nice to Have
- **GitHub Desktop** - For easier Git management
- **Fork** or **Tower** - Git GUI clients
- **VS Code** - For markdown editing
- **Dash** - Documentation browser

---

## 📥 Step 1: Repository Setup

### 1.1 Fork the Repository (External Contributors)

If you're not a core team member:

```bash
# Fork the repo on GitHub, then clone your fork:
git clone https://github.com/YOUR_USERNAME/visionOS_Gaming_mystery-investigation.git
cd visionOS_Gaming_mystery-investigation

# Add upstream remote
git remote add upstream https://github.com/[org]/visionOS_Gaming_mystery-investigation.git
```

### 1.2 Clone the Repository (Core Team)

```bash
# Clone directly
git clone https://github.com/[org]/visionOS_Gaming_mystery-investigation.git
cd visionOS_Gaming_mystery-investigation
```

### 1.3 Configure Git

```bash
# Set your name and email
git config user.name "Your Name"
git config user.email "your.email@example.com"

# Set up helpful aliases
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
```

---

## 🛠 Step 2: Xcode Setup

### 2.1 Install Xcode

1. Download Xcode 16.0+ from the App Store
2. Launch Xcode and accept the license
3. Install additional components when prompted

### 2.2 Install visionOS SDK

```bash
# Open Xcode
# Navigate to: Xcode > Settings > Platforms
# Download visionOS Simulator
```

### 2.3 Configure Code Signing

1. Open `MysteryInvestigation.xcodeproj`
2. Select the project in Project Navigator
3. Go to "Signing & Capabilities" tab
4. Select your development team
5. Ensure "Automatically manage signing" is checked

---

## 🏗 Step 3: Build the Project

### 3.1 Open the Project

```bash
cd MysteryInvestigation
open MysteryInvestigation.xcodeproj
```

### 3.2 First Build

1. **Select scheme:** "MysteryInvestigation" from the scheme dropdown
2. **Select destination:** "Apple Vision Pro (Simulator)"
3. **Build:** Press `Cmd+B` or Product > Build
4. **Wait:** First build takes 2-5 minutes

**Expected Output:**
```
Build Succeeded
Build time: ~3 minutes
```

### 3.3 Run on Simulator

1. Press `Cmd+R` or Product > Run
2. visionOS Simulator will launch
3. App should start in Main Menu

**Troubleshooting Build Issues:**

| Error | Solution |
|-------|----------|
| "No developer account found" | Add your Apple ID in Xcode Settings > Accounts |
| "Code signing failed" | Select your team in Signing & Capabilities |
| "visionOS SDK not found" | Install visionOS platform in Xcode Settings > Platforms |
| "Swift compiler error" | Clean build folder (Cmd+Shift+K), then rebuild |

---

## 📚 Step 4: Understand the Codebase

### 4.1 Project Structure

```
MysteryInvestigation/
├── Sources/
│   ├── App/                    # App entry point
│   │   └── MysteryInvestigationApp.swift
│   ├── Coordinators/           # Game flow coordination
│   │   └── GameCoordinator.swift
│   ├── Models/                 # Data models
│   │   └── CaseData.swift
│   ├── Managers/               # Business logic
│   │   ├── CaseManager.swift
│   │   ├── EvidenceManager.swift
│   │   └── SaveGameManager.swift
│   ├── Components/             # RealityKit components
│   │   └── EvidenceComponent.swift
│   └── Views/                  # SwiftUI views
│       ├── MainMenuView.swift
│       └── CrimeSceneView.swift
├── Tests/                      # Unit tests
│   └── UnitTests/
├── Resources/                  # Assets
│   ├── Assets.xcassets/
│   └── RealityKitContent/
└── MysteryInvestigation.xcodeproj
```

### 4.2 Key Files to Know

**Start Here:**
- `MysteryInvestigationApp.swift` - App entry point, scene setup
- `GameCoordinator.swift` - Main game controller
- `CaseData.swift` - Core data models

**Important Managers:**
- `CaseManager.swift` - Case loading and validation
- `EvidenceManager.swift` - Evidence discovery tracking
- `SpatialMappingManager.swift` - ARKit integration

**Main Views:**
- `MainMenuView.swift` - Starting screen
- `CaseSelectionView.swift` - Choose a case
- `CrimeSceneView.swift` - Investigation scene

### 4.3 Architecture Overview

**Pattern:** Entity-Component-System (ECS) + MVVM

```
┌─────────────────┐
│  SwiftUI Views  │ ← User Interface
└────────┬────────┘
         │
┌────────▼────────┐
│  Coordinators   │ ← Orchestration
└────────┬────────┘
         │
┌────────▼────────┐
│    Managers     │ ← Business Logic
└────────┬────────┘
         │
┌────────▼────────┐
│     Models      │ ← Data
└─────────────────┘
```

**Read:** [ARCHITECTURE.md](docs/ARCHITECTURE.md) for detailed architecture

---

## ✍️ Step 5: Make Your First Contribution

### 5.1 Find a Good First Issue

Look for issues tagged `good-first-issue`:

```bash
# Open issues page
open https://github.com/[org]/visionOS_Gaming_mystery-investigation/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22
```

### 5.2 Create a Feature Branch

```bash
# Update main
git checkout main
git pull origin main

# Create feature branch
git checkout -b feature/your-feature-name

# Example:
git checkout -b feature/add-hint-button
```

### 5.3 Make Changes

1. Edit files in Xcode
2. Test your changes (Cmd+R)
3. Run tests (Cmd+U)
4. Ensure no warnings

### 5.4 Commit Your Changes

```bash
# Stage changes
git add .

# Commit with descriptive message
git commit -m "feat: Add hint button to investigation HUD

- Added hint button component
- Implemented hint cost deduction
- Updated tests for hint system"
```

**Commit Message Format:**
```
<type>: <subject>

<body>
```

**Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

### 5.5 Push and Create PR

```bash
# Push to your fork
git push origin feature/your-feature-name

# Create pull request on GitHub
```

**PR Template:** Will auto-populate - fill it out completely!

---

## 🧪 Step 6: Testing

### 6.1 Run Unit Tests

```bash
# In Xcode: Press Cmd+U

# Or via command line:
xcodebuild test \
  -scheme MysteryInvestigation \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

### 6.2 Write Tests for New Code

```swift
import XCTest
@testable import MysteryInvestigation

final class MyFeatureTests: XCTestCase {
    func testMyNewFeature() {
        // Arrange
        let manager = MyManager()

        // Act
        let result = manager.doSomething()

        // Assert
        XCTAssertEqual(result, expectedValue)
    }
}
```

### 6.3 Manual Testing Checklist

Before submitting PR:

- [ ] Tested on visionOS Simulator
- [ ] No console errors or warnings
- [ ] Tested happy path
- [ ] Tested edge cases
- [ ] Tested error conditions
- [ ] Checked performance (no lag)
- [ ] Verified accessibility (VoiceOver)

---

## 📖 Step 7: Essential Reading

### Must Read (30 min)
1. [README.md](README.md) - Project overview
2. [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
3. [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) - Community standards

### Should Read (1 hour)
4. [ARCHITECTURE.md](docs/ARCHITECTURE.md) - Technical architecture
5. [TECHNICAL_SPEC.md](docs/TECHNICAL_SPEC.md) - Implementation details
6. [TEST_PLAN.md](TEST_PLAN.md) - Testing strategy

### Reference (as needed)
7. [DESIGN.md](docs/DESIGN.md) - Game design document
8. [IMPLEMENTATION_PLAN.md](docs/IMPLEMENTATION_PLAN.md) - Roadmap

---

## 🔧 Development Tools

### Recommended Xcode Extensions

- **SwiftLint** - Code style enforcement
- **SwiftFormat** - Automatic code formatting
- **Sourcery** - Code generation

### Helpful Scripts

```bash
# Format all Swift files
./scripts/format-code.sh

# Run linter
./scripts/lint.sh

# Generate documentation
./scripts/generate-docs.sh
```

---

## 💡 Development Tips

### Swift 6.0 Best Practices

```swift
// Use @Observable for state (not @ObservableObject)
@Observable
class GameCoordinator {
    var currentState: GameState = .mainMenu
}

// Use structured concurrency
func loadCase() async throws {
    let data = try await fetchCaseData()
    await processData(data)
}

// Use typed throws (Swift 6.0)
func validateCase() throws(CaseError) {
    // ...
}
```

### RealityKit Tips

```swift
// Pool entities for performance
let evidencePool = EntityPool<EvidenceEntity>()

// Use async loading for models
let model = try await Entity.load(named: "evidence")

// Optimize with LOD
entity.components[LODComponent.self] = LODComponent(levels: ...)
```

### Debugging

```swift
// Use Swift's built-in debugger
print("Debug: \(value)")

// Breakpoints with conditions
// Right-click breakpoint → Edit Breakpoint → Add condition

// View hierarchy debugging
// Debug > View Debugging > Capture View Hierarchy
```

---

## 🚀 Next Steps

### Your First Week

**Day 1-2:** Setup and explore
- Complete this onboarding
- Build and run the app
- Navigate the codebase

**Day 3-4:** Small contribution
- Fix a bug or typo
- Update documentation
- Add a test

**Day 5:** Larger contribution
- Implement a small feature
- Create your first PR
- Participate in code review

### Getting Help

**Stuck? Ask for help!**

- **Discord:** `#dev-help` channel
- **GitHub:** Comment on your issue
- **Email:** dev@mysteryinvestigation.com
- **Pair Programming:** Schedule with team member

**No question is too small!** We're here to help.

---

## 📋 Onboarding Checklist

Track your progress:

### Environment Setup
- [ ] Installed Xcode 16.0+
- [ ] Installed visionOS SDK
- [ ] Cloned repository
- [ ] Configured Git
- [ ] Built project successfully
- [ ] Ran app on simulator

### Understanding
- [ ] Read essential documentation
- [ ] Explored codebase structure
- [ ] Understood architecture
- [ ] Reviewed coding standards
- [ ] Ran and understood tests

### Contributing
- [ ] Created feature branch
- [ ] Made first code change
- [ ] Ran tests successfully
- [ ] Created first commit
- [ ] Opened first PR

### Community
- [ ] Joined Discord
- [ ] Introduced yourself
- [ ] Read Code of Conduct
- [ ] Asked a question
- [ ] Helped someone else

---

## 🎉 Welcome to the Team!

You're now ready to contribute to Mystery Investigation! Remember:

- **Ask questions** - We're friendly and helpful
- **Start small** - Build confidence with small PRs
- **Review code** - Learn by reviewing others' PRs
- **Have fun** - We're building something amazing!

**Happy coding! 🔍✨**

---

## Appendix: Useful Commands

```bash
# Git
git status                  # Check status
git log --oneline          # View commit history
git diff                   # See changes
git stash                  # Save changes temporarily
git stash pop              # Restore stashed changes

# Xcode Build
xcodebuild clean           # Clean build
xcodebuild build           # Build from terminal
xcodebuild test            # Run tests from terminal

# Project
find . -name "*.swift" | xargs wc -l  # Count lines of Swift code
git log --author="Your Name" --oneline  # Your commits
```

## Appendix: Troubleshooting

**App crashes on launch:**
- Clean build folder (Cmd+Shift+K)
- Reset simulator (Device > Erase All Content and Settings)
- Check console for error messages

**Tests failing:**
- Ensure scheme is set to MysteryInvestigationTests
- Check for timing issues in async tests
- Verify test data is valid

**Git merge conflicts:**
- Update your branch: `git pull origin main`
- Resolve conflicts in Xcode
- Test after resolving
- Commit resolution

---

_Last Updated: January 19, 2025_
