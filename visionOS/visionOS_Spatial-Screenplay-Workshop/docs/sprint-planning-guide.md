# Sprint Planning Guide

## Overview

This guide provides practical templates and guidelines for sprint planning, story estimation, and task breakdown for Spatial Screenplay Workshop development.

---

## Story Point Estimation

### Fibonacci Scale

We use the Fibonacci sequence for story points:
**1, 2, 3, 5, 8, 13, 21**

### Point Guidelines

| Points | Complexity | Time | Example |
|--------|------------|------|---------|
| 1 | Trivial | 1-2 hours | Add a button, fix typo |
| 2 | Simple | 2-4 hours | Simple UI component, basic model |
| 3 | Moderate | 4-8 hours | View with logic, simple algorithm |
| 5 | Complex | 1-2 days | Feature with multiple components |
| 8 | Very Complex | 2-3 days | Complex feature, integration work |
| 13 | Highly Complex | 3-5 days | Major feature, needs breakdown |
| 21 | Epic | 1-2 weeks | Too large, must split |

### Estimation Factors

Consider:
- **Technical complexity**: Algorithm difficulty, new tech
- **Uncertainty**: How well-defined is the requirement?
- **Dependencies**: Blocked by other work?
- **Testing**: Unit tests, integration tests, manual testing
- **Risk**: Unfamiliar territory, potential for rework

---

## User Story Template

### Format

```
As a [user type],
I want to [action],
So that [benefit].
```

### Acceptance Criteria

```
Given [context],
When [action],
Then [expected result].
```

### Definition of Done

- [ ] Code complete and reviewed
- [ ] Unit tests written and passing
- [ ] Integration tests (if applicable)
- [ ] Documentation updated
- [ ] Tested on device/simulator
- [ ] No console warnings
- [ ] Meets acceptance criteria

---

## Sprint 1 Stories: Foundation & Data Layer

### Story 1.1: Implement Project Model

**Points**: 3

**Description**:
As a developer,
I want to implement the Project data model,
So that we can persist screenplay project data.

**Acceptance Criteria**:
- Project model includes: id, title, logline, type, metadata, settings
- Model conforms to Codable and Identifiable
- SwiftData annotations applied
- Can create, read, update project instances
- Unit tests cover all properties

**Tasks**:
- [ ] Create `Project.swift` file
- [ ] Define struct with all properties
- [ ] Add SwiftData annotations (@Model)
- [ ] Implement computed properties (if any)
- [ ] Write unit tests
- [ ] Document public API

**Estimate**: 4 hours

---

### Story 1.2: Implement Scene Model

**Points**: 5

**Description**:
As a developer,
I want to implement the Scene data model with relationships,
So that we can store screenplay scenes linked to projects.

**Acceptance Criteria**:
- Scene model includes: id, number, slug_line, content, characters, metadata
- Relationship to Project defined
- ScriptElement enum implemented
- Can add/remove scenes from project
- Unit tests cover relationships

**Tasks**:
- [ ] Create `Scene.swift` file
- [ ] Define struct with properties
- [ ] Implement `ScriptElement` enum with associated values
- [ ] Add `SlugLine` struct
- [ ] Define Project ↔ Scene relationship
- [ ] Write unit tests
- [ ] Test relationship cascade (delete project → delete scenes)

**Estimate**: 8 hours

---

### Story 1.3: Implement Character Model

**Points**: 2

**Description**:
As a developer,
I want to implement the Character data model,
So that we can track characters in scenes.

**Acceptance Criteria**:
- Character model includes: id, name, metadata
- Basic voice settings (for future use)
- Relationship to scenes
- Unit tests pass

**Tasks**:
- [ ] Create `Character.swift` file
- [ ] Define struct with properties
- [ ] Add basic voice settings struct
- [ ] Define Scene ↔ Character relationship
- [ ] Write unit tests

**Estimate**: 3 hours

---

### Story 1.4: Set Up SwiftData Persistence

**Points**: 5

**Description**:
As a developer,
I want to configure SwiftData for the app,
So that all data persists across launches.

**Acceptance Criteria**:
- ModelContainer configured
- Schema includes Project, Scene, Character
- Data persists after app termination
- Can query and filter models
- Migration strategy defined

**Tasks**:
- [ ] Create ModelContainer configuration
- [ ] Register all model types
- [ ] Configure in App struct
- [ ] Test persistence (save, quit, launch, load)
- [ ] Set up migration (for future versions)
- [ ] Write integration test

**Estimate**: 6 hours

---

### Story 1.5: Create ProjectStore

**Points**: 8

**Description**:
As a developer,
I want a ProjectStore actor for data access,
So that all data operations are centralized and thread-safe.

**Acceptance Criteria**:
- ProjectStore is an actor
- CRUD operations implemented (Create, Read, Update, Delete)
- Query methods (fetchAll, fetchById, search)
- Async/await API
- Error handling
- Unit tests for all methods

**Tasks**:
- [ ] Create `ProjectStore.swift` actor
- [ ] Implement `save(project:)` method
- [ ] Implement `fetch(id:)` method
- [ ] Implement `fetchAll()` method
- [ ] Implement `delete(id:)` method
- [ ] Implement `query(predicate:)` method
- [ ] Add error handling
- [ ] Write comprehensive tests
- [ ] Add documentation

**Estimate**: 10 hours

---

### Story 1.6: Implement Auto-Save

**Points**: 3

**Description**:
As a user,
I want my work to auto-save every 5 minutes,
So that I don't lose progress if the app crashes.

**Acceptance Criteria**:
- Timer triggers every 5 minutes
- Saves current project automatically
- Only saves if changes detected
- User sees "Saving..." indicator
- No performance impact

**Tasks**:
- [ ] Create AutoSaveManager class
- [ ] Set up Timer (5 min interval)
- [ ] Detect if project has changes
- [ ] Trigger save via ProjectStore
- [ ] Add UI indicator
- [ ] Test timer fires correctly
- [ ] Test no-op if no changes

**Estimate**: 4 hours

---

## Sprint 2 Stories: Script Editor

### Story 2.1: Create Script Editor View

**Points**: 5

**Description**:
As a user,
I want a text editor for writing screenplay scenes,
So that I can write my script.

**Acceptance Criteria**:
- Text editor displays scene content
- Can type and edit text
- Displays in Courier font
- Proper sizing for Vision Pro
- Edit saves to scene model

**Tasks**:
- [ ] Create `ScriptEditorView.swift`
- [ ] Add TextEditor component
- [ ] Style with Courier font
- [ ] Bind to scene content
- [ ] Handle save on change
- [ ] Test on simulator and device

**Estimate**: 6 hours

---

### Story 2.2: Implement Element Type Detection

**Points**: 8

**Description**:
As a user,
I want the editor to detect element types automatically,
So that my screenplay formats correctly.

**Acceptance Criteria**:
- Typing "INT." or "EXT." creates slug line
- Typing all-caps name creates character
- Regular text creates action
- Lines ending in "TO:" create transitions
- Detection happens in real-time

**Tasks**:
- [ ] Create `ElementDetector.swift`
- [ ] Implement slug line regex
- [ ] Implement character name detection (all caps)
- [ ] Implement transition detection (ends with "TO:")
- [ ] Default to action for other text
- [ ] Hook into editor
- [ ] Write comprehensive tests
- [ ] Test edge cases

**Estimate**: 10 hours

---

### Story 2.3: Implement Script Formatting

**Points**: 8

**Description**:
As a user,
I want my script elements to format correctly,
So that my screenplay follows industry standards.

**Acceptance Criteria**:
- Slug lines: all caps, 1.5" margin
- Action: regular text, 1.5" margin
- Character: centered at 3.7"
- Dialogue: 2.5" left margin
- Parentheticals: 3.1" left margin
- Formatting updates in real-time

**Tasks**:
- [ ] Create `ScriptFormatter.swift`
- [ ] Define formatting rules (margins, caps)
- [ ] Implement `format(element:)` method
- [ ] Calculate positions/indentation
- [ ] Apply formatting to TextEditor
- [ ] Test all element types
- [ ] Compare with Final Draft output

**Estimate**: 12 hours

---

### Story 2.4: Implement Page Count Calculation

**Points**: 5

**Description**:
As a user,
I want to see the page count of my screenplay,
So that I know how long my script is.

**Acceptance Criteria**:
- Page count displayed in editor
- Updates in real-time as I type
- Accurate to within 1/8 page
- Follows 1 page = 1 minute rule
- Works for all element types

**Tasks**:
- [ ] Create `PageCalculator.swift`
- [ ] Define lines-per-page constants
- [ ] Calculate element height (lines)
- [ ] Sum total pages across scenes
- [ ] Display in UI
- [ ] Write tests against known scripts
- [ ] Validate accuracy

**Estimate**: 6 hours

---

### Story 2.5: Implement Character Auto-Complete

**Points**: 5

**Description**:
As a user,
I want character names to auto-complete,
So that I can quickly write dialogue.

**Acceptance Criteria**:
- Auto-complete appears after typing 2 characters
- Shows matching character names
- Arrow keys navigate suggestions
- Enter/Tab selects suggestion
- ESC dismisses

**Tasks**:
- [ ] Create `AutoCompleteView.swift`
- [ ] Detect partial character name
- [ ] Query ProjectStore for matching characters
- [ ] Display suggestion list
- [ ] Handle keyboard navigation
- [ ] Handle selection
- [ ] Position UI near cursor
- [ ] Test with multiple characters

**Estimate**: 8 hours

---

## Sprint 3 Stories: Spatial Timeline

### Story 3.1: Set Up RealityKit Scene

**Points**: 5

**Description**:
As a developer,
I want a RealityKit scene for the timeline,
So that we can render 3D scene cards.

**Acceptance Criteria**:
- RealityView configured
- Root entity created
- Camera and lighting set up
- Scene renders without errors
- Runs at 60+ FPS (empty scene)

**Tasks**:
- [ ] Create `TimelineView.swift` with RealityView
- [ ] Create root entity
- [ ] Configure lighting
- [ ] Set up camera (if needed)
- [ ] Test rendering
- [ ] Profile performance

**Estimate**: 5 hours

---

### Story 3.2: Create Scene Card Entity

**Points**: 8

**Description**:
As a developer,
I want a SceneCardEntity that renders scene data,
So that scenes appear as 3D cards.

**Acceptance Criteria**:
- Card has quad mesh (0.4m × 0.5m)
- Card displays slug line
- Card displays page count
- Card displays characters
- Text renders clearly
- Material applied correctly

**Tasks**:
- [ ] Create `SceneCardEntity.swift`
- [ ] Generate plane mesh
- [ ] Create SwiftUI view for card content
- [ ] Render SwiftUI to texture
- [ ] Apply texture to mesh
- [ ] Add rounded corners (shader or geometry)
- [ ] Test text legibility
- [ ] Test with various scene data

**Estimate**: 12 hours

---

### Story 3.3: Implement Spatial Layout Algorithm

**Points**: 8

**Description**:
As a developer,
I want an algorithm that positions scene cards in 3D space,
So that cards are arranged logically by act structure.

**Acceptance Criteria**:
- Cards arranged in 3 acts (I, II, III)
- Act I: Left (-2m to -0.5m)
- Act II: Center (0.5m to 2m)
- Act III: Right (2.5m to 4m)
- Proper spacing between cards
- No overlaps
- Adapts to variable scene counts

**Tasks**:
- [ ] Create `SpatialLayoutEngine.swift`
- [ ] Implement `calculateLayout(scenes:)` method
- [ ] Define act boundaries
- [ ] Calculate card positions
- [ ] Handle variable act lengths
- [ ] Add spacing and padding
- [ ] Test with 10, 50, 100 scenes
- [ ] Visualize layout

**Estimate**: 10 hours

---

### Story 3.4: Implement Tap Gesture

**Points**: 5

**Description**:
As a user,
I want to tap a scene card to select it,
So that I can perform actions on that scene.

**Acceptance Criteria**:
- Tapping card selects it
- Selected card highlights (brighter, border)
- Only one card selected at a time
- Selection state persists until new card tapped
- Haptic feedback on tap

**Tasks**:
- [ ] Add InputTargetComponent to cards
- [ ] Create `TapHandler.swift`
- [ ] Detect tap events
- [ ] Update selection state
- [ ] Apply highlight effect
- [ ] Add haptic feedback
- [ ] Test on device

**Estimate**: 6 hours

---

### Story 3.5: Implement Drag to Reorder

**Points**: 13

**Description**:
As a user,
I want to drag scene cards to reorder them,
So that I can restructure my screenplay.

**Acceptance Criteria**:
- Can grab and drag any card
- Card follows hand/cursor during drag
- Other cards shift to make space
- Dropping updates scene order
- Smooth animations
- Works across acts

**Tasks**:
- [ ] Create `DragHandler.swift`
- [ ] Detect drag start (long press + move)
- [ ] Update card position during drag
- [ ] Detect drop target position
- [ ] Calculate new scene order
- [ ] Update data model
- [ ] Animate other cards shifting
- [ ] Re-layout after drop
- [ ] Test edge cases (first, last, cross-act)
- [ ] Performance test (smooth at 60 FPS)

**Estimate**: 16 hours (Consider splitting into 2 stories)

---

## Sprint 4 Stories: Integration & Export

### Story 4.1: Create Project Home View

**Points**: 5

**Description**:
As a user,
I want to see a list of my projects,
So that I can select which screenplay to work on.

**Acceptance Criteria**:
- Grid layout of project cards
- Each card shows title, type, last modified
- Tap opens project in timeline
- "New Project" button visible
- Empty state if no projects

**Tasks**:
- [ ] Create `ProjectHomeView.swift`
- [ ] Create `ProjectGridItem.swift`
- [ ] Fetch all projects from ProjectStore
- [ ] Display in grid
- [ ] Handle project selection
- [ ] Add "New Project" button
- [ ] Create empty state view

**Estimate**: 6 hours

---

### Story 4.2: Implement New Project Flow

**Points**: 3

**Description**:
As a user,
I want to create a new project,
So that I can start writing a screenplay.

**Acceptance Criteria**:
- Tapping "New Project" shows modal
- Modal has fields: title, type, author
- Can select type (Feature, TV, Short)
- Creates project in database
- Opens timeline with empty project

**Tasks**:
- [ ] Create `NewProjectSheet.swift`
- [ ] Add form fields
- [ ] Add type picker
- [ ] Hook up save action
- [ ] Navigate to timeline
- [ ] Test creating multiple projects

**Estimate**: 4 hours

---

### Story 4.3: Implement PDF Export

**Points**: 13

**Description**:
As a user,
I want to export my screenplay to PDF,
So that I can share it with producers and actors.

**Acceptance Criteria**:
- Export generates production-ready PDF
- Correct margins (1.5" left, 1" right, 1" top, 0.5" bottom)
- Courier 12pt font
- Page numbering (top right)
- Scene numbering (if enabled)
- Title page included
- Export time < 5 seconds for 100 pages

**Tasks**:
- [ ] Create `PDFExporter.swift`
- [ ] Implement title page generation
- [ ] Implement script page formatting
- [ ] Add page numbers
- [ ] Add scene numbers
- [ ] Calculate pagination
- [ ] Generate PDF data
- [ ] Save to Files app
- [ ] Create export UI
- [ ] Test with sample scripts
- [ ] Compare with Final Draft PDFs
- [ ] Performance test

**Estimate**: 20 hours (Consider splitting)

**Split Suggestion**:
- Story 4.3a: PDF Generation Engine (8 pts)
- Story 4.3b: PDF Formatting & Layout (5 pts)
- Story 4.3c: Export UI & Integration (3 pts)

---

### Story 4.4: Implement Auto-Save Indicator

**Points**: 2

**Description**:
As a user,
I want to see when my work is being saved,
So that I know my changes are persisted.

**Acceptance Criteria**:
- "Saving..." indicator appears during save
- Indicator fades after save complete
- Indicator positioned unobtrusively
- Does not block interaction

**Tasks**:
- [ ] Create save indicator view
- [ ] Connect to AutoSaveManager
- [ ] Show/hide with animation
- [ ] Position in UI
- [ ] Test timing

**Estimate**: 2 hours

---

## Task Breakdown Template

Use this template for breaking down stories into tasks:

```markdown
### Story: [Story Title]

**Points**: [1-13]

**Description**: [User story format]

**Acceptance Criteria**:
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

**Tasks**:
- [ ] Task 1 (X hours)
- [ ] Task 2 (X hours)
- [ ] Task 3 (X hours)

**Total Estimate**: X hours

**Testing Checklist**:
- [ ] Unit tests written
- [ ] Integration test (if applicable)
- [ ] Manual testing completed
- [ ] Tested on simulator
- [ ] Tested on device
- [ ] Performance acceptable
- [ ] No memory leaks

**Dependencies**:
- Story X.X must be complete
- Waiting on [person/resource]

**Risks**:
- [Potential issue and mitigation]
```

---

## Sprint Ceremonies

### Sprint Planning (Monday, 1 hour)

**Agenda**:
1. Review sprint goal (5 min)
2. Review stories in priority order (30 min)
   - Read story aloud
   - Clarify acceptance criteria
   - Estimate story points
   - Identify dependencies/risks
3. Commit to sprint scope (10 min)
4. Assign stories (10 min)
5. Break down first story into tasks (5 min)

**Output**:
- Sprint backlog finalized
- Stories estimated
- Sprint goal agreed
- First story ready to start

---

### Daily Stand-up (15 min)

**Format**:
Each person answers:
1. What did I complete yesterday?
2. What will I work on today?
3. Any blockers?

**Rules**:
- Stand-up, not sit-down
- 15 minutes max
- Problem-solve after if needed
- Update sprint board

---

### Sprint Review (Friday, 30 min)

**Agenda**:
1. Demo completed stories (20 min)
   - Show, don't tell
   - Use actual app
   - Highlight acceptance criteria met
2. Review sprint metrics (5 min)
   - Velocity (points completed)
   - Burndown chart
   - Bugs found/fixed
3. Discuss incomplete work (5 min)

**Output**:
- Stakeholders see progress
- Feedback collected
- Incomplete work moved to next sprint

---

### Sprint Retrospective (Friday, 30 min)

**Agenda**:
1. What went well? (10 min)
2. What didn't go well? (10 min)
3. Action items (10 min)

**Format** (Start/Stop/Continue):
- What should we START doing?
- What should we STOP doing?
- What should we CONTINUE doing?

**Output**:
- 1-3 actionable improvements
- Assign owners
- Review in next retro

---

## Sprint Metrics

### Velocity

Track story points completed per sprint:

| Sprint | Planned | Completed | Velocity |
|--------|---------|-----------|----------|
| 1 | 30 | 28 | 28 |
| 2 | 30 | 32 | 32 |
| 3 | 32 | 30 | 30 |
| **Avg** | | | **30** |

Use average velocity to plan future sprints.

### Burndown Chart

Track daily progress:

```
Points
40│●
  │ ●
30│  ●
  │   ●
20│    ●●
  │      ●●
10│        ●●
  │          ●●
 0└───────────────● Day
   1 2 3 4 5 6 7 8 9 10
```

Ideal: Straight line from start to zero
Actual: May vary but should trend toward zero

---

## Definition of Ready (DoR)

A story is ready for sprint if:

- [ ] User story written in standard format
- [ ] Acceptance criteria defined
- [ ] Estimated (story points)
- [ ] Dependencies identified
- [ ] Mockups/designs available (if UI)
- [ ] Technical approach discussed
- [ ] No blockers

---

## Definition of Done (DoD)

A story is done when:

- [ ] Code complete
- [ ] Code reviewed and approved
- [ ] Unit tests written and passing (if applicable)
- [ ] Integration tested
- [ ] Manually tested on simulator
- [ ] Tested on device
- [ ] Documentation updated
- [ ] No console warnings/errors
- [ ] Meets all acceptance criteria
- [ ] Product owner accepts

---

## Story Splitting Techniques

If a story is too large (13+ points), split using:

### By Workflow Steps

Original: "User can export screenplay"

Split:
- User can select export format
- User can generate PDF
- User can save PDF to Files

### By CRUD Operations

Original: "Manage characters"

Split:
- Create character
- Edit character
- Delete character
- List characters

### By Complexity

Original: "Implement drag to reorder"

Split:
- Detect drag gesture
- Move card during drag
- Update data model on drop
- Animate other cards

### By Happy/Sad Path

Original: "Import Final Draft file"

Split:
- Import valid FDX file
- Handle invalid file
- Handle parse errors
- Handle large files

---

## Estimation Poker

When the team disagrees on estimates:

1. Everyone shows estimate simultaneously
2. Highest and lowest explain reasoning
3. Discuss and re-estimate
4. Repeat until consensus (or take average)

---

## Sprint Anti-Patterns

### Avoid:

**Overcommitment**
- Problem: Committing to 50 points when velocity is 30
- Solution: Use historical velocity, add buffer

**Scope Creep**
- Problem: Adding stories mid-sprint
- Solution: Protect sprint scope, add to backlog instead

**Working on Non-Sprint Work**
- Problem: Fixing bugs not in sprint
- Solution: Time-box interruptions (10% sprint capacity)

**No Testing**
- Problem: Skipping tests to "save time"
- Solution: Tests are part of DoD, not optional

**Hero Programming**
- Problem: One person does everything
- Solution: Pair programming, knowledge sharing

---

**Document Version**: 1.0
**Last Updated**: 2025-11-24
**Author**: Agile Coach & Engineering Lead
