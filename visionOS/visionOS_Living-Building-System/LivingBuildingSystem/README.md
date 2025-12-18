# Living Building System - MVP

> Intelligent home interface for Apple Vision Pro

## Overview

This is the MVP (Minimum Viable Product) implementation of the Living Building System. It provides core smart home device control through a visionOS spatial interface.

## Features (MVP)

- ✅ HomeKit device discovery
- ✅ Device control (lights, switches, thermostats, locks)
- ✅ Real-time state updates
- ✅ SwiftData persistence
- ✅ Multi-window interface
- ✅ Error handling and logging

## Requirements

- **Xcode**: 15.2 or later
- **visionOS SDK**: 2.0 or later
- **Swift**: 6.0 or later
- **Target**: Apple Vision Pro or visionOS Simulator

## Project Structure

```
LivingBuildingSystem/
├── Package.swift                       # Swift Package configuration
├── Sources/LivingBuildingSystem/
│   ├── App/                           # Main app entry point
│   │   └── LivingBuildingSystemApp.swift
│   ├── Presentation/                  # UI layer
│   │   └── WindowViews/
│   │       ├── DashboardView.swift   # Main dashboard
│   │       ├── DeviceDetailView.swift # Device controls
│   │       └── SettingsView.swift    # Settings
│   ├── Application/                   # Business logic
│   │   └── Managers/
│   │       └── DeviceManager.swift   # Device operations
│   ├── Domain/                        # Core models & state
│   │   ├── Models/
│   │   │   ├── Home.swift
│   │   │   ├── Room.swift
│   │   │   ├── SmartDevice.swift
│   │   │   ├── DeviceState.swift
│   │   │   ├── User.swift
│   │   │   └── UserPreferences.swift
│   │   └── State/
│   │       └── AppState.swift         # Centralized state
│   ├── Integrations/                  # External services
│   │   └── HomeKit/
│   │       ├── HomeKitServiceProtocol.swift
│   │       └── HomeKitService.swift
│   ├── Utilities/                     # Helpers
│   │   ├── Constants/
│   │   │   └── LBSError.swift
│   │   └── Helpers/
│   │       └── Logger.swift
│   └── Resources/
│       └── Info.plist                 # App permissions
└── Tests/
    └── LivingBuildingSystemTests/
```

## Building the Project

### 1. Open in Xcode

```bash
cd LivingBuildingSystem
open Package.swift
```

Xcode will automatically resolve the Swift Package.

### 2. Select Target

- Select the `LivingBuildingSystem` scheme
- Choose "Apple Vision Pro" simulator as the destination

### 3. Build & Run

```bash
# Command line build
swift build

# Or use Xcode:
# Product > Run (⌘R)
```

## Setup Instructions

### First Launch

1. **Launch the app** on visionOS Simulator or device
2. **Grant HomeKit permission** when prompted
3. **Tap "Refresh"** button to discover devices
4. **View devices** on the dashboard
5. **Tap a device** to open detailed controls

### Adding Sample Data (Debug Mode)

For testing without real HomeKit devices:

1. Open **Settings** (gear icon in toolbar)
2. Scroll to **Debug** section
3. Tap **"Load Sample Data"**
4. Return to dashboard to see sample devices

### HomeKit Setup

To use with real devices:

1. **Set up Home app** on iPhone/iPad first
2. **Add devices** to Home app
3. **Launch Living Building System**
4. Devices will automatically appear after discovery

## Key Features

### Dashboard

- Device status overview
- Device count, active count, reachable count
- Device grid with quick toggle
- Tap device card for details

### Device Detail

- Full device information
- On/Off toggle (lights, switches, outlets)
- Brightness slider (lights)
- Temperature control (thermostats)
- Real-time state updates

### Settings

- Home configuration
- Device statistics
- Debug utilities (sample data, clear data)

## Architecture

### State Management

- **@Observable** for reactive updates
- **AppState** as single source of truth
- **SwiftData** for persistence

### Service Layer

- **Protocol-based** for testability
- **Actor-isolated** for thread safety
- **Async/await** for all operations

### UI Layer

- **SwiftUI** declarative UI
- **Multi-window** support
- **Material design** for visionOS

## Troubleshooting

### No Devices Discovered

- Ensure Home app is set up with devices
- Check that device is on same network
- Verify HomeKit permission granted
- Try "Load Sample Data" in Settings (debug)

### Build Errors

- Clean build folder: **Product > Clean Build Folder** (⇧⌘K)
- Reset package cache: **File > Packages > Reset Package Caches**
- Ensure Xcode 15.2+ installed
- Verify visionOS SDK installed

### Runtime Errors

- Check logs in **Console.app** (filter: com.lbs.app)
- Enable verbose logging in scheme settings
- File issue on GitHub with logs

## Development

### Running Tests

```bash
# Command line
swift test

# Xcode
# Product > Test (⌘U)
```

### Adding New Device Types

1. Add to `DeviceType` enum in `SmartDevice.swift`
2. Update `determineDeviceType` in `HomeKitService.swift`
3. Add control UI in `DeviceDetailView.swift`

### Debugging

- Set breakpoints in Xcode
- Use `Logger.shared.log()` for custom logging
- Check Console.app for system logs
- Use Instruments for performance profiling

## Next Steps (Post-MVP)

See `docs/mvp-and-epics.md` for roadmap:

- **Epic 1**: Spatial Interface (ImmersiveSpace, room scanning)
- **Epic 2**: Energy Monitoring (smart meter integration)
- **Epic 3**: Advanced Energy Visualization (RealityKit flows)
- **Epic 4**: Environmental Monitoring (sensors)
- **Epic 5**: Maintenance Tracking
- **Epic 6**: Scenes & Automation
- **Epic 7**: Advanced Spatial Features
- **Epic 8**: Performance & Polish

## Resources

- [Design Documentation](../docs/)
- [System Architecture](../docs/system-architecture.md)
- [Data Models](../docs/data-models-schema.md)
- [API Integration Specs](../docs/api-integration-specs.md)
- [PRD](../PRD.md)

## License

See LICENSE file in repository root.

## Support

For issues, questions, or contributions, please open an issue on GitHub.
