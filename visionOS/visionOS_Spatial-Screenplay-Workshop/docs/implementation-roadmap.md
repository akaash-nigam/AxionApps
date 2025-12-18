# Implementation Roadmap

## Overview

This document provides a detailed, sprint-by-sprint implementation roadmap for Spatial Screenplay Workshop, focusing on the MVP delivery in 8 weeks (4 two-week sprints).

---

## MVP Development: 8-Week Plan

### Sprint 0: Setup & Planning (Week -1)

**Goals**: Prepare development environment and finalize architecture

**Tasks**:
- [ ] Create Xcode project for visionOS
- [ ] Set up Git repository structure
- [ ] Configure SwiftData schema
- [ ] Set up project dependencies
- [ ] Create initial file structure
- [ ] Design system setup (colors, fonts, spacing)
- [ ] Development environment setup (simulators, test devices)

**Deliverables**:
- Empty visionOS project that compiles
- Basic file structure in place
- README with setup instructions

**Team**:
- iOS Developer: 100%
- Designer: 50%

---

### Sprint 1: Foundation & Data Layer (Weeks 1-2)

**Sprint Goal**: Build the data foundation - models, persistence, and basic CRUD

#### Week 1: Data Models

**Tasks**:
- [ ] Implement `Project` model with SwiftData
- [ ] Implement `Scene` model with SwiftData
- [ ] Implement `Character` model with SwiftData
- [ ] Implement `ScriptElement` enum and subtypes
- [ ] Create model relationships (Project → Scenes, Scenes → Characters)
- [ ] Write unit tests for models

**Code Files**:
```
Models/
├── Project.swift
├── Scene.swift
├── Character.swift
├── ScriptElement.swift
├── SlugLine.swift
└── Metadata.swift
```

**Acceptance Criteria**:
- All models conform to Codable and Identifiable
- SwiftData annotations in place
- Relationships work bidirectionally
- Models can be saved and loaded
- Unit tests pass (90%+ coverage)

#### Week 2: Persistence & Project Management

**Tasks**:
- [ ] Create `ProjectStore` actor for data access
- [ ] Implement create project
- [ ] Implement load project
- [ ] Implement save project
- [ ] Implement delete project
- [ ] Implement auto-save (5 min intervals)
- [ ] Create sample project for testing
- [ ] Write integration tests

**Code Files**:
```
Data/
├── ProjectStore.swift
├── ModelContainer+Configuration.swift
└── SampleData.swift

Tests/
├── ProjectStoreTests.swift
└── ModelTests.swift
```

**Acceptance Criteria**:
- Projects persist across app launches
- Auto-save triggers every 5 minutes
- Load time < 1 second for typical project
- No data loss on crash
- Integration tests pass

**Sprint 1 Demo**:
- Show creating a project
- Show saving/loading project
- Show auto-save in action

---

### Sprint 2: Script Editor (Weeks 3-4)

**Sprint Goal**: Build the screenplay editor with proper formatting

#### Week 3: Editor UI & Basic Formatting

**Tasks**:
- [ ] Create `ScriptEditorView` with TextEditor
- [ ] Implement `ScriptFormatter` class
- [ ] Auto-detect element types (slug, action, dialogue, etc.)
- [ ] Apply formatting rules (indentation, caps, spacing)
- [ ] Character name extraction
- [ ] Page count calculation
- [ ] Create formatting toolbar

**Code Files**:
```
Views/
├── ScriptEditor/
│   ├── ScriptEditorView.swift
│   ├── FormattingToolbar.swift
│   └── ElementTypeIndicator.swift

Business/
├── ScriptEngine/
│   ├── ScriptFormatter.swift
│   ├── ElementDetector.swift
│   ├── PageCalculator.swift
│   └── CharacterExtractor.swift
```

**Acceptance Criteria**:
- Typing "INT." auto-formats as slug line
- Typing all-caps name centers as character
- Tab key cycles through element types
- Page count updates in real-time
- Character names extracted automatically
- Formatting matches Final Draft output

#### Week 4: Advanced Editor Features

**Tasks**:
- [ ] Implement character name auto-complete
- [ ] Add scene metadata editor (summary, status)
- [ ] Create scene navigation (prev/next buttons)
- [ ] Implement undo/redo
- [ ] Add word count and statistics
- [ ] Handle dual dialogue
- [ ] Create keyboard shortcuts

**Code Files**:
```
Views/
├── ScriptEditor/
│   ├── AutoCompleteView.swift
│   ├── SceneMetadataPanel.swift
│   └── SceneNavigator.swift

ViewModels/
└── ScriptEditorViewModel.swift
```

**Acceptance Criteria**:
- Auto-complete shows after typing 2 characters
- Metadata saves with scene
- Navigation between scenes works
- Undo/redo works for all edits
- Keyboard shortcuts work (⌘S, ⌘Z, ⌘⇧Z, etc.)
- Statistics accurate

**Sprint 2 Demo**:
- Write a complete scene with proper formatting
- Show auto-complete in action
- Navigate between multiple scenes
- Show undo/redo

---

### Sprint 3: Spatial Timeline (Weeks 5-6)

**Sprint Goal**: Implement 3D scene cards and spatial interaction

#### Week 5: RealityKit Setup & Scene Cards

**Tasks**:
- [ ] Set up RealityKit scene
- [ ] Create `SceneCardEntity` class
- [ ] Implement card 3D mesh generation
- [ ] Create card material and texture
- [ ] Render scene data as texture (SwiftUI → Texture)
- [ ] Implement spatial layout algorithm
- [ ] Position cards in acts (I, II, III)

**Code Files**:
```
Views/
├── Timeline/
│   ├── TimelineView.swift
│   └── TimelineRealityView.swift

RealityKit/
├── Entities/
│   ├── SceneCardEntity.swift
│   └── TimelineContainerEntity.swift
├── Materials/
│   └── CardMaterial.swift
└── Layout/
    └── SpatialLayoutEngine.swift
```

**Acceptance Criteria**:
- Scene cards render in 3D space
- Cards display slug line, page count, characters
- Cards positioned in three acts
- Layout adapts to number of scenes
- Runs at 60+ FPS with 50 cards
- Cards visible from 2-4 meters away

#### Week 6: Interaction & Gestures

**Tasks**:
- [ ] Implement tap gesture (select card)
- [ ] Implement double-tap gesture (open editor)
- [ ] Implement drag gesture (reorder scenes)
- [ ] Add hover effects
- [ ] Add selection highlighting
- [ ] Create floating toolbar
- [ ] Implement scene deletion from timeline

**Code Files**:
```
RealityKit/
├── Gestures/
│   ├── TapHandler.swift
│   ├── DragHandler.swift
│   └── HoverHandler.swift
└── Components/
    ├── InteractionComponent.swift
    └── SelectionComponent.swift

Views/
└── Timeline/
    └── FloatingToolbar.swift

ViewModels/
└── TimelineViewModel.swift
```

**Acceptance Criteria**:
- Tap selects card (highlight visible)
- Double-tap opens editor for that scene
- Drag moves card to new position
- Scenes reorder when dropped
- Hover effect appears on gaze
- Toolbar visible and functional
- Delete confirmation works

**Sprint 3 Demo**:
- Show 20 scene cards in spatial timeline
- Select and edit a scene
- Drag a scene from Act I to Act II
- Show smooth animations and interactions

---

### Sprint 4: Integration, Export & Polish (Weeks 7-8)

**Sprint Goal**: Connect all pieces, implement PDF export, and polish for MVP release

#### Week 7: Integration & Navigation

**Tasks**:
- [ ] Create `ProjectHomeView` (project list)
- [ ] Implement project creation flow
- [ ] Implement project selection
- [ ] Connect Timeline ↔ Editor navigation
- [ ] Implement back navigation
- [ ] Add app-level state management
- [ ] Create onboarding flow
- [ ] Add empty states

**Code Files**:
```
Views/
├── ProjectHome/
│   ├── ProjectHomeView.swift
│   ├── ProjectGridItem.swift
│   └── NewProjectSheet.swift
├── Onboarding/
│   ├── WelcomeView.swift
│   └── TutorialView.swift
└── Navigation/
    └── AppNavigator.swift

ViewModels/
└── AppViewModel.swift
```

**Acceptance Criteria**:
- Can create new project from home screen
- Project list shows all saved projects
- Selecting project opens timeline
- Timeline → Editor → Timeline navigation works
- Back button returns to appropriate view
- Onboarding shown on first launch
- Empty states helpful and clear

#### Week 8: PDF Export, Testing & Polish

**Tasks**:
- [ ] Implement PDF export engine
- [ ] Create screenplay formatter for PDF
- [ ] Generate title page
- [ ] Add page numbers and scene numbers
- [ ] Implement export UI
- [ ] Comprehensive testing (100+ scenes)
- [ ] Performance optimization
- [ ] Bug fixes
- [ ] UI polish (animations, transitions)
- [ ] App icon and launch screen

**Code Files**:
```
Services/
└── Export/
    ├── PDFExporter.swift
    ├── ScreenplayFormatter.swift
    ├── TitlePageGenerator.swift
    └── PageRenderer.swift

Views/
└── Export/
    ├── ExportView.swift
    └── ExportProgressView.swift
```

**Acceptance Criteria**:
- PDF export produces production-ready script
- Formatting matches industry standard (Courier 12pt, correct margins)
- Title page includes project metadata
- Page numbering correct
- Export time < 5 seconds for 100-page script
- App runs at 60+ FPS consistently
- No crashes in 1-hour test session
- Memory usage < 1GB

**Sprint 4 Demo**:
- Complete end-to-end flow:
  1. Create new project
  2. Write 3 scenes
  3. View in spatial timeline
  4. Rearrange scenes
  5. Export to PDF
  6. Show formatted PDF
- Performance metrics (FPS, memory)

---

## MVP Release Checklist

### Technical Requirements
- [ ] Runs on visionOS 2.0+
- [ ] 60+ FPS with 50 scenes
- [ ] Memory usage < 1GB
- [ ] No crashes in 2-hour test
- [ ] Auto-save working reliably
- [ ] All core features functional

### Quality Requirements
- [ ] Unit test coverage > 80%
- [ ] Integration tests passing
- [ ] Manual QA completed
- [ ] Accessibility labels on all UI elements
- [ ] No console warnings/errors
- [ ] Performance profiled with Instruments

### Content Requirements
- [ ] App icon (1024×1024)
- [ ] Launch screen
- [ ] Tutorial/onboarding
- [ ] Sample project included
- [ ] Help documentation
- [ ] Privacy policy

### App Store Requirements
- [ ] App Store Connect account set up
- [ ] Screenshots (Vision Pro)
- [ ] App description
- [ ] Keywords
- [ ] Preview video
- [ ] Build uploaded to TestFlight

---

## Post-MVP Sprint Planning

### Sprint 5-6: Character Performance (Epic 1 - Weeks 9-11)

**Week 9: Character Profiles**
- Character creation UI
- Voice settings
- Apple Neural Voices integration
- Character list view

**Week 10: Avatar Rendering**
- Silhouette avatar generation
- Life-sized positioning
- Spatial audio setup
- Character positioning in space

**Week 11: Dialogue Playback**
- Performance view
- TTS playback
- Playback controls
- Polish and testing

**Deliverable**: Users can create characters and hear dialogue

---

### Sprint 7-10: Cloud & Collaboration (Epic 2 - Weeks 12-19)

**Week 12-13: CloudKit Setup**
- CloudKit schema
- Initial sync implementation
- Conflict detection
- Background sync

**Week 14-15: Project Sharing**
- Share sheet
- Invitation system
- Permissions model
- Collaborator management

**Week 16-17: Real-time Sync**
- Change-based sync
- Presence system
- Real-time updates
- Conflict resolution UI

**Week 18-19: Comments & Versions**
- Comment system
- Comment threads
- Version history
- Version comparison

**Deliverable**: Multi-user collaboration working

---

### Sprint 11-14: Import/Export (Epic 5 - Weeks 20-26)

**Week 20-21: Final Draft Integration**
- FDX parser
- FDX generator
- Import UI
- Export UI

**Week 22-23: Fountain Support**
- Fountain parser
- Fountain exporter
- Syntax highlighting
- Validation

**Week 24-25: Additional Formats**
- HTML export
- JSON export
- CSV export (Movie Magic)
- Shot list generator

**Week 26: Testing & Polish**
- Format compatibility testing
- Edge case handling
- Error handling
- Documentation

**Deliverable**: Professional format compatibility

---

## Development Best Practices

### Code Organization

```
SpatialScreenplayWorkshop/
├── App/
│   ├── SpatialScreenplayWorkshopApp.swift
│   └── AppState.swift
├── Models/
│   ├── Project.swift
│   ├── Scene.swift
│   └── Character.swift
├── Views/
│   ├── ProjectHome/
│   ├── Timeline/
│   ├── ScriptEditor/
│   └── Shared/
├── ViewModels/
│   ├── ProjectViewModel.swift
│   ├── TimelineViewModel.swift
│   └── ScriptEditorViewModel.swift
├── Business/
│   ├── ScriptEngine/
│   ├── CharacterManager/
│   └── ExportManager/
├── Data/
│   └── ProjectStore.swift
├── Services/
│   ├── ExportService/
│   └── VoiceService/
├── RealityKit/
│   ├── Entities/
│   ├── Components/
│   └── Systems/
├── Utilities/
│   ├── Extensions/
│   └── Helpers/
└── Resources/
    └── Assets.xcassets
```

### Git Workflow

**Branches**:
- `main`: Production-ready code
- `develop`: Integration branch
- `feature/[name]`: Feature development
- `hotfix/[name]`: Critical fixes

**Commit Messages**:
```
[Type]: Brief description

Detailed explanation if needed

Type: feat, fix, docs, style, refactor, test, chore
```

**Example**:
```
feat: Add spatial layout algorithm for scene cards

Implemented the algorithm that positions scene cards in 3D space
based on act structure. Cards are arranged left to right with
proper spacing and collision avoidance.
```

### Code Review Checklist

- [ ] Code follows Swift style guide
- [ ] No force unwrapping (use guard/if let)
- [ ] All public APIs documented
- [ ] Unit tests added/updated
- [ ] No console warnings
- [ ] Performance acceptable (tested)
- [ ] Memory leaks checked
- [ ] Accessibility considered

### Testing Strategy

**Unit Tests**:
- All models
- Business logic
- Formatters and parsers
- Utilities

**Integration Tests**:
- Data persistence
- Export functionality
- Scene ordering
- Character extraction

**UI Tests**:
- Critical user flows
- Navigation
- Gestures
- Performance

**Manual Testing**:
- Full app walkthrough
- Edge cases
- Performance testing
- Accessibility testing

---

## Monitoring & Metrics

### Development Metrics

Track weekly:
- Story points completed
- Bugs filed vs closed
- Test coverage %
- Build time
- Code review turnaround

### Performance Metrics

Monitor:
- Frame rate (target: 60+ FPS)
- Memory usage (target: < 1GB)
- Load times (target: < 1s for project)
- Export time (target: < 5s for 100 pages)

### Quality Metrics

Track:
- Crash-free rate (target: > 99%)
- Test coverage (target: > 80%)
- Bug escape rate (target: < 5%)

---

## Risk Mitigation

### Technical Risks

**RealityKit Performance**
- Mitigation: Early prototyping, LOD system, profiling
- Contingency: Reduce visual fidelity, limit card count

**SwiftData Bugs**
- Mitigation: Test extensively, follow Apple guidelines
- Contingency: Fallback to Core Data if needed

**Vision Pro Hardware Limitations**
- Mitigation: Test on device early and often
- Contingency: Reduce polygon count, optimize textures

### Schedule Risks

**Feature Creep**
- Mitigation: Strict MVP scope, defer nice-to-haves
- Contingency: Cut lowest-priority features

**Blocked by Dependencies**
- Mitigation: Identify dependencies early
- Contingency: Parallel work on independent features

**Underestimated Complexity**
- Mitigation: Add 20% buffer to estimates
- Contingency: Reduce scope or extend timeline

---

## Communication Plan

### Daily
- Stand-up (15 min)
  - What I did yesterday
  - What I'm doing today
  - Any blockers

### Weekly
- Sprint planning (Monday, 1 hour)
- Sprint review (Friday, 30 min)
- Sprint retrospective (Friday, 30 min)

### As Needed
- Technical design reviews
- Code reviews
- Pair programming sessions

---

## Success Criteria

### MVP Success
- [ ] All MVP features complete
- [ ] 100 beta testers onboarded
- [ ] 50 screenplays written
- [ ] 4.0+ TestFlight rating
- [ ] < 5% crash rate
- [ ] Ready for App Store submission

### 3-Month Success (Post-MVP)
- [ ] App Store approved and launched
- [ ] 1,000 downloads
- [ ] 100 active users
- [ ] 10 paying customers (if monetization enabled)
- [ ] 4.5+ App Store rating
- [ ] 2 additional epics completed

### 6-Month Success
- [ ] 5,000 MAU
- [ ] 500 paying customers
- [ ] Featured by Apple
- [ ] 1 film school partnership
- [ ] 4 epics completed
- [ ] Press coverage

---

**Document Version**: 1.0
**Last Updated**: 2025-11-24
**Author**: Engineering & Product Team
