# Deployment Guide

This guide covers building, testing, and deploying Parkour Pathways to TestFlight and the App Store.

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Build Configuration](#build-configuration)
- [Local Testing](#local-testing)
- [TestFlight Deployment](#testflight-deployment)
- [App Store Deployment](#app-store-deployment)
- [CI/CD Pipeline](#cicd-pipeline)
- [Post-Deployment](#post-deployment)
- [Troubleshooting](#troubleshooting)

## 🔑 Prerequisites

### Required

- **macOS 14.0+** (Sonoma or later)
- **Xcode 16.0+** with visionOS SDK installed
- **Apple Developer Account** (paid membership required)
- **App Store Connect** access
- **Valid certificates and provisioning profiles**
- **Vision Pro device** (for final testing)

### Recommended

- **Fastlane** (for automation)
- **Xcode Cloud** or CI/CD service
- **TestFlight External Testers** group configured
- **App Analytics** enabled

## 🏗️ Build Configuration

### 1. Update Version Numbers

Before each release, update version numbers in `Package.swift`:

```swift
// Package.swift
let package = Package(
    name: "ParkourPathways",
    platforms: [.visionOS(.v2)],
    products: [
        .library(
            name: "ParkourPathways",
            targets: ["ParkourPathways"]
        )
    ],
    // ... rest of configuration
)
```

Also update your app target's version and build number in Xcode:

1. Select **ParkourPathways** target
2. Go to **General** tab
3. Update **Version** (e.g., `1.0.0`)
4. Update **Build** (e.g., `1` or use auto-increment)

### 2. Build Configurations

We use three build configurations:

#### Debug
- For development
- Includes debug symbols
- Performance profiling enabled
- Analytics disabled

```swift
#if DEBUG
let analyticsEnabled = false
let debugMenuEnabled = true
#endif
```

#### Release
- For TestFlight and App Store
- Optimizations enabled
- Debug symbols stripped
- Analytics enabled

```swift
#if RELEASE
let analyticsEnabled = true
let debugMenuEnabled = false
#endif
```

#### Beta (TestFlight)
- Hybrid configuration
- Crash reporting enabled
- Beta feedback integration
- TestFlight-specific features

### 3. Code Signing

#### Automatic Signing (Recommended)

1. Select **ParkourPathways** target
2. Go to **Signing & Capabilities**
3. Enable **Automatically manage signing**
4. Select your **Team**
5. Xcode will handle certificates and profiles

#### Manual Signing

For advanced scenarios:

1. Create distribution certificate in Apple Developer Portal
2. Create App Store distribution provisioning profile
3. Download and install both
4. In Xcode:
   - Disable automatic signing
   - Select certificate and profile manually

### 4. Entitlements

Required entitlements for Parkour Pathways:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- ARKit for spatial mapping -->
    <key>com.apple.developer.arkit</key>
    <true/>

    <!-- CloudKit for leaderboards -->
    <key>com.apple.developer.icloud-container-identifiers</key>
    <array>
        <string>iCloud.com.parkourpathways.app</string>
    </array>

    <!-- GroupActivities for SharePlay -->
    <key>com.apple.developer.group-activities</key>
    <true/>

    <!-- Spatial computing -->
    <key>com.apple.developer.scene-understanding</key>
    <true/>
</dict>
</plist>
```

## 🧪 Local Testing

### Pre-Deployment Checklist

Before building for distribution, ensure:

```bash
# 1. Clean build folder
⌘ + Shift + K

# 2. Run all tests
⌘ + U
# Or via command line:
swift test

# 3. Run SwiftLint
swiftlint

# 4. Build for release
# Select: Any visionOS Device (arm64)
⌘ + B

# 5. Profile performance
⌘ + I
# Choose: Time Profiler, Allocations, Leaks

# 6. Test on actual hardware
# Connect Vision Pro and run: ⌘ + R
```

### Testing on Simulator

```bash
# Select visionOS Simulator
# Run the app: ⌘ + R

# Test key flows:
# - Room scanning (simulated)
# - Course generation
# - Movement mechanics
# - UI navigation
# - Settings and preferences
```

**Note**: Some features won't work in simulator:
- ARKit spatial mapping
- Hand tracking
- True performance metrics
- Hardware-specific optimizations

### Testing on Device

1. **Connect Vision Pro**:
   - Via USB-C cable (first time)
   - Or via Wi-Fi (after pairing)

2. **Install build**:
   ```bash
   # In Xcode, select your Vision Pro device
   # Press ⌘ + R
   ```

3. **Test critical paths**:
   - Complete room scan
   - Play through full course
   - Test multiplayer (SharePlay)
   - Check performance (90 FPS)
   - Verify spatial audio
   - Test safety boundaries
   - Check memory usage

4. **Performance validation**:
   ```bash
   # In Xcode: ⌘ + I (Instruments)
   # Choose profiles:
   # - Time Profiler: Ensure 90 FPS
   # - Allocations: Check memory < 2 GB
   # - Energy Log: Validate battery impact
   ```

## 🚀 TestFlight Deployment

### 1. Prepare for TestFlight

#### Create Archive

```bash
# In Xcode:
# 1. Select: Any visionOS Device (arm64)
# 2. Product → Archive (⌘ + Shift + I)
# 3. Wait for archive to complete
```

Or use command line:

```bash
xcodebuild archive \
  -scheme ParkourPathways \
  -sdk visionos \
  -configuration Release \
  -archivePath build/ParkourPathways.xcarchive
```

#### Export for App Store

1. **In Xcode Organizer**:
   - Window → Organizer (⌘ + Shift + O)
   - Select latest archive
   - Click **Distribute App**

2. **Choose distribution method**:
   - Select **App Store Connect**
   - Click **Next**

3. **Select export options**:
   - **Upload**: Direct to App Store Connect
   - **Export**: Save IPA locally
   - Choose **Upload** for TestFlight

4. **Configure export options**:
   - ✅ Include bitcode: No (not needed for visionOS)
   - ✅ Upload symbols: Yes (for crash reports)
   - ✅ Manage version: Automatically
   - Click **Next**

5. **Review and upload**:
   - Review summary
   - Click **Upload**
   - Wait for upload to complete (~5-15 minutes)

### 2. Configure TestFlight

#### In App Store Connect

1. **Navigate to TestFlight**:
   ```
   App Store Connect → Apps → Parkour Pathways → TestFlight
   ```

2. **Wait for processing**:
   - Build processing: ~10-30 minutes
   - Export compliance: Respond to encryption question
   - Status changes to: **Ready to Submit**

3. **Add Beta Information**:
   - **What to Test**: Describe new features/changes
   - **Feedback Email**: support@parkourpathways.app
   - **Marketing URL**: https://parkourpathways.app

#### Create Test Groups

**Internal Testers** (Team members):
```
TestFlight → Internal Testing → Add Internal Testers
- Add up to 100 internal testers
- Builds automatically distributed
- No App Review required
```

**External Testers** (Beta users):
```
TestFlight → External Testing → Create New Group
- Group Name: "Beta Testers"
- Add up to 10,000 external testers
- Requires Beta App Review (24-48 hours)
```

### 3. Submit for Beta Review

1. **Select build**: Choose latest build
2. **Add test information**:
   - **Beta App Description**: Clear description
   - **Feedback Email**: support@parkourpathways.app
   - **Test Details**: What testers should focus on
3. **Submit for review**: Click **Submit**
4. **Wait for approval**: Usually 24-48 hours

### 4. Invite Testers

After approval:

```bash
# Via email
TestFlight → External Testing → Testers → Add Testers
Enter email addresses → Send Invites

# Via public link
TestFlight → External Testing → Public Link
Enable Public Link → Copy Link → Share
```

Testers will:
1. Receive email invitation
2. Install TestFlight app from App Store
3. Accept invitation
4. Download Parkour Pathways beta
5. Provide feedback via TestFlight app

### 5. Monitor Beta Feedback

```
TestFlight → Feedback
- View crash reports
- Read tester feedback
- Track adoption rates
- Monitor session statistics
```

## 🏪 App Store Deployment

### 1. Prepare App Store Listing

#### App Information

```
App Store Connect → Apps → Parkour Pathways → App Information

Name: Parkour Pathways
Subtitle: Your Room. Your Playground.
Category: Games - Sports
Content Rights: Own or licensed all rights

Age Rating:
- Unrestricted Web Access: No
- Simulated Gambling: No
- Realistic Violence: No
Recommended: 12+
```

#### App Store Assets

**App Icon** (Required):
- 1024 × 1024 px (no transparency, no rounded corners)

**Screenshots** (Required):
- visionOS: Minimum 3, maximum 10
- Recommended size: 3840 × 2160 px
- Show key features: room scanning, gameplay, multiplayer

**App Preview Videos** (Optional but recommended):
- Maximum 3 videos
- Duration: 15-30 seconds
- Show: room scanning → course generation → gameplay

**Marketing Assets**:
```
Screenshots needed:
1. Hero shot: Player in parkour action
2. Room scanning: Spatial mapping visualization
3. Course view: AI-generated course layout
4. Multiplayer: SharePlay session
5. Leaderboard: Social features
6. Settings: Accessibility options
```

#### App Description

**Promotional Text** (170 characters):
```
Transform any room into an immersive parkour playground.
AI-powered courses, multiplayer racing, and comprehensive
safety features. Your space. Your challenge.
```

**Description** (4,000 characters max):
```markdown
TRANSFORM YOUR SPACE INTO A PARKOUR PLAYGROUND

Parkour Pathways is the ultimate spatial parkour game built
exclusively for Apple Vision Pro. Using advanced AI and ARKit
technology, it transforms any room into a personalized parkour
playground with dynamic courses that adapt to your space, skill
level, and playing style.

KEY FEATURES

🤖 AI-POWERED COURSE GENERATION
Infinite unique courses tailored to your room. Our advanced AI
analyzes your space and creates challenging parkour sequences
that fit perfectly within your environment.

🏃 REALISTIC MOVEMENT PHYSICS
Experience precision jumps, dynamic vaults, wall runs, and
balance challenges with physics-based mechanics that feel
natural and responsive.

🔒 SAFETY FIRST
Advanced boundary detection and real-time safety monitoring
ensure you stay within safe zones while maintaining immersion.

🎵 IMMERSIVE AUDIO
3D spatial audio with room acoustics and haptic feedback make
every jump, landing, and movement feel real.

👥 MULTIPLAYER
Challenge friends with SharePlay support, race against ghost
recordings, and compete on global leaderboards.

📊 TRACK YOUR PROGRESS
Comprehensive performance tracking, fitness metrics, and
achievement system keep you motivated.

♿ ACCESSIBILITY
Full VoiceOver support, color blind modes, and assistive
difficulty settings ensure everyone can play.

REQUIREMENTS
- Apple Vision Pro
- visionOS 2.0 or later
- Minimum 2m × 2m (6.5ft × 6.5ft) play area
- Internet connection for multiplayer (optional)

Join thousands of players transforming their spaces into
parkour playgrounds. Download now and start your journey!
```

**Keywords** (100 characters):
```
parkour, visionOS, spatial, AR, fitness, multiplayer, game,
racing, training, obstacle
```

**Support URL**: `https://parkourpathways.app/support`
**Marketing URL**: `https://parkourpathways.app`
**Privacy Policy URL**: `https://parkourpathways.app/privacy`

### 2. Pricing and Availability

```
App Store Connect → Pricing and Availability

Price: $9.99 USD (or your chosen price tier)
Availability: All territories
Pre-order: Optional (for launch hype)

In-App Purchases:
- Pro Subscription: $4.99/month or $39.99/year
- Premium Courses Pack: $2.99
- Custom Theme Pack: $1.99
```

### 3. Submit for App Review

#### Pre-Submission Checklist

- [ ] All screenshots uploaded (minimum 3)
- [ ] App icon uploaded (1024×1024)
- [ ] Description complete and proofread
- [ ] Keywords optimized
- [ ] Support URL active and responsive
- [ ] Privacy policy URL active
- [ ] Age rating completed
- [ ] Contact information current
- [ ] Export compliance answered
- [ ] Build selected for release

#### Submit Build

1. **Select build for release**:
   ```
   App Store Connect → Prepare for Submission
   Build → Select latest build from TestFlight
   ```

2. **Version information**:
   ```
   Version: 1.0.0
   Copyright: © 2024 Parkour Pathways
   ```

3. **App Review Information**:
   ```
   First Name: [Your name]
   Last Name: [Your name]
   Phone: [Support phone]
   Email: support@parkourpathways.app

   Demo Account (if needed):
   Username: demo@parkourpathways.app
   Password: [Demo password]

   Notes:
   "Please test room scanning and course generation features.
   A minimum 2m × 2m space is required for optimal experience.
   SharePlay multiplayer requires two Vision Pro devices."
   ```

4. **Version Release**:
   - **Automatically release**: Immediately after approval
   - **Manually release**: Hold for manual release
   - **Scheduled release**: Release on specific date

5. **Submit for review**:
   - Review all information
   - Click **Submit for Review**
   - Status changes to: **Waiting for Review**

### 4. Review Process

**Timeline**:
- **In Review**: 24-72 hours typically
- **Status updates**: Monitor via App Store Connect or email
- **Rejections**: Address issues and resubmit

**Common rejection reasons**:
- Performance issues (< 90 FPS on Vision Pro)
- Crashes or bugs
- Incomplete features
- Privacy violations
- Guideline violations

**If rejected**:
1. Read rejection notice carefully
2. Fix all mentioned issues
3. Update build and re-upload to TestFlight
4. Select new build in App Store Connect
5. Address rejection in "Notes" section
6. Resubmit for review

### 5. Release

When approved:

**Status: Ready for Sale**

Monitor:
```
App Store Connect → App Analytics
- Downloads
- Impressions
- Conversion rate
- Crashes
- Ratings & reviews
```

Respond to reviews:
```
App Store Connect → Ratings and Reviews
- Thank positive reviews
- Address negative feedback professionally
- Fix reported bugs in updates
```

## 🤖 CI/CD Pipeline

### GitHub Actions (Recommended)

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to TestFlight

on:
  push:
    tags:
      - 'v*'

jobs:
  deploy:
    runs-on: macos-14

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_16.0.app

      - name: Install dependencies
        run: |
          brew install swiftlint

      - name: Lint
        run: swiftlint

      - name: Run tests
        run: swift test

      - name: Build archive
        run: |
          xcodebuild archive \
            -scheme ParkourPathways \
            -sdk visionos \
            -configuration Release \
            -archivePath build/ParkourPathways.xcarchive

      - name: Export IPA
        run: |
          xcodebuild -exportArchive \
            -archivePath build/ParkourPathways.xcarchive \
            -exportPath build \
            -exportOptionsPlist ExportOptions.plist

      - name: Upload to TestFlight
        env:
          APP_STORE_CONNECT_API_KEY: ${{ secrets.APP_STORE_CONNECT_API_KEY }}
        run: |
          xcrun altool --upload-app \
            --type visionos \
            --file build/ParkourPathways.ipa \
            --apiKey $APP_STORE_CONNECT_API_KEY
```

### Fastlane (Alternative)

Install Fastlane:

```bash
# Install
sudo gem install fastlane

# Initialize
cd ParkourPathways
fastlane init
```

Create `Fastfile`:

```ruby
default_platform(:visionos)

platform :visionos do
  desc "Run tests"
  lane :test do
    run_tests(scheme: "ParkourPathways")
  end

  desc "Deploy to TestFlight"
  lane :beta do
    increment_build_number
    build_app(
      scheme: "ParkourPathways",
      configuration: "Release"
    )
    upload_to_testflight(
      skip_waiting_for_build_processing: true
    )
  end

  desc "Deploy to App Store"
  lane :release do
    build_app(
      scheme: "ParkourPathways",
      configuration: "Release"
    )
    upload_to_app_store(
      submit_for_review: true,
      automatic_release: true
    )
  end
end
```

Run deployment:

```bash
# Deploy to TestFlight
fastlane beta

# Deploy to App Store
fastlane release
```

## 📊 Post-Deployment

### Monitor Performance

**App Store Connect Analytics**:
```
- Impressions: Track visibility
- Conversions: Monitor download rate
- Retention: Day 1, 7, 30 retention
- Crashes: Monitor crash-free sessions
```

**Custom Analytics** (via AnalyticsManager):
```swift
// Track key metrics
- Daily active users (DAU)
- Session length
- Course completion rate
- Multiplayer engagement
- In-app purchase conversion
```

### User Feedback

**Respond to reviews**:
- Thank users for positive feedback
- Address concerns professionally
- Fix reported bugs promptly
- Update app based on feedback

**Track feedback channels**:
- App Store reviews
- TestFlight feedback
- Support email
- Social media
- Discord community

### Update Strategy

**Patch updates (1.0.x)**:
- Critical bug fixes
- Performance improvements
- Release: Within 24-48 hours

**Minor updates (1.x.0)**:
- New features
- UI improvements
- Additional content
- Release: Every 2-4 weeks

**Major updates (x.0.0)**:
- Major new features
- Architectural changes
- Breaking changes
- Release: Every 3-6 months

### Marketing Post-Launch

**Launch week**:
- [ ] Press release distribution
- [ ] Social media campaign
- [ ] App Store featuring request
- [ ] Influencer outreach
- [ ] Community engagement

**Ongoing**:
- [ ] Regular content updates
- [ ] Social media presence
- [ ] Community events
- [ ] Seasonal promotions
- [ ] Feature updates

## 🐛 Troubleshooting

### Build Issues

**"No such module 'RealityKit'"**:
```bash
# Ensure visionOS SDK is installed
# Xcode → Settings → Platforms → Download visionOS
# Clean build: ⌘ + Shift + K
```

**"Code signing failed"**:
```bash
# Check Developer Account status
# Verify certificate is valid
# Regenerate provisioning profile
# Clean derived data:
rm -rf ~/Library/Developer/Xcode/DerivedData
```

### Upload Issues

**"Invalid binary"**:
- Ensure you selected "Any visionOS Device (arm64)"
- Check minimum deployment target is visionOS 2.0
- Verify all entitlements are properly configured

**"Processing timeout"**:
- Wait 24 hours for processing to complete
- Check App Store Connect status page
- Contact Apple Developer Support if persists

### Review Rejections

**Performance Issues**:
```bash
# Profile with Instruments
# Optimize render pipeline
# Reduce memory usage
# Target 90 FPS consistently
```

**Crashes**:
```bash
# Review crash logs in Xcode Organizer
# Fix all reproducible crashes
# Add error handling for edge cases
# Test on actual hardware extensively
```

**Guideline Violations**:
- Review App Store Review Guidelines
- Address specific violation mentioned
- Add explanation in review notes
- Resubmit promptly

## 📞 Support

**Apple Developer Support**:
- https://developer.apple.com/support/
- Phone: 1-800-633-2152

**App Store Connect**:
- https://appstoreconnect.apple.com

**Xcode Cloud**:
- https://developer.apple.com/xcode-cloud/

**Documentation**:
- [App Distribution Guide](https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases)
- [TestFlight Guide](https://developer.apple.com/testflight/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

---

**Ready to deploy? Start with TestFlight beta and gather feedback before App Store release!** 🚀
