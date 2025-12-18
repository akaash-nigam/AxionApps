# Science Lab Sandbox - Quick Start Guide

**Get up and running in 5 minutes**

---

## ⚡ Prerequisites

Before you begin, ensure you have:

- ✅ **macOS 15.0 Sequoia** or later
- ✅ **Xcode 16.0** or later (download from Mac App Store)
- ✅ **Apple Vision Pro** or visionOS Simulator
- ✅ **15GB free disk space** for Xcode and visionOS SDK

---

## 🚀 Method 1: Create New Xcode Project (Recommended)

### Step 1: Clone the Repository

```bash
git clone <repository-url>
cd visionOS_Gaming_science-lab-sandbox
```

### Step 2: Open Xcode

```bash
open -a Xcode
```

### Step 3: Create New visionOS Project

1. In Xcode: **File → New → Project**
2. Select **visionOS** tab
3. Choose **App** template
4. Click **Next**

### Step 4: Configure Project

```
Product Name: ScienceLabSandbox
Team: [Your Team]
Organization Identifier: com.yourcompany
Interface: SwiftUI
Language: Swift
```

Click **Next**, choose location, **Create**

### Step 5: Copy Source Files

```bash
# In Terminal, from repository directory
cp -R ScienceLabSandbox/* /path/to/your/new/ScienceLabSandbox/
```

Or manually drag and drop all files from `ScienceLabSandbox/` folder into your Xcode project.

### Step 6: Add Capabilities

1. Select project in Xcode sidebar
2. Select **ScienceLabSandbox** target
3. Go to **Signing & Capabilities** tab
4. Click **+ Capability**
5. Add:
   - Hand Tracking
   - Scene Understanding
   - Group Activities

### Step 7: Create Entitlements

Create `ScienceLabSandbox.entitlements` file:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.arkit.hand-tracking</key>
    <true/>
    <key>com.apple.developer.scene-understanding</key>
    <true/>
    <key>com.apple.developer.group-activities</key>
    <true/>
</dict>
</plist>
```

### Step 8: Build and Run

1. Select **Apple Vision Pro** or **visionOS Simulator** as destination
2. Press **⌘R** or click **Run**
3. Wait for build (first time takes 2-3 minutes)
4. App launches on device/simulator

**Done! You're running Science Lab Sandbox!** 🎉

---

## 🚀 Method 2: Use Swift Package (Alternative)

### Step 1: Clone Repository

```bash
git clone <repository-url>
cd visionOS_Gaming_science-lab-sandbox
```

### Step 2: Open in Xcode

```bash
open Package.swift
```

Xcode will automatically recognize it as a Swift Package.

### Step 3: Build

Press **⌘B** to build.

**Note:** This method has limitations. Method 1 is recommended for full functionality.

---

## 🎮 First Launch: What to Expect

### Main Menu
- Beautiful gradient background
- Menu options: New Experiment, Choose Laboratory, My Progress, Settings
- Player stats at bottom (Level, Experiments, Achievements, Lab Time)

### Settings
- Difficulty modes (Beginner to Adaptive)
- Immersion styles (Mixed, Progressive, Full)
- Audio controls
- Accessibility options

### Progress View
- Current level and XP progress
- Statistics (experiments, lab time, measurements)
- Skill levels for each discipline
- Achievements showcase

### Immersive Laboratory (in development)
- Chemistry station with lab bench
- Basic beaker and burner models
- Tap to interact (console logs interaction)

---

## 🧪 Try Your First Experiment

1. Launch the app
2. Tap **"Choose Laboratory"**
3. Select **Chemistry**
4. Choose **"Acid-Base Titration"** experiment
5. Follow step-by-step instructions
6. Record observations and measurements
7. Complete the experiment
8. View your results and AI feedback

**Note:** Full experiment functionality requires additional development (Phase 3).

---

## 🛠 Development Quick Reference

### Project Structure
```
ScienceLabSandbox/
├── App/                      # Main app and coordinator
├── Game/                     # Game logic and state
├── Systems/                  # Core systems (Physics, Input, Audio, AI)
├── Scenes/                   # RealityKit scenes
├── Views/                    # SwiftUI views
├── Models/                   # Data models
├── Resources/                # Assets and config
├── Utilities/                # Helpers
└── Tests/                    # Unit tests
```

### Key Files to Explore

| File | Purpose |
|------|---------|
| `App/ScienceLabSandboxApp.swift` | Main entry point |
| `App/GameCoordinator.swift` | Central coordinator |
| `Game/GameLogic/ExperimentManager.swift` | Experiment management |
| `Models/Experiment.swift` | Experiment definitions |
| `Views/UI/MainMenu/MainMenuView.swift` | Main menu UI |
| `Scenes/ImmersiveViews/LaboratoryImmersiveView.swift` | 3D laboratory |

### Adding a New Experiment

Edit `ExperimentManager.swift` in `loadExperimentLibrary()`:

```swift
let myExperiment = Experiment(
    name: "My Custom Experiment",
    discipline: .chemistry,
    difficulty: .beginner,
    description: "Learn about...",
    learningObjectives: ["Objective 1", "Objective 2"],
    requiredEquipment: [.beaker, .testTube],
    safetyLevel: .safe,
    estimatedDuration: 600,
    instructions: [
        ExperimentStep(
            stepNumber: 1,
            title: "First Step",
            instruction: "Do this...",
            expectedDuration: 60
        )
    ]
)

experimentLibrary.append(myExperiment)
```

### Running Tests

```bash
# Command line
swift test

# Or in Xcode
Product → Test (⌘U)
```

### Building for Different Targets

```bash
# Simulator
xcodebuild -scheme ScienceLabSandbox -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

# Device
xcodebuild -scheme ScienceLabSandbox -destination 'platform=visionOS'
```

---

## 📱 Simulator Controls

### Mouse/Trackpad
- **Click**: Tap gesture
- **Click + Drag**: Pan/rotate objects
- **Option + Click**: Pinch gesture
- **Two-finger scroll**: Scroll content

### Keyboard Shortcuts
- **⌘H**: Toggle hand tracking visualization
- **⌘E**: Toggle eye tracking visualization
- **⌘R**: Reset view
- **Esc**: Exit immersive space

---

## 🐛 Common Issues & Solutions

### Issue: "Cannot find type 'Entity' in scope"

**Solution:** Ensure `import RealityKit` is at top of file.

### Issue: "Hand tracking not available"

**Solution:** Check entitlements are configured correctly.

### Issue: Build fails with concurrency errors

**Solution:** Ensure Swift 6.0 is selected and strict concurrency is enabled in build settings.

### Issue: Simulator crashes

**Solution:**
1. Quit Simulator
2. Xcode → Product → Clean Build Folder (⌘⇧K)
3. Restart Xcode
4. Try again

### Issue: Files not found after copying

**Solution:** In Xcode, right-click project → Add Files to "ScienceLabSandbox" → Select all copied files.

---

## 📚 Next Steps

### Explore the Documentation

1. **[README.md](README.md)** - Full project overview
2. **[ARCHITECTURE.md](ARCHITECTURE.md)** - System design
3. **[TECHNICAL_SPEC.md](TECHNICAL_SPEC.md)** - Implementation specs
4. **[DESIGN.md](DESIGN.md)** - Game design
5. **[IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md)** - Roadmap

### Start Developing

**Easy Tasks (Good for beginners):**
- Add new chemicals to `Chemical.swift`
- Add new equipment types to `ScientificEquipment.swift`
- Create new achievements in `PlayerProgress.swift`
- Add new experiments to `ExperimentManager.swift`
- Customize UI colors and styles

**Intermediate Tasks:**
- Implement new scientific calculations in `PhysicsManager.swift`
- Add new RealityKit entities in `LaboratoryImmersiveView.swift`
- Create new UI views for specific experiments
- Add particle effects for reactions
- Implement new gestures in `InputManager.swift`

**Advanced Tasks:**
- Complete chemistry reaction engine
- Implement full ARKit hand tracking
- Add multiplayer SharePlay features
- Create custom RealityKit components
- Implement voice command recognition

---

## 🎯 Development Checklist

### Getting Started ✅
- [ ] Xcode 16+ installed
- [ ] Repository cloned
- [ ] Project created in Xcode
- [ ] Files copied
- [ ] Capabilities added
- [ ] Entitlements configured
- [ ] App builds successfully
- [ ] App runs on simulator
- [ ] Explored main menu
- [ ] Viewed progress screen

### Ready to Code ✅
- [ ] Read ARCHITECTURE.md
- [ ] Read TECHNICAL_SPEC.md
- [ ] Understand project structure
- [ ] Reviewed existing code
- [ ] Unit tests pass
- [ ] Created first branch
- [ ] Made first commit

---

## 💡 Pro Tips

### Performance
- Keep frame rate at 90 FPS - profile regularly with Instruments
- Use LOD (Level of Detail) for 3D models
- Implement object pooling for frequently created entities

### Code Quality
- Follow Swift 6.0 concurrency patterns
- Use meaningful variable names
- Add documentation comments
- Write tests for new features

### RealityKit
- Keep entity hierarchies shallow
- Use components instead of subclassing
- Implement systems for game logic
- Cache frequently used resources

### Debugging
- Use `print()` liberally during development
- Check Xcode console for logs
- Use breakpoints to inspect state
- Profile with Instruments regularly

---

## 🆘 Getting Help

### Documentation
- Check [TECHNICAL_SPEC.md](TECHNICAL_SPEC.md) for implementation details
- See [ARCHITECTURE.md](ARCHITECTURE.md) for system design
- Review [DESIGN.md](DESIGN.md) for UX guidance

### External Resources
- [Apple visionOS Documentation](https://developer.apple.com/visionos/)
- [RealityKit Documentation](https://developer.apple.com/documentation/realitykit/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [Swift Documentation](https://swift.org/documentation/)

### Code Comments
- All major files have inline documentation
- Check function headers for usage examples
- Review existing tests for usage patterns

---

## ✨ You're All Set!

You now have a fully functional visionOS app running on your development machine. Happy coding! 🚀

**Next:** Check out [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) to see the full 24-month roadmap and pick what you want to build next.

---

<p align="center">
  <strong>Welcome to Science Lab Sandbox development! 🔬</strong>
</p>
