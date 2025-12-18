# Deployment Guide

This guide covers deploying Spatial Pictionary to TestFlight, the App Store, and managing releases.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Version Management](#version-management)
- [Build Configuration](#build-configuration)
- [Code Signing](#code-signing)
- [TestFlight Deployment](#testflight-deployment)
- [App Store Submission](#app-store-submission)
- [Release Process](#release-process)
- [Post-Release](#post-release)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required

- **Apple Developer Program** membership ($99/year)
- **Xcode** 16.0 or later
- **macOS** 14.0 or later
- **App Store Connect** access
- **Completed app** ready for release

### Recommended

- **TestFlight** for beta testing
- **App Store Screenshots** (multiple sizes)
- **App Preview Videos** (optional but recommended)
- **Marketing materials** prepared

---

## Version Management

### Semantic Versioning

We follow [Semantic Versioning](https://semver.org/): `MAJOR.MINOR.PATCH`

- **MAJOR**: Incompatible API changes
- **MINOR**: New functionality (backwards-compatible)
- **PATCH**: Bug fixes (backwards-compatible)

Examples:
- `1.0.0` - Initial release
- `1.1.0` - New features added
- `1.1.1` - Bug fixes
- `2.0.0` - Breaking changes

### Update Version Numbers

**In Xcode:**
1. Select project in navigator
2. Select "SpatialPictionary" target
3. Go to "General" tab
4. Update version fields:
   - **Version**: `1.0.0` (user-facing version)
   - **Build**: `1` (increment for each submission)

**Via Command Line:**
```bash
# Set version
xcrun agvtool new-marketing-version 1.0.0

# Increment build number
xcrun agvtool next-version -all
```

### Update CHANGELOG

Before each release, update [CHANGELOG.md](CHANGELOG.md):

```markdown
## [1.0.0] - 2025-01-15

### Added
- Initial public release
- 3D drawing with hand tracking
- Multiplayer support (2-12 players)
- 1000+ word categories

### Fixed
- Performance improvements for 90 FPS
```

---

## Build Configuration

### Release Build Settings

1. **Select Release configuration:**
   - Product → Scheme → Edit Scheme
   - Select "Archive" in sidebar
   - Build Configuration → "Release"

2. **Optimization Settings:**
   - Optimization Level: `-O` (Optimize for Speed)
   - Swift Optimization Level: `-O`
   - Strip Debug Symbols: Yes
   - Enable Bitcode: No (not available for visionOS)

3. **Deployment Target:**
   - Minimum deployment: visionOS 2.0

### Build Flags

```swift
// Use build flags for environment-specific code
#if DEBUG
    print("Debug mode")
#else
    // Production code
#endif
```

### Configuration Files

Create separate configurations if needed:
- `Debug.xcconfig`
- `Release.xcconfig`
- `Beta.xcconfig`

---

## Code Signing

### Certificates

Required certificates from Apple Developer portal:

1. **Development Certificate**
   - For simulator and device testing
   - Valid for 1 year

2. **Distribution Certificate**
   - For App Store submission
   - Valid for 1 year

### Provisioning Profiles

1. **Development Profile**
   - For testing on devices
   - Includes specific device UDIDs

2. **App Store Profile**
   - For App Store distribution
   - No device restrictions

### Automatic Signing (Recommended)

In Xcode:
1. Select target → Signing & Capabilities
2. Check "Automatically manage signing"
3. Select your team
4. Xcode handles the rest

### Manual Signing

For more control:
1. Create certificates in [Apple Developer portal](https://developer.apple.com)
2. Download and install certificates
3. Create provisioning profiles
4. In Xcode, uncheck "Automatically manage signing"
5. Select profiles manually

---

## TestFlight Deployment

TestFlight allows beta testing before public release.

### Step 1: Create App in App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Click "My Apps" → "+" → "New App"
3. Fill in details:
   - **Platform**: visionOS
   - **Name**: Spatial Pictionary
   - **Primary Language**: English
   - **Bundle ID**: Select from dropdown
   - **SKU**: Unique identifier (e.g., `spatial-pictionary-001`)
   - **User Access**: Full Access

### Step 2: Archive the App

1. **Clean build folder:**
   ```
   Cmd+Shift+K
   ```

2. **Archive:**
   - Select "Any visionOS Device" as destination
   - Product → Archive
   - Wait for archive to complete

3. **Organizer opens automatically**
   - Shows your archive
   - Click "Distribute App"

### Step 3: Upload to App Store Connect

1. In Organizer, click "Distribute App"
2. Select "App Store Connect"
3. Click "Upload"
4. Select signing options:
   - Use automatically manage signing (recommended)
5. Review app information
6. Click "Upload"

**Upload Time**: 5-30 minutes depending on size

### Step 4: Configure TestFlight

1. Go to App Store Connect
2. Select your app → TestFlight tab
3. Wait for build to process (10-60 minutes)
4. Add build to test group:
   - Internal Testing (up to 100 testers)
   - External Testing (up to 10,000 testers)

### Step 5: Invite Testers

**Internal Testers:**
- Must be part of your organization in App Store Connect
- No review required
- Instant access

**External Testers:**
- Add via email
- Requires beta review (1-2 days)
- Can be public link or specific invites

### Step 6: Provide Test Information

Required for external testing:
- **Beta App Description**: What testers should know
- **Feedback Email**: Where testers can reach you
- **Marketing URL**: Optional
- **Privacy Policy URL**: Required if app collects data
- **Test Information**: Login credentials if needed

### TestFlight Submission

1. Select build
2. Add to external testing group
3. Fill in test information
4. Submit for beta review
5. Wait for approval (typically 24-48 hours)

---

## App Store Submission

### Step 1: Prepare App Information

In App Store Connect:

**App Information:**
- Name: Spatial Pictionary
- Subtitle: Draw in the Air, Guess in 3D
- Privacy Policy URL: Required
- Category: Games → Word
- Secondary Category: Games → Family

**Pricing and Availability:**
- Price: $24.99 (Party Game) or Free with IAP
- Availability: All countries or specific regions
- Release date: Manual or automatic

### Step 2: Prepare Screenshots

Required screenshot sizes for visionOS:
- **6.5" Display**: 2532 x 1170 pixels (minimum 1-10 images)

**Screenshot Tips:**
- Show key features
- Use captions
- Demonstrate 3D drawing
- Show multiplayer
- Highlight unique features

**Take screenshots:**
```bash
# In simulator: Cmd+S
# On device: Volume Up + Power button
```

### Step 3: App Preview Video (Optional)

**Specifications:**
- Resolution: 1920 x 1080 (16:9) or device resolution
- Duration: 15-30 seconds
- Format: M4V, MP4, or MOV
- File size: Up to 500 MB

**Content:**
- Show gameplay
- Demonstrate 3D drawing
- Show multiplayer interaction
- Keep it exciting

### Step 4: Write App Description

**App Description Template:**
```
Draw in the air, guess in three dimensions!

Spatial Pictionary revolutionizes the classic party game with true 3D drawing
in mid-air using Apple Vision Pro. Create artwork using natural hand gestures
while friends guess from any angle.

KEY FEATURES:
• True 3D Drawing - Sculpt in mid-air with precision hand tracking
• Multiplayer Fun - 2-12 players locally or via SharePlay
• 1000+ Words - Across 14 categories and 3 difficulty levels
• AI-Powered - Dynamic difficulty adjustment
• Rich Tools - 5 material types, unlimited colors
• Educational - Perfect for vocabulary building

GAMEPLAY:
One player draws a word in 3D space while others guess. Walk around the
creation to see it from all angles. First to guess wins points!

PERFECT FOR:
• Family game nights
• Virtual hangouts with friends
• Educational environments
• Party entertainment
• Creative expression

Requires Apple Vision Pro with visionOS 2.0 or later.

Privacy Policy: [URL]
Support: [Email]
```

**Character limits:**
- Description: 4,000 characters
- Promotional text: 170 characters
- Keywords: 100 characters

### Step 5: Set Keywords

Choose relevant keywords (max 100 characters):
```
pictionary,drawing,3d,spatial,party,game,multiplayer,guess,family,fun,art,creative
```

**Keyword Tips:**
- Use relevant terms
- Avoid repetition
- Don't use "Apple" or app name
- Think about search terms

### Step 6: Set Age Rating

Use questionnaire in App Store Connect:
- **Rating**: 4+ (no objectionable content)
- Questions about:
  - Violence
  - Sexual content
  - Profanity
  - Horror
  - Mature themes
  - Gambling
  - Contests

### Step 7: Submit for Review

1. **Complete all required fields**
2. **Add build** (from TestFlight)
3. **Review information**:
   - Demo account (if login required)
   - Review notes
   - Contact information
4. **Submit for review**

**Review Time**: Typically 24-48 hours

### Step 8: App Review Process

**Statuses:**
- **Waiting for Review**: In queue
- **In Review**: Being reviewed by Apple
- **Pending Developer Release**: Approved, waiting for you to release
- **Ready for Sale**: Live on App Store
- **Rejected**: Needs changes

**Common Rejection Reasons:**
- Crashes or bugs
- Incomplete information
- Privacy policy issues
- Guideline violations
- Misleading screenshots

---

## Release Process

### Pre-Release Checklist

- [ ] Version number updated
- [ ] Build number incremented
- [ ] CHANGELOG.md updated
- [ ] All tests passing
- [ ] TestFlight beta testing completed
- [ ] Critical bugs fixed
- [ ] Performance benchmarks met (90 FPS)
- [ ] Accessibility tested
- [ ] Privacy policy updated
- [ ] Marketing materials prepared
- [ ] App Store screenshots ready
- [ ] App description written
- [ ] Support email configured
- [ ] Release notes written

### Release Notes Template

```markdown
What's New in Version 1.0.0

🎨 NEW FEATURES
• True 3D drawing with hand tracking
• Multiplayer support for up to 12 players
• 1000+ words across 14 categories
• SharePlay integration for remote play

🐛 BUG FIXES
• Improved drawing precision
• Enhanced multiplayer stability
• Fixed sync issues

⚡ IMPROVEMENTS
• Optimized for 90 FPS
• Reduced latency
• Enhanced accessibility
```

### Phased Release (Recommended)

**What is Phased Release?**
- Gradual rollout to users over 7 days
- Allows monitoring for critical issues
- Can pause if problems found

**Enable Phased Release:**
1. App Store Connect → Version → Phased Release
2. Toggle on
3. Release updates gradually

**Rollout Schedule:**
- Day 1: 1% of users
- Day 2: 2%
- Day 3: 5%
- Day 4: 10%
- Day 5: 20%
- Day 6: 50%
- Day 7: 100%

### Manual Release

If approved with "Pending Developer Release":
1. Go to App Store Connect
2. Select your app version
3. Click "Release This Version"
4. Confirm

---

## Post-Release

### Monitoring

**App Analytics:**
- App Store Connect → Analytics
- Monitor:
  - Downloads
  - Crashes
  - Usage
  - Retention

**Crash Reports:**
- Xcode → Window → Organizer → Crashes
- Review crash logs
- Fix critical issues

**User Reviews:**
- Monitor App Store reviews
- Respond to feedback
- Identify common issues

### Responding to Reviews

**Best Practices:**
- Respond within 24-48 hours
- Be professional and courteous
- Thank users for feedback
- Address specific concerns
- Invite bug reports via email

**Template:**
```
Thank you for your feedback! We're glad you're enjoying Spatial Pictionary.
We're constantly working to improve the experience. If you have specific
suggestions, please email us at support@spatialpictionary.com.
```

### Hotfix Process

For critical bugs post-release:

1. **Assess severity**
   - Crashes → Immediate hotfix
   - Major bugs → Fast-track fix
   - Minor issues → Include in next update

2. **Fix the bug**
   ```bash
   git checkout -b hotfix/critical-bug
   # Make fix
   git commit -m "fix: resolve critical crash on game start"
   ```

3. **Test thoroughly**
   - Verify fix works
   - Ensure no regressions
   - Test on multiple devices

4. **Increment version**
   - Version: 1.0.0 → 1.0.1
   - Build: Increment

5. **Fast-track release**
   - Upload to App Store Connect
   - Request expedited review (if critical)
   - Include detailed explanation

**Expedited Review:**
- Available for critical bugs
- Explain impact in review notes
- Usually reviewed within hours

---

## Troubleshooting

### Archive Validation Errors

**"Invalid Bundle"**
- Check bundle identifier matches App Store Connect
- Verify Info.plist is complete
- Ensure all required icons are included

**"Missing Compliance"**
- Add export compliance in Info.plist if using encryption
- Answer encryption questions in App Store Connect

**"Invalid Signature"**
- Verify code signing certificate is valid
- Check provisioning profile is correct
- Clean build and try again

### Upload Failures

**"Upload failed"**
- Check internet connection
- Try uploading via Application Loader
- Verify build is properly signed

**"Invalid Toolchain"**
- Update to latest Xcode
- Use Xcode 16.0+ for visionOS

### Review Rejections

**Guideline 2.1 - Performance**
- App crashes: Fix bugs, test thoroughly
- Incomplete features: Finish or remove
- Placeholder content: Replace with final content

**Guideline 4.3 - Spam**
- App is too similar to others: Emphasize unique features
- Minimal functionality: Add more features

**Guideline 5.1.1 - Privacy**
- Missing privacy policy: Add and link
- Improper data collection: Review and fix

---

## Continuous Delivery

### Automation with Fastlane

Consider using [Fastlane](https://fastlane.tools) for automated deployment:

```ruby
# Fastfile
lane :beta do
  increment_build_number
  build_app(scheme: "SpatialPictionary")
  upload_to_testflight
end

lane :release do
  increment_build_number
  build_app(scheme: "SpatialPictionary")
  upload_to_app_store
end
```

### CI/CD Integration

Use GitHub Actions for automated builds:

```yaml
# .github/workflows/deploy.yml
name: Deploy to TestFlight

on:
  push:
    tags:
      - 'v*'

jobs:
  deploy:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build and upload to TestFlight
        run: fastlane beta
```

---

## Resources

- [App Store Connect](https://appstoreconnect.apple.com)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [TestFlight Documentation](https://developer.apple.com/testflight/)

---

## Support

For deployment questions:
- Check [FAQ.md](FAQ.md)
- Ask in [GitHub Discussions](https://github.com/akaash-nigam/visionOS_Gaming_spatial-pictionary/discussions)
- Contact Apple Developer Support

---

## Summary

Deployment checklist:
1. ✅ Complete app development
2. ✅ Test thoroughly via TestFlight
3. ✅ Prepare marketing materials
4. ✅ Submit to App Store
5. ✅ Monitor and respond to feedback
6. ✅ Plan regular updates

Good luck with your release! 🚀
