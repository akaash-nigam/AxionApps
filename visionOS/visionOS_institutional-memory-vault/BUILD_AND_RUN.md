# Build and Run Guide - Institutional Memory Vault

This guide will walk you through building and running the Institutional Memory Vault visionOS application.

## Prerequisites

### Required

- **macOS Sonoma 14.0+** (required for visionOS development)
- **Xcode 16.0+** with visionOS SDK
- **Apple Developer Account** (free tier is sufficient for simulator)
- **8GB+ RAM** recommended
- **20GB+ free disk space**

### Optional
- **Apple Vision Pro** device (for hardware testing)
- **Enterprise Developer Account** (for enterprise distribution)

## Project Structure

```
InstitutionalMemoryVault/
├── App/
│   └── InstitutionalMemoryVaultApp.swift    ✅ Main app entry (11 scenes)
├── Models/
│   └── DataModels.swift                     ✅ SwiftData models (6 models)
├── Views/
│   ├── Windows/                             ✅ 5 window views
│   ├── Volumes/                             ✅ 3 volumetric views
│   └── ImmersiveViews/                      ✅ 3 immersive spaces
├── Services/                                 ✅ 3 service classes
│   ├── KnowledgeManager.swift
│   ├── SearchEngine.swift
│   └── SpatialLayoutManager.swift
├── Utilities/                                ✅ Helper utilities
│   └── SampleDataGenerator.swift
├── ViewModels/                               (Future)
├── Resources/
│   ├── Assets.xcassets/                     (To populate)
│   └── 3DModels/                            (To add)
└── Tests/                                    (To implement)
```

## Step-by-Step Build Instructions

### Step 1: Create Xcode Project

1. Open **Xcode 16+**
2. Select **File → New → Project**
3. Choose **visionOS → App**
4. Configure:
   - **Product Name**: `InstitutionalMemoryVault`
   - **Organization Identifier**: `com.yourcompany`
   - **Bundle Identifier**: `com.yourcompany.institutional-memory-vault`
   - **Language**: Swift
   - **User Interface**: SwiftUI
   - **Minimum Deployment**: visionOS 2.0
5. Save to a location (NOT in this git repository yet)

### Step 2: Import Source Files

1. **Delete default files** created by Xcode:
   - Delete `ContentView.swift`
   - Keep `InstitutionalMemoryVaultApp.swift` (we'll replace it)

2. **Copy all source files** from this repository:
   ```bash
   # From this repository root
   cp -r InstitutionalMemoryVault/* /path/to/your/XcodeProject/InstitutionalMemoryVault/
   ```

3. **Add files to Xcode project**:
   - Right-click on project navigator
   - Select **Add Files to "InstitutionalMemoryVault"...**
   - Select all copied folders (App, Models, Views, Services, Utilities)
   - ✅ Check "Copy items if needed"
   - ✅ Check "Create groups"
   - ✅ Ensure target is selected
   - Click **Add**

### Step 3: Configure Project Settings

#### 3.1 Capabilities

1. Select **project** in navigator
2. Select **target** → **Signing & Capabilities**
3. Add capabilities:
   - ✅ **App Sandbox**: Already enabled by default

#### 3.2 Info.plist

Add these entries to `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is used for spatial tracking and hand gestures</string>

<key>NSMicrophoneUsageDescription</key>
<string>Microphone access is used for voice commands and knowledge capture</string>
```

#### 3.3 Build Settings

1. Select **target** → **Build Settings**
2. Verify:
   - **Swift Language Version**: Swift 6.0
   - **iOS Deployment Target**: visionOS 2.0
   - **Swift Compiler - Code Generation**:
     - **Strict Concurrency Checking**: Complete

### Step 4: Build the Project

1. Select target: **InstitutionalMemoryVault**
2. Select destination: **visionOS Simulator** (or device if available)
3. Press **⌘ + B** to build
4. Fix any errors:
   - Most common: Missing imports → Add `import SwiftUI`, `import SwiftData`, etc.
   - File organization issues → Ensure all files are in target membership

### Step 5: Run on Simulator

1. Press **⌘ + R** to run
2. Wait for visionOS Simulator to launch (~30 seconds first time)
3. The app should launch and show the main dashboard

## Testing the Application

### Initial Launch

When you first launch the app:
- You'll see the **Main Dashboard** with quick actions
- No knowledge items yet (empty state)

### Generate Sample Data

To populate with sample data:

1. Add this button temporarily to `MainDashboardView.swift`:
   ```swift
   Button("Generate Sample Data") {
       Task {
           try? await SampleDataGenerator.generateSampleData(
               modelContext: modelContext
           )
       }
   }
   ```

2. Run the app, tap the button
3. Sample data will be created:
   - 1 Organization
   - 8 Departments
   - 17 Employees
   - 10+ Knowledge items
   - Multiple connections

### Navigate the App

#### 2D Windows

1. **Dashboard**: Main entry point
   - View recent knowledge
   - Quick actions
   - Health metrics

2. **Search**: Find knowledge
   - Text search
   - Filter by type/department
   - View results

3. **Detail View**: Deep dive
   - Full content
   - Context information
   - Connections
   - Actions

4. **Analytics**: Metrics
   - Overview stats
   - Growth charts
   - Department coverage
   - Top items

5. **Settings**: Configuration
   - App preferences
   - Accessibility options

#### 3D Volumetric Windows

1. **Knowledge Network (3D)**:
   - Tap "Explore in 3D" from any knowledge
   - See knowledge constellation
   - Nodes = knowledge items
   - Lines = connections

2. **Timeline (3D)**:
   - Navigate from dashboard
   - See chronological journey
   - Nodes along timeline

3. **Organization Chart (3D)**:
   - View department structure
   - Hierarchical visualization

#### Immersive Experiences

1. **Memory Palace**:
   - Tap "Memory Palace" button
   - Enter full immersion
   - Navigate central atrium
   - Explore temporal halls

2. **Capture Studio**:
   - Tap "Capture New"
   - Enter recording environment
   - Create new knowledge

3. **Collaboration Space**:
   - (Placeholder for multi-user)

## Troubleshooting

### Build Errors

**Error**: "Cannot find 'KnowledgeEntity' in scope"
- **Fix**: Ensure `DataModels.swift` is added to target
- Check target membership in File Inspector

**Error**: "Module 'SwiftData' not found"
- **Fix**: Verify deployment target is visionOS 2.0+
- SwiftData is available in visionOS 2.0+

**Error**: "Type 'AccessLevel' does not conform to protocol 'Comparable'"
- **Fix**: Already implemented in DataModels.swift, clean build folder (⇧⌘K)

### Runtime Issues

**Issue**: App crashes on launch
- Check Console for errors
- Verify SwiftData schema is valid
- Try deleting app and rebuilding

**Issue**: Empty windows appear
- Likely SwiftUI preview issue
- Try running on simulator instead of preview
- Check view hierarchy

**Issue**: 3D content doesn't appear
- RealityKit may take time to initialize
- Check for errors in console
- Verify volumetric window style is set correctly

**Issue**: Performance is slow
- Simulator is slower than device
- Reduce number of 3D entities
- Check for memory leaks in Instruments

### Simulator Limitations

The visionOS Simulator has limitations:

- ❌ **No hand tracking** (device only)
- ❌ **No eye tracking** (device only)
- ❌ **Lower performance** than real hardware
- ✅ **All window types work**
- ✅ **RealityKit renders**
- ✅ **Gestures simulated** with mouse/trackpad

## Testing Checklist

### ✅ Core Functionality

- [ ] App launches without crashes
- [ ] Dashboard displays correctly
- [ ] Can generate sample data
- [ ] Sample data appears in lists
- [ ] Can search knowledge
- [ ] Search results display
- [ ] Can view knowledge details
- [ ] Analytics dashboard shows metrics
- [ ] Settings window opens

### ✅ 3D Features

- [ ] Knowledge Network volume opens
- [ ] 3D nodes render
- [ ] Timeline volume opens
- [ ] Org chart volume opens
- [ ] Can interact with 3D objects (tap, drag)

### ✅ Immersive Features

- [ ] Can enter Memory Palace
- [ ] Memory Palace environment renders
- [ ] Can exit immersive mode
- [ ] Capture Studio opens
- [ ] Collaboration Space opens

### ✅ Navigation

- [ ] Windows open/close properly
- [ ] No navigation crashes
- [ ] Back navigation works
- [ ] Multiple windows can be open

### ✅ Data Persistence

- [ ] Data persists after app restart
- [ ] Created knowledge saves
- [ ] Search results consistent
- [ ] No data corruption

## Performance Targets

Our goals (from IMPLEMENTATION_PLAN.md):

- ✅ **Frame Rate**: 90 FPS (99th percentile)
- ✅ **App Launch**: < 3 seconds
- ✅ **Search**: < 1 second for 1000 items
- ✅ **3D Render**: 500 nodes at 90 FPS
- ✅ **Memory**: < 1.5 GB typical usage

### Measuring Performance

1. **Frame Rate**:
   - Xcode → Debug → Performance → FPS
   - Target: 90 FPS
   - Minimum acceptable: 60 FPS

2. **Launch Time**:
   - Instruments → App Launch
   - From tap to interactive

3. **Memory**:
   - Instruments → Allocations
   - Watch for leaks

4. **Search Speed**:
   - Add timing logs in SearchEngine
   - Measure query → results

## Next Steps

### Phase 1 Complete ✅
- Documentation
- Project structure
- Core views
- Services implemented

### Phase 2: Sprint 1-2 (Weeks 1-4)

Next tasks from IMPLEMENTATION_PLAN.md:

1. **Refine UI**:
   - Improve dashboard design
   - Better empty states
   - Loading indicators

2. **Enhanced Services**:
   - Complete KnowledgeManager
   - Advanced search features
   - Caching improvements

3. **ViewModels**:
   - Create ViewModels for each view
   - Separate UI from business logic

4. **Testing**:
   - Unit tests for services
   - UI tests for critical flows
   - Performance tests

5. **Real Data**:
   - Import from enterprise systems
   - Document parsing
   - Bulk import tools

### Phase 3: Sprint 3-4 (Weeks 5-8)

3D visualization enhancements:

1. **Force-Directed Layout**:
   - Implement physics simulation
   - Smooth animations
   - Performance optimization

2. **Interactive Nodes**:
   - Rich hover states
   - Selection feedback
   - Connection highlighting

3. **Advanced Gestures**:
   - Drag to reposition
   - Pinch to scale
   - Rotate network

## Resources

- **Apple Documentation**: https://developer.apple.com/visionos/
- **HIG**: https://developer.apple.com/design/human-interface-guidelines/visionos
- **Sample Code**: https://developer.apple.com/documentation/visionos/world
- **WWDC Videos**: Search for "visionOS" on Apple Developer

## Support

For issues with this codebase:
1. Check troubleshooting section above
2. Review ARCHITECTURE.md for technical details
3. See IMPLEMENTATION_PLAN.md for development roadmap
4. Check PROJECT_STATUS.md for current state

---

**Ready to build the future of organizational knowledge management!** 🚀
