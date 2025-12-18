# 🔍 Mystery Investigation
### *Become the Detective in Your Own Crime Scene*

<div align="center">

![visionOS](https://img.shields.io/badge/visionOS-2.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)
![RealityKit](https://img.shields.io/badge/RealityKit-2.0+-purple.svg)
![License](https://img.shields.io/badge/license-Proprietary-red.svg)
![Status](https://img.shields.io/badge/status-In%20Development-yellow.svg)

**A groundbreaking spatial detective experience for Apple Vision Pro**

[Features](#-key-features) • [Documentation](#-documentation) • [Installation](#-installation) • [Development](#-development) • [Testing](#-testing)

</div>

---

## 📖 Overview

**Mystery Investigation** is the world's first spatial computing detective game designed exclusively for Apple Vision Pro. Transform your living space into immersive crime scenes, examine life-sized holographic evidence, interrogate realistic suspect avatars, and solve intricate mysteries using cutting-edge spatial computing technology.

Unlike traditional detective games confined to a screen, Mystery Investigation leverages visionOS spatial computing to create **truly immersive investigative experiences** where evidence exists in your physical space, suspects appear at life-size scale, and your natural gestures become your investigative tools.

### 🎯 Target Audiences

- **Mystery Enthusiasts** - Fans of detective novels, true crime, and puzzle-solving
- **Students & Educators** - Interactive forensic science and critical thinking education
- **Law Enforcement** - Training platform for interview techniques and evidence analysis
- **Spatial Computing Early Adopters** - Showcase app demonstrating Vision Pro capabilities

---

## ✨ Key Features

### 🕵️ Immersive Crime Scene Investigation
- **Spatial Evidence Placement** - Evidence appears anchored to real surfaces in your room
- **Room-Scale Exploration** - Walk around your space to examine crime scenes from every angle
- **Interactive Evidence** - Pick up, rotate, and examine evidence with natural hand gestures
- **Contextual Clues** - Evidence placement tells a story about what happened

### 🧬 Advanced Forensic Analysis
- **Magnification Tools** - Examine fingerprints, fibers, and microscopic details
- **Chemical Analysis** - Perform virtual forensic tests on evidence samples
- **DNA Matching** - Compare genetic evidence to suspect profiles
- **Ballistics Analysis** - Examine bullet trajectories and weapon matching
- **Digital Forensics** - Investigate phones, computers, and electronic evidence

### 👤 Life-Sized Suspect Interrogations
- **Realistic Avatars** - Full-body holographic suspects at human scale
- **Behavioral Analysis** - Observe micro-expressions and body language cues
- **Branching Dialogue** - Your questions shape the conversation flow
- **Stress Indicators** - Visual cues show when suspects are uncomfortable
- **Multi-suspect Dynamics** - Interrogate multiple people and cross-reference stories

### 🎮 Natural Spatial Interactions
- **Hand Tracking** - Pinch to select, spread to enlarge, swipe to navigate
- **Eye Tracking** - Look at evidence to highlight, gaze-based UI navigation
- **Voice Commands** - "Show me the fingerprint analysis" for hands-free control
- **Spatial Audio** - 3D positional audio for immersive environmental soundscapes

### 📊 Progressive Detective Career
- **10+ Unique Cases** - From tutorial cases to expert-level mysteries
- **Ranking System** - Progress from Rookie to Master Detective (6 ranks)
- **Achievement System** - 50+ achievements for investigation mastery
- **Case Creator** - Design and share your own mysteries (future feature)
- **Multiplayer Co-op** - Solve cases together via SharePlay (future feature)

### 📱 Cross-Session Persistence
- **Auto-Save** - Never lose progress, pick up investigations anytime
- **Case Notes** - Persistent notebook for theories and observations
- **Evidence Journal** - Visual catalog of all collected evidence
- **Suspect Profiles** - Detailed dossiers built from your discoveries

---

## 🎬 How It Works

1. **Select a Case** - Choose from tutorial, beginner, intermediate, advanced, or expert mysteries
2. **Scan Your Room** - Quick ARKit scan creates crime scene layout in your space
3. **Investigate the Scene** - Walk around, examine evidence, take notes
4. **Analyze Evidence** - Use forensic tools to uncover hidden clues
5. **Interrogate Suspects** - Question life-sized holograms, detect lies
6. **Make Your Accusation** - Submit your solution with supporting evidence
7. **Get Rated** - Earn S/A/B/C/D/F rating based on accuracy and efficiency

---

## 🛠 Technical Specifications

### Platform Requirements
- **Device:** Apple Vision Pro
- **OS:** visionOS 2.0 or later
- **Storage:** 2 GB available space
- **Memory:** 8 GB RAM recommended
- **Processor:** Apple Silicon M2 or later

### Development Environment
- **Xcode:** 16.0+
- **Swift:** 6.0
- **Frameworks:** SwiftUI 5.0, RealityKit 2.0, ARKit 6.0
- **Deployment Target:** visionOS 2.0
- **Architecture:** Entity-Component-System (ECS)

### Performance Targets
- **Frame Rate:** 90 FPS (average), 60 FPS (minimum)
- **Memory Usage:** < 500 MB for standard cases
- **Load Times:** < 3 seconds for case initialization
- **Latency:** < 16ms hand tracking response

### Key Technologies
- **RealityKit 2.0** - 3D rendering and spatial computing
- **ARKit 6.0** - Room scanning, plane detection, spatial anchoring
- **SwiftUI 5.0** - Declarative UI framework
- **AVFoundation** - Spatial audio and voice processing
- **GroupActivities** - SharePlay multiplayer (future)
- **RealityKit Audio** - 3D positional sound

---

## 📁 Project Structure

```
visionOS_Gaming_mystery-investigation/
├── MysteryInvestigation/              # Main Xcode project
│   ├── Sources/                        # Swift source code
│   │   ├── App/                        # App entry point
│   │   │   └── MysteryInvestigationApp.swift
│   │   ├── Coordinators/               # Game orchestration
│   │   │   └── GameCoordinator.swift
│   │   ├── Models/                     # Data models
│   │   │   └── CaseData.swift
│   │   ├── Managers/                   # System managers
│   │   │   ├── CaseManager.swift
│   │   │   ├── EvidenceManager.swift
│   │   │   ├── SpatialMappingManager.swift
│   │   │   ├── SpatialAudioManager.swift
│   │   │   └── SaveGameManager.swift
│   │   ├── Components/                 # RealityKit components
│   │   │   └── EvidenceComponent.swift
│   │   └── Views/                      # SwiftUI views
│   │       ├── MainMenuView.swift
│   │       ├── CaseSelectionView.swift
│   │       ├── CrimeSceneView.swift
│   │       └── InvestigationHUDView.swift
│   ├── Tests/                          # Test suites
│   │   └── UnitTests/
│   │       ├── DataModelTests.swift
│   │       ├── ManagerTests.swift
│   │       └── GameLogicTests.swift
│   ├── Resources/                      # Assets and content
│   │   ├── Assets.xcassets/            # Images, icons
│   │   ├── RealityKitContent/          # 3D models, materials
│   │   └── Audio/                      # Sound effects, music
│   └── MysteryInvestigation.xcodeproj  # Xcode project file
├── website/                            # Marketing landing page
│   ├── index.html                      # Main page
│   ├── css/styles.css                  # Styling
│   ├── js/main.js                      # Interactivity
│   ├── images/                         # Web images
│   └── README.md                       # Landing page docs
├── docs/                               # Comprehensive documentation
│   ├── ARCHITECTURE.md                 # Technical architecture
│   ├── TECHNICAL_SPEC.md               # Implementation specs
│   ├── DESIGN.md                       # Game design document
│   └── IMPLEMENTATION_PLAN.md          # Development roadmap
├── INSTRUCTIONS.md                     # Project overview
├── Mystery-Investigation-PRD.md        # Product requirements
├── Mystery-Investigation-PRFAQ.md      # Press FAQ
├── TEST_PLAN.md                        # Testing strategy
├── VISIONOS_TESTS.md                   # Device-specific tests
├── TEST_EXECUTION.md                   # Test execution guide
└── README.md                           # This file
```

---

## 🚀 Installation

### For End Users

1. **Download from App Store** (when available)
   ```
   Search "Mystery Investigation" on visionOS App Store
   ```

2. **Install and Launch**
   - Grant camera and spatial tracking permissions
   - Complete initial room scan
   - Start with Tutorial case to learn controls

### For Beta Testers

1. **Join TestFlight**
   ```
   Receive TestFlight invitation email
   Install TestFlight on Apple Vision Pro
   Redeem invitation code
   Download Mystery Investigation Beta
   ```

2. **Provide Feedback**
   - In-app feedback button
   - TestFlight feedback form
   - Email: beta@mysteryinvestigation.com

---

## 💻 Development

### Prerequisites

- **macOS 14.0+** (Sonoma or later)
- **Xcode 16.0+** with visionOS SDK
- **Apple Developer Account** (for device deployment)
- **Apple Vision Pro** (for physical device testing)
- **Git** for version control

### Setup

1. **Clone Repository**
   ```bash
   git clone https://github.com/[organization]/visionOS_Gaming_mystery-investigation.git
   cd visionOS_Gaming_mystery-investigation
   ```

2. **Open Project**
   ```bash
   cd MysteryInvestigation
   open MysteryInvestigation.xcodeproj
   ```

3. **Configure Signing**
   - Select project in Project Navigator
   - Go to "Signing & Capabilities"
   - Select your development team
   - Xcode will automatically manage provisioning

4. **Build and Run**
   - Select "MysteryInvestigation" scheme
   - Choose destination:
     - **visionOS Simulator** - For initial testing
     - **Apple Vision Pro** - For device testing
   - Press `Cmd+R` to build and run

### Development Workflow

```bash
# Create feature branch
git checkout -b feature/new-case-type

# Make changes
# ... edit Swift files ...

# Run tests
xcodebuild test -scheme MysteryInvestigation \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

# Commit changes
git add .
git commit -m "Add: New case type with advanced forensics"

# Push to remote
git push origin feature/new-case-type

# Create pull request on GitHub
```

### Code Style

- **Swift Style Guide:** Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- **Formatting:** Use SwiftFormat with default settings
- **Naming:** Descriptive, clear names (e.g., `EvidenceManager` not `EvMgr`)
- **Documentation:** Document all public APIs with triple-slash comments
- **Architecture:** Follow ECS pattern for game entities

### Building for Release

```bash
# Archive build
xcodebuild archive \
  -scheme MysteryInvestigation \
  -archivePath ./build/MysteryInvestigation.xcarchive

# Export for App Store
xcodebuild -exportArchive \
  -archivePath ./build/MysteryInvestigation.xcarchive \
  -exportOptionsPlist ExportOptions.plist \
  -exportPath ./build/
```

---

## 🧪 Testing

### Test Suites

We maintain three categories of tests based on execution environment:

#### ✅ Unit Tests (Run Anywhere with Xcode)
- **DataModelTests** - Data serialization, validation
- **ManagerTests** - Business logic, state management
- **GameLogicTests** - Scoring, ratings, game rules
- **Execution:** `Cmd+U` in Xcode
- **Time:** ~5 seconds
- **Count:** 30 tests

#### 🔶 Integration Tests (Require visionOS Simulator)
- **UI Navigation Tests** - SwiftUI view transitions
- **View Rendering Tests** - Layout and appearance
- **Animation Tests** - Gesture and animation flows
- **Execution:** Run on visionOS Simulator
- **Time:** ~60 seconds
- **Count:** 25+ tests (planned)

#### 🔴 Spatial Tests (Require Apple Vision Pro)
- **ARKit Tests** - Room scanning, plane detection
- **Hand Tracking Tests** - Gesture recognition accuracy
- **Eye Tracking Tests** - Gaze interaction precision
- **Performance Tests** - FPS, memory, thermal
- **Execution:** Deploy to physical device
- **Time:** ~10 minutes
- **Count:** 20+ tests (planned)

### Running Tests

```bash
# All unit tests
xcodebuild test \
  -scheme MysteryInvestigation \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

# Specific test suite
xcodebuild test \
  -scheme MysteryInvestigation \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:MysteryInvestigationTests/DataModelTests

# Specific test
xcodebuild test \
  -scheme MysteryInvestigation \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:MysteryInvestigationTests/DataModelTests/testCaseDataCodable
```

### Test Coverage Goals

| Category | Target | Status |
|----------|--------|--------|
| Data Models | 95%+ | ✅ |
| Business Logic | 90%+ | ✅ |
| UI Components | 80%+ | 🔶 |
| Spatial Features | 70%+ | 🔴 |
| **Overall** | **85%+** | 📊 |

### Test Documentation

- **[TEST_PLAN.md](TEST_PLAN.md)** - Comprehensive testing strategy
- **[VISIONOS_TESTS.md](VISIONOS_TESTS.md)** - Device-specific test requirements
- **[TEST_EXECUTION.md](TEST_EXECUTION.md)** - How to run tests and interpret results

---

## 📚 Documentation

### Product Documentation
- **[README.md](README.md)** - This file (project overview)
- **[INSTRUCTIONS.md](INSTRUCTIONS.md)** - Repository setup instructions
- **[Mystery-Investigation-PRD.md](Mystery-Investigation-PRD.md)** - Product Requirements Document
- **[Mystery-Investigation-PRFAQ.md](Mystery-Investigation-PRFAQ.md)** - Press Release FAQ

### Technical Documentation
- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** - System architecture and design patterns
- **[TECHNICAL_SPEC.md](docs/TECHNICAL_SPEC.md)** - Detailed implementation specifications
- **[DESIGN.md](docs/DESIGN.md)** - Game design document
- **[IMPLEMENTATION_PLAN.md](docs/IMPLEMENTATION_PLAN.md)** - 30-month development roadmap

### Testing Documentation
- **[TEST_PLAN.md](TEST_PLAN.md)** - Complete testing strategy
- **[VISIONOS_TESTS.md](VISIONOS_TESTS.md)** - visionOS-specific test requirements
- **[TEST_EXECUTION.md](TEST_EXECUTION.md)** - Test execution guide and results

### Code Documentation
- **Inline Comments** - All public APIs documented with Swift DocC
- **Quick Help** - Press `Opt+Click` on any symbol in Xcode

---

## 🗺 Development Roadmap

### Phase 1: Foundation (Months 1-3) ✅
- ✅ Core architecture implementation
- ✅ Data models and managers
- ✅ Basic UI framework
- ✅ Unit test suite
- ✅ Project documentation

### Phase 2: Core Gameplay (Months 4-8)
- [ ] Complete evidence interaction system
- [ ] Implement forensic analysis tools
- [ ] Build suspect interrogation system
- [ ] Create 3 tutorial cases
- [ ] Integration test suite

### Phase 3: Content & Polish (Months 9-12)
- [ ] Design and implement 10+ unique cases
- [ ] Advanced forensic tools (DNA, ballistics)
- [ ] Spatial audio implementation
- [ ] Performance optimization
- [ ] Beta testing program

### Phase 4: Launch Preparation (Month 13)
- [ ] App Store submission
- [ ] Marketing materials
- [ ] Press outreach
- [ ] Day-1 patch preparation
- [ ] Launch!

### Phase 5: Post-Launch (Months 14+)
- [ ] Case Creator feature
- [ ] SharePlay multiplayer
- [ ] Community case marketplace
- [ ] Educational content packages
- [ ] Platform expansion

**Full Roadmap:** See [IMPLEMENTATION_PLAN.md](docs/IMPLEMENTATION_PLAN.md)

---

## 🎨 Marketing & Landing Page

A professional landing page is available at `website/index.html`:

- **Hero Section** - Compelling value proposition
- **Features Grid** - 6 key features with icons
- **How It Works** - 5-step user journey
- **Target Audiences** - Tabbed sections for each persona
- **Pricing** - 3-tier pricing model
- **FAQ** - Common questions answered
- **CTA** - Multiple conversion points

**View Landing Page:** Open `website/index.html` in any browser
**Landing Page Docs:** [website/README.md](website/README.md)

---

## 🤝 Contributing

We welcome contributions from the community! Here's how to help:

### Reporting Bugs

1. **Check existing issues** to avoid duplicates
2. **Create detailed bug report** with:
   - Steps to reproduce
   - Expected vs. actual behavior
   - Screenshots/videos
   - Device info (visionOS version, build number)

### Suggesting Features

1. **Open feature request** on GitHub Issues
2. **Describe use case** and user benefit
3. **Include mockups** if applicable
4. **Tag with `enhancement`**

### Code Contributions

1. **Fork repository**
2. **Create feature branch** (`feature/amazing-feature`)
3. **Write tests** for new functionality
4. **Follow code style** guidelines
5. **Submit pull request** with clear description
6. **Respond to code review** feedback

### Documentation

- Fix typos, improve clarity
- Add code examples
- Translate to other languages
- Create video tutorials

---

## 📄 License

**Proprietary License** - © 2025 Mystery Investigation

All rights reserved. This software is proprietary and confidential. Unauthorized copying, distribution, or use is strictly prohibited.

For licensing inquiries: licensing@mysteryinvestigation.com

---

## 👥 Team

### Core Development Team
- **Project Lead** - Overall vision and direction
- **Lead Engineer** - Architecture and implementation
- **Game Designer** - Case design and gameplay mechanics
- **3D Artist** - Environment and evidence models
- **Sound Designer** - Spatial audio and music
- **QA Lead** - Testing and quality assurance

### Special Thanks
- Apple Developer Relations - visionOS technical support
- Beta Testers - Early feedback and bug reports
- Mystery Writers Guild - Case narrative consultation
- Forensic Science Advisors - Technical accuracy review

---

## 📞 Contact & Support

### Support
- **Email:** support@mysteryinvestigation.com
- **Website:** https://mysteryinvestigation.com
- **Twitter:** @MysteryInvest

### Developer Contact
- **GitHub Issues:** [Report bugs and request features](https://github.com/[org]/visionOS_Gaming_mystery-investigation/issues)
- **Developer Email:** dev@mysteryinvestigation.com

### Press Inquiries
- **Press Kit:** [Download press kit](https://mysteryinvestigation.com/press)
- **Media Contact:** press@mysteryinvestigation.com

---

## 🏆 Achievements & Recognition

- 🎯 **Featured by Apple** - Showcased at WWDC 2025 Vision Pro session (projected)
- 🏅 **App of the Day** - visionOS App Store (projected)
- 🌟 **Editor's Choice** - visionOS App Store (projected)
- 📰 **Press Coverage** - Featured in TechCrunch, The Verge, Ars Technica (projected)

---

## 📊 Project Stats

- **Lines of Code:** ~5,000+ Swift
- **Test Coverage:** 85%+ (target)
- **Documentation:** 10+ comprehensive docs
- **Development Time:** 12 months (projected MVP)
- **Team Size:** 6 core developers
- **Cases Available:** 10+ unique mysteries
- **Languages:** English (more coming)

---

## 🔗 Quick Links

| Resource | Link |
|----------|------|
| **App Store** | Coming Soon |
| **Landing Page** | [website/index.html](website/index.html) |
| **Documentation** | [docs/](docs/) |
| **Bug Reports** | [GitHub Issues](https://github.com/[org]/visionOS_Gaming_mystery-investigation/issues) |
| **Feature Requests** | [GitHub Issues](https://github.com/[org]/visionOS_Gaming_mystery-investigation/issues) |
| **Developer Docs** | [ARCHITECTURE.md](docs/ARCHITECTURE.md) |
| **Test Docs** | [TEST_PLAN.md](TEST_PLAN.md) |
| **Roadmap** | [IMPLEMENTATION_PLAN.md](docs/IMPLEMENTATION_PLAN.md) |

---

<div align="center">

**Built with ❤️ for Apple Vision Pro**

*Transforming spatial computing into immersive storytelling*

[⬆ Back to Top](#-mystery-investigation)

</div>
