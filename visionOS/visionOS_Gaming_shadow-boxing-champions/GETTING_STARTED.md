# Getting Started with Shadow Boxing Champions

Welcome! This guide will help you get up and running with Shadow Boxing Champions, whether you're a user, contributor, or team member.

---

## 🎯 Choose Your Path

- **[I want to use the app](#for-users)** - Download and play
- **[I want to contribute code](#for-developers)** - Build and develop
- **[I'm joining the team](#for-team-members)** - Onboarding
- **[I want to learn about the project](#for-learners)** - Explore documentation
- **[I represent media/press](#for-media)** - Press information

---

## 👤 For Users

### Requirements

- **Device:** Apple Vision Pro
- **OS:** visionOS 2.0 or later
- **Space:** Minimum 2m × 2m clear area (3m × 3m recommended)
- **Account:** Apple ID

### Installation

1. **Download from App Store** (Coming Soon)
   ```
   Search: "Shadow Boxing Champions"
   Or visit: [App Store Link]
   ```

2. **Launch the app**
   - Put on your Vision Pro
   - Find Shadow Boxing Champions in your apps
   - Tap to launch

3. **Complete Tutorial** (5 minutes)
   - Space calibration
   - Hand tracking setup
   - Basic punch training
   - First sparring match

4. **Start Training!**
   - Choose your training mode
   - Select difficulty level
   - Begin your boxing journey

### First Steps

**Day 1: Learn the Basics**
- Complete the tutorial
- Try technique drills mode
- Practice jabs and crosses
- Get comfortable with tracking

**Week 1: Build Foundation**
- Train 3-4 times per week
- Focus on form over power
- Try different training modes
- Beat your first beginner opponent

**Month 1: Level Up**
- Increase difficulty
- Join your first tournament
- Track your fitness progress
- Challenge friends online

### Getting Help

- **In-App Help:** Tap the (?) icon
- **Support:** support@shadowboxingchampions.com
- **Community:** [Discord](https://discord.gg/shadowboxing) (Coming Soon)
- **FAQ:** See [website FAQ](website/index.html#faq)

---

## 💻 For Developers

### Prerequisites

**Required:**
- macOS 14.0 or later
- Xcode 16.0 or later
- Apple Developer Account (for device testing)
- Basic Swift knowledge
- Git installed

**Recommended:**
- Apple Vision Pro device (simulator works for most development)
- Familiarity with SwiftUI
- Experience with RealityKit/ARKit
- Understanding of spatial computing concepts

### Quick Setup (5 minutes)

```bash
# 1. Clone the repository
git clone https://github.com/akaash-nigam/visionOS_Gaming_shadow-boxing-champions.git
cd visionOS_Gaming_shadow-boxing-champions

# 2. Open in Xcode (Phase 2 - project will be created)
open ShadowBoxingChampions.xcodeproj

# 3. Select your development team
# In Xcode: Signing & Capabilities > Team > [Your Team]

# 4. Build and run
# Press ⌘R or click the Play button
```

### Development Workflow

**1. Create a Feature Branch**
```bash
git checkout -b feature/your-feature-name
```

**2. Make Your Changes**
- Follow the [code style guide](CONTRIBUTING.md#swift-code-style)
- Write tests for new functionality
- Update documentation as needed

**3. Test Locally**
```bash
# Run tests
⌘U in Xcode

# Test on simulator
Select "Apple Vision Pro" simulator > ⌘R

# Test on device (if available)
Connect Vision Pro > Select device > ⌘R
```

**4. Commit Your Changes**
```bash
git add .
git commit -m "feat(combat): add uppercut detection"
```

Follow [conventional commits](https://www.conventionalcommits.org/)

**5. Push and Create PR**
```bash
git push origin feature/your-feature-name
# Then create PR on GitHub
```

### Project Structure Overview

```
ShadowBoxingChampions/
├── App/                    # App entry point
├── Game/                   # Game logic
│   ├── Combat/            # Punch detection, damage
│   ├── AI/                # Opponent behavior
│   └── Training/          # Training modes
├── Systems/               # Core systems
│   ├── Input/            # Hand tracking
│   ├── Physics/          # Collision, impact
│   └── Audio/            # Spatial audio
├── Views/                # UI components
├── Models/               # Data models
├── Resources/            # Assets
└── Tests/                # Unit tests
```

### Key Files to Know

- `GameCoordinator.swift` - Main game state machine
- `PunchDetectionSystem.swift` - Hand tracking and punch detection
- `AIOpponent.swift` - Opponent behavior
- `CombatSystem.swift` - Damage calculation
- `TrainingMode.swift` - Training session logic

### Common Tasks

**Add a New Punch Type:**
1. Update `PunchType` enum
2. Add detection logic in `PunchDetectionSystem`
3. Update UI feedback
4. Add tests

**Create a New Training Mode:**
1. Conform to `TrainingMode` protocol
2. Implement required methods
3. Add to mode selection UI
4. Add difficulty scaling

**Add a New Opponent:**
1. Create `OpponentProfile`
2. Design behavior tree
3. Create 3D model (or use existing)
4. Add to opponent roster

### Debugging Tips

**Performance Issues:**
```bash
# Profile with Instruments
Product > Profile (⌘I)
# Select "Time Profiler" or "Allocations"
```

**Hand Tracking Not Working:**
- Check ARKit permissions in Info.plist
- Verify hand tracking provider is running
- Test in good lighting conditions
- Check console for ARKit errors

**Build Errors:**
- Clean build folder: ⌘⇧K
- Reset package cache: File > Packages > Reset Package Caches
- Restart Xcode
- Check Swift version compatibility

### Resources

- **Apple Docs:** [developer.apple.com/visionos](https://developer.apple.com/visionos/)
- **RealityKit:** [developer.apple.com/realitykit](https://developer.apple.com/documentation/realitykit)
- **ARKit:** [developer.apple.com/arkit](https://developer.apple.com/documentation/arkit)
- **Project Docs:** [Architecture](docs/ARCHITECTURE.md), [Technical Spec](docs/TECHNICAL_SPEC.md)

---

## 👔 For Team Members

### Day 1: Onboarding

**Morning:**
1. ✅ Complete HR paperwork
2. ✅ Set up development environment
3. ✅ Clone repository and build project
4. ✅ Read [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)

**Afternoon:**
5. ✅ Review [ARCHITECTURE.md](docs/ARCHITECTURE.md)
6. ✅ Meet the team (standups)
7. ✅ Get assigned first task
8. ✅ Join communication channels

### Week 1: Integration

**Technical Setup:**
- [ ] Xcode configured
- [ ] Apple Developer account
- [ ] Access to repositories
- [ ] CI/CD permissions

**Knowledge:**
- [ ] Read all core documentation
- [ ] Understand architecture
- [ ] Review code style guide
- [ ] Complete first PR

**Team:**
- [ ] Meet all team members
- [ ] Understand roles
- [ ] Join daily standups
- [ ] Set up 1-on-1s

### Month 1: Contributing

**Goals:**
- Complete 3-5 PRs
- Review others' code
- Participate in design discussions
- Attend sprint planning

### Team Resources

**Communication:**
- **Slack/Discord:** Daily communication
- **GitHub:** Code reviews, issues
- **Zoom:** Video calls
- **Email:** Official communications

**Meetings:**
- **Daily Standup:** 9:00 AM (15 min)
- **Sprint Planning:** Mondays (1 hour)
- **Sprint Review:** Fridays (30 min)
- **Retrospective:** Bi-weekly (45 min)

**Documentation:**
- **Confluence/Notion:** Internal wiki
- **Google Drive:** Shared documents
- **Figma:** Design files

---

## 📚 For Learners

### Learning Path

**Level 1: Understanding the Project (2 hours)**
1. Read [README.md](README.md) - 10 min
2. Read [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) - 15 min
3. Browse [landing page](website/index.html) - 5 min
4. Watch demo video (coming soon) - 5 min
5. Read [PRD](Shadow-Boxing-Champions-PRD.md) - 30 min
6. Read [PRFAQ](Shadow-Boxing-Champions-PRFAQ.md) - 20 min

**Level 2: Technical Deep Dive (4 hours)**
1. Read [ARCHITECTURE.md](docs/ARCHITECTURE.md) - 1 hour
2. Read [TECHNICAL_SPEC.md](docs/TECHNICAL_SPEC.md) - 1 hour
3. Read [DESIGN.md](docs/DESIGN.md) - 1 hour
4. Read [IMPLEMENTATION_PLAN.md](docs/IMPLEMENTATION_PLAN.md) - 1 hour

**Level 3: Contributing (Ongoing)**
1. Read [CONTRIBUTING.md](CONTRIBUTING.md) - 30 min
2. Read [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) - 10 min
3. Review open issues - 20 min
4. Set up development environment - 30 min
5. Make your first contribution!

### Study Topics

**visionOS Development:**
- Apple's visionOS documentation
- RealityKit tutorials
- ARKit hand tracking
- Spatial computing concepts

**Game Development:**
- Entity-Component-System pattern
- Game loop architecture
- Physics simulation
- AI behavior trees

**Swift Advanced Topics:**
- Async/await and actors
- Swift concurrency
- Memory management
- Performance optimization

### Practice Projects

Before contributing, try building:
1. **Simple hand tracker** - Track hand position
2. **Punch detector** - Detect fast hand movement
3. **3D object placer** - Place objects in space
4. **Simple game loop** - Update entities each frame

---

## 📰 For Media

### Quick Facts

- **Name:** Shadow Boxing Champions
- **Category:** Fitness & Gaming
- **Platform:** Apple Vision Pro (visionOS 2.0+)
- **Price:** $39.99 (Training Suite), $9.99/month (Champions Pass)
- **Launch:** Q4 2026 (Target)
- **Developer:** Shadow Boxing Champions Inc.

### Key Features

1. **Precision Tracking** - Millimeter-accurate punch analysis
2. **AI Opponents** - Adaptive opponents that learn your style
3. **Professional Coaching** - Real-time technique feedback
4. **Fitness Integration** - HealthKit sync, 200-400 cal/session
5. **Competitive Gaming** - Online tournaments and leaderboards

### Media Resources

- **Press Kit:** [Coming Soon]
- **Screenshots:** [Coming Soon]
- **Demo Video:** [Coming Soon]
- **Logos:** [Coming Soon]

### Contact

- **Press Inquiries:** press@shadowboxingchampions.com
- **General:** contact@shadowboxingchampions.com
- **Website:** shadowboxingchampions.com (Coming Soon)

### Interview Availability

Available for interviews about:
- Spatial computing in fitness
- visionOS game development
- Boxing training technology
- Startup journey

---

## 🆘 Troubleshooting

### Common Issues

**"Can't build the project"**
- Ensure Xcode 16.0+ installed
- Clean build folder (⌘⇧K)
- Check signing certificates
- Verify minimum deployment target

**"Hand tracking not working"**
- Grant camera permissions
- Ensure good lighting
- Hold hands in frame
- Restart app

**"Performance issues"**
- Close other apps
- Check FPS counter
- Profile with Instruments
- Review performance targets

**"Can't find documentation"**
- Check docs/ folder
- See docs/INDEX.md
- Visit repository root
- Search GitHub

### Getting Help

1. **Check Documentation**
   - Browse docs/ folder
   - Search GitHub issues
   - Read FAQ on website

2. **Ask the Community**
   - Discord server (Coming Soon)
   - GitHub Discussions
   - Stack Overflow (tag: shadow-boxing-visionos)

3. **Contact Support**
   - support@shadowboxingchampions.com
   - Include: OS version, device, steps to reproduce

4. **Report Bugs**
   - Use GitHub issue templates
   - Provide logs and screenshots
   - Check for duplicates first

---

## 📖 Documentation Index

- **[README.md](README.md)** - Project overview
- **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** - Complete project summary
- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** - Technical architecture
- **[TECHNICAL_SPEC.md](docs/TECHNICAL_SPEC.md)** - Implementation details
- **[DESIGN.md](docs/DESIGN.md)** - Game design document
- **[IMPLEMENTATION_PLAN.md](docs/IMPLEMENTATION_PLAN.md)** - Development roadmap
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - How to contribute
- **[CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)** - Community guidelines
- **[SECURITY.md](SECURITY.md)** - Security policy

---

## ✅ Next Steps

Choose your path:

**Users:** Wait for App Store launch → Join beta program
**Developers:** Set up environment → Pick an issue → Submit PR
**Team Members:** Complete onboarding → Get first task → Start building
**Learners:** Read docs → Try tutorials → Build practice projects
**Media:** Contact us → Review press kit → Schedule interview

---

**Welcome to Shadow Boxing Champions!** 🥊

Questions? reach out to hello@shadowboxingchampions.com

---

<p align="center">
  <sub>Last Updated: 2025-11-19 | Version: 1.0</sub>
</p>
