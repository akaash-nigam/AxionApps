# Deployment Guide - Rhythm Flow

Complete guide for deploying Rhythm Flow to the App Store.

---

## 📋 Table of Contents

1. [Pre-Deployment Checklist](#pre-deployment-checklist)
2. [App Store Requirements](#app-store-requirements)
3. [Building for Release](#building-for-release)
4. [TestFlight Beta](#testflight-beta)
5. [App Store Submission](#app-store-submission)
6. [Post-Launch](#post-launch)
7. [Troubleshooting](#troubleshooting)

---

## ✅ Pre-Deployment Checklist

### Code Quality

- [ ] All tests passing (118+ tests)
- [ ] Code coverage ≥ 80%
- [ ] No compiler warnings
- [ ] No force unwraps in production code
- [ ] All TODO/FIXME items resolved or documented
- [ ] Performance targets met (90 FPS sustained)
- [ ] Memory usage < 2GB
- [ ] No memory leaks (tested with Instruments)

### Documentation

- [ ] README.md updated with current version
- [ ] CHANGELOG.md updated
- [ ] API documentation complete
- [ ] All comments up to date
- [ ] Privacy Policy finalized
- [ ] Terms of Service finalized

### Assets

- [ ] App icon (1024x1024 PNG)
- [ ] Screenshots for all required sizes
- [ ] Preview video (15-30 seconds)
- [ ] All audio files licensed and included
- [ ] All 3D models optimized
- [ ] All textures compressed

### Compliance

- [ ] Privacy Policy reviewed by legal
- [ ] Terms of Service reviewed
- [ ] Age rating determined (4+)
- [ ] Export compliance verified
- [ ] Accessibility features tested
- [ ] WCAG 2.1 Level AA compliance verified

---

## 📱 App Store Requirements

### Required Assets

#### App Icon

**Specifications**:
- Size: 1024x1024 pixels
- Format: PNG (no alpha channel)
- Color space: sRGB or P3
- No rounded corners (App Store adds them)

**Design Guidelines**:
- Simple, recognizable design
- Works at all sizes (from 20px to 1024px)
- No text (should be iconic)
- Unique and memorable

**Location**: `RhythmFlow/RhythmFlow/Resources/Assets.xcassets/AppIcon.appiconset/`

#### Screenshots

**Required Sizes for visionOS**:
- 3840 x 2160 (landscape)
- 2160 x 3840 (portrait)

**Quantity**: 3-10 screenshots

**Guidelines**:
- Show key features
- Include captions explaining features
- High quality, professional
- No device frames
- Actual gameplay footage

**Recommended Screenshots**:
1. Main menu with song selection
2. Gameplay action shot (notes approaching)
3. Combo/scoring highlight
4. Results screen with high score
5. Fitness tracking (if applicable)
6. Multiplayer (if applicable)

#### Preview Video

**Specifications**:
- Duration: 15-30 seconds
- Resolution: 1920x1080 or higher
- Format: MOV or MP4
- Max file size: 500 MB
- No audio required (optional)

**Content**:
- First 3 seconds are critical (auto-play)
- Show core gameplay loop
- Highlight unique features
- End with compelling call-to-action

### App Information

#### App Name
- **Primary**: "Rhythm Flow"
- **Subtitle**: "Spatial Rhythm Game" (30 chars max)
- **Bundle ID**: `com.beatspace.rhythmflow`

#### Category
- **Primary**: Games > Music
- **Secondary**: Health & Fitness (if fitness mode prominent)

#### Age Rating
- **Suggested**: 4+ (Everyone)
- **Mature Content**: None
- **Violence**: None
- **Gambling**: None

#### Keywords (100 chars max)
```
rhythm,music,visionos,spatial,fitness,beat,game,dance,immersive,3d
```

#### Description

**Short Description** (170 chars):
```
Transform your living room into a musical universe. Hit notes with natural hand movements in this revolutionary spatial rhythm game for Vision Pro.
```

**Full Description** (4000 chars max):
```
RHYTHM FLOW - The Future of Rhythm Gaming

Transform your living room into an immersive musical universe. Rhythm Flow is the first true spatial rhythm game for Apple Vision Pro, using natural hand tracking to create an unprecedented gaming experience.

KEY FEATURES

🖐️ NATURAL HAND TRACKING
No controllers needed. Use your hands naturally to punch, swipe, and dance through beats. Our advanced hand tracking technology makes every movement feel intuitive and responsive.

🎵 100+ SONGS
Diverse music library spanning multiple genres and difficulty levels. From electronic to classical, hip-hop to rock - there's something for everyone.

🤖 AI-POWERED GAMEPLAY
Dynamic difficulty adjustment learns your skill level and provides the perfect challenge. AI-generated beat maps ensure endless replayability.

💪 FITNESS INTEGRATION
Turn gaming into a workout. Track calories, monitor intensity, and achieve fitness goals while having fun. Full HealthKit integration.

👥 MULTIPLAYER
Challenge friends in real-time rhythm battles via SharePlay. Compete on global leaderboards or cooperate in team modes.

🎨 360° IMMERSIVE ENVIRONMENTS
Experience music in stunning 3D environments that react to the beat. Every song has unique visuals that surround you completely.

♿ ACCESSIBLE TO ALL
WCAG 2.1 Level AA compliant with multiple accessibility features including VoiceOver support, high contrast modes, adjustable difficulty, and seated play modes.

GAME MODES

• Campaign - Progress through curated playlists
• Practice - Perfect your technique
• Fitness - Turn gaming into exercise
• Multiplayer - Compete with friends
• Custom - Create and share beat maps

FEATURES

• 90 FPS ultra-smooth gameplay
• Spatial audio with HRTF rendering
• Player progression and unlockables
• Real-time combo multipliers
• Detailed statistics tracking
• Multiple difficulty levels
• Custom beat map creator

REQUIREMENTS

• Apple Vision Pro
• visionOS 2.0 or later
• 2GB free storage
• Play area: 2.5m x 2.5m recommended

Transform music into movement. Download Rhythm Flow today!
```

#### What's New (4000 chars max)

**Version 1.0**:
```
Welcome to Rhythm Flow!

This is our initial release featuring:

NEW FEATURES
• 100+ licensed songs across all genres
• Full hand tracking gameplay
• AI-powered beat map generation
• Fitness mode with HealthKit integration
• Global leaderboards
• 6 game modes

PERFORMANCE
• 90 FPS sustained gameplay
• Ultra-low latency input (<20ms)
• Optimized for Vision Pro

ACCESSIBILITY
• VoiceOver support throughout
• High contrast mode
• Adjustable timing windows
• Seated play mode
• Multiple difficulty levels

Thank you for playing Rhythm Flow!
```

#### Promotional Text (170 chars - updateable without review)
```
🎵 NEW: Holiday Music Pack! 20 festive songs now available. Transform your space into a winter wonderland while staying active!
```

---

## 🔨 Building for Release

### 1. Update Version Numbers

**In Xcode**:
1. Select RhythmFlow target
2. General tab
3. Identity section:
   - **Version**: `1.0.0` (user-facing)
   - **Build**: `1` (increment for each submission)

**Semantic Versioning**:
- Major.Minor.Patch (e.g., 1.0.0)
- Major: Breaking changes
- Minor: New features
- Patch: Bug fixes

### 2. Update Bundle Identifier

Ensure bundle ID matches App Store Connect:
```
com.beatspace.rhythmflow
```

### 3. Configure Code Signing

**Automatic Signing** (Recommended):
1. Select RhythmFlow target
2. Signing & Capabilities tab
3. Check "Automatically manage signing"
4. Select your Team
5. Xcode handles certificates and provisioning

**Manual Signing**:
1. Create App Store distribution certificate
2. Create App Store provisioning profile
3. Select profile in Xcode

### 4. Archive Build

```bash
# Clean build folder
xcodebuild clean \
  -project RhythmFlow/RhythmFlow.xcodeproj \
  -scheme RhythmFlow

# Create archive
xcodebuild archive \
  -project RhythmFlow/RhythmFlow.xcodeproj \
  -scheme RhythmFlow \
  -sdk xros \
  -configuration Release \
  -archivePath RhythmFlow.xcarchive
```

**In Xcode**:
1. Product → Archive
2. Wait for build to complete
3. Archive appears in Organizer

### 5. Validate Archive

**Before uploading**:
1. Open Organizer (Window → Organizer)
2. Select archive
3. Click "Validate App"
4. Choose distribution method: "App Store Connect"
5. Select signing options
6. Click "Validate"
7. Fix any issues reported

**Common Validation Issues**:
- Missing icons
- Invalid bundle ID
- Code signing issues
- Missing provisioning profile
- Invalid entitlements

### 6. Upload to App Store Connect

**Via Xcode**:
1. In Organizer, select validated archive
2. Click "Distribute App"
3. Choose "App Store Connect"
4. Click "Upload"
5. Wait for processing (10-30 minutes)

**Via Transporter App**:
1. Export IPA from Xcode
2. Open Transporter app
3. Drag IPA file
4. Click "Deliver"

---

## 🧪 TestFlight Beta

### 1. Set Up TestFlight

**In App Store Connect**:
1. Go to your app
2. TestFlight tab
3. Select build once processing completes
4. Add "What to Test" notes for testers

### 2. Internal Testing

**Add Internal Testers** (up to 100):
1. TestFlight → Internal Testing
2. Add testers (must have App Store Connect role)
3. Testers receive email invite
4. Available immediately after upload

**Internal Testing Checklist**:
- [ ] App launches successfully
- [ ] Hand tracking works
- [ ] Audio plays correctly
- [ ] No crashes
- [ ] Performance is acceptable
- [ ] UI renders correctly

### 3. External Testing

**Create External Test Group**:
1. TestFlight → External Testing
2. Create group (e.g., "Beta Testers")
3. Add testers via email or public link
4. Requires Beta App Review (1-2 days)

**External Testing Goals**:
- Test with 100-1000 users
- Gather feedback on gameplay
- Identify edge case bugs
- Validate performance on real hardware
- Collect crash logs and analytics

### 4. Gather Feedback

**Feedback Channels**:
- TestFlight feedback (in-app)
- Surveys (Google Forms, Typeform)
- Discord/community forums
- Email feedback
- Bug tracking (GitHub Issues)

**Key Metrics to Track**:
- Crash rate (target: <1%)
- Session length
- Retention (Day 1, Day 7, Day 30)
- Feature usage
- Performance metrics

### 5. Iterate Based on Feedback

**Beta Cycle**:
1. Release beta build
2. Collect feedback (1-2 weeks)
3. Fix critical issues
4. Release new beta build
5. Repeat until stable

**When to Stop Beta**:
- Crash rate < 1%
- No critical bugs
- Performance targets met
- Positive feedback from testers
- Feature complete

---

## 🚀 App Store Submission

### 1. Complete App Information

**In App Store Connect → App Information**:

- [ ] Name: "Rhythm Flow"
- [ ] Subtitle: "Spatial Rhythm Game"
- [ ] Privacy Policy URL: `https://yoursite.com/privacy`
- [ ] Category: Music
- [ ] License Agreement: Standard or Custom

### 2. Set Pricing

**Pricing Models**:

**Option A: Premium ($39.99)**
- One-time purchase
- All content included
- No ads, no IAP

**Option B: Freemium (Free + IAP)**
- Free base game (5 songs)
- Song packs: $4.99-$9.99
- Premium subscription: $9.99/month

**Option C: Subscription ($9.99/month)**
- Full access to all content
- New songs added monthly
- Fitness features

**Recommended**: Premium ($39.99) for launch

### 3. Prepare for Review

**App Review Information**:

**Contact Information**:
- First Name: [Your Name]
- Last Name: [Your Name]
- Email: [Your Email]
- Phone: [Your Phone]

**Demo Account** (if login required):
- Username: demo@rhythmflow.app
- Password: DemoPass123!

**Notes**:
```
Thank you for reviewing Rhythm Flow!

TESTING NOTES:
• Hand tracking works best in well-lit room
• Requires 2.5m x 2.5m play area
• Tutorial plays on first launch
• Demo song: "Neon Dreams" - Normal difficulty

ACCESSIBILITY FEATURES:
• VoiceOver enabled throughout app
• High contrast mode available in Settings
• Seated play mode available

If you encounter any issues, please contact: support@rhythmflow.app
```

**Attachments**:
- [ ] Demo video showing gameplay
- [ ] Screenshots of key features

### 4. Submit for Review

**Final Checklist**:
- [ ] All metadata complete
- [ ] Screenshots uploaded (3-10)
- [ ] Preview video uploaded
- [ ] App description compelling
- [ ] Keywords optimized
- [ ] Pricing set
- [ ] Availability regions selected
- [ ] Age rating confirmed
- [ ] Review notes provided
- [ ] Contact information accurate

**Submit**:
1. Click "Add for Review"
2. Select build version
3. Complete questionnaire:
   - Export compliance: No (or Yes if applicable)
   - Content rights: Yes
   - Advertising identifier: No
3. Click "Submit for Review"

### 5. Review Process

**Timeline**:
- Initial review: 24-48 hours
- Follow-up questions: 1-2 days
- Total: 3-7 days average

**Possible Outcomes**:

**Approved** ✅
- App goes live automatically (or on release date)
- Celebrate! 🎉

**Rejected** ❌
- Read rejection reason carefully
- Fix issues
- Respond to reviewer or resubmit
- Common reasons:
  - Crashes on launch
  - Missing features described in metadata
  - Privacy policy issues
  - Performance problems
  - Guideline violations

**Metadata Rejected** ⚠️
- App is okay, but metadata needs fixes
- Update screenshots, description, etc.
- No new build needed

---

## 📅 Launch Day

### 1. Pre-Launch (1 week before)

- [ ] Announce launch date on social media
- [ ] Send press releases to gaming media
- [ ] Prepare launch blog post
- [ ] Set up customer support channels
- [ ] Brief support team on FAQs
- [ ] Prepare social media content
- [ ] Contact influencers/reviewers

### 2. Launch Day

**Morning**:
- [ ] Verify app is live on App Store
- [ ] Test download and launch
- [ ] Post launch announcement
- [ ] Send email to mailing list
- [ ] Post on social media
- [ ] Submit to Product Hunt

**Throughout Day**:
- [ ] Monitor App Store reviews
- [ ] Respond to customer questions
- [ ] Track download numbers
- [ ] Monitor crash reports
- [ ] Watch social media mentions

**Evening**:
- [ ] Review day's metrics
- [ ] Plan next day's content
- [ ] Address any critical issues

### 3. Post-Launch (First Week)

**Daily Tasks**:
- Monitor reviews (respond within 24h)
- Check crash reports
- Track key metrics
- Engage with community
- Create content

**Key Metrics**:
- Downloads
- Daily/Monthly active users
- Retention rates
- Revenue (if paid)
- Crash rate
- Review rating

---

## 📊 Post-Launch

### Analytics Setup

**Recommended Tools**:
- App Store Connect Analytics (built-in)
- Firebase Analytics (optional)
- TestFlight metrics
- Custom in-app analytics (privacy-respecting)

**Key Metrics to Track**:
- Downloads
- Active users (DAU/MAU)
- Session length
- Retention (D1, D7, D30)
- Conversion rate (free to paid)
- Revenue per user
- Crash-free rate
- Review rating

### Update Cadence

**Version 1.1** (Month 2):
- Critical bug fixes
- Minor improvements
- User-requested features

**Version 1.2** (Month 3):
- New song pack
- Performance optimizations
- Quality of life improvements

**Version 2.0** (Month 6):
- Major new features
- Multiplayer enhancements
- New game modes

### App Store Optimization (ASO)

**Ongoing Tasks**:
- Update keywords based on search data
- A/B test screenshots
- Update promotional text monthly
- Respond to all reviews
- Encourage positive reviews
- Monitor competitor keywords

---

## 🔧 Troubleshooting

### Common Submission Issues

**"Invalid Bundle"**
- Verify bundle ID matches App Store Connect
- Check Info.plist for required keys
- Ensure all required icons present

**"Code Signing Error"**
- Verify certificate is valid
- Check provisioning profile
- Ensure no expired certificates

**"Missing Compliance"**
- Answer export compliance questions
- May need to submit CCATS form
- Consult legal if unsure

**"Guideline 2.1 - Performance: App Completeness"**
- Ensure app is feature-complete
- No placeholder content
- All buttons/features functional
- Provide demo account if needed

**"Guideline 2.3 - Performance: Accurate Metadata"**
- Screenshots match actual app
- Description matches functionality
- No misleading claims
- Keywords relevant

**"Guideline 4.0 - Design"**
- Follows Apple Human Interface Guidelines
- No unpolished UI elements
- Professional design quality

### Performance Issues

**Frame Rate < 90 FPS**:
1. Profile with Instruments
2. Check Time Profiler for hotspots
3. Optimize rendering pipeline
4. Reduce draw calls
5. Implement LOD system

**Memory Issues**:
1. Run Allocations instrument
2. Check for retain cycles
3. Verify object pooling working
4. Monitor texture memory
5. Implement background memory warnings

**Crash on Launch**:
1. Check crash logs in Organizer
2. Verify all resources present
3. Test on clean install
4. Check for missing permissions
5. Validate Info.plist

---

## 📞 Support Resources

- **App Store Connect Help**: https://developer.apple.com/support/app-store-connect/
- **App Review Guidelines**: https://developer.apple.com/app-store/review/guidelines/
- **Human Interface Guidelines**: https://developer.apple.com/design/human-interface-guidelines/
- **TestFlight Documentation**: https://developer.apple.com/testflight/
- **App Store Connect API**: https://developer.apple.com/app-store-connect/api/

---

## ✅ Final Checklist

**Before Submission**:
- [ ] All tests passing
- [ ] Code coverage ≥ 80%
- [ ] Performance targets met
- [ ] All assets optimized
- [ ] Metadata complete
- [ ] Screenshots professional
- [ ] Privacy Policy live
- [ ] Terms of Service live
- [ ] Support email set up
- [ ] Beta testing complete
- [ ] Legal review complete

**After Submission**:
- [ ] Monitor review status
- [ ] Prepare launch marketing
- [ ] Set up support channels
- [ ] Plan post-launch updates
- [ ] Thank beta testers

---

**Good luck with your App Store launch!** 🚀🎵

For questions, see [CONTRIBUTING.md](CONTRIBUTING.md) or open a [GitHub Issue](https://github.com/akaash-nigam/visionOS_Gaming_rhythm-flow/issues).
