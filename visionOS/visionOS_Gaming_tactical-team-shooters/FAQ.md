# Frequently Asked Questions

Common questions about Tactical Team Shooters development and gameplay.

## General

### What is Tactical Team Shooters?

A competitive 5v5 tactical shooter built exclusively for Apple Vision Pro, featuring hand gesture and eye tracking controls, realistic ballistics, and immersive spatial gameplay.

### What platforms does it support?

Currently only Apple Vision Pro running visionOS 2.0+. No plans for other platforms at this time.

### Is it free or paid?

Pricing TBD. Check the App Store listing for current pricing.

### When will it be released?

Targeting Q1 2025. Follow development on GitHub for updates.

## Development

### How can I contribute?

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed contribution guidelines.

### What technologies are used?

- Swift 6.0
- SwiftUI for UI
- RealityKit for 3D
- ARKit for spatial features
- MultipeerConnectivity for networking

### Can I run this on Mac/iPhone/iPad?

No, it's Vision Pro exclusive. The gameplay depends on spatial computing features not available on other devices.

### Do I need a Vision Pro to develop?

For basic development, you can use the visionOS Simulator. However, testing hand tracking, eye tracking, spatial audio, and performance requires a physical Vision Pro.

## Gameplay

### How do controls work?

- **Hand Gestures**: Weapon switching, reloading, grenade throwing
- **Eye Tracking**: Precision aiming
- **Voice**: Optional voice commands
- **Traditional**: Also supports controller if preferred

### What game modes are available?

- **Bomb Defusal**: Plant or defuse the bomb
- **Team Deathmatch**: First team to score limit wins
- **Control Point**: Capture and hold objectives (future)

### How does matchmaking work?

ELO-based matchmaking pairs players of similar skill levels. Competitive ranks range from Recruit to Legend.

### Is there single-player?

Currently multiplayer-focused. Single-player campaign may come in future updates.

### Can I play with bots?

Yes, bot matches available for practice. AI difficulty adjustable.

## Technical

### Why does it require visionOS 2.0+?

We use latest visionOS features for optimal performance and capabilities.

### What about performance?

Target is 120 FPS on Vision Pro. Performance tested and optimized for smooth gameplay.

### How much storage does it need?

Approximately 1-2GB download, 2-3GB installed.

### Does it work offline?

Multiplayer requires internet. Offline bot matches available.

### What about battery life?

Typical gameplay session: 2-3 hours on full charge.

## Multiplayer

### How many players per match?

5v5 (10 players total).

### Is voice chat included?

Spatial voice chat with 3D positioning coming in v1.1.

### How does networking work?

Client-server architecture with client-side prediction and lag compensation for responsive gameplay despite latency.

### What's the tick rate?

Server: 60Hz update rate
Client: 120Hz input rate

### Can I host my own server?

Not currently. All matches on official servers.

## Privacy & Security

### What data is collected?

See [PRIVACY_POLICY.md](PRIVACY_POLICY.md) for complete details.

Collected:
- Username
- Gameplay stats
- Match history

NOT collected:
- Biometric data
- Hand tracking data
- Eye tracking data
- Room scan data

### Is it safe for kids?

Rated 17+ due to realistic violence. Parental discretion advised.

### How is cheating prevented?

- Server-authoritative game state
- Input validation
- Anomaly detection
- Regular updates to anti-cheat

## Troubleshooting

### App won't launch

1. Restart Vision Pro
2. Check visionOS version (need 2.0+)
3. Reinstall app
4. See [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

### Hand gestures not working

1. Ensure adequate lighting
2. Keep hands in front of Vision Pro
3. Recalibrate in Settings
4. Remove gloves/obstructions

### Poor network performance

1. Check WiFi connection
2. Move closer to router
3. Close other apps using network
4. See network requirements (< 50ms latency ideal)

### Crashes or bugs

1. Update to latest version
2. Restart app
3. Report bug on GitHub with details
4. See [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

## Community

### Where can I get help?

- GitHub Discussions: Technical questions
- GitHub Issues: Bug reports
- Discord: Community chat (if available)
- Support email: support@tacticalsquad.com

### Can I stream/record gameplay?

Yes! Streaming and content creation encouraged. Please credit the game.

### Is there a competitive scene?

Competitive ranking system in-game. Official tournaments planned for future.

### How do I report toxic players?

In-game reporting system available. See Code of Conduct in [TERMS_OF_SERVICE.md](TERMS_OF_SERVICE.md).

## Development Questions

### How do I set up the development environment?

See [DEVELOPMENT_ENVIRONMENT.md](DEVELOPMENT_ENVIRONMENT.md) for complete setup guide.

### How do I run tests?

```bash
swift test
```

See [TESTING_STRATEGY.md](TESTING_STRATEGY.md) for details.

### How do I build for release?

See [DEPLOYMENT.md](DEPLOYMENT.md) for release process.

### Where's the documentation?

- [README.md](README.md) - Project overview
- [ARCHITECTURE.md](ARCHITECTURE.md) - Technical architecture
- [API_DOCUMENTATION.md](API_DOCUMENTATION.md) - API reference
- [CONTRIBUTING.md](CONTRIBUTING.md) - How to contribute

### Code style guidelines?

See [CODING_STANDARDS.md](CODING_STANDARDS.md).

## Future Plans

### What's on the roadmap?

See [ROADMAP.md](ROADMAP.md) for detailed plans.

Upcoming:
- Voice chat (v1.1)
- New maps (v1.1)
- Training mode (v2.0)
- Tournaments (v2.0)

### Will there be a battle pass?

Seasonal content planned for v1.2+.

### Cross-platform play?

No plans currently. Vision Pro exclusive focus.

### VR headset support?

No. Designed specifically for Vision Pro's unique capabilities.

## Still Have Questions?

- Check other documentation files
- Search GitHub Discussions
- Open new Discussion for questions
- Email: support@tacticalsquad.com

---

**Last Updated**: 2025-11-19
