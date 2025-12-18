# Wardrobe Consultant - Source Code

## Overview

This directory contains the Swift source code for the Wardrobe Consultant visionOS application. The project follows **Clean Architecture** principles with an MVVM presentation pattern.

## Project Structure

```
WardrobeConsultant/
├── App/                          # Application entry point
│   ├── WardrobeConsultantApp.swift   # Main app struct
│   └── AppCoordinator.swift          # App-level coordination
│
├── Presentation/                 # UI Layer (SwiftUI + ViewModels)
│   ├── Screens/                  # Feature screens
│   │   ├── Home/
│   │   ├── Wardrobe/
│   │   ├── Outfits/
│   │   ├── VirtualTryOn/
│   │   ├── Onboarding/
│   │   └── Settings/
│   ├── Components/               # Reusable UI components
│   └── ViewModels/              # View state management
│
├── Domain/                       # Business Logic Layer
│   ├── Entities/                # Core business objects
│   │   ├── WardrobeItem.swift   # Clothing item model
│   │   ├── Outfit.swift         # Outfit combination model
│   │   └── UserProfile.swift    # User profile model
│   ├── UseCases/                # Business use cases
│   └── Repositories/            # Data access protocols
│       ├── WardrobeRepository.swift
│       ├── OutfitRepository.swift
│       └── UserProfileRepository.swift
│
├── Infrastructure/              # External services & frameworks
│   ├── Persistence/             # Data storage
│   │   ├── PersistenceController.swift
│   │   ├── CoreDataWardrobeRepository.swift
│   │   └── CoreDataUserProfileRepository.swift
│   ├── Networking/              # API clients
│   │   ├── WeatherService/
│   │   └── RetailerService/
│   ├── AR/                      # AR & 3D rendering
│   │   ├── ARBodyTrackingManager.swift
│   │   ├── ClothingModelLoader.swift
│   │   └── FabricMaterialFactory.swift
│   └── ML/                      # Machine learning
│       ├── ClothingClassifier.swift
│       └── StyleRecommendationService.swift
│
├── Resources/                   # Assets & resources
│   ├── Assets.xcassets
│   ├── Models/                  # 3D models (USDZ)
│   └── Fonts/
│
└── Tests/                       # Test suites
    ├── UnitTests/
    ├── IntegrationTests/
    └── UITests/
```

## Architecture Principles

### Clean Architecture
The project is organized into distinct layers:

1. **Presentation Layer**: SwiftUI views and ViewModels
   - Views are passive and only display data
   - ViewModels contain presentation logic
   - No direct access to data layer

2. **Domain Layer**: Business logic and entities
   - Pure Swift (no framework dependencies)
   - Contains business rules
   - Defines interfaces (protocols) for data access

3. **Infrastructure Layer**: External dependencies
   - Implements repository protocols
   - Handles Core Data, networking, AR, ML
   - Framework-specific code isolated here

### Dependency Flow
```
Presentation → Domain ← Infrastructure
```
- Presentation depends on Domain
- Infrastructure depends on Domain
- Domain depends on nothing (pure business logic)

## Key Design Patterns

### Repository Pattern
Data access abstracted behind protocols:
```swift
protocol WardrobeRepository {
    func fetchAll() async throws -> [WardrobeItem]
    func create(_ item: WardrobeItem) async throws -> WardrobeItem
}
```

### MVVM (Model-View-ViewModel)
```swift
// View
struct WardrobeView: View {
    @StateObject var viewModel: WardrobeViewModel
}

// ViewModel
@MainActor
class WardrobeViewModel: ObservableObject {
    @Published var items: [WardrobeItem] = []
}
```

### Use Cases
Business operations encapsulated:
```swift
class GenerateOutfitSuggestionsUseCase {
    func execute() async throws -> [Outfit] {
        // Coordinate repositories and services
    }
}
```

## Current Implementation Status

### ✅ Completed (Epic 1 - Foundation)
- [x] Project structure
- [x] Domain entities (WardrobeItem, Outfit, UserProfile)
- [x] Repository protocols
- [x] Core Data persistence controller (stub)
- [x] Repository implementations (stubs)
- [x] Keychain service for body measurements
- [x] App coordinator and main app structure

### 🚧 In Progress
- [ ] Core Data model (.xcdatamodeld) - To be created in Xcode
- [ ] Full repository implementations - Epic 2
- [ ] UI screens - Epic 3
- [ ] Style recommendation engine - Epic 4

### 📋 TODO
See `docs/IMPLEMENTATION_PLAN.md` for full roadmap

## Building the Project

### Prerequisites
- macOS 14.0+
- Xcode 15.2+
- Apple Vision Pro or simulator

### Setup
```bash
# Clone repository
git clone <repository-url>
cd visionOS_Wardrobe-Consultant

# Open in Xcode
open WardrobeConsultant.xcodeproj

# Build and run
# Select "Apple Vision Pro" simulator
# Press Cmd+R to build and run
```

### Creating the Core Data Model
1. In Xcode, create a new Data Model file: `WardrobeConsultant.xcdatamodeld`
2. Add entities:
   - WardrobeItemEntity
   - OutfitEntity
   - UserProfileEntity
3. Configure attributes based on `docs/02-data-models.md`

## Testing

### Unit Tests
```bash
# Run unit tests
xcodebuild test -scheme WardrobeConsultant -destination 'platform=visionOS Simulator'
```

### Code Coverage
Target: 80%+ coverage for domain and infrastructure layers

## Code Style

### SwiftLint
Configuration file: `.swiftlint.yml`
```bash
# Run SwiftLint
swiftlint lint
```

### Naming Conventions
- Types: PascalCase (`WardrobeItem`)
- Variables/Functions: camelCase (`primaryColor`)
- Constants: camelCase (`maxItems`)
- Protocols: Noun or Adjective (`WardrobeRepository`, `Codable`)

## Contributing

### Branch Strategy
- `main`: Production releases
- `develop`: Development branch
- `epic/*`: Epic branches
- `feature/*`: Feature branches

### Commit Messages
```
feat: Add wardrobe item creation
fix: Resolve Core Data crash
docs: Update README
test: Add wardrobe repository tests
refactor: Extract color harmony logic
```

## Documentation

- **PRD**: `docs/PRD.md`
- **Design Docs**: `docs/01-system-architecture.md` through `docs/10-onboarding-design.md`
- **Implementation Plan**: `docs/IMPLEMENTATION_PLAN.md`

## License

Copyright © 2025 Wardrobe Consultant. All rights reserved.

---

**Last Updated**: 2025-11-24
**Epic**: 1 - Foundation
**Status**: In Progress
