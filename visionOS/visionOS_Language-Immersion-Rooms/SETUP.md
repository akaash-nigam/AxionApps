# Development Setup Guide

Complete guide to setting up your development environment for Language Immersion Rooms.

## Table of Contents

- [System Requirements](#system-requirements)
- [Quick Start](#quick-start)
- [Detailed Setup](#detailed-setup)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)
- [IDE Setup](#ide-setup)

---

## System Requirements

### Minimum Requirements

- **macOS**: 14.0 (Sonoma) or later
- **Xcode**: 16.0 or later
- **visionOS SDK**: 2.0 or later
- **RAM**: 16GB minimum, 32GB recommended
- **Storage**: 50GB free space (for Xcode + simulators)
- **CPU**: Apple Silicon (M1/M2/M3) recommended

### Optional Tools

- **Swift Lint**: Code quality tool
- **Git**: Version control (usually pre-installed)
- **Homebrew**: Package manager for macOS

---

## Quick Start

```bash
# 1. Install Xcode from App Store
# 2. Install Command Line Tools
xcode-select --install

# 3. Clone the repository
git clone https://github.com/YOUR_USERNAME/visionOS_Language-Immersion-Rooms.git
cd visionOS_Language-Immersion-Rooms

# 4. Install SwiftLint (optional)
brew install swiftlint

# 5. Open project
open LanguageImmersionRooms.xcodeproj

# 6. Select destination: Apple Vision Pro (Simulator)
# 7. Press ⌘+R to build and run
```

---

## Detailed Setup

### 1. Install Xcode

**Via App Store** (Recommended):
1. Open **App Store** app
2. Search for **"Xcode"**
3. Click **Get** or **Update**
4. Wait for download (12+ GB)
5. Launch Xcode to complete installation

**Via Direct Download**:
1. Visit [developer.apple.com/download](https://developer.apple.com/download)
2. Sign in with Apple ID
3. Download **Xcode 16.0+**
4. Move to `/Applications`
5. Run `sudo xcode-select -s /Applications/Xcode.app`

**Verify Installation**:
```bash
xcodebuild -version
# Should show: Xcode 16.0 or later
```

### 2. Install visionOS Simulator

1. Open **Xcode**
2. Go to **Settings** (⌘+,)
3. Select **Platforms** tab
4. Click **+** (bottom left)
5. Select **visionOS 2.0** or later
6. Click **Get**
7. Wait for download (~5GB)

**Verify**:
```bash
xcrun simctl list devices | grep "Vision Pro"
# Should show: Apple Vision Pro (visionOS 2.0)
```

### 3. Install Command Line Tools

```bash
xcode-select --install
```

Click **Install** in the popup dialog.

**Verify**:
```bash
xcode-select -p
# Should show: /Applications/Xcode.app/Contents/Developer
```

### 4. Install Homebrew (Optional but Recommended)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Follow on-screen instructions to add to PATH.

**Verify**:
```bash
brew --version
# Should show: Homebrew 4.0+
```

### 5. Install SwiftLint

```bash
brew install swiftlint
```

**Verify**:
```bash
swiftlint version
# Should show: 0.50.0 or later
```

### 6. Clone the Repository

**Using HTTPS**:
```bash
git clone https://github.com/YOUR_USERNAME/visionOS_Language-Immersion-Rooms.git
cd visionOS_Language-Immersion-Rooms
```

**Using SSH** (if configured):
```bash
git clone git@github.com:YOUR_USERNAME/visionOS_Language-Immersion-Rooms.git
cd visionOS_Language-Immersion-Rooms
```

### 7. Set Up Git Remotes

```bash
# Add upstream remote (original repository)
git remote add upstream https://github.com/ORIGINAL_OWNER/visionOS_Language-Immersion-Rooms.git

# Verify remotes
git remote -v
# Should show:
# origin    https://github.com/YOUR_USERNAME/... (fetch)
# origin    https://github.com/YOUR_USERNAME/... (push)
# upstream  https://github.com/ORIGINAL_OWNER/... (fetch)
# upstream  https://github.com/ORIGINAL_OWNER/... (push)
```

### 8. Open the Project

```bash
open LanguageImmersionRooms.xcodeproj
```

Or from Xcode:
1. File → Open
2. Navigate to project folder
3. Select `LanguageImmersionRooms.xcodeproj`

---

## Configuration

### Xcode Project Settings

1. **Select Project** in Navigator (left sidebar)
2. **Select Target**: LanguageImmersionRooms
3. **General Tab**:
   - Bundle Identifier: `com.yourcompany.languageimmersionrooms`
   - Team: Select your development team
   - Deployment Target: visionOS 2.0

4. **Signing & Capabilities**:
   - Automatically manage signing: ✓ (checked)
   - Team: Your team
   - Capabilities: Sign in with Apple, Speech Recognition

### Environment Variables (API Keys)

1. **Product** → **Scheme** → **Edit Scheme** (⌘+<)
2. Select **Run** (left sidebar)
3. **Arguments** tab
4. **Environment Variables** section
5. Click **+** to add:
   - Name: `OPENAI_API_KEY`
   - Value: `your-api-key-here`

**Important**: Never commit API keys to the repository!

### Build Settings

**Debug Configuration** (default for development):
- Optimization Level: None
- Swift Compilation Mode: Incremental
- Debug Information Format: DWARF with dSYM

**Release Configuration** (for distribution):
- Optimization Level: Optimize for Speed
- Swift Compilation Mode: Whole Module
- Debug Information Format: DWARF with dSYM

### Simulator Settings

1. **Select Destination**: Apple Vision Pro (Simulator)
2. **Window** → **Devices and Simulators** (⌘+Shift+2)
3. **Simulators** tab
4. Select **Apple Vision Pro**
5. Settings:
   - Name: Apple Vision Pro
   - OS Version: visionOS 2.0 or later

---

## Running the App

### First Run

1. **Select Destination**: Apple Vision Pro (Simulator)
2. **Build** (⌘+B) to verify no errors
3. **Run** (⌘+R) to launch

**Expected**:
- Simulator launches
- App installs and opens
- Sign-in screen appears

### Subsequent Runs

- Press **⌘+R** to build and run
- Or click the **Play** button (▶️) in toolbar

### Running Tests

**All Tests**:
```bash
# Via script
./run_tests.sh

# Via xcodebuild
xcodebuild test \
  -scheme LanguageImmersionRooms \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

**Specific Tests**:
```bash
# Unit tests only
xcodebuild test \
  -scheme LanguageImmersionRooms \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:LanguageImmersionRoomsTests/Unit
```

**In Xcode**:
1. Press **⌘+U** to run all tests
2. Or **Test Navigator** (⌘+6) → Click diamond (◆) next to test

---

## Troubleshooting

### Common Issues

#### Issue: "Unable to boot simulator"

**Solution**:
```bash
# Kill simulator processes
killall Simulator

# Reset simulator
xcrun simctl shutdown all
xcrun simctl erase all

# Restart Xcode
```

#### Issue: "No such module 'RealityKit'"

**Solution**:
1. Xcode → Settings → Platforms
2. Verify visionOS SDK is installed
3. Clean build folder (⌘+Shift+K)
4. Build again (⌘+B)

#### Issue: "Signing for 'LanguageImmersionRooms' requires a development team"

**Solution**:
1. Select project in Navigator
2. Target → Signing & Capabilities
3. Team: Select your team
4. Or create free Apple ID team

#### Issue: "Swift compiler crashed"

**Solution**:
```bash
# Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData

# Clean build folder
# In Xcode: Product → Clean Build Folder (⌘+Shift+K)

# Restart Xcode
```

#### Issue: "SourceKit service crashed"

**Solution**:
1. Close Xcode
2. Delete derived data:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```
3. Reopen Xcode

#### Issue: SwiftLint warnings/errors

**Solution**:
```bash
# Run SwiftLint to see issues
swiftlint

# Auto-fix some issues
swiftlint --fix

# Or disable in Xcode:
# Build Phases → Remove "SwiftLint" run script
```

### Performance Issues

If Xcode is slow:

1. **Disable indexing temporarily**:
   ```bash
   defaults write com.apple.dt.XCode IDEIndexDisable 1
   # Re-enable: defaults delete com.apple.dt.XCode IDEIndexDisable
   ```

2. **Close other apps**:
   - Simulator uses significant memory
   - Close browsers, Slack, etc.

3. **Increase RAM allocation**:
   - For simulator: Xcode → Settings → Simulators
   - Adjust memory allocation

4. **Use Release build**:
   - Product → Scheme → Edit Scheme
   - Run → Build Configuration → Release

### Build Errors

#### "Missing required module"

```bash
# Clean and rebuild
rm -rf ~/Library/Developer/Xcode/DerivedData
xcodebuild clean build -scheme LanguageImmersionRooms
```

#### "Duplicate symbols"

- Check for duplicate file references in project
- Remove duplicate files from Target → Build Phases → Compile Sources

#### "Linker command failed"

- Verify all frameworks are properly linked
- Target → General → Frameworks, Libraries, and Embedded Content

---

## IDE Setup

### Xcode Preferences

**Recommended Settings**:

1. **Editor** → **Font & Colors**:
   - Theme: Xcode Default or Dusk
   - Font: SF Mono, 12pt

2. **Text Editing**:
   - ✓ Line numbers
   - ✓ Code folding ribbon
   - Tab width: 4 spaces
   - Indent width: 4 spaces
   - ✓ Convert tabs to spaces

3. **Behaviors**:
   - Build → Show: Navigator (Issues)
   - Test → Show: Navigator (Tests)
   - Build fails → Show: Navigator (Issues)

4. **Key Bindings**:
   - All defaults (or customize to your preference)

5. **Source Control**:
   - ✓ Enable source control
   - ✓ Refresh local status automatically
   - ✓ Show source control changes

### Xcode Extensions (Optional)

1. **Copilot** (if you have GitHub Copilot):
   - Install from Xcode Settings → Extensions

2. **SourceTree** (GUI for Git):
   ```bash
   brew install --cask sourcetree
   ```

3. **Kaleidoscope** (Diff tool):
   ```bash
   brew install --cask kaleidoscope
   ```

### Keyboard Shortcuts

Essential shortcuts:
- **⌘+B**: Build
- **⌘+R**: Run
- **⌘+.**: Stop
- **⌘+U**: Test
- **⌘+Shift+K**: Clean Build Folder
- **⌘+Shift+O**: Open Quickly (file search)
- **⌘+Ctrl+Up**: Switch between .swift and Tests
- **⌘+/**: Toggle comment
- **⌘+[**: Shift left
- **⌘+]**: Shift right

---

## Development Workflow

### Daily Workflow

```bash
# 1. Start of day - sync with upstream
git checkout develop
git fetch upstream
git merge upstream/develop

# 2. Create feature branch
git checkout -b feature/my-feature

# 3. Make changes, commit regularly
git add .
git commit -m "feat(scope): description"

# 4. Run tests before pushing
./run_tests.sh

# 5. Push to your fork
git push origin feature/my-feature

# 6. Create PR on GitHub
```

### Before Committing

```bash
# 1. Run SwiftLint
swiftlint

# 2. Run tests
./run_tests.sh

# 3. Build for release
xcodebuild build -scheme LanguageImmersionRooms -configuration Release

# 4. Check for warnings
# (Should see 0 warnings in Xcode)
```

---

## Additional Tools

### Instruments (Profiling)

1. **Product** → **Profile** (⌘+I)
2. Select template:
   - **Time Profiler**: CPU performance
   - **Allocations**: Memory usage
   - **Leaks**: Memory leaks
3. Record and analyze

### Reality Composer (RealityKit Assets)

1. Open **Reality Composer** app
2. Create 3D assets
3. Export to project

### Accessibility Inspector

1. **Xcode** → **Open Developer Tool** → **Accessibility Inspector**
2. Inspect app for accessibility issues
3. Test with VoiceOver

---

## Getting Help

- **Xcode Documentation**: Help → Developer Documentation
- **Apple Forums**: [developer.apple.com/forums](https://developer.apple.com/forums)
- **Stack Overflow**: Tag with `visionos` and `swiftui`
- **Project Issues**: [GitHub Issues](https://github.com/OWNER/REPO/issues)

---

## Next Steps

After setup:
1. Read [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines
2. Review [ARCHITECTURE.md](ARCHITECTURE.md) to understand the codebase
3. Browse [docs/](docs/) for design documentation
4. Run tests to verify everything works: `./run_tests.sh`
5. Make your first contribution!

---

**Last Updated**: 2025-11-24
**Version**: 1.0
