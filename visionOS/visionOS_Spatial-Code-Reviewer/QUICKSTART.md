# Quick Start Guide for Developers

## Prerequisites

### Required
- macOS 14.0+ (Sonoma)
- Xcode 15.0+ with visionOS SDK
- Apple Developer Account (for device testing)
- Git installed

### Recommended
- Apple Vision Pro (or simulator)
- GitHub account
- Familiarity with Swift, SwiftUI, and RealityKit

## Setup Instructions

### 1. Clone Repository

```bash
git clone https://github.com/akaash-nigam/visionOS_Spatial-Code-Reviewer.git
cd visionOS_Spatial-Code-Reviewer
```

### 2. Create Xcode Project

Since we're starting fresh, create the Xcode project:

```bash
# Open Xcode
open /Applications/Xcode.app

# File > New > Project
# Choose: visionOS > App
# Product Name: SpatialCodeReviewer
# Interface: SwiftUI
# Language: Swift
```

### 3. Configure Project Settings

#### In Xcode:
1. Select project in navigator
2. Set deployment target: visionOS 2.0
3. Configure signing:
   - Team: Your Apple Developer Team
   - Bundle Identifier: com.yourteam.spatialcodereviewer

#### Add Capabilities:
1. Go to Signing & Capabilities
2. Add capabilities:
   - [ ] Keychain Sharing
   - [ ] Group Activities
   - [ ] CloudKit (optional for now)

### 4. Add Dependencies

Create `Package.swift` or use Xcode SPM:

```swift
dependencies: [
    .package(url: "https://github.com/tree-sitter/swift-tree-sitter", from: "0.20.0"),
]
```

### 5. Configure OAuth (Development)

Create `Config.plist` in project:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>GITHUB_CLIENT_ID</key>
    <string>YOUR_DEV_CLIENT_ID</string>
    <key>GITHUB_CLIENT_SECRET</key>
    <string>YOUR_DEV_CLIENT_SECRET</string>
</dict>
</plist>
```

**Note**: Get OAuth credentials from GitHub:
1. Go to GitHub Settings > Developer settings > OAuth Apps
2. Create new OAuth App
3. Homepage URL: `http://localhost`
4. Callback URL: `spatialcodereviewer://oauth/github`

### 6. Build and Run

```bash
# In Xcode:
# 1. Select Apple Vision Pro Simulator
# 2. Product > Build (⌘B)
# 3. Product > Run (⌘R)
```

## Project Structure

```
SpatialCodeReviewer/
├── SpatialCodeReviewerApp.swift    # App entry point
├── ContentView.swift                # Main view
├── Features/
│   ├── Authentication/              # Auth flow
│   ├── Repository/                  # Repo browsing
│   └── CodeViewer/                  # 3D code view
├── Core/
│   ├── Networking/                  # API clients
│   ├── Storage/                     # Persistence
│   └── Extensions/                  # Swift extensions
├── Models/                          # Data models
├── Resources/                       # Assets, fonts
└── Tests/                           # Unit & UI tests
```

## Development Workflow

### Starting a New Feature

1. **Create Branch**
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/story-0.X-description
   ```

2. **Implement Feature**
   - Write code following Swift style guide
   - Add unit tests
   - Update documentation

3. **Test Locally**
   ```bash
   # Run tests
   ⌘U in Xcode

   # Or via command line
   xcodebuild test -scheme SpatialCodeReviewer -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
   ```

4. **Create Pull Request**
   ```bash
   git add .
   git commit -m "feat: implement story 0.X"
   git push origin feature/story-0.X-description
   ```

   Then create PR on GitHub targeting `develop` branch.

### Code Review Process

1. Create PR with description
2. Request review from team
3. Address feedback
4. Ensure CI passes
5. Merge when approved

## Common Tasks

### Running Tests

```bash
# All tests
⌘U

# Specific test
⌘-click on test method name > Run
```

### Debugging in Simulator

1. Set breakpoints
2. Run app (⌘R)
3. Use debugger console
4. Use RealityKit debugger: Debug > View Debugging

### Performance Profiling

1. Product > Profile (⌘I)
2. Choose Instruments template:
   - Time Profiler (CPU usage)
   - Allocations (Memory)
   - Metal System Trace (GPU)

### Viewing Logs

```bash
# In Console.app
# Filter by: SpatialCodeReviewer

# Or in Xcode console
# View > Debug Area > Activate Console (⌘⇧Y)
```

## Troubleshooting

### Build Failures

**Issue**: Missing dependencies
```bash
# Solution: Reset package cache
File > Packages > Reset Package Caches
```

**Issue**: Signing errors
```bash
# Solution: Check team and provisioning
# Xcode > Preferences > Accounts
# Verify team is selected in project settings
```

### Simulator Issues

**Issue**: Simulator slow or unresponsive
```bash
# Solution: Reset simulator
Device > Erase All Content and Settings
```

**Issue**: App crashes on launch
```bash
# Solution: Clean build
Product > Clean Build Folder (⌘⇧K)
# Then rebuild
```

### Runtime Errors

**Issue**: OAuth redirect not working
```bash
# Solution: Check URL scheme in Info.plist
# Add: spatialcodereviewer
```

**Issue**: RealityKit entities not visible
```bash
# Solution: Check entity positioning
# Use RealityKit debugger
# Verify lighting setup
```

## Coding Standards

### Swift Style Guide

```swift
// Use clear, descriptive names
func fetchRepositories() async throws -> [Repository] { }

// Group related code
// MARK: - Repository Management

// Document public APIs
/// Fetches repositories from GitHub for the authenticated user.
/// - Returns: Array of Repository objects
/// - Throws: APIError if request fails

// Use guard for early returns
guard let token = authToken else {
    throw AuthError.notAuthenticated
}

// Prefer async/await over callbacks
let repos = try await apiService.fetchRepositories()
```

### Testing Guidelines

```swift
// Given-When-Then pattern
func testRepositoryFetch() async throws {
    // Given
    let mockService = MockGitHubService()
    mockService.mockRepositories = [testRepo]

    // When
    let repos = try await mockService.fetchRepositories()

    // Then
    XCTAssertEqual(repos.count, 1)
    XCTAssertEqual(repos[0].name, "test-repo")
}
```

## Resources

### Documentation
- [System Architecture](docs/01-system-architecture.md)
- [Data Models](docs/02-data-models.md)
- [Implementation Roadmap](IMPLEMENTATION_ROADMAP.md)
- [MVP Plan](MVP_DETAILED_PLAN.md)

### External Resources
- [visionOS Documentation](https://developer.apple.com/visionos/)
- [RealityKit Docs](https://developer.apple.com/documentation/realitykit)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [GitHub API](https://docs.github.com/en/rest)

### Team Communication
- Slack: #spatial-code-reviewer-dev
- GitHub Issues: Bug tracking
- GitHub Discussions: Technical Q&A
- Daily Standup: 9:00 AM

## Getting Help

### Common Questions

**Q: How do I test without a Vision Pro device?**
A: Use the visionOS Simulator in Xcode. Most features work in simulator.

**Q: What if I'm blocked on a task?**
A: Post in Slack #spatial-code-reviewer-dev or raise in daily standup.

**Q: How do I handle merge conflicts?**
A:
```bash
git checkout develop
git pull origin develop
git checkout your-branch
git merge develop
# Resolve conflicts in Xcode
git commit
```

**Q: Where do I add new dependencies?**
A: Use Swift Package Manager via Xcode:
   File > Add Packages > Enter package URL

### Contact

- **Tech Lead**: [Your Name]
- **Product Manager**: [PM Name]
- **Designer**: [Designer Name]

---

## Next Steps

1. ✅ Complete setup above
2. ✅ Review [MVP Plan](MVP_DETAILED_PLAN.md)
3. ✅ Join Slack channels
4. ✅ Attend sprint planning
5. ✅ Pick up first story from backlog

**Ready to code!** 🚀

Start with: [Story 0.1: App Shell](IMPLEMENTATION_ROADMAP.md#story-01-app-shell)
