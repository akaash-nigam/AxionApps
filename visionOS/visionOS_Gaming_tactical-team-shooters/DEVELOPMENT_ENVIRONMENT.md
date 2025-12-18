# Development Environment Setup

Complete guide to setting up your development environment for Tactical Team Shooters.

## Required Software

### macOS

- **Version**: macOS 14.0 (Sonoma) or later
- **Recommended**: macOS 14.5+ for best visionOS simulator performance

### Xcode

- **Version**: Xcode 16.0 or later
- **Download**: [Mac App Store](https://apps.apple.com/app/xcode/id497799835)
- **Size**: ~15 GB

**Installation**:
```bash
# Install from App Store
# Or download from developer.apple.com

# Accept license
sudo xcodebuild -license accept

# Install command line tools
xcode-select --install
```

### Swift

- **Version**: Swift 6.0+
- **Included**: With Xcode 16.0+

**Verify**:
```bash
swift --version
# Should show: Swift version 6.0+
```

## Optional Tools

### SwiftLint

Code linting and style enforcement.

```bash
# Install via Homebrew
brew install swiftlint

# Verify
swiftlint version

# Run
swiftlint
```

### Homebrew

Package manager for macOS.

```bash
# Install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Verify
brew --version
```

### Git

Version control (usually pre-installed).

```bash
# Check version
git --version

# Configure
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

## Xcode Configuration

### Preferences

**Accounts** (⌘,):
- Add your Apple ID
- Download provisioning profiles

**Text Editing**:
- Indentation: 4 spaces
- Enable "Trim trailing whitespace"
- Enable "Include whitespace-only lines"

**Fonts & Colors**:
- Choose preferred theme
- Font size: 11-13pt recommended

**Behaviors**:
- Configure build success/failure behaviors

### Key Bindings

Recommended shortcuts:
- Build: ⌘B
- Run: ⌘R
- Test: ⌘U
- Clean: ⌘⇧K
- Navigate: ⌘⇧O (Open Quickly)

## visionOS Simulator

### Setup

1. **Open Xcode**
2. **Window → Devices and Simulators**
3. **Simulators Tab → +**
4. **Select**: Apple Vision Pro
5. **Create**

### Configuration

- **Graphics Quality**: Automatic or High
- **Location**: Set if testing location features

### Limitations

**Cannot Test**:
- Hand tracking (limited gesture support)
- Eye tracking
- Physical comfort
- True performance (slower than device)

**Can Test**:
- UI layouts
- Basic interactions
- Game logic
- Most features

## Vision Pro Device

### Developer Mode

1. **Settings → Privacy & Security**
2. **Developer Mode → On**
3. **Restart** device

### Pairing with Xcode

1. **Connect** Vision Pro via USB-C
2. **Xcode → Window → Devices and Simulators**
3. **Trust** this computer on Vision Pro
4. **Select** device as run destination

### Wireless Debugging

1. **Connect via USB** first
2. **Devices and Simulators → Connect via Network**
3. **Disconnect USB** after pairing
4. **Select** networked device in Xcode

## Project Setup

### Clone Repository

```bash
git clone https://github.com/yourorg/visionOS_Gaming_tactical-team-shooters.git
cd visionOS_Gaming_tactical-team-shooters
```

### Open Project

```bash
# Open Package
open Package.swift

# Or from Xcode
# File → Open → Select Package.swift
```

### First Build

```bash
# Command line
swift build

# Or in Xcode
Product → Build (⌘B)
```

Expected time: 2-3 minutes

## IDE Alternatives

### VS Code

Can be used for Swift development with extensions.

**Extensions**:
- Swift Language
- CodeLLDB (debugging)
- GitLens

**Note**: Xcode required for building visionOS apps

## Environment Variables

### For Development

```bash
# Add to ~/.zshrc or ~/.bash_profile

# Xcode path
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer

# Swift toolchain
export TOOLCHAINS=swift

# Project-specific
export TTS_ENV=development
export TTS_LOG_LEVEL=debug
```

## Performance Optimization

### Build Settings

For faster builds:

```swift
// Package.swift
.target(
    name: "TacticalTeamShooters",
    swiftSettings: [
        .unsafeFlags(["-Xfrontend", "-warn-long-expression-type-checking=100"]),
        .unsafeFlags(["-Xfrontend", "-warn-long-function-bodies=100"])
    ]
)
```

### Derived Data

Clear periodically for issues:

```bash
rm -rf ~/Library/Developer/Xcode/DerivedData
```

## Testing Setup

### Run Tests

```bash
# All tests
swift test

# Specific test
swift test --filter PlayerTests

# With coverage
swift test --enable-code-coverage
```

### Continuous Testing

```bash
# Watch for changes and re-run tests
# (requires nodemon or similar)
nodemon --exec "swift test" --ext swift
```

## Debugging Setup

### LLDB

Comes with Xcode.

**Custom commands** (`~/.lldbinit`):
```lldb
# Custom aliases
command alias bd breakpoint disable
command alias be breakpoint enable
```

### Instruments

Profiling tool included with Xcode.

**Launch**:
- Xcode → Product → Profile (⌘I)

## Version Control

### Git Configuration

```bash
# Global config
git config --global core.editor "code --wait"
git config --global merge.tool opendiff
git config --global core.excludesfile ~/.gitignore_global

# Project-specific .gitignore
# Already included in repository
```

### Pre-commit Hooks

```bash
# Install
cp scripts/pre-commit-hook.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

## Documentation Tools

### DocC

Built into Xcode 13+.

**Generate**:
```bash
# Build documentation
xcodebuild docbuild -scheme TacticalTeamShooters

# Or in Xcode
Product → Build Documentation (⌃⇧⌘D)
```

## Troubleshooting

### Common Issues

**"No such module RealityKit"**:
- Ensure Xcode 16.0+ installed
- Check deployment target is visionOS 2.0+

**Build fails**:
```bash
# Clean and rebuild
rm -rf .build
swift build
```

**Simulator not appearing**:
- Xcode → Preferences → Components
- Download visionOS Simulator

## System Requirements

### Minimum

- **Mac**: Apple Silicon M1 or Intel with 16GB RAM
- **macOS**: 14.0+
- **Storage**: 30GB free space
- **Internet**: For downloading dependencies

### Recommended

- **Mac**: Apple Silicon M2 Pro/Max with 32GB RAM
- **macOS**: 14.5+
- **Storage**: 50GB+ free space
- **Display**: 2K or higher resolution

## Updates

Keep tools up to date:

```bash
# Update Homebrew
brew update && brew upgrade

# Update Xcode
# Check Mac App Store

# Update SwiftLint
brew upgrade swiftlint
```

## Next Steps

1. ✅ Complete this setup
2. 📖 Read [QUICK_START.md](QUICK_START.md)
3. 🎮 Build and run the app
4. ✏️ Make your first change
5. 🧪 Run tests
6. 📝 Read [CONTRIBUTING.md](CONTRIBUTING.md)

## Resources

- [Xcode Documentation](https://developer.apple.com/documentation/xcode)
- [visionOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/visionos)
- [Swift Documentation](https://www.swift.org/documentation/)

## Questions?

- Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- See [FAQ.md](FAQ.md)
- Open GitHub Discussion

---

**Last Updated**: 2025-11-19
