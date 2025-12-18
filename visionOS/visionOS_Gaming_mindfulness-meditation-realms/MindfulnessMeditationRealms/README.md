# Mindfulness Meditation Realms - Source Code

## Overview

This directory contains the Swift source code for the Mindfulness Meditation Realms visionOS application. The codebase is organized following clean architecture principles with clear separation of concerns.

## Project Structure

```
MindfulnessMeditationRealms/
├── App/                          # Application entry point and coordination
│   ├── MeditationApp.swift       # Main app entry (@main)
│   ├── AppCoordinator.swift      # Central app coordinator
│   └── Configuration.swift       # App-wide configuration and constants
│
├── Core/                         # Core business logic
│   ├── Meditation/               # Meditation session management
│   ├── Biometric/                # Biometric monitoring and analysis
│   ├── AI/                       # AI adaptation and personalization
│   └── Audio/                    # Spatial audio engine
│
├── Spatial/                      # Spatial computing features
│   ├── RealityKitSystems/        # Custom RealityKit systems
│   ├── Components/               # RealityKit components
│   ├── RoomMapping/              # ARKit room analysis
│   └── Interaction/              # Gesture and gaze interaction
│
├── Multiplayer/                  # SharePlay and group meditation
│
├── Data/                         # Data layer
│   ├── Models/                   # Data models
│   │   ├── UserProfile.swift
│   │   ├── MeditationSession.swift
│   │   ├── BiometricSnapshot.swift
│   │   ├── MeditationEnvironment.swift
│   │   └── UserProgress.swift
│   ├── Persistence/              # Local storage and CloudKit
│   └── Repositories/             # Data access layer
│
├── UI/                           # User interface
│   ├── Views/                    # SwiftUI views
│   ├── Components/               # Reusable UI components
│   └── Styles/                   # Theme and styling
│
├── Resources/                    # Assets and content
│
└── Utilities/                    # Helper functions and extensions
    ├── Extensions/
    └── Helpers/
```

## Current Implementation Status

### ✅ Completed

- **App Structure**: Main app entry point, coordinator pattern
- **Configuration**: Centralized app configuration
- **Data Models**: Complete data model layer
  - UserProfile with preferences and goals
  - MeditationSession with biometric tracking
  - BiometricSnapshot with wellness metrics
  - MeditationEnvironment with visual themes
  - UserProgress with achievements and leveling

### 🚧 In Progress

- Core meditation engine
- Biometric monitoring systems
- Environment management
- Spatial audio implementation
- UI views

### 📋 Planned

- RealityKit systems and components
- ARKit integration
- AI adaptation engine
- Multiplayer/SharePlay
- Persistence layer
- Unit tests

## Key Components

### App Layer

**MeditationApp.swift**
- Main application entry point
- Manages window groups and immersive spaces
- Sets up environment objects

**AppCoordinator.swift**
- Central coordinator for app state
- Manages navigation between views
- Coordinates core managers (session, biometric, audio, etc.)
- Handles session lifecycle

**Configuration.swift**
- Performance targets
- Session defaults
- Biometric thresholds
- Audio settings
- Feature flags

### Data Models

**UserProfile**
- User information and preferences
- Experience level tracking
- Wellness goals
- Meditation preferences (guidance style, duration, etc.)

**MeditationSession**
- Session lifecycle data
- Biometric snapshots
- Quality metrics (focus, calm scores)
- Completion tracking

**BiometricSnapshot**
- Point-in-time biometric data
- Stress and calm levels
- Movement and focus tracking
- Wellness score calculation

**MeditationEnvironment**
- Environment metadata
- Visual themes and soundscapes
- Unlock conditions
- Difficulty levels

**UserProgress**
- Experience points and leveling
- Streak tracking
- Achievement system
- Session statistics

## Requirements

- **Platform**: visionOS 2.0+
- **Device**: Apple Vision Pro
- **Language**: Swift 6.0+
- **Frameworks**:
  - SwiftUI
  - RealityKit
  - ARKit
  - AVFoundation
  - Combine
  - GroupActivities (SharePlay)
  - CloudKit

## Architecture Principles

1. **Separation of Concerns**: Clear boundaries between layers
2. **Dependency Injection**: Managers injected via initializers
3. **ObservableObject**: Reactive state management with Combine
4. **Protocol-Oriented**: Flexible, testable interfaces
5. **Privacy-First**: All biometric processing on-device

## Development Workflow

1. **Build**: Open in Xcode 16+ and build for visionOS
2. **Test**: Run on Vision Pro simulator or device
3. **Profile**: Use Instruments for performance validation
4. **Deploy**: TestFlight for beta testing

## Performance Targets

- **Frame Rate**: 90 fps (locked)
- **Memory**: <2GB usage
- **Battery**: <20% drain per hour
- **Startup**: <2 seconds to main menu

## Documentation

For detailed technical documentation, see:
- `../ARCHITECTURE.md` - System architecture
- `../TECHNICAL_SPEC.md` - Technical specifications
- `../DESIGN.md` - Design and UX guidelines
- `../IMPLEMENTATION_PLAN.md` - Development roadmap

## Next Steps

1. Implement SessionManager with state machine
2. Build BiometricMonitor with proxy detection
3. Create EnvironmentManager for RealityKit scenes
4. Implement SpatialAudioEngine
5. Build UI views (MainMenu, Session, Settings)
6. Add persistence layer
7. Implement gesture recognition
8. Add unit tests

## Contributing

This is a reference implementation. When extending:
- Follow existing architectural patterns
- Maintain 90fps performance target
- Prioritize user comfort and privacy
- Write tests for core functionality
- Document complex systems

---

**Status**: Initial implementation in progress
**Last Updated**: 2025-01-20
