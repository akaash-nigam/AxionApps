# Spatial CRM - Build Instructions

## Prerequisites

- **macOS**: Sonoma 14.0 or later
- **Xcode**: 16.0 or later (Beta)
- **visionOS SDK**: 2.0 or later
- **Apple Vision Pro**: Device or Simulator

## Quick Start (Xcode Project Setup)

Since this is a Swift codebase without a pre-built `.xcodeproj` file, you'll need to create the Xcode project:

### Option 1: Manual Xcode Project Creation

1. **Open Xcode 16+**

2. **Create New Project**:
   - File → New → Project
   - Select "visionOS" platform
   - Choose "App" template
   - Click "Next"

3. **Configure Project**:
   - Product Name: `SpatialCRM`
   - Team: Your development team
   - Organization Identifier: `com.yourcompany`
   - Interface: SwiftUI
   - Language: Swift
   - Click "Next" and choose save location (this repository root)

4. **Import Source Files**:
   - Delete the default `ContentView.swift` and `SpatialCRMApp.swift` from Xcode's generated files
   - In Finder, select all folders in `/SpatialCRM/` directory
   - Drag them into Xcode's project navigator under the SpatialCRM target
   - Check "Copy items if needed"
   - Ensure "Create groups" is selected
   - Add to SpatialCRM target

5. **Configure Build Settings**:
   - Select project in navigator
   - Select SpatialCRM target
   - Go to "Signing & Capabilities"
   - Select your development team
   - Add capabilities:
     - Hand Tracking
     - Eye Tracking
     - iCloud (CloudKit)
   - Go to "Info" tab
   - Add Info.plist from `SpatialCRM/Resources/Info.plist`

6. **Add Entitlements**:
   - In project settings → Build Settings
   - Search for "Code Signing Entitlements"
   - Set to: `SpatialCRM/Resources/SpatialCRM.entitlements`

7. **Build Settings**:
   - Deployment Target: visionOS 2.0
   - Swift Language Version: Swift 6

### Option 2: Using Swift Package Manager

```bash
# Clone the repository
git clone <repository-url>
cd visionOS_spatial-crm

# Note: visionOS requires Xcode, cannot build with swift build on command line
# You must use Xcode for visionOS development
```

## Building the Project

### In Xcode

1. **Select Destination**:
   - Product → Destination → Apple Vision Pro (Simulator)
   - Or select your physical Vision Pro device

2. **Build Project**:
   ```
   ⌘ + B
   ```

3. **Run on Simulator**:
   ```
   ⌘ + R
   ```

### Build Configurations

- **Debug**: Development build with debug symbols
- **Release**: Optimized for performance

To switch configurations:
- Product → Scheme → Edit Scheme → Run → Build Configuration

## Testing

### Running Unit Tests

```bash
# In Xcode
⌘ + U
```

Or via Test Navigator:
- ⌘ + 6 to open Test Navigator
- Click play button next to test suite

### Available Test Suites

- `AccountTests`: Account model tests
- `OpportunityTests`: Opportunity model tests
- `ContactTests`: Contact model tests
- `ActivityTests`: Activity model tests
- `AIServiceTests`: AI service logic tests

## Generating Sample Data

The app includes a sample data generator for development:

1. Add breakpoint or code in `SpatialCRMApp.swift`'s `init()`:

```swift
// In SpatialCRMApp init, after modelContainer is created:
#if DEBUG
Task { @MainActor in
    let generator = SampleDataGenerator(modelContext: modelContainer.mainContext)
    generator.generateCompleteDataset()
}
#endif
```

2. Run the app once to populate sample data

3. Comment out or remove the code for subsequent runs

## Project Structure

```
SpatialCRM/
├── App/
│   ├── SpatialCRMApp.swift          # App entry point
│   └── ContentView.swift            # Main content view
├── Models/
│   ├── Account.swift                # Customer/Account model
│   ├── Contact.swift                # Contact model
│   ├── Opportunity.swift            # Deal/Opportunity model
│   ├── Activity.swift               # Activity/Task model
│   ├── Territory.swift              # Territory & SalesRep models
│   └── CollaborationSession.swift   # Collaboration model
├── ViewModels/
│   └── (View models with @Observable)
├── Views/
│   ├── Dashboard/                   # Dashboard views
│   ├── Pipeline/                    # Pipeline views
│   ├── Accounts/                    # Account views
│   ├── Spatial/                     # 3D spatial views
│   └── Components/                  # Reusable components
├── Services/
│   ├── CRMService.swift            # CRM data operations
│   ├── AIService.swift             # AI intelligence
│   └── SpatialService.swift        # 3D layout calculations
├── Utilities/
│   ├── SampleDataGenerator.swift   # Sample data creation
│   ├── Extensions/                 # Swift extensions
│   └── Helpers/                    # Helper utilities
├── Resources/
│   ├── Info.plist                  # App configuration
│   ├── SpatialCRM.entitlements     # Capabilities
│   └── Assets.xcassets             # Images and assets
└── Tests/
    └── UnitTests/                   # Unit test files
```

## Common Build Issues

### Issue: "No such module 'SwiftData'"
**Solution**: Ensure deployment target is visionOS 2.0+

### Issue: "Hand tracking capability not found"
**Solution**:
1. Select project in navigator
2. Go to Signing & Capabilities
3. Click "+ Capability"
4. Add "Hand Tracking"

### Issue: Build fails with entitlements error
**Solution**:
1. Verify entitlements file path in Build Settings
2. Ensure you have valid development team selected
3. Check provisioning profile includes required capabilities

### Issue: SwiftData schema migration errors
**Solution**:
- Delete app from simulator/device
- Clean build folder (⌘ + Shift + K)
- Rebuild project

## Performance Profiling

### Using Instruments

1. Product → Profile (⌘ + I)
2. Select profiling template:
   - **Time Profiler**: CPU performance
   - **Allocations**: Memory usage
   - **Metal System Trace**: GPU performance
   - **Network**: API calls

### Performance Targets

- Frame Rate: 90 FPS minimum
- App Launch: < 2 seconds
- Search Response: < 100ms
- Memory Usage: < 500MB typical

## Debugging Tips

### Enable Spatial Debugging

In Xcode:
1. Debug → Rendering → Show Bounding Boxes
2. Debug → Rendering → Show Statistics

### SwiftData Debugging

Add launch argument:
```
-com.apple.CoreData.SQLDebug 1
```

### Enable Verbose Logging

In scheme:
1. Product → Scheme → Edit Scheme
2. Run → Arguments → Environment Variables
3. Add: `OS_ACTIVITY_MODE = default`

## Distribution

### TestFlight

1. Archive the app:
   - Product → Archive
2. In Organizer:
   - Select archive
   - Click "Distribute App"
   - Choose "TestFlight & App Store"
   - Follow wizard

### App Store

1. Prepare metadata in App Store Connect
2. Archive and upload via Organizer
3. Submit for review

## Continuous Integration

### GitHub Actions (Example)

```yaml
name: Build visionOS App

on: [push, pull_request]

jobs:
  build:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_16.0.app
      - name: Build
        run: xcodebuild -scheme SpatialCRM -destination 'platform=visionOS Simulator,name=Apple Vision Pro' build
      - name: Test
        run: xcodebuild -scheme SpatialCRM -destination 'platform=visionOS Simulator,name=Apple Vision Pro' test
```

## Resources

- [visionOS Documentation](https://developer.apple.com/visionos/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/visionos)
- [RealityKit Documentation](https://developer.apple.com/documentation/realitykit/)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)

## Support

For issues or questions:
1. Check existing GitHub issues
2. Review ARCHITECTURE.md and TECHNICAL_SPEC.md
3. Create new issue with details

## License

[Your License Here]
