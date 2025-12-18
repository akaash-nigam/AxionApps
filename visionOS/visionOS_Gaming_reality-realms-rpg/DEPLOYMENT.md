# Deployment Guide - Reality Realms RPG

Complete guide for deploying Reality Realms RPG to the Apple App Store.

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Pre-Deployment Checklist](#pre-deployment-checklist)
- [App Store Connect Setup](#app-store-connect-setup)
- [Build Configuration](#build-configuration)
- [TestFlight Beta Testing](#testflight-beta-testing)
- [App Review Preparation](#app-review-preparation)
- [Submission Process](#submission-process)
- [Post-Release](#post-release)
- [Troubleshooting](#troubleshooting)

## 🔑 Prerequisites

### Required Accounts
- ✅ Apple Developer Program membership ($99/year)
- ✅ App Store Connect access
- ✅ CloudKit entitlement enabled
- ✅ SharePlay entitlement enabled

### Required Tools
- ✅ Xcode 16.0 or later
- ✅ macOS Sonoma 14.0 or later
- ✅ Apple Vision Pro (for final testing)
- ✅ Fastlane (optional, for automation)

### Required Certificates
- ✅ iOS Distribution Certificate
- ✅ App Store Provisioning Profile
- ✅ CloudKit Container
- ✅ SharePlay entitlement

## ✅ Pre-Deployment Checklist

### Code Quality
- [ ] All unit tests pass (49 tests)
- [ ] All integration tests pass (10 tests)
- [ ] All performance tests pass (12 tests)
- [ ] Code coverage ≥ 95%
- [ ] SwiftLint shows no errors
- [ ] No compiler warnings
- [ ] No force unwraps in production code
- [ ] All TODOs resolved or documented

### Testing
- [ ] Tested on visionOS Simulator
- [ ] Tested on Apple Vision Pro device
- [ ] All accessibility features tested
- [ ] Spatial features validated
- [ ] Multiplayer tested with SharePlay
- [ ] Performance validated (90 FPS)
- [ ] Memory usage < 4GB
- [ ] No crashes in 4+ hour session
- [ ] Battery life acceptable (2+ hours)
- [ ] Thermal performance acceptable

### Content
- [ ] All assets optimized
- [ ] All strings localized
- [ ] Privacy policy updated
- [ ] Terms of service finalized
- [ ] App Store screenshots prepared
- [ ] App preview video created
- [ ] App description written
- [ ] Keywords researched
- [ ] Support URL active
- [ ] Marketing URL active

### Legal & Privacy
- [ ] Privacy policy published
- [ ] Terms of service published
- [ ] COPPA compliance verified (13+)
- [ ] GDPR compliance verified
- [ ] CCPA compliance verified
- [ ] Privacy manifest created
- [ ] Data collection documented
- [ ] Third-party SDKs documented (none)

## 🏪 App Store Connect Setup

### 1. Create App Record

```bash
# Navigate to App Store Connect
https://appstoreconnect.apple.com

# Apps > + > New App
```

**App Information**:
- **Name**: Reality Realms RPG
- **Primary Language**: English (U.S.)
- **Bundle ID**: com.yourcompany.realityrealms
- **SKU**: REALITYREALMS-001
- **User Access**: Full Access

### 2. Configure App Information

**Category**:
- **Primary**: Games
- **Secondary**: Role-Playing

**Age Rating**:
- **Rating**: 13+ (Fantasy Violence, Mild Suggestive Themes)

**Platforms**:
- **visionOS**: 2.0 or later
- **Devices**: Apple Vision Pro

### 3. Pricing and Availability

**Price**:
- **Price Tier**: $29.99 USD (Tier 30)
- **Availability**: All territories
- **Pre-order**: Optional (2-180 days before release)

**In-App Purchases** (Future):
- Cosmetic items
- Character slots
- Expansion packs

### 4. App Privacy

**Privacy Policy URL**: https://realityrealms.example.com/privacy

**Data Collection**:
```
Data Types Collected:
- Game Progress (not linked to user)
- Crash Data (opt-in, not linked to user)
- Analytics (opt-in, not linked to user)

Data NOT Collected:
- Personal Information
- Location
- Contacts
- Photos
- Camera Data (used only for room mapping, not stored)
- Hand Tracking Data (processed on-device, not stored)
- Eye Tracking Data (processed on-device, not stored)
```

### 5. App Information

**Name**: Reality Realms RPG

**Subtitle**: Your Home. Your Adventure.

**Description**:
```
Transform your living space into an epic fantasy RPG adventure with Reality
Realms RPG, the groundbreaking mixed reality game exclusively for Apple Vision Pro.

YOUR HOME IS YOUR REALM
Scan your room and watch as your furniture becomes part of the game world.
Tables become treasure chests, chairs become NPCs, and your entire living
space transforms into a persistent fantasy realm.

NATURAL INTERACTIONS
- Swing your hand to attack with swords
- Draw magical symbols to cast spells
- Look at targets to aim
- Speak commands to interact

DEEP RPG SYSTEMS
- 4 Character Classes: Warrior, Mage, Rogue, Ranger
- 50 Levels of progression
- Hundreds of spells and abilities
- Rich loot and equipment system
- Engaging quest storylines

PLAY WITH FRIENDS
- SharePlay integration for remote multiplayer
- Visit friends' realms through magical portals
- Cooperative combat and questing
- Spatial voice chat

ACCESSIBILITY FOR ALL
- Colorblind modes (4 types)
- One-handed play mode
- Seated play option
- Adjustable difficulty (Story to Nightmare)
- Comprehensive subtitles
- And much more...

PLATFORM EXCLUSIVE
Built exclusively for Apple Vision Pro, Reality Realms RPG showcases the
future of spatial gaming with cutting-edge hand tracking, eye tracking,
and room-scale gameplay.

Experience the future of RPGs. Your legend begins at home.

Requires:
- Apple Vision Pro
- visionOS 2.0 or later
- 2m x 2m play space (minimum)
- 5GB storage
```

**Keywords**:
```
RPG, fantasy, mixed reality, spatial gaming, adventure, multiplayer,
hand tracking, Vision Pro, AR game, role-playing
```

**Support URL**: https://realityrealms.example.com/support

**Marketing URL**: https://realityrealms.example.com

## 🔧 Build Configuration

### 1. Update Version Numbers

**In Xcode**:
```
Target > General
- Version: 1.0.0
- Build: 1

# Or in Info.plist:
CFBundleShortVersionString = 1.0.0
CFBundleVersion = 1
```

### 2. Set Release Configuration

```
Product > Scheme > Edit Scheme
- Run > Build Configuration > Release
- Archive > Build Configuration > Release
```

### 3. Optimize Build Settings

```swift
// Build Settings
SWIFT_OPTIMIZATION_LEVEL = -O
SWIFT_COMPILATION_MODE = wholemodule
ENABLE_BITCODE = NO (visionOS doesn't support bitcode)
VALIDATE_PRODUCT = YES
STRIP_INSTALLED_PRODUCT = YES
```

### 4. Configure Signing

```
Target > Signing & Capabilities
- Automatically manage signing: ✓
- Team: [Your Team]
- Provisioning Profile: App Store
```

### 5. Add Required Entitlements

```xml
<!-- Entitlements -->
<key>com.apple.developer.kernel.extended-virtual-addressing</key>
<true/>
<key>com.apple.developer.arkit.worldsensing</key>
<true/>
<key>com.apple.developer.group-session</key>
<true/>
<key>com.apple.developer.icloud-container-identifiers</key>
<array>
    <string>iCloud.com.yourcompany.realityrealms</string>
</array>
```

### 6. Privacy Manifest

Create `PrivacyInfo.xcprivacy`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSPrivacyTracking</key>
    <false/>
    <key>NSPrivacyTrackingDomains</key>
    <array/>
    <key>NSPrivacyCollectedDataTypes</key>
    <array/>
    <key>NSPrivacyAccessedAPITypes</key>
    <array>
        <dict>
            <key>NSPrivacyAccessedAPIType</key>
            <string>NSPrivacyAccessedAPICategoryWorldSensing</string>
            <key>NSPrivacyAccessedAPITypeReasons</key>
            <array>
                <string>For room-scale gameplay and furniture detection</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
```

## 📱 TestFlight Beta Testing

### 1. Create Archive

```bash
# In Xcode
Product > Archive

# Wait for archive to complete
# Organizer window opens automatically
```

### 2. Upload to App Store Connect

```
Organizer > Distribute App
- Method: App Store Connect
- Destination: Upload
- Include bitcode: NO
- Upload symbols: YES
- Manage Version and Build Number: Automatic
```

### 3. Configure TestFlight

**Internal Testing**:
- Add internal testers (up to 100)
- No App Review required
- Builds available immediately

**External Testing**:
- Add external testers (up to 10,000)
- Requires App Review (first build only)
- Provide testing notes
- Test duration: up to 90 days

### 4. Beta Testing Checklist

- [ ] Internal testing (1 week minimum)
- [ ] External testing (2 weeks minimum)
- [ ] Collect feedback via TestFlight
- [ ] Monitor crash reports
- [ ] Track performance metrics
- [ ] Fix critical bugs
- [ ] Update build if needed

## 📋 App Review Preparation

### 1. App Review Information

**Contact Information**:
- First Name: [Your Name]
- Last Name: [Your Name]
- Phone: [Your Phone]
- Email: [Your Email]

**Demo Account** (if applicable):
- Username: demo@realityrealms.example.com
- Password: [Secure password]
- Notes: Full access demo account

### 2. Review Notes

```
Dear App Review Team,

Reality Realms RPG is a mixed reality RPG game for Apple Vision Pro.

SETUP REQUIREMENTS:
- Apple Vision Pro device required
- Minimum 2m x 2m play space
- Room with furniture (tables, chairs) for best experience
- Good lighting for hand tracking

TESTING INSTRUCTIONS:
1. Complete room scanning tutorial (2-3 minutes)
2. Create character (choose any class)
3. Complete combat tutorial
4. Explore your transformed living room
5. Try multiplayer via SharePlay (optional)

KEY FEATURES TO TEST:
- Hand gesture combat (swing to attack)
- Spell casting (draw symbols)
- Furniture interaction (tables become chests)
- Spatial audio
- Eye tracking for targeting
- Accessibility options in Settings

MULTIPLAYER:
- SharePlay integration for remote co-op
- Requires two Vision Pro devices for testing
- Can be skipped for basic review

PRIVACY:
- No personal data collected
- Room maps stored locally only
- Hand/eye tracking processed on-device, never stored
- Full privacy manifest included

Thank you for your review!
```

### 3. App Store Screenshots

**Required Sizes** (visionOS):
- 2880 x 2048 px (portrait)
- 2048 x 2880 px (landscape)

**Screenshot Content**:
1. Hero shot: Player in living room with magical UI
2. Combat: Sword swinging at enemy
3. Magic: Spell casting with hand gestures
4. Furniture: Table transformed into treasure chest
5. Character: Stats and equipment screen
6. Multiplayer: Two players fighting together

### 4. App Preview Video

**Specifications**:
- Length: 15-30 seconds
- Resolution: 1920x1080 minimum
- Format: .mov, .m4v, or .mp4
- Content: Gameplay highlights

**Video Structure**:
1. (0-5s) Opening: Logo and tagline
2. (5-15s) Gameplay: Room scanning, combat
3. (15-25s) Features: Magic, multiplayer
4. (25-30s) Closing: Call to action

## 🚀 Submission Process

### 1. Final Checklist

- [ ] All TestFlight testing complete
- [ ] Critical bugs fixed
- [ ] Screenshots uploaded
- [ ] App preview video uploaded
- [ ] Description finalized
- [ ] Keywords optimized
- [ ] Support URL active
- [ ] Privacy policy published
- [ ] Review notes written
- [ ] Demo account created

### 2. Submit for Review

```
App Store Connect > My Apps > Reality Realms RPG
Version > Submit for Review
```

### 3. Review Timeline

- **Typical Review Time**: 24-48 hours
- **Complex Apps**: 3-5 days
- **Holiday Periods**: 5-7 days

### 4. Possible Review Outcomes

**Approved** ✅
- App goes live automatically (or on scheduled date)
- Notify users
- Monitor metrics

**Rejected** ❌
- Read rejection reason carefully
- Fix issues
- Resubmit

**In Review** 🔄
- Wait for completion
- Monitor status

**Metadata Rejected** ⚠️
- Fix screenshots/description
- No code changes needed
- Quick resubmission

## 📊 Post-Release

### 1. Launch Day

- [ ] Monitor crash reports
- [ ] Check reviews
- [ ] Monitor social media
- [ ] Track downloads
- [ ] Respond to support requests
- [ ] Update marketing materials

### 2. Ongoing Maintenance

**Weekly**:
- Review crash reports
- Respond to user reviews
- Monitor analytics
- Check support queue

**Monthly**:
- Analyze user metrics
- Plan updates
- Review feature requests
- Update documentation

**Quarterly**:
- Major feature updates
- Performance optimization
- Security audits

### 3. Update Process

**Version Numbering**:
- **Major (x.0.0)**: Breaking changes, major features
- **Minor (1.x.0)**: New features, improvements
- **Patch (1.0.x)**: Bug fixes only

**Update Checklist**:
- [ ] Increment version number
- [ ] Update CHANGELOG.md
- [ ] Test thoroughly
- [ ] Create release build
- [ ] Upload to TestFlight
- [ ] Beta test update
- [ ] Submit for review
- [ ] Write release notes

## 🔧 Troubleshooting

### Common Issues

**"Archive Failed"**
- Check for compiler errors
- Verify all targets build
- Clean build folder (⇧⌘K)
- Delete DerivedData

**"Upload Failed"**
- Check internet connection
- Verify certificates are valid
- Regenerate provisioning profile
- Try uploading from Organizer

**"Invalid Bundle"**
- Check version numbers match
- Verify Info.plist is correct
- Ensure all icons included
- Check for unsupported frameworks

**"Missing Compliance"**
- Complete export compliance in App Store Connect
- Declare encryption usage
- Add NSAppTransportSecurity if needed

### App Review Rejections

**Guideline 2.1 - Performance**
- Fix crashes
- Reduce memory usage
- Improve responsiveness
- Test on actual device

**Guideline 4.3 - Design**
- Ensure unique gameplay
- Avoid spam/duplicates
- Provide meaningful content

**Guideline 5.1.1 - Privacy**
- Update privacy policy
- Add privacy manifest
- Declare data collection
- Explain permissions

### Getting Help

- **Apple Developer Forums**: https://developer.apple.com/forums/
- **App Store Connect Help**: https://help.apple.com/app-store-connect/
- **DTS (Technical Support)**: Submit tech support request
- **App Review**: Use Resolution Center for questions

## 📞 Emergency Procedures

### Critical Bug Post-Launch

1. **Assess Severity**: Is it crashing? Data loss? Security issue?
2. **Expedited Review**: Contact Apple if critical
3. **Hotfix Process**:
   - Create fix immediately
   - Test thoroughly
   - Submit with "Critical Bug Fix" note
   - Request expedited review

### Pull App from Store

Only in extreme cases:
1. Contact Apple immediately
2. Remove from sale in App Store Connect
3. Issue public statement
4. Fix issue
5. Resubmit

## 📚 Resources

- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [visionOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/visionos)
- [Fastlane Documentation](https://docs.fastlane.tools/)

---

**Last Updated**: 2025-11-19
**Version**: 1.0.0

**Good luck with your launch! 🚀**
