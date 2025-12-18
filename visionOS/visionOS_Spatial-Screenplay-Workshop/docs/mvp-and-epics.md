# MVP & Epic Breakdown

## Overview

This document defines the Minimum Viable Product (MVP) and subsequent development epics for Spatial Screenplay Workshop. The goal is to deliver value incrementally while building toward the full product vision.

## MVP Definition

### MVP Goal

Deliver a functional spatial screenplay writing tool that allows users to:
- Create and organize screenplay scenes in 3D space
- Write properly formatted screenplays
- Visualize script structure spatially
- Export to industry-standard formats

### MVP Success Criteria

- ✅ User can create a new screenplay project
- ✅ User can write scenes with proper screenplay formatting
- ✅ Scenes appear as 3D cards in spatial timeline
- ✅ User can rearrange scenes by dragging in 3D space
- ✅ User can export to PDF (production-ready)
- ✅ Projects save and load reliably
- ✅ App runs at 60+ FPS with 50 scenes

### MVP Feature Set

#### Core Features (Must Have)

**1. Project Management**
- Create new project (Feature Film, TV Pilot, Short Film)
- Save project locally
- Load existing projects
- Auto-save every 5 minutes
- Project metadata (title, author, logline)

**2. Scene Management**
- Create new scene
- Delete scene
- Edit scene content
- Scene numbering (automatic)
- Scene status (Draft, Revised, Locked)

**3. Screenplay Editor**
- Text editing with screenplay formatting
- Auto-format elements:
  - Slug lines (INT/EXT detection)
  - Action
  - Character names
  - Dialogue
  - Parentheticals
  - Transitions
- Character name auto-complete
- Page count calculation
- Scene summary field

**4. Spatial Timeline View**
- Scene cards floating in 3D space
- Arranged by acts (I, II, III)
- Basic card layout algorithm
- Tap to select scene
- Double-tap to edit scene
- Drag to reorder scenes
- Scene card displays:
  - Slug line
  - Page count
  - Character names
  - Status indicator

**5. Data Persistence**
- Local storage using SwiftData
- Project data model
- Scene data model
- Character data model (basic)

**6. Export**
- PDF export (industry-standard format)
- Proper screenplay formatting
- Page numbering
- Title page

**7. Basic UI**
- Project list view
- Timeline view (Full Space)
- Script editor view (Immersive)
- Settings panel

#### Deferred to Post-MVP

- ❌ Collaboration (real-time sync)
- ❌ Character performance (TTS, avatars)
- ❌ Location scouting (virtual environments)
- ❌ Storyboards
- ❌ CloudKit sync
- ❌ Voice commands
- ❌ Final Draft import/export
- ❌ Fountain support
- ❌ AI features

### MVP Technical Stack

**Required**:
- visionOS 2.0+
- Swift 6.0+
- SwiftUI
- RealityKit (for 3D scene cards)
- SwiftData (for persistence)

**Not Required for MVP**:
- CloudKit
- AVFoundation (TTS)
- WebRTC
- External APIs

### MVP Development Phases

#### Phase 1: Foundation (2 weeks)
- Project setup (Xcode project, basic structure)
- Data models (Project, Scene, Character)
- SwiftData persistence setup
- Basic project CRUD operations

#### Phase 2: Core Editor (2 weeks)
- Script editor UI
- Screenplay formatting engine
- Element type detection and auto-formatting
- Character name extraction

#### Phase 3: Spatial Timeline (2 weeks)
- RealityKit scene setup
- Scene card 3D rendering
- Spatial layout algorithm
- Gesture handling (tap, drag)

#### Phase 4: Integration & Polish (1 week)
- Connect editor to timeline
- Scene creation/deletion flow
- Navigation between views
- Auto-save implementation

#### Phase 5: Export & Testing (1 week)
- PDF export implementation
- Screenplay formatting validation
- Bug fixes
- Performance optimization

**Total MVP Timeline**: 8 weeks

---

## Post-MVP Epics

### Epic 1: Character Performance System

**Goal**: Bring characters to life with voice and spatial presence

**Features**:
- Character profile creation (voice settings, appearance)
- Text-to-speech integration (Apple Neural Voices)
- Life-sized character avatars (silhouette mode)
- Dialogue playback in performance view
- Spatial audio (voice from character position)
- Character blocking (position characters in space)

**Stories**:
1. As a writer, I want to create character profiles with voice settings
2. As a writer, I want to hear my dialogue spoken by characters
3. As a writer, I want to see life-sized characters in my space
4. As a writer, I want to position characters spatially for blocking

**Acceptance Criteria**:
- User can create character with name, age, gender
- User can select voice from Apple Neural Voices
- User can adjust pitch, rate, volume
- Character appears as life-sized silhouette
- Dialogue plays with spatial audio
- User can drag character to reposition

**Estimated Duration**: 3 weeks

**Dependencies**: MVP complete

---

### Epic 2: Cloud Sync & Collaboration

**Goal**: Enable multi-device access and team collaboration

**Features**:
- CloudKit integration
- Project sync across devices
- Share projects with collaborators
- Real-time presence (see who's editing)
- Comments on scenes
- Version history

**Stories**:
1. As a user, I want my projects synced across my devices
2. As a user, I want to share my project with writing partners
3. As a collaborator, I want to see what others are editing in real-time
4. As a user, I want to leave comments on scenes
5. As a user, I want to revert to previous versions

**Acceptance Criteria**:
- Projects sync to iCloud automatically
- User can invite collaborators by email
- Presence indicators show active collaborators
- Comments thread on each scene
- Version history shows last 10 versions
- User can rollback to any version

**Estimated Duration**: 4 weeks

**Dependencies**: MVP complete

---

### Epic 3: Virtual Location Scouting

**Goal**: Visualize scenes in virtual environments

**Features**:
- Location library (20+ initial environments)
- Location browser and search
- Immersive location preview
- AR overlay mode (blend virtual with real)
- Full virtual mode (complete immersion)
- Camera position markers
- Lighting adjustment

**Stories**:
1. As a director, I want to browse available locations
2. As a director, I want to preview my scene in a virtual location
3. As a director, I want to blend virtual furniture with my real room
4. As a director, I want to mark camera positions
5. As a director, I want to adjust time of day and lighting

**Acceptance Criteria**:
- Library includes 20 diverse locations
- User can search/filter locations
- Immersive preview loads in <2 seconds
- AR mode overlays virtual objects on real space
- User can place camera markers
- Lighting presets (day, night, golden hour)

**Estimated Duration**: 5 weeks

**Dependencies**: MVP complete, 3D assets library

---

### Epic 4: Storyboard & Animatic Creation

**Goal**: Pre-visualize scenes with storyboards

**Features**:
- Storyboard frame creation
- Drawing tools (PencilKit integration)
- Import images as frames
- Frame sequence editor
- Shot type and duration settings
- Animatic playback
- Export to video (MP4)
- Export to PDF

**Stories**:
1. As a director, I want to create storyboard frames for my scenes
2. As a director, I want to draw on frames with Apple Pencil
3. As a director, I want to import reference images
4. As a director, I want to set shot types and durations
5. As a director, I want to preview my animatic
6. As a director, I want to export my storyboard as video/PDF

**Acceptance Criteria**:
- User can create new storyboard for any scene
- Drawing tools work with Apple Pencil (on iPad/Mac)
- User can import images from Photos
- Shot types selectable (WS, MS, CU, OTS, POV, etc.)
- Animatic plays frames with timing
- Export MP4 at 1080p, 24fps
- Export PDF with 6 frames per page

**Estimated Duration**: 4 weeks

**Dependencies**: MVP complete

---

### Epic 5: Professional Import/Export

**Goal**: Seamless integration with industry tools

**Features**:
- Final Draft (.fdx) import
- Final Draft (.fdx) export
- Fountain (.fountain) import
- Fountain (.fountain) export
- Celtx import (basic)
- HTML export
- Movie Magic Scheduling export (CSV)
- Shot list export

**Stories**:
1. As a writer, I want to import my Final Draft scripts
2. As a writer, I want to export to Final Draft format
3. As a writer, I want to work with Fountain files
4. As a producer, I want to export scene data for scheduling
5. As a cinematographer, I want to export a shot list

**Acceptance Criteria**:
- FDX import preserves formatting and structure
- FDX export compatible with Final Draft 12+
- Fountain import/export supports full syntax
- Movie Magic CSV includes all scene details
- Shot list includes scene, shot type, description

**Estimated Duration**: 3 weeks

**Dependencies**: MVP complete

---

### Epic 6: Voice Commands & Accessibility

**Goal**: Hands-free operation and inclusive design

**Features**:
- Voice command system
- Complete VoiceOver support
- High contrast mode
- Adjustable text size
- Reduced motion mode
- Dwell control (gaze-based)
- Keyboard navigation

**Stories**:
1. As a user, I want to create scenes with voice commands
2. As a blind user, I want to use VoiceOver to write screenplays
3. As a user with motor disabilities, I want to navigate with gaze
4. As a user sensitive to motion, I want reduced animation
5. As a keyboard user, I want full keyboard navigation

**Acceptance Criteria**:
- 20+ voice commands supported
- All UI elements have VoiceOver labels
- High contrast mode meets WCAG AAA
- Text size adjustable 12-18pt
- Reduced motion disables animations
- Gaze control works for all primary actions
- All features accessible via keyboard

**Estimated Duration**: 3 weeks

**Dependencies**: MVP complete

---

### Epic 7: Advanced Character System

**Goal**: Detailed character avatars and advanced features

**Features**:
- Detailed 3D avatars (3 quality levels)
- Custom avatar import (USDZ)
- Facial animation (talking, emotions)
- Gesture library (point, shrug, nod)
- ElevenLabs voice integration (premium)
- Custom voice uploads
- Character relationship mapping

**Stories**:
1. As a writer, I want realistic character avatars
2. As a writer, I want to import custom avatars
3. As a writer, I want characters to show emotions
4. As a writer, I want premium voice quality (ElevenLabs)
5. As a writer, I want to map character relationships

**Acceptance Criteria**:
- 3 avatar quality levels (silhouette, simple, detailed)
- USDZ import for custom avatars
- Basic facial animation (talking, smiling, frowning)
- 10+ gesture animations
- ElevenLabs integration (premium feature)
- Relationship graph visualization

**Estimated Duration**: 5 weeks

**Dependencies**: Epic 1 (Character Performance System)

---

### Epic 8: AI-Powered Features

**Goal**: Enhance creativity with AI assistance

**Features**:
- Scene summary generation (from action/dialogue)
- Character description generation
- Dialogue suggestions
- Storyboard image generation (DALL-E 3)
- Script analysis (pacing, structure, characters)
- Logline generation

**Stories**:
1. As a writer, I want AI to summarize my scenes
2. As a writer, I want AI to generate character descriptions
3. As a writer, I want dialogue suggestions
4. As a director, I want AI-generated storyboard images
5. As a writer, I want AI to analyze my script structure

**Acceptance Criteria**:
- Scene summaries generated in <3 seconds
- Character descriptions match scene content
- Dialogue suggestions contextually appropriate
- Storyboard images match scene descriptions
- Script analysis provides actionable insights

**Estimated Duration**: 4 weeks

**Dependencies**: MVP complete, API integrations

---

### Epic 9: Advanced Spatial Features

**Goal**: Leverage Vision Pro capabilities fully

**Features**:
- Spatial bookmarks (save card positions)
- Custom timeline layouts
- Multi-timeline view (multiple projects)
- Spatial notes (floating annotations)
- Hand gesture shortcuts
- Eye tracking for selection
- Spatial memories (location-based saves)

**Stories**:
1. As a user, I want to save my preferred card layout
2. As a user, I want custom timeline arrangements (circular, linear, etc.)
3. As a user, I want to view multiple projects simultaneously
4. As a user, I want spatial notes that stay in position
5. As a user, I want to select cards with eye gaze

**Acceptance Criteria**:
- Spatial layouts save with project
- 3+ layout algorithms (linear, radial, grid)
- Up to 3 projects visible simultaneously
- Floating notes persist position
- Eye gaze + pinch for selection

**Estimated Duration**: 4 weeks

**Dependencies**: MVP complete

---

### Epic 10: Production Integration

**Goal**: Bridge pre-production and production

**Features**:
- Shot list generation with technical specs
- Call sheet export
- Production schedule integration
- Script breakdown (props, wardrobe, locations)
- Budget estimation (basic)
- Casting notes
- Location scouting photos/videos

**Stories**:
1. As a producer, I want to generate shot lists from storyboards
2. As a 1st AD, I want to export call sheets
3. As a production designer, I want script breakdown by department
4. As a producer, I want basic budget estimates
5. As a casting director, I want to add casting notes

**Acceptance Criteria**:
- Shot list includes shot number, type, description, duration
- Call sheet format matches industry standard
- Script breakdown categorizes elements (props, wardrobe, etc.)
- Budget estimation based on page count and location count
- Casting notes attach to characters

**Estimated Duration**: 5 weeks

**Dependencies**: Epic 3, Epic 4

---

## Priority Ranking

### Phase 1 (MVP): Foundation
**Timeline**: Weeks 1-8
- Core screenplay writing
- Spatial timeline
- Basic export

### Phase 2: Essential Enhancements
**Timeline**: Weeks 9-20 (3 months)
1. **Epic 1**: Character Performance System (3 weeks)
2. **Epic 2**: Cloud Sync & Collaboration (4 weeks)
3. **Epic 5**: Professional Import/Export (3 weeks)
4. **Epic 6**: Voice Commands & Accessibility (3 weeks)

### Phase 3: Creative Features
**Timeline**: Weeks 21-38 (4.5 months)
1. **Epic 3**: Virtual Location Scouting (5 weeks)
2. **Epic 4**: Storyboard & Animatic Creation (4 weeks)
3. **Epic 8**: AI-Powered Features (4 weeks)
4. **Epic 9**: Advanced Spatial Features (4 weeks)

### Phase 4: Advanced & Production
**Timeline**: Weeks 39-53 (3.5 months)
1. **Epic 7**: Advanced Character System (5 weeks)
2. **Epic 10**: Production Integration (5 weeks)

---

## Feature Comparison Matrix

| Feature | MVP | Post-MVP Epic |
|---------|-----|---------------|
| Create/Edit Scenes | ✅ | - |
| Spatial Timeline | ✅ | - |
| Screenplay Formatting | ✅ | - |
| PDF Export | ✅ | - |
| Local Save/Load | ✅ | - |
| Character Profiles | Basic | Epic 1, Epic 7 |
| Text-to-Speech | ❌ | Epic 1 |
| Character Avatars | ❌ | Epic 1, Epic 7 |
| CloudKit Sync | ❌ | Epic 2 |
| Collaboration | ❌ | Epic 2 |
| Comments | ❌ | Epic 2 |
| Location Scouting | ❌ | Epic 3 |
| Storyboards | ❌ | Epic 4 |
| Final Draft Import/Export | ❌ | Epic 5 |
| Fountain Support | ❌ | Epic 5 |
| Voice Commands | ❌ | Epic 6 |
| Accessibility Features | Basic | Epic 6 |
| AI Features | ❌ | Epic 8 |
| Advanced Spatial | ❌ | Epic 9 |
| Production Tools | ❌ | Epic 10 |

---

## Success Metrics

### MVP Metrics
- 100 beta testers
- 50 completed screenplays
- 4.0+ rating
- <5% crash rate
- 90%+ 60 FPS

### Post-MVP Metrics (12 months)
- 5,000 MAU
- 1,000 paying subscribers (20% conversion)
- 500 completed screenplays
- 4.5+ rating
- Featured by Apple
- 2+ film schools using it

---

## Development Resources

### MVP Team (Recommended)
- 1 iOS/visionOS Developer
- 1 3D/RealityKit Developer
- 1 Designer (UI/UX)
- 1 QA Tester

### Post-MVP Team
- Same as MVP + 1 Backend Developer (for collaboration)

### External Resources
- 3D Asset Artists (for location library)
- Voice Actor Database (for character voices)
- Beta Testers (screenwriters, film students)

---

## Risk Assessment

### MVP Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| RealityKit performance issues | Medium | High | Early prototyping, LOD system |
| Screenplay formatting complexity | Low | Medium | Reference Final Draft format |
| Vision Pro adoption slow | High | High | Also support Mac/iPad |
| PDF export formatting errors | Medium | Medium | Extensive testing, reference scripts |

### Post-MVP Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Collaboration sync conflicts | High | High | CRDT implementation, thorough testing |
| TTS quality insufficient | Medium | Medium | Multiple voice providers |
| 3D asset creation cost | High | Medium | Start with library, expand based on demand |
| AI API costs high | Medium | Medium | Cache responses, rate limiting |

---

## Next Steps

1. **Review & Approve MVP Scope**: Ensure stakeholders agree on MVP features
2. **Set Up Development Environment**: Xcode, visionOS simulator, version control
3. **Create Sprint Plan**: Break MVP Phase 1 into 2-week sprints
4. **Begin Development**: Start with data models and project structure
5. **Weekly Progress Reviews**: Track against 8-week MVP timeline

---

**Document Version**: 1.0
**Last Updated**: 2025-11-24
**Author**: Product Management & Engineering Team
