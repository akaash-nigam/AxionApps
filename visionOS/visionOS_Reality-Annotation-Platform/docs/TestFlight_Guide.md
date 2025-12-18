# TestFlight Beta Testing Guide
## Reality Annotation Platform - MVP v1.0

**Last Updated**: November 2024
**Build**: MVP Release Candidate
**Target Device**: Apple Vision Pro
**OS Requirements**: visionOS 1.0+

---

## Welcome Beta Testers!

Thank you for helping us test the Reality Annotation Platform! This is an MVP (Minimum Viable Product) release, and your feedback is crucial for making this app amazing.

---

## What is Reality Annotations?

Reality Annotations lets you leave **spatial notes** in physical space that persist across time and devices. Think of it as sticky notes for the real world, but in 3D space.

### Key Features in This MVP:

✅ **Text Annotations**: Create text notes anchored in 3D space
✅ **AR Placement**: Tap in space to place annotations
✅ **Persistent Across Sessions**: Your annotations stay where you left them
✅ **CloudKit Sync**: Annotations sync across all your Apple Vision Pro devices
✅ **Layer Organization**: Group annotations in layers
✅ **2D UI**: Manage annotations from a traditional UI when not in AR

---

## Getting Started

### First Launch

1. **Grant Permissions**: The app needs access to spatial data for AR features
2. **Watch Onboarding**: A 5-screen introduction will guide you through the basics
3. **Sign in with iCloud**: Required for syncing (uses your Apple ID)

### Creating Your First Annotation

1. Tap **"Enter AR Mode"** on the Home screen
2. Look around your space - you'll see a cursor
3. **Tap in space** where you want to place an annotation
4. A creation panel will appear
5. Enter your **title** (optional) and **content** (required)
6. Tap **"Create"**
7. Your annotation appears in space! 🎉

### Managing Annotations

- **View All**: Go to the "Annotations" tab to see a list
- **Edit**: Tap any annotation in the list → Tap "Edit" → Make changes → Save
- **Delete**: Tap annotation → Scroll down → Tap "Delete" → Confirm
- **Sort**: Use the sort menu (⇅ icon) to sort by date or title

### Using Layers

Layers help organize annotations:
- **Default Layer**: All annotations start in "Default"
- **View Layers**: Go to the "Layers" tab
- **Toggle Visibility**: Tap the eye icon to show/hide a layer's annotations
- **Note**: MVP supports 1 layer (more coming in v2.0!)

### Sync Settings

Go to **Settings → CloudKit Sync**:
- **Status**: Shows Ready/Syncing/Error/Offline
- **Sync Now**: Manual sync trigger
- **Automatic Sync**: Toggle auto-sync (syncs every 60 seconds when online)
- **Last Sync**: Shows when last sync completed

---

## What to Test

### Critical Flows

1. **Onboarding Experience**
   - Is it clear and helpful?
   - Any confusing steps?

2. **AR Annotation Placement**
   - Can you easily place annotations?
   - Do they stay in the right position?
   - Do they face you (billboard behavior)?

3. **CRUD Operations**
   - Create annotations (AR and 2D UI)
   - View annotation details
   - Edit annotations
   - Delete annotations

4. **CloudKit Sync**
   - Do annotations sync across devices?
   - Does offline mode work?
   - Do conflicts resolve correctly?

5. **Performance**
   - Is the app smooth with 25+ annotations?
   - Any lag or frame drops?

### Edge Cases to Try

- **Offline Mode**: Turn off Wi-Fi and create annotations
- **Many Annotations**: Create 25-50 annotations in one space
- **Long Content**: Try very long annotation text (1000+ characters)
- **Rapid Actions**: Create/delete multiple annotations quickly
- **App Backgrounding**: Switch apps and come back

---

## Known Issues

### Current Limitations (MVP)

- **Single Layer Only**: MVP supports 1 layer; multi-layer coming in v2.0
- **Text Only**: Photos, voice, and drawings coming in post-MVP updates
- **No Sharing**: Can't share annotations with others yet
- **Manual Relocalization**: If AR tracking is lost, you may need to restart AR mode
- **No Search**: Search functionality coming in v2.0

### Known Bugs

- ⚠️ First sync may take 10-15 seconds if you have many annotations
- ⚠️ Annotations may appear slightly offset if device tracking drifts
- ⚠️ Sync conflicts always use "last write wins" (no manual resolution yet)

---

## Feedback Guidelines

### What We Want to Know

**Bugs & Issues**:
- What happened?
- What were you trying to do?
- Can you reproduce it?
- Screenshots/screen recordings help!

**Feature Requests**:
- What feature would you like?
- What problem does it solve?
- How would you use it?

**UX Feedback**:
- Was anything confusing?
- What felt slow or clunky?
- What delighted you?

### How to Report

**In TestFlight**:
1. Shake your device (or trigger screenshot)
2. Tap "Send Feedback"
3. Include as much detail as possible

**Email**: feedback@realityannotations.com
**GitHub Issues**: [Project Repository](https://github.com/your-org/reality-annotations)

---

## Performance Expectations

### Target Performance

- **60+ FPS** with 25 annotations visible
- **< 100ms** annotation creation time
- **< 2s** sync time for single annotation
- **< 5s** app launch time

### If You Experience Issues

- Close and restart the app
- Check available storage (need 500MB+ free)
- Restart your Vision Pro
- Report persistent issues via TestFlight

---

## Privacy & Data

### What We Collect

- **Annotation Data**: Title, content, position, timestamps
- **Sync Metadata**: Last sync time, pending changes
- **Crash Logs**: Automated crash reports via TestFlight
- **Usage Analytics**: Basic usage stats (opt-in)

### What We DON'T Collect

- ❌ Location data
- ❌ Camera images
- ❌ Personal information beyond Apple ID
- ❌ Spatial scan of your environment

### Data Storage

- **Local**: SwiftData on device
- **Cloud**: CloudKit Private Database (your iCloud account)
- **Encrypted**: All data encrypted in transit and at rest

---

## FAQ

**Q: Do I need internet to use the app?**
A: No! The app works offline. Annotations sync when you're back online.

**Q: Will my annotations work on other devices?**
A: Yes, they sync via iCloud to all your Vision Pro devices.

**Q: How many annotations can I create?**
A: No hard limit, but performance is optimized for up to 100 annotations.

**Q: Can others see my annotations?**
A: Not in this MVP. Sharing features are planned for v2.0.

**Q: What if I find a critical bug?**
A: Please report it immediately via TestFlight feedback!

**Q: Can I delete all my data?**
A: Yes, via Settings → scroll down → "Delete All Data" (coming soon)

---

## Roadmap

### Post-MVP (v2.0+)

- 📸 Photo annotations
- 🎤 Voice memos
- ✏️ Drawings with PencilKit
- 📚 Multiple layers (up to 10)
- 🔍 Search annotations
- 👥 Share annotations with others
- 💬 Comments and reactions
- ⏰ Time-based visibility
- 📊 Advanced sorting and filtering

---

## Support

**Need Help?**
- Email: support@realityannotations.com
- TestFlight Feedback
- GitHub Issues

**Want to Stay Updated?**
- Twitter: @RealityAnnotate
- Website: realityannotations.com

---

## Thank You!

Your testing and feedback are invaluable. We're building this app for YOU, and your input shapes every decision we make.

Happy Annotating! 🎉

---

**Reality Annotations Team**
November 2024
