# Deployment Guide - Tactical Team Shooters

This guide covers the complete process of deploying **Tactical Team Shooters** to the Apple App Store for visionOS.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Pre-Deployment Checklist](#pre-deployment-checklist)
- [Build Configuration](#build-configuration)
- [Code Signing](#code-signing)
- [App Store Connect Setup](#app-store-connect-setup)
- [Submitting for Review](#submitting-for-review)
- [TestFlight Beta Testing](#testflight-beta-testing)
- [Release Management](#release-management)
- [Post-Release](#post-release)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Accounts

- **Apple Developer Account** ($99/year)
  - Enrolled in Apple Developer Program
  - Team Agent or Admin role
- **App Store Connect Access**
  - Admin or App Manager role

### Required Tools

- **macOS 14.0+** (Sonoma or later)
- **Xcode 16.0+** with visionOS SDK
- **Transporter** app (for uploading builds)
- **TestFlight** (for beta testing)

### Required Documentation

- App privacy details
- Export compliance information
- Marketing materials (screenshots, preview videos)
- App description and keywords

## Pre-Deployment Checklist

### Code Quality

- [ ] All tests pass (`swift test`)
- [ ] Code coverage ≥ 80%
- [ ] No compiler warnings
- [ ] SwiftLint violations resolved
- [ ] Performance targets met (120 FPS)
- [ ] Memory leaks resolved
- [ ] Security audit completed

### Functionality

- [ ] All features working on Vision Pro hardware
- [ ] Multiplayer tested with multiple devices
- [ ] Hand gesture controls tested
- [ ] Eye tracking calibrated and tested
- [ ] Spatial audio verified
- [ ] Room mapping tested in various environments
- [ ] All UI elements accessible and readable
- [ ] Accessibility features tested

### Content

- [ ] All assets optimized (3D models, textures, audio)
- [ ] No placeholder content
- [ ] All text localized (if supporting multiple languages)
- [ ] Profanity filter tested
- [ ] Content ratings appropriate

### Legal & Compliance

- [ ] Privacy policy updated
- [ ] Terms of service finalized
- [ ] COPPA compliance (if applicable)
- [ ] Export compliance determined
- [ ] Third-party licenses documented
- [ ] No unauthorized copyrighted material

### App Store Assets

- [ ] App icon (1024x1024 PNG, no transparency)
- [ ] Screenshots (at least 3, up to 10)
- [ ] Preview videos (optional, recommended)
- [ ] App description written
- [ ] Keywords researched and selected
- [ ] Support URL configured
- [ ] Marketing URL configured (landing page)

## Build Configuration

### 1. Update Version and Build Numbers

Edit `Info.plist`:

```xml
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
<key>CFBundleVersion</key>
<string>1</string>
```

Or use Xcode:
- Select project → Target → General
- Update **Version** (e.g., 1.0.0)
- Update **Build** (e.g., 1)

**Version Numbering**:
- **Major.Minor.Patch** (Semantic Versioning)
- Examples: 1.0.0 (initial release), 1.1.0 (new features), 1.0.1 (bug fixes)

**Build Numbers**:
- Must increment for each submission
- Can use date-based: 2025111901 (YYYYMMDD##)

### 2. Configure Build Settings

**Release Configuration**:

1. Select **Product → Scheme → Edit Scheme**
2. Set **Build Configuration** to **Release**
3. Uncheck **Debug executable**

**Optimization Settings**:

```swift
// Build Settings
SWIFT_OPTIMIZATION_LEVEL = -O
SWIFT_COMPILATION_MODE = wholemodule
ENABLE_BITCODE = NO  // Not supported on visionOS
GCC_OPTIMIZATION_LEVEL = s  // Optimize for size
```

**Code Signing**:

```
CODE_SIGN_STYLE = Manual
DEVELOPMENT_TEAM = [Your Team ID]
CODE_SIGN_IDENTITY = Apple Distribution
PROVISIONING_PROFILE_SPECIFIER = [Profile Name]
```

### 3. Archive the App

```bash
# Command line
xcodebuild archive \
  -scheme TacticalTeamShooters \
  -destination 'generic/platform=visionOS' \
  -archivePath ~/Desktop/TacticalTeamShooters.xcarchive

# Or use Xcode: Product → Archive
```

### 4. Export for App Store

```bash
xcodebuild -exportArchive \
  -archivePath ~/Desktop/TacticalTeamShooters.xcarchive \
  -exportPath ~/Desktop/ \
  -exportOptionsPlist ExportOptions.plist
```

**ExportOptions.plist**:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>uploadSymbols</key>
    <true/>
    <key>uploadBitcode</key>
    <false/>
</dict>
</plist>
```

## Code Signing

### 1. Create App ID

**App Store Connect**:
1. Go to **Certificates, Identifiers & Profiles**
2. Click **Identifiers** → **+**
3. Select **App IDs** → **Continue**
4. Description: `Tactical Team Shooters`
5. Bundle ID: `com.yourcompany.tacticalsquad` (explicit)
6. Capabilities:
   - ✅ Game Center
   - ✅ In-App Purchase
   - ✅ Multiplayer Networking (if using Game Center)
7. Click **Continue** → **Register**

### 2. Create Distribution Certificate

1. **Certificates** → **+**
2. Select **Apple Distribution**
3. Upload CSR (Certificate Signing Request)
   ```bash
   # Create CSR using Keychain Access:
   # Keychain Access → Certificate Assistant → Request a Certificate from a Certificate Authority
   ```
4. Download and install certificate

### 3. Create Provisioning Profile

1. **Profiles** → **+**
2. Select **App Store**
3. Choose App ID: `Tactical Team Shooters`
4. Select Distribution Certificate
5. Name: `Tactical Team Shooters Distribution`
6. Download and install profile

### 4. Configure Xcode

1. Xcode → Settings → Accounts
2. Select Apple ID → Download Manual Profiles
3. Project → Target → Signing & Capabilities
4. Uncheck **Automatically manage signing**
5. Select provisioning profile

## App Store Connect Setup

### 1. Create App Record

1. Log in to **App Store Connect**
2. **My Apps** → **+** → **New App**
3. Fill in details:
   - **Platform**: visionOS
   - **Name**: Tactical Team Shooters
   - **Primary Language**: English (U.S.)
   - **Bundle ID**: com.yourcompany.tacticalsquad
   - **SKU**: TTS-VISIONOS-2025
   - **User Access**: Full Access

### 2. App Information

**Category**:
- Primary: Games
- Secondary: Action

**Age Rating**:
- Complete questionnaire
- Likely rating: 17+ (due to realistic violence)

**Privacy Policy URL**:
- `https://yourdomain.com/privacy`

### 3. Pricing and Availability

**Price**:
- Free (with in-app purchases)
- Or: $29.99 (premium pricing)

**Availability**:
- All territories (or select specific countries)
- Available immediately upon approval

**Pre-Order** (optional):
- Enable for marketing campaigns

### 4. App Privacy

Complete privacy questionnaire:

**Data Collected**:
- User ID (for multiplayer)
- Gameplay stats
- Purchase history
- Device information

**Data Usage**:
- Analytics
- Multiplayer functionality
- Leaderboards

**Data Linked to User**:
- Yes (gameplay stats, purchases)

**Tracking**:
- No (if not using third-party analytics)

### 5. Version Information

**Version**: 1.0.0

**Copyright**: © 2025 Your Company Name

**What's New in This Version**:
```
Initial release of Tactical Team Shooters for Apple Vision Pro!

Features:
• Immersive 5v5 tactical team combat
• Advanced hand gesture and eye tracking controls
• Realistic ballistics and weapon physics
• Spatial audio with directional sound
• Competitive matchmaking and ranking system
• Multiple game modes and maps

Experience the future of competitive gaming in spatial computing!
```

**Description** (4000 character limit):
```
TACTICAL TEAM SHOOTERS - The Ultimate Spatial Combat Experience

Enter a new dimension of competitive gaming designed exclusively for Apple Vision Pro. Tactical Team Shooters delivers heart-pounding 5v5 combat with precision controls, realistic physics, and fully spatial gameplay.

🎮 REVOLUTIONARY GAMEPLAY
• Intuitive hand gesture controls for natural weapon handling
• Eye tracking for precision aiming
• Full spatial awareness with 360° combat environments
• Room-scale movement and positioning

⚔️ COMPETITIVE FEATURES
• Ranked matchmaking with ELO-based ranking system
• Multiple game modes: Bomb Defusal, Team Deathmatch, Control Points
• Progression system from Recruit to Legend
• Detailed stats tracking and leaderboards

🔫 AUTHENTIC WEAPON SYSTEM
• Realistic ballistics with bullet drop and travel time
• Weapon customization with attachments and skins
• Distinctive recoil patterns requiring skill mastery
• Balanced arsenal including assault rifles, SMGs, snipers, shotguns

🏆 PROFESSIONAL TRAINING
• Tactical scenarios for military and law enforcement
• Communication and coordination training
• Strategic gameplay requiring team coordination
• Realistic engagement simulations

🎧 IMMERSIVE AUDIO
• Spatial audio with directional sound positioning
• Environmental acoustics and occlusion
• Voice chat with 3D positioning
• Realistic weapon and environmental sounds

✨ VISIONOS FEATURES
• Progressive and full immersion modes
• Adaptive environments using room mapping
• Smooth 120 FPS performance
• Comfort-first design to minimize motion sickness

Perfect for competitive gamers seeking the next evolution in esports or professionals training for tactical scenarios.

Requires Apple Vision Pro and internet connection for multiplayer features.
```

**Keywords** (100 character limit):
```
fps,shooter,tactical,multiplayer,competitive,visionos,spatial,esports,combat,team
```

**Support URL**:
```
https://yourdomain.com/support
```

**Marketing URL**:
```
https://yourdomain.com/tactical-team-shooters
```

### 6. Screenshots and Previews

**Screenshot Requirements** (visionOS):
- Dimensions: 3840 x 2160 pixels (16:9 aspect ratio)
- Format: PNG or JPEG
- Color space: sRGB or P3
- Minimum: 3 screenshots
- Maximum: 10 screenshots

**Recommended Screenshots**:
1. Hero shot - Intense combat moment
2. Hand gesture controls demonstration
3. Weapon customization screen
4. Multiplayer lobby
5. Tactical gameplay showing teamwork
6. HUD and interface overview
7. Map overview
8. Character loadout screen

**App Preview Video** (optional, recommended):
- Duration: 15-30 seconds
- Resolution: 3840 x 2160
- Format: .mov, .m4v, or .mp4
- Show gameplay, controls, key features

**Capture Screenshots**:
```swift
// In visionOS Simulator or device
// Cmd + S (Simulator)
// Digital Crown + Top button (Device)
```

## Submitting for Review

### 1. Upload Build

**Using Xcode**:
1. Window → Organizer
2. Select archive
3. Click **Distribute App**
4. Select **App Store Connect**
5. Upload

**Using Transporter**:
1. Open Transporter app
2. Drag and drop .ipa file
3. Click **Deliver**

**Verify Upload**:
- App Store Connect → TestFlight → Builds
- Wait for processing (10-60 minutes)

### 2. Select Build for Release

1. App Store Connect → My Apps → Tactical Team Shooters
2. Version 1.0.0 → Build
3. Click **+** and select uploaded build
4. Save

### 3. Export Compliance

**Does your app use encryption?**
- Yes (for network communications)

**Is encryption limited to?**
- ✅ Standard encryption in HTTPS
- Self-assessment: No export compliance required

### 4. Content Rights

- [ ] I confirm this app does not contain, show, or access third-party content

### 5. Advertising Identifier

**Does this app use the Advertising Identifier (IDFA)?**
- No (unless using ad networks)

### 6. Submit for Review

1. Click **Add for Review**
2. Review all information
3. Click **Submit to App Review**

**Review Notes** (optional):
```
Test Account Credentials:
Username: reviewer@test.com
Password: ReviewPass123!

Testing Instructions:
1. Launch app and complete tutorial
2. Join Quick Match for multiplayer (test bots available if no players online)
3. Try hand gesture controls for weapon switching
4. Access Settings to test all features

Note: Full multiplayer experience requires 2+ Vision Pro devices. Bot matches available for single-player testing.
```

## TestFlight Beta Testing

### 1. Internal Testing

**Add Internal Testers**:
1. TestFlight → Internal Testing
2. Add users from your team (up to 100)
3. Select build
4. Testers receive email invitation

**Test Period**: Unlimited

### 2. External Testing

**Add External Testers**:
1. TestFlight → External Testing
2. Create new group
3. Add testers (up to 10,000)
4. Submit for Beta App Review (required for first build)

**Test Period**: 90 days per build

### 3. Collecting Feedback

**TestFlight Feedback**:
- Testers can submit feedback via TestFlight app
- Review: App Store Connect → TestFlight → Feedback

**Crash Reports**:
- Xcode → Organizer → Crashes
- App Store Connect → TestFlight → Crashes

## Release Management

### Version Workflow

**1.0.0** - Initial Release
**1.0.1** - Bug fix (maintain backwards compatibility)
**1.1.0** - New features (backwards compatible)
**2.0.0** - Major update (breaking changes)

### Phased Release

**Enable Phased Release**:
1. Version → Phased Release
2. Enable (releases to 1% day 1, increasing over 7 days)
3. Can pause at any time

**Benefits**:
- Monitor crash rates
- Gather initial feedback
- Pause if critical issues found

### Release Scheduling

**Immediate Release**:
- Available as soon as approved

**Scheduled Release**:
- Select specific date/time
- Coordinate with marketing campaigns

### Update Submission

For version updates:
1. Increment version number
2. Archive new build
3. Upload to App Store Connect
4. Create new version
5. Update "What's New"
6. Submit for review

## Post-Release

### 1. Monitor Performance

**App Analytics** (App Store Connect):
- Downloads and sales
- Sessions and active devices
- Crashes and errors
- Customer reviews and ratings

**Metrics Dashboard**:
```
Key Metrics:
- Daily Active Users (DAU)
- Monthly Active Users (MAU)
- Retention rate (Day 1, Day 7, Day 30)
- Average session duration
- Crash-free rate (target: >99%)
```

### 2. Respond to Reviews

**Monitor Reviews**:
- App Store Connect → Ratings and Reviews
- Respond to reviews (especially negative ones)
- Thank positive reviewers

**Response Time**: Within 24-48 hours

### 3. Crash Monitoring

**Xcode Organizer**:
- Crashes → Select version
- Analyze crash logs
- Prioritize fixes based on frequency

**Third-Party Tools** (optional):
- Firebase Crashlytics
- Sentry
- Bugsnag

### 4. Update Strategy

**Hotfix** (1.0.1):
- Critical bugs affecting users
- Release within 1-2 days

**Minor Update** (1.1.0):
- New features
- Performance improvements
- Release every 2-4 weeks

**Major Update** (2.0.0):
- Significant new features
- UI redesign
- Release every 3-6 months

## Troubleshooting

### Common Issues

**Issue**: "Invalid Bundle"
- **Cause**: Missing required icons or plist keys
- **Fix**: Validate all required assets, check Info.plist

**Issue**: "Invalid Provisioning Profile"
- **Cause**: Profile doesn't match bundle ID or expired
- **Fix**: Regenerate profile, ensure bundle ID matches exactly

**Issue**: "App is Not Eligible for Family Sharing"
- **Cause**: Using non-consumable in-app purchases
- **Fix**: Enable Family Sharing for in-app purchases

**Issue**: "Missing Compliance"
- **Cause**: Export compliance not completed
- **Fix**: Complete encryption export compliance documentation

**Issue**: "Processing Stuck"
- **Cause**: Server-side processing delay
- **Fix**: Wait up to 24 hours; contact Apple Developer Support if persists

### App Review Rejection

**Common Rejection Reasons**:

1. **Guideline 2.1 - App Completeness**
   - Incomplete features or placeholder content
   - Fix: Complete all features, remove placeholders

2. **Guideline 4.3 - Spam**
   - Too similar to existing apps
   - Fix: Highlight unique visionOS features

3. **Guideline 2.3.10 - Accurate Metadata**
   - Screenshots don't match actual app
   - Fix: Update screenshots to reflect current version

4. **Guideline 2.1 - Performance**
   - Crashes or bugs during review
   - Fix: Thorough testing, provide test account

**Appeal Process**:
1. Resolution Center → Appeal
2. Provide detailed explanation
3. Reference App Review Guidelines
4. Wait 1-3 days for response

### Support Resources

- **App Store Connect Help**: https://help.apple.com/app-store-connect/
- **Developer Forums**: https://developer.apple.com/forums/
- **Technical Support**: https://developer.apple.com/support/
- **App Review**: https://developer.apple.com/app-store/review/

## Automation Scripts

### Build and Upload Script

```bash
#!/bin/bash
# build_and_upload.sh

VERSION=$1
BUILD=$2

if [ -z "$VERSION" ] || [ -z "$BUILD" ]; then
    echo "Usage: ./build_and_upload.sh <version> <build>"
    exit 1
fi

# Update version numbers
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD" Info.plist

# Archive
xcodebuild archive \
    -scheme TacticalTeamShooters \
    -destination 'generic/platform=visionOS' \
    -archivePath ./build/TacticalTeamShooters.xcarchive

# Export
xcodebuild -exportArchive \
    -archivePath ./build/TacticalTeamShooters.xcarchive \
    -exportPath ./build/ \
    -exportOptionsPlist ExportOptions.plist

# Upload
xcrun altool --upload-app \
    --type visionos \
    --file ./build/TacticalTeamShooters.ipa \
    --apiKey YOUR_API_KEY \
    --apiIssuer YOUR_ISSUER_ID

echo "Build $VERSION ($BUILD) uploaded successfully!"
```

### Version Bump Script

```bash
#!/bin/bash
# bump_version.sh

# Read current version
CURRENT_VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" Info.plist)
CURRENT_BUILD=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" Info.plist)

# Increment build number
NEW_BUILD=$((CURRENT_BUILD + 1))

# Update
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $NEW_BUILD" Info.plist

echo "Version $CURRENT_VERSION, Build $CURRENT_BUILD → $NEW_BUILD"
```

## Checklist

### Pre-Submission

- [ ] All tests pass
- [ ] App tested on Vision Pro hardware
- [ ] Version and build numbers updated
- [ ] Code signing configured
- [ ] Archive created successfully
- [ ] Export for App Store completed

### App Store Connect

- [ ] App record created
- [ ] App information completed
- [ ] Pricing and availability set
- [ ] Privacy details submitted
- [ ] Version information written
- [ ] Screenshots uploaded (minimum 3)
- [ ] Build selected for release

### Submission

- [ ] Export compliance completed
- [ ] Content rights confirmed
- [ ] Test account provided (if needed)
- [ ] Review notes added
- [ ] Submitted for review

### Post-Submission

- [ ] Monitoring enabled
- [ ] Review response plan ready
- [ ] Crash monitoring configured
- [ ] Update strategy defined

---

**Good luck with your App Store submission!**

For additional support, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md) or contact Apple Developer Support.
