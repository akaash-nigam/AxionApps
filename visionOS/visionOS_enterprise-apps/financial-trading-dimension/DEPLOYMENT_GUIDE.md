# Deployment Guide - Financial Trading Dimension

**Version**: 1.0
**Last Updated**: 2025-11-17

This guide covers deploying Financial Trading Dimension to various environments, from development to production App Store release.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Environment Configuration](#environment-configuration)
3. [Build Configurations](#build-configurations)
4. [Development Deployment](#development-deployment)
5. [Beta Deployment (TestFlight)](#beta-deployment-testflight)
6. [Production Deployment (App Store)](#production-deployment-app-store)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Tools

- **macOS 14.0+** (Sonoma or later)
- **Xcode 16.0+** with visionOS 2.0 SDK
- **Apple Developer Account** (paid membership)
- **App Store Connect access**
- **Fastlane** (optional, for automation)

### Required Credentials

- Apple Developer Team ID
- App Store Connect API Key
- Signing certificates
- Provisioning profiles
- Market data API keys (for production)
- Trading platform credentials (for production)

### Required Access

- GitHub repository access
- CI/CD system access (GitHub Actions)
- App Store Connect account
- TestFlight access

---

## Environment Configuration

### Environment Types

We support three environments:

| Environment | Purpose | Data | APIs |
|-------------|---------|------|------|
| Development | Local development | Mock | Mocked |
| Staging | Beta testing | Test | Sandbox |
| Production | Live app | Real | Production |

### Configuration Files

#### 1. Create Config Files

Each environment has its own configuration:

**Development** (`Config/Development.xcconfig`):
```
APP_NAME = Financial Trading Dimension DEV
BUNDLE_IDENTIFIER = com.financialtradingdimension.dev
API_BASE_URL = https://api-dev.financialtradingdimension.com
MARKET_DATA_API_KEY = dev_key_here
ENABLE_ANALYTICS = NO
LOG_LEVEL = DEBUG
```

**Staging** (`Config/Staging.xcconfig`):
```
APP_NAME = Financial Trading Dimension BETA
BUNDLE_IDENTIFIER = com.financialtradingdimension.beta
API_BASE_URL = https://api-staging.financialtradingdimension.com
MARKET_DATA_API_KEY = staging_key_here
ENABLE_ANALYTICS = YES
LOG_LEVEL = INFO
```

**Production** (`Config/Production.xcconfig`):
```
APP_NAME = Financial Trading Dimension
BUNDLE_IDENTIFIER = com.financialtradingdimension.app
API_BASE_URL = https://api.financialtradingdimension.com
MARKET_DATA_API_KEY = prod_key_here
ENABLE_ANALYTICS = YES
LOG_LEVEL = WARNING
```

#### 2. Environment Variables

Create `.env` files for sensitive data (never commit these):

**`.env.development`**:
```bash
MARKET_DATA_API_KEY=dev_api_key
TRADING_API_KEY=dev_trading_key
ANALYTICS_KEY=dev_analytics_key
```

**`.env.production`**:
```bash
MARKET_DATA_API_KEY=prod_api_key
TRADING_API_KEY=prod_trading_key
ANALYTICS_KEY=prod_analytics_key
```

---

## Build Configurations

### Xcode Build Settings

#### 1. Create Build Configurations

In Xcode:
1. Project Settings → Info → Configurations
2. Duplicate "Debug" → Rename to "Development"
3. Duplicate "Release" → Rename to "Staging"
4. Keep "Release" for "Production"

#### 2. Scheme Configuration

Create schemes for each environment:

**Development Scheme**:
- Configuration: Development
- Target: FinancialTradingDimension
- Destination: Any visionOS Simulator

**Staging Scheme**:
- Configuration: Staging
- Target: FinancialTradingDimension
- Destination: Any visionOS Device

**Production Scheme**:
- Configuration: Release
- Target: FinancialTradingDimension
- Destination: Any visionOS Device

#### 3. Code Signing

**Development**:
- Signing: Automatically manage signing
- Team: Your development team
- Provisioning Profile: Xcode Managed

**Staging/Production**:
- Signing: Manual signing
- Certificate: Distribution certificate
- Provisioning Profile: App Store profile

---

## Development Deployment

### Local Development

#### 1. Build for Simulator

```bash
# Via Xcode
⌘R with Development scheme selected

# Via command line
xcodebuild build \
  -scheme FinancialTradingDimension \
  -configuration Development \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

#### 2. Run Tests

```bash
# Via Xcode
⌘U

# Via command line
xcodebuild test \
  -scheme FinancialTradingDimension \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -enableCodeCoverage YES
```

#### 3. Debug Build

- Enable verbose logging
- Use mock services
- Enable debug overlays
- Fast iteration without optimizations

---

## Beta Deployment (TestFlight)

### Prerequisites

1. **App Store Connect Setup**
   - App record created
   - Bundle ID registered
   - TestFlight enabled

2. **Certificates & Provisioning**
   - Distribution certificate installed
   - App Store provisioning profile downloaded

### Deployment Steps

#### 1. Prepare Build

```bash
# Clean build folder
rm -rf ~/Library/Developer/Xcode/DerivedData

# Update version and build number
# Edit Info.plist:
# - CFBundleShortVersionString (e.g., 1.0.0)
# - CFBundleVersion (e.g., 1)
```

#### 2. Archive Build

**Via Xcode**:
1. Select "Any visionOS Device" destination
2. Product → Archive
3. Wait for archive to complete
4. Organizer window opens automatically

**Via Command Line**:
```bash
xcodebuild archive \
  -scheme FinancialTradingDimension \
  -configuration Staging \
  -archivePath build/FinancialTradingDimension.xcarchive \
  -destination 'generic/platform=visionOS'
```

#### 3. Export for App Store

**Via Xcode Organizer**:
1. Select archive
2. Click "Distribute App"
3. Choose "App Store Connect"
4. Select "Upload"
5. Choose signing options (automatic recommended)
6. Review and upload

**Via Command Line**:
```bash
xcodebuild -exportArchive \
  -archivePath build/FinancialTradingDimension.xcarchive \
  -exportPath build/export \
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
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
</dict>
</plist>
```

#### 4. Upload to App Store Connect

**Via Xcode**:
- Automatic upload after export

**Via Transporter App**:
1. Open Transporter
2. Add .ipa file
3. Deliver

**Via altool** (command line):
```bash
xcrun altool --upload-app \
  -f build/export/FinancialTradingDimension.ipa \
  -t ios \
  -u your@email.com \
  -p @keychain:AC_PASSWORD
```

#### 5. Configure TestFlight

In App Store Connect:
1. Go to TestFlight tab
2. Select build
3. Add test information:
   - What to test
   - Beta App Description
   - Test details
4. Add internal testers
5. Submit for Beta App Review (if needed)
6. Add external testers (after approval)

### TestFlight Distribution

#### Internal Testing

- Add up to 100 internal testers
- No review required
- Instant access
- Use for QA team

#### External Testing

- Add up to 10,000 external testers
- Requires Beta App Review (1-2 days)
- Public link available
- Use for beta users

---

## Production Deployment (App Store)

### Pre-Release Checklist

- [ ] All tests passing
- [ ] Code coverage > 80%
- [ ] SwiftLint violations resolved
- [ ] Performance benchmarks met
- [ ] Security audit completed
- [ ] Accessibility testing done
- [ ] Privacy policy updated
- [ ] Terms of service reviewed
- [ ] App Store materials ready
- [ ] Version number updated
- [ ] Build number incremented

### App Store Submission

#### 1. Prepare App Store Materials

**App Information**:
- App name
- Subtitle
- Keywords
- Primary/secondary category
- Content rights

**Pricing & Availability**:
- Price tier
- Available territories
- Pre-order settings

**App Privacy**:
- Privacy policy URL
- Privacy nutrition labels
- Data collection details

**Version Information**:
- What's new
- Promotional text
- Description
- Keywords
- Support URL
- Marketing URL

**Media**:
- App icon (1024x1024)
- Screenshots (8 required for Vision Pro)
- App preview video (optional)

#### 2. Create App Store Version

In App Store Connect:
1. Go to "App Store" tab
2. Click "+" to add version
3. Enter version number (e.g., 1.0.0)
4. Fill in all required information
5. Upload screenshots and videos
6. Select build from TestFlight
7. Configure release options

#### 3. Submit for Review

1. Click "Submit for Review"
2. Answer App Review questions:
   - Export compliance
   - Content rights
   - Advertising ID usage
   - Sensitive content
3. Provide demo account (if needed)
4. Add review notes (testing instructions)
5. Confirm submission

#### 4. App Review Process

**Timeline**:
- Initial review: 24-48 hours
- Additional questions: 1-3 days (if needed)
- Total: 1-7 days typically

**Possible Outcomes**:
- **Approved**: App goes live (or scheduled)
- **Rejected**: Fix issues and resubmit
- **Metadata Rejected**: Fix metadata only
- **In Review**: Awaiting decision

**Common Rejection Reasons**:
- Crashes or bugs
- Incomplete information
- Guideline violations
- Privacy policy issues
- Incorrect metadata

#### 5. Release

**Automatic Release**:
- App goes live immediately after approval

**Manual Release**:
- Hold for manual release
- Release when ready via App Store Connect

**Scheduled Release**:
- Release on specific date/time
- Set up during submission

### Post-Release

#### 1. Monitor Metrics

**App Store Connect Analytics**:
- Impressions and downloads
- Conversion rate
- Crashes and bugs
- User ratings and reviews

**Internal Analytics**:
- Active users
- Feature usage
- Performance metrics
- Error rates

#### 2. Crash Reporting

Monitor crashes via:
- Xcode Organizer
- App Store Connect
- Third-party tools (Crashlytics, Sentry)

#### 3. User Feedback

- Monitor App Store reviews
- Respond to user feedback
- Track feature requests
- Identify common issues

---

## Automation with Fastlane

### Setup Fastlane

```bash
# Install Fastlane
sudo gem install fastlane

# Initialize in project
cd financial-trading-dimension
fastlane init
```

### Fastfile Configuration

```ruby
default_platform(:visionos)

platform :visionos do
  desc "Run tests"
  lane :test do
    run_tests(
      scheme: "FinancialTradingDimension",
      destination: "platform=visionOS Simulator,name=Apple Vision Pro"
    )
  end

  desc "Build for TestFlight"
  lane :beta do
    increment_build_number
    build_app(
      scheme: "FinancialTradingDimension",
      configuration: "Staging"
    )
    upload_to_testflight(
      skip_waiting_for_build_processing: true
    )
  end

  desc "Build for App Store"
  lane :release do
    increment_version_number
    increment_build_number
    build_app(
      scheme: "FinancialTradingDimension",
      configuration: "Release"
    )
    upload_to_app_store(
      submit_for_review: false,
      automatic_release: false
    )
  end
end
```

### Running Fastlane

```bash
# Run tests
fastlane test

# Deploy to TestFlight
fastlane beta

# Deploy to App Store
fastlane release
```

---

## CI/CD Pipeline

### GitHub Actions

See `.github/workflows/test.yml` for automated testing.

**Additional Workflows**:

**Beta Deployment** (`.github/workflows/beta.yml`):
```yaml
name: Deploy to TestFlight

on:
  push:
    branches: [ main ]
    tags: [ 'v*.*.*-beta' ]

jobs:
  deploy:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to TestFlight
        run: fastlane beta
        env:
          FASTLANE_USER: ${{ secrets.APPLE_ID }}
          FASTLANE_PASSWORD: ${{ secrets.APPLE_PASSWORD }}
```

---

## Troubleshooting

### Build Issues

**Problem**: Code signing failed
**Solution**:
1. Verify certificate is installed
2. Check provisioning profile is valid
3. Ensure bundle ID matches

**Problem**: Build failed with compiler errors
**Solution**:
1. Clean build folder (⇧⌘K)
2. Delete derived data
3. Restart Xcode

### Upload Issues

**Problem**: Invalid archive
**Solution**:
1. Verify all frameworks are properly signed
2. Check Info.plist is correct
3. Ensure no simulator builds included

**Problem**: Upload times out
**Solution**:
1. Check internet connection
2. Try Transporter app instead
3. Upload during off-peak hours

### TestFlight Issues

**Problem**: Build stuck in processing
**Solution**:
- Wait (can take 1-2 hours)
- Check for email from Apple
- Verify dSYM files were uploaded

### App Review Issues

**Problem**: App rejected for crashes
**Solution**:
1. Fix the crash
2. Add better error handling
3. Test thoroughly
4. Resubmit with notes

---

## Security Considerations

### Secrets Management

- **Never commit** API keys or secrets
- Use **Keychain** for local secrets
- Use **GitHub Secrets** for CI/CD
- Use **App Store Connect** API keys

### API Keys Rotation

Rotate production API keys:
- Every 90 days (minimum)
- After team member leaves
- If compromise suspected

---

## Rollback Procedure

If a critical bug is found in production:

1. **Immediate**:
   - Stop phased release (if active)
   - Remove from App Store (if critical)

2. **Short-term**:
   - Revert to last known good version
   - Submit emergency update
   - Request expedited review

3. **Communication**:
   - Notify users
   - Update status page
   - Post to support channels

---

## Contacts

**App Store Support**: https://developer.apple.com/contact/
**TestFlight Support**: https://developer.apple.com/testflight/
**Technical Support**: devops@financialtradingdimension.com

---

**Last Updated**: 2025-11-17
**Version**: 1.0
