# Spatial CRM - Design Specifications

## 1. Spatial Design Principles

### 1.1 Core Principles for Spatial CRM

1. **Depth Hierarchy**: Use z-axis to communicate importance and relationships
2. **Ergonomic Placement**: Position critical elements 10-15° below eye level
3. **Progressive Disclosure**: Start with familiar 2D, expand to 3D when beneficial
4. **Natural Mapping**: Visualizations mirror real-world metaphors
5. **Comfortable Viewing Distance**: 0.5m - 5m optimal range
6. **Minimal Cognitive Load**: Don't overwhelm with 3D complexity
7. **Purposeful Animation**: Movement aids understanding, not decoration

### 1.2 Spatial Ergonomics

```
User Standing Position (0,0,0)
         │
         │  [Eye Level]
         │
    ─────┼───── -10° to -15° (Optimal viewing angle)
         │
    [Quick Actions: 0.5m - 1.0m]
         │
    [Main Content: 1.0m - 2.0m]
         │
    [Context/Reference: 2.0m - 3.5m]
         │
    [Ambient Info: 3.5m - 5.0m]
```

### 1.3 Interaction Zones

| Zone | Distance | Purpose | Examples |
|------|----------|---------|----------|
| Intimate | 0.5-1.0m | Quick actions, detail work | Customer cards, deal updates |
| Personal | 1.0-2.0m | Primary workspace | Dashboards, pipelines |
| Social | 2.0-3.5m | Analysis, overview | Territory maps, analytics |
| Public | 3.5-5.0m | Context, ambient data | Background metrics, notifications |

## 2. Window Layouts and Configurations

### 2.1 Main Dashboard Window

**Dimensions**: 1400pt × 900pt (default)

```
┌─────────────────────────────────────────────────────────────┐
│  [App Icon] Spatial CRM                    🔔 [User Avatar]  │
├─────────────────────────────────────────────────────────────┤
│  Dashboard  Pipeline  Accounts  Analytics          [Search] │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌───────────────────┐  ┌───────────────────┐              │
│  │   My Pipeline     │  │  Today's Tasks    │              │
│  │                   │  │                   │              │
│  │  [$2.4M]         │  │  □ Call Acme      │              │
│  │   5 Deals        │  │  □ Demo TechCo    │              │
│  │   Closing Soon   │  │  ☑ Send Proposal  │              │
│  └───────────────────┘  └───────────────────┘              │
│                                                               │
│  ┌─────────────────────────────────────────┐                │
│  │  Hot Opportunities                       │                │
│  │  ────────────────────────────────────────│                │
│  │  🔴 Acme Corp      $500K    Negotiation  │                │
│  │  🟠 TechCo         $250K    Proposal     │                │
│  │  🟡 StartupX       $100K    Qualification│                │
│  └─────────────────────────────────────────┘                │
│                                                               │
│  ┌────────────────┐  ┌────────────────┐  ┌──────────────┐  │
│  │  Win Rate      │  │  Avg Deal Size │  │  Forecast    │  │
│  │   72%  ↑      │  │   $180K  ↑    │  │  $1.8M       │  │
│  └────────────────┘  └────────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

**Materials**:
- Background: `.ultraThinMaterial` with vibrancy
- Cards: `.regularMaterial` with subtle shadow
- Active elements: `.thickMaterial` with glow

**Interactions**:
- Hover: Subtle scale (1.0 → 1.02)
- Tap: Spring animation
- Long press: Context menu with blur

### 2.2 Customer Detail Window

**Dimensions**: 1000pt × 700pt

```
┌─────────────────────────────────────────────────────────────┐
│  ← Back              ACME CORPORATION               [Edit]   │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌─────────────┐  Acme Corporation                          │
│  │   [LOGO]    │  Enterprise Software                       │
│  │             │  $2.5M ARR  •  500 employees               │
│  └─────────────┘  ⭐️⭐️⭐️⭐️⭐️ Health Score: 92            │
│                                                               │
│  ┌─────────────────────────────────────────────────────────┐│
│  │  Contacts (12)   Opportunities (3)   Activities (24)   ││
│  ├─────────────────────────────────────────────────────────┤│
│  │                                                         ││
│  │  👤 John Smith - CEO                                   ││
│  │     john@acme.com  •  Decision Maker                   ││
│  │     Last contact: 2 days ago                           ││
│  │                                                         ││
│  │  👤 Sarah Johnson - CTO                                ││
│  │     sarah@acme.com  •  Technical Influencer            ││
│  │     Last contact: 1 week ago                           ││
│  │                                                         ││
│  └─────────────────────────────────────────────────────────┘│
│                                                               │
│  AI Insights:                                                │
│  💡 High engagement last 30 days - consider upsell          │
│  💡 Contract renewal in 45 days - schedule QBR              │
│                                                               │
│  [View in 3D] [Schedule Meeting] [Create Opportunity]       │
└─────────────────────────────────────────────────────────────┘
```

### 2.3 Quick Actions Panel

**Dimensions**: 400pt × 600pt
**Placement**: Trailing edge of primary window

```
┌────────────────────────┐
│   Quick Actions        │
├────────────────────────┤
│                        │
│  📞 Log Call           │
│  ✉️  Send Email        │
│  📅 Schedule Meeting   │
│  📝 Add Note           │
│  ──────────────────    │
│  💼 New Opportunity    │
│  👤 New Contact        │
│  🏢 New Account        │
│  ──────────────────    │
│  🎯 AI Suggestions     │
│                        │
│  • Call John at Acme   │
│  • Follow up TechCo    │
│  • Update forecast     │
│                        │
└────────────────────────┘
```

## 3. Volume Designs (3D Bounded Spaces)

### 3.1 Pipeline River Volume

**Size**: 2.0m × 1.5m × 1.0m (W × H × D)

**Visual Design**:
```
Front View:
    ┌────────────────────────────────────────┐
    │          Closed Won (Ocean)            │
    │              ~~~~~~~~~~~~               │
    │            ~~ [Boats] ~~               │
    ├────────────────────────────────────────┤
    │         Negotiation (Rapids)           │
    │          /\/\/\ [Boats] /\/\/\         │
    ├────────────────────────────────────────┤
    │         Proposal (Stream)              │
    │        --- [Boats] ---                 │
    ├────────────────────────────────────────┤
    │       Needs Analysis (Brook)           │
    │      - [Boats] -                       │
    ├────────────────────────────────────────┤
    │      Qualification (Spring)            │
    │     · [Boats] ·                        │
    ├────────────────────────────────────────┤
    │     Prospecting (Source)               │
    │    . [Boats] .                         │
    └────────────────────────────────────────┘
```

**Interaction Model**:
- **Gaze + Pinch**: Select a deal boat
- **Drag**: Move deal between stages
- **Double Tap**: Open deal details
- **Rotate Hand**: View from different angles
- **Pinch Spread**: Zoom into stage

**Visual Elements**:
- Boats: 3D models sized by deal value
- Water particles: Animated flow direction
- Stage boundaries: Translucent planes
- Velocity indicators: Particle trails
- Blockers: Dam objects (red warning)

**Materials**:
- Water: Shader with reflection/refraction
- Boats: Metallic material with company logo
- Boundaries: Glass with colored tint

### 3.2 Relationship Network Volume

**Size**: 1.5m × 1.5m × 1.5m (cubic)

**Visual Design**:
```
3D Network Graph:
           Contact A (large sphere)
          /    |    \
         /     |     \
    Contact B  C  D   Contact E
         \     |     /
          \    |    /
          Contact F (hub)
```

**Node Representation**:
- **Size**: Influence score (0.1m - 0.3m diameter)
- **Color**:
  - Green: Champion
  - Blue: Influencer
  - Yellow: User
  - Red: Blocker
  - Gray: Unknown
- **Glow**: Engagement level (pulsing)
- **Badge**: Decision maker crown icon

**Edge Representation**:
- **Line Width**: Relationship strength
- **Color**: Interaction recency
  - White: This week
  - Light gray: This month
  - Dark gray: Older
- **Particle Flow**: Recent activity direction
- **Dashed**: Inferred relationship

**Interactions**:
- **Tap Contact**: Expand info panel
- **Tap Edge**: Show interaction history
- **Drag Contact**: Reposition in space
- **Two-finger Gesture**: Create connection
- **Pinch**: Zoom in/out
- **Rotate**: Orbit around network

**Physics Simulation**:
- Force-directed layout (real-time)
- Gravity to center
- Repulsion between nodes
- Attraction along edges
- Collision detection

### 3.3 Account Terrain Volume

**Size**: 2.0m × 1.2m × 1.5m

**Terrain Elements**:
- **Mountain Height**: Revenue (higher = more revenue)
- **Vegetation Density**: Engagement level
- **Water Features**: Cash flow
- **Volcanic Activity**: Risk level (smoking = high risk)
- **Settlements**: Products/services deployed
- **Roads**: Customer journey paths
- **Weather**: Current status
  - Sunny: Healthy
  - Cloudy: At risk
  - Stormy: Critical issues

**Interaction**:
- Walk around terrain (room-scale)
- Point to area: Show metrics
- Pinch to select region: Filter view
- Gesture up: Raise timeline slider

## 4. Full Space / Immersive Experiences

### 4.1 Customer Galaxy (Full Immersive)

**Scale**: Infinite (room-scale and beyond)

**Visual Metaphor**: Solar system
- **Companies**: Suns (size = revenue)
- **Contacts**: Planets (orbit = engagement)
- **Opportunities**: Bright stars
- **Activities**: Comet trails
- **Territory Boundaries**: Constellation outlines

**Central View**:
```
                    ✨ Opportunity
                   /
        🪐 Contact Orbit
       /         \
   [☀️ Company]   🪐 Contact
       \         /
        🪐 Contact Orbit
                   \
                    ☄️ Activity Trail
```

**Spatial Layout**:
- User at origin (0, 0, 0)
- Tier 1 Accounts: 2-3m radius
- Tier 2 Accounts: 4-5m radius
- Tier 3 Accounts: 6-8m radius
- Territory clusters: Grouped by region

**Navigation**:
- **Walk**: Physical movement
- **Teleport**: Point and select distant object
- **Zoom**: Pinch gesture (fly closer)
- **Time Travel**: Rotate dial to see historical state

**Visual Effects**:
- **Gravitational Pull**: Visual indicator of influence
- **Orbital Speed**: Engagement frequency
- **Star Brightness**: Opportunity value
- **Nebula Clouds**: Territory boundaries
- **Cosmic Background**: Ambient market data

**Information Overlay**:
- Floating labels (billboarded)
- Connection lines (animated)
- Metric panels (appear on gaze)
- Timeline scrubber (bottom periphery)

### 4.2 Territory Explorer (Full Immersive)

**Environment**: 360° terrain landscape

**Viewing Modes**:
1. **Ground Level**: Walk through territory
2. **Aerial View**: Bird's eye perspective
3. **Data Layer**: Abstract visualization

**Heat Map Overlays**:
- Revenue density (red = hot)
- Activity frequency (blue = active)
- Risk areas (yellow = warning)
- Opportunity concentration (green = potential)

**Interactive Elements**:
- Buildings represent accounts (height = size)
- Roads connect related accounts
- Traffic flow shows deal movement
- Weather systems indicate health

## 5. Visual Design System

### 5.1 Color Palette

#### Primary Colors (Spatial)
```swift
// Brand Colors
.brandPrimary:   #007AFF (Spatial Blue)
.brandSecondary: #5856D6 (Spatial Purple)
.brandAccent:    #FF9500 (Spatial Orange)

// Status Colors
.success:  #34C759 (Green)
.warning:  #FF9500 (Orange)
.error:    #FF3B30 (Red)
.info:     #5AC8FA (Light Blue)

// Semantic CRM Colors
.hotLead:     #FF3B30 (Pulsing Red)
.warmLead:    #FF9500 (Orange Glow)
.customer:    #34C759 (Green Aura)
.atRisk:      #FFCC00 (Yellow Warning)
.lost:        #8E8E93 (Gray Fade)
.champion:    #FFD700 (Gold)
.blocker:     #FF3B30 (Red)
```

#### Glass Materials
```swift
// Background materials
.dashboardGlass:    .ultraThinMaterial
.cardGlass:         .thinMaterial
.activeCardGlass:   .regularMaterial
.popoverGlass:      .thickMaterial

// Vibrancy
.textVibrancy:      .label
.subtleVibrancy:    .secondaryLabel
.iconVibrancy:      .tertiaryLabel
```

### 5.2 Typography (Spatial Text Rendering)

```swift
// Text Styles for visionOS
.largeTitle:     48pt  -  San Francisco (Rounded)
.title1:         34pt  -  San Francisco (Rounded)
.title2:         28pt  -  San Francisco (Rounded)
.title3:         24pt  -  San Francisco (Rounded)
.headline:       17pt  -  San Francisco (Rounded Semibold)
.body:           17pt  -  San Francisco
.callout:        16pt  -  San Francisco
.subheadline:    15pt  -  San Francisco
.footnote:       13pt  -  San Francisco
.caption1:       12pt  -  San Francisco
.caption2:       11pt  -  San Francisco

// Spatial-specific
.spatialLabel:   24pt  -  High contrast, readable at 2m
.spatialValue:   36pt  -  Bold, key metrics
.spatialHint:    14pt  -  Subtle, contextual info
```

**Rendering Guidelines**:
- Minimum size: 12pt for readability
- High contrast ratios (4.5:1 minimum)
- Use SF Rounded for warmth in spatial context
- Billboard text to face user
- Shadow/outline for depth separation

### 5.3 Iconography in 3D Space

**Icon Sizes**:
- Small: 20pt × 20pt (buttons, indicators)
- Medium: 32pt × 32pt (actions, toolbar)
- Large: 48pt × 48pt (main features)
- Hero: 64pt × 64pt (splash, empty states)

**3D Icon Treatment**:
```swift
// Floating icon with depth
Icon()
    .frame(width: 32, height: 32)
    .padding(12)
    .background(.ultraThinMaterial)
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .shadow(radius: 8, y: 4)  // Depth cue
    .hoverEffect()
```

**Icon Library**:
- SF Symbols 5.0+ (native)
- Custom CRM icons (3D assets)
- Company logos (texture-mapped)
- Status badges (animated)

### 5.4 Materials and Lighting

**Glass Types**:
```swift
// Hierarchy through materials
Level 1 (Background):     .ultraThinMaterial
Level 2 (Containers):     .thinMaterial
Level 3 (Cards):          .regularMaterial
Level 4 (Active):         .thickMaterial
Level 5 (Modal):          .ultraThickMaterial
```

**Lighting Setup**:
```swift
// RealityKit lighting
DirectionalLight:
    - Intensity: 1000 lux
    - Color: Warm white (5500K)
    - Direction: (-1, -1, -0.5) // Upper left

AmbientLight:
    - Intensity: 300 lux
    - Color: Cool white (6500K)

ImageBasedLight:
    - HDRI: "office_environment.hdr"
    - Intensity: 1.0
```

**Material Properties**:
```swift
// Customer entity material
var customerMaterial: PhysicallyBasedMaterial {
    var material = PhysicallyBasedMaterial()
    material.baseColor = .init(tint: customerColor)
    material.metallic = 0.8
    material.roughness = 0.2
    material.emissiveColor = .init(color: glowColor)
    material.emissiveIntensity = 0.5
    return material
}
```

## 6. User Flows and Navigation

### 6.1 Primary User Journey

```
App Launch
    ↓
Biometric Auth
    ↓
Dashboard (2D Window)
    ↓
├─→ Quick Action → Create Deal → Form → Pipeline
├─→ Pipeline Tab → View Options:
│   ├─→ List View (2D)
│   ├─→ Kanban View (2D)
│   └─→ River View (3D Volume) → Deal Details
├─→ Account Tab → Account List
│   └─→ Select Account → Detail View
│       └─→ "View in 3D" → Customer Galaxy (Immersive)
└─→ Analytics Tab → Dashboard
    └─→ "Explore Territory" → Territory Explorer (Immersive)
```

### 6.2 Navigation Patterns

**Tab-Based Navigation** (2D Windows):
```swift
TabView {
    DashboardView()
        .tabItem { Label("Dashboard", systemImage: "square.grid.2x2") }

    PipelineView()
        .tabItem { Label("Pipeline", systemImage: "chart.line.uptrend.xyaxis") }

    AccountsView()
        .tabItem { Label("Accounts", systemImage: "building.2") }

    AnalyticsView()
        .tabItem { Label("Analytics", systemImage: "chart.bar") }
}
```

**Spatial Navigation** (3D Volumes):
- Orbit: Two-finger rotation
- Pan: Two-finger drag
- Zoom: Pinch gesture
- Reset: Double-tap empty space

**Immersive Navigation**:
- Physical walking (room-scale)
- Point-and-teleport (distant objects)
- Gesture-based flying (pinch-pull)
- Voice command ("Go to Acme Corp")

### 6.3 Modal Presentations

**Sheet (Form Entry)**:
```swift
.sheet(isPresented: $showingForm) {
    CreateOpportunityForm()
        .frame(width: 600, height: 700)
        .presentationDetents([.medium, .large])
}
```

**Popover (Contextual Info)**:
```swift
.popover(isPresented: $showingDetails) {
    ContactQuickView()
        .frame(width: 400, height: 300)
}
```

**Immersive Transition**:
```swift
Button("Enter Galaxy") {
    openImmersiveSpace(id: "customer-galaxy")
    dismissWindow(id: "dashboard")
}
```

## 7. Animation and Transition Specifications

### 7.1 Standard Transitions

**Window Appearance**:
```swift
.transition(.asymmetric(
    insertion: .scale(scale: 0.8).combined(with: .opacity),
    removal: .scale(scale: 1.1).combined(with: .opacity)
))
.animation(.spring(response: 0.4, dampingFraction: 0.8), value: isPresented)
```

**Card Flip**:
```swift
.rotation3DEffect(
    .degrees(isFlipped ? 180 : 0),
    axis: (x: 0, y: 1, z: 0)
)
.animation(.spring(response: 0.6, dampingFraction: 0.7), value: isFlipped)
```

**Slide In/Out**:
```swift
.offset(x: isVisible ? 0 : -300)
.opacity(isVisible ? 1 : 0)
.animation(.easeInOut(duration: 0.3), value: isVisible)
```

### 7.2 Spatial Animations

**Deal Stage Transition** (Pipeline River):
```swift
// Smooth movement through stages
withAnimation(.spring(response: 1.0, dampingFraction: 0.6)) {
    deal.position.y += stageHeight
}

// Celebration particles on close
if newStage == .closedWon {
    emitCelebrationParticles(at: deal.position)
    playSound("deal-closed.wav", at: deal.position)
}
```

**Customer Entity Pulse** (Galaxy):
```swift
// Breathing animation for engagement
Entity.runContinuously {
    Transform.scale(by: 1.1, relativeTo: .local)
        .move(duration: 1.0, timingFunction: .easeInOut)
    Transform.scale(by: 0.9, relativeTo: .local)
        .move(duration: 1.0, timingFunction: .easeInOut)
}
```

**Network Force Animation**:
```swift
// Physics-based relationship adjustment
func updateNetworkLayout() {
    let forces = calculateForces(for: contacts)

    withAnimation(.linear(duration: 0.016)) { // 60 FPS
        for (contact, force) in zip(contacts, forces) {
            contact.velocity += force * deltaTime
            contact.position += contact.velocity * deltaTime
            contact.velocity *= dampingFactor
        }
    }
}
```

### 7.3 Loading and Progress

**Skeleton Loading**:
```swift
struct SkeletonCard: View {
    @State private var isAnimating = false

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.ultraThinMaterial)
            .frame(height: 100)
            .overlay(
                LinearGradient(
                    colors: [.clear, .white.opacity(0.3), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: isAnimating ? 400 : -400)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}
```

**Progress Indicator (Spatial)**:
```swift
struct SpatialProgressRing: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(.thinMaterial, lineWidth: 8)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(.brandPrimary, lineWidth: 8)
                .rotationEffect(.degrees(-90))
                .animation(.spring(), value: progress)
        }
        .frame(width: 100, height: 100)
    }
}
```

## 8. Error States and Feedback

### 8.1 Error Presentation

**Inline Error**:
```swift
if let error = viewModel.error {
    HStack {
        Image(systemName: "exclamationmark.triangle.fill")
            .foregroundStyle(.error)
        Text(error.localizedDescription)
            .font(.callout)
        Button("Retry") {
            Task { await viewModel.retry() }
        }
    }
    .padding()
    .background(.regularMaterial)
    .cornerRadius(12)
}
```

**Toast Notification**:
```swift
struct ToastView: View {
    let message: String
    let type: ToastType

    var body: some View {
        HStack {
            Image(systemName: type.icon)
            Text(message)
        }
        .padding()
        .background(.ultraThickMaterial)
        .cornerRadius(12)
        .shadow(radius: 8)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
```

**Spatial Error Indicator**:
```swift
// Floating error badge in 3D space
ModelEntity(
    mesh: .generateSphere(radius: 0.05),
    materials: [SimpleMaterial(color: .red, isMetallic: false)]
)
.position([0, 0.2, 0])  // Above failed entity
.runContinuously {
    Transform.rotationAnimation(around: [0, 1, 0], duration: 2)
}
```

### 8.2 Empty States

**No Data**:
```swift
VStack(spacing: 20) {
    Image(systemName: "tray")
        .font(.system(size: 64))
        .foregroundStyle(.tertiary)

    Text("No Opportunities Yet")
        .font(.title2)

    Text("Create your first deal to get started")
        .font(.body)
        .foregroundStyle(.secondary)

    Button("Create Opportunity") {
        showCreateForm = true
    }
    .buttonStyle(.borderedProminent)
}
.frame(maxWidth: .infinity, maxHeight: .infinity)
```

**No Search Results**:
```swift
VStack {
    Image(systemName: "magnifyingglass")
        .font(.system(size: 48))
    Text("No results for '\(searchQuery)'")
    Button("Clear Search") {
        searchQuery = ""
    }
}
```

## 9. Accessibility Design

### 9.1 VoiceOver Optimization

**Semantic Labels**:
```swift
CustomerCard(customer)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(customer.name), \(customer.industry)")
    .accessibilityValue("Health score \(customer.healthScore) percent")
    .accessibilityHint("Double tap to view customer details")
```

**Custom Actions**:
```swift
.accessibilityAction(named: "Call Primary Contact") {
    callContact(customer.primaryContact)
}
.accessibilityAction(named: "View Opportunities") {
    showOpportunities(for: customer)
}
```

### 9.2 Alternative Visualizations

**2D Fallback**:
- Provide list view alternative for all 3D visualizations
- Keyboard navigation for all spatial content
- Screen reader descriptions of 3D layouts

**Simplified Mode**:
- Reduce animations
- Limit 3D complexity
- Increase contrast
- Larger hit targets (80pt minimum)

### 9.3 Inclusive Design

- Color blindness safe palette (use patterns + color)
- Haptic feedback for confirmations
- Audio cues for state changes
- Subtitles for all voice feedback
- Adjustable font sizes (up to 200%)

## 10. Responsive Design & Adaptivity

### 10.1 Window Resizing

```swift
@State private var windowSize: CGSize = CGSize(width: 1400, height: 900)

var body: some View {
    GeometryReader { geometry in
        if geometry.size.width > 1200 {
            ThreeColumnLayout()
        } else if geometry.size.width > 800 {
            TwoColumnLayout()
        } else {
            SingleColumnLayout()
        }
    }
}
```

### 10.2 Device Adaptivity

**visionOS Simulator** (Development):
- Simplified 3D (lower poly count)
- Reduced particle effects
- Placeholder 3D assets

**Apple Vision Pro** (Production):
- Full fidelity 3D
- Advanced rendering
- All spatial features

---

## Appendix A: Component Library

### Standard Components
- SpatialButton
- GlassCard
- FloatingPanel
- MetricWidget
- SearchBar
- ContextMenu
- ActionSheet
- Timeline
- DataGrid

### CRM-Specific Components
- CustomerCard
- OpportunityCard
- ContactAvatar
- HealthScoreMeter
- PipelineStage
- ActivityTimeline
- RelationshipGraph
- TerritoryHeatMap

## Appendix B: Design Tokens

```swift
enum DesignTokens {
    // Spacing
    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 16
    static let spacingL: CGFloat = 24
    static let spacingXL: CGFloat = 32
    static let spacingXXL: CGFloat = 48

    // Corner Radius
    static let radiusS: CGFloat = 8
    static let radiusM: CGFloat = 12
    static let radiusL: CGFloat = 16
    static let radiusXL: CGFloat = 24

    // Shadows
    static let shadowS: CGFloat = 4
    static let shadowM: CGFloat = 8
    static let shadowL: CGFloat = 16

    // Animation Durations
    static let durationQuick: TimeInterval = 0.2
    static let durationNormal: TimeInterval = 0.3
    static let durationSlow: TimeInterval = 0.5
}
```

## Appendix C: Gesture Cheat Sheet

| Gesture | 2D Action | 3D Action |
|---------|-----------|-----------|
| Tap | Select | Select entity |
| Double Tap | Open | Reset view |
| Long Press | Context menu | Info panel |
| Drag | Scroll | Move entity |
| Pinch | Zoom | Scale/fly |
| Two-Finger Rotate | - | Orbit view |
| Three-Finger Swipe | Switch app | - |
| Palm Up | - | Go home |
| Victory Sign | - | Mark complete |
| Fist | - | Delete |
