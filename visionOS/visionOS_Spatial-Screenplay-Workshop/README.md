# Spatial Screenplay Workshop

> Professional screenwriting reimagined for spatial computing on Apple Vision Pro

[![visionOS](https://img.shields.io/badge/visionOS-2.0+-blue.svg)](https://developer.apple.com/visionos/)
[![Swift](https://img.shields.io/badge/Swift-6.0+-orange.svg)](https://swift.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Status](https://img.shields.io/badge/Status-MVP_Complete-success.svg)]()

## 📖 Overview

Spatial Screenplay Workshop is a groundbreaking visionOS application that brings professional screenwriting into the era of spatial computing. Write industry-standard screenplays with an immersive 3D timeline where scenes float in space, organized by acts, and interact naturally with gestures and voice.

### Why Spatial Computing for Screenwriting?

- **Visualize Story Structure**: See your entire screenplay laid out in 3D space, with scenes organized by acts at different depths
- **Natural Interactions**: Tap to select, drag to reorder, gaze to highlight - writing feels more intuitive than ever
- **Distraction-Free Focus**: Immersive environment lets you focus on your story without desktop clutter
- **Spatial Memory**: Leverage your brain's spatial memory to remember scene positions and story flow

---

## ✨ Features

### MVP (v1.0) - ✅ Complete

#### 📝 Professional Script Editor
- ✅ Industry-standard formatting (Courier 12pt, proper margins)
- ✅ Automatic element detection (slug lines, character names, dialogue, action, transitions)
- ✅ Real-time page count (55 lines per page standard)
- ✅ Character name auto-complete
- ✅ Scene metadata editor (summary, mood, notes, status)
- ✅ Undo/redo with 50-action history
- ✅ Keyboard shortcuts (Cmd+Z, Cmd+Shift+Z, Cmd+I)
- ✅ Word count and statistics

#### 🎬 3D Spatial Timeline
- ✅ Scene cards rendered as 3D entities in RealityKit
- ✅ Act-based organization (Act I, II, III) with depth layering
- ✅ Color-coded by status (draft, revision, locked, final)
- ✅ Tap gesture to select scenes
- ✅ Double-tap to open editor
- ✅ Drag & drop to reorder scenes
- ✅ Hover effects with eye tracking
- ✅ Floating toolbar for scene actions

#### 💾 Data Management
- ✅ SwiftData persistence layer
- ✅ Auto-save every 5 minutes
- ✅ Project and scene CRUD operations
- ✅ Thread-safe data access with @ModelActor
- ✅ Sample data generation

#### 📄 Export & Sharing
- ✅ PDF export with industry-standard formatting
- ✅ Professional title pages
- ✅ Page and scene numbering
- ✅ Ready-to-share with producers

### Post-MVP Roadmap

See [docs/mvp-and-epics.md](docs/mvp-and-epics.md) for detailed post-MVP features including:
- 🔄 iCloud sync
- 🎤 Voice input and dictation
- 👥 Real-time collaboration
- 📦 Fountain & FDX import/export
- 🗣️ Text-to-speech character voices
- 🎨 3D asset integration
- 📊 Advanced analytics
- 🌐 Web companion app

---

## 🏗️ Architecture

### System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        visionOS App                          │
├─────────────────────────────────────────────────────────────┤
│                    Presentation Layer                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ ProjectList  │  │   Timeline   │  │ ScriptEditor │      │
│  │    View      │  │  RealityView │  │     View     │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
├─────────────────────────────────────────────────────────────┤
│                   Application Layer                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   AppState   │  │  Timeline    │  │ ScriptEditor │      │
│  │  (Observable)│  │  ViewModel   │  │  ViewModel   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
├─────────────────────────────────────────────────────────────┤
│                    Business Layer                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Element    │  │    Script    │  │     Page     │      │
│  │  Detector    │  │  Formatter   │  │  Calculator  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
├─────────────────────────────────────────────────────────────┤
│                      Data Layer                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Project    │  │    Scene     │  │  Character   │      │
│  │    @Model    │  │   @Model     │  │   @Model     │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│  ┌──────────────────────────────────────────────────┐      │
│  │         ProjectStore (@ModelActor)                │      │
│  │         SwiftData ModelContainer                  │      │
│  └──────────────────────────────────────────────────┘      │
├─────────────────────────────────────────────────────────────┤
│                   RealityKit Layer                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ SceneCard    │  │  Timeline    │  │   Spatial    │      │
│  │   Entity     │  │  Container   │  │   Layout     │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │     Tap      │  │     Drag     │  │    Hover     │      │
│  │   Handler    │  │   Handler    │  │   Handler    │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow

```
User Interaction → Gesture Handler → View Model → Business Logic
                                           ↓
                                      Data Layer
                                           ↓
                                   SwiftData/Disk
                                           ↓
                                   Auto-save (5min)
```

### 3D Timeline Spatial Layout

```
                    ACT I (z=0.0)
        ┌────┐  ┌────┐  ┌────┐  ┌────┐
        │ S1 │  │ S2 │  │ S3 │  │ S4 │
        └────┘  └────┘  └────┘  └────┘

                ACT II (z=-0.5)
    ┌────┐  ┌────┐  ┌────┐  ┌────┐  ┌────┐
    │ S5 │  │ S6 │  │ S7 │  │ S8 │  │ S9 │
    └────┘  └────┘  └────┘  └────┘  └────┘

                ACT III (z=-1.0)
        ┌────┐  ┌────┐  ┌────┐  ┌────┐
        │S10 │  │S11 │  │S12 │  │S13 │
        └────┘  └────┘  └────┘  └────┘
```

---

## 📁 Project Structure

```
SpatialScreenplayWorkshop/
├── Models/                          # SwiftData @Model classes
│   ├── ProjectType.swift           # Project types, enums
│   ├── SlugLine.swift              # Scene heading structure
│   ├── ScriptElement.swift         # All screenplay elements
│   ├── SpatialCoordinates.swift    # 3D positioning
│   ├── Metadata.swift              # Project/scene metadata
│   ├── Character.swift             # Character model
│   ├── Scene.swift                 # Scene model
│   └── Project.swift               # Top-level project
│
├── Data/                           # Persistence layer
│   ├── ProjectStore.swift          # Thread-safe CRUD (@ModelActor)
│   ├── ModelContainer+Config.swift # SwiftData setup
│   └── SampleData.swift            # Test data generation
│
├── Business/                       # Business logic
│   └── ScriptEngine/
│       ├── ElementDetector.swift   # Detect element types
│       ├── ScriptFormatter.swift   # Industry formatting
│       └── PageCalculator.swift    # Page count calculation
│
├── Views/                          # SwiftUI views
│   ├── ScriptEditor/
│   │   ├── ScriptEditorView.swift
│   │   ├── CharacterAutoComplete.swift
│   │   └── SceneMetadataPanel.swift
│   └── Timeline/
│       ├── TimelineView.swift
│       ├── TimelineRealityView.swift
│       └── FloatingToolbar.swift
│
├── ViewModels/                     # @Observable view models
│   └── TimelineViewModel.swift
│
├── RealityKit/                     # 3D spatial features
│   ├── Entities/
│   │   ├── SceneCardEntity.swift   # 3D scene cards
│   │   └── TimelineContainerEntity.swift
│   ├── Layout/
│   │   └── SpatialLayoutEngine.swift
│   ├── Gestures/
│   │   ├── TapHandler.swift
│   │   ├── DragHandler.swift
│   │   └── HoverHandler.swift
│   └── Components/
│       ├── InteractionComponent.swift
│       └── SelectionComponent.swift
│
├── Services/                       # External services
│   └── Export/
│       ├── PDFExporter.swift       # PDF generation
│       ├── ScreenplayFormatter.swift
│       └── TitlePageGenerator.swift
│
├── Utilities/                      # Utilities
│   ├── AutoSaveManager.swift       # Auto-save timer
│   └── EditorUndoManager.swift     # Undo/redo system
│
└── App/                           # App entry point
    ├── SpatialScreenplayWorkshopApp.swift
    └── AppState.swift             # Global app state

docs/                              # Documentation
├── data-model-schema.md           # Data structures
├── technical-architecture.md      # System architecture
├── spatial-ux-specifications.md   # UX guidelines
├── integration-specifications.md  # File formats
├── collaboration-architecture.md  # Multi-user design
├── 3d-assets-rendering.md         # 3D pipeline
├── file-format-specifications.md  # Import/export
├── mvp-and-epics.md              # Product roadmap
├── implementation-roadmap.md      # Sprint plan
├── sprint-planning-guide.md       # Story points
├── TESTING.md                     # Test documentation
└── landing-page.html             # Marketing page

SpatialScreenplayWorkshopTests/    # Unit tests
└── SpatialLayoutEngineTests.swift
```

---

## 🚀 Getting Started

### Prerequisites

- **macOS** 14.0+ (Sonoma or later)
- **Xcode** 16.0+ with visionOS SDK
- **Apple Vision Pro** device or simulator
- **Swift** 6.0+

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/visionOS_Spatial-Screenplay-Workshop.git
   cd visionOS_Spatial-Screenplay-Workshop
   ```

2. **Open in Xcode**
   ```bash
   open SpatialScreenplayWorkshop.xcodeproj
   ```

3. **Select target**
   - Select "Apple Vision Pro" simulator or connected device
   - Build scheme: SpatialScreenplayWorkshop

4. **Build and run**
   - Press `Cmd+R` or click Run
   - First build may take 2-3 minutes

### Running Tests

```bash
# Run all tests
xcodebuild test \
  -scheme SpatialScreenplayWorkshop \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

# Run specific test suite
xcodebuild test \
  -scheme SpatialScreenplayWorkshop \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:SpatialScreenplayWorkshopTests/SpatialLayoutEngineTests
```

See [docs/TESTING.md](docs/TESTING.md) for comprehensive testing guide.

---

## 💻 Development

### Technology Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Platform** | visionOS 2.0+ | Spatial computing OS |
| **Language** | Swift 6.0+ | Type-safe, modern language |
| **UI Framework** | SwiftUI | Declarative UI |
| **3D Rendering** | RealityKit | Spatial entities & gestures |
| **Spatial Tracking** | ARKit | Eye tracking, hand tracking |
| **Persistence** | SwiftData | Modern Core Data wrapper |
| **Concurrency** | Swift Concurrency | Async/await, actors |
| **PDF Generation** | UIGraphicsPDFRenderer | Industry-standard export |

### Code Style

- **SwiftLint** for style enforcement
- **Swift 6 concurrency** (strict mode)
- **@Observable** macro for reactive state
- **@Model** macro for SwiftData entities
- **@ModelActor** for thread-safe operations

### Performance Targets

- **Frame Rate**: 60+ FPS consistently
- **Memory**: < 1GB for 100-scene project
- **Auto-save**: < 100ms operation time
- **PDF Export**: < 5 seconds for 100-page script
- **Scene Cards**: Support 50+ cards without lag

### Key Design Patterns

1. **MVVM Architecture**: Views + ViewModels + Models
2. **Unidirectional Data Flow**: View → ViewModel → Model → View
3. **Actor Isolation**: Thread-safe data access with @ModelActor
4. **Component-Based Entities**: RealityKit components for modularity
5. **Dependency Injection**: Pass dependencies explicitly

---

## 📊 Implementation Status

### Sprint 1: Foundation & Data Layer ✅
- [x] SwiftData models (Project, Scene, Character)
- [x] ProjectStore with thread-safe operations
- [x] Auto-save manager
- [x] App shell and navigation

**31 story points** | **Status**: Complete

### Sprint 2: Script Editor ✅
- [x] Element auto-detection
- [x] Industry-standard formatting
- [x] Page count calculation
- [x] Character auto-complete
- [x] Scene metadata editor
- [x] Undo/redo system

**31 story points** | **Status**: Complete

### Sprint 3: Spatial Timeline ✅
- [x] RealityKit scene setup
- [x] 3D scene card entities
- [x] Spatial layout engine
- [x] Tap/drag/hover gestures
- [x] Floating toolbar
- [x] Scene reordering

**38 story points** | **Status**: Complete

### Sprint 4: Export & Polish ✅
- [x] PDF export engine
- [x] Title page generation
- [x] Professional formatting
- [x] Landing page

**20 story points** | **Status**: Complete

### Total: 120/120 story points (100%)

---

## 🗺️ Roadmap

### v1.1 - Cloud & Collaboration (Q2 2025)
- iCloud sync across devices
- Real-time collaboration (multi-user)
- Conflict resolution with CRDT
- Voice chat during collaboration

### v1.2 - Advanced Import/Export (Q3 2025)
- Fountain format support
- Final Draft (FDX) import/export
- Celtx integration
- PDF import with OCR

### v1.3 - Voice & AI (Q4 2025)
- Voice input and dictation
- Text-to-speech character voices
- AI-powered suggestions
- Scene analysis and insights

### v2.0 - Immersive Features (Q1 2026)
- 3D asset integration (USDZ)
- Virtual location scouting
- Character hologram practice
- Animated storyboards

See [docs/mvp-and-epics.md](docs/mvp-and-epics.md) for detailed epic breakdown.

---

## 📝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Quick Start for Contributors

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Write tests for new features
5. Ensure all tests pass
6. Submit a pull request

### Areas for Contribution

- 🐛 Bug fixes
- ✨ New features from roadmap
- 📚 Documentation improvements
- 🎨 UI/UX enhancements
- ⚡ Performance optimizations
- 🧪 Additional test coverage

---

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) for details.

---

## 🙏 Acknowledgments

- Apple for visionOS and spatial computing platform
- Screenwriting community for feedback and requirements
- Open source Swift community

---

## 📞 Support

- 📧 Email: support@spatialscreenplay.app
- 🐦 Twitter: [@SpatialScreenplay](https://twitter.com/SpatialScreenplay)
- 💬 Discord: [Join our community](https://discord.gg/spatialscreenplay)
- 📖 Docs: [docs.spatialscreenplay.app](https://docs.spatialscreenplay.app)

---

## 🏆 Credits

Created with ❤️ for screenwriters everywhere.

Built using [Claude Code](https://claude.ai/code) - AI-powered development assistant.

---

**Status**: MVP Complete - Ready for Testing
**Version**: 1.0.0-beta
**Last Updated**: November 2025

