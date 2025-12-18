# Legal Discovery Universe - Build Instructions

## Overview

This is a visionOS application for Apple Vision Pro that transforms legal document review through immersive 3D spatial computing. The app enables legal professionals to visualize evidence, navigate document galaxies, and discover patterns in complex litigation cases.

## Prerequisites

### Required Software
- **macOS**: Sequoia (15.0+) or later
- **Xcode**: 16.0+ with visionOS SDK
- **Apple Vision Pro**: Hardware device or simulator
- **Apple Developer Account**: Required for device deployment

### Knowledge Requirements
- Swift 6.0+ (with strict concurrency)
- SwiftUI for visionOS
- RealityKit fundamentals
- SwiftData (Apple's modern persistence framework)
- Basic understanding of MVVM architecture

## Project Structure

```
LegalDiscoveryUniverse/
├── LegalDiscoveryUniverse/
│   ├── App/
│   │   ├── LegalDiscoveryUniverseApp.swift    # App entry point
│   │   └── ContentView.swift                   # Root content view
│   │
│   ├── Models/                                 # Data models (SwiftData)
│   │   ├── LegalCase.swift                    # Case management
│   │   ├── LegalDocument.swift                # Document model
│   │   ├── LegalEntity.swift                  # Entity & relationships
│   │   ├── Timeline.swift                     # Timeline events
│   │   └── Annotation.swift                   # Annotations & comments
│   │
│   ├── Views/
│   │   ├── Windows/                           # 2D window views
│   │   │   ├── CaseDashboardView.swift       # Main dashboard
│   │   │   ├── DocumentViewerView.swift      # Document viewer
│   │   │   └── SearchResultsView.swift       # Search interface
│   │   │
│   │   ├── Volumes/                           # 3D bounded volumes
│   │   │   └── EvidenceClusterView.swift     # Document clusters
│   │   │
│   │   └── ImmersiveViews/                   # Full immersive spaces
│   │       ├── EvidenceUniverseView.swift    # 3D document galaxy
│   │       └── TimelineImmersiveView.swift   # Timeline visualization
│   │
│   ├── ViewModels/                            # View models (future)
│   │
│   ├── Services/                              # Business logic (future)
│   │   # Will include:
│   │   # - DocumentService.swift
│   │   # - SearchService.swift
│   │   # - AIDiscoveryService.swift
│   │   # - SpatialService.swift
│   │   # - SecurityService.swift
│   │
│   ├── Utilities/                             # Helpers and extensions
│   │
│   └── Resources/
│       ├── Assets.xcassets                    # App icons, images
│       └── 3DModels/                          # 3D assets (Reality Composer)
│
├── Tests/
│   ├── LegalDiscoveryUniverseTests/          # Unit tests
│   └── LegalDiscoveryUniverseUITests/        # UI tests
│
├── Package.swift                              # Swift Package Manager
└── BUILD.md                                   # This file
```

## Architecture

### Technology Stack
- **Platform**: visionOS 2.0+
- **Language**: Swift 6.0 (strict concurrency)
- **UI Framework**: SwiftUI
- **3D Framework**: RealityKit
- **Persistence**: SwiftData
- **Architecture**: MVVM (Model-View-ViewModel)

### Key Design Patterns
- **Observable Macro**: SwiftUI state management (@Observable)
- **SwiftData Models**: @Model macro for persistence
- **Actor Isolation**: Thread-safe services using actors
- **Async/Await**: Modern Swift concurrency throughout

## Building the Project

### Step 1: Open in Xcode

Since this is a complete source code structure but not a generated Xcode project, you'll need to create an Xcode project:

1. **Open Xcode 16+**
2. **Create New Project**: File > New > Project
3. **Select Template**: visionOS > App
4. **Project Settings**:
   - Product Name: `LegalDiscoveryUniverse`
   - Team: Your development team
   - Organization Identifier: `com.yourcompany`
   - Interface: SwiftUI
   - Language: Swift
   - Storage: SwiftData

5. **Replace Generated Files**:
   - Copy all files from this source structure into the new project
   - Maintain the folder hierarchy
   - Replace the auto-generated App file and ContentView

### Step 2: Configure Project Settings

In Xcode project settings:

1. **General Tab**:
   - Deployment Target: visionOS 2.0
   - Supported Destinations: Apple Vision Pro

2. **Signing & Capabilities**:
   - Enable automatic signing with your Apple Developer account
   - Add capabilities if needed (currently none required for MVP)

3. **Build Settings**:
   - Swift Language Version: Swift 6
   - Enable Strict Concurrency Checking: Yes

### Step 3: Build

```bash
# In Xcode:
# 1. Select target device (Apple Vision Pro or Simulator)
# 2. Product > Build (⌘B)
# 3. Product > Run (⌘R)
```

### Step 4: Test

```bash
# Run tests in Xcode:
# Product > Test (⌘U)
```

## Development Workflow

### Running on Simulator

1. **Select Simulator**: Apple Vision Pro simulator in Xcode
2. **Build & Run**: ⌘R
3. **Interact**: Use mouse/trackpad for gaze, click for tap gestures

### Running on Device

1. **Connect Vision Pro**: USB-C cable to Mac
2. **Trust Device**: Follow on-screen prompts
3. **Select Device**: Choose your Vision Pro in Xcode
4. **Build & Run**: ⌘R (first run may take a few minutes)

### Tips for visionOS Development

- **Simulator Limitations**: Some features (hand tracking, eye tracking) only work on device
- **3D Content**: Test RealityKit scenes on device for accurate performance
- **Spatial Audio**: Test audio on device for proper 3D positioning
- **Performance**: Profile early with Instruments (90 FPS target)

## Current Implementation Status

### ✅ Completed (MVP Foundation)
- [x] Project structure
- [x] SwiftData models (LegalCase, LegalDocument, etc.)
- [x] Main dashboard UI (WindowGroup)
- [x] Case management interface
- [x] Document viewer (basic)
- [x] Search interface (UI only)
- [x] Evidence Universe (placeholder 3D)
- [x] Timeline visualization (placeholder 3D)

### 🚧 In Progress / TODO
- [ ] Document upload and ingestion
- [ ] PDF rendering and text extraction
- [ ] Full-text search implementation
- [ ] AI integration (OpenAI/Anthropic)
- [ ] Complete 3D visualization
- [ ] Hand gesture recognition
- [ ] Collaboration features
- [ ] Security and encryption
- [ ] Accessibility (VoiceOver)
- [ ] Comprehensive testing
- [ ] Performance optimization

## Common Issues & Solutions

### Build Errors

**Issue**: "Cannot find type 'LegalCase' in scope"
**Solution**: Ensure all model files are added to the target

**Issue**: "Module 'RealityKit' not found"
**Solution**: Check that visionOS SDK is selected as deployment target

### Runtime Errors

**Issue**: SwiftData crashes on launch
**Solution**: Delete app from simulator/device, rebuild

**Issue**: 3D content not appearing
**Solution**: Check RealityView implementation and entity hierarchy

### Performance Issues

**Issue**: Low frame rate in immersive mode
**Solution**:
- Reduce polygon count on 3D models
- Implement LOD (Level of Detail) system
- Profile with Instruments

## Next Steps

Refer to the **IMPLEMENTATION_PLAN.md** for the detailed 24-week development roadmap.

### Immediate Next Phase (Weeks 7-12):
1. Implement document upload
2. Add full-text search
3. Build annotation system
4. Implement security layer

### Resources

- [visionOS Documentation](https://developer.apple.com/visionos/)
- [RealityKit Documentation](https://developer.apple.com/documentation/realitykit/)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata/)
- [ARCHITECTURE.md](../ARCHITECTURE.md) - Technical architecture
- [TECHNICAL_SPEC.md](../TECHNICAL_SPEC.md) - Technical specifications
- [DESIGN.md](../DESIGN.md) - Design guidelines
- [IMPLEMENTATION_PLAN.md](../IMPLEMENTATION_PLAN.md) - Development roadmap

## License

Copyright © 2025. All rights reserved.

## Contact

For questions or support, contact the development team.

---

**Note**: This is an MVP implementation. Many features from the PRD and design documents are planned but not yet implemented. See IMPLEMENTATION_PLAN.md for the full development timeline.
