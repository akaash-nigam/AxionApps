# Deployment Guide - AI Agent Coordinator

## Document Information
- **Version**: 1.0.0
- **Last Updated**: 2025-01-20
- **Platform**: Apple Vision Pro (visionOS 2.0+)

---

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Build Configuration](#build-configuration)
4. [Code Signing & Provisioning](#code-signing--provisioning)
5. [App Store Submission](#app-store-submission)
6. [TestFlight Distribution](#testflight-distribution)
7. [Enterprise Distribution](#enterprise-distribution)
8. [Post-Deployment](#post-deployment)
9. [Rollback Procedures](#rollback-procedures)
10. [Monitoring & Analytics](#monitoring--analytics)

---

## Overview

This guide covers the complete deployment process for AI Agent Coordinator to Apple Vision Pro devices, including:
- Production builds for App Store
- TestFlight beta testing
- Enterprise/internal distribution
- Version management and rollback

### Deployment Targets

| Environment | Purpose | Distribution |
|-------------|---------|--------------|
| Development | Internal testing | Direct device install |
| TestFlight | Beta testing | TestFlight |
| Production | Public release | App Store |
| Enterprise | Corporate deployment | MDM/Enterprise |

---

## Prerequisites

### Required Tools

1. **Development Machine**
   - macOS 14.0 (Sonoma) or later
   - Xcode 16.0 or later with visionOS SDK
   - Command Line Tools installed
   - At least 50GB free disk space

2. **Apple Developer Account**
   - Active Apple Developer Program membership ($99/year)
   - App Store Connect access
   - Code signing certificates
   - Provisioning profiles

3. **Vision Pro Device** (for testing)
   - visionOS 2.0 or later
   - Developer mode enabled
   - Paired with development Mac

### Environment Setup

```bash
# Install Xcode Command Line Tools
xcode-select --install

# Verify installation
xcodebuild -version
# Should output: Xcode 16.0 or later

# Install xcpretty for better build output (optional)
gem install xcpretty
```

---

## Build Configuration

### Build Settings

#### Debug Configuration

```swift
// Xcode Build Settings - Debug
SWIFT_OPTIMIZATION_LEVEL = -Onone
SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG
GCC_OPTIMIZATION_LEVEL = 0
ENABLE_TESTABILITY = YES
DEBUG_INFORMATION_FORMAT = dwarf-with-dsym
```

#### Release Configuration

```swift
// Xcode Build Settings - Release
SWIFT_OPTIMIZATION_LEVEL = -O
SWIFT_COMPILATION_MODE = wholemodule
GCC_OPTIMIZATION_LEVEL = s
ENABLE_TESTABILITY = NO
DEBUG_INFORMATION_FORMAT = dwarf-with-dsym
VALIDATE_PRODUCT = YES
STRIP_INSTALLED_PRODUCT = YES
```

### Version Management

Update version numbers in `Config.xcconfig`:

```
MARKETING_VERSION = 1.0.0
CURRENT_PROJECT_VERSION = 1
```

Or via Xcode:
1. Select project in Navigator
2. Select target > General
3. Update "Version" and "Build"

### Build Numbers

Use semantic versioning:
- **Version**: `MAJOR.MINOR.PATCH` (e.g., 1.0.0)
- **Build**: Incrementing integer (e.g., 1, 2, 3...)

```bash
# Auto-increment build number
agvtool next-version -all
```

### Configuration Files

Create environment-specific configurations:

```bash
# Config/Debug.xcconfig
#include "Base.xcconfig"
API_BASE_URL = https:/​/dev-api.aiagentcoordinator.dev
ENABLE_LOGGING = YES
CRASH_REPORTING = NO

# Config/Release.xcconfig
#include "Base.xcconfig"
API_BASE_URL = https:/​/api.aiagentcoordinator.dev
ENABLE_LOGGING = NO
CRASH_REPORTING = YES
```

---

## Code Signing & Provisioning

### Certificates

#### Development Certificate

1. Xcode > Settings > Accounts
2. Select your Apple ID
3. Manage Certificates > + > Apple Development
4. Certificate auto-generated

#### Distribution Certificate

1. Xcode > Settings > Accounts
2. Manage Certificates > + > Apple Distribution
3. Or create in [Apple Developer Portal](https://developer.apple.com/account/resources/certificates/)

### Provisioning Profiles

#### Development Profile

```bash
# Automatic (recommended)
# Xcode > Project > Signing & Capabilities
# Enable "Automatically manage signing"
# Select your Team

# Manual
# 1. Go to developer.apple.com
# 2. Certificates, IDs & Profiles > Profiles
# 3. Create new Development profile
# 4. Download and double-click to install
```

#### App Store Profile

1. Developer Portal > Profiles > +
2. Select "App Store" distribution
3. Select App ID
4. Select Distribution certificate
5. Generate and download
6. Double-click to install

### Capabilities

Enable required capabilities in Xcode:

```
Signing & Capabilities Tab:
☑ Hand Tracking
☑ World Sensing
☑ Network (Client)
☑ SharePlay (if using collaboration)
☑ iCloud (if using sync)
```

### Entitlements

Verify `AIAgentCoordinator.entitlements`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.arkit.hand-tracking</key>
    <true/>
    <key>com.apple.developer.worldsensing.hand-tracking-input</key>
    <true/>
    <key>com.apple.developer.spatial-tracking</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <true/>
</dict>
</plist>
```

---

## App Store Submission

### Pre-Submission Checklist

- [ ] All tests passing
- [ ] No compiler warnings
- [ ] Version and build numbers updated
- [ ] Release notes prepared
- [ ] Screenshots created (required sizes)
- [ ] App icons provided (all sizes)
- [ ] Privacy policy URL active
- [ ] Terms of service URL active
- [ ] Support URL active
- [ ] Code signed with distribution certificate
- [ ] Archive validated in Xcode

### Create Archive

```bash
# Clean build folder
Product > Clean Build Folder (Cmd + Shift + K)

# Create archive
Product > Archive

# Or via command line
xcodebuild clean archive \
  -scheme AIAgentCoordinator \
  -destination 'generic/platform=visionOS' \
  -archivePath build/AIAgentCoordinator.xcarchive \
  -configuration Release
```

### Validate Archive

1. Window > Organizer
2. Select your archive
3. Click "Validate App"
4. Choose distribution method: "App Store Connect"
5. Select signing options (Automatic recommended)
6. Click "Validate"
7. Fix any issues reported

### Upload to App Store Connect

**Via Xcode Organizer:**

1. Window > Organizer
2. Select archive
3. Click "Distribute App"
4. Choose "App Store Connect"
5. Select "Upload"
6. Choose signing options
7. Review content
8. Click "Upload"

**Via Command Line:**

```bash
# Export IPA
xcodebuild -exportArchive \
  -archivePath build/AIAgentCoordinator.xcarchive \
  -exportPath build/ \
  -exportOptionsPlist ExportOptions.plist

# Upload with xcrun altool (deprecated, use App Store Connect API)
# Or use Transporter app
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

### App Store Connect Configuration

1. **Login**: [appstoreconnect.apple.com](https://appstoreconnect.apple.com)

2. **Create App**:
   - My Apps > + > New App
   - Platform: visionOS
   - Name: AI Agent Coordinator
   - Language: English
   - Bundle ID: com.yourcompany.aiagentcoordinator
   - SKU: unique identifier

3. **App Information**:
   - **Name**: AI Agent Coordinator
   - **Subtitle**: Spatial AI Agent Management
   - **Category**: Developer Tools / Productivity
   - **License Agreement**: Standard EULA

4. **Pricing & Availability**:
   - Price: Choose tier (or Free)
   - Availability: All territories or select countries
   - Pre-orders: Optional

5. **App Privacy**:
   - Privacy Policy URL: https://aiagentcoordinator.dev/privacy
   - Data Types Collected:
     - User ID (for authentication)
     - Device ID (for license validation)
     - Usage Data (crash reports, analytics)
   - Purpose: App Functionality, Analytics

6. **Version Information**:
   - **Version**: 1.0.0
   - **Copyright**: © 2025 Your Company
   - **Release Notes**: (see template below)
   - **Build**: Select uploaded build

7. **Screenshots** (Required sizes for Vision Pro):
   - 3840 x 2160 px (16:9 landscape)
   - At least 3 screenshots required
   - Showcase key features:
     - Galaxy visualization
     - Control panel
     - Performance dashboard

8. **App Preview Videos** (Optional):
   - Up to 3 videos
   - 30 seconds each
   - Show app in action

9. **Description**:
   ```
   AI Agent Coordinator brings professional AI infrastructure management to Apple Vision Pro.

   Monitor, manage, and visualize thousands of AI agents in immersive 3D space.

   FEATURES:
   • Immersive 3D agent network visualization
   • Real-time performance monitoring
   • Multi-platform integration (OpenAI, AWS, Azure, Anthropic)
   • SharePlay collaboration for team management
   • Spatial hand tracking and gesture controls
   • Voice command support
   • Enterprise-grade security

   VISUALIZATIONS:
   • Agent Galaxy: See your entire AI ecosystem at a glance
   • Performance Landscape: 3D terrain showing system health
   • Decision Flow River: Trace data through orchestration workflows

   INTEGRATIONS:
   • OpenAI (GPT models, Assistants)
   • AWS SageMaker (ML endpoints)
   • Anthropic (Claude)
   • Azure AI Services
   • Google Vertex AI
   • Custom REST/gRPC APIs

   Perfect for DevOps teams, ML engineers, and AI infrastructure managers.
   ```

10. **Keywords**: (100 characters max)
    ```
    ai,agent,monitoring,devops,ml,openai,aws,spatial,3d,visualization
    ```

11. **Support URL**: https://support.aiagentcoordinator.dev

12. **Marketing URL**: https://aiagentcoordinator.dev

### Release Notes Template

```
Version 1.0.0 - Initial Release

Welcome to AI Agent Coordinator for Vision Pro!

NEW FEATURES:
• Immersive 3D agent network visualization (Galaxy View)
• Real-time performance monitoring and alerting
• Multi-platform integration support
• SharePlay collaboration for team monitoring
• Spatial gesture controls and voice commands
• Comprehensive agent lifecycle management

SUPPORTED PLATFORMS:
• OpenAI (GPT-4, GPT-3.5, Assistants API)
• AWS SageMaker (ML endpoints, CloudWatch integration)
• Anthropic (Claude models)
• Azure AI Services
• Google Vertex AI
• Custom integrations via REST/gRPC

We're excited to bring AI infrastructure management to spatial computing!

Questions or feedback? Contact support@aiagentcoordinator.dev
```

### Submit for Review

1. **Add for Review**: App Store Connect > Version > Submit for Review
2. **Answer Questions**:
   - Export Compliance: Does your app use encryption? (Yes/No)
   - Content Rights: Do you own all content? (Yes)
   - Advertising Identifier: Does app use IDFA? (No)
3. **Submit**: Click "Submit for Review"

### Review Timeline

- **Initial Review**: 24-48 hours typically
- **Resubmissions**: 24 hours typically
- **Check Status**: App Store Connect > My Apps > Activity

### Common Rejection Reasons

1. **Incomplete Information**: Missing screenshots, descriptions
2. **Privacy Issues**: Privacy policy missing or incomplete
3. **Crashes**: App crashes on launch or during review
4. **Broken Features**: Features don't work as described
5. **Guideline Violations**: Not following App Store Review Guidelines

---

## TestFlight Distribution

### Internal Testing

**Setup**:
1. App Store Connect > TestFlight > Internal Testing
2. Add internal testers (up to 100, must have App Store Connect role)
3. Testers auto-receive new builds

**Upload Build**:
- Same process as App Store (Archive > Upload)
- Builds appear in TestFlight after processing (10-60 minutes)

### External Testing

**Setup**:
1. App Store Connect > TestFlight > External Testing
2. Create test group
3. Add testers by email (up to 10,000)
4. Add builds to group
5. Submit for Beta App Review (required)

**Invite Testers**:
1. Testers receive email invitation
2. Install TestFlight app on Vision Pro
3. Accept invitation
4. Install beta build

**Test Information**:
```
What to Test:
• Agent network visualization performance
• Platform integration connectivity
• Hand tracking gesture controls
• SharePlay collaboration features
• Performance with large agent datasets (1000+ agents)

Known Issues:
• None

Feedback Email: beta@aiagentcoordinator.dev
```

---

## Enterprise Distribution

### Prerequisites

- Apple Developer Enterprise Program ($299/year)
- Enterprise distribution certificate
- In-house provisioning profile

### Build for Enterprise

1. **Certificate**:
   - Apple Developer Portal > Certificates > +
   - Select "In-House and Ad Hoc"
   - Download and install

2. **Provisioning Profile**:
   - Profiles > + > In House
   - Select App ID and certificate
   - Download and install

3. **Archive**:
   - Same as App Store
   - Product > Archive

4. **Export**:
   - Organizer > Distribute App
   - Select "Enterprise"
   - Choose signing
   - Export IPA

### Deploy via MDM

**Jamf Pro Example**:

```bash
# Upload IPA to Jamf
# Configure app deployment:
# - Target: All Vision Pro devices
# - Distribution: Install automatically
# - Update: Auto-update enabled
```

**Microsoft Intune Example**:

1. Intune > Apps > iOS/iPadOS apps > Add
2. Upload IPA file
3. Configure app information
4. Assign to groups
5. Deploy

### Manual Installation

```bash
# Using Apple Configurator (not typically available for visionOS)
# Or distribute IPA via internal website:

# 1. Host IPA file
# 2. Create manifest.plist
# 3. Users download via: itms-services://?action=download-manifest&url=https://yourcompany.com/manifest.plist
```

**manifest.plist**:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>items</key>
    <array>
        <dict>
            <key>assets</key>
            <array>
                <dict>
                    <key>kind</key>
                    <string>software-package</string>
                    <key>url</key>
                    <string>https://yourcompany.com/AIAgentCoordinator.ipa</string>
                </dict>
            </array>
            <key>metadata</key>
            <dict>
                <key>bundle-identifier</key>
                <string>com.yourcompany.aiagentcoordinator</string>
                <key>bundle-version</key>
                <string>1.0.0</string>
                <key>kind</key>
                <string>software</string>
                <key>title</key>
                <string>AI Agent Coordinator</string>
            </dict>
        </dict>
    </array>
</dict>
</plist>
```

---

## Post-Deployment

### Monitor App Store Metrics

**App Store Connect Analytics**:
- Impressions
- Product page views
- Downloads
- Crashes
- Customer reviews

**Access**: App Store Connect > Analytics > App Analytics

### Crash Reporting

**Xcode Organizer**:
1. Window > Organizer > Crashes
2. View crash reports
3. Symbolicate crashes
4. Identify issues

**Third-Party Tools** (optional):
- Firebase Crashlytics
- Sentry
- Bugsnag

### User Feedback

**Monitor Reviews**:
- App Store Connect > Ratings and Reviews
- Respond to reviews (optional)
- Address common issues

**Support Channels**:
- Email: support@aiagentcoordinator.dev
- GitHub Issues: Bug tracking
- Documentation: Help articles

### Release Communication

**Announcement Channels**:
- Website blog post
- Email to existing users
- Social media (Twitter, LinkedIn)
- Product Hunt launch (optional)
- Tech blogs outreach

---

## Rollback Procedures

### Remove from Sale

**Emergency only** - if critical issue discovered:

1. App Store Connect > My Apps > AI Agent Coordinator
2. Pricing and Availability
3. Uncheck all territories
4. Save
5. App removed from sale within hours

### Submit Hotfix

```bash
# 1. Create hotfix branch
git checkout -b hotfix/1.0.1 release/1.0.0

# 2. Fix critical issue
# ... make changes ...

# 3. Update version
# Version: 1.0.1
# Build: increment

# 4. Test thoroughly
xcodebuild test -scheme AIAgentCoordinator

# 5. Create archive and submit
# Follow standard submission process

# 6. Mark as critical bug fix
# App Store Connect > What's New:
# "Critical bug fix for [issue]. Users should update immediately."

# 7. Request expedited review (if truly critical)
# App Store Connect > Contact Us > Request Expedited Review
# Explain critical nature
```

### Revert to Previous Version

**Not possible directly**, but can:
1. Submit older build as new version
2. Increment version number (e.g., 1.0.2 containing 1.0.0 code)
3. Users update to "reverted" version

---

## Monitoring & Analytics

### Built-in Analytics

```swift
// app already includes basic analytics
// See Services/Analytics/AnalyticsService.swift

// Track key events
AnalyticsService.shared.track(.appLaunched)
AnalyticsService.shared.track(.agentCreated(type: .llm))
AnalyticsService.shared.track(.visualizationOpened(type: .galaxy))
```

### Performance Monitoring

**MetricKit** (built-in):
```swift
import MetricKit

class MetricsManager: NSObject, MXMetricManagerSubscriber {
    override init() {
        super.init()
        MXMetricManager.shared.add(self)
    }

    func didReceive(_ payloads: [MXMetricPayload]) {
        for payload in payloads {
            // Process metrics
            // Upload to analytics service
        }
    }
}
```

### Update Strategy

**Frequency**: Every 2-4 weeks for minor updates, as needed for critical fixes

**Version Scheme**:
- Major (1.0.0 → 2.0.0): Breaking changes, major features
- Minor (1.0.0 → 1.1.0): New features, improvements
- Patch (1.0.0 → 1.0.1): Bug fixes only

---

## Automation (CI/CD)

See `.github/workflows/deploy.yml` for automated deployment pipeline.

**GitHub Actions** example:

```yaml
name: Deploy to App Store

on:
  release:
    types: [published]

jobs:
  deploy:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4

      - name: Setup Xcode
        uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: '16.0'

      - name: Build and Archive
        run: |
          xcodebuild archive \
            -scheme AIAgentCoordinator \
            -destination 'generic/platform=visionOS' \
            -archivePath build/App.xcarchive

      - name: Upload to App Store
        env:
          APP_STORE_CONNECT_API_KEY: ${{ secrets.ASC_API_KEY }}
        run: |
          xcodebuild -exportArchive \
            -archivePath build/App.xcarchive \
            -exportPath build/ \
            -exportOptionsPlist ExportOptions.plist
```

---

## Troubleshooting

### Common Build Issues

**Issue**: "Code signing failed"
**Solution**: Verify certificates and provisioning profiles are valid

**Issue**: "Missing required icon"
**Solution**: Ensure all icon sizes provided in Assets.xcassets

**Issue**: "Invalid bundle"
**Solution**: Check Bundle ID matches App Store Connect

### Upload Issues

**Issue**: "Upload failed - network error"
**Solution**: Check internet connection, try Transporter app

**Issue**: "Invalid app bundle - missing entitlements"
**Solution**: Verify entitlements file configured correctly

---

## Support

For deployment questions:
- Email: deployment@aiagentcoordinator.dev
- Documentation: https://docs.aiagentcoordinator.dev/deployment
- GitHub: Issues for deployment-related bugs

---

**Ready to deploy?** Follow the checklist in [RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md)!
