# Deployment Guide

Complete guide for deploying Retail Space Optimizer to TestFlight and the App Store.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Build Configuration](#build-configuration)
- [TestFlight Deployment](#testflight-deployment)
- [App Store Submission](#app-store-submission)
- [Release Process](#release-process)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Accounts

- **Apple Developer Account** ($99/year)
  - Enrolled in Apple Developer Program
  - visionOS development capabilities enabled

- **App Store Connect Access**
  - Admin or App Manager role
  - Access to Certificates, Identifiers & Profiles

### Development Environment

- macOS Sonoma 14.5+ (Apple Silicon recommended)
- Xcode 16.0+ with visionOS SDK 2.0+
- Valid development certificate
- Distribution certificate (for App Store)

### App Information

- **App Name**: Retail Space Optimizer
- **Bundle ID**: `com.retailspaceoptimizer.visionos`
- **SKU**: `RSO-VISIONOS-001`
- **Primary Category**: Business
- **Secondary Category**: Productivity

## Build Configuration

### 1. Update Version Numbers

In Xcode:
```
Target > General > Identity
Version: 1.0.0
Build: 1
```

Or via command line:
```bash
agvtool new-marketing-version 1.0.0
agvtool new-version -all 1
```

### 2. Build Settings

**Release Configuration:**
```
Build Settings > Build Configuration
- Optimization Level: -Os (Optimize for Size)
- Swift Compilation Mode: Whole Module Optimization
- Enable Bitcode: NO (visionOS doesn't support bitcode)
- Strip Debug Symbols: YES
- Make Strings Read-Only: YES
```

### 3. Signing Configuration

```
Target > Signing & Capabilities
- Automatically manage signing: ✓
- Team: [Your Team]
- Signing Certificate: Apple Distribution
- Provisioning Profile: App Store
```

### 4. Info.plist Configuration

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required for spatial scanning and AR features.</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>Location is used to identify store locations.</string>

<key>UIRequiredDeviceCapabilities</key>
<array>
    <string>arm64</string>
    <string>visionos</string>
</array>

<key>LSMinimumSystemVersion</key>
<string>2.0</string>
```

## TestFlight Deployment

### Step 1: Archive the Build

```bash
# Clean build folder
rm -rf ~/Library/Developer/Xcode/DerivedData

# Archive via Xcode
# Product > Archive

# Or via command line
xcodebuild archive \
  -scheme RetailSpaceOptimizer \
  -destination generic/platform=visionOS \
  -archivePath build/RetailSpaceOptimizer.xcarchive
```

### Step 2: Validate Archive

```bash
# Validate before upload
xcodebuild -exportArchive \
  -archivePath build/RetailSpaceOptimizer.xcarchive \
  -exportOptionsPlist ExportOptions.plist \
  -exportPath build/Validate \
  -allowProvisioningUpdates \
  -validateOnly
```

**ExportOptions.plist:**
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

### Step 3: Upload to App Store Connect

**Via Xcode Organizer:**
1. Window > Organizer
2. Select your archive
3. Click "Distribute App"
4. Select "App Store Connect"
5. Choose "Upload"
6. Select signing certificate
7. Review and upload

**Via Command Line:**
```bash
xcrun altool --upload-app \
  --type visionos \
  --file build/RetailSpaceOptimizer.ipa \
  --apiKey YOUR_API_KEY \
  --apiIssuer YOUR_ISSUER_ID
```

### Step 4: Configure TestFlight

**In App Store Connect:**

1. **Go to TestFlight tab**
2. **Add Internal Testers**
   - Add up to 100 internal testers
   - Internal testing available immediately after processing

3. **Configure Test Information**
   - What to Test: Describe new features
   - Test Details: Instructions for testers
   - App Clip: N/A

4. **Add External Testers** (optional)
   - Create a group (e.g., "Beta Testers")
   - Add up to 10,000 external testers
   - Requires beta app review (1-2 days)

### Step 5: Distribute to Testers

**Email invitation sent automatically:**
- Internal testers: Immediate access
- External testers: After beta review approval

**TestFlight Expiry:**
- Builds expire after 90 days
- Upload new builds to continue testing

## App Store Submission

### Step 1: Prepare App Store Connect

**App Information:**
```
Name: Retail Space Optimizer
Subtitle: Immersive Retail Planning
Category: Business
Secondary Category: Productivity
```

**Pricing and Availability:**
```
Price: Free (with in-app purchases)
Availability: All territories
Pre-order: No (for v1.0)
```

**App Privacy:**
- Data collection: Location, Usage Data
- Data usage: Analytics, Product Personalization
- Data linked to user: Email, Name, Store Data
- Tracking: No

### Step 2: Version Information

**Version 1.0:**
```
What's New:
• Immersive 3D store visualization
• Real-time customer analytics
• AI-powered layout optimization
• Multi-user collaboration
• A/B testing capabilities

Description:
[Copy from README.md Executive Summary]

Keywords:
retail, store planning, merchandising, analytics, 3D visualization, layout optimization

Support URL: https://support.retailspaceoptimizer.com
Marketing URL: https://retailspaceoptimizer.com
Privacy Policy URL: https://retailspaceoptimizer.com/privacy
```

### Step 3: App Review Information

```
Contact Information:
- First Name: [Your Name]
- Last Name: [Your Last Name]
- Phone: +1-XXX-XXX-XXXX
- Email: appstore@retailspaceoptimizer.com

Demo Account (for reviewers):
- Username: reviewer@retailspaceoptimizer.com
- Password: [Provide demo password]
- Instructions: "App starts with sample retail store data. Use main navigation to explore features."

Notes:
"This app is designed for Apple Vision Pro and requires visionOS 2.0+. Best experienced with the included sample store data."
```

### Step 4: Screenshots and Media

**Required visionOS Screenshots:**
- 3840 x 2160 pixels (at 1x scale)
- Minimum 3 screenshots required
- Maximum 10 screenshots

**Screenshot Checklist:**
1. Main store list view
2. 2D store editor with fixtures
3. 3D volumetric preview
4. Analytics dashboard with heat maps
5. Immersive space walkthrough

**App Preview Video** (optional but recommended):
- Duration: 15-30 seconds
- Resolution: 3840 x 2160
- Format: H.264 or HEVC
- Show key features in action

### Step 5: App Store Icon

```
Size: 1024 x 1024 pixels
Format: PNG (no alpha channel)
No rounded corners (Apple adds automatically)
```

### Step 6: Age Rating

```
Questionnaire Results:
- Cartoon or Fantasy Violence: None
- Realistic Violence: None
- Sexual Content or Nudity: None
- Profanity or Crude Humor: None
- Horror or Fear Themes: None
- Mature/Suggestive Themes: None
- Alcohol, Tobacco, or Drugs: None
- Gambling: None
- Medical/Treatment Information: None
- Unrestricted Web Access: No
- Gambling and Contests: No

Result: 4+ (Everyone)
```

### Step 7: Submit for Review

**Pre-Submission Checklist:**
- [ ] All required metadata filled
- [ ] Screenshots uploaded (minimum 3)
- [ ] App icon uploaded (1024x1024)
- [ ] Privacy policy URL working
- [ ] Support URL working
- [ ] Demo account credentials provided
- [ ] Export compliance information complete
- [ ] Content rights verified
- [ ] All tests passing
- [ ] No crashes in TestFlight

**Submit:**
1. Review all information
2. Click "Add for Review"
3. Answer export compliance questions
4. Click "Submit to App Review"

**Review Timeline:**
- Average: 24-48 hours
- Can be rejected and require resubmission
- Status updates via email and App Store Connect

## Release Process

### Pre-Release Checklist

**Code Quality:**
- [ ] All unit tests passing (60+)
- [ ] All integration tests passing
- [ ] Code coverage > 55%
- [ ] No compiler warnings
- [ ] No SwiftLint errors
- [ ] Performance benchmarks met (90 FPS, < 2GB memory)

**Testing:**
- [ ] TestFlight beta tested (10+ users, 7+ days)
- [ ] All critical bugs fixed
- [ ] UI/UX reviewed and approved
- [ ] Accessibility tested (VoiceOver, Dynamic Type)
- [ ] Tested on Vision Pro device
- [ ] Tested on visionOS Simulator

**Documentation:**
- [ ] README.md updated
- [ ] CHANGELOG.md updated
- [ ] User guide created
- [ ] API documentation current
- [ ] Release notes written

**Legal:**
- [ ] Privacy policy updated
- [ ] Terms of service updated
- [ ] License file included
- [ ] Third-party licenses included

### Release Steps

**1. Finalize Version**
```bash
# Update version
agvtool new-marketing-version 1.0.0

# Update CHANGELOG.md
# Update README.md
# Update version in documentation
```

**2. Create Release Branch**
```bash
git checkout -b release/1.0.0
git push origin release/1.0.0
```

**3. Build and Archive**
```bash
./scripts/build.sh --release
```

**4. Upload to App Store Connect**
```bash
# Via Xcode Organizer or command line
```

**5. Submit for Review**
- Complete App Store Connect metadata
- Submit to Apple

**6. Monitor Review Status**
- Check App Store Connect daily
- Respond to any review questions within 24 hours

**7. Release**
- After approval, release manually or automatically
- Monitor crash reports and user feedback

**8. Post-Release**
```bash
# Tag release
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# Merge to main
git checkout main
git merge release/1.0.0
git push origin main
```

### Hotfix Process

**For Critical Bugs:**
```bash
# Create hotfix branch
git checkout -b hotfix/1.0.1 v1.0.0

# Fix bug
# Update version to 1.0.1
# Test thoroughly

# Build and submit as expedited review
# Mention "critical bug fix" in review notes
```

## Continuous Deployment

### GitHub Actions Workflow

See `.github/workflows/deploy.yml` for automated deployment:

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
      - uses: actions/checkout@v4
      - name: Build and Upload
        run: ./scripts/deploy.sh
        env:
          APP_STORE_CONNECT_API_KEY: ${{ secrets.APP_STORE_CONNECT_API_KEY }}
```

## Troubleshooting

### Common Issues

**Build Failed: Code Signing**
```
Error: No signing certificate found
Solution: Verify certificate in Keychain Access, refresh Xcode preferences
```

**Upload Failed: Invalid Binary**
```
Error: Invalid visionOS binary
Solution: Ensure deployment target is visionOS 2.0+, rebuild clean
```

**Review Rejection: Crashes**
```
Reason: App crashes on launch
Solution: Test on actual device, check crash reports in Organizer
```

**Review Rejection: Missing Info.plist Keys**
```
Reason: Missing usage description
Solution: Add NSCameraUsageDescription and other required keys
```

**TestFlight Processing Stuck**
```
Issue: Build stuck in "Processing" status
Solution: Wait 24 hours, if still stuck contact Apple Support
```

### Getting Help

- **App Store Connect Support**: https://developer.apple.com/contact/
- **Developer Forums**: https://developer.apple.com/forums/
- **Phone Support**: Available with Apple Developer membership

## Monitoring

### Post-Release Monitoring

**Crash Reports:**
- Xcode > Window > Organizer > Crashes
- Monitor daily for first week
- Address crashes with > 1% occurrence rate

**User Feedback:**
- App Store Connect > App Store > Reviews
- Respond to reviews (especially negative ones)
- Track sentiment trends

**Analytics:**
- App Store Connect > Analytics
- Monitor downloads, sessions, crashes
- Track retention and engagement

### Performance Metrics

**Key Metrics to Track:**
- Downloads per day
- Crash-free session rate (target: > 99%)
- Average session duration
- Day 1/7/30 retention
- App Store rating (target: > 4.0)

## Support

- **Deployment Issues**: deploy@retailspaceoptimizer.com
- **App Review Questions**: appstore@retailspaceoptimizer.com
- **Documentation**: See TECHNICAL_README.md

---

**Last Updated**: 2025-11-19
**Document Version**: 1.0
