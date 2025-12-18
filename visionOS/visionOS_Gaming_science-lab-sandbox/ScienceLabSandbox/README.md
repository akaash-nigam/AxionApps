# Science Lab Sandbox - visionOS Application

Complete Swift codebase for Science Lab Sandbox educational gaming application.

## Project Structure

```
ScienceLabSandbox/
├── App/                        # Main application entry points
│   ├── ScienceLabSandboxApp.swift
│   └── GameCoordinator.swift
├── Game/                       # Game logic and state
│   ├── GameLogic/
│   ├── GameState/
│   ├── Entities/
│   └── Components/
├── Systems/                    # Core game systems
│   ├── PhysicsSystem/
│   ├── InputSystem/
│   ├── AudioSystem/
│   └── AISystem/
├── Scenes/                     # RealityKit scenes
│   ├── MenuScene/
│   ├── LaboratoryScene/
│   └── ImmersiveViews/
├── Views/                      # SwiftUI views
│   ├── UI/
│   └── HUD/
├── Models/                     # Data models
├── Resources/                  # Assets and resources
├── Utilities/                  # Helper functions
└── Tests/                      # Unit and integration tests
```

## Requirements

- **macOS**: macOS 15.0 Sequoia or later
- **Xcode**: Xcode 16.0 or later
- **visionOS SDK**: visionOS 2.0 SDK
- **Apple Vision Pro**: Device or visionOS Simulator

## How to Open in Xcode

### Option 1: Create New Xcode Project (Recommended)

1. Open Xcode 16+
2. File → New → Project
3. Select **visionOS** → **App**
4. Configure project:
   - Product Name: `ScienceLabSandbox`
   - Interface: `SwiftUI`
   - Language: `Swift`
5. Copy all files from this directory into your new Xcode project
6. Replace the generated files with the corresponding files from this codebase

### Option 2: Use Swift Package

1. Open Xcode 16+
2. File → Open
3. Navigate to and select `Package.swift` in the parent directory
4. Xcode will recognize it as a Swift Package
5. Build and run

### Option 3: Manual Xcode Project Creation

If you need to create a complete `.xcodeproj`:

1. Open Terminal
2. Navigate to parent directory
3. Run: `swift package generate-xcodeproj` (if using SPM)
4. Open the generated `.xcodeproj` file

## Building the Project

1. Select target: **ScienceLabSandbox**
2. Select destination: **Apple Vision Pro** or **visionOS Simulator**
3. Product → Build (⌘B)
4. Product → Run (⌘R)

## Project Configuration

### Build Settings

- **Swift Version**: 6.0
- **Deployment Target**: visionOS 2.0
- **Concurrency**: Strict concurrency checking enabled
- **Optimization**: `-O` for Release, `-Onone` for Debug

### Capabilities Required

Add these in Xcode project settings:

- **Hand Tracking**: Required for gesture input
- **Scene Understanding**: Required for spatial anchoring
- **Group Activities**: Required for multiplayer features

### Entitlements

Create `ScienceLabSandbox.entitlements`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.arkit.hand-tracking</key>
    <true/>
    <key>com.apple.developer.scene-understanding</key>
    <true/>
    <key>com.apple.developer.group-activities</key>
    <true/>
</dict>
</plist>
```

## Running on Simulator

1. Open Xcode
2. Select **visionOS Simulator** as destination
3. Build and Run
4. Use keyboard/mouse to simulate hand gestures:
   - **Click**: Tap gesture
   - **Click + Drag**: Pan/rotate
   - **Option + Click**: Pinch gesture

## Running on Device

1. Connect Apple Vision Pro via WiFi or USB-C
2. Trust the device in Xcode
3. Select device as destination
4. Build and Run
5. App will install and launch on Vision Pro

## Key Features Implemented

### Core Systems
- ✅ Game state management
- ✅ Experiment lifecycle management
- ✅ Physics simulation
- ✅ Input handling (hand tracking foundation)
- ✅ Spatial audio system
- ✅ AI tutor system
- ✅ Save/load system

### Data Models
- ✅ Experiments
- ✅ Scientific equipment
- ✅ Chemicals
- ✅ Player progress
- ✅ Achievements

### UI/UX
- ✅ Main menu
- ✅ Settings
- ✅ Progress view
- ✅ Immersive laboratory
- ✅ Experiment volume view

### Scientific Disciplines
- ⚠️ Chemistry (foundation implemented)
- ⚠️ Physics (foundation implemented)
- ⚠️ Biology (planned)
- ⚠️ Astronomy (planned)

## Next Steps for Development

### Immediate Priorities

1. **Complete Scientific Simulations**
   - Implement full chemistry reaction engine
   - Implement physics calculation systems
   - Add biology simulation
   - Add astronomy simulation

2. **Expand RealityKit Components**
   - Create detailed 3D models for equipment
   - Implement custom RealityKit components
   - Add particle systems for reactions
   - Implement advanced visual effects

3. **Complete Input Systems**
   - Integrate ARKit hand tracking
   - Implement eye tracking
   - Add voice command recognition
   - Implement gesture recognition

4. **Add 3D Assets**
   - Create or import 3D models for all equipment
   - Add textures and materials
   - Create particle effects
   - Add audio assets

5. **Expand Experiment Library**
   - Add 50+ experiments across disciplines
   - Create detailed instructions
   - Add assessment criteria
   - Implement hints and guidance

### Testing

Run unit tests:
```bash
swift test
```

Run in Xcode:
- Product → Test (⌘U)

## Troubleshooting

### "Cannot find type 'Entity' in scope"
- Ensure `import RealityKit` is present
- Check that visionOS SDK is selected

### "Hand tracking not available"
- Check that entitlements are configured
- Verify hand tracking capability is enabled
- Ensure running on Vision Pro or simulator with hand tracking support

### Build Errors
- Clean build folder: Product → Clean Build Folder (⌘⇧K)
- Reset package cache: File → Packages → Reset Package Caches
- Restart Xcode

## Documentation

See parent directory for complete documentation:
- `ARCHITECTURE.md` - Technical architecture
- `TECHNICAL_SPEC.md` - Technical specifications
- `DESIGN.md` - Game design document
- `IMPLEMENTATION_PLAN.md` - Development roadmap

## License

Copyright © 2025 Science Lab Sandbox. All rights reserved.

## Support

For issues and questions:
- Review documentation in parent directory
- Check Xcode console for error messages
- Verify all requirements are met
