# Post-MVP Epic Specifications

Detailed specifications for the 10 post-MVP epics planned for Spatial Screenplay Workshop.

---

## Epic 1: Cloud Sync & Storage (v1.1)

**Story Points**: 34 | **Priority**: High | **Timeline**: Q2 2025

### Overview
Enable seamless iCloud sync across all user devices (Vision Pro, iPad, Mac) with robust conflict resolution.

### User Stories

#### 1.1 iCloud Enable ment (8 pts)
**As a** screenwriter
**I want** my projects to automatically sync to iCloud
**So that** I can access them from any device

**Acceptance Criteria**:
- CloudKit integration configured
- Projects sync to iCloud on save
- Download projects on device login
- Sync indicator in UI
- Sync happens in background

**Technical Notes**:
- Use NSUbiquitousKeyValueStore for metadata
- CKRecord for project data
- CKAsset for large attachments

#### 1.2 Offline Support (8 pts)
**As a** screenwriter
**I want** to work offline
**So that** I can write anywhere without internet

**Acceptance Criteria**:
- All features work offline
- Changes queued for sync
- Sync when connection restored
- Offline indicator in UI
- No data loss

#### 1.3 Conflict Resolution (13 pts)
**As a** screenwriter
**I want** conflicts resolved intelligently
**So that** I don't lose work when editing on multiple devices

**Acceptance Criteria**:
- Detect conflicts on sync
- CRDT-based automatic resolution
- Manual resolution UI for complex conflicts
- Conflict history visible
- Preserve all versions

**Technical Approach**:
- Implement CRDT (Conflict-free Replicated Data Type)
- Operation-based CRDTs for text editing
- Vector clocks for causality tracking
- Three-way merge algorithm

#### 1.4 Sync Settings (5 pts)
**As a** screenwriter
**I want** to control sync behavior
**So that** I can manage bandwidth and storage

**Acceptance Criteria**:
- Enable/disable iCloud sync
- Sync over cellular toggle
- Storage usage display
- Manual sync trigger
- Sync frequency settings

---

## Epic 2: Real-Time Collaboration (v1.1)

**Story Points**: 55 | **Priority**: High | **Timeline**: Q2 2025

### Overview
Multi-user collaborative writing with live presence, voice chat, and synchronized timeline views.

### User Stories

#### 2.1 Invite Collaborators (8 pts)
**As a** screenwriter
**I want** to invite others to my project
**So that** we can write together

**Acceptance Criteria**:
- Send invite via email/iCloud
- Set collaborator permissions (view, edit, admin)
- Accept/decline invites
- See active collaborators
- Remove collaborators

#### 2.2 Live Presence (13 pts)
**As a** collaborator
**I want** to see where others are working
**So that** we avoid editing conflicts

**Acceptance Criteria**:
- See collaborator avatars on timeline
- See who's editing which scene
- Cursor positions visible in editor
- Collaborator list with status
- Activity feed

**Technical Notes**:
- WebSocket for real-time updates
- SharePlay integration for Vision Pro
- Presence heartbeat (every 30s)

#### 2.3 Synchronized Editing (21 pts)
**As a** collaborator
**I want** changes to appear in real-time
**So that** we stay in sync

**Acceptance Criteria**:
- Character-by-character sync
- Operational transformation
- < 100ms latency
- Works with undo/redo
- Graceful degradation offline

**Technical Approach**:
- Operational Transformation (OT) algorithm
- Server-side conflict resolution
- Client-side prediction
- Event sourcing for edit history

#### 2.4 Voice Chat (8 pts)
**As a** collaborator
**I want** to talk while writing
**So that** we can discuss ideas

**Acceptance Criteria**:
- Spatial audio voice chat
- Mute/unmute controls
- Push-to-talk option
- Audio quality indicator
- Record sessions (opt-in)

#### 2.5 Comments & Annotations (5 pts)
**As a** collaborator
**I want** to leave comments on scenes
**So that** we can give feedback

**Acceptance Criteria**:
- Add comments to scenes
- Reply to comments
- Resolve/close comments
- @mention collaborators
- Comment threads

---

## Epic 3: Advanced Import/Export (v1.2)

**Story Points**: 34 | **Priority**: Medium | **Timeline**: Q3 2025

### Overview
Support industry-standard formats: Fountain, Final Draft (FDX), Celtx, and PDF import with OCR.

### User Stories

#### 3.1 Fountain Import/Export (13 pts)
**As a** screenwriter
**I want** to import/export Fountain files
**So that** I can work with other tools

**Acceptance Criteria**:
- Parse Fountain syntax correctly
- Preserve all formatting
- Export to valid Fountain
- Handle Fountain metadata
- Support Fountain extensions

**Fountain Spec Coverage**:
- Scene headings
- Action
- Character names
- Dialogue
- Parentheticals
- Transitions
- Dual dialogue
- Lyrics
- Title page
- Notes and boneyard

#### 3.2 Final Draft (FDX) Import/Export (13 pts)
**As a** screenwriter
**I want** to work with Final Draft files
**So that** I can collaborate with the industry standard

**Acceptance Criteria**:
- Parse FDX XML format
- Import all screenplay elements
- Export valid FDX files
- Preserve scene numbers
- Maintain revision marks

#### 3.3 PDF Import with OCR (8 pts)
**As a** screenwriter
**I want** to import PDF screenplays
**So that** I can digitize existing scripts

**Acceptance Criteria**:
- OCR PDF text
- Detect screenplay structure
- > 95% accuracy
- Manual correction interface
- Batch import support

**Technical Stack**:
- Vision framework for OCR
- Machine learning for element detection
- User review workflow

---

## Epic 4: Voice Input & Dictation (v1.3)

**Story Points**: 21 | **Priority**: Medium | **Timeline**: Q4 2025

### User Stories

#### 4.1 Voice Dictation (13 pts)
**As a** screenwriter
**I want** to dictate dialogue
**So that** I can hear it naturally

**Acceptance Criteria**:
- Activate voice input
- Real-time transcription
- Automatic element detection
- Punctuation commands
- Language support (English, Spanish, French)

#### 4.2 Voice Commands (8 pts)
**As a** screenwriter
**I want** to control the app by voice
**So that** I can write hands-free

**Commands**:
- "New scene"
- "Delete scene"
- "Go to Act II"
- "Save project"
- "Export PDF"

---

## Epic 5: Text-to-Speech Characters (v1.3)

**Story Points**: 21 | **Priority**: Low | **Timeline**: Q4 2025

### User Stories

#### 5.1 Character Voice Assignment (8 pts)
**As a** screenwriter
**I want** to assign voices to characters
**So that** I can hear dialogue read aloud

**Acceptance Criteria**:
- Browse voice library
- Assign voice per character
- Preview voices
- Adjust speech rate/pitch
- Custom voice upload

#### 5.2 Dialogue Playback (13 pts)
**As a** screenwriter
**I want** to hear my dialogue
**So that** I can refine it

**Acceptance Criteria**:
- Play individual scenes
- Play entire script
- Spatial audio positioning
- Pause/resume controls
- Export audio file

---

## Epic 6: Advanced Analytics (v1.3)

**Story Points**: 21 | **Priority**: Low | **Timeline**: Q4 2025

### User Stories

#### 6.1 Script Analytics (13 pts)
**As a** screenwriter
**I want** detailed analytics
**So that** I can improve my script

**Metrics**:
- Dialogue vs action ratio
- Character screen time
- Scene length distribution
- Page count by act
- Reading time estimate
- Pacing visualization

#### 6.2 Character Analysis (8 pts)
**As a** screenwriter
**I want** character-specific insights
**So that** I can balance roles

**Metrics**:
- Lines per character
- Scenes per character
- Dialogue complexity
- Character arc visualization
- Bechdel test checker

---

## Epic 7: 3D Asset Integration (v2.0)

**Story Points**: 55 | **Priority**: Low | **Timeline**: Q1 2026

### User Stories

#### 7.1 USDZ Import (21 pts)
**As a** filmmaker
**I want** to import 3D models
**So that** I can visualize locations and props

**Acceptance Criteria**:
- Import USDZ files
- Attach to scenes
- Position in 3D space
- Scale and rotate
- Asset library management

#### 7.2 Virtual Location Scouting (21 pts)
**As a** filmmaker
**I want** to place virtual locations in my space
**So that** I can plan shots

**Features**:
- AR placement of models
- Measure distances
- Camera angle planning
- Lighting simulation
- Export shot list

#### 7.3 Character Holograms (13 pts)
**As a** screenwriter
**I want** life-sized character models
**So that** I can practice dialogue

**Features**:
- Life-sized avatars
- Lip-sync to TTS
- Position in room
- Trigger dialogue playback
- Multiple characters simultaneously

---

## Epic 8: Storyboard Mode (v2.0)

**Story Points**: 34 | **Priority**: Low | **Timeline**: Q1 2026

### User Stories

#### 8.1 Storyboard Creator (21 pts)
**As a** filmmaker
**I want** to create visual storyboards
**So that** I can plan shots

**Features**:
- Import/sketch frames
- Link to scenes
- Shot composition tools
- Camera movement annotations
- Export shot list

#### 8.2 Animated Preview (13 pts)
**As a** filmmaker
**I want** to see animated storyboards
**So that** I can visualize pacing

**Features**:
- Sequence frames with timing
- Transition effects
- Audio sync
- Export animatic
- VR playback

---

## Epic 9: Web Companion App (v2.0)

**Story Points**: 55 | **Priority** Medium | **Timeline**: Q1 2026

### User Stories

#### 9.1 Web Viewer (21 pts)
**As a** screenwriter
**I want** to view scripts on web
**So that** I can access from any device

**Features**:
- Read-only script view
- Print to PDF
- Share via link
- Search scripts
- Responsive design

#### 9.2 Web Editor (34 pts)
**As a** screenwriter
**I want** to edit on web
**So that** I don't need Vision Pro

**Features**:
- Full editing capabilities
- Sync with Vision Pro
- Keyboard shortcuts
- Export options
- Collaboration support

**Tech Stack**:
- Next.js frontend
- Firebase backend
- WebSocket for real-time
- Auth with Apple Sign-In

---

## Epic 10: Professional Tools (v2.1)

**Story Points**: 34 | **Priority**: Low | **Timeline**: Q2 2026

### User Stories

#### 10.1 Index Cards (13 pts)
**As a** screenwriter
**I want** digital index cards
**So that** I can outline structure

**Features**:
- Create scene cards
- Arrange on virtual board
- Color coding
- Beat sheet templates
- Export to scenes

#### 10.2 Production Reports (13 pts)
**As a** producer
**I want** production reports
**So that** I can plan shoots

**Reports**:
- Scene breakdown
- Character breakdown
- Location list
- Prop list
- Day/night split
- Budget estimates

#### 10.3 Revision Tracking (8 pts)
**As a** screenwriter
**I want** to track revisions
**So that** I can manage versions

**Features**:
- Color-coded revisions
- Revision history
- Compare versions
- Lock pages
- Production draft export

---

## Implementation Priority Matrix

| Epic | Priority | Complexity | User Value | Timeline |
|------|----------|------------|------------|----------|
| 1. Cloud Sync | High | Medium | High | Q2 2025 |
| 2. Collaboration | High | High | High | Q2 2025 |
| 3. Import/Export | Medium | Medium | High | Q3 2025 |
| 4. Voice Input | Medium | Low | Medium | Q4 2025 |
| 5. TTS Characters | Low | Low | Medium | Q4 2025 |
| 6. Analytics | Low | Low | Low | Q4 2025 |
| 7. 3D Assets | Low | High | Medium | Q1 2026 |
| 8. Storyboards | Low | Medium | Low | Q1 2026 |
| 9. Web App | Medium | High | High | Q1 2026 |
| 10. Pro Tools | Low | Medium | Medium | Q2 2026 |

---

## Resource Requirements

**Team Composition** (ideal):
- 1 iOS/visionOS Engineer (lead)
- 1 Backend Engineer (collaboration, sync)
- 1 Frontend Engineer (web app)
- 1 ML Engineer (OCR, voice)
- 1 Designer (UX/UI)
- 1 QA Engineer
- 1 Product Manager

**External Services**:
- CloudKit (Apple) - Sync
- Firebase - Web backend
- Deepgram/AssemblyAI - Voice transcription
- AWS S3 - Asset storage
- Sentry - Error tracking

---

## Success Metrics

### v1.1 (Cloud & Collaboration)
- 60% of users enable iCloud sync
- 30% of projects have collaborators
- < 1% data conflicts requiring manual resolution
- 99.9% sync success rate

### v1.2 (Import/Export)
- 40% of users import Fountain/FDX
- > 95% OCR accuracy
- 500+ file imports/month

### v1.3 (Voice & AI)
- 25% of users try voice dictation
- 10% of dialogue written by voice
- 4.5+ star rating for TTS quality

### v2.0 (Immersive)
- 15% of users add 3D assets
- 20% create storyboards
- 50% use web companion app

---

**Total Post-MVP Story Points**: 364
**Estimated Timeline**: 12-18 months
**Team**: 4-6 engineers + designer + PM
