# Product Requirements Document: Spatial Screenplay Workshop

## Executive Summary

Spatial Screenplay Workshop revolutionizes screenwriting for Apple Vision Pro by enabling scenes to float in timeline around the room, characters to stand life-sized for dialogue practice, locations to be scouted through virtual/real blend, and storyboards to animate in sequence—transforming script writing from a linear text document into an immersive spatial experience.

## Product Vision

Empower screenwriters, filmmakers, and storytellers to write better scripts by visualizing scenes spatially, interacting with characters in 3D, scouting locations virtually, and animating storyboards—bringing the screenplay to life before production begins.

## Target Users

### Primary Users
- Screenwriters (feature films, TV, shorts)
- TV show creators and showrunners
- Film directors who write their own scripts
- Film school students
- Playwright adapters

### Secondary Users
- Story editors and script supervisors
- Producers reviewing scripts
- Actors preparing roles
- Storyboard artists

## Market Opportunity

- Screenwriting software market: $500M+ (Final Draft dominates)
- 50,000+ professional screenwriters in US
- 300,000+ aspiring screenwriters globally
- Film and TV production: $250B industry
- Film schools: 1,000+ programs worldwide

## Core Features

### 1. Floating Scene Cards in Timeline

**Description**: Each scene appears as a 3D card floating in spatial timeline around the room, showing key info and enabling spatial rearrangement

**User Stories**:
- As a screenwriter, I want to see my script's structure visually
- As a director, I want to rearrange scenes spatially to find best flow
- As a TV writer, I want to organize episodes across a season arc

**Acceptance Criteria**:
- Each scene = floating card with: slug line, page count, characters, location
- Timeline layout: Left to right, Act I → Act II → Act III
- Color-coded by location, time of day, or character focus
- Drag scenes to reorder
- Pinch to zoom into scene details or out to full script view
- Scene card shows status (draft, revised, locked)
- Quick jump to scriptwriting mode

**Technical Requirements**:
- RealityKit for 3D card rendering
- Timeline layout algorithm
- Gesture recognition for drag/reorder
- SwiftUI for card content
- Real-time script parsing

**Scene Card Design**:
```
┌──────────────────────────┐
│ INT. COFFEE SHOP - DAY   │ ← Slug line
│                          │
│ 2.5 pages                │
│ Characters: ALEX, SARAH  │
│ Location: Coffee Shop    │
│                          │
│ Summary: Alex reveals    │
│ secret to Sarah...       │
│                          │
│ Status: 🟢 Locked        │
│ [Edit] [Delete] [Notes]  │
└──────────────────────────┘

Timeline Layout (Top View):
┌─────┬─────┬─────┬─────┐
│ S1  │ S2  │ S3  │ S4  │  Act I
└─────┴─────┴─────┴─────┘
       ┌─────┬─────┬─────┬─────┐
       │ S5  │ S6  │ S7  │ S8  │  Act II
       └─────┴─────┴─────┴─────┘
              ┌─────┬─────┐
              │ S9  │ S10 │      Act III
              └─────┴─────┘

Color Coding Options:
- By Location: All coffee shop scenes = brown
- By Time: Day = yellow, night = dark blue
- By Character: Alex scenes = red, Sarah = blue
- By Story Thread: A-plot, B-plot, C-plot
- By Status: Draft, revised, locked
```

### 2. Life-Sized Character Dialogue

**Description**: Characters appear as life-sized holograms in the room, enabling writers to hear and refine dialogue naturally

**User Stories**:
- As a writer, I want to hear my dialogue spoken aloud to test if it sounds natural
- As a director, I want to block scenes with character positions
- As an actor, I want to rehearse lines with virtual scene partners

**Acceptance Criteria**:
- Create character profiles (name, appearance, voice)
- Characters appear life-sized when scene is activated
- Text-to-speech delivers dialogue in character voice
- Adjustable voice: pitch, speed, accent
- Characters positioned where they'd stand in scene
- Dialogue pacing adjustments
- Record performances for review
- Switch between characters to read all parts

**Technical Requirements**:
- RealityKit character rendering
- High-quality text-to-speech (ElevenLabs API or Apple Neural Voices)
- Voice customization
- Spatial audio (dialogue comes from character position)
- Character animation (basic gestures, lip sync)

**Character Features**:
```
Character Profile:
┌──────────────────────────┐
│ Character: ALEX CHEN     │
│ Age: 28                  │
│ Gender: Non-binary       │
│                          │
│ Voice:                   │
│ • Type: Neutral, warm    │
│ • Pitch: Medium          │
│ • Speed: Natural         │
│ • Accent: American       │
│                          │
│ Appearance:              │
│ • Height: 5'7"           │
│ • Build: Athletic        │
│ • Avatar: [Select]       │
│                          │
│ Scenes: 15               │
│ Lines: 234               │
└──────────────────────────┘

Dialogue Performance:
Scene 3: Coffee Shop
                    ALEX
           I need to tell you something.

[Character appears life-sized, positioned in room]
[Speaks line in customized voice]
[Writer evaluates if dialogue sounds natural]

Controls:
- [▶️ Play Scene] - All characters perform
- [⏸️ Pause] - Stop at current line
- [⏮️ Previous] - Go back one line
- [⏭️ Next] - Skip to next line
- [🎙️ Record] - Record this reading
- [Edit Dialogue] - Jump to script

Blocking:
- Position character where they'd stand
- Add movement markers (walk to door, sit down)
- Camera angle visualization (director's POV)
```

### 3. Virtual/Real Location Scouting

**Description**: Blend virtual locations with real room or explore fully virtual environments for scene settings

**User Stories**:
- As a writer, I want to visualize my coffee shop scene in a real space
- As a director, I want to scout locations without leaving home
- As a production designer, I want to test different location aesthetics

**Acceptance Criteria**:
- Library of 100+ virtual locations (café, office, apartment, street, etc.)
- Overlay virtual location on user's physical room
- Fully immersive mode (replace room entirely)
- Customize location details (furniture, props, lighting)
- Take reference photos/videos
- Mark camera positions and angles
- Measure space for physical production planning
- Import custom 3D models (SketchUp, Unreal Engine)

**Technical Requirements**:
- ARKit scene understanding
- RealityKit for virtual environments
- 3D asset library
- Spatial anchoring
- Camera path recording
- 3D model import (USDZ, OBJ)

**Location Library**:
```
Interior Locations:
- 🏠 Residential: Apartment, house, loft, mansion
- ☕ Commercial: Coffee shop, restaurant, bar, hotel
- 🏢 Office: Corporate, startup, home office, cubicles
- 🏥 Institutional: Hospital, school, police station, courthouse
- 🏪 Retail: Store, mall, grocery, boutique
- 🎭 Entertainment: Theater, museum, gallery, cinema

Exterior Locations:
- 🌳 Nature: Forest, beach, mountain, desert, park
- 🏙️ Urban: City street, alley, rooftop, subway, parking lot
- 🏘️ Suburban: Neighborhood, yard, driveway, playground
- 🚗 Vehicles: Car interior, train, plane, boat

Time/Weather Variants:
- Day / Night
- Golden hour / Blue hour
- Clear / Rainy / Snowy / Foggy

Location Scout Mode:
┌────────────────────────┐
│ Scene 5: Coffee Shop   │
│                        │
│ Location: The Bean     │
│ [Change Location]      │
│                        │
│ Lighting: Natural day  │
│ [Adjust]               │
│                        │
│ Camera Angles:         │
│ • Wide establish       │
│ • Over-shoulder        │
│ • Close-up Alex        │
│                        │
│ [Save Setup]           │
│ [Export to Production] │
└────────────────────────┘

Customization:
- Furniture placement
- Wall color and textures
- Decorations and props
- Lighting (warm, cool, dramatic)
- Weather effects
- Time of day
```

### 4. Animated Storyboard Sequence

**Description**: Convert script scenes into animated storyboard sequences with camera movements and timing

**User Stories**:
- As a director, I want to pre-visualize my film before shooting
- As a cinematographer, I want to plan camera movements
- As a writer, I want to see if my scene pacing works visually

**Acceptance Criteria**:
- Auto-generate storyboard frames from scene description
- Manual drawing/sketching on frames (Apple Pencil support)
- Import images or AI-generated frames
- Arrange frames in sequence
- Add camera movements (pan, tilt, dolly, zoom)
- Set shot duration and transitions
- Playback as animatic (timed sequence)
- Export as video or PDF shot list

**Technical Requirements**:
- PencilKit for drawing
- AI image generation (DALL-E or Midjourney API) optional
- Animation timeline engine
- Video export (AVFoundation)
- PDF generation

**Storyboard Features**:
```
Shot Types:
- Wide Shot (WS): Establishing, full scene
- Medium Shot (MS): Waist up
- Close-Up (CU): Face, details
- Over-the-Shoulder (OTS): Dialogue scenes
- Point of View (POV): Character perspective
- Insert: Object detail
- Two-Shot: Two characters

Camera Movements:
- Pan: Left/right
- Tilt: Up/down
- Dolly: In/out
- Tracking: Follow character
- Crane: Vertical movement
- Static: No movement

Storyboard Frame:
┌─────────────────────────┐
│  [Sketch/Image Area]    │
│                         │
│                         │
│                         │
└─────────────────────────┘
Shot #5: WS - Coffee Shop
Duration: 3 seconds
Camera: Dolly in slowly
Dialogue: "I need to tell you something."
Notes: Warm lighting, morning

Animatic Playback:
Frame 1 → Frame 2 → Frame 3 → ...
[Duration timed, transitions applied]
[Optional: Add temp music, sound effects]

Export Options:
- PDF: Shot list with frames
- Video: Animatic MP4
- Images: Individual frames (PNG sequence)
- JSON: Shot data for production software
```

### 5. Collaborative Writing Sessions

**Description**: Multiple writers co-write in shared spatial environment with real-time updates

**User Stories**:
- As writing partners, we want to collaborate remotely in the same virtual room
- As a showrunner, I want to lead a writers' room in spatial mode
- As a script editor, I want to review scenes with the writer

**Acceptance Criteria**:
- Invite collaborators to shared script
- Real-time scene card updates (see others' changes)
- Voice chat with spatial audio
- Avatars show where collaborators are looking
- Comments and notes attached to scenes
- Version history and rollback
- Permissions (owner, writer, editor, viewer)
- Export collaborative notes for meetings

**Technical Requirements**:
- SharePlay or custom WebRTC
- CloudKit for sync
- Real-time collaboration engine
- Conflict resolution (concurrent edits)
- Voice chat integration

**Collaboration Features**:
```
Writers' Room Mode:
- Host creates session
- Invites up to 8 participants
- Everyone sees same scene timeline
- Voice discussion with spatial audio
- Pointing/highlighting gestures visible to all

Roles:
- Showrunner/Host: Full control
- Staff Writer: Edit assigned scenes
- Script Editor: Comment and suggest
- Producer: View only, approve

Real-Time Updates:
"Jane is editing Scene 7"
"Mark added Scene 12"
"Sarah left a comment on Scene 3"

Comment Thread:
┌─────────────────────────┐
│ 💬 Scene 5 Discussion   │
│                         │
│ Mark: This dialogue     │
│ feels forced            │
│ 10 min ago              │
│                         │
│ Jane: Agreed, let's     │
│ simplify it             │
│ 5 min ago               │
│                         │
│ You: Done, check v2     │
│ Just now                │
└─────────────────────────┘

Version Control:
- Auto-save every 5 minutes
- Manual save points
- Version history browser
- Compare versions side-by-side
- Rollback to previous version
```

### 6. Professional Scriptwriting Tools

**Description**: Standard industry formatting with templates, auto-formatting, and export options

**User Stories**:
- As a professional writer, I need industry-standard formatting
- As a producer, I need PDFs formatted for production
- As a writer, I want templates for features, TV, shorts

**Acceptance Criteria**:
- Templates: Feature film, TV pilot, TV spec, short film
- Auto-formatting: Sluglines, action, dialogue, parentheticals
- Character name auto-complete
- Scene numbering
- Page count estimation (1 page = 1 minute screen time)
- Export: PDF, Final Draft (.fdx), Fountain (.fountain)
- Title page generation
- Revision colors (white, blue, pink, yellow, green, goldenrod)

**Technical Requirements**:
- Script formatting engine
- Export to industry formats (FDX, Fountain)
- PDF generation with proper margins
- Courier font (industry standard)

**Formatting Features**:
```
Industry-Standard Format:

    INT. COFFEE SHOP - DAY

    ALEX sits across from SARAH, nervous.

                        ALEX
                 (hesitant)
           I need to tell you something.

    Sarah looks up from her coffee, concerned.

                        SARAH
           What is it?

Element Types:
- Slug Line: ALL CAPS, INT/EXT, location, time
- Action: Regular text, present tense
- Character: ALL CAPS, centered
- Parenthetical: (emotion/action), centered under character
- Dialogue: Centered under character
- Transition: FADE TO:, CUT TO:, etc.

Auto-Formatting:
- Type "INT" → Auto-formats as slug line
- Type character name → Auto-centers
- Tab key cycles through elements
- Spacebar triggers auto-complete

Templates:
- Feature Film: 90-120 pages, 3-act structure
- TV Pilot (1 hour): 50-65 pages, acts marked
- TV Pilot (30 min): 25-35 pages
- Short Film: 5-15 pages

Export:
- PDF: Production-ready, Courier 12pt
- Final Draft: .fdx (industry standard software)
- Fountain: Plain text markup (open format)
- HTML: Web viewing
```

## User Experience

### Onboarding
1. Create new project: Feature film, TV pilot, short
2. Enter title, logline
3. Create character profiles
4. Tutorial: Add first scene, write dialogue
5. Tutorial: Position scene card in timeline
6. Tutorial: Hear characters speak dialogue
7. Ready to write

### Writing Session
1. Open Spatial Screenplay Workshop
2. See scene timeline floating around room
3. Walk to Act II, notice scene 7 needs work
4. Tap scene 7 card → enters edit mode
5. Revise dialogue
6. Summon characters to hear new lines
7. Sounds better, save
8. Drag scene 7 to different position in timeline
9. Better flow, continue writing
10. Session auto-saved

### Gesture & Voice Controls

```
Gestures:
- Tap scene card: Open/edit scene
- Drag card: Reorder in timeline
- Pinch: Zoom timeline
- Double-tap: Enter immersive writing mode

Voice:
- "Create new scene"
- "Summon characters for scene 7"
- "Play scene 12 dialogue"
- "Export script to PDF"
```

## Design Specifications

### Visual Design

**Color Palette**:
- Primary: Navy Blue #1A237E (professional, creative)
- Secondary: Gold #FFB300 (creativity, awards)
- Background: Dark mode (focus on writing)

**Typography**:
- Script: Courier (industry standard)
- UI: SF Pro

### Spatial Layout

**Timeline View**: Scenes arranged horizontally in acts
**Writing View**: Full-screen text editor, minimal UI
**Performance View**: Characters in room, scene card nearby

## Technical Architecture

### Platform
- Apple Vision Pro (visionOS 2.0+)
- Companion Mac app (for keyboard typing)
- Swift, SwiftUI, RealityKit

### Performance Targets
- Frame rate: 60fps
- Scene load: < 1 second
- Auto-save: Every 5 minutes
- Voice synthesis: < 500ms per line

## Monetization Strategy

**Pricing**:
- **Free**: 1 project, 50 scenes, basic features
- **Pro**: $19.99/month or $199/year
  - Unlimited projects
  - Collaboration
  - All locations
  - Storyboard export
  - Priority support
- **Team**: $99/month (10 users)

**Revenue Streams**:
1. Subscriptions
2. Film school licensing
3. Production company team plans

### Target Revenue
- Year 1: $1M (5,000 users @ $200 ARPU)
- Year 2: $5M (20,000 users)
- Year 3: $15M (60,000 users + B2B)

## Success Metrics

### Primary KPIs
- MAU: 20,000 in Year 1
- Premium conversion: 25%
- Scripts completed: 5,000+ in Year 1
- NPS: > 65

### Creative Impact
- 40% faster script writing (survey)
- 50% better dialogue quality (peer review)
- 80% of users: Spatial mode helps creativity

## Launch Strategy

**Phase 1**: Beta (Months 1-2) - 100 professional screenwriters
**Phase 2**: Launch (Month 3) - Public release
**Phase 3**: Growth (Months 4-12) - Film schools, studios

## Risks & Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Writers prefer traditional tools | High | Medium | Compelling demos, film school partnerships |
| Voice synthesis not realistic | Medium | Low | Use best TTS, allow custom voice uploads |
| Complexity overwhelming | Medium | Medium | Excellent tutorials, progressive disclosure |

## Success Criteria
- 50,000 users in 12 months
- 10,000 paying subscribers
- Featured by Apple
- Adopted by 5+ major film schools
- First produced screenplay written entirely in app

## Appendix

### Integrations
- Final Draft (import/export)
- Movie Magic Scheduling (export scenes)
- Celtx (import)
