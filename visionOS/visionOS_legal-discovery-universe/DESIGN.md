# Legal Discovery Universe - Design Specification

## 1. Spatial Design Principles

### 1.1 Core Design Philosophy

The Legal Discovery Universe follows these fundamental spatial design principles:

1. **Clarity Over Complexity**: Legal work demands precision - every UI element must be crystal clear
2. **Spatial Hierarchy**: Use depth meaningfully to show relationships and importance
3. **Ergonomic Comfort**: Extended use requires optimal positioning and minimal strain
4. **Progressive Disclosure**: Start simple, reveal complexity only when needed
5. **Context Preservation**: Maintain spatial memory - documents stay where users place them
6. **Trust Through Transparency**: Security indicators always visible, actions always reversible

### 1.2 Spatial Design Zones

```
User's Spatial Environment:
┌─────────────────────────────────────────────────────────┐
│  Ambient Zone (3-5m)                                    │
│  - Case overview                                        │
│  - Timeline visualization                               │
│  - High-level patterns                                  │
│                                                         │
│    ┌───────────────────────────────────────┐          │
│    │ Analysis Zone (1-3m)                  │          │
│    │ - Document clusters                   │          │
│    │ - Relationship networks               │          │
│    │ - Evidence connections                │          │
│    │                                       │          │
│    │   ┌─────────────────────────┐        │          │
│    │   │ Reading Zone (0.5-1m)   │        │          │
│    │   │ - Document detail       │        │          │
│    │   │ - Annotations           │        │          │
│    │   │ - Close reading         │        │          │
│    │   └─────────────────────────┘        │          │
│    └───────────────────────────────────────┘          │
└─────────────────────────────────────────────────────────┘
```

### 1.3 Ergonomic Guidelines

- **Vertical Positioning**: Primary content 10-15° below eye level
- **Horizontal Spread**: Interactive elements within 60° field of view
- **Depth Positioning**:
  - Reading: 0.5-1.0m (arm's length)
  - Interaction: 0.8-2.0m (comfortable reach)
  - Overview: 2.0-5.0m (environmental)
- **Minimum Hit Targets**: 60pt (44pt absolute minimum)
- **Text Size**: Minimum 16pt at 0.5m viewing distance

## 2. Visual Design System

### 2.1 Color Palette

#### Primary Colors
```swift
// Legal Discovery Color Palette
struct DiscoveryColors {
    // Primary Actions
    static let primaryBlue = Color(red: 0.0, green: 0.48, blue: 0.96)      // #007AFF
    static let primaryGold = Color(red: 1.0, green: 0.84, blue: 0.0)       // #FFD700

    // Document Status
    static let relevantGold = Color(red: 1.0, green: 0.76, blue: 0.03)     // #FFC107
    static let privilegedRed = Color(red: 0.96, green: 0.26, blue: 0.21)   // #F44336
    static let keyEvidenceBlue = Color(red: 0.13, green: 0.59, blue: 0.95) // #2196F3
    static let riskOrange = Color(red: 1.0, green: 0.60, blue: 0.0)        // #FF9800

    // Backgrounds (Glass Materials)
    static let glassRegular = Material.regular
    static let glassThin = Material.thin
    static let glassThick = Material.thick
    static let glassUltraThin = Material.ultraThin

    // Text
    static let textPrimary = Color.primary      // Adaptive
    static let textSecondary = Color.secondary  // Adaptive
    static let textTertiary = Color.tertiary    // Adaptive

    // Semantic Colors
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    static let info = Color.blue
}
```

#### Legal Status Colors

| Status | Color | Usage | Accessibility |
|--------|-------|-------|---------------|
| Relevant | Gold (#FFC107) | Key documents | WCAG AAA compliant |
| Privileged | Red (#F44336) | Protected material | Icon + color + pattern |
| Key Evidence | Blue (#2196F3) | Smoking guns | Star icon + glow |
| Risk | Orange (#FF9800) | Potential issues | Warning icon |
| Neutral | Gray (#9E9E9E) | Unreviewed | Default state |

### 2.2 Typography

#### Font System
```swift
struct DiscoveryTypography {
    // Document Display
    static let documentTitle = Font.system(size: 24, weight: .bold, design: .default)
    static let documentBody = Font.system(size: 16, weight: .regular, design: .default)
    static let documentMeta = Font.system(size: 14, weight: .medium, design: .default)

    // UI Elements
    static let heading1 = Font.system(size: 34, weight: .bold, design: .rounded)
    static let heading2 = Font.system(size: 28, weight: .semibold, design: .rounded)
    static let heading3 = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 17, weight: .regular, design: .default)
    static let caption = Font.system(size: 13, weight: .regular, design: .default)

    // 3D Spatial Text
    static let label3D = Font.system(size: 20, weight: .medium, design: .rounded)
    static let tag3D = Font.system(size: 14, weight: .semibold, design: .rounded)

    // Monospace (for metadata, dates, IDs)
    static let code = Font.system(size: 14, weight: .regular, design: .monospaced)
}
```

#### Text Rendering in 3D
- Use `.foregroundStyle(.primary)` for adaptive light/dark
- Add subtle shadows for depth: `.shadow(radius: 2, y: 2)`
- Background plates for readability in complex environments
- Dynamic Type support for accessibility

### 2.3 Materials and Lighting

#### Glass Materials
```swift
// Window backgrounds
.background(.regularMaterial)           // Standard windows
.background(.thinMaterial)              // Overlays, popovers
.background(.thickMaterial)             // Important panels
.background(.ultraThinMaterial)         // Subtle separators

// Custom glass with blur
struct CustomGlass: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.regularMaterial)
            .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
    }
}
```

#### Lighting for 3D Content
```swift
// Scene lighting setup
func configureLighting(_ scene: RealityKit.Scene) {
    // Ambient light - soft fill
    let ambient = DirectionalLight()
    ambient.light.intensity = 300
    ambient.light.color = .white
    scene.addChild(ambient)

    // Key light - main illumination
    let key = DirectionalLight()
    key.light.intensity = 1000
    key.light.color = UIColor(white: 0.95, alpha: 1.0)
    key.position = SIMD3(x: 2, y: 3, z: 2)
    key.look(at: .zero, from: key.position, relativeTo: nil)
    scene.addChild(key)

    // Rim light - edge definition
    let rim = DirectionalLight()
    rim.light.intensity = 500
    rim.light.color = UIColor(Color.blue)
    rim.position = SIMD3(x: -2, y: 1, z: -2)
    rim.look(at: .zero, from: rim.position, relativeTo: nil)
    scene.addChild(rim)
}
```

### 2.4 Iconography

#### 3D Icon System
```
Core Legal Icons:
├── Document Types
│   ├── Email (envelope)
│   ├── PDF (document page)
│   ├── Contract (handshake)
│   ├── Spreadsheet (table)
│   └── Image (picture frame)
├── Status Indicators
│   ├── Relevant (star)
│   ├── Privileged (shield)
│   ├── Key Evidence (key)
│   ├── Risk (warning triangle)
│   └── Reviewed (checkmark)
├── Actions
│   ├── Search (magnifying glass)
│   ├── Filter (funnel)
│   ├── Connect (link chain)
│   ├── Annotate (pencil)
│   └── Export (arrow up from box)
└── Navigation
    ├── Home (house)
    ├── Timeline (clock)
    ├── Network (connected nodes)
    └── Settings (gear)
```

#### Icon Specifications
- Style: SF Symbols for 2D, custom models for 3D
- Size: 24pt base (scales with Dynamic Type)
- Weight: Medium (matches UI weight)
- 3D depth: 2-4mm extrusion
- Material: Matte with subtle specular highlights

## 3. Window Layouts

### 3.1 Main Discovery Workspace

```
┌─────────────────────────────────────────────────────────┐
│  Discovery Workspace                    [- □ ×]         │
├─────────────────────────────────────────────────────────┤
│  ┌──────────────┐                                       │
│  │  Case Info   │  Project Nightingale v. TechCorp      │
│  │  ┌────────┐  │  Status: Active | 456,789 Documents   │
│  │  │ Badge  │  │                                       │
│  │  └────────┘  │                                       │
│  └──────────────┘                                       │
├─────────────────────────────────────────────────────────┤
│  ┌──────────────────────────────────────────────────┐  │
│  │  Search: [________________________] 🔍           │  │
│  │  Filters: [ Relevant ] [ Privileged ] [ Dated ]  │  │
│  └──────────────────────────────────────────────────┘  │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────┐   │
│  │  Documents                    Sort: Relevance ▼ │   │
│  ├─────────────────────────────────────────────────┤   │
│  │  ⭐ Email: Project Status Update               │   │
│  │     John Smith → Jane Doe | Mar 15, 2024       │   │
│  │     Relevance: 98% | Privilege: None           │   │
│  ├─────────────────────────────────────────────────┤   │
│  │  🛡️ Memo: Legal Strategy Discussion            │   │
│  │     Attorney Notes | Mar 14, 2024              │   │
│  │     Relevance: 87% | Privilege: Attorney-Client│   │
│  ├─────────────────────────────────────────────────┤   │
│  │  📄 Contract: Service Agreement                │   │
│  │     Executed Document | Jan 10, 2024           │   │
│  │     Relevance: 92% | Privilege: None           │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  Bottom Ornament:                                       │
│  [ 🏠 Home ] [ 🌌 Universe ] [ 📊 Timeline ] [⚙️ Settings]│
└─────────────────────────────────────────────────────────┘
```

**Specifications**:
- Default size: 1200×900 points
- Glass material: `.regularMaterial`
- Corner radius: 16pt
- Padding: 20pt
- List row height: 80pt
- Hover effect: Subtle glow

### 3.2 Document Detail Window

```
┌─────────────────────────────────────────────────────────┐
│  Email: Project Status Update           [- □ ×]         │
├─────────────────────────────────────────────────────────┤
│  ┌──────────────────────────────────────────────────┐  │
│  │  From: John Smith <jsmith@techcorp.com>         │  │
│  │  To: Jane Doe <jdoe@techcorp.com>               │  │
│  │  Date: March 15, 2024 at 3:42 PM                │  │
│  │  Subject: Project Status Update                 │  │
│  └──────────────────────────────────────────────────┘  │
├─────────────────────────────────────────────────────────┤
│  ┌──────────────────────────────────────────────────┐  │
│  │  AI Analysis                                     │  │
│  │  • Relevance: 98% (Highly Relevant)             │  │
│  │  • Privilege: None detected                     │  │
│  │  • Key Entities: John Smith, Jane Doe,          │  │
│  │    Project Nightingale                          │  │
│  │  • Sentiment: Professional, Concerned           │  │
│  │  • Suggested Tags: Timeline, Key Evidence       │  │
│  └──────────────────────────────────────────────────┘  │
├─────────────────────────────────────────────────────────┤
│  ┌──────────────────────────────────────────────────┐  │
│  │                                                  │  │
│  │  Jane,                                           │  │
│  │                                                  │  │
│  │  I wanted to update you on Project Nightingale. │  │
│  │  We've identified some concerning issues with   │  │
│  │  the Q2 deliverables that need immediate        │  │
│  │  attention...                                    │  │
│  │                                                  │  │
│  │  [Document content continues...]                │  │
│  │                                                  │  │
│  └──────────────────────────────────────────────────┘  │
├─────────────────────────────────────────────────────────┤
│  Actions:                                               │
│  [ ⭐ Mark Relevant ] [ 🛡️ Flag Privileged ]            │
│  [ 🏷️ Add Tag ] [ 🔗 Create Connection ] [ 📤 Export ] │
└─────────────────────────────────────────────────────────┘
```

**Specifications**:
- Default size: 900×1200 points (vertical)
- Reading-optimized layout
- Metadata section: Collapsible
- AI analysis: Expandable card
- Content area: Scrollable, full text rendering
- Action buttons: Always visible at bottom

### 3.3 Settings Window

```
┌─────────────────────────────────────────────────────────┐
│  Settings                                [- □ ×]         │
├─────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌─────────────────────────────────┐ │
│  │  General     │  │  Account                        │ │
│  │─────────────│  │  User: attorney@lawfirm.com     │ │
│  │  Security    │  │  Role: Lead Attorney            │ │
│  │─────────────│  │  [ Change Password ]            │ │
│  │  Display     │  │                                 │ │
│  │─────────────│  │  Preferences                    │ │
│  │  Privacy     │  │  □ Auto-save document positions│ │
│  │─────────────│  │  ☑ Enable AI suggestions       │ │
│  │  About       │  │  ☑ Show confidence scores      │ │
│  │              │  │  □ Offline mode                │ │
│  │              │  │                                 │ │
│  │              │  │  Notifications                  │ │
│  │              │  │  ☑ New document alerts         │ │
│  │              │  │  ☑ Review reminders            │ │
│  │              │  │  □ Team activity updates       │ │
│  └──────────────┘  └─────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

## 4. Volumetric Designs

### 4.1 Evidence Universe Volume

```
3D Visualization (1.5m × 1.5m × 1.5m):

         Y
         ↑
         │      ⭐ Key Evidence Cluster
         │     ╱ ╲
         │    ●   ●
         │   ●  ●  ●
    ●●●●●│●●●●●●●●●●●●●●● → X
       ● │ ●   ●  ●   ●
      ●  │  ●     ●  ●
     ●   │   ●   ●  ●
    ●    │    Privilege Zone (Red Sphere)
         │
        ╱
       Z

Legend:
● Document node (sphere)
⭐ Highly relevant (gold glow)
🛡️ Privileged (red shield overlay)
Lines: Document relationships
Clusters: AI-grouped by topic
```

**Specifications**:
- Document nodes:
  - Base size: 3cm spheres
  - Scale with relevance: 2cm-5cm
  - LOD: 3 levels based on distance
- Connections:
  - Line thickness: 1-3mm based on strength
  - Color: Gradient from source to target status color
  - Animated pulse for active connections
- Clustering:
  - K-means clustering by topic
  - Cluster radius: 20-40cm
  - Center marked with label
- Interaction:
  - Gaze: Highlight + show label
  - Tap: Select + open detail
  - Drag: Reposition (with physics)

### 4.2 Timeline Volume

```
Timeline Visualization (2m × 0.8m × 0.5m):

Past                                              Future
←──────────────────────────────────────────────────────→
Jan 2024        Mar 2024        Jun 2024        Sep 2024

   │               │               │               │
   ●               ●●●             ●               ●
   │              ╱│╲              │               │
   │             ● │ ●             │               │
   │               │               │               │
Timeline River    Event Burst    Single Event   Today

Depth: Document volume (more docs = thicker river)
Height: Importance (key evidence elevated)
Color: Status (relevant gold, privileged red)
```

**Specifications**:
- Timeline flow:
  - Direction: Left (past) to right (future)
  - Width: Constant 5cm
  - Depth: Variable 5-50cm (document volume)
- Events:
  - Markers: 5cm spheres
  - Elevation: Based on importance
  - Color: Status-based
  - Label: Hover to reveal
- River rendering:
  - Particle system for flow
  - Glow effect for activity
  - Transparency based on relevance
- Scrubber:
  - Vertical plane at current time
  - Draggable left/right
  - Shows date and event count

### 4.3 Network Analysis Volume

```
Network Graph (1.2m × 1.2m × 1.2m):

         Person Node (Blue)
              ●
             ╱│╲
            ●─┼─●  Organization Node (Green)
           ╱  │  ╲
          ●   │   ●
         ╱    │    ╲
        ●─────●─────● Location Node (Orange)

Node Size: Importance (document count)
Edge Thickness: Relationship strength
Edge Color: Relationship type
Position: Force-directed layout
```

**Specifications**:
- Nodes:
  - Types: Person, Organization, Location, Event
  - Size: 2-8cm (based on document count)
  - Color: Type-based
  - Label: Name with document count
- Edges:
  - Thickness: 1-5mm (relationship strength)
  - Color: Relationship type
    - Email: Blue
    - Meeting: Green
    - Contract: Purple
    - Mention: Gray
  - Animation: Pulse on interaction
- Layout:
  - Algorithm: Force-directed (D3-style)
  - Update: Real-time physics
  - Constraints: Keep within volume bounds
- Interaction:
  - Select node: Highlight connected nodes
  - Double-tap: Show documents for entity
  - Pinch two nodes: Show shared documents

## 5. Immersive Space Designs

### 5.1 Case Investigation Space

**Environment**:
- Immersion: Progressive (0.0 to 1.0)
- Sky: Dark gradient (midnight blue to black)
- Floor: Subtle grid (legal pad yellow, 10% opacity)
- Ambient: Soft warm lighting

**Layout**:
```
          Evidence Universe
               (Center)
                  ●
                 ╱│╲
                ╱ │ ╲
               ╱  │  ╲
  Timeline ───●───●───●─── Network
   (Left)         │         (Right)
                  │
                  │
            Document Detail
              (Forward)
```

**Specifications**:
- Central focus: Evidence Universe (1.5m sphere)
- Left panel: Timeline (2m wide, at user's 9 o'clock)
- Right panel: Network (1.2m sphere, at user's 3 o'clock)
- Forward panel: Active document (1m away, eye level)
- Floor markers: Case name and stats
- Navigation: Gaze + voice commands

### 5.2 Presentation Mode Space

**Environment**:
- Immersion: Full (1.0)
- Sky: Solid dark background
- Spotlight: On presenter and content
- Audience: Empty seats visible (if configured)

**Layout**:
```
                [Evidence Display]
                ┌─────────────┐
                │   Content   │
                │   Center    │
                │  (Floating) │
                └─────────────┘
                      ↑
                Presenter Area
                  (You Here)

     Notes Panel               Controls Panel
    (Left, private)           (Right, private)
```

**Specifications**:
- Content display: 2m wide, eye level, 2m away
- Presenter view: Private panels on sides
- Controls: Next/previous, annotations, laser pointer
- Voice commands: "Next slide", "Highlight this", "Zoom in"
- Recording: Optional session recording

## 6. Interaction Patterns

### 6.1 Gaze and Pinch

**Selection Flow**:
1. Gaze: Look at document → Highlight appears (300ms delay)
2. Pinch: Thumb + index → Select document
3. Feedback: Haptic tick + audio click + visual pulse

**Drag Flow**:
1. Pinch and hold on document
2. Move hand to reposition
3. Release to drop with momentum
4. Snap to grid if near organizational structure

### 6.2 Hand Tracking Gestures

#### Thumbs Up - Mark Relevant
```
Gesture Recognition:
1. Detect hand orientation
2. Verify thumb up, fingers curled
3. Hold for 500ms
4. Apply relevant tag
5. Animate gold glow on document
```

#### Shield - Mark Privileged
```
Gesture Recognition:
1. Detect both hands
2. Verify crossing at wrists
3. Verify palms forward
4. Hold for 750ms
5. Show confirmation dialog
6. Apply privilege protection
```

#### Draw Connection
```
Gesture Recognition:
1. Pinch first document
2. Maintain pinch while moving to second
3. Show line preview
4. Release on second document
5. Create connection with type selector
```

### 6.3 Voice Commands

**Core Commands**:
```yaml
Search:
  - "Search for [query]"
  - "Find documents about [topic]"
  - "Show me emails from [person]"

Navigation:
  - "Open Evidence Universe"
  - "Show timeline"
  - "Go to network view"
  - "Return to workspace"

Actions:
  - "Mark this as relevant"
  - "Flag as privileged"
  - "Add tag [tag name]"
  - "Export selected documents"

Presentation:
  - "Next document"
  - "Previous document"
  - "Highlight this section"
  - "Zoom in"
```

## 7. User Flows

### 7.1 Document Review Flow

```
Start: Discovery Workspace
  ↓
Search/Filter documents
  ↓
Select document from list
  ↓
Document Detail opens (new window)
  ↓
Review content + AI analysis
  ↓
Decision point:
  ├─ Not Relevant → Dismiss
  ├─ Relevant → Mark + Tag
  ├─ Privileged → Flag + Confirm
  └─ Key Evidence → Star + Annotate
  ↓
Next document (automatic or manual)
  ↓
Repeat until batch complete
```

### 7.2 Evidence Discovery Flow

```
Start: Discovery Workspace
  ↓
Open Evidence Universe (volume)
  ↓
Observe 3D document clustering
  ↓
Identify interesting cluster
  ↓
Navigate to cluster (gaze + walk or drag)
  ↓
Select document from cluster
  ↓
Review in detail panel
  ↓
Discover related documents (connections)
  ↓
Follow connection thread
  ↓
Build evidence timeline
  ↓
Export evidence package
```

### 7.3 Timeline Construction Flow

```
Start: Discovery Workspace
  ↓
Open Timeline Volume
  ↓
Scrub to date range of interest
  ↓
Identify event clusters
  ↓
Select event
  ↓
Review associated documents
  ↓
Add annotations
  ↓
Connect related events
  ↓
Label critical moments
  ↓
Export timeline visualization
```

## 8. Animation and Transitions

### 8.1 Window Transitions

**Open Window**:
```swift
.transition(.asymmetric(
    insertion: .scale(scale: 0.9).combined(with: .opacity),
    removal: .scale(scale: 1.1).combined(with: .opacity)
))
.animation(.spring(response: 0.4, dampingFraction: 0.8), value: isPresented)
```

- Duration: 400ms
- Curve: Spring with bounce
- Effect: Scale from 90% with fade in

**Close Window**:
- Duration: 300ms
- Curve: Ease in
- Effect: Scale to 110% with fade out

### 8.2 3D Entity Animations

**Document Appear**:
```swift
func animateDocumentEntry(_ entity: Entity) {
    entity.scale = SIMD3<Float>(0.1, 0.1, 0.1)
    entity.opacity = 0

    entity.animate(duration: 0.6, timingFunction: .easeOut) {
        entity.scale = SIMD3<Float>(1, 1, 1)
        entity.opacity = 1
    }
}
```

**Selection Pulse**:
```swift
func animateSelection(_ entity: Entity) {
    let originalScale = entity.scale

    // Pulse animation
    entity.animate(duration: 0.2, timingFunction: .easeOut) {
        entity.scale = originalScale * 1.1
    } completion: {
        entity.animate(duration: 0.2, timingFunction: .easeIn) {
            entity.scale = originalScale
        }
    }

    // Add glow effect
    addGlowEffect(to: entity, color: .gold, duration: 0.4)
}
```

**Connection Formation**:
```swift
func animateConnection(from: Entity, to: Entity) {
    // Create line entity
    let line = createLineEntity(from: from.position, to: to.position)
    line.opacity = 0

    // Animate line drawing
    line.animate(duration: 0.5) {
        line.opacity = 1
        // Animate line growth from source to target
        line.scale.z = 1 // Start at 0, grow to 1
    }

    // Pulse effect
    pulseLine(line, count: 2)
}
```

### 8.3 Timing Specifications

| Animation | Duration | Curve | Purpose |
|-----------|----------|-------|---------|
| Hover effect | 150ms | Linear | Quick feedback |
| Selection | 200ms | Ease out | Confirmation |
| Window open | 400ms | Spring | Polished feel |
| Window close | 300ms | Ease in | Quick dismiss |
| Entity appear | 600ms | Ease out | Graceful entry |
| Connection draw | 500ms | Linear | Process visual |
| Cluster form | 800ms | Ease in-out | Complex transition |
| Immersion change | 1000ms | Ease in-out | Comfortable shift |

## 9. Accessibility Design

### 9.1 VoiceOver Spatial Audio

```swift
// Spatial audio cues for entity position
func configureVoiceOver(for entity: Entity) {
    entity.accessibility = AccessibilityComponent(
        label: "Email from John Smith, March 15th, highly relevant",
        value: "98% relevance score",
        hint: "Double tap to open",
        traits: [.button]
    )

    // Add spatial audio position announcement
    entity.accessibility?.spatialAudioPosition = entity.position
}
```

**Specifications**:
- Spatial position announced as clock face: "Document at 2 o'clock, 1 meter"
- Importance indicated by pitch: Higher pitch = more relevant
- Status indicated by tone: Different tones for relevant/privileged/neutral
- Haptic feedback: Different patterns for different document types

### 9.2 High Contrast Mode

```swift
@Environment(\.accessibilityColorScheme) var colorScheme

var statusColor: Color {
    if colorScheme == .highContrast {
        return document.isRelevant ? .yellow : .white
    } else {
        return document.isRelevant ? .gold : .gray
    }
}
```

**High Contrast Specifications**:
- Relevant: Bright yellow (#FFFF00)
- Privileged: Bright red (#FF0000) + pattern overlay
- Key Evidence: Bright blue (#0000FF)
- Background contrast ratio: 7:1 minimum (WCAG AAA)

### 9.3 Gesture Alternatives

| Primary Gesture | Alternative | VoiceOver Alternative |
|----------------|-------------|----------------------|
| Gaze + Pinch | Keyboard: Space | "Select" |
| Thumbs Up | Button tap | "Mark relevant" |
| Shield gesture | Menu: Flag privileged | "Flag privileged" |
| Draw connection | Button: Connect | "Connect to..." |
| Drag entity | Keyboard: Arrow keys | "Move [direction]" |

## 10. Error States and Loading Indicators

### 10.1 Loading States

**Document Loading**:
```swift
struct DocumentLoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .controlSize(.large)
                .tint(.blue)

            Text("Loading document...")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .padding(40)
        .background(.regularMaterial)
        .cornerRadius(16)
    }
}
```

**AI Analysis Loading**:
```
Analyzing document...
[████████░░] 80%

✓ Text extraction complete
✓ Entity recognition complete
⧗ Privilege detection in progress
⧗ Relevance scoring in progress
```

### 10.2 Error States

**Network Error**:
```swift
struct NetworkErrorView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 48))
                .foregroundStyle(.red)

            Text("Connection Lost")
                .font(.title2)

            Text("Working offline. Changes will sync when connection is restored.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Retry") {
                // Retry connection
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(40)
        .background(.regularMaterial)
    }
}
```

**Empty States**:
```swift
struct EmptyDocumentsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 64))
                .foregroundStyle(.tertiary)

            Text("No Documents Found")
                .font(.title2)

            Text("Try adjusting your filters or search terms")
                .font(.body)
                .foregroundStyle(.secondary)

            Button("Clear Filters") {
                // Clear all filters
            }
        }
    }
}
```

## 11. Responsive Design

### 11.1 Window Size Adaptations

**Minimum Size (800×600)**:
- Hide secondary panels
- Collapse metadata
- Show essential content only
- Provide expand button

**Standard Size (1200×900)**:
- Full interface
- All panels visible
- Optimal layout

**Large Size (1600×1200+)**:
- Show additional details
- Multi-column layout
- Preview pane
- Extended metadata

### 11.2 Content Scaling

```swift
@Environment(\.dynamicTypeSize) var typeSize
@Environment(\.displayScale) var displayScale

var adaptiveLayout: some View {
    if typeSize >= .xxxLarge {
        // Vertical stack for large text
        VStack { /* ... */ }
    } else {
        // Horizontal layout
        HStack { /* ... */ }
    }
}
```

## 12. Design Assets

### 12.1 Required 3D Models

**Document Representations**:
- Generic document (paper sheet)
- Email icon (envelope)
- PDF icon (acrobat symbol)
- Contract icon (handshake)
- Spreadsheet icon (grid)

**Status Indicators**:
- Star (relevant marker)
- Shield (privilege protection)
- Key (key evidence)
- Warning triangle (risk)
- Checkmark (reviewed)

**Environmental**:
- Floor grid pattern
- Spatial cursors
- Connection lines
- Cluster boundaries

### 12.2 Audio Assets

| Asset | Format | Duration | Use Case |
|-------|--------|----------|----------|
| select_click.aac | AAC 48kHz | 100ms | Document selection |
| mark_relevant.aac | AAC 48kHz | 300ms | Relevant tag |
| flag_privileged.aac | AAC 48kHz | 500ms | Privilege flag |
| connect.aac | AAC 48kHz | 400ms | Connection created |
| search_complete.aac | AAC 48kHz | 250ms | Search finished |
| error_alert.aac | AAC 48kHz | 600ms | Error occurred |
| ambient_background.aac | AAC 48kHz | Loop | Immersive space |

## 13. Brand Integration

### 13.1 Law Firm Customization

**Branding Elements**:
- Firm logo in app icon and splash
- Custom color scheme (within accessibility guidelines)
- Firm name in window titles
- Custom case numbering format

**Whitelabel Support**:
```swift
struct BrandingConfiguration {
    let firmName: String
    let primaryColor: Color
    let secondaryColor: Color
    let logoAsset: String
    let accentMaterial: Material

    static let `default` = BrandingConfiguration(
        firmName: "Legal Discovery Universe",
        primaryColor: .blue,
        secondaryColor: .gold,
        logoAsset: "default-logo",
        accentMaterial: .regularMaterial
    )
}
```

---

**Document Version**: 1.0
**Last Updated**: 2025-11-17
**Status**: Initial Design Specification
