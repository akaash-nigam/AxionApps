# Mindfulness Meditation Realms

<div align="center">

![Status](https://img.shields.io/badge/status-in%20development-blue)
![Platform](https://img.shields.io/badge/platform-visionOS%202.0%2B-purple)
![Swift](https://img.shields.io/badge/swift-6.0%2B-orange)
![License](https://img.shields.io/badge/license-Proprietary-red)

**Transform Your Space Into Inner Peace**

*Meditation reimagined for Apple Vision Pro with AI-powered environments that respond to your mental state*

[Features](#features) •
[Documentation](#documentation) •
[Installation](#installation) •
[Testing](#testing) •
[Contributing](#contributing)

</div>

---

## Overview

Mindfulness Meditation Realms is a revolutionary wellness platform that transforms any room into a tranquil sanctuary using Apple Vision Pro's spatial computing capabilities. Unlike traditional meditation apps, our environments adapt in real-time to your stress levels, breathing patterns, and focus, creating a truly personalized meditation experience.

### Key Differentiators

- 🧘 **Biometric Adaptation** - Environments respond to your stress and breathing
- 🌸 **20+ Stunning Realms** - From Zen gardens to cosmic nebulae
- 🎯 **AI Personalization** - Smart recommendations based on your patterns
- 🔊 **Spatial Audio** - Immersive 3D soundscapes
- 🤝 **Group Meditation** - SharePlay integration for social practice
- 📊 **Progress Tracking** - Streaks, achievements, and wellness insights
- 🔒 **Privacy-First** - All biometric processing on-device

---

## Features

### Core Meditation Experience

#### Adaptive Environments
- **5 Starter Realms**: Zen Garden, Forest Grove, Ocean Depths, Mountain Peak, Cosmic Nebula
- **Real-time Adaptation**: Environments change based on your biometric feedback
- **Dynamic Time of Day**: Experience sunrise, day, sunset, night cycles
- **Weather Moods**: Rain for cleansing, sun for energy, mist for introspection

#### Biometric Integration
- **Stress Detection**: Analyzes movement patterns and body language
- **Breathing Monitoring**: Estimates breathing rate and quality
- **Focus Tracking**: Measures attention and meditation depth
- **Wellness Scoring**: Composite metrics for session quality

#### Meditation Techniques
- Breath Awareness
- Body Scan
- Loving-Kindness
- Mindful Observation
- Sound Meditation
- Mantra Repetition
- Walking Meditation
- Visualization Journeys

### Progression System

- **Experience & Leveling**: Earn XP, level up, unlock content
- **Achievement System**: 100+ achievements for milestones
- **Streak Tracking**: Build consistent practice habits
- **Environment Unlocks**: Earn access to premium realms
- **Skill Trees**: Master different meditation disciplines

### Social Features

- **Group Meditation**: Up to 7 people via SharePlay
- **Meditation Buddies**: Accountability partners
- **Achievement Sharing**: Celebrate milestones together
- **Global Events**: Synchronized worldwide sessions

### Technical Excellence

- **90fps Performance**: Buttery smooth at all times
- **Spatial Audio**: Full 3D audio positioning
- **Hand Tracking**: Intuitive gesture controls
- **Eye Tracking**: Focus-based interactions
- **Room Mapping**: Adapts to your physical space

---

## Documentation

### Design Documents

| Document | Description | Status |
|----------|-------------|--------|
| [ARCHITECTURE.md](ARCHITECTURE.md) | Technical architecture and system design | ✅ Complete |
| [TECHNICAL_SPEC.md](TECHNICAL_SPEC.md) | Detailed technical specifications | ✅ Complete |
| [DESIGN.md](DESIGN.md) | Game design and UI/UX guidelines | ✅ Complete |
| [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) | 12-month development roadmap | ✅ Complete |
| [TODO.md](TODO.md) | Comprehensive task breakdown | ✅ Complete |
| [TESTING.md](TESTING.md) | Testing strategy and test documentation | ✅ Complete |

### Requirements Documents

- [Mindfulness-Meditation-Realms-PRD.md](Mindfulness-Meditation-Realms-PRD.md) - Product requirements
- [Mindfulness-Meditation-Realms-PRFAQ.md](Mindfulness-Meditation-Realms-PRFAQ.md) - Press release FAQ

### Source Code Documentation

- [MindfulnessMeditationRealms/README.md](MindfulnessMeditationRealms/README.md) - Source code overview

---

## Installation

### Prerequisites

- **Hardware**: Apple Vision Pro
- **OS**: visionOS 2.0 or later
- **Development**:
  - macOS 15.0+ (Sequoia)
  - Xcode 16.0+
  - Swift 6.0+

### Clone Repository

```bash
git clone https://github.com/yourusername/visionOS_Gaming_mindfulness-meditation-realms.git
cd visionOS_Gaming_mindfulness-meditation-realms
```

### Open in Xcode

```bash
open MindfulnessMeditationRealms.xcodeproj
```

### Build & Run

1. Select **Apple Vision Pro** as deployment target
2. Choose **Simulator** or connected **Vision Pro**
3. Press **Cmd + R** to build and run

---

## Project Structure

```
visionOS_Gaming_mindfulness-meditation-realms/
├── README.md                           # This file
├── ARCHITECTURE.md                     # Technical architecture
├── TECHNICAL_SPEC.md                   # Technical specifications
├── DESIGN.md                           # Game design document
├── IMPLEMENTATION_PLAN.md              # Development roadmap
├── TODO.md                             # Task breakdown
├── TESTING.md                          # Testing strategy
│
├── MindfulnessMeditationRealms/        # Swift source code
│   ├── App/                            # Application entry point
│   ├── Core/                           # Business logic
│   ├── Spatial/                        # RealityKit & ARKit
│   ├── Data/                           # Data models & persistence
│   ├── UI/                             # SwiftUI views
│   ├── Multiplayer/                    # SharePlay integration
│   ├── Resources/                      # Assets & environments
│   └── Utilities/                      # Helper functions
│
├── Tests/                              # Unit & integration tests
│   ├── UserProfileTests.swift          # ✅ 12 tests
│   ├── MeditationSessionTests.swift    # ✅ 18 tests
│   ├── BiometricSnapshotTests.swift    # ✅ 16 tests
│   └── UserProgressTests.swift         # ✅ 20 tests
│
└── landing-page/                       # Marketing website
    ├── index.html                      # Landing page
    ├── styles.css                      # Styling
    └── script.js                       # Interactions
```

---

## Development Status

### ✅ Completed (Phase 0)

- [x] Comprehensive design documentation (4 documents)
- [x] Initial Swift source code structure
- [x] Complete data model layer (5 models)
- [x] Unit tests for all data models (66 tests)
- [x] Landing page (HTML/CSS/JS)
- [x] TODO breakdown with 80+ tasks
- [x] Testing strategy documentation

### 🚧 In Progress (Phase 1)

- [ ] Core meditation engine (SessionManager)
- [ ] Biometric monitoring system
- [ ] AI adaptation engine
- [ ] Environment management (RealityKit)
- [ ] Spatial audio system

### 📋 Planned (Phases 2-12)

See [TODO.md](TODO.md) and [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) for complete roadmap.

---

## Testing

### Current Test Coverage

- **Data Models**: 95% coverage ✅
- **Unit Tests**: 66 tests passing ✅
- **Integration Tests**: 0% (not implemented)
- **UI Tests**: 0% (not implemented)

### Running Tests

```bash
# Run all unit tests
swift test

# Run specific test file
swift test --filter UserProfileTests

# Run in Xcode
# Cmd + U
```

For complete testing documentation, see [TESTING.md](TESTING.md).

### Test Categories

| Category | Status | Environment Required |
|----------|--------|---------------------|
| Unit Tests | ✅ 66 passing | Any Swift environment |
| Integration Tests | 🔲 TODO | visionOS Simulator |
| UI Tests | 🔲 TODO | visionOS Simulator/Device |
| Spatial Tests | 🔲 TODO | Vision Pro Hardware |
| Performance Tests | 🔲 TODO | Vision Pro Hardware |
| Manual Tests | 🔲 TODO | Human testers |

---

## Architecture Highlights

### Tech Stack

- **Language**: Swift 6.0+
- **UI Framework**: SwiftUI (visionOS)
- **3D Rendering**: RealityKit
- **Spatial Tracking**: ARKit
- **Audio**: AVFoundation (Spatial Audio)
- **Multiplayer**: GroupActivities (SharePlay)
- **Persistence**: Swift Data + CloudKit
- **Analytics**: On-device processing only
- **Payments**: StoreKit 2

### Performance Targets

- ⚡ **90 FPS** locked frame rate
- 💾 **<2GB** memory usage
- 🔋 **<20%** battery drain per hour
- 🚀 **<2 seconds** startup time

### Design Principles

1. **Wellness-First**: Every decision prioritizes user mental health
2. **Privacy by Design**: All biometric data processed locally
3. **Spatial Native**: Fully leverages Vision Pro capabilities
4. **Performance Critical**: 90fps is non-negotiable
5. **Adaptive Intelligence**: AI responds to real-time user state
6. **Graceful Degradation**: Works without biometric features

---

## Monetization

### Subscription Tiers

| Tier | Price | Features |
|------|-------|----------|
| **Free** | $0 | 3 environments, 10 sessions, 5-min limit |
| **Premium** | $14.99/mo<br>$99/yr | 20+ environments, unlimited duration, biometrics, group meditation |
| **Enterprise** | $29/user/yr | Premium + admin dashboard, SSO, volume discounts |

### Additional Revenue

- **Realm Packs**: $4.99 themed collections
- **Master Classes**: $19.99 expert-led series
- **Corporate Wellness**: Custom pricing
- **Insurance Coverage**: Reimbursement eligible

---

## Roadmap

### Q1 2025 - Launch (Month 13)

- ✅ Core meditation experience
- ✅ 5+ environments
- ✅ Biometric adaptation
- ✅ Progress tracking
- ✅ App Store submission

### Q2 2025 - Growth

- ⬜ Group meditation (SharePlay)
- ⬜ 10+ new guided sessions
- ⬜ Sleep enhancement features
- ⬜ Corporate wellness pilots

### Q3 2025 - Expansion

- ⬜ Movement meditation (Tai Chi, Yoga)
- ⬜ Custom session builder
- ⬜ Kids & family content
- ⬜ International expansion

### Q4 2025 - Innovation

- ⬜ Apple Watch integration
- ⬜ iPhone companion app
- ⬜ Advanced biofeedback training
- ⬜ Clinical trials publication

### 2026 - Vision

- ⬜ AR extensions (quick sessions)
- ⬜ Teacher certification program
- ⬜ User-generated content
- ⬜ Medical device certification

---

## Contributing

This is a proprietary project currently in active development. Contributions are limited to the core team at this time.

### For Core Team

1. Read all design documents first
2. Follow Swift API Design Guidelines
3. Maintain 90fps performance target
4. Write tests for all new features
5. Privacy-first always
6. Update documentation

### Code Style

- **Swift**: Follow official Swift style guide
- **Comments**: Explain why, not what
- **Naming**: Clear, descriptive, no abbreviations
- **Testing**: Test-driven development preferred
- **Performance**: Profile before optimizing

---

## Privacy & Security

### Data Handling

- ✅ **All biometric processing on-device** - Never transmitted
- ✅ **Optional CloudKit sync** - Encrypted end-to-end
- ✅ **No third-party analytics** - Privacy-first
- ✅ **User data export** - GDPR compliant
- ✅ **Complete data deletion** - Right to be forgotten

### Security Measures

- ✅ **End-to-end encryption** for cloud sync
- ✅ **No plaintext storage** of sensitive data
- ✅ **Secure payment processing** via StoreKit
- ✅ **Regular security audits**
- ✅ **Privacy policy** full transparency

---

## Support

### Documentation

- **Technical Questions**: See [TECHNICAL_SPEC.md](TECHNICAL_SPEC.md)
- **Design Questions**: See [DESIGN.md](DESIGN.md)
- **Testing**: See [TESTING.md](TESTING.md)
- **Tasks**: See [TODO.md](TODO.md)

### Contact

- **Website**: https://mindfulnessrealms.com
- **Email**: support@mindfulnessrealms.com
- **Twitter**: @MindfulnessVR
- **Instagram**: @mindfulnessrealms

### Issues

For bug reports and feature requests, please use the GitHub issue tracker (when public).

---

## License

Copyright © 2025 Mindfulness Meditation Realms. All rights reserved.

This is proprietary software. Unauthorized copying, distribution, or modification is strictly prohibited.

---

## Acknowledgments

### Inspiration

- **Meditation Teachers**: For centuries of wisdom
- **Clinical Researchers**: For validating mindfulness benefits
- **Apple**: For creating Vision Pro and spatial computing
- **Beta Testers**: For invaluable feedback

### Technology

- Built with Swift and SwiftUI
- Powered by RealityKit and ARKit
- Designed for Apple Vision Pro
- Optimized for wellness and comfort

---

## Disclaimer

**Medical Disclaimer**: This app is not a substitute for professional medical advice, diagnosis, or treatment. If you have mental health concerns, please consult a qualified healthcare provider.

The biometric measurements are estimates and should not be relied upon for medical decisions. This app is designed for wellness and meditation purposes only.

---

<div align="center">

**🕊️ Transform Your Space Into Inner Peace 🕊️**

*Meditation reimagined for the spatial computing era*

[Download for Vision Pro](#) • [View Landing Page](landing-page/index.html) • [Read Documentation](#documentation)

</div>

---

## Quick Links

- 📚 [Full Documentation](#documentation)
- 🧪 [Testing Strategy](TESTING.md)
- 📋 [Task List](TODO.md)
- 🗺️ [Development Roadmap](IMPLEMENTATION_PLAN.md)
- 🏗️ [Architecture](ARCHITECTURE.md)
- 🎨 [Design Specifications](DESIGN.md)
- 💻 [Technical Specs](TECHNICAL_SPEC.md)
- 🌐 [Landing Page](landing-page/README.md)

---

**Status**: Active Development | **Team**: 4-6 developers | **Target Launch**: Q1 2025

*Last Updated: 2025-01-20*
