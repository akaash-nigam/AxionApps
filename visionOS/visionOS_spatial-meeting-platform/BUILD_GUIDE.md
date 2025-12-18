# Build Guide - Spatial Meeting Platform

## Prerequisites

### Required Software

1. **macOS Sonoma 14.5+**
   - This is required to run Xcode 16+

2. **Xcode 16.0+**
   - Download from Mac App Store or Apple Developer website
   - Includes visionOS 2.0 SDK
   - Includes visionOS Simulator

3. **Apple Developer Account**
   - Free account sufficient for simulator testing
   - Paid account ($99/year) required for device deployment

4. **Apple Vision Pro** (Optional, recommended for final testing)
   - Simulator is sufficient for development
   - Physical device highly recommended for final testing and production

### Recommended Tools

- **Reality Composer Pro** - For creating and editing 3D environments
- **SF Symbols App** - For browsing available system icons
- **Instruments** - For performance profiling (included with Xcode)

## Project Setup

### 1. Clone the Repository

```bash
git clone https://github.com/your-org/visionOS_spatial-meeting-platform.git
cd visionOS_spatial-meeting-platform
```

### 2. Install Dependencies

This project uses Swift Package Manager. Dependencies will be resolved automatically when you build.

**Dependencies include:**
- None currently (self-contained)
- In future: WebRTC framework, networking libraries

### 3. Open in Xcode

```bash
open SpatialMeetingPlatform.xcodeproj
```

OR

- Launch Xcode
- File → Open → Select `SpatialMeetingPlatform` folder
- Xcode will automatically detect the Swift package

## Building the App

### For visionOS Simulator

1. In Xcode, select the scheme: **SpatialMeetingPlatform**
2. Select destination: **Apple Vision Pro (Simulator)**
3. Press **⌘R** (Command-R) to build and run

OR

```bash
# Command line build
xcodebuild -scheme SpatialMeetingPlatform \
           -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
           -configuration Debug \
           build
```

### For Physical Device

1. Connect Apple Vision Pro via USB-C
2. Trust the computer on the device
3. In Xcode, select destination: **Your Vision Pro Device Name**
4. Ensure signing & capabilities are configured (see below)
5. Press **⌘R** to build and run

### Signing & Capabilities

1. Select the project in Xcode navigator
2. Select the **SpatialMeetingPlatform** target
3. Go to **Signing & Capabilities** tab
4. Select your **Team** (Apple Developer account)
5. Ensure bundle identifier is unique (e.g., `com.yourcompany.spatialmeeting`)

**Required Capabilities:**
- ✅ Camera
- ✅ Microphone
- ✅ Hand Tracking
- ✅ World Sensing

## Project Structure

```
SpatialMeetingPlatform/
├── App/                          # Application entry point
│   ├── SpatialMeetingPlatformApp.swift
│   └── AppModel.swift
├── Models/                       # Data models (SwiftData)
│   └── DataModels.swift
├── Views/                        # SwiftUI views
│   ├── Windows/                  # 2D window views
│   │   ├── DashboardView.swift
│   │   ├── MeetingControlsView.swift
│   │   └── SharedContentView.swift
│   ├── Volumes/                  # 3D volumetric views
│   │   ├── MeetingVolumeView.swift
│   │   └── CollaborationVolumeView.swift
│   └── ImmersiveViews/           # Fully immersive views
│       └── ImmersiveMeetingView.swift
├── ViewModels/                   # View models (MVVM)
├── Services/                     # Business logic & networking
│   ├── ServiceProtocols.swift
│   ├── MeetingService.swift
│   ├── SpatialService.swift
│   ├── AIService.swift
│   ├── WebSocketService.swift
│   ├── APIClient.swift
│   ├── AuthService.swift
│   └── DataStore.swift
├── Utilities/                    # Helper utilities
├── Resources/                    # Assets & 3D models
│   ├── Assets.xcassets
│   └── 3DModels/
└── Tests/                        # Unit & UI tests
```

## Running Tests

### Unit Tests

```bash
# Run all tests
xcodebuild test -scheme SpatialMeetingPlatform \
                -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

# Or in Xcode: ⌘U (Command-U)
```

### UI Tests

UI tests can be run the same way as unit tests. They're located in the `Tests/` directory.

## Development Workflow

### 1. Start the Simulator

```bash
# List available simulators
xcrun simctl list devices visionOS

# Boot the visionOS simulator
xcrun simctl boot "Apple Vision Pro"

# Or use Xcode: Xcode → Open Developer Tool → Simulator
```

### 2. Hot Reload

SwiftUI supports live previews:
- Open any View file
- Click **Resume** in the preview canvas (⌥⌘P)
- Changes appear in real-time as you edit

### 3. Debugging

**Breakpoints:**
- Click line number in Xcode to add breakpoint
- Run app in debug mode (⌘R)
- Execution will pause at breakpoints

**Logging:**
- Uses OSLog framework
- View logs in Console.app or Xcode console
- Filter by subsystem: `com.spatial.meeting`

**Instruments:**
- Profile app performance
- Xcode → Product → Profile (⌘I)
- Recommended instruments:
  - Time Profiler (CPU usage)
  - Allocations (memory usage)
  - Leaks (memory leaks)

## Configuration

### Environment Variables

Create a `.env` file (not committed to git):

```bash
API_BASE_URL=https://api.example.com
OPENAI_API_KEY=your_openai_key_here
WEBSOCKET_URL=wss://api.example.com/realtime
```

### Build Configurations

- **Debug**: Development builds with debugging symbols
- **Release**: Optimized builds for production
- **Testing**: For running tests

## Troubleshooting

### Common Issues

**Issue: "No such module 'RealityKit'"**
- Solution: Ensure visionOS SDK is selected, not iOS

**Issue: Simulator crashes on launch**
- Solution: Reset simulator (Device → Erase All Content and Settings)

**Issue: "Signing requires a development team"**
- Solution: Add Apple ID in Xcode Preferences → Accounts

**Issue: Build fails with Swift errors**
- Solution: Clean build folder (⇧⌘K), then rebuild

**Issue: 3D content not appearing**
- Solution: Check RealityView is properly configured, verify entities are added to content

### Reset Everything

```bash
# Clean build artifacts
xcodebuild clean

# Remove derived data
rm -rf ~/Library/Developer/Xcode/DerivedData

# Reset simulator
xcrun simctl erase all
```

## Performance Optimization

### Target Metrics

- **Frame Rate**: 90 FPS (target for visionOS)
- **Memory**: <2GB usage
- **CPU**: <50% sustained
- **Battery**: <30% drain per hour

### Profiling

1. Build in Release mode
2. Run Instruments (⌘I)
3. Select Time Profiler
4. Record session (red button)
5. Interact with app
6. Stop recording
7. Analyze call tree for hotspots

### Optimization Tips

- Use `@Observable` instead of `@ObservableObject` (less overhead)
- Implement LOD (Level of Detail) for 3D assets
- Limit particles and real-time effects
- Cache network responses
- Use lazy loading for lists

## Deployment

### TestFlight Beta

1. Archive the app (Product → Archive)
2. Upload to App Store Connect
3. Add to TestFlight
4. Invite beta testers via email
5. Testers install via TestFlight app

### App Store Release

1. Prepare metadata in App Store Connect
2. Submit for review
3. Wait for approval (typically 1-3 days)
4. Release to App Store

### Enterprise Distribution

For internal enterprise use:
1. Enroll in Apple Developer Enterprise Program
2. Create distribution certificate
3. Build with enterprise profile
4. Distribute via MDM or direct download

## Additional Resources

### Apple Documentation

- [visionOS Documentation](https://developer.apple.com/visionos/)
- [visionOS HIG](https://developer.apple.com/design/human-interface-guidelines/visionos)
- [RealityKit Documentation](https://developer.apple.com/documentation/realitykit/)
- [SwiftUI for visionOS](https://developer.apple.com/documentation/swiftui/bringing-your-app-to-visionos)

### Sample Code

- [Apple visionOS Samples](https://developer.apple.com/documentation/visionos/world)
- [WWDC Sessions](https://developer.apple.com/videos/)

### Community

- [Apple Developer Forums](https://developer.apple.com/forums/)
- [Stack Overflow - visionOS tag](https://stackoverflow.com/questions/tagged/visionos)

## Support

For issues, questions, or contributions:
- GitHub Issues: [Report an issue](https://github.com/your-org/visionOS_spatial-meeting-platform/issues)
- Documentation: See `/docs` folder
- Email: support@example.com

---

**Happy Building! 🚀**
