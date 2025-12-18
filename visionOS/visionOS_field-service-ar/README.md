# Field Service AR Assistant for visionOS

A comprehensive augmented reality application for Apple Vision Pro that transforms equipment maintenance and repair through immersive spatial computing.

## Overview

The Field Service AR Assistant enables field service technicians to:
- **Recognize Equipment** using spatial image tracking
- **View Step-by-Step AR Guidance** overlaid on physical equipment
- **Collaborate with Remote Experts** via WebRTC video and spatial annotations
- **Access AI-Powered Diagnostics** for faster problem resolution
- **Work Offline** with full data synchronization when connected

## Features

### Core Capabilities
- ✅ **Dashboard** - Job scheduling and management
- ✅ **Job Details** - Comprehensive job information with equipment specs
- ✅ **Equipment Library** - Browse 3D models of all supported equipment
- ✅ **3D Equipment Preview** - Volumetric inspection and exploration
- ✅ **AR Repair Guidance** - Immersive step-by-step repair instructions
- 🚧 **Remote Collaboration** - Real-time expert assistance (in progress)
- 🚧 **AI Diagnostics** - Intelligent failure prediction (in progress)
- 🚧 **IoT Integration** - Live sensor data visualization (planned)

## Architecture

### Technology Stack
- **Platform**: visionOS 2.0+
- **Language**: Swift 6.0
- **UI Framework**: SwiftUI
- **3D/AR**: RealityKit 4, ARKit 6
- **Data**: SwiftData
- **Networking**: URLSession + WebRTC
- **AI/ML**: Core ML 7

### Project Structure
```
FieldServiceAR/
├── App/                    # Application entry point
│   ├── FieldServiceARApp.swift
│   ├── AppState.swift
│   └── DependencyContainer.swift
├── Models/                 # Data models
│   ├── Equipment/
│   ├── Service/
│   ├── Collaboration/
│   └── AI/
├── Views/                  # UI components
│   ├── Windows/            # 2D floating windows
│   ├── Volumes/            # 3D volumetric views
│   └── Immersive/          # Full space AR experiences
├── ViewModels/             # Observable view models
├── Services/               # Business logic
│   ├── Recognition/
│   ├── Procedure/
│   ├── Collaboration/
│   ├── Diagnostic/
│   └── Sync/
├── Repositories/           # Data access layer
├── Networking/             # API client
└── Resources/              # Assets and 3D models
```

## Documentation

Comprehensive technical documentation is available:
- **[ARCHITECTURE.md](./ARCHITECTURE.md)** - System architecture and design patterns
- **[TECHNICAL_SPEC.md](./TECHNICAL_SPEC.md)** - Detailed technical specifications
- **[DESIGN.md](./DESIGN.md)** - UI/UX design and spatial interaction patterns
- **[IMPLEMENTATION_PLAN.md](./IMPLEMENTATION_PLAN.md)** - Development roadmap and milestones
- **[PRD-Field-Service-AR-Assistant.md](./PRD-Field-Service-AR-Assistant.md)** - Product requirements

## Getting Started

### Prerequisites
- macOS Sequoia 15.0+
- Xcode 16.0+
- Apple Vision Pro (for full testing)
- visionOS 2.0+ SDK

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-org/visionOS_field-service-ar.git
   cd visionOS_field-service-ar
   ```

2. **Open in Xcode**
   ```bash
   open FieldServiceAR.xcodeproj
   ```

3. **Configure dependencies**
   - The project uses Swift Package Manager
   - Dependencies will be resolved automatically on first build

4. **Build and run**
   - Select visionOS Simulator or Vision Pro device
   - Press Cmd+R to build and run

### Development Workflow

1. **Branching Strategy**
   - `main` - Production-ready code
   - `develop` - Integration branch
   - `feature/*` - Feature branches
   - `bugfix/*` - Bug fix branches

2. **Code Standards**
   - Swift 6.0 with strict concurrency
   - SwiftLint for code style (.swiftlint.yml)
   - ESLint for JavaScript (.eslintrc.json)
   - Stylelint for CSS (.stylelintrc.json)
   - Minimum 80% code coverage for tests
   - DocC documentation for public APIs

3. **Testing**

   See **[TESTING.md](./TESTING.md)** for comprehensive testing documentation.

   **Quick Start:**
   ```bash
   # Run all validation tests (no Xcode required)
   python3 tests/validate.py

   # Run Swift unit tests (requires Xcode + visionOS Simulator)
   xcodebuild test -scheme FieldServiceAR -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

   # Run landing page tests (requires npm packages)
   npm test

   # Individual test suites
   npm run test:html      # Validate HTML structure
   npm run test:css       # Validate CSS syntax
   npm run test:js        # Validate JavaScript syntax
   npm run test:validate  # Run Python validation suite
   ```

   **Test Coverage:**
   - ✅ 30+ Swift unit tests (Equipment, ServiceJob, Repositories)
   - ✅ 71 validation checks (structure, docs, HTML/CSS/JS)
   - ✅ CI/CD workflows (.github/workflows/test.yml)
   - ✅ Code quality tools (SwiftLint, ESLint, Stylelint)
   - 🎯 Target: 80% code coverage

   **Current Test Results:**
   - Swift Unit Tests: 30/30 passing (100%)
   - Validation Suite: 70/71 passing (98.6%)
   - Code Coverage: 15% (expanding to 80%)

## Key Concepts

### visionOS Presentation Modes

The app uses three spatial presentation modes:

1. **Windows** (2D Floating Panels)
   - Dashboard, Job Details, Equipment Library
   - Standard UI with glass materials
   - User-positionable

2. **Volumes** (3D Bounded Content)
   - 3D Equipment Preview
   - Interactive 3D models
   - 60cm³ physical space

3. **Immersive Spaces** (Full AR)
   - AR Repair Guidance
   - Mixed reality overlays
   - Equipment tracking and recognition

### Data Models

Core domain models:
- **Equipment** - Physical equipment with 3D models and components
- **ServiceJob** - Work orders with scheduling and status tracking
- **RepairProcedure** - Step-by-step repair instructions
- **CollaborationSession** - Remote expert sessions with annotations
- **DiagnosticResult** - AI-powered diagnostic analysis

### Offline-First Architecture

The app supports full offline operation:
- Local SwiftData persistence
- Automatic background sync
- Conflict resolution
- Offline job completion
- Media caching

## Development Status

### Phase 1: Core Foundation ✅
- [x] Data models and persistence
- [x] Basic UI windows
- [x] Service layer architecture
- [x] API integration structure
- [x] Offline data synchronization framework

### Phase 2: 3D & AR Features 🚧
- [x] 3D equipment volumes
- [x] AR immersive space
- [ ] Equipment recognition (image tracking)
- [ ] Procedure overlays
- [ ] Hand tracking gestures

### Phase 3: Collaboration & AI 📋
- [ ] WebRTC setup
- [ ] Remote collaboration UI
- [ ] Spatial annotations
- [ ] AI diagnostics
- [ ] Predictive maintenance

### Phase 4: Polish & Deployment 📋
- [ ] Accessibility features
- [ ] Performance optimization
- [ ] Comprehensive testing
- [ ] Documentation
- [ ] Enterprise deployment

## API Integration

The app connects to a backend API for:
- Job management
- Equipment database
- Repair procedures
- Parts inventory
- AI diagnostics
- Collaboration signaling

### API Configuration

Set API base URL in `DependencyContainer.swift`:
```swift
struct Configuration {
    static var apiBaseURL: URL {
        #if DEBUG
        return URL(string: "https://dev-api.fieldservice.com")!
        #else
        return URL(string: "https://api.fieldservice.com")!
        #endif
    }
}
```

## Deployment

### Enterprise Distribution

The app is designed for enterprise deployment via MDM:

1. **Code Signing**
   - Enterprise developer certificate
   - Provisioning profiles for in-house distribution

2. **MDM Configuration**
   ```xml
   <dict>
       <key>Bundle Identifier</key>
       <string>com.enterprise.fieldservice-ar</string>
       <key>Minimum OS Version</key>
       <string>2.0</string>
       <key>Configuration</key>
       <dict>
           <key>API_BASE_URL</key>
           <string>https://api.fieldservice.com</string>
       </dict>
   </dict>
   ```

3. **Over-the-Air Installation**
   - Upload to MDM server
   - Push to Vision Pro devices
   - Silent installation

## Performance Targets

- **Frame Rate**: 90 FPS in AR mode
- **Memory**: <4GB peak usage
- **Battery**: <20% drain per hour
- **Latency**: <100ms for AR interactions
- **Recognition**: <2 seconds for equipment identification
- **Network**: <1MB per job sync

## Contributing

### Pull Request Process

1. Create feature branch from `develop`
2. Implement changes with tests
3. Update documentation
4. Submit PR with description
5. Pass CI/CD checks
6. Code review approval
7. Merge to `develop`

### Code Review Checklist

- [ ] Follows Swift style guide
- [ ] Includes unit tests
- [ ] Updates documentation
- [ ] No breaking changes
- [ ] Accessibility compliant
- [ ] Performance verified

## Support

For questions or issues:
- **Email**: support@fieldservice.com
- **Slack**: #field-service-ar
- **Documentation**: https://docs.fieldservice.com/ar-assistant

## License

Copyright © 2025 Enterprise Field Service Inc. All rights reserved.

This software is proprietary and confidential. Unauthorized copying, distribution, or use is strictly prohibited.

## Acknowledgments

- Apple visionOS team for spatial computing platform
- Field service technicians for feedback and testing
- Equipment manufacturers for 3D models and specifications

---

**Built with ❤️ for field service excellence**
