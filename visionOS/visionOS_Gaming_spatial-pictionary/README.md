# Spatial Pictionary

<div align="center">

**Draw in the air, guess in three dimensions**

[![visionOS](https://img.shields.io/badge/visionOS-2.0+-blue.svg)](https://developer.apple.com/visionos/)
[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

[Features](#features) • [Quick Start](#quick-start) • [Documentation](#documentation) • [Contributing](#contributing) • [License](#license)

</div>

---

## Overview

Spatial Pictionary revolutionizes the classic drawing game by enabling players to create 3D artwork in mid-air using hand gestures, while others guess the subject from any angle around the floating creation. Using Vision Pro's precise hand tracking, players sculpt, draw, and build clues in three-dimensional space, creating a party game experience that combines artistic creativity with spatial reasoning and social interaction.

### Why Spatial Pictionary?

✨ **Immersive 3D Drawing** - Create artwork in true 3D space using natural hand gestures
🎮 **Multiplayer Fun** - Play with 2-12 players locally or remotely via SharePlay
🧠 **AI-Powered** - Dynamic difficulty adjustment and intelligent word selection
🎨 **Rich Creative Tools** - Multiple materials, colors, and artistic effects
📚 **Educational** - Perfect for vocabulary building and spatial reasoning development
🌍 **Accessible** - Multi-language support and inclusive design

## Table of Contents

- [Quick Start](#quick-start)
- [Features](#features)
- [Installation](#installation)
- [Development](#development)
- [Testing](#testing)
- [Documentation](#documentation)
- [Monetization](#monetization)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)

---

## Quick Start

**For Users:**
1. Ensure you have Apple Vision Pro with visionOS 2.0+
2. Download from App Store (coming soon)
3. Grant hand tracking and microphone permissions
4. Follow the in-app tutorial
5. Start playing!

**For Developers:**
See [QUICKSTART.md](QUICKSTART.md) for detailed setup instructions.

```bash
# Clone the repository
git clone https://github.com/akaash-nigam/visionOS_Gaming_spatial-pictionary.git
cd visionOS_Gaming_spatial-pictionary

# Open in Xcode (macOS required)
open SpatialPictionary.xcodeproj

# Build and run on Vision Pro simulator or device
```

---

## Features

### Core Gameplay Features

#### 3D Drawing and Sculpting
- **Air Drawing**: Create lines, shapes, and forms in 3D space using natural hand movements
- **Sculptural Mode**: Build objects by adding and subtracting virtual clay-like materials
- **Color and Texture**: Apply realistic materials and lighting effects to enhance visual clues
- **Scale Manipulation**: Resize creations to fit room space or emphasize important details

### Enhanced Guessing Mechanics
- **Multi-Angle Viewing**: Guessers can walk around creations to see them from all perspectives
- **Progressive Revelation**: Drawings build over time, allowing for strategic guessing timing
- **Collaborative Clues**: Team members can add details to help others guess correctly
- **Dynamic Categories**: AI generates contextual categories based on current events and player interests

### Social Gaming Excellence
- **Party Mode**: Support for 2-12 players in the same physical space
- **Remote Play**: Connect with friends in different locations for online drawing sessions
- **Tournament Organization**: Bracket systems for competitive drawing and guessing competitions
- **Custom Challenges**: Create personalized word lists and categories for specific groups

## Technical Innovation

### Advanced Hand Tracking
- **Precision Drawing**: Sub-millimeter accuracy for detailed artistic expression
- **Gesture Recognition**: Different hand movements create different artistic effects
- **Two-Hand Coordination**: Use both hands simultaneously for complex creation techniques
- **Fatigue Prevention**: Ergonomic gesture design to prevent hand strain during extended play

### Spatial Art Systems
- **Realistic Physics**: Virtual materials behave authentically with gravity and collision
- **Lighting Integration**: Room lighting affects the appearance of 3D creations
- **Perspective Rendering**: Drawings look correct from multiple viewing angles simultaneously
- **Creation Persistence**: Artwork remains exactly positioned for detailed examination

## Monetization Strategy

### Party Game Complete ($24.99)
- **Unlimited Word Categories**: Access to thousands of words across hundreds of categories
- **Multiplayer Support**: Up to 12 players in local or remote multiplayer sessions
- **Custom Content Tools**: Create personalized word lists and game variations
- **Achievement System**: Unlock new drawing tools and artistic effects through gameplay

### Premium Content Packs ($4.99 each)
- **Themed Categories**: Specialized word sets for holidays, professions, movies, and pop culture
- **Educational Packs**: STEM vocabulary, language learning, and academic subject categories
- **Artistic Tools**: Advanced drawing implements, materials, and special effects
- **Cultural Collections**: International words and concepts for diverse gaming experiences

### Educational Platform ($99.99/year per classroom)
- **Curriculum Integration**: Vocabulary building and artistic expression lesson plans
- **Student Progress Tracking**: Monitor creativity development and vocabulary growth
- **Safe Multiplayer**: Moderated gaming environments appropriate for educational settings
- **Assessment Tools**: Evaluate student participation and creative problem-solving skills

## Target Audience

### Primary: Social Gamers (Ages 8-adult)
- **Family Entertainment**: Multi-generational gaming that everyone can enjoy together
- **Party Hosts**: People seeking engaging group activities for gatherings and celebrations
- **Social Gaming Groups**: Friend groups looking for creative and interactive entertainment

### Secondary: Educational Market (Ages 6-18)
- **Elementary Educators**: Teachers seeking creative vocabulary and art education tools
- **Art Instructors**: Art teachers exploring 3D creativity and spatial reasoning development
- **ESL Programs**: Language learning programs using visual association for vocabulary building

### Tertiary: Creative Communities (Ages 12-adult)
- **Art Enthusiasts**: People interested in exploring 3D artistic expression
- **Streaming Content**: Content creators showcasing entertaining and creative gameplay
- **Therapeutic Applications**: Art therapy and social interaction therapy programs

---

## Installation

### Requirements

- **Hardware**: Apple Vision Pro
- **OS**: visionOS 2.0 or later
- **Development**:
  - macOS 14.0+ (Sonoma)
  - Xcode 16.0+
  - Swift 6.0+

### For End Users

Download from the App Store (coming soon) or see [DEPLOYMENT.md](DEPLOYMENT.md) for TestFlight beta access.

### For Developers

1. **Clone the repository:**
   ```bash
   git clone https://github.com/akaash-nigam/visionOS_Gaming_spatial-pictionary.git
   cd visionOS_Gaming_spatial-pictionary
   ```

2. **Install dependencies:**
   ```bash
   # Currently no external dependencies
   # All frameworks are native to visionOS
   ```

3. **Open in Xcode:**
   ```bash
   open SpatialPictionary.xcodeproj
   ```

4. **Configure signing:**
   - Select your development team in Xcode
   - Update bundle identifier if needed

5. **Build and run:**
   - Select Vision Pro simulator or device
   - Press Cmd+R to build and run

See [QUICKSTART.md](QUICKSTART.md) for detailed instructions.

---

## Development

### Project Structure

```
SpatialPictionary/
├── App/                    # Application entry point
├── Models/                 # Data models (Player, Word, Drawing)
├── Game/                   # Game logic and state management
│   ├── GameState/         # Observable game state
│   ├── Logic/             # Turn management, scoring
│   └── Networking/        # Multiplayer synchronization
├── Views/                  # SwiftUI views
│   ├── Lobby/            # Pre-game setup
│   ├── Drawing/          # 3D drawing interface
│   └── Guessing/         # Guessing interface
├── Systems/               # Core systems
│   ├── Drawing/          # Drawing engine
│   ├── Recognition/      # Gesture and speech recognition
│   └── AI/               # AI difficulty adjustment
└── Resources/             # Assets, sounds, word databases

Tests/
├── UnitTests/            # Unit tests for logic
├── IntegrationTests/     # System integration tests
└── UITests/              # UI and interaction tests
```

See [SOURCE_CODE_README.md](SOURCE_CODE_README.md) for detailed architecture.

### Development Workflow

1. **Create a feature branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes:**
   - Follow Swift style guidelines
   - Add tests for new functionality
   - Update documentation

3. **Run tests:**
   ```bash
   # Run all tests in Xcode
   Cmd+U

   # Or use command line
   xcodebuild test -scheme SpatialPictionary -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
   ```

4. **Submit a pull request:**
   - See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines

### Coding Standards

- **Swift Style**: Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- **Concurrency**: Use Swift 6 strict concurrency
- **Architecture**: Observable pattern with unidirectional data flow
- **Comments**: Document public APIs with Swift DocC format
- **Testing**: Maintain >80% code coverage

---

## Testing

We have comprehensive test coverage across multiple categories:

- **Unit Tests** (40+ tests): Pure logic testing
- **Integration Tests** (30+ tests): System-wide functionality
- **Performance Tests** (20+ tests): 90 FPS target validation
- **UI Tests** (25+ tests): User interaction flows
- **Multiplayer Tests** (15+ tests): Network synchronization
- **Accessibility Tests** (15+ tests): VoiceOver, contrast, reduced motion

**Run all tests:**
```bash
xcodebuild test -scheme SpatialPictionary -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

See [TESTING_GUIDE.md](TESTING_GUIDE.md) for comprehensive testing documentation.

---

## Documentation

### For Users
- **[README.md](README.md)** - This file, project overview
- **[FAQ.md](FAQ.md)** - Frequently asked questions
- **[Landing Page](docs/README.md)** - Marketing website

### For Developers
- **[QUICKSTART.md](QUICKSTART.md)** - Getting started guide
- **[SOURCE_CODE_README.md](SOURCE_CODE_README.md)** - Code architecture
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - System architecture
- **[TECHNICAL_SPEC.md](TECHNICAL_SPEC.md)** - Technical specifications
- **[TESTING_GUIDE.md](TESTING_GUIDE.md)** - Testing strategies
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Contribution guidelines
- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Deployment guide

### Product & Planning
- **[PRD](spatial-pictionary-PRD.md)** - Product Requirements Document
- **[PRFAQ](Spatial-Pictionary-PRFAQ.md)** - Press Release & FAQ
- **[DESIGN.md](DESIGN.md)** - Design specifications
- **[IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md)** - 24-month roadmap
- **[CHANGELOG.md](CHANGELOG.md)** - Version history

---

## Development Timeline & Roadmap

### Phase 1: Core Game Engine (Months 1-8)
- Advanced 3D drawing and sculpting systems with hand tracking integration
- Multiplayer infrastructure for local and remote gameplay
- Basic word category library and guessing mechanics
- Social features and party game optimization

### Phase 2: Content and Features (Months 9-16)
- Extensive word category library across multiple languages and cultures
- Advanced artistic tools and creative effects systems
- Educational curriculum development and teacher training materials
- Tournament and competitive gameplay features

### Phase 3: Platform Enhancement (Months 17-24)
- AI-driven content generation and personalized word selection
- Advanced accessibility features for players with different abilities
- Professional art tool integration and creative showcasing features
- Marketing partnerships with educational institutions and family entertainment

See [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) for detailed roadmap.

## Why It's Revolutionary for Vision Pro

### Creative Expression Revolution
Spatial Pictionary demonstrates how Vision Pro can transform traditional creative activities by enabling three-dimensional artistic expression that was impossible with traditional tools, opening new possibilities for creative communication.

### Social Gaming Innovation
The app proves that spatial computing can enhance rather than isolate social gaming experiences by creating shared creative spaces that bring people together in meaningful and entertaining ways.

### Educational Entertainment Excellence
By combining artistic creation with vocabulary development and spatial reasoning, the app showcases how Vision Pro can make learning natural and enjoyable while maintaining strong educational value.

### Accessibility Through Spatial Design
The application establishes new standards for inclusive gaming by creating experiences that accommodate different artistic abilities and learning styles through spatial interaction and three-dimensional creativity.

Spatial Pictionary positions Vision Pro as the ultimate platform for creative social gaming, proving that spatial computing can enhance traditional party games while creating entirely new forms of artistic expression and social interaction.

---

## Contributing

We welcome contributions from the community! Whether it's:

- 🐛 Bug reports
- 💡 Feature requests
- 📝 Documentation improvements
- 🔧 Code contributions
- 🎨 Art and design assets
- 🌍 Translations

Please see [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

### Quick Contribution Steps

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Commit your changes (`git commit -m 'Add amazing feature'`)
7. Push to your branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

### Code of Conduct

This project adheres to a [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

---

## Support

- **Issues**: [GitHub Issues](https://github.com/akaash-nigam/visionOS_Gaming_spatial-pictionary/issues)
- **Discussions**: [GitHub Discussions](https://github.com/akaash-nigam/visionOS_Gaming_spatial-pictionary/discussions)
- **FAQ**: See [FAQ.md](FAQ.md)

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Acknowledgments

- Apple Vision Pro team for the incredible spatial computing platform
- Swift and SwiftUI teams for modern app development frameworks
- RealityKit team for 3D rendering capabilities
- SharePlay team for seamless multiplayer experiences
- Our amazing community of contributors and testers

---

## Contact

- **Project Maintainer**: Akaash Nigam
- **Repository**: [github.com/akaash-nigam/visionOS_Gaming_spatial-pictionary](https://github.com/akaash-nigam/visionOS_Gaming_spatial-pictionary)
- **Website**: Coming soon

---

<div align="center">

**Made with ❤️ for Vision Pro**

[⬆ Back to Top](#spatial-pictionary)

</div>