# Design Specification
## visionOS Executive Briefing App

### Document Version
- **Version**: 1.0
- **Date**: 2025-11-19
- **Status**: Initial Design

---

## 1. Spatial Design Principles

### 1.1 Core Design Philosophy

**Guiding Principles**:
1. **Clarity First**: Information must be immediately comprehensible
2. **Spatial Hierarchy**: Use depth to organize information importance
3. **Progressive Disclosure**: Start simple, reveal complexity on demand
4. **Executive Elegance**: Professional, sophisticated, premium feel
5. **Ergonomic Comfort**: Content positioned for extended viewing sessions

### 1.2 visionOS Design Fundamentals

**Spatial Ergonomics**:
- Primary content: 10-15° below eye level
- Optimal viewing distance: 1.5-2.0 meters
- Maximum field of view usage: 60° horizontal
- Depth layering: -500mm (far) to +300mm (near)

**Material System**:
- Glass materials for UI elements (system materials)
- Subtle transparency allowing environmental awareness
- Appropriate vibrancy for readability
- Depth-appropriate materials (heavier materials closer)

---

## 2. Window Layouts and Configurations

### 2.1 Main Window - Briefing Navigator

**Dimensions**:
- Default: 1000pt × 800pt
- Min: 800pt × 600pt
- Max: 1400pt × 1000pt
- Resizable: Yes (content-based)

**Layout Structure**:
```
┌────────────────────────────────────────────────┐
│  ┌──────────────┐  ┌─────────────────────────┐ │
│  │              │  │                         │ │
│  │   Sidebar    │  │    Content Area         │ │
│  │   (280pt)    │  │    (Flexible)           │ │
│  │              │  │                         │ │
│  │ • TOC        │  │  Section Title          │ │
│  │ • Progress   │  │  ─────────────          │ │
│  │ • Quick      │  │                         │ │
│  │   Actions    │  │  [Content Blocks]       │ │
│  │              │  │                         │ │
│  │              │  │                         │ │
│  └──────────────┘  └─────────────────────────┘ │
│                                                │
│  [Bottom Toolbar - 60pt]                       │
└────────────────────────────────────────────────┘
```

**Visual Hierarchy**:
```swift
ZStack {
    // Background - Glass material
    RoundedRectangle(cornerRadius: 32)
        .fill(.regularMaterial)

    HStack(spacing: 0) {
        // Sidebar - Darker glass for separation
        SidebarView()
            .frame(width: 280)
            .background(.thickMaterial)

        // Content area
        ContentView()
            .padding(40)
    }

    // Floating toolbar
    VStack {
        Spacer()
        ToolbarView()
            .padding()
            .background(.ultraThinMaterial)
    }
}
```

### 2.2 Sidebar Design

**Components**:
1. **Header** (80pt)
   - App icon/title
   - User progress indicator

2. **Table of Contents** (Expandable)
   - Executive Summary
   - Top 10 Use Cases
   - Critical Decisions
   - Risk/Opportunity Matrix
   - Investment Priorities
   - Competitive Positioning
   - Action Items
   - Success Metrics
   - Conclusion

3. **Quick Actions** (100pt)
   - Open 3D Visualization
   - View All Actions
   - Export Progress
   - Settings

**Interaction**:
- Hover effects on items (subtle scale + glow)
- Active section highlighted with accent color
- Smooth collapse/expand animations
- Progress indicators (pie chart or progress bar)

### 2.3 Content Area Design

**Typography**:
```swift
// Section titles
.font(.system(size: 48, weight: .bold))
.foregroundStyle(.primary)

// Subsection headers
.font(.system(size: 32, weight: .semibold))
.foregroundStyle(.primary)

// Body text
.font(.system(size: 20, weight: .regular))
.foregroundStyle(.secondary)
.lineSpacing(8)

// Metrics/numbers (emphasis)
.font(.system(size: 56, weight: .heavy))
.foregroundStyle(.accent)
```

**Content Block Types**:

1. **Text Blocks**
   - Max width: 720pt (optimal readability)
   - Line spacing: 1.4x
   - Paragraph spacing: 16pt

2. **Metric Cards**
   ```
   ┌─────────────────────────┐
   │  ROI                    │
   │  400%                   │ ← Large number
   │  within 12 months       │ ← Context
   │  ↗ +15% from 2024       │ ← Trend
   └─────────────────────────┘
   ```

3. **Use Case Cards**
   ```
   ┌──────────────────────────────────────┐
   │  🎯 Remote Expert Assistance         │
   │                                      │
   │  ROI: 400% • Timeline: 12 months    │
   │                                      │
   │  67% reduction in travel costs      │
   │  50% faster problem resolution      │
   │                                      │
   │  [View 3D Visualization]  [Details] │
   └──────────────────────────────────────┘
   ```

4. **Decision Frameworks**
   ```
   ┌─────────────────────────────────────┐
   │  Platform Strategy                  │
   │                                     │
   │  Question: Closed vs. Open?         │
   │                                     │
   │  ┌─────────────┐  ┌──────────────┐ │
   │  │ Closed      │  │ Open         │ │
   │  │ Ecosystem   │  │ Standards    │ │
   │  │             │  │              │ │
   │  │ Pros/Cons   │  │ Pros/Cons    │ │
   │  └─────────────┘  └──────────────┘ │
   │                                     │
   │  💡 Recommendation: Hybrid approach │
   └─────────────────────────────────────┘
   ```

5. **Checklists**
   ```
   Investment Priorities - Phase 1
   ☑ Establish innovation lab
   ☑ Recruit AR/VR leadership
   ☐ Launch 3-5 pilot programs
   ☐ Develop governance framework

   Progress: 50% complete
   ```

---

## 3. Volume Designs (3D Bounded Spaces)

### 3.1 ROI Comparison Volume

**Dimensions**: 600 × 600 × 600 points

**Layout**:
```
       ↑ ROI %
       │
  400% │     ┃
       │     ┃
  350% │  ┃  ┃
       │  ┃  ┃
  300% │  ┃  ┃  ┃
       │  ┃  ┃  ┃
  250% │  ┃  ┃  ┃  ┃
       │  ┃  ┃  ┃  ┃
       └──────────────→
         1  2  3  4  ...
```

**Design Elements**:
- **3D Bar Charts**: Cylinders or rounded cuboids
- **Color Coding**:
  - 400%+: Green gradient
  - 300-399%: Blue gradient
  - 200-299%: Orange gradient
- **Interactive Labels**: Float above bars, always facing user
- **Hover State**: Bar expands, details panel appears
- **Selection**: Tap to select, full details in side panel

**Materials**:
```swift
// Bar material (glass with color tint)
var material: Material {
    var mat = PhysicallyBasedMaterial()
    mat.baseColor = .init(tint: color.withAlphaComponent(0.8))
    mat.roughness = 0.2
    mat.metallic = 0.0
    return Material.from(mat)
}

// Label material (always legible)
var labelMaterial: Material {
    var mat = UnlitMaterial()
    mat.color = .init(tint: .white)
    return Material.from(mat)
}
```

### 3.2 Decision Matrix Volume

**Dimensions**: 700 × 500 × 500 points

**Layout**:
```
    High Impact
        ↑
   ┌────┼────┐
   │ II │ I  │  ← Quadrant I: High Impact, High Feasibility
   ├────┼────┤
   │ III│ IV │
   └────┼────┘
        → High Feasibility
```

**Design Elements**:
- **3D Quadrants**: Floating planes with glass material
- **Decision Points**: Spheres positioned in 3D space
- **Connecting Lines**: Show relationships between decisions
- **Interactive**: Tap sphere to see decision details
- **Filters**: Toggle visibility by category

**Spatial Positioning**:
```swift
func positionDecision(_ decision: DecisionPoint) -> SIMD3<Float> {
    let x = Float(decision.feasibility) * 300 - 150  // -150 to +150
    let y = Float(decision.impact) * 250 - 125       // -125 to +125
    let z = 0  // All on same plane
    return SIMD3(x, y, z)
}
```

### 3.3 Investment Timeline Volume

**Dimensions**: 800 × 400 × 400 points

**Layout**:
```
         Phase 3
           ◆
          /│\
         / │ \
   Phase 2 │  Budget
      ◆────┼────
      │    │
      │    │
   Phase 1 │
      ◆────┴───→ Time
     Q1   Q2  Q3  Q4  2026
```

**Design Elements**:
- **Timeline Path**: 3D curve through space
- **Phase Markers**: Diamond-shaped markers
- **Budget Visualization**: Vertical bars from timeline
- **Milestone Cards**: Float above timeline, face user
- **Progress Indicator**: Animated line showing current phase

**Animation**:
```swift
// Animate through timeline
func animateTimelineIntro() async {
    for phase in phases {
        await phase.fadeIn(duration: 0.5)
        await phase.highlight(duration: 0.3)
        try? await Task.sleep(for: .seconds(0.5))
    }
}
```

---

## 4. Full Space / Immersive Experiences

### 4.1 Immersive Briefing Environment (Optional)

**Concept**: Virtual executive boardroom with spatial data visualization

**Environment**:
- **Space**: Mixed immersion (see surroundings with virtual overlay)
- **Setting**: Professional, modern boardroom aesthetic
- **Lighting**: Soft, directional light from above
- **Materials**: Wood table, glass surfaces, metal accents

**Layout**:
```
        [Ceiling Virtual Skylights]
                  │
     ┌────────────┼────────────┐
     │                         │
  [Chart 1]    [User]     [Chart 2]
     │         Position        │
     │            │            │
     └────────────┼────────────┘
              [Table]
```

**Interactive Elements**:
1. **Central Holographic Display**: Main content
2. **Surrounding Data Panels**: 3-5 panels in arc around user
3. **Floating UI Controls**: Below field of view
4. **Spatial Audio**: Narration from content direction

**Navigation**:
- Look at panel to bring it forward
- Pinch gesture to select
- Swipe to navigate between sections
- Voice commands for major actions

### 4.2 Passthrough vs. Full Immersion

**Mixed Mode** (Default):
- 50% environment visible
- Virtual elements overlaid
- Maintain spatial awareness
- Less fatigue for extended use

**Full Immersion** (Optional):
- 100% virtual environment
- Maximum focus
- Shorter session recommendations
- Clear exit affordance

---

## 5. 3D Visualization Specifications

### 5.1 Chart Types and Styles

#### 3D Bar Chart
```swift
struct ROIBar {
    let height: Float        // Based on ROI percentage
    let radius: Float = 40   // Consistent width
    let color: Color         // Gradient based on value
    let position: SIMD3<Float>

    var entity: Entity {
        let mesh = MeshResource.generateCylinder(
            height: height,
            radius: radius
        )
        let material = SimpleMaterial(
            color: UIColor(color),
            roughness: 0.2,
            isMetallic: false
        )
        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.position = position
        return entity
    }
}
```

#### Scatter Plot (Decision Matrix)
```swift
struct DecisionSphere {
    let position: SIMD3<Float>
    let size: Float
    let color: Color
    let label: String

    var entity: Entity {
        let mesh = MeshResource.generateSphere(radius: size)
        let material = createGlassMaterial(tint: color)
        let entity = ModelEntity(mesh: mesh, materials: [material])

        // Add label attachment
        let labelEntity = createLabel(text: label)
        labelEntity.position.y = size + 20
        entity.addChild(labelEntity)

        return entity
    }
}
```

#### Timeline Path
```swift
struct TimelinePath {
    let points: [SIMD3<Float>]
    let width: Float = 10

    var entity: Entity {
        // Create curved path using spline interpolation
        let path = generateSpline(from: points)

        // Create tube mesh along path
        let mesh = MeshResource.generateTube(along: path, radius: width)
        let material = createMaterial(color: .accent)

        return ModelEntity(mesh: mesh, materials: [material])
    }
}
```

### 5.2 Animation Specifications

**Entry Animations**:
```swift
// Fade in + scale up
entity.scale = SIMD3<Float>(repeating: 0.1)
entity.components[OpacityComponent.self] = OpacityComponent(opacity: 0)

await entity.animate(
    to: Transform(scale: SIMD3(repeating: 1.0)),
    duration: 0.6,
    timingFunction: .easeOut
)

// Stagger multiple entities
for (index, entity) in entities.enumerated() {
    try? await Task.sleep(for: .milliseconds(index * 100))
    await entity.fadeIn(duration: 0.4)
}
```

**Hover Animations**:
```swift
// Grow on hover
let originalScale = entity.scale
entity.animate(
    to: Transform(scale: originalScale * 1.1),
    duration: 0.2,
    timingFunction: .easeInOut
)

// Add glow effect
entity.components[HighlightComponent.self] = HighlightComponent(
    color: .accent,
    intensity: 0.5
)
```

**Selection Animations**:
```swift
// Pulse effect
func pulseAnimation(entity: Entity) async {
    while entity.isSelected {
        await entity.animate(scale: 1.05, duration: 0.5)
        await entity.animate(scale: 1.0, duration: 0.5)
    }
}
```

**Transition Animations**:
```swift
// Smooth scene transitions
await withTaskGroup(of: Void.self) { group in
    // Fade out old content
    group.addTask {
        await oldContent.fadeOut(duration: 0.3)
    }

    // Fade in new content
    group.addTask {
        try? await Task.sleep(for: .seconds(0.2))
        await newContent.fadeIn(duration: 0.4)
    }
}
```

---

## 6. Interaction Patterns

### 6.1 Gaze and Pinch Gestures

**Hover State**:
```
User looks at element
    ↓
Element highlights (100-200ms delay)
    ↓
Subtle scale increase (1.05x)
    ↓
Optional tooltip appears (if gaze held > 500ms)
```

**Selection**:
```
User gazes at element (highlight appears)
    ↓
User performs pinch gesture
    ↓
Element confirms selection (haptic feedback + animation)
    ↓
Action executes or details panel opens
```

**Visual Feedback**:
```swift
struct HoverableCard: View {
    @State private var isHovered = false

    var body: some View {
        CardContent()
            .hoverEffect(.highlight)
            .scaleEffect(isHovered ? 1.05 : 1.0)
            .shadow(
                color: .accent.opacity(isHovered ? 0.3 : 0),
                radius: isHovered ? 20 : 0
            )
            .animation(.easeInOut(duration: 0.2), value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}
```

### 6.2 Hand Tracking Gestures

**Supported Gestures**:

1. **Point and Select**
   - Point index finger at element
   - Tap thumb to index finger to select

2. **Swipe Navigation**
   - Swipe hand left/right to change sections
   - Swipe up/down to scroll

3. **Grab and Move**
   - Pinch to grab volumetric content
   - Move hand to reposition
   - Release to drop

4. **Rotate**
   - Two-handed pinch
   - Rotate hands to rotate content

**Implementation**:
```swift
func handleHandGesture(_ gesture: HandGesture) {
    switch gesture {
    case .pinch(let strength):
        if strength > 0.8 {
            selectHoveredElement()
        }

    case .swipe(let direction):
        navigateInDirection(direction)

    case .grab(let position):
        startDragging(at: position)

    case .rotate(let angle):
        rotateContent(by: angle)
    }
}
```

### 6.3 Voice Commands (Future)

**Supported Commands**:
- "Show executive summary"
- "Open ROI visualization"
- "Next section" / "Previous section"
- "Mark this action item complete"
- "Export my progress"

---

## 7. Visual Design System

### 7.1 Color Palette

**Primary Colors**:
```swift
// Brand/Accent
.accent = Color(hex: "#007AFF")  // visionOS blue

// Success/High Performance
.success = Color(hex: "#30D158")  // Green

// Warning/Medium Performance
.warning = Color(hex: "#FF9F0A")  // Orange

// Critical/Low Performance
.critical = Color(hex: "#FF453A")  // Red

// Executive Dark
.executiveDark = Color(hex: "#1C1C1E")  // Near black

// Premium Gold (accents)
.premiumGold = Color(hex: "#FFD60A")
```

**Semantic Colors**:
```swift
// Text
.primary = Color.primary           // High contrast text
.secondary = Color.secondary       // Medium contrast text
.tertiary = Color.tertiary         // Low contrast text

// Backgrounds
.background = Color(uiColor: .systemBackground)
.secondaryBackground = Color(uiColor: .secondarySystemBackground)

// Glass materials (visionOS)
.ultraThinMaterial    // Lightest glass
.thinMaterial         // Light glass
.regularMaterial      // Standard glass
.thickMaterial        // Heavy glass
.ultraThickMaterial   // Heaviest glass
```

**Color Usage**:
- ROI > 400%: Success green
- ROI 300-399%: Accent blue
- ROI 200-299%: Warning orange
- ROI < 200%: Tertiary gray

### 7.2 Typography

**Font Family**: SF Pro (System)

**Type Scale**:
```swift
enum Typography {
    // Headings
    case largeTitle    // 48pt, bold
    case title1        // 40pt, bold
    case title2        // 32pt, semibold
    case title3        // 24pt, semibold

    // Body
    case body          // 20pt, regular
    case callout       // 18pt, regular
    case subheadline   // 16pt, regular
    case footnote      // 14pt, regular

    // Special
    case metric        // 56pt, heavy (for big numbers)
    case caption       // 12pt, regular

    var font: Font {
        switch self {
        case .largeTitle: return .system(size: 48, weight: .bold)
        case .title1: return .system(size: 40, weight: .bold)
        case .title2: return .system(size: 32, weight: .semibold)
        case .title3: return .system(size: 24, weight: .semibold)
        case .body: return .system(size: 20, weight: .regular)
        case .callout: return .system(size: 18, weight: .regular)
        case .subheadline: return .system(size: 16, weight: .regular)
        case .footnote: return .system(size: 14, weight: .regular)
        case .metric: return .system(size: 56, weight: .heavy)
        case .caption: return .system(size: 12, weight: .regular)
        }
    }
}
```

**Spatial Text Rendering**:
```swift
// Text in 3D space
Text3D("ROI: 400%")
    .font(.system(size: 32, weight: .bold))
    .fontWidth(.condensed)  // Better for spatial text
    .depth(10)  // Slight extrusion
```

### 7.3 Materials and Lighting

**Glass Materials**:
```swift
// UI Windows
.background(.regularMaterial)      // Main windows
.background(.thickMaterial)        // Sidebar
.background(.ultraThinMaterial)    // Floating toolbars

// Interactive elements
Button("Action") { }
    .buttonStyle(.bordered)
    .buttonBorderShape(.capsule)
    .tint(.accent)
```

**3D Materials**:
```swift
// Chart bars - Glossy with color
var barMaterial: PhysicallyBasedMaterial {
    var mat = PhysicallyBasedMaterial()
    mat.baseColor = .init(tint: color)
    mat.roughness = .init(floatLiteral: 0.2)
    mat.metallic = .init(floatLiteral: 0.1)
    mat.blending = .transparent(opacity: 0.9)
    return mat
}

// Selection highlight - Emissive
var highlightMaterial: UnlitMaterial {
    var mat = UnlitMaterial()
    mat.color = .init(tint: .accent)
    mat.blending = .transparent(opacity: 0.5)
    return mat
}

// Background elements - Matte
var backgroundMaterial: PhysicallyBasedMaterial {
    var mat = PhysicallyBasedMaterial()
    mat.baseColor = .init(tint: .gray)
    mat.roughness = .init(floatLiteral: 0.8)
    mat.metallic = .init(floatLiteral: 0.0)
    return mat
}
```

**Lighting**:
```swift
// Image-based lighting for realistic reflections
let environmentResource = try await EnvironmentResource(named: "Studio")
entity.components[ImageBasedLightComponent.self] = ImageBasedLightComponent(
    source: .single(environmentResource)
)

// Directional light for charts
let directionalLight = DirectionalLight()
directionalLight.light.color = .white
directionalLight.light.intensity = 500
directionalLight.position = SIMD3(0, 200, 100)
directionalLight.look(at: .zero, from: directionalLight.position, relativeTo: nil)
```

### 7.4 Iconography in 3D Space

**Icon Style**:
- SF Symbols (Apple's icon system)
- 2D icons with depth (slight extrusion)
- Size: 40-60pt for spatial UI
- Always facing user (billboard effect)

**Icon Usage**:
```swift
// 2D icons in windows
Image(systemName: "chart.bar.fill")
    .font(.system(size: 48))
    .foregroundStyle(.accent)
    .symbolRenderingMode(.hierarchical)

// 3D icons in volumes
struct Icon3D: View {
    var systemName: String

    var body: some View {
        Model3D(named: systemName) { model in
            model
                .resizable()
                .scaledToFit()
        } placeholder: {
            ProgressView()
        }
        .frame(width: 60, height: 60, depth: 10)
    }
}
```

**Use Case Icons**:
- Remote Expert: 🎯 person.2.badge.gearshape
- Training: 📚 book.fill
- Surgery: ⚕️ cross.case.fill
- Showroom: 🏪 storefront.fill
- Design: ✏️ pencil.and.outline
- Field Service: 🔧 wrench.and.screwdriver.fill
- Real Estate: 🏠 house.fill
- Mental Health: 🧠 brain.head.profile
- Data Center: 💻 server.rack
- Manufacturing: ⚙️ gearshape.2.fill

---

## 8. User Flows and Navigation

### 8.1 Primary User Flow

```
Launch App
    ↓
Main Window Opens (Table of Contents visible)
    ↓
User selects "Executive Summary"
    ↓
Content loads in main area
    ↓
User scrolls through content
    ↓
User taps "View 3D Visualization"
    ↓
ROI Comparison Volume opens in space
    ↓
User explores 3D chart (tap, rotate, inspect)
    ↓
User selects specific use case in chart
    ↓
Detail panel appears with full information
    ↓
User marks action item as complete
    ↓
Progress updates in sidebar
```

### 8.2 Navigation Patterns

**Hierarchical Navigation**:
```
Home (Table of Contents)
 ├─ Section 1: Executive Summary
 │   └─ (No subsections)
 ├─ Section 2: Top 10 Use Cases
 │   ├─ Use Case 1
 │   ├─ Use Case 2
 │   └─ ...
 ├─ Section 3: Critical Decisions
 │   ├─ Decision 1
 │   └─ ...
 └─ Section 4: Action Items
     ├─ CEO Actions
     ├─ CFO Actions
     └─ ...
```

**Navigation Controls**:
- Sidebar: Direct access to all sections
- Breadcrumbs: Show current location
- Previous/Next buttons: Sequential navigation
- Search: Jump to content
- Quick access: Bookmarks/favorites

### 8.3 Onboarding Flow

**First Launch**:
```
1. Welcome screen
   "Welcome to the AR/VR Executive Briefing"

2. Brief tutorial (skippable)
   - How to navigate
   - How to open visualizations
   - How to mark action items

3. Optional: Choose your role
   - CEO, CFO, CTO, etc.
   - Highlights relevant action items

4. Start exploring
   - Lands on Executive Summary
```

**Tutorial Tooltips**:
- Appear on first interaction with each feature
- Can be dismissed with "Got it" or "Don't show again"
- Accessible via Help menu anytime

---

## 9. Accessibility Design

### 9.1 VoiceOver Optimization

**Spatial Audio Cues**:
- Sounds originate from interactive elements
- Different sounds for different element types
- Confirmation sounds for actions

**Descriptive Labels**:
```swift
// Before (bad)
Image("icon")

// After (good)
Image("icon")
    .accessibilityLabel("Remote Expert Assistance - ROI 400%")
    .accessibilityHint("Double tap to view detailed metrics and visualization")
```

**Navigable Hierarchies**:
```swift
VStack {
    Text("Top 10 Use Cases")
        .accessibilityAddTraits(.isHeader)

    ForEach(useCases) { useCase in
        UseCaseCard(useCase)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(useCase.title), ROI \(useCase.roi)%")
    }
}
```

### 9.2 Reduced Motion

**Standard View** (motion enabled):
- Smooth animations
- Parallax effects
- Particle systems
- Rotation animations

**Reduced Motion View**:
- Instant transitions (no animation)
- Static backgrounds
- No particle effects
- Simplified visualizations

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

var animation: Animation? {
    reduceMotion ? nil : .spring(response: 0.5)
}
```

### 9.3 High Contrast Mode

```swift
@Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor

var cardBorder: some View {
    RoundedRectangle(cornerRadius: 20)
        .stroke(
            differentiateWithoutColor ? Color.primary : Color.clear,
            lineWidth: differentiateWithoutColor ? 2 : 0
        )
}
```

### 9.4 Alternative Input Methods

**Supported Methods**:
1. Gaze + pinch (primary)
2. Hand gestures (secondary)
3. Voice commands (tertiary)
4. Keyboard shortcuts (Mac-style, if supported)
5. Switch control (for accessibility)

---

## 10. Error States and Loading Indicators

### 10.1 Loading States

**Content Loading**:
```swift
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Loading briefing content...")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial)
    }
}
```

**Visualization Building**:
```swift
struct VisualizationLoadingView: View {
    @State private var progress: Double = 0

    var body: some View {
        VStack(spacing: 20) {
            ProgressView(value: progress)
                .progressViewStyle(.circular)

            Text("Building 3D visualization...")
                .font(.headline)

            Text("\(Int(progress * 100))% complete")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(40)
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
```

### 10.2 Error States

**Content Load Error**:
```swift
struct ErrorView: View {
    let error: Error
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.warning)

            Text("Failed to Load Content")
                .font(.title2)

            Text(error.localizedDescription)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Try Again", action: retry)
                .buttonStyle(.borderedProminent)
        }
        .padding(40)
        .frame(maxWidth: 500)
    }
}
```

**Empty State**:
```swift
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 64))
                .foregroundStyle(.tertiary)

            Text("No Content Available")
                .font(.title3)

            Text("This section is currently empty")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(40)
    }
}
```

---

## 11. Animation and Transition Specifications

### 11.1 Timing Functions

```swift
enum AnimationStyle {
    static let quick = Animation.easeInOut(duration: 0.2)
    static let standard = Animation.easeInOut(duration: 0.3)
    static let slow = Animation.easeInOut(duration: 0.5)
    static let spring = Animation.spring(response: 0.5, dampingFraction: 0.7)
    static let springBouncy = Animation.spring(response: 0.4, dampingFraction: 0.6)
}
```

### 11.2 Common Animations

**Fade In/Out**:
```swift
.opacity(isVisible ? 1 : 0)
.animation(.easeInOut(duration: 0.3), value: isVisible)
```

**Slide In/Out**:
```swift
.offset(y: isPresented ? 0 : 100)
.opacity(isPresented ? 1 : 0)
.animation(.spring(response: 0.5), value: isPresented)
```

**Scale (Bounce)**:
```swift
.scaleEffect(isSelected ? 1.05 : 1.0)
.animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
```

**Rotation**:
```swift
.rotationEffect(.degrees(isRotating ? 360 : 0))
.animation(.linear(duration: 2).repeatForever(autoreverses: false), value: isRotating)
```

### 11.3 Transition Specifications

**Window Transitions**:
```swift
.transition(.asymmetric(
    insertion: .move(edge: .trailing).combined(with: .opacity),
    removal: .move(edge: .leading).combined(with: .opacity)
))
```

**Volume Entrance**:
```swift
.transition(.scale(scale: 0.8).combined(with: .opacity))
```

**Modal Dialogs**:
```swift
.transition(.scale(scale: 1.1).combined(with: .opacity))
```

---

## 12. Responsive Design (Different Spaces)

### 12.1 Compact Mode (Smaller Window)

**Layout Adjustments**:
- Single column layout
- Sidebar collapses to overlay
- Smaller typography scale
- Simplified visualizations

### 12.2 Regular Mode (Standard Window)

**Layout**:
- Two-column layout (sidebar + content)
- Full typography scale
- All features available

### 12.3 Expanded Mode (Large Window)

**Layout**:
- Three-column layout (sidebar + content + info panel)
- Larger typography
- Side-by-side comparisons
- Multiple visualizations simultaneously

---

## Appendix A: Design Assets

### Required Assets

**Icons**:
- App icon (1024×1024)
- Use case icons (10 unique, SF Symbols)
- Action item icons (6 by role)

**3D Models**:
- Chart geometry (procedural, no files needed)
- Optional: Executive briefcase icon (3D)
- Optional: Boardroom environment assets

**Sounds**:
- Transition sound (subtle swoosh)
- Selection sound (tap)
- Completion sound (success chime)
- Error sound (gentle alert)

**Images**:
- None required (all content is text/data)

---

## Appendix B: Design Checklist

- [ ] All interactive elements have min 60pt hit targets
- [ ] All colors meet 4.5:1 contrast ratio
- [ ] All text supports Dynamic Type
- [ ] All images have accessibility labels
- [ ] All animations respect Reduced Motion setting
- [ ] All 3D content has 2D fallback
- [ ] All spatial content positioned 10-15° below eye level
- [ ] All glass materials use system materials
- [ ] All typography uses SF Pro
- [ ] All icons use SF Symbols
- [ ] All sounds are optional (can be disabled)
- [ ] All features work without network
- [ ] All states have appropriate feedback (loading, error, empty)

---

**Document Status**: Ready for implementation
**Next Steps**: Create IMPLEMENTATION_PLAN.md and begin development
