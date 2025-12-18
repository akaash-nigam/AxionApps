# Legal Discovery Universe - Build Instructions

## Prerequisites

### Required Software
- **Xcode 16.0 or later** with visionOS SDK
- **macOS Sonoma (14.0) or later**
- **Apple Developer Account** (for device deployment)
- **Apple Vision Pro** (for hardware testing, optional but recommended)

### Required Knowledge
- Swift 6.0+ with strict concurrency
- SwiftUI for visionOS
- RealityKit 2.0+
- SwiftData

## Project Structure

```
LegalDiscoveryUniverse/
├── ARCHITECTURE.md          # System architecture documentation
├── TECHNICAL_SPEC.md        # Technical specifications
├── DESIGN.md                # UI/UX design guidelines
├── IMPLEMENTATION_PLAN.md   # Development roadmap
├── BUILD_INSTRUCTIONS.md    # This file
├── README.md                # Project overview
└── LegalDiscoveryUniverse/  # Source code
    ├── App/                 # App entry point and state
    ├── Models/              # Data models (SwiftData)
    ├── Views/               # UI components
    │   ├── Windows/         # 2D window views
    │   ├── Volumes/         # 3D volumetric views
    │   └── ImmersiveSpaces/ # Full immersion views
    ├── Services/            # Business logic services
    ├── Repositories/        # Data access layer
    ├── Utilities/           # Helper functions
    ├── Resources/           # Assets, 3D models, audio
    └── Persistence/         # Data management
```

## Setting Up the Project

### Step 1: Create Xcode Project

Since this is source code only, you need to create a new Xcode project:

1. Open Xcode
2. File → New → Project
3. Select **visionOS → App**
4. Configure project:
   - Product Name: `LegalDiscoveryUniverse`
   - Team: Your development team
   - Organization Identifier: `com.legal` (or your own)
   - Interface: SwiftUI
   - Language: Swift
   - Minimum Deployment: visionOS 2.0

### Step 2: Add Source Files

1. Delete the default `ContentView.swift` created by Xcode
2. Copy all Swift files from `LegalDiscoveryUniverse/` to your Xcode project
3. Ensure files are added to the target

### Step 3: Configure Project Settings

#### Info.plist Additions
Add these entries if needed for certain features:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access for document scanning</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Photo library access for importing images</string>
```

#### Capabilities
Enable these capabilities in Xcode:
1. Project Settings → Signing & Capabilities
2. Add: Data Protection
3. Add: Keychain Sharing (if needed)

### Step 4: Dependencies

This project uses native frameworks only:
- SwiftUI
- SwiftData
- RealityKit
- ARKit
- CryptoKit
- Natural Language

No external package dependencies are required for the MVP.

## Building the Project

### For Simulator

```bash
# Build for visionOS Simulator
xcodebuild -scheme LegalDiscoveryUniverse \
           -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
           build
```

Or in Xcode:
1. Select **Apple Vision Pro** simulator
2. Product → Build (⌘B)
3. Product → Run (⌘R)

### For Device

1. Connect Apple Vision Pro device
2. Ensure device is in Developer Mode
3. Select device in Xcode
4. Product → Run (⌘R)

## Running with Sample Data

The app includes a sample data generator in `DataManager.swift`:

```swift
// In your app initialization or first launch
try DataManager.shared.insertSampleData()
```

This creates:
- 1 sample case: "Acme Corp v. TechStart Inc."
- 3 sample documents (PDF, email, work product)
- 4 sample entities (people and organizations)
- 3 sample tags
- 1 timeline with 3 events

## Testing

### Unit Tests

```bash
xcodebuild test -scheme LegalDiscoveryUniverse \
                -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

### UI Tests

```bash
xcodebuild test -scheme LegalDiscoveryUniverseUITests \
                -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

## Known Limitations (Current MVP)

This is a foundational implementation. The following features are **stubs** and need full implementation:

### To Implement
1. **3D Visualizations**: RealityKit entities for document galaxies, timeline, and network
2. **AI Features**: Actual ML models for relevance, privilege detection, entity extraction
3. **Security**: Full encryption, authentication, audit logging
4. **File Import**: PDF parsing, email parsing, OCR
5. **Search**: Full-text search with SwiftData
6. **Network Sync**: Backend API integration
7. **Collaboration**: Real-time sync and SharePlay
8. **Export**: PDF generation, CSV export, production sets

### What Works
✅ Project structure and architecture
✅ SwiftData models and persistence
✅ Basic UI layouts (workspace, document detail, settings)
✅ Window management (multiple windows, volumes)
✅ Sample data generation
✅ Navigation and state management

## Development Workflow

### Recommended Development Order

Follow the **IMPLEMENTATION_PLAN.md** for detailed phase-by-phase development:

**Phase 1 (Weeks 1-2): Foundation**
- ✅ Project setup (DONE)
- ✅ Data models (DONE)
- ✅ Basic services (DONE)

**Phase 2 (Weeks 3-5): Core Features**
- [ ] Document import with actual parsing
- [ ] Full-text search
- [ ] Case management CRUD

**Phase 3 (Weeks 6-8): Spatial Features**
- [ ] Evidence Universe 3D rendering
- [ ] Timeline visualization
- [ ] Network graph
- [ ] Immersive spaces

**Phase 4 (Weeks 9-11): AI Integration**
- [ ] Relevance scoring
- [ ] Privilege detection
- [ ] Entity extraction
- [ ] Relationship mapping

**Phase 5 (Weeks 12-14): Polish**
- [ ] Performance optimization
- [ ] Accessibility (VoiceOver, keyboard)
- [ ] User testing
- [ ] Security audit

**Phase 6 (Weeks 15-16): Deployment**
- [ ] Final testing
- [ ] Documentation
- [ ] App Store submission

## Troubleshooting

### Build Errors

**Error: Missing SwiftData imports**
- Ensure deployment target is visionOS 2.0+
- Clean build folder (⇧⌘K) and rebuild

**Error: RealityKit not found**
- Ensure you're building for visionOS, not iOS
- Check that RealityKit is imported in files that need it

**Error: @Observable macro not found**
- Ensure Swift 6.0 is enabled
- Check Build Settings → Swift Language Version

### Runtime Issues

**App crashes on launch**
- Check that DataManager initializes correctly
- Ensure SwiftData schema is valid
- Look for force unwraps that might fail

**Simulator performance is slow**
- RealityKit rendering is slower in simulator
- Test on actual hardware for accurate performance
- Reduce entity count for simulator testing

**Windows not opening**
- Check window IDs match between `openWindow` calls and WindowGroup IDs
- Ensure environment objects are passed correctly

## Performance Tips

### Optimization Checklist
- [ ] Profile with Instruments (Time Profiler, Allocations)
- [ ] Implement Level of Detail (LOD) for 3D entities
- [ ] Use entity culling (don't render off-screen entities)
- [ ] Lazy load documents (pagination)
- [ ] Cache frequently accessed data
- [ ] Use background tasks for AI processing
- [ ] Optimize SwiftData queries with indexes

### Target Metrics
- **FPS**: 90+ (measured with Instruments)
- **Memory**: <2GB typical usage
- **Search**: <500ms for 10K documents
- **App Launch**: <3 seconds

## Security Checklist

Before production deployment:
- [ ] Implement AES-256 encryption for documents
- [ ] Store encryption keys in Secure Enclave
- [ ] Enable certificate pinning for API calls
- [ ] Implement comprehensive audit logging
- [ ] Add biometric authentication
- [ ] Conduct security penetration testing
- [ ] Review for OWASP Top 10 vulnerabilities
- [ ] Ensure GDPR compliance
- [ ] Test privilege protection mechanisms

## Documentation

For more information, see:
- **ARCHITECTURE.md** - System design and component architecture
- **TECHNICAL_SPEC.md** - Detailed technical specifications
- **DESIGN.md** - UI/UX and spatial design guidelines
- **IMPLEMENTATION_PLAN.md** - Development roadmap and milestones
- **README.md** - Project overview and business case

## Support

For issues, questions, or contributions:
1. Review the documentation above
2. Check the implementation plan for feature status
3. Consult Apple's visionOS documentation
4. File issues in the project repository

## License

Copyright © 2024 Legal Discovery Universe. All rights reserved.

---

**Version**: 1.0.0 (MVP Foundation)
**Last Updated**: 2025-11-17
**Status**: Foundation Complete, Core Features In Development
