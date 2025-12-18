# Spatial Code Reviewer - Developer Guide

**Version**: 1.0.0
**Last Updated**: November 25, 2025

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Project Structure](#project-structure)
3. [Core Components](#core-components)
4. [Development Setup](#development-setup)
5. [Building & Running](#building--running)
6. [Testing](#testing)
7. [Contributing](#contributing)
8. [Code Style](#code-style)

---

## Architecture Overview

### Design Pattern: MVVM

The app follows **Model-View-ViewModel (MVVM)** architecture:

- **Models**: Data structures (`Repository`, `FileNode`, `CodeTheme`)
- **Views**: SwiftUI views (`.swift` files in `Views/` folders)
- **ViewModels**: `@Observable` classes (`*Manager`, `*Service`)

### Layer Separation

```
┌─────────────────────────────────────┐
│         SwiftUI Views               │ ← User Interface
├─────────────────────────────────────┤
│    ViewModels / Managers            │ ← Business Logic
│  (SpatialManager, AuthService, etc) │
├─────────────────────────────────────┤
│    Services / Utilities             │ ← Data & Network
│  (GitHubAPIClient, LocalRepo, etc)  │
├─────────────────────────────────────┤
│         Models                      │ ← Data Structures
│  (Repository, FileNode, etc)        │
└─────────────────────────────────────┘
```

### Thread Safety

- **@MainActor**: All ViewModels and UI-updating classes
- **async/await**: Asynchronous operations (network, file I/O)
- **Task**: Background work without blocking UI

---

## Project Structure

```
SpatialCodeReviewer/
├── App/
│   ├── SpatialCodeReviewerApp.swift    # App entry point
│   └── AppState.swift                  # Global app state
│
├── Core/
│   ├── Models/                         # Data models
│   │   ├── Repository.swift
│   │   ├── FileNode.swift
│   │   └── User.swift
│   ├── Storage/
│   │   ├── LocalRepositoryManager.swift # File system
│   │   └── KeychainService.swift        # Secure storage
│   └── Utilities/
│       ├── PKCEHelper.swift             # OAuth utils
│       └── ErrorHandling.swift          # Error types
│
├── Features/
│   ├── Authentication/
│   │   ├── Services/
│   │   │   └── AuthService.swift
│   │   └── Views/
│   │       └── WelcomeView.swift
│   ├── Repository/
│   │   ├── Services/
│   │   │   ├── GitHubAPIClient.swift
│   │   │   └── RepositoryService.swift
│   │   └── Views/
│   │       ├── RepositoryListView.swift
│   │       └── RepositoryDetailView.swift
│   ├── CodeViewer/
│   │   ├── Components/
│   │   │   ├── CodeWindowComponent.swift    # RealityKit component
│   │   │   └── CodeWindowEntityFactory.swift
│   │   ├── Layout/
│   │   │   ├── HemisphereLayout.swift       # 3D positioning
│   │   │   ├── FocusLayout.swift
│   │   │   ├── GridLayout.swift
│   │   │   └── NestedLayout.swift
│   │   ├── Rendering/
│   │   │   ├── SyntaxHighlighter.swift      # Code tokenization
│   │   │   ├── CodeTheme.swift              # Color schemes
│   │   │   └── CodeContentRenderer.swift    # Texture generation
│   │   ├── Interaction/
│   │   │   └── GestureManager.swift         # Gesture handling
│   │   ├── Navigation/
│   │   │   └── FileNavigationManager.swift  # File tree navigation
│   │   ├── Managers/
│   │   │   └── SpatialManager.swift         # 3D scene coordinator
│   │   └── Views/
│   │       └── CodeReviewImmersiveView.swift # Main 3D view
│   └── Settings/
│       ├── SettingsManager.swift            # User preferences
│       └── SettingsPanelView.swift          # Settings UI
│
├── Resources/
│   └── Assets.xcassets/                     # Images, icons
│
└── Tests/
    ├── SpatialCodeReviewerTests/            # Unit tests
    └── SpatialCodeReviewerUITests/          # UI tests
```

---

## Core Components

### 1. Authentication Flow

**Files**: `AuthService.swift`, `PKCEHelper.swift`, `KeychainService.swift`

**OAuth 2.0 with PKCE Flow**:

```swift
// 1. Generate PKCE challenge
let verifier = PKCEHelper.generateCodeVerifier()
let challenge = PKCEHelper.generateCodeChallenge(from: verifier)

// 2. Build authorization URL
let authURL = "https://github.com/login/oauth/authorize?" +
              "client_id=\(clientID)" +
              "&redirect_uri=\(redirectURI)" +
              "&scope=repo%20user" +
              "&code_challenge=\(challenge)" +
              "&code_challenge_method=S256"

// 3. User authorizes in Safari

// 4. App receives callback with code
func handleCallback(code: String) async throws {
    let token = try await exchangeCodeForToken(code, verifier: verifier)
    try KeychainService.shared.saveToken(token)
}

// 5. Use token for API requests
let headers = ["Authorization": "Bearer \(token)"]
```

### 2. GitHub API Integration

**File**: `GitHubAPIClient.swift`

**Usage**:
```swift
let client = GitHubAPIClient.shared

// Fetch repositories (with pagination)
let repos = try await client.fetchRepositories(page: 1, perPage: 30)

// Search repositories
let results = try await client.searchRepositories(query: "visionOS")

// Download repository ZIP
let data = try await client.downloadRepository(
    owner: "apple",
    name: "swift",
    branch: "main"
)
```

**Pagination**:
```swift
// Link header: <https://api.github.com/repos?page=2>; rel="next"
func parseLinkHeader(_ linkHeader: String) -> Int? {
    // Extract next page number
}
```

### 3. File System Management

**File**: `LocalRepositoryManager.swift`

**Repository Storage**:
```
~/Documents/
  └── SpatialCodeReviewer/
      └── Repositories/
          ├── owner_repo_branch/
          │   ├── src/
          │   ├── README.md
          │   └── .metadata.json
          └── another_repo/
```

**Usage**:
```swift
let manager = LocalRepositoryManager.shared

// Save downloaded repository
try await manager.saveRepository(data, owner: "apple", name: "swift", branch: "main")

// Load file tree
let fileTree = try manager.loadFileTree(owner: "apple", name: "swift")

// Get file content
let content = try manager.getFileContent(path: "Sources/main.swift")
```

### 4. Syntax Highlighting

**File**: `SyntaxHighlighter.swift`

**Language Support**:
- Swift, Python, JavaScript, TypeScript, Go, Rust
- Java, C++, C, Ruby, PHP
- HTML, CSS, Markdown

**Tokenization**:
```swift
let highlighter = SyntaxHighlighter()
let tokens = highlighter.highlight(code: sourceCode, language: "swift")

// Token structure
struct SyntaxToken {
    let type: TokenType      // keyword, string, comment, etc.
    let text: String          // actual text
    let range: Range<String.Index>
    var color: Color          // from current theme
}
```

**Theme System**:
```swift
CodeTheme.current = .monokai
let keywordColor = CodeTheme.current.keyword  // Color

// Available themes
CodeTheme.allThemes = [
    .visionOSDark, .visionOSLight, .xcodeDark,
    .monokai, .solarizedDark, .githubLight, .dracula
]
```

### 5. 3D Rendering Pipeline

**Files**: `CodeContentRenderer.swift`, `CodeWindowEntityFactory.swift`

**SwiftUI → Texture → 3D Entity**:

```swift
// 1. Create SwiftUI view with highlighted code
let codeView = CodeContentView(lines: lines, language: "swift")

// 2. Render to CGImage
let renderer = ImageRenderer(content: codeView)
renderer.scale = 2.0  // Retina
let cgImage = renderer.cgImage

// 3. Convert to TextureResource
let textureResource = try await TextureResource.generate(
    from: cgImage,
    options: .init(semantic: .color)
)

// 4. Create material
var material = UnlitMaterial()
material.color = .init(texture: .init(textureResource))

// 5. Create mesh (plane)
let mesh = MeshResource.generatePlane(width: 0.4, height: 0.6)

// 6. Create entity
let entity = ModelEntity(mesh: mesh, materials: [material])
entity.position = [0, 1.5, -2]
```

### 6. Layout Algorithms

**Hemisphere Layout** (`HemisphereLayout.swift`):

```swift
// Golden ratio sphere packing
let goldenRatio = (1.0 + sqrt(5.0)) / 2.0
let goldenAngle = 2.0 * .pi * (1.0 - 1.0 / goldenRatio)

for i in 0..<count {
    let t = Float(i) / Float(max(count - 1, 1))
    let inclination = acos(1.0 - t)  // Vertical angle
    let azimuth = goldenAngle * Float(i)  // Horizontal angle

    // Convert spherical to Cartesian
    let x = radius * sin(inclination) * cos(azimuth)
    let y = radius * sin(inclination) * sin(azimuth)
    let z = -radius * cos(inclination)
}
```

### 7. Gesture System

**File**: `GestureManager.swift`

**Supported Gestures**:
```swift
// Tap
SpatialTapGesture()
    .targetedToAnyEntity()
    .onEnded { value in
        handleTap(on: value.entity)
    }

// Pinch (Scale)
MagnifyGesture()
    .onChanged { value in
        entity.scale *= Float(value.magnification)
        entity.scale = clamp(entity.scale, 0.3...2.0)
    }

// Drag (Move)
DragGesture()
    .onChanged { value in
        let translation = convert(value.translation)
        entity.position += translation
    }
```

### 8. Performance Optimizations

**Entity Pooling** (`EntityPool` in `SettingsManager.swift`):

```swift
class EntityPool {
    private var pool: [Entity] = []

    func acquire() -> Entity {
        return pool.popLast() ?? createEntity()
    }

    func release(_ entity: Entity) {
        entity.isEnabled = false
        pool.append(entity)
    }
}
```

**Level of Detail** (`LODSystem`):

```swift
func updateLOD(entity: Entity, cameraPos: SIMD3<Float>) {
    let distance = simd_distance(entity.position, cameraPos)

    switch distance {
    case 0..<2.0:
        entity.scale = [1, 1, 1]      // High detail
    case 2.0..<4.0:
        entity.scale = [0.8, 0.8, 1]  // Medium detail
    default:
        entity.scale = [0.6, 0.6, 1]  // Low detail
    }
}
```

---

## Development Setup

### Prerequisites

1. **Xcode 16.0+** (supports visionOS 2.0)
2. **macOS Sequoia 15.0+**
3. **Apple Vision Pro** (or simulator)
4. **Apple Developer Account** (for device testing)

### Installation

```bash
# Clone repository
git clone https://github.com/yourusername/spatial-code-reviewer.git
cd spatial-code-reviewer

# Open in Xcode
open SpatialCodeReviewer.xcodeproj

# Install dependencies (if using SPM)
# Dependencies are auto-resolved by Xcode
```

### Configuration

**GitHub OAuth Setup**:

1. Register app at https://github.com/settings/developers
2. Set redirect URI: `spatialcodereview://oauth/callback`
3. Add client ID to `AuthService.swift`:
   ```swift
   private let clientID = "your_client_id_here"
   ```

**Info.plist**:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
</dict>

<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>spatialcodereview</string>
        </array>
    </dict>
</array>
```

---

## Building & Running

### Xcode Build

1. **Select Target**: Vision Pro (Device or Simulator)
2. **Build**: Cmd + B
3. **Run**: Cmd + R

### Build Configurations

- **Debug**: Development builds with logging
- **Release**: Optimized for App Store submission

### Build Settings

- **Deployment Target**: visionOS 2.0
- **Swift Language Version**: 5.9
- **Optimization**: -Onone (Debug), -O (Release)

---

## Testing

### Unit Tests

**Location**: `Tests/SpatialCodeReviewerTests/`

**Run**: Cmd + U or `xcodebuild test`

**Test Coverage**: 80%+ goal

**Key Test Suites**:
- `PKCEHelperTests` (12 tests)
- `KeychainServiceTests` (16 tests)
- `LocalRepositoryManagerTests` (20 tests)
- `GitHubAPIIntegrationTests` (15 tests)
- `SyntaxHighlighterTests` (25 tests)

**Example Test**:
```swift
func testPKCECodeVerifierGeneration() {
    let verifier = PKCEHelper.generateCodeVerifier()

    XCTAssertGreaterThanOrEqual(verifier.count, 43)
    XCTAssertLessThanOrEqual(verifier.count, 128)
    XCTAssertTrue(verifier.isBase64URLEncoded)
}
```

### UI Tests

**Location**: `Tests/SpatialCodeReviewerUITests/`

**Run**: Cmd + U (with UI Testing scheme)

**Test Suites**:
- `AuthenticationFlowUITests` (10 tests)
- `RepositoryFlowUITests` (15 tests)

**Example UI Test**:
```swift
func testRepositorySelection() throws {
    let app = XCUIApplication()
    app.launch()

    // Tap first repository
    let firstRepo = app.buttons["repository-cell-0"]
    XCTAssertTrue(firstRepo.waitForExistence(timeout: 5))
    firstRepo.tap()

    // Verify detail view
    XCTAssertTrue(app.staticTexts["Repository Details"].exists)
}
```

### Performance Tests

**Instruments**:
- Time Profiler: Identify hot paths
- Allocations: Track memory usage
- Leaks: Detect memory leaks

**Benchmarks**:
```swift
func testLoadTime() {
    measure {
        _ = try? SpatialManager().loadRepository(owner: "test", name: "repo")
    }

    // Target: < 2 seconds for small repos
}
```

---

## Contributing

### Workflow

1. **Fork** the repository
2. **Create feature branch**: `git checkout -b feature/my-feature`
3. **Commit changes**: `git commit -m "Add my feature"`
4. **Push**: `git push origin feature/my-feature`
5. **Create Pull Request** on GitHub

### PR Guidelines

- **Title**: Clear, descriptive (e.g., "Add Python syntax highlighting")
- **Description**: What, why, how
- **Tests**: Include unit tests for new features
- **Screenshots**: For UI changes
- **Documentation**: Update relevant docs

### Code Review

All PRs require:
- ✅ Passing CI/CD tests
- ✅ Code review approval (1+ maintainer)
- ✅ No merge conflicts
- ✅ Updated documentation (if needed)

---

## Code Style

### Swift Style Guide

Follow [Apple's Swift Style Guide](https://www.swift.org/documentation/api-design-guidelines/)

**Key Points**:
- **Naming**: camelCase for properties/methods, PascalCase for types
- **Indentation**: 4 spaces (no tabs)
- **Line Length**: 120 characters max
- **Access Control**: Use `private`, `fileprivate`, `internal`, `public` appropriately
- **Documentation**: `///` for public APIs

**Example**:
```swift
/// Manages 3D spatial layout of code windows
@MainActor
class SpatialManager: ObservableObject {

    // MARK: - Properties

    /// Currently loaded code entities
    @Published private(set) var entities: [Entity] = []

    /// Loading state indicator
    @Published var isLoading: Bool = false

    // MARK: - Public Methods

    /// Loads repository into 3D space
    /// - Parameters:
    ///   - owner: Repository owner
    ///   - name: Repository name
    /// - Throws: `SpatialError` if loading fails
    func loadRepository(owner: String, name: String) async throws {
        isLoading = true
        defer { isLoading = false }

        // Implementation...
    }

    // MARK: - Private Methods

    private func createEntity(for file: FileNode) -> Entity {
        // Implementation...
    }
}
```

### SwiftUI Best Practices

- **Extract Views**: Keep views < 100 lines
- **ViewModels**: Use `@ObservableObject` for complex state
- **@State**: For simple local state
- **@Binding**: For passing state down
- **PreferenceKeys**: For passing data up

### RealityKit Best Practices

- **Component-based**: Use ECS pattern
- **@MainActor**: Always for Entity manipulation
- **Async**: Use for texture/resource loading
- **Memory**: Release entities when done

---

## API Reference

See [API_REFERENCE.md](./API_REFERENCE.md) for detailed API documentation.

---

## Useful Resources

- [visionOS Documentation](https://developer.apple.com/visionos/)
- [RealityKit Documentation](https://developer.apple.com/documentation/realitykit/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [GitHub REST API](https://docs.github.com/en/rest)

---

**Questions?** Open an issue or discussion on GitHub!

**© 2025 Spatial Code Reviewer**
