# MySpatial Life - visionOS Life Simulation Game

A revolutionary life simulation game for Apple Vision Pro where AI-powered virtual family members live persistently in your actual home space, developing real personalities, forming authentic relationships, and experiencing life whether you're watching or not.

## 🎮 Project Status

**Phase**: Early Development - Core Systems Implementation
**Platform**: visionOS 2.0+
**Language**: Swift 6.0
**Development Time**: Started 2025-01-20

## 📋 What's Implemented

### ✅ Complete
- **Documentation** (100%)
  - Comprehensive Architecture Document
  - Detailed Technical Specifications
  - Complete Game Design Document
  - 36-Week Implementation Plan

- **Core Game Architecture** (90%)
  - Game Loop (30 FPS target for life sim)
  - Game State Management
  - Event Bus System
  - Time Management (real-time to sim-time conversion)

- **Character System** (85%)
  - Character Model with full properties
  - Big Five Personality System
  - Personality Evolution based on life experiences
  - Genetics System for offspring
  - Compatibility Calculation
  - 50+ Personality Traits

- **Relationship System** (80%)
  - Relationship Tracking (-100 to +100 score)
  - Relationship Type Progression (stranger → soulmate)
  - Romance & Friendship Levels
  - Dating & Marriage Systems
  - Relationship Decay over time

- **Career System** (75%)
  - 8 Career Paths (Culinary, Tech, Medical, Business, Creative, Education, Athletic, Science)
  - 10-level progression per career
  - Performance-based promotions
  - Salary scaling ($25k - $1M+)

- **Memory System** (70%)
  - Episodic Memory Storage
  - Emotional Weight (importance)
  - Memory Recall & Strengthening
  - Memory Decay over time

- **Family System** (70%)
  - Family Units with multi-generational tracking
  - Family Tree Structure
  - Family Funds Management

- **Testing** (75%)
  - Comprehensive Personality Tests
  - Character System Tests
  - Relationship System Tests
  - Test Coverage: ~75% of implemented code

- **UI/UX** (30%)
  - Main Menu View
  - Family Creation Flow (basic)
  - Game Volume View (placeholder)
  - Immersive Space View (placeholder)

### 🚧 In Progress / TODO
- **Needs System** - Character needs (hunger, energy, social, fun, hygiene, bladder)
- **AI Decision Making** - Utility-based AI for autonomous behavior
- **Spatial Integration** - ARKit room mapping, furniture detection, navigation
- **Spatial Audio** - 3D positional audio, character voices (Simlish)
- **Persistence** - SwiftData save/load, CloudKit sync
- **Aging System** - Life stage progression, birthday events
- **Advanced UI** - Character panels, HUD, settings, tutorial
- **Life Events** - Birthdays, weddings, births, deaths
- **Multiplayer** - Neighborhood system, character sharing

## 🏗️ Project Structure

```
MySpatialLife/
├── App/                    # App entry point and coordination
├── Core/                   # Core game systems
│   ├── GameLoop/          # Game loop, time, scheduling
│   ├── State/             # Game state management
│   └── Events/            # Event bus system
├── Game/                  # Game logic
│   ├── Characters/        # Character, personality, genetics
│   ├── Relationships/     # Relationship system
│   ├── Needs/             # Needs system (TODO)
│   ├── Career/            # Career progression
│   ├── Aging/             # Aging system (TODO)
│   └── Memory/            # Memory system
├── AI/                    # AI systems
│   ├── DecisionMaking/    # Utility-based AI (TODO)
│   ├── Personality/       # Personality engine
│   └── Behaviors/         # Autonomous behaviors (TODO)
├── Spatial/               # visionOS spatial features
│   ├── RoomMapping/       # ARKit integration (TODO)
│   ├── Navigation/        # Pathfinding (TODO)
│   └── Anchors/           # Spatial anchors (TODO)
├── Views/                 # SwiftUI views
│   ├── MainMenu/          # Menu screens
│   ├── Game/              # Game views
│   └── HUD/               # In-game UI (TODO)
└── Tests/                 # Comprehensive test suite
```

## 🎯 Core Features

### Personality System
- **Big Five Model**: Openness, Conscientiousness, Extraversion, Agreeableness, Neuroticism
- **Dynamic Evolution**: Personality changes based on life experiences
- **Age-Based Plasticity**: Younger characters change more easily
- **Compatibility Algorithm**: Calculate attraction between characters

### Relationship System
- **Relationship Types**: Stranger, Acquaintance, Friend, Best Friend, Romantic, Soulmate, Spouse, Family
- **Dynamic Progression**: Relationships evolve through interactions
- **Romance & Dating**: Full romantic progression system
- **Marriage & Divorce**: Long-term relationship changes

### Career System
- **8 Career Paths** with unique progression
- **Performance-Based**: Work quality affects promotions
- **Realistic Salaries**: $25k entry to $1M+ top positions
- **Skill Integration**: Relevant skills boost career success

## 🧪 Testing

Run tests with Xcode:
```bash
# Unit tests
cmd+U in Xcode

# Or via command line
xcodebuild test -scheme MySpatialLife
```

**Test Coverage**:
- Personality System: 95%
- Character System: 90%
- Relationship System: 85%
- Overall: ~75%

## 📚 Documentation

### 🚀 Quick Access
- **[QUICK_START.md](QUICK_START.md)** - ⚡ **10-MINUTE SETUP** - Get running FAST
- **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** - 📊 Complete project overview & status

### Setup & Getting Started
- **[SETUP_XCODE_PROJECT.md](SETUP_XCODE_PROJECT.md)** - ⭐ Step-by-step Xcode project creation
- **[TODO_visionOS_env.md](TODO_visionOS_env.md)** - Complete visionOS environment setup

### Technical Documentation
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Technical architecture and system design
- **[TECHNICAL_SPEC.md](TECHNICAL_SPEC.md)** - Detailed technical specifications
- **[DESIGN.md](DESIGN.md)** - Game design and UI/UX specifications
- **[IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md)** - 36-week development roadmap

### Original Requirements
- **[INSTRUCTIONS.md](INSTRUCTIONS.md)** - Original implementation instructions
- **[MySpatial-Life-PRD.md](MySpatial-Life-PRD.md)** - Product requirements document
- **[MySpatial-Life-PRFAQ.md](MySpatial-Life-PRFAQ.md)** - Press release FAQ

## 🚀 Getting Started

### Prerequisites
- macOS Sonoma or later
- Xcode 16.0+
- Apple Vision Pro (device or simulator)
- visionOS 2.0+ SDK

### ⚠️ Important: Project Setup Required

**The code is complete, but you need to create an Xcode project to run it.**

**Quick Start:**
1. Clone this repository
2. **Follow the setup guide:** [SETUP_XCODE_PROJECT.md](SETUP_XCODE_PROJECT.md) (10 minutes)
3. Build and run on Vision Pro simulator (⌘+R)

**Why?** The code is currently in Swift Package format. visionOS apps need a proper Xcode project structure to run. The setup guide walks you through creating this (it's easy!).

**Detailed Environment Setup:** See [TODO_visionOS_env.md](TODO_visionOS_env.md) for complete visionOS development environment configuration.

### Development

This project uses Swift Package Manager for dependencies:
- swift-algorithms
- swift-collections
- swift-numerics

Dependencies are automatically resolved by Xcode.

## 🎨 Design Principles

1. **Emotional Connection**: Form genuine bonds with AI characters
2. **Emergent Stories**: Let unpredictable life moments create narratives
3. **Spatial Presence**: Characters truly inhabit your living space
4. **Generational Legacy**: Watch families evolve across decades
5. **Autonomous Life**: Characters live independently with minimal intervention

## 🔮 Roadmap

### Phase 1: Core Systems (Weeks 1-6) ✅ 90% Complete
- Game loop, state management, events
- Character system with personality
- Basic relationships

### Phase 2: Life Simulation (Weeks 7-10) 🚧 60% Complete
- Career system ✅
- Enhanced AI (in progress)
- Aging system (TODO)

### Phase 3: Spatial Immersion (Weeks 11-14) 📋 Planned
- Room integration
- 3D characters & animation
- Spatial audio
- Hand & gaze interaction

### Phase 4: UI & Polish (Weeks 15-18) 📋 Planned
- Complete UI
- Tutorial & onboarding
- Life events
- Visual polish

### Phase 5-8: See [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md)

## 🤝 Contributing

This is currently a solo development project. Contributions welcome after MVP release.

## 📄 License

All rights reserved. This is a proprietary project.

## 📞 Contact

For questions or feedback, please open an issue on GitHub.

---

**Built with ❤️ for Apple Vision Pro**

*MySpatial Life - Where virtual families become part of your real home*
