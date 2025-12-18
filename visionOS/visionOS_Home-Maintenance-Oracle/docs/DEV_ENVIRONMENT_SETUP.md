# Development Environment Setup Guide
## Home Maintenance Oracle

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Draft

---

## Prerequisites

### Hardware Requirements

**Required**:
- Mac with Apple Silicon (M1 or later) **OR** Intel Mac (2018 or later)
- macOS 14.0 (Sonoma) or later
- 16GB RAM minimum, 32GB recommended
- 50GB free disk space

**For Testing**:
- Apple Vision Pro (for device testing)
- iPhone 15 Pro (for Persona testing)

### Software Requirements

- Xcode 15.2 or later
- visionOS SDK 1.0+
- Command Line Tools
- Git 2.30+
- CocoaPods or Swift Package Manager

---

## Installation Steps

### 1. Install Xcode

```bash
# Install from Mac App Store (recommended)
# OR download from Apple Developer portal

# Verify installation
xcode-select --version

# Install command line tools
xcode-select --install

# Accept license
sudo xcodebuild -license accept
```

### 2. Install visionOS SDK

```bash
# Open Xcode
# Xcode > Settings > Platforms
# Download "visionOS" platform

# Verify
xcodebuild -showsdks | grep visionOS
```

### 3. Set Up Git

```bash
# Install Git (if not already installed)
brew install git

# Configure
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Set up SSH key for GitHub
ssh-keygen -t ed25519 -C "your.email@example.com"
cat ~/.ssh/id_ed25519.pub
# Add to GitHub: Settings > SSH Keys
```

### 4. Clone Repository

```bash
# Clone the repo
git clone git@github.com:your-org/home-maintenance-oracle.git
cd home-maintenance-oracle

# Create development branch
git checkout -b dev/your-name
```

---

## Project Setup

### 1. Install Dependencies

#### Swift Package Manager (Recommended)

Dependencies are managed in `Package.swift`:

```swift
// Package.swift
let package = Package(
    name: "HomeMaintenanceOracle",
    platforms: [
        .visionOS(.v1)
    ],
    dependencies: [
        // Add dependencies here
    ],
    targets: [
        .target(
            name: "HomeMaintenanceOracle",
            dependencies: []
        )
    ]
)
```

In Xcode:
1. File > Add Package Dependencies
2. Enter package URL
3. Select version/branch
4. Add to target

#### Common Dependencies

```swift
dependencies: [
    // Networking (optional, URLSession is built-in)
    .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0"),

    // SwiftLint (code quality)
    .package(url: "https://github.com/realm/SwiftLint.git", from: "0.54.0"),
]
```

### 2. Configure Code Signing

```bash
# Open project in Xcode
open HomeMaintenanceOracle.xcodeproj

# In Xcode:
# 1. Select project in navigator
# 2. Select target
# 3. Signing & Capabilities tab
# 4. Team: Select your Apple Developer team
# 5. Bundle Identifier: com.yourorg.homemaintenanceoracle
```

### 3. Set Up CloudKit

```bash
# In Xcode:
# 1. Signing & Capabilities
# 2. Click "+ Capability"
# 3. Add "iCloud"
# 4. Check "CloudKit"
# 5. Add container: iCloud.com.yourorg.homemaintenanceoracle
```

### 4. Configure Core Data

```bash
# Create Core Data model
# File > New > File > Data Model
# Name: HomeMaintenanceOracle.xcdatamodeld

# Add entities as per DATA_MODEL.md
```

---

## Development Tools

### 1. SwiftLint (Code Style)

```bash
# Install via Homebrew
brew install swiftlint

# Create .swiftlint.yml
cat > .swiftlint.yml << EOF
disabled_rules:
  - trailing_whitespace
opt_in_rules:
  - empty_count
  - empty_string
included:
  - HomeMaintenanceOracle
excluded:
  - Pods
  - Build
line_length: 120
EOF

# Add build phase in Xcode
# Target > Build Phases > New Run Script Phase
# Script: swiftlint
```

### 2. SwiftFormat (Auto-formatting)

```bash
# Install
brew install swiftformat

# Create .swiftformat
cat > .swiftformat << EOF
--indent 4
--maxwidth 120
--wraparguments before-first
--wrapcollections before-first
EOF

# Format code
swiftformat .
```

### 3. Instruments (Profiling)

```bash
# Profile app performance
# Xcode > Product > Profile
# OR: Cmd+I

# Common instruments:
# - Time Profiler (CPU usage)
# - Allocations (memory usage)
# - Leaks (memory leaks)
# - Network (API calls)
```

---

## Xcode Configuration

### Recommended Settings

```bash
# Xcode > Settings

# General:
# - Issue Navigator: Show only issues
# - Navigation: Uses Focused Editor

# Text Editing:
# - Indentation: 4 spaces
# - Line endings: Unix (LF)
# - Enable: Trim trailing whitespace
# - Enable: Add newline at end of file

# Behaviors:
# - Running starts: Show Debug Navigator
# - Running completes: Show Project Navigator
```

### Useful Keyboard Shortcuts

```
# Navigation
Cmd+Shift+O         Open Quickly
Cmd+Shift+J         Reveal in Navigator
Cmd+Ctrl+←/→        Navigate back/forward

# Editing
Cmd+/               Toggle comment
Cmd+Ctrl+E          Rename symbol
Cmd+Shift+F         Find in project

# Building & Running
Cmd+B               Build
Cmd+R               Run
Cmd+U               Run tests
Cmd+.               Stop

# Debugging
Cmd+\               Toggle breakpoint
Cmd+Y               Activate/deactivate breakpoints
Ctrl+Cmd+Y          Continue execution
F6                  Step over
F7                  Step into
```

---

## Running the App

### Vision Pro Simulator

```bash
# Select scheme
# Toolbar: HomeMaintenanceOracle > Apple Vision Pro

# Run
Cmd+R

# Simulator controls:
# - Mouse: Look around
# - Click: Tap gesture
# - Drag: Pinch gesture
# - Spacebar: Reset view
```

### Physical Device

**Requirements**:
- Apple Vision Pro
- Developer mode enabled
- Same Wi-Fi network as Mac

```bash
# Enable Developer Mode on Vision Pro:
# Settings > Privacy & Security > Developer Mode > On

# Connect to Mac:
# Window > Devices and Simulators
# Select Vision Pro
# Trust computer

# Run on device:
# Select "Apple Vision Pro (Your Device)"
# Cmd+R
```

### Debugging Tips

```swift
// Print debugging
print("Debug: \(variable)")

// Breakpoint logging
// Right-click breakpoint > Edit Breakpoint
// Add: Log Message: "Value is @variable@"
// Check: Automatically continue after evaluating

// LLDB commands
po variable                    // Print object
p variable                     // Print value
expr variable = newValue       // Modify value
bt                            // Backtrace
```

---

## Testing Setup

### Unit Tests

```bash
# Create test target
# File > New > Target > Unit Testing Bundle

# Run tests
Cmd+U

# Run specific test
# Right-click test function > Run "testName"
```

### UI Tests

```bash
# Record UI test
# 1. Create UI test file
# 2. Place cursor in test function
# 3. Click record button (red dot)
# 4. Interact with app
# 5. Stop recording

# Generated code example:
let app = XCUIApplication()
app.buttons["Scan Appliance"].tap()
```

### Test Coverage

```bash
# Enable code coverage
# Scheme > Edit Scheme > Test
# Options > Code Coverage: ✓ Gather coverage

# View coverage
# Report Navigator (Cmd+9)
# Select test run
# Coverage tab
```

---

## Database Setup

### Core Data

```swift
// AppDelegate or @main
import CoreData

class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "HomeMaintenanceOracle")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
}

// In your App struct:
@main
struct HomeMaintenanceOracleApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
```

### CloudKit Setup

```bash
# Dashboard:
# https://icloud.developer.apple.com/

# Create record types:
# 1. CKAppliance
# 2. CKMaintenanceTask
# 3. CKServiceHistory

# Set up indexes for queries
```

---

## API Configuration

### Local API Server (Development)

```bash
# Backend API (Python Flask example)
cd backend
python3 -m venv venv
source venv/bin/activate
pip install flask flask-cors

# Run server
python app.py
# Server running on http://localhost:5000
```

### API Keys Setup

```bash
# Create Config.xcconfig
cat > Config.xcconfig << EOF
MANUAL_API_KEY = your_api_key_here
YOUTUBE_API_KEY = your_youtube_key
AMAZON_ACCESS_KEY = your_amazon_key
EOF

# Add to .gitignore
echo "Config.xcconfig" >> .gitignore

# In Xcode:
# Project > Info > Configurations
# Set Config.xcconfig for Debug/Release

# Access in code:
let apiKey = Bundle.main.object(forInfoDictionaryKey: "MANUAL_API_KEY") as? String
```

**Secure Alternative**: Use Keychain

```swift
enum APIKeys {
    static var manualAPIKey: String {
        // Fetch from Keychain or environment
        KeychainManager.shared.get(key: "manual_api_key") ?? ""
    }
}
```

---

## ML Model Setup

### Core ML Model Integration

```bash
# Add .mlmodel file to project
# Xcode will auto-generate Swift class

# Usage:
import CoreML

let model = try ApplianceClassifier(configuration: MLModelConfiguration())
let input = try ApplianceClassifierInput(imageWith: cgImage)
let prediction = try model.prediction(input: input)
```

### Training Models (Optional)

```bash
# Install Python dependencies
pip install torch torchvision coremltools

# Train model
python train_model.py

# Convert to Core ML
python convert_to_coreml.py

# Add ApplianceClassifier.mlmodel to Xcode project
```

---

## CI/CD Setup (Optional)

### GitHub Actions

```yaml
# .github/workflows/build.yml
name: Build and Test

on: [push, pull_request]

jobs:
  build:
    runs-on: macos-14

    steps:
    - uses: actions/checkout@v3

    - name: Select Xcode
      run: sudo xcode-select -s /Applications/Xcode_15.2.app

    - name: Build
      run: xcodebuild build -scheme HomeMaintenanceOracle -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

    - name: Test
      run: xcodebuild test -scheme HomeMaintenanceOracle -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

---

## Troubleshooting

### Common Issues

**Issue**: "Unable to boot the Simulator"
```bash
# Solution:
sudo killall -9 com.apple.CoreSimulator.CoreSimulatorService
xcrun simctl shutdown all
```

**Issue**: "Code signing error"
```bash
# Solution:
# 1. Xcode > Settings > Accounts
# 2. Download Manual Profiles
# 3. Clean Build Folder (Cmd+Shift+K)
# 4. Rebuild
```

**Issue**: "CloudKit not working"
```bash
# Solution:
# 1. Check iCloud signed in (System Settings)
# 2. Verify CloudKit capability added
# 3. Check container identifier matches
# 4. Reset CloudKit Development Environment (iCloud Dashboard)
```

**Issue**: "Module not found"
```bash
# Solution:
# File > Packages > Reset Package Caches
# File > Packages > Update to Latest Package Versions
```

---

## Project Structure

```
HomeMaintenanceOracle/
├── HomeMaintenanceOracle/
│   ├── App/
│   │   ├── HomeMaintenanceOracleApp.swift
│   │   └── AppDependencies.swift
│   ├── Presentation/
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   └── Components/
│   ├── Domain/
│   │   ├── Entities/
│   │   └── UseCases/
│   ├── Data/
│   │   ├── CoreData/
│   │   ├── Repositories/
│   │   └── Models/
│   ├── Services/
│   │   ├── Recognition/
│   │   ├── API/
│   │   └── Storage/
│   ├── Resources/
│   │   ├── Assets.xcassets
│   │   ├── CoreML/
│   │   └── Localizable.strings
│   └── Supporting Files/
│       └── Info.plist
├── HomeMaintenanceOracleTests/
├── HomeMaintenanceOracleUITests/
├── docs/
├── .gitignore
├── .swiftlint.yml
└── README.md
```

---

## Git Workflow

### Branch Strategy

```bash
# Main branches
main            # Production releases
develop         # Integration branch

# Feature branches
feature/recognition
feature/manual-viewer
feature/maintenance

# Create feature branch
git checkout develop
git pull
git checkout -b feature/your-feature

# Commit changes
git add .
git commit -m "Add feature: brief description"

# Push
git push origin feature/your-feature

# Create Pull Request on GitHub
```

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting
- `refactor`: Code restructuring
- `test`: Adding tests
- `chore`: Maintenance

**Example**:
```
feat(recognition): Add refrigerator detection

- Implement refrigerator classification
- Add test cases
- Update model accuracy threshold

Closes #123
```

---

## Next Steps

1. ✅ Complete environment setup
2. ✅ Run sample project
3. ✅ Create first feature branch
4. ✅ Write first test
5. ✅ Make first commit

---

## Resources

### Documentation
- [visionOS Developer Guide](https://developer.apple.com/visionos/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Core ML Guide](https://developer.apple.com/documentation/coreml)
- [RealityKit Documentation](https://developer.apple.com/documentation/realitykit)

### Community
- [Apple Developer Forums](https://developer.apple.com/forums/)
- [r/visionOS](https://reddit.com/r/visionOS)
- [Swift Forums](https://forums.swift.org/)

### Tools
- [SF Symbols](https://developer.apple.com/sf-symbols/)
- [Create ML](https://developer.apple.com/documentation/createml)
- [Reality Composer Pro](https://developer.apple.com/augmented-reality/tools/)

---

**Document Status**: Ready for Use
**Questions**: Contact the tech lead or file an issue on GitHub
