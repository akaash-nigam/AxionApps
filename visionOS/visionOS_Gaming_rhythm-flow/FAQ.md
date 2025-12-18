# Frequently Asked Questions (FAQ)

Common questions about Rhythm Flow.

---

## 📋 Table of Contents

1. [General Questions](#general-questions)
2. [Gameplay](#gameplay)
3. [Technical](#technical)
4. [Compatibility](#compatibility)
5. [Pricing & Purchases](#pricing--purchases)
6. [Privacy & Data](#privacy--data)
7. [Troubleshooting](#troubleshooting)
8. [Development & Contributing](#development--contributing)

---

## General Questions

### What is Rhythm Flow?

Rhythm Flow is a revolutionary spatial rhythm game for Apple Vision Pro that uses natural hand movements to interact with music in 3D space. Unlike traditional rhythm games, you're fully immersed in a 360-degree musical universe.

### Is this game released yet?

Not yet! We're currently in pre-alpha development (v0.1.0). The project includes:
- ✅ Complete documentation
- ✅ Prototype code
- ✅ Comprehensive test suite
- ✅ Landing page

We're working toward an alpha release. Follow our [GitHub repository](https://github.com/akaash-nigam/visionOS_Gaming_rhythm-flow) for updates.

### When will Rhythm Flow be available?

We're following an 18-month development plan (see [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md)):
- **Months 1-3**: Alpha development
- **Months 4-6**: Beta testing
- **Months 7-18**: Production and polish
- **Month 18**: Target launch

### How can I try Rhythm Flow early?

We'll have a beta program via TestFlight! To get early access:
1. Watch our [GitHub repository](https://github.com/akaash-nigam/visionOS_Gaming_rhythm-flow)
2. Join our mailing list (coming soon)
3. Follow us on social media (coming soon)

### Is this an official Apple product?

No, Rhythm Flow is an independent game developed for the Apple Vision Pro platform. We use Apple's frameworks (RealityKit, ARKit) but are not affiliated with Apple Inc.

---

## Gameplay

### How do you play Rhythm Flow?

**Basic Controls**:
1. **Hand Tracking**: Use your hands naturally - no controllers needed
2. **Punch**: Quick forward jabs to hit notes
3. **Swipe**: Directional hand movements
4. **Hold**: Maintain hand position in streams

**Gameplay Loop**:
1. Select a song and difficulty
2. System calibrates hand tracking
3. Notes flow toward you to the beat
4. Hit them with the correct gesture and timing
5. Build combos for multipliers
6. Achieve high scores and unlock content

### Do I need controllers?

**No!** Rhythm Flow uses Apple Vision Pro's hand tracking exclusively. Just use your hands naturally. We also support:
- Game controller (optional)
- Head tracking (accessibility)
- Voice commands (accessibility)

### What music genres are available?

We plan to include diverse genres:
- Electronic / EDM
- Hip-Hop
- Rock / Alternative
- Pop
- Classical
- Jazz
- Synthwave
- World Music

**Launch target**: 100+ songs across all genres

### What difficulty levels are there?

Five difficulty levels:
- **Easy**: Beginners (slower notes, simpler patterns)
- **Normal**: Standard gameplay
- **Hard**: Experienced players (faster, complex patterns)
- **Expert**: Very challenging
- **Expert+**: Tournament/competitive level

Each song has beat maps for all difficulty levels.

### Can I create custom beat maps?

Yes! (Planned feature)
- Built-in beat map editor
- Import custom songs (within license limits)
- Share creations with community
- AI assistance for beat mapping

See [BEATMAP_SPEC.md](coming soon) for technical details.

### Is there multiplayer?

Yes! (Planned features)
- **SharePlay**: Real-time rhythm battles with friends
- **Asynchronous**: Compete on leaderboards
- **Co-op**: Team up for collaborative songs
- **Tournament**: Competitive ranked mode

### How does fitness mode work?

Fitness mode tracks your physical activity:
- Calorie burn estimation
- Workout duration
- Movement intensity
- Heart rate zones (if Apple Watch connected)
- Integration with Apple Health

You can play Rhythm Flow as a fun workout!

### What is the combo system?

Hit notes consecutively without missing to build combos:
- **10 combo**: 1.1x multiplier
- **25 combo**: 1.25x multiplier
- **50 combo**: 1.5x multiplier
- **100 combo**: 2.0x multiplier
- **200+ combo**: 2.5x multiplier

Missing resets your combo to 0.

### How is scoring calculated?

**Hit Quality**:
- **Perfect**: 115 points (100 base + 15% bonus)
- **Great**: 110 points (100 base + 10% bonus)
- **Good**: 105 points (100 base + 5% bonus)
- **Okay**: 100 points (base only)
- **Miss**: 0 points (resets combo)

**Final Score** = Base Points × Combo Multiplier

**Grades**: S, A, B, C, D, F (based on accuracy %)

---

## Technical

### What are the minimum requirements?

**Required**:
- Apple Vision Pro (1st generation or later)
- visionOS 2.0 or later
- 2GB free storage
- Well-lit room (for hand tracking)
- 2.5m x 2.5m play area (recommended)

**For Development**:
- macOS 14.0+ (Sonoma)
- Xcode 16.0+
- Apple Developer Account

### What frame rate does it run at?

**Target**: 90 FPS sustained

We've optimized for ultra-smooth gameplay with:
- < 11.1ms frame time
- Object pooling for efficiency
- Dynamic quality scaling
- Performance profiling

### How much space do I need to play?

**Recommended**: 2.5m x 2.5m (8ft x 8ft) clear space

**Minimum**: 2m x 2m (6ft x 6ft)

**Seated Mode**: Play while seated with reduced space requirements (accessibility feature)

The game adapts note placement to your available space.

### Does it work in the dark?

Hand tracking requires **adequate lighting**. Tips:
- Normal room lighting works fine
- Avoid direct sunlight (can interfere)
- Turn on lights if tracking feels off
- Vision Pro will warn if lighting is too dim

### How is the hand tracking accuracy?

We target **<20ms input latency** for responsive gameplay. The game uses Apple's ARKit hand tracking, which is:
- Highly accurate in good lighting
- Robust to different hand sizes
- Adaptive to movement speed

### Can I play sitting down?

**Yes!** Seated play mode is available:
- Notes appear within arm's reach
- No need to stand or move around
- Full game experience
- Accessibility feature

### What audio setup do I need?

**Built-in**: Vision Pro spatial audio works great!

**Enhanced**:
- AirPods Pro (3D audio)
- AirPods Max (best experience)
- Other headphones (stereo only)

We use HRTF spatial audio for immersive 3D sound.

---

## Compatibility

### Which devices are supported?

**Currently**:
- Apple Vision Pro (1st generation)
- visionOS 2.0 or later

**Future** (not confirmed):
- Future Vision Pro models
- Possibly other platforms

### Will there be an iPhone/iPad version?

Not at launch. We're focused on the Vision Pro experience. However, we're considering:
- iPhone AR mode (future)
- iPad companion app (beat map creator)
- Cross-platform progression

### Can I use my Apple Watch?

Yes! (Planned integration)
- Heart rate monitoring
- Calorie tracking
- Workout sessions
- Activity rings
- Achievements unlocked on Watch

### Does it support game controllers?

Yes! (Optional)
- Xbox Wireless Controller
- PlayStation DualSense
- MFi game controllers

However, hand tracking is the primary input method and provides the best experience.

---

## Pricing & Purchases

### How much will it cost?

**Not yet announced.** Considering:

**Option A**: Premium ($39.99)
- One-time purchase
- All content included
- No ads, no subscriptions

**Option B**: Freemium
- Free base game (5 songs)
- Song packs: $4.99-$9.99
- Optional subscription: $9.99/month

We'll announce pricing closer to launch.

### Will there be in-app purchases?

Possibly. Options being considered:
- Song packs
- Visual themes
- Special events
- Premium subscription

**No pay-to-win mechanics** - purchases are cosmetic or content-focused.

### Will there be ads?

**No.** We're committed to an ad-free experience.

### Is there a free trial?

We're considering:
- Free demo with 3-5 songs
- TestFlight beta (free during testing)
- Free weekend events

Details TBD closer to launch.

---

## Privacy & Data

### What data does Rhythm Flow collect?

**Locally Stored Only**:
- Your scores and progress
- Game settings
- Player profile

**Optional**:
- Fitness data (if you enable HealthKit)
- Anonymous analytics (opt-in only)
- Leaderboard username (if you participate)

**We DO NOT collect**:
- Personal information
- Location data
- Contacts
- Photos
- Hand tracking data (processed locally only)

See [PRIVACY_POLICY.md](PRIVACY_POLICY.md) for complete details.

### Is my hand tracking data sent anywhere?

**No.** Hand tracking is processed entirely **on-device** by Apple's ARKit. We never capture, store, or transmit hand tracking data.

### Do you sell my data?

**Absolutely not.** We will never sell your personal data to third parties.

### Is it GDPR/CCPA compliant?

**Yes.** We're committed to:
- GDPR compliance (EU users)
- CCPA compliance (California users)
- COPPA compliance (users under 13)

You have full control over your data with rights to access, delete, and export.

### Can I play offline?

**Yes!** (For solo modes)
- All songs playable offline
- Progress saved locally
- No internet required

**Internet required for**:
- Multiplayer
- Leaderboards
- Downloading new content
- Online features

---

## Troubleshooting

### Hand tracking isn't working well

**Try**:
1. Improve lighting (turn on room lights)
2. Move away from windows (avoid direct sunlight)
3. Clear play area of obstructions
4. Re-calibrate in Settings
5. Clean Vision Pro cameras
6. Restart the app

### The game is laggy

**Performance tips**:
1. Close other apps
2. Restart Vision Pro
3. Lower graphics quality (Settings)
4. Ensure 2GB free storage
5. Check for software updates

If issues persist, see [TROUBLESHOOTING.md](coming soon).

### Audio is out of sync

**Solutions**:
1. Restart the song
2. Check audio latency settings
3. Try different audio output
4. Restart the app
5. Report the issue (with song name and difficulty)

Target audio sync: ±2ms

### Notes are spawning incorrectly

**Check**:
1. Play area is clear
2. Standing in center of play space
3. Room has adequate space (2.5m x 2.5m)
4. Beat map file is valid

If problem persists, it may be a beat map bug - please report!

### App crashes on launch

1. Restart Vision Pro
2. Check for updates (app and visionOS)
3. Reinstall the app
4. Check crash logs and report issue

See [GitHub Issues](https://github.com/akaash-nigam/visionOS_Gaming_rhythm-flow/issues) to report.

### Can't connect to leaderboards

1. Check internet connection
2. Verify App Store account is signed in
3. Check server status (website)
4. Try again later

---

## Development & Contributing

### Can I contribute to Rhythm Flow?

**Yes!** We welcome contributions:
- Code improvements
- Bug reports
- Documentation
- Beat map creation
- Translations

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### How do I report a bug?

1. Check [existing issues](https://github.com/akaash-nigam/visionOS_Gaming_rhythm-flow/issues)
2. Create a new issue using the [bug report template](.github/ISSUE_TEMPLATE/bug_report.md)
3. Include:
   - Device info
   - Steps to reproduce
   - Expected vs actual behavior
   - Screenshots/videos if possible

### How do I request a feature?

1. Check [existing feature requests](https://github.com/akaash-nigam/visionOS_Gaming_rhythm-flow/issues?q=is%3Aissue+label%3Aenhancement)
2. Create a new issue using the [feature request template](.github/ISSUE_TEMPLATE/feature_request.md)
3. Describe the feature and why it would be valuable

### Is the source code available?

**Yes!** Rhythm Flow is being developed openly:
- [GitHub Repository](https://github.com/akaash-nigam/visionOS_Gaming_rhythm-flow)
- License: TBD (likely MIT or similar)
- Contributions welcome

### How can I run the project locally?

See [README.md](README.md#-getting-started) for setup instructions:
1. Clone the repository
2. Open in Xcode 16.0+
3. Build for Vision Pro Simulator or device
4. See documentation for details

### What tech stack does it use?

- **Language**: Swift 6.0
- **UI**: SwiftUI
- **3D**: RealityKit 4.0+
- **AR**: ARKit 6.0
- **Audio**: AVAudioEngine
- **Platform**: visionOS 2.0+

See [TECHNICAL_SPEC.md](TECHNICAL_SPEC.md) for complete details.

### Can I create beat maps for the game?

**Yes!** (When beat map creator is ready)
- Use built-in editor
- Or create JSON files manually
- Submit via community hub
- See [BEATMAP_SPEC.md](coming soon)

### How do I become a beta tester?

**Beta program details coming soon!**

We'll announce via:
- GitHub repository
- Mailing list
- Social media

Beta will likely be via TestFlight (100-1000 testers).

---

## Still Have Questions?

### Contact Us

- **GitHub Issues**: [Report bugs or request features](https://github.com/akaash-nigam/visionOS_Gaming_rhythm-flow/issues)
- **GitHub Discussions**: [Ask questions](https://github.com/akaash-nigam/visionOS_Gaming_rhythm-flow/discussions)
- **Email**: [Coming soon]
- **Discord**: [Coming soon]
- **Twitter**: [Coming soon]

### Documentation

- [README.md](README.md) - Project overview
- [ARCHITECTURE.md](ARCHITECTURE.md) - Technical details
- [CONTRIBUTING.md](CONTRIBUTING.md) - How to contribute
- [PRIVACY_POLICY.md](PRIVACY_POLICY.md) - Privacy information
- [SECURITY.md](SECURITY.md) - Security policy

---

**Last Updated**: 2024

This FAQ will be updated regularly as development progresses and we receive more questions from the community.

**Have a question not answered here?** [Open an issue](https://github.com/akaash-nigam/visionOS_Gaming_rhythm-flow/issues/new) and we'll add it!
