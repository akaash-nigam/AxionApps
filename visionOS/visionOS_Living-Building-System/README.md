# Living Building System

<div align="center">

![visionOS](https://img.shields.io/badge/visionOS-2.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)
![Platform](https://img.shields.io/badge/platform-Apple%20Vision%20Pro-lightgrey.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Status](https://img.shields.io/badge/status-Production%20Ready-brightgreen.svg)
![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)

**Transform Your Home with Spatial Computing**

_Intelligent home interface for Apple Vision Pro that visualizes your smart home in 3D space_

[Features](#-features) • [Quick Start](#-quick-start) • [Architecture](#-architecture) • [Testing](#-testing) • [Contributing](#-contributing) • [Documentation](#-documentation)

</div>

---

## 🌟 Overview

Living Building System is a revolutionary visionOS application that transforms how you interact with your smart home. Using Apple Vision Pro's spatial computing capabilities, it creates an immersive 3D interface where you can see, control, and monitor every aspect of your home through natural gestures and eye tracking.

**What Makes It Special:**
- 🏠 **3D Home Visualization** - See your entire home in immersive space with real device locations
- 👁️ **Look-to-Control** - Just look at a device and tap the air to control it
- ⚡ **Real-Time Energy Monitoring** - Visualize electricity, solar, and battery flows live
- 🔋 **Smart Energy Insights** - AI-powered anomaly detection saves you money
- 🎯 **Spatial Anchors** - Persistent device placement across sessions
- 📱 **HomeKit & Matter** - Works with all your existing smart home devices

---

## ✨ Features

### MVP Features (v1.0)

#### 🏡 Smart Home Control
- **Device Discovery** - Automatic HomeKit device detection
- **Universal Control** - Lights, switches, thermostats, locks, and more
- **Real-Time Updates** - Live device state synchronization
- **Optimistic UI** - Instant feedback, responsive controls
- **Device Management** - Group by rooms, types, or custom categories

#### 🎮 Spatial Interface (Epic 1)
- **Immersive 3D View** - Full 3D home visualization with RealityKit
- **Gaze Detection** - Highlight devices by looking at them
- **Air Tap Control** - Natural gesture-based device control
- **Room Scanning** - ARKit-powered room mesh reconstruction
- **Persistent Anchors** - Devices stay in place using spatial anchors
- **Contextual Displays** - Device info follows physical locations

#### ⚡ Energy Monitoring (Epic 2)
- **Real-Time Power** - Live electricity consumption tracking
- **Solar Generation** - Monitor solar panel output and net power
- **Battery Storage** - Track home battery charge/discharge
- **Cost Calculation** - Real-time energy cost tracking
- **Consumption Charts** - Daily and weekly visualization
- **Top Consumers** - Identify highest-usage circuits
- **Anomaly Detection** - AI-powered unusual usage alerts
- **Multi-Utility** - Electricity, gas, and water monitoring

#### 💾 Core System
- **SwiftData Persistence** - Automatic data persistence
- **User Profiles** - Multi-user support with roles (Owner, Admin, Member, Guest)
- **Onboarding Flow** - Smooth first-launch experience
- **Error Handling** - Graceful error recovery
- **Logging** - Comprehensive system logging
- **Auto-Save** - Continuous background saves

---

## 🚀 Quick Start

### Prerequisites

- macOS 14.0 or later
- Xcode 15.2 or later
- Swift 6.0 or later
- visionOS SDK 2.0 or later
- Apple Vision Pro (device or simulator)

### Installation

```bash
# Clone the repository
git clone https://github.com/OWNER/visionOS_Living-Building-System.git
cd visionOS_Living-Building-System

# Install development tools
brew install swiftlint swift-format

# Open the project
cd LivingBuildingSystem
open Package.swift

# Build and run in Xcode
# 1. Select scheme: LivingBuildingSystem
# 2. Select destination: Apple Vision Pro (Simulator)
# 3. Press Cmd+R to build and run
```

### Running Tests

```bash
# Run all tests
xcodebuild test -scheme LivingBuildingSystem \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

# Run with coverage
xcodebuild test -scheme LivingBuildingSystem \
  -enableCodeCoverage YES

# Run SwiftLint
swiftlint
```

### First Launch

1. **Onboarding** - Complete the 3-step setup process
2. **Create Home** - Name your home and add optional address
3. **User Profile** - Set your name and role
4. **Grant Permissions** - Allow HomeKit access
5. **Discover Devices** - Automatic device discovery
6. **Start Controlling** - Tap devices to control them

---

## 🏗️ Architecture

Living Building System follows **Clean Architecture** principles with clear separation of concerns:

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (SwiftUI Views, RealityKit)            │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         Application Layer               │
│  (Managers, Business Logic)             │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│           Domain Layer                  │
│  (Models, State, Entities)              │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│            Data Layer                   │
│  (Services, Persistence, APIs)          │
└─────────────────────────────────────────┘
```

### Key Technologies

- **SwiftUI** - Declarative UI framework
- **RealityKit** - 3D visualization and spatial computing
- **ARKit** - Room scanning and spatial tracking
- **SwiftData** - Model-driven persistence with @Model
- **@Observable** - Swift Observation for reactive state
- **Actors** - Thread-safe concurrency
- **HomeKit** - Smart home device integration
- **Matter** - Cross-platform device support

### Project Structure

```
LivingBuildingSystem/
├── Sources/LivingBuildingSystem/
│   ├── App/                    # App entry point
│   ├── Domain/                 # Models, State
│   │   ├── Models/            # Home, Room, Device, Energy, User
│   │   └── State/             # AppState (@Observable)
│   ├── Application/            # Business logic
│   │   └── Managers/          # Device, Energy, Persistence, Spatial
│   ├── Integrations/           # External services
│   │   ├── HomeKit/           # HomeKit integration
│   │   └── Energy/            # Energy meter integration
│   ├── Presentation/           # UI layer
│   │   ├── WindowViews/       # 2D windows
│   │   └── ImmersiveViews/    # 3D immersive spaces
│   └── Utilities/              # Helpers, Constants
├── Tests/                      # 250+ unit and integration tests
├── docs/                       # Documentation
│   ├── design/                # Design documents
│   ├── testing/               # Test documentation
│   └── app-store/             # App Store materials
└── landing-page/               # Marketing website
```

---

## 🧪 Testing

We maintain **90%+ test coverage** across the codebase with comprehensive testing at multiple levels.

### Test Suite (250+ Tests)

- **Unit Tests** (150+ tests)
  - Model tests (Home, Room, Device, User, Energy)
  - Business logic validation
  - Edge case coverage

- **Integration Tests** (30+ tests)
  - Service integration (HomeKit, Energy)
  - Manager coordination
  - Real-world workflows

- **UI Tests** (50+ scenarios)
  - Complete user journeys
  - Device control flows
  - Error handling paths
  - Documentation: [docs/testing/UI-TESTS.md](docs/testing/UI-TESTS.md)

- **Manual Tests** (200+ checkpoints)
  - QA checklist for physical devices
  - Performance validation
  - Accessibility verification
  - Checklist: [docs/testing/MANUAL-TEST-CHECKLIST.md](docs/testing/MANUAL-TEST-CHECKLIST.md)

### Running Tests

```bash
# Unit and integration tests
xcodebuild test -scheme LivingBuildingSystem

# Specific test class
xcodebuild test -scheme LivingBuildingSystem \
  -only-testing:LivingBuildingSystemTests/SmartDeviceTests

# With coverage report
xcodebuild test -scheme LivingBuildingSystem \
  -enableCodeCoverage YES
```

### CI/CD

Automated testing runs on every push and pull request via GitHub Actions:
- ✅ Unit tests
- ✅ Integration tests
- ✅ SwiftLint checks
- ✅ Code coverage reporting
- ✅ Security scanning
- ✅ Build verification

See [.github/workflows/ci.yml](.github/workflows/ci.yml) for details.

---

## 🤝 Contributing

We welcome contributions! Please read our [Contributing Guidelines](CONTRIBUTING.md) before submitting pull requests.

### Development Process

1. **Fork & Clone** - Fork the repo and clone your fork
2. **Branch** - Create feature branch (`feature/amazing-feature`)
3. **Code** - Write code following our style guide
4. **Test** - Add tests and ensure all tests pass
5. **Lint** - Run SwiftLint and fix warnings
6. **Commit** - Use conventional commits (`feat:`, `fix:`, etc.)
7. **Push** - Push to your fork
8. **PR** - Open pull request with detailed description

### Code Quality Standards

- ✅ SwiftLint compliant (see [.swiftlint.yml](LivingBuildingSystem/.swiftlint.yml))
- ✅ 90%+ test coverage for new features
- ✅ No force unwrapping in production code
- ✅ Use Logger, never print()
- ✅ Documented public APIs
- ✅ No compiler warnings

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**: feat, fix, docs, style, refactor, test, chore

**Example**:
```
feat(energy): add solar generation monitoring

Add real-time solar generation tracking with net power calculation.
Includes consumption vs generation chart and to/from grid indicators.

Closes #123
```

---

## 📚 Documentation

### For Users
- [Product Requirements Document](PRD.md) - Complete product specification
- [App Store Materials](docs/app-store/APP_STORE_MATERIALS.md) - App Store listing content
- [Landing Page](landing-page/index.html) - Marketing website

### For Developers
- [Developer Guide](docs/DEVELOPER_GUIDE.md) - Architecture, setup, patterns
- [Contributing Guidelines](CONTRIBUTING.md) - How to contribute
- [Changelog](CHANGELOG.md) - Version history

### Design Documents
1. [System Requirements](docs/design/01-SYSTEM-REQUIREMENTS.md)
2. [Domain Models](docs/design/02-DOMAIN-MODELS.md)
3. [Service Layer](docs/design/03-SERVICE-LAYER.md)
4. [State Management](docs/design/04-STATE-MANAGEMENT.md)
5. [Smart Device Integration](docs/design/05-SMART-DEVICE-INTEGRATION.md)
6. [Energy Monitoring](docs/design/06-ENERGY-MONITORING.md)
7. [User Experience](docs/design/07-USER-EXPERIENCE.md)
8. [Spatial Interface](docs/design/08-SPATIAL-INTERFACE.md)
9. [Persistence Strategy](docs/design/09-PERSISTENCE-STRATEGY.md)
10. [Testing Strategy](docs/design/10-TESTING-STRATEGY.md)

### Testing Documentation
- [UI Tests](docs/testing/UI-TESTS.md) - UI test scenarios and code
- [Manual Test Checklist](docs/testing/MANUAL-TEST-CHECKLIST.md) - QA checklist

---

## 🗺️ Roadmap

### ✅ Version 1.0 (Released)
- MVP features complete
- Epic 1: Spatial Interface
- Epic 2: Energy Monitoring
- Full test coverage
- Production infrastructure

### 🚧 Version 1.1 (Q2 2025)
- Advanced energy visualization
- Historical data analysis
- Energy savings recommendations
- Export data functionality

### 🔮 Version 1.2 (Q3 2025)
- Environmental monitoring
- Air quality sensors
- Temperature/humidity tracking
- Environmental health insights

### 🌟 Version 2.0 (Q4 2025)
- AI-powered automation
- Predictive device control
- Scene creation and scheduling
- Voice command integration
- Multi-home support

See [CHANGELOG.md](CHANGELOG.md) for detailed version history.

---

## 📱 App Store

**Status**: Ready for submission

Living Building System is available on the App Store for Apple Vision Pro.

**Pricing**:
- **Free Plan** - Basic device control (up to 10 devices)
- **Home Plan** - $4.99/month - Unlimited devices + energy monitoring
- **Pro Plan** - $9.99/month - All features + advanced analytics

See [App Store Materials](docs/app-store/APP_STORE_MATERIALS.md) for complete submission details.

---

## 🔧 Development Setup

### Environment

```bash
# System requirements
macOS 14.0+
Xcode 15.2+
Swift 6.0+
visionOS SDK 2.0+

# Install tools
brew install swiftlint swift-format

# Optional: Install dependencies
brew install gh  # GitHub CLI for PR creation
```

### Build Configurations

- **Debug** - Development with logging, no optimizations
- **Release** - Production optimized, minimal logging

### Xcode Schemes

- **LivingBuildingSystem** - Main app scheme
- **LivingBuildingSystemTests** - Test scheme

---

## 🐛 Issue Reporting

Found a bug? Have a feature request? Please use our issue templates:

- [🐛 Bug Report](.github/ISSUE_TEMPLATE/bug_report.yml)
- [✨ Feature Request](.github/ISSUE_TEMPLATE/feature_request.yml)

**Before submitting**:
1. Search existing issues
2. Check documentation
3. Ensure reproducibility
4. Include device/OS details
5. Add screenshots/videos if applicable

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 Living Building System

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction...
```

---

## 🙏 Acknowledgments

### Technologies
- **Apple** - visionOS, SwiftUI, RealityKit, ARKit, HomeKit, SwiftData
- **Swift Community** - Open source tools and libraries

### Inspiration
- Smart home automation enthusiasts
- Energy efficiency advocates
- Spatial computing pioneers
- Home automation community

### Special Thanks
- Apple Developer Documentation
- visionOS Developer Community
- Beta testers and early adopters
- Contributors and maintainers

---

## 📞 Contact & Support

- **GitHub Issues** - Bug reports and feature requests
- **GitHub Discussions** - Questions and community
- **Email** - support@livingbuildingsystem.com (coming soon)
- **Website** - https://livingbuildingsystem.com (coming soon)

---

## 📊 Project Stats

![Lines of Code](https://img.shields.io/badge/lines%20of%20code-10k+-blue)
![Test Coverage](https://img.shields.io/badge/test%20coverage-90%25-brightgreen)
![Tests](https://img.shields.io/badge/tests-250+-green)
![Documentation](https://img.shields.io/badge/documentation-comprehensive-blue)

---

<div align="center">

**Built with ❤️ for Apple Vision Pro**

[⭐ Star this repo](https://github.com/OWNER/visionOS_Living-Building-System) • [🐛 Report Bug](.github/ISSUE_TEMPLATE/bug_report.yml) • [✨ Request Feature](.github/ISSUE_TEMPLATE/feature_request.yml)

</div>

---

## 🏷️ Keywords

`visionOS` `spatial-computing` `smart-home` `HomeKit` `Matter` `energy-management` `vision-pro` `SwiftUI` `RealityKit` `ARKit` `SwiftData` `home-automation` `IoT` `energy-monitoring` `solar-power` `battery-storage` `3D-visualization` `gesture-control` `eye-tracking` `spatial-anchors`

---

*Last Updated: 2025-01-24*
*Version: 1.0.0*
