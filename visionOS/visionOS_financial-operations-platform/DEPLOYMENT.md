# Financial Operations Platform - Deployment Guide

## Table of Contents
1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Development Environment Setup](#development-environment-setup)
4. [Building the Application](#building-the-application)
5. [Testing on visionOS Simulator](#testing-on-visionos-simulator)
6. [Testing on Apple Vision Pro Device](#testing-on-apple-vision-pro-device)
7. [TestFlight Distribution](#testflight-distribution)
8. [App Store Submission](#app-store-submission)
9. [Enterprise Distribution](#enterprise-distribution)
10. [Continuous Integration/Deployment](#continuous-integrationdeployment)
11. [Monitoring and Analytics](#monitoring-and-analytics)
12. [Troubleshooting](#troubleshooting)

---

## Overview

This guide provides comprehensive instructions for deploying the Financial Operations Platform visionOS application across different environments, from local development to production App Store distribution.

### Deployment Targets

- **Development**: Local Xcode builds on visionOS Simulator
- **Internal Testing**: Device testing on Apple Vision Pro hardware
- **Beta Testing**: TestFlight distribution to pilot users
- **Production**: App Store distribution to enterprise customers
- **Enterprise**: Custom enterprise distribution for large organizations

---

## Prerequisites

### Required Software

#### Xcode 16.0+
```bash
# Check Xcode version
xcodebuild -version
# Expected: Xcode 16.0 or later

# Verify visionOS SDK is installed
xcodebuild -showsdks | grep visionOS
# Expected: visionOS 2.0 or later
```

#### macOS Sonoma or later
```bash
# Check macOS version
sw_vers
# Expected: macOS 14.0 (Sonoma) or later
```

#### Command Line Tools
```bash
# Install Xcode Command Line Tools
xcode-select --install

# Verify installation
xcode-select -p
# Expected: /Applications/Xcode.app/Contents/Developer
```

### Required Accounts

1. **Apple Developer Account** (required)
   - Individual or Organization account
   - Apple Developer Program membership ($99/year)
   - Access to App Store Connect

2. **App Store Connect Access**
   - Admin or App Manager role
   - Certificates, Identifiers & Profiles access
   - TestFlight access for beta distribution

3. **Apple Vision Pro Device** (optional but recommended)
   - For device testing
   - Developer mode enabled

### Required Certificates & Profiles

1. **Development Certificate**
   - iOS/visionOS Development Certificate
   - Installed in Xcode

2. **Distribution Certificate**
   - iOS/visionOS Distribution Certificate
   - For TestFlight and App Store

3. **Provisioning Profiles**
   - Development provisioning profile
   - Ad Hoc provisioning profile (for device testing)
   - App Store provisioning profile

---

## Development Environment Setup

### 1. Clone the Repository

```bash
# Clone the repository
git clone https://github.com/your-org/visionOS_financial-operations-platform.git
cd visionOS_financial-operations-platform
```

### 2. Open in Xcode

```bash
# Open the Xcode project
open FinancialOpsApp/FinancialOpsApp.xcodeproj
```

### 3. Configure Signing & Capabilities

1. Select the **FinancialOpsApp** target
2. Go to **Signing & Capabilities** tab
3. Select your **Team** from the dropdown
4. Verify **Bundle Identifier** matches your registered App ID
   - Example: `com.yourcompany.financialopsapp`
5. Enable **Automatically manage signing** (recommended)

### 4. Configure Build Settings

#### Required Build Settings

```
SWIFT_VERSION = 6.0
SWIFT_STRICT_CONCURRENCY = complete
IPHONEOS_DEPLOYMENT_TARGET = 2.0
TARGETED_DEVICE_FAMILY = 7 (visionOS)
ENABLE_PREVIEWS = YES
SWIFT_OPTIMIZATION_LEVEL = -O (for release)
```

#### Update in Xcode:
1. Select **FinancialOpsApp** project
2. Select **FinancialOpsApp** target
3. Go to **Build Settings**
4. Verify the settings above

### 5. Verify Dependencies

```bash
# Verify Swift Package Manager dependencies
# Xcode will automatically resolve packages when opening the project

# If needed, manually resolve packages:
# File > Packages > Resolve Package Versions
```

---

## Building the Application

### Development Build (Simulator)

```bash
# Build for visionOS Simulator
xcodebuild \
  -project FinancialOpsApp/FinancialOpsApp.xcodeproj \
  -scheme FinancialOpsApp \
  -sdk xrsimulator \
  -configuration Debug \
  clean build

# Expected output: BUILD SUCCEEDED
```

### Development Build (Device)

```bash
# Build for Apple Vision Pro device
xcodebuild \
  -project FinancialOpsApp/FinancialOpsApp.xcodeproj \
  -scheme FinancialOpsApp \
  -sdk xros \
  -configuration Debug \
  clean build

# Expected output: BUILD SUCCEEDED
```

### Release Build (for distribution)

```bash
# Build for App Store distribution
xcodebuild \
  -project FinancialOpsApp/FinancialOpsApp.xcodeproj \
  -scheme FinancialOpsApp \
  -sdk xros \
  -configuration Release \
  clean archive \
  -archivePath ./build/FinancialOpsApp.xcarchive

# Expected output: ARCHIVE SUCCEEDED
```

### Build from Xcode GUI

1. **Select Target**:
   - Product > Destination > Choose simulator or device

2. **Build**:
   - Press `⌘B` or Product > Build

3. **Run**:
   - Press `⌘R` or Product > Run

---

## Testing on visionOS Simulator

### Launch Simulator

```bash
# Open visionOS Simulator
open -a Simulator

# Or from Xcode: Xcode > Open Developer Tool > Simulator
```

### Run on Simulator

1. **Select Simulator**: Product > Destination > Apple Vision Pro (Simulator)
2. **Run**: Press `⌘R` or Product > Run
3. **Verify**: App launches and displays dashboard

### Simulator Keyboard Shortcuts

- **Home**: `⌘H`
- **Rotate Left**: `⌘←`
- **Rotate Right**: `⌘→`
- **Move Up**: `⌥↑`
- **Move Down**: `⌥↓`

### Simulator Limitations

⚠️ **Note**: The visionOS Simulator has limitations:
- No hand tracking (use mouse/trackpad)
- No eye tracking
- No spatial audio
- Reduced performance vs. device
- No real-world passthrough

For full testing, use an actual Apple Vision Pro device.

---

## Testing on Apple Vision Pro Device

### Enable Developer Mode

1. **On Apple Vision Pro**:
   - Settings > Privacy & Security > Developer Mode
   - Toggle **Developer Mode** ON
   - Restart device when prompted

2. **Verify in Xcode**:
   - Connect device via USB-C or wirelessly
   - Device should appear in destination list

### Connect Device

#### USB-C Connection (Recommended)
```bash
# Connect Apple Vision Pro via USB-C cable
# Device will appear in Xcode automatically

# Verify connection
xcrun devicectl list devices
```

#### Wireless Connection
1. Window > Devices and Simulators
2. Select your Apple Vision Pro
3. Check "Connect via network"
4. Disconnect USB-C cable

### Deploy to Device

1. **Select Device**: Product > Destination > [Your Apple Vision Pro]
2. **Trust Device**:
   - Click "Trust" on Mac prompt
   - Enter passcode on Vision Pro
3. **Run**: Press `⌘R` or Product > Run
4. **Verify Installation**: App installs and launches on device

### Device Testing Checklist

- [ ] App launches successfully
- [ ] Dashboard displays all KPI cards
- [ ] Hand gestures work correctly
- [ ] Eye tracking navigation functions
- [ ] 3D visualizations render properly
- [ ] Spatial audio plays correctly
- [ ] Performance is smooth (90+ FPS)
- [ ] Memory usage is acceptable
- [ ] No crashes or errors

---

## TestFlight Distribution

### 1. Create App Store Connect Record

1. **Sign in to App Store Connect**: https://appstoreconnect.apple.com
2. **Navigate to**: My Apps > + > New App
3. **Fill in details**:
   - **Platform**: visionOS
   - **Name**: Financial Operations Platform
   - **Primary Language**: English
   - **Bundle ID**: Select your registered bundle ID
   - **SKU**: FINOPS-001 (or unique identifier)

### 2. Configure App Information

#### App Information
- **Name**: Financial Operations Platform
- **Subtitle**: Immersive Financial Management
- **Category**: Business, Finance
- **Content Rights**: Contains third-party content

#### Pricing and Availability
- **Price**: Set according to your pricing tier
- **Availability**: Select countries/regions

### 3. Build and Archive

```bash
# Create archive for distribution
xcodebuild \
  -project FinancialOpsApp/FinancialOpsApp.xcodeproj \
  -scheme FinancialOpsApp \
  -sdk xros \
  -configuration Release \
  -archivePath ./build/FinancialOpsApp.xcarchive \
  clean archive

# Verify archive
ls -lh ./build/FinancialOpsApp.xcarchive
```

### 4. Export for TestFlight

#### Using Xcode GUI

1. **Open Organizer**: Window > Organizer
2. **Select Archive**: Choose the latest archive
3. **Distribute App**: Click "Distribute App"
4. **Select Method**: Choose "TestFlight & App Store"
5. **Upload**: Follow prompts to upload to App Store Connect

#### Using Command Line

```bash
# Export archive
xcodebuild \
  -exportArchive \
  -archivePath ./build/FinancialOpsApp.xcarchive \
  -exportPath ./build/Export \
  -exportOptionsPlist ExportOptions.plist

# Upload to App Store Connect
xcrun altool --upload-app \
  -f ./build/Export/FinancialOpsApp.ipa \
  -t ios \
  -u your-apple-id@example.com \
  -p your-app-specific-password
```

#### ExportOptions.plist Template

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
```

### 5. Configure TestFlight

1. **Navigate to**: App Store Connect > TestFlight
2. **Select Build**: Choose uploaded build
3. **Export Compliance**: Answer encryption questions
4. **Add Testers**:
   - Internal Testing: Add up to 100 internal testers
   - External Testing: Create beta groups

### 6. Invite Beta Testers

#### Internal Testing
```
1. Navigate to Internal Testing
2. Click + to add testers
3. Select users from your organization
4. Build automatically distributes to internal testers
```

#### External Testing
```
1. Navigate to External Testing
2. Create a new group (e.g., "Pilot Users")
3. Add beta testers via email
4. Submit for Beta App Review (if first build)
5. Testers receive invitation email after approval
```

### 7. Monitor TestFlight Feedback

- **Crashes**: App Store Connect > TestFlight > Crashes
- **Feedback**: Email notifications from testers
- **Usage**: TestFlight > Metrics

---

## App Store Submission

### 1. Prepare App Metadata

#### Required Assets

**App Icon (visionOS)**
- 1024x1024 PNG (no transparency)
- Optional: App icon layers for 3D effect

**Screenshots (Apple Vision Pro)**
- At least 3 screenshots
- Recommended sizes:
  - 2570x1920 (landscape)
  - 1920x2570 (portrait)
  - Capture actual app running on device or simulator

**App Preview Videos (Optional)**
- Up to 3 preview videos
- Max duration: 30 seconds each
- Format: M4V, MP4, or MOV

#### App Description

```
Transform your financial operations with the power of spatial computing.

Financial Operations Platform brings enterprise financial management into a new dimension with:

• Real-time 3D cash flow visualization
• Immersive risk management landscapes
• AI-powered financial insights
• Natural gesture-based controls
• Collaborative spatial workspaces

Built exclusively for Apple Vision Pro, this platform transforms traditional financial dashboards into interactive command centers providing unprecedented visibility into cash flows, risk positions, and operational performance.

FEATURES:
• Real-Time Treasury Management
• Immersive Financial Reporting
• Risk Management Command Center
• Strategic Financial Planning
• AI-Powered Analytics

Perfect for CFOs, finance teams, and treasury professionals managing complex financial operations.

Requires enterprise license. Contact sales for pricing.
```

### 2. Configure App Store Information

1. **Navigate to**: App Store Connect > My Apps > Financial Operations Platform
2. **Select**: App Store tab
3. **Fill in**:
   - **App Name**: Financial Operations Platform
   - **Subtitle**: Immersive Financial Management for Apple Vision Pro
   - **Description**: (see above)
   - **Keywords**: finance, treasury, accounting, CFO, financial operations, spatial computing
   - **Support URL**: https://yourcompany.com/support
   - **Marketing URL**: https://yourcompany.com/financialops
   - **Privacy Policy URL**: https://yourcompany.com/privacy

### 3. Configure Version Information

- **Version**: 1.0.0
- **Copyright**: © 2024 Your Company
- **Age Rating**: 4+ (appropriate for all ages)
- **Category**: Primary: Business, Secondary: Finance

### 4. Submit for Review

1. **Select Build**: Choose TestFlight build
2. **Add Screenshots**: Upload required screenshots
3. **Fill Review Information**:
   - **Demo Account**: Provide test credentials
   - **Review Notes**: Any special instructions
4. **Submit for Review**: Click "Submit for Review"

### 5. App Review Process

**Timeline**: Typically 24-48 hours

**Possible Outcomes**:
- ✅ **Approved**: App goes live automatically
- ⚠️ **Metadata Rejected**: Update metadata and resubmit
- ❌ **Rejected**: Address issues and resubmit

**Common Rejection Reasons**:
- Missing demo account
- Crashes on launch
- Privacy policy issues
- Incomplete functionality
- Guideline violations

### 6. Post-Approval

Once approved:
- App is **live on App Store** (if auto-release enabled)
- Or **ready for manual release**
- Update **Marketing Website** with App Store link
- Announce to **Sales Team** and **Customers**

---

## Enterprise Distribution

For large organizations requiring custom distribution outside the App Store.

### Apple Business Manager

1. **Enroll Organization**:
   - Visit https://business.apple.com
   - Enroll in Apple Business Manager

2. **Create Custom Apps**:
   - Enable custom app distribution
   - Generate custom B2B app

3. **Deploy to Managed Devices**:
   - Use MDM (Mobile Device Management)
   - Push app to Vision Pro devices

### Ad Hoc Distribution

For limited device testing (up to 100 devices):

```bash
# Build with Ad Hoc provisioning profile
xcodebuild \
  -project FinancialOpsApp/FinancialOpsApp.xcodeproj \
  -scheme FinancialOpsApp \
  -sdk xros \
  -configuration Release \
  -archivePath ./build/FinancialOpsApp-AdHoc.xcarchive \
  CODE_SIGN_STYLE=Manual \
  PROVISIONING_PROFILE_SPECIFIER="FinancialOps AdHoc" \
  clean archive

# Export with Ad Hoc method
xcodebuild \
  -exportArchive \
  -archivePath ./build/FinancialOpsApp-AdHoc.xcarchive \
  -exportPath ./build/AdHoc \
  -exportOptionsPlist ExportOptions-AdHoc.plist
```

**Distribution**:
- Distribute .ipa file to testers
- Install via Xcode Devices window or MDM

---

## Continuous Integration/Deployment

### GitHub Actions Workflow

Create `.github/workflows/build-test.yml`:

```yaml
name: Build and Test

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: macos-14

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Select Xcode version
      run: sudo xcode-select -s /Applications/Xcode_16.0.app

    - name: Show Xcode version
      run: xcodebuild -version

    - name: Build for visionOS Simulator
      run: |
        xcodebuild \
          -project FinancialOpsApp/FinancialOpsApp.xcodeproj \
          -scheme FinancialOpsApp \
          -sdk xrsimulator \
          -configuration Debug \
          clean build

    - name: Run tests
      run: |
        xcodebuild test \
          -project FinancialOpsApp/FinancialOpsApp.xcodeproj \
          -scheme FinancialOpsApp \
          -sdk xrsimulator \
          -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

    - name: Run validation tests
      run: ./test-suite.sh
```

### Fastlane Configuration

Create `Fastfile`:

```ruby
default_platform(:ios)

platform :ios do
  desc "Run tests"
  lane :test do
    run_tests(
      scheme: "FinancialOpsApp",
      device: "Apple Vision Pro (Simulator)",
      sdk: "xrsimulator"
    )
  end

  desc "Build for TestFlight"
  lane :beta do
    build_app(
      scheme: "FinancialOpsApp",
      sdk: "xros",
      configuration: "Release"
    )
    upload_to_testflight(
      skip_waiting_for_build_processing: true
    )
  end

  desc "Build for App Store"
  lane :release do
    build_app(
      scheme: "FinancialOpsApp",
      sdk: "xros",
      configuration: "Release"
    )
    upload_to_app_store(
      submit_for_review: false,
      automatic_release: false
    )
  end
end
```

**Usage**:
```bash
# Run tests
fastlane test

# Deploy to TestFlight
fastlane beta

# Deploy to App Store
fastlane release
```

---

## Monitoring and Analytics

### Crash Reporting

**Xcode Organizer**:
- Window > Organizer > Crashes
- View crashes from TestFlight and App Store users
- Download and symbolicate crash reports

**Third-Party Services**:
- Firebase Crashlytics
- Sentry
- Bugsnag

### Performance Monitoring

**MetricKit Integration**:

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
            if let launchTime = payload.applicationLaunchMetrics {
                print("Launch time: \(launchTime)")
            }
        }
    }
}
```

### Analytics

**App Store Connect Analytics**:
- Sales and Trends
- App Analytics
- Acquisition metrics
- User engagement

**Custom Analytics**:
- Firebase Analytics
- Mixpanel
- Amplitude

---

## Troubleshooting

### Build Errors

#### "No matching provisioning profile found"

**Solution**:
```bash
# Refresh provisioning profiles
1. Xcode > Settings > Accounts
2. Select Apple ID
3. Download Manual Profiles
```

#### "Swift compiler error"

**Solution**:
```bash
# Clean build folder
Product > Clean Build Folder (⌘⇧K)

# Delete DerivedData
rm -rf ~/Library/Developer/Xcode/DerivedData
```

### Deployment Errors

#### "Asset validation failed"

**Solution**:
- Verify app icons are correct size and format
- Check for missing required screenshots
- Ensure all metadata fields are filled

#### "Binary was rejected"

**Solution**:
- Check for missing bitcode
- Verify minimum visionOS version
- Ensure proper code signing

### TestFlight Errors

#### "Build is not available to test"

**Solution**:
- Wait for processing to complete (can take 30+ minutes)
- Check for email about export compliance
- Verify build status in App Store Connect

#### "Testers not receiving invites"

**Solution**:
- Check spam/junk folders
- Verify email addresses are correct
- Ensure TestFlight app is installed on device

### Runtime Issues

#### "App crashes on launch"

**Debug Steps**:
```bash
# View device logs
1. Window > Devices and Simulators
2. Select device
3. View Device Logs
4. Filter for FinancialOpsApp
```

#### "Poor performance"

**Optimization**:
- Profile with Instruments (Time Profiler)
- Reduce polygon count in 3D scenes
- Optimize texture sizes
- Implement LOD (Level of Detail)

---

## Support and Resources

### Apple Documentation

- [visionOS Developer Documentation](https://developer.apple.com/visionos/)
- [App Store Connect Help](https://developer.apple.com/help/app-store-connect/)
- [TestFlight Documentation](https://developer.apple.com/testflight/)

### Internal Resources

- **Architecture**: See [ARCHITECTURE.md](ARCHITECTURE.md)
- **Technical Specs**: See [TECHNICAL_SPEC.md](TECHNICAL_SPEC.md)
- **Testing**: See [TESTING.md](TESTING.md)
- **Implementation Plan**: See [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md)

### Getting Help

- **GitHub Issues**: [Repository Issues](https://github.com/your-org/visionOS_financial-operations-platform/issues)
- **Internal Slack**: #finops-development
- **Email**: development@yourcompany.com

---

**Version**: 1.0.0
**Last Updated**: 2024-11-17
**Status**: Production Ready
