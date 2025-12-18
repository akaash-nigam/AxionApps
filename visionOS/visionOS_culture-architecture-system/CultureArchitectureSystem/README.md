# Culture Architecture System - visionOS Application

## Overview

The **Culture Architecture System** is an enterprise visionOS application for Apple Vision Pro that transforms organizational culture from abstract concepts into immersive spatial experiences. This application enables leaders to visualize, measure, and strengthen organizational culture through 3D environments, real-time analytics, and privacy-preserving behavioral insights.

## Project Status

**Version:** 1.0.0 (MVP Implementation)
**Platform:** visionOS 2.0+
**Device:** Apple Vision Pro
**Last Updated:** 2025-01-20

### Implementation Status

✅ **Complete:**
- Comprehensive technical documentation (ARCHITECTURE.md, TECHNICAL_SPEC.md, DESIGN.md, IMPLEMENTATION_PLAN.md)
- Full project structure and folder organization
- Data layer with SwiftData models (Organization, CulturalValue, Employee, Recognition, BehaviorEvent, CulturalLandscape)
- Privacy-preserving architecture with anonymization
- Services layer (CultureService, AnalyticsService, RecognitionService, VisualizationService)
- ViewModels for all major views
- Window-based views (Dashboard, Analytics, Recognition)
- Volumetric views (Team Culture, Value Explorer) - stub implementations
- Immersive spaces (Culture Campus, Onboarding) - stub implementations
- Networking layer (APIClient, AuthenticationManager)
- Utility services (DataAnonymizer, Constants)

🚧 **In Progress:**
- Full 3D RealityKit implementations for volumetric and immersive views
- Hand tracking gesture recognition
- Real backend API integration
- Comprehensive unit and UI tests

📋 **Planned:**
- Advanced AI culture coaching
- Predictive analytics
- Multi-organization support
- Full accessibility testing and refinement

## Features

### Core Features (P0 - Implemented)

1. **Cultural Dashboard**
   - Health score visualization
   - Engagement metrics
   - Recent activity feed
   - Quick actions

2. **Analytics & Insights**
   - Engagement trend charts
   - Value alignment breakdown
   - Team health comparisons
   - Customizable time ranges

3. **Recognition System**
   - Give recognition to team members
   - Value-based recognition
   - Privacy-preserving visibility controls
   - Celebration animations

4. **Data Models**
   - Organization structure
   - Cultural values
   - Anonymous employee tracking
   - Behavior events
   - Cultural landscapes

### Spatial Features (P1 - Stubs Implemented)

1. **Team Culture Volume (3D Bounded)**
   - Team health visualization
   - Innovation garden
   - Collaboration network
   - Recognition wall

2. **Value Explorer Volume**
   - Deep dive into cultural values
   - Behavior orbiting core concept
   - Impact visualization

3. **Culture Campus (Immersive)**
   - Purpose Mountain
   - Innovation Forest
   - Trust Valley
   - Collaboration Bridges
   - Recognition Plaza
   - Team Territories

4. **Onboarding Journey (Immersive)**
   - New employee cultural introduction
   - Values walk-through
   - Interactive orientation

## Architecture

### Technology Stack

- **Platform:** visionOS 2.0+
- **Language:** Swift 6.0+
- **UI Framework:** SwiftUI
- **3D Engine:** RealityKit
- **AR Framework:** ARKit
- **Data Persistence:** SwiftData
- **Concurrency:** Swift Concurrency (async/await)
- **State Management:** Observation Framework (@Observable)

### Project Structure

```
CultureArchitectureSystem/
├── App/
│   ├── CultureArchitectureSystemApp.swift    # Main app entry point
│   ├── AppModel.swift                         # Global app state
│   └── ContentView.swift                      # Root view
├── Models/
│   ├── Organization.swift                     # Org data model
│   ├── CulturalValue.swift                    # Values model
│   ├── Employee.swift                         # Anonymous employee model
│   ├── Recognition.swift                      # Recognition model
│   ├── BehaviorEvent.swift                    # Behavior tracking
│   ├── CulturalLandscape.swift                # 3D landscape model
│   └── Department.swift                       # Department model
├── Views/
│   ├── Windows/
│   │   ├── DashboardView.swift                # Main dashboard
│   │   ├── AnalyticsView.swift                # Analytics window
│   │   └── RecognitionView.swift              # Recognition form
│   ├── Volumes/
│   │   ├── TeamCultureVolume.swift            # 3D team viz
│   │   └── ValueExplorerVolume.swift          # Value deep dive
│   └── Immersive/
│       ├── CultureCampusView.swift            # Full campus
│       └── OnboardingImmersiveView.swift      # Onboarding journey
├── ViewModels/
│   ├── DashboardViewModel.swift
│   ├── AnalyticsViewModel.swift
│   └── RecognitionViewModel.swift
├── Services/
│   ├── CultureService.swift                   # Core culture logic
│   ├── AnalyticsService.swift                 # Analytics processing
│   ├── RecognitionService.swift               # Recognition handling
│   └── VisualizationService.swift             # 3D generation
├── Networking/
│   ├── APIClient.swift                        # REST API client
│   └── AuthenticationManager.swift            # OAuth 2.0 auth
├── Utilities/
│   ├── Constants.swift                        # App constants
│   └── DataAnonymizer.swift                   # Privacy preservation
├── Resources/
│   ├── Assets.xcassets/                       # Asset catalog
│   ├── 3DModels/                              # 3D models (USDZ)
│   └── Audio/                                 # Spatial audio
└── Tests/
    ├── UnitTests/                             # Unit tests
    ├── IntegrationTests/                      # Integration tests
    └── UITests/                               # UI tests
```

## Privacy & Security

### Privacy-First Design

The Culture Architecture System is built with privacy as a core principle:

1. **No PII Storage:** Employee data is anonymized at collection time
2. **K-Anonymity:** Minimum team size of 5 for all visualizations
3. **Aggregated Data:** All metrics are team-level or higher
4. **User Control:** Granular privacy settings for data sharing
5. **Encryption:** Data encrypted at rest and in transit

### Data Anonymization

```swift
// Example: Employee anonymization
let rawEmployee = RawEmployee(
    realId: "john.doe@company.com",  // NEVER stored
    teamId: teamId,
    role: "Senior Software Engineer"
)

let anonymized = DataAnonymizer().anonymize(rawEmployee)
// Result:
// - Anonymous UUID (one-way hash)
// - Generalized role: "Engineering"
// - No personal information
```

## Building the Project

### Prerequisites

- **macOS:** 14.0 (Sonoma) or later
- **Xcode:** 16.0 or later
- **visionOS SDK:** 2.0 or later
- **Apple Vision Pro:** Device or Simulator

### Build Instructions

**Note:** This project was generated as Swift source code files. To build:

1. **Open Xcode** and create a new visionOS project:
   - File → New → Project
   - Choose: visionOS → App
   - Name: CultureArchitectureSystem
   - Interface: SwiftUI
   - Language: Swift

2. **Replace the generated files** with the source files from the `CultureArchitectureSystem/` directory

3. **Build the project:**
   ```bash
   # Command line (if you have xcode-select configured)
   xcodebuild -scheme CultureArchitectureSystem -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
   ```

   Or use Xcode:
   - Select scheme: CultureArchitectureSystem
   - Select destination: visionOS Simulator or Device
   - Product → Build (⌘B)

4. **Run the application:**
   - Product → Run (⌘R)

### Configuration

Update `Constants.swift` with your configuration:

```swift
enum AppConstants {
    static let apiBaseURL = "YOUR_API_URL"
    static let minimumTeamSize = 5  // Privacy setting
}
```

## Usage

### Dashboard

The main dashboard provides an overview of cultural health:

1. **Health Score:** Central gauge showing overall culture health
2. **Quick Stats:** Engagement, values alignment, recognition count
3. **Activity Feed:** Real-time cultural activities
4. **Quick Actions:** Give recognition, explore campus

### Analytics

View detailed cultural analytics:

1. **Engagement Trend:** 30-day engagement chart
2. **Value Breakdown:** Alignment scores for each value
3. **Team Comparison:** Health scores across teams

### Recognition

Recognize team members:

1. Search for team member
2. Select demonstrated value
3. Write personalized message
4. Choose visibility (private, team, org)
5. Send recognition

### Immersive Experiences

Open immersive spaces for deeper engagement:

1. **Culture Campus:** Navigate the full organizational landscape
2. **Team Volumes:** Explore team-specific culture in 3D
3. **Value Exploration:** Deep dive into specific values

## Documentation

### Comprehensive Documentation

This project includes extensive documentation:

- **[ARCHITECTURE.md](../ARCHITECTURE.md)** - Complete technical architecture
- **[TECHNICAL_SPEC.md](../TECHNICAL_SPEC.md)** - Detailed technical specifications
- **[DESIGN.md](../DESIGN.md)** - UI/UX design specifications
- **[IMPLEMENTATION_PLAN.md](../IMPLEMENTATION_PLAN.md)** - 12-week development roadmap

### Key Design Decisions

1. **SwiftData over CoreData:** Modern Swift API, better SwiftUI integration
2. **Observable Framework:** Latest iOS 17+ state management
3. **Privacy-First:** Anonymization at data collection layer
4. **Progressive Immersion:** Windows → Volumes → Immersive Spaces
5. **Mock Data for MVP:** Enables development without backend

## Testing

### Test Strategy

```
Test Pyramid:
- Unit Tests (70%): Models, Services, Utilities
- Integration Tests (20%): API, Service integration
- UI Tests (10%): Critical user flows
```

### Running Tests

```bash
# Unit tests
xcodebuild test -scheme CultureArchitectureSystem -destination 'platform=visionOS Simulator'

# Or in Xcode
Product → Test (⌘U)
```

## Performance

### Target Metrics

- **Frame Rate:** 90 FPS (immersive spaces)
- **Load Time:** < 3 seconds (dashboard)
- **Memory:** < 2 GB peak usage
- **Battery:** < 15% drain per hour
- **API Response:** < 500ms (P95)

## Accessibility

### Supported Features

- ✅ VoiceOver support
- ✅ Dynamic Type
- ✅ Reduce Motion alternatives
- ✅ High Contrast mode
- ✅ Voice Control compatibility
- ✅ Alternative navigation methods

### WCAG Compliance

Target: **WCAG 2.1 Level AA**

- Color contrast: 7:1 minimum
- Interactive elements: 60pt minimum
- Alternative text for all UI elements
- Keyboard/voice navigation support

## Roadmap

### Phase 2 (Q3 2025)
- AI culture coaching
- Predictive analytics
- Advanced visualizations

### Phase 3 (Q4 2025)
- Multi-organization support
- Advanced integrations
- Custom workflows

### Phase 4 (2026)
- Blockchain culture records
- Edge computing
- Advanced AR features

## Contributing

### Development Guidelines

1. Follow Swift style guide
2. Write tests for new features
3. Document public APIs
4. Maintain privacy-first principles
5. Test accessibility features

### Code Quality

- **SwiftLint:** Enforce coding standards
- **Code Coverage:** > 80% target
- **Documentation:** DocC for all public APIs

## License

Copyright © 2025 CultureSpace Technologies. All rights reserved.

## Support

For questions or issues:

- Review documentation in this repository
- Check Apple's visionOS documentation
- File issues on the project repository

## Acknowledgments

Built following:
- [Apple visionOS Guidelines](https://developer.apple.com/visionos/)
- [Human Interface Guidelines - visionOS](https://developer.apple.com/design/human-interface-guidelines/visionos)
- [RealityKit Documentation](https://developer.apple.com/documentation/realitykit/)
- [SwiftData Guide](https://developer.apple.com/documentation/swiftdata)

---

**Ready to transform organizational culture through spatial computing! 🚀**
