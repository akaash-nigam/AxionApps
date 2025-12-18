# Changelog

All notable changes to Personal Finance Navigator will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Plaid integration for automatic bank connections
- CloudKit sync for cross-device data synchronization
- Advanced 3D visualizations (investment trees, debt snowballs)
- Category management UI
- Recurring transaction detection
- Financial reports and PDF exports

## [1.0.0] - 2025-11-24

### Added - MVP Release

#### Core Features
- **Account Management**
  - Add, edit, and delete financial accounts
  - Support for checking, savings, credit card, and investment accounts
  - Real-time balance tracking
  - Account grouping by type
  - Net worth calculation (assets - liabilities)

- **Transaction Management**
  - Manual transaction entry and editing
  - Transaction categorization
  - Search and filter functionality
  - Date-based grouping
  - Swipe actions for quick operations
  - Balance synchronization with accounts

- **Budget Management**
  - Create budgets with multiple strategies:
    - 50/30/20 Rule
    - Zero-Based Budgeting
    - Envelope Method
    - Custom allocations
  - 3-step budget creation wizard
  - Real-time progress tracking
  - Category-level budget monitoring
  - Smart budget alerts (75%, 90%, 100%)
  - Budget status color coding

- **Dashboard**
  - Comprehensive financial overview
  - Net worth display with assets/liabilities breakdown
  - Budget status with circular progress indicator
  - Monthly spending vs. income summary
  - Recent transactions list (last 5)
  - Quick action buttons
  - Pull-to-refresh functionality
  - Time-based greetings

- **3D Money Flow Visualization**
  - RealityKit-powered 3D particle system
  - Category-based money flow streams
  - Color-coded particles by category
  - Interactive gestures (drag to rotate, pinch to zoom)
  - Real-time data updates
  - Category breakdown info panel

- **Onboarding Flow**
  - 6-step guided setup:
    1. Welcome screen with feature highlights
    2. Features overview
    3. Privacy and security information
    4. Bank connection (placeholder for Plaid)
    5. Budget setup with strategy selection
    6. Completion with next steps
  - Progress bar
  - Skip option for experienced users
  - Preference collection (biometric, notifications)

#### Technical Infrastructure
- **Architecture**
  - MVVM pattern with clean architecture
  - Repository pattern for data access
  - Dependency injection container
  - Protocol-oriented design
  - Swift 6.0 concurrency (async/await, actors)

- **Data Layer**
  - Core Data with 9 entities
  - Proper relationships and cascade rules
  - Repository implementations for all entities
  - Domain-to-entity mapping
  - Sample data generation for testing

- **Security**
  - Biometric authentication (Face ID/Optic ID/Touch ID)
  - AES-256-GCM encryption for sensitive data
  - Secure keychain storage
  - Auto-lock with configurable timeout (1-15 minutes)
  - Session management
  - App backgrounding protection

- **User Interface**
  - Native SwiftUI implementation
  - visionOS spatial design
  - Material effects (.regularMaterial, .ultraThinMaterial)
  - Adaptive layouts for different sizes
  - Pull-to-refresh support
  - Empty state handling
  - Error displays with user-friendly messages

#### Testing
- **Unit Tests** (68 tests total)
  - AccountViewModel: 15 tests
  - TransactionViewModel: 20 tests
  - BudgetViewModel: 18 tests
  - Domain Models: 15 tests
- **Test Coverage**: ~85% for business logic
- **Mock Repositories**: Full mock implementations for testing
- **TEST_GUIDE.md**: Comprehensive testing documentation

#### Documentation
- **README.md**: Complete project overview
- **CONTRIBUTING.md**: Contribution guidelines
- **CHANGELOG.md**: Version history (this file)
- **PRD.md**: Product Requirements Document
- **Design Documents** (14 files in docs/):
  - technical-architecture.md
  - data-model-schema.md
  - api-integration.md
  - security-privacy.md
  - ui-ux-design-system.md
  - 3d-visualization-spec.md
  - testing-strategy.md
  - performance-optimization.md
  - analytics-observability.md
  - state-management.md
  - mvp-and-epics.md
  - implementation-roadmap.md
  - core-data-model-definition.md
  - xcode-setup-guide.md

#### Marketing
- **Landing Page**
  - Modern, responsive design
  - Feature showcases
  - Pricing tiers (Free, Pro, Lifetime)
  - FAQ section
  - Call-to-action sections
  - Interactive JavaScript features

### Technical Details

- **Platform**: visionOS 2.0+
- **Language**: Swift 6.0
- **Frameworks**: SwiftUI, RealityKit, Core Data, Combine
- **Minimum Requirements**: Apple Vision Pro
- **Lines of Code**: ~15,000+
- **Files**: 50+ Swift files

### Known Issues

- CloudKit sync not yet implemented (local-only storage)
- Plaid integration is placeholder (manual entry only)
- Some 3D visualization animations need performance optimization
- Category management limited to default categories

### Migration Notes

- First release - no migrations needed

---

## Version History

### Version Numbering

We follow [Semantic Versioning](https://semver.org/):
- **MAJOR**: Incompatible API changes
- **MINOR**: New functionality (backwards-compatible)
- **PATCH**: Bug fixes (backwards-compatible)

### Release Cycle

- **Major releases**: Every 6-12 months
- **Minor releases**: Monthly (feature additions)
- **Patch releases**: As needed (bug fixes)

### Support Policy

- **Current version**: Full support with new features
- **Previous major version**: Security updates only (6 months)
- **Older versions**: No support

---

## Acknowledgments

### Built With
- Apple visionOS SDK
- RealityKit for 3D visualization
- Core Data for persistence
- SwiftUI for user interface

### Contributors
- Lead Developer: [Your Name]
- Design: [Design Team]
- Testing: [QA Team]
- Documentation: Contributors

### Special Thanks
- Apple Developer Relations
- Swift Community
- Beta Testers
- Early Adopters

---

**For detailed information about specific features, see [README.md](README.md)**

**For technical architecture, see [docs/technical-architecture.md](docs/technical-architecture.md)**
