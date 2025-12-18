# Financial Operations Platform - Design Specification

## Table of Contents
1. [Spatial Design Principles](#spatial-design-principles)
2. [Window Layouts & Configurations](#window-layouts--configurations)
3. [Volume Designs (3D Bounded Spaces)](#volume-designs-3d-bounded-spaces)
4. [Full Space / Immersive Experiences](#full-space--immersive-experiences)
5. [3D Visualization Specifications](#3d-visualization-specifications)
6. [Interaction Patterns](#interaction-patterns)
7. [Visual Design System](#visual-design-system)
8. [User Flows & Navigation](#user-flows--navigation)
9. [Accessibility Design](#accessibility-design)
10. [Error States & Loading Indicators](#error-states--loading-indicators)
11. [Animation & Transition Specifications](#animation--transition-specifications)

---

## Spatial Design Principles

### Core Spatial Principles

#### 1. Ergonomic Positioning
- **Primary Content Zone**: 10-15° below eye level for comfortable viewing
- **Depth Layering**: Content at varying depths (0.5m - 3m) for hierarchy
- **Reading Distance**: Text content at 0.6m - 1.2m for optimal readability
- **Interaction Zone**: Interactive elements within arm's reach (0.3m - 0.6m)

```
Spatial Zones (Side View)
        User's Eye Level
            ━━━━━━━━
               ↓
        [10-15° Below]
               ↓
    ┌────────────────────┐
    │  Primary Dashboard │  ← 0.8m - 1.2m distance
    │   (Main Window)    │
    └────────────────────┘
           ↓
    [Interactive Panel]      ← 0.5m - 0.7m
           ↓
    [Detail Cards]           ← 0.3m - 0.5m
```

#### 2. Information Hierarchy Through Depth
- **Tier 1 (Closest)**: Critical actions, alerts, current transactions
- **Tier 2 (Middle)**: Dashboard, KPIs, main content
- **Tier 3 (Far)**: Context, history, background visualizations
- **Tier 4 (Environment)**: Immersive 3D landscapes

#### 3. Progressive Disclosure
```
Complexity Level Progression:
1. Start → Simple 2D Windows (Dashboard)
2. Explore → Add 3D Volumes (KPI Cubes)
3. Analyze → Enter Mixed Immersive Spaces (Cash Flow Universe)
4. Present → Full Immersive Presentations (Executive View)
```

#### 4. Spatial Affordances
- **Glass Materials**: Indicate interactivity and layering
- **Shadows**: Provide depth cues
- **Proximity Highlights**: Gaze-based focus indicators
- **Scale Variations**: Size indicates importance
- **Spatial Audio**: Directional cues for alerts

#### 5. Comfort & Focus
- **Anti-Fatigue Design**: Limit continuous 3D immersion to 20-30 minutes
- **Focus Mode**: Minimize distractions when processing transactions
- **Break Reminders**: Suggest eye rest after extended use
- **Adjustable Layouts**: User-customizable window positions

---

## Window Layouts & Configurations

### Primary Dashboard Window

```
┌─────────────────────────────────────────────────────────────┐
│  Financial Operations Dashboard              [⚙️] [👤] [🔔] │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Cash Position│  │Working Capital│  │   Forecast   │      │
│  │   $847M      │  │    $432M     │  │  Accuracy    │      │
│  │   ↑ 5.2%    │  │    ↓ 2.1%   │  │    92%       │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                                                              │
│  ┌─────────────────────────────────────────────────┐        │
│  │  Cash Flow Trend (Last 30 Days)                 │        │
│  │  [Line chart showing cash flow]                 │        │
│  └─────────────────────────────────────────────────┘        │
│                                                              │
│  Recent Transactions                                         │
│  ┌─────────────────────────────────────────────────┐        │
│  │ Date        Description      Amount    Status   │        │
│  │ 2024-11-17  Invoice #12345  $12,500   Pending   │        │
│  │ 2024-11-17  Payment to...   -$8,200   Approved  │        │
│  │ 2024-11-16  Vendor Payment  -$5,400   Posted    │        │
│  └─────────────────────────────────────────────────┘        │
│                                                              │
│  Quick Actions                                               │
│  [Process Transaction] [Review Approvals] [Run Report]      │
└─────────────────────────────────────────────────────────────┘
                    [Ornament Toolbar Below]
            [Refresh] [Filter] [Export] [3D View]
```

**Specifications**:
- **Default Size**: 1400x900 points
- **Minimum Size**: 1000x600 points
- **Position**: Centered, 1.2m from user
- **Materials**: Glass background with vibrancy
- **Resizable**: Yes
- **Multiple Instances**: No (single dashboard)

### Transaction Detail Window

```
┌─────────────────────────────────────────────────┐
│  Transaction Details                      [✕]  │
├─────────────────────────────────────────────────┤
│                                                  │
│  Transaction ID: TX-2024-11-17-001              │
│                                                  │
│  ┌────────────────────────────────────────────┐ │
│  │ Amount: $12,500.00                         │ │
│  │ Date: November 17, 2024                    │ │
│  │ Account: 1001 - Cash Operating             │ │
│  │ Description: Customer Payment - INV-12345  │ │
│  │ Status: Pending Approval                   │ │
│  └────────────────────────────────────────────┘ │
│                                                  │
│  Audit Trail                                     │
│  ┌────────────────────────────────────────────┐ │
│  │ Created: John Smith - 11/17 09:30 AM       │ │
│  │ Reviewed: Sarah Jones - 11/17 10:15 AM     │ │
│  │ Pending: CFO Approval                      │ │
│  └────────────────────────────────────────────┘ │
│                                                  │
│  Supporting Documents (2)                        │
│  📄 Invoice-12345.pdf                           │
│  📄 Purchase-Order.pdf                          │
│                                                  │
│         [Approve] [Reject] [Request Info]       │
└─────────────────────────────────────────────────┘
```

**Specifications**:
- **Default Size**: 800x700 points
- **Position**: Overlays dashboard, slightly offset
- **Modal**: Yes (blocks interaction with parent)
- **Gestures**: Swipe to approve/reject (optional)

### Treasury Command Center Window

```
┌─────────────────────────────────────────────────────────────┐
│  Treasury Command Center                                     │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Global Cash Position                    [Enter 3D Universe]│
│  ┌──────────┬──────────┬──────────┬──────────┐             │
│  │   USD    │   EUR    │   GBP    │   JPY    │             │
│  │  $523M   │  €145M   │  £87M    │  ¥12B    │             │
│  └──────────┴──────────┴──────────┴──────────┘             │
│                                                              │
│  30-Day Forecast                                             │
│  ┌─────────────────────────────────────────────────┐        │
│  │  [Waterfall chart showing projected cash flow]  │        │
│  │  Projected Position: $792M                      │        │
│  │  Risk: Customer X payment delay ($23M)          │        │
│  └─────────────────────────────────────────────────┘        │
│                                                              │
│  Optimization Opportunities                                  │
│  🎯 Trapped Cash in APAC: $112M                             │
│  🎯 FX Hedging Opportunity: €15M                            │
│  🎯 Investment Yield Improvement: $5M annually              │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Close Management Window

```
┌─────────────────────────────────────────────────────────────┐
│  Month-End Close: November 2024                   [3D View] │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Progress: 67% Complete                    Day 2 of 3       │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━░░░░░░░       │
│                                                              │
│  Critical Path Tasks                                         │
│  ✅ Bank Reconciliations (15/15)                            │
│  🔄 Revenue Recognition (8/12)  [Sarah - In Progress]       │
│  ⏳ Accruals Review (0/8)       [John - Starts at 2 PM]     │
│  ⏳ Management Review (0/1)     [Blocked - Waiting]         │
│                                                              │
│  Issues Requiring Attention (3)                              │
│  ⚠️ GL Account 4550 - $12K variance                         │
│  ⚠️ Missing vendor invoice for $8,500                       │
│  ⚠️ Intercompany mismatch: $3,200                           │
│                                                              │
│  Team Status                                                 │
│  👤 Sarah Jones    - Working on Revenue Recognition          │
│  👤 John Smith     - Available at 2 PM                       │
│  👤 Mary Johnson   - Completed reconciliations               │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Volume Designs (3D Bounded Spaces)

### KPI Performance Cube

**Visual Design**:
```
       ┌─────────────────┐
      /│   Profitability │/
     / │      15.2%     │/
    /  │       ↑       │/
   ┌───┼───────────────┤
   │   │   Liquidity   │
   │   │     92%       │
   │   │      →        │
   ├───┼───────────────┤
   │   │   Efficiency  │
   │   │     78%       │
   │   │      ↓        │
   └───┴───────────────┘
```

**Specifications**:
- **Size**: 0.5m x 0.5m x 0.5m
- **Position**: Floating to the left of dashboard, 0.8m away
- **Materials**:
  - Glass panels with gradient fills
  - Green: Goals achieved
  - Yellow: Warning zone
  - Red: Below target
- **Interactions**:
  - Tap panel to expand details
  - Rotate cube with hand gesture
  - Pull panel out for detailed view
- **Animations**:
  - Gentle rotation (5-second cycle)
  - Pulse effect on value changes
  - Color transitions on threshold changes

### Cash Flow Mini-Universe (Volume)

**Visual Design**:
```
    💧 Revenue Streams
       ↓ ↓ ↓
    ┌──────────────┐
    │  💰 💰 💰    │  ← Liquidity Pool
    │              │
    │   ↓  ↓  ↓   │  ← Outflows
    └──────────────┘
       Expense Valleys
```

**Specifications**:
- **Size**: 0.6m x 0.4m x 0.4m
- **Contents**:
  - Animated water particles (revenue inflows)
  - Liquid simulation (cash pool)
  - Drain visualization (expense outflows)
- **Real-time Updates**:
  - Particles spawn on new revenue
  - Pool level adjusts with balance changes
  - Drain rate reflects expense velocity
- **Color Coding**:
  - Blue particles: Operating revenue
  - Green particles: Investment income
  - Purple: Financing activities

### Risk Heat Map Volume

**Visual Design**:
```
    High Risk ↑
    ┌─────────────────┐
    │  🔴 Market      │
    │      Risk       │
    ├─────────────────┤
    │  🟡 Credit      │
    │      Risk       │
    ├─────────────────┤
    │  🟢 Operational │
    │      Risk       │
    └─────────────────┘
    Low Risk
```

**Specifications**:
- **Size**: 0.4m x 0.6m x 0.3m
- **Visualization**: 3D terrain with elevation
  - Height = Risk severity
  - Color = Risk category
  - Pulses = Active risks
- **Interaction**:
  - Tap risk zone for details
  - Pinch to zoom into specific risk
- **Updates**: Real-time risk scoring

---

## Full Space / Immersive Experiences

### Cash Flow Universe (Mixed Immersive)

**Overview**:
Transforms the user's environment into a financial landscape where cash flows like rivers, liquidity pools form lakes, and investments grow as forests.

**Spatial Layout**:
```
User Position (Center)
        👤
       / \
      /   \

360° Financial Landscape:

Front (0°): Revenue Rivers
  - Multiple streams flowing toward user
  - Width = revenue magnitude
  - Speed = frequency
  - Color = source type

Right (90°): Expense Valleys
  - Valleys draining away from user
  - Depth = expense amount
  - Flow rate = payment velocity

Back (180°): Investment Forests
  - Trees growing upward
  - Height = investment value
  - Growth animation = returns

Left (270°): Liquidity Lakes
  - Calm water bodies
  - Size = cash balance
  - Clarity = availability

Above: Performance Sky
  - Weather = financial health
  - Clear sky = good performance
  - Storm clouds = risks

Below: Historical Foundation
  - Ground terrain = past performance
  - Layers = quarterly results
```

**Visual Specifications**:

**Revenue Rivers**:
- Material: Flowing liquid shader (blue gradient)
- Particles: 1000-5000 particles per stream
- Width: 0.5m - 3m based on revenue amount
- Flow velocity: 0.1m/s - 1.0m/s
- Audio: Water flowing sounds (spatial)

**Expense Valleys**:
- Material: Rocky terrain with erosion
- Depth: 0.5m - 2m below ground plane
- Drainage streams: Red/orange particles
- Audio: Draining sounds

**Liquidity Lakes**:
- Material: Reflective water surface
- Size: Radius 1m - 10m
- Waves: Gentle ripples
- Depth visualization: Transparency gradient
- Audio: Calm water ambience

**Investment Forests**:
- Models: Procedural trees
- LOD: 3 levels (high/med/low detail)
- Height: 2m - 8m
- Growth animation: 5-10 seconds for value changes
- Leaves: Color-coded by asset type

**Interaction Patterns**:
1. **Navigation**:
   - Gaze direction + head movement to "fly"
   - Hand gesture to "walk" through landscape
   - Pinch and pull to teleport

2. **Data Exploration**:
   - Approach river → Shows revenue details
   - Touch lake → Cash position breakdown
   - Grab tree → Investment performance

3. **Time Travel**:
   - Swipe gesture to scrub through time
   - Past: Landscape fades to sepia
   - Future: Projected landscape (transparent)

**UI Overlays**:
```
Top Right Corner:
┌─────────────────┐
│ Mini Map        │
│  [Radar view]   │
│                 │
│ Timeline        │
│ ←─────●─────→  │
│ Past   Now  Future │
└─────────────────┘

Bottom Center:
[Details Panel - Context Aware]
Shows info about focused element
```

### Risk Topography (Mixed Immersive)

**Concept**: 3D terrain where elevation represents risk severity

**Spatial Layout**:
```
    High Risk Mountains
         ⛰️ ⛰️
        /    \
       /      \
    Risk Plateaus 🏔️
      /        \
     /          \
  Safe Plains 🌾
 ────────────────
```

**Visual Specifications**:

**Terrain Generation**:
- Base: 10m x 10m plane
- Elevation range: 0m (no risk) - 5m (critical risk)
- Mesh resolution: 100x100 vertices
- Material: Gradient from green → yellow → red
- Texture: Contour lines every 0.5m elevation

**Risk Entities**:
- **Market Risk**: Storm clouds above mountains
- **Credit Risk**: Cracks in terrain
- **Liquidity Risk**: Dry riverbeds
- **Operational Risk**: Earthquake tremors
- **Compliance Risk**: Warning beacons

**Interaction**:
1. **Fly Over**: Navigate above terrain
2. **Drill Down**: Tap high-risk area to see details
3. **Scenario Testing**: Add hypothetical risks to see terrain change

**Time Dimension**:
- Slider to view risk evolution over time
- Animation shows terrain morphing
- Predictive view shows forecasted risk landscape

### Financial Close Environment (Mixed Immersive)

**Concept**: 3D workspace showing close process as mountain climbing expedition

**Spatial Layout**:
```
      🏔️ Summit
     (Month Closed)
         /\
        /  \
    Checkpoints (Tasks)
      🏕️ 🏕️ 🏕️
       /     \
      /       \
   Base Camp
  (Start of Close)
```

**Visual Elements**:

**Task Mountains**:
- Each task = mountain to climb
- Height = complexity/hours
- Color = status
  - Gray: Not started
  - Blue: In progress
  - Green: Completed
  - Red: Blocked
- Climbers: Team members (avatars)

**Dependency Paths**:
- Rope bridges connecting mountains
- Shows task dependencies
- Can't cross until prerequisite complete

**Progress Indicators**:
- Flags planted at checkpoints
- Percentage markers on mountain sides
- Time remaining: Sun position in sky

**Collaboration**:
- See team members working on tasks
- Chat bubbles for communication
- Hand off items between members

### Performance Galaxy (Full Immersive)

**Concept**: Financial metrics as star constellations

**Spatial Layout**:
```
        ✨ ✨ ✨
     KPI Constellation

  ✨        ✨       ✨
Revenue  Profit  Growth
 Stars    Stars   Stars

      Nebula of Metrics
     (Historical Data)
```

**Visual Specifications**:

**Stars (Individual KPIs)**:
- Size: Proportional to importance
- Brightness: Performance vs. target
  - Bright: Exceeding target
  - Dim: Below target
- Color: Category-coded
  - Blue: Financial
  - Green: Operational
  - Gold: Strategic
- Twinkle: Recent activity

**Constellations (KPI Groups)**:
- Lines connecting related metrics
- Label hovering above group
- Constellation rotation: Gentle orbit

**Nebulas (Trend Data)**:
- Particle clouds showing variance
- Density = data points
- Color = positive/negative trend

**Interactive Elements**:
1. **Reach and Grab**: Pull star toward you for details
2. **Gaze Selection**: Look at star → highlights constellation
3. **Voice Command**: "Show me profitability" → zooms to constellation
4. **Time Travel**: Scrub timeline to see historical galaxy state

---

## Interaction Patterns

### Gaze + Pinch (Primary)

**Use Cases**:
1. **Selection**: Gaze at element + pinch to select
2. **Activation**: Gaze at button + pinch to activate
3. **Drag**: Gaze at object + pinch and move hand to drag

**Visual Feedback**:
- Gaze cursor: Subtle ring on focused element
- Pre-pinch: Element highlights (glow)
- During pinch: Element scales slightly (1.05x)
- Success: Brief flash + haptic (if supported)

**Example**:
```swift
VStack {
    TransactionCard(transaction: transaction)
        .hoverEffect(.highlight)
        .onTapGesture {
            selectTransaction(transaction)
        }
}
```

### Hand Tracking Gestures

**Financial Gesture Library**:

1. **Approve** (Thumbs Up):
   - Recognize: Thumb extended, other fingers curled
   - Action: Approve selected transaction
   - Feedback: Green checkmark animation

2. **Reject** (Swipe Away):
   - Recognize: Flat palm, quick horizontal movement
   - Action: Reject selected transaction
   - Feedback: Red X animation, item slides away

3. **Review** (Circle Motion):
   - Recognize: Index finger draws circle
   - Action: Open detailed review panel
   - Feedback: Panel spirals open

4. **Drill Down** (Point + Push):
   - Recognize: Index finger extended, push forward
   - Action: Navigate deeper into data
   - Feedback: Zoom transition

5. **Compare** (Two Hands Side-by-Side):
   - Recognize: Both palms facing each other
   - Action: Place two items for comparison
   - Feedback: Split screen view

6. **Filter** (Funnel Shape):
   - Recognize: Hands form funnel shape
   - Action: Open filter menu
   - Feedback: Filter panel appears

7. **Export** (Grab and Pull):
   - Recognize: Pinch object and pull toward body
   - Action: Export data
   - Feedback: Object copies and shrinks into download icon

**Implementation Guidelines**:
- **Confidence Threshold**: 80% recognition confidence
- **Debounce**: 500ms between gesture activations
- **Fallback**: Always provide button alternative
- **Tutorial**: First-run gesture guide

### Voice Commands

**Command Structure**:
```
[Action] [Target] [Modifier]

Examples:
- "Show cash position"
- "Approve transaction 12345"
- "Compare Q1 to Q2"
- "Filter by region Asia"
- "Export November close report"
```

**Supported Commands**:

**Navigation**:
- "Go to dashboard"
- "Open treasury"
- "Enter cash flow universe"
- "Exit immersive space"

**Data Query**:
- "Show [metric/report]"
- "What's the [KPI name]"
- "Display [account] transactions"

**Actions**:
- "Approve [transaction ID]"
- "Reject [transaction ID]"
- "Process [payment/invoice]"
- "Create [report/transaction]"

**Analysis**:
- "Compare [A] to [B]"
- "Forecast [metric] for [period]"
- "Show variance for [account]"

**Filtering**:
- "Filter by [criteria]"
- "Show only [status]"
- "Limit to [region/department]"

**Feedback**:
- Visual: Command text appears briefly
- Audio: Confirmation chime
- Result: Requested action executes

---

## Visual Design System

### Color Palette

#### Primary Colors

**Glass Material Base**:
- Background: `Color.clear` with `.ultraThinMaterial`
- Vibrancy: Automatic based on environment

**Accent Colors**:
```swift
// Financial Status Colors
let positive = Color.green       // Growth, profit, surplus
let negative = Color.red         // Loss, deficit, risk
let neutral = Color.blue         // Stable, informational
let warning = Color.orange       // Caution, review needed
let critical = Color.red         // Urgent attention required

// Category Colors
let revenue = Color.cyan         // Revenue streams
let expense = Color.orange       // Expense flows
let asset = Color.green          // Assets
let liability = Color.red        // Liabilities
let equity = Color.purple        // Equity
```

**Semantic Colors**:
```swift
let approved = Color.green
let pending = Color.yellow
let rejected = Color.red
let posted = Color.blue
let reconciled = Color.green.opacity(0.8)
```

#### Gradient Definitions

**Cash Flow Gradient**:
```swift
LinearGradient(
    colors: [
        Color(red: 0.0, green: 0.5, blue: 1.0),  // Deep blue
        Color(red: 0.3, green: 0.8, blue: 1.0)   // Light cyan
    ],
    startPoint: .top,
    endPoint: .bottom
)
```

**Risk Gradient** (Green → Yellow → Red):
```swift
LinearGradient(
    stops: [
        .init(color: .green, location: 0.0),
        .init(color: .yellow, location: 0.5),
        .init(color: .red, location: 1.0)
    ],
    startPoint: .bottom,
    endPoint: .top
)
```

**Performance Gradient**:
```swift
AngularGradient(
    colors: [.blue, .purple, .pink, .orange, .yellow, .green, .blue],
    center: .center
)
```

### Typography

**Font System** (SF Pro for visionOS):

```swift
// Display (Large numbers, KPIs)
.font(.system(size: 64, weight: .bold, design: .rounded))

// Title (Section headers)
.font(.system(size: 34, weight: .bold))

// Headline (Card titles)
.font(.system(size: 24, weight: .semibold))

// Body (Main content)
.font(.system(size: 17, weight: .regular))

// Caption (Secondary info)
.font(.system(size: 13, weight: .regular))

// Monospaced (Financial amounts)
.font(.system(size: 17, weight: .regular, design: .monospaced))
```

**Spatial Text Rendering**:
- **Near Text** (< 1m): Standard rendering
- **Far Text** (> 1m): Increased weight, higher contrast
- **3D Labels**: Billboard rendering (always face user)

**Financial Amount Formatting**:
```swift
Text(amount.formatted(.currency(code: "USD")))
    .font(.system(.title, design: .monospaced))
    .foregroundColor(amount >= 0 ? .green : .red)
```

### Materials & Lighting

#### Glass Materials

**Standard Glass** (Windows):
```swift
.background(.ultraThinMaterial)
```

**Thick Glass** (Important panels):
```swift
.background(.thickMaterial)
```

**Vibrant Glass** (Active elements):
```swift
.background(.ultraThickMaterial)
```

#### 3D Materials

**Metallic** (Important metrics):
```swift
var material = PhysicallyBasedMaterial()
material.baseColor = .init(tint: .gold)
material.metallic = 0.9
material.roughness = 0.1
```

**Glass** (Transparent volumes):
```swift
var material = PhysicallyBasedMaterial()
material.baseColor = .init(tint: .blue.withAlphaComponent(0.3))
material.opacity = 0.3
material.blending = .transparent
```

**Emission** (Alerts, highlights):
```swift
var material = UnlitMaterial()
material.color = .init(tint: .red)
material.emissiveIntensity = 2.0
```

#### Lighting

**Ambient Light**:
- Intensity: 500 lux
- Color temperature: 6500K (daylight)

**Directional Light** (Key light):
- Intensity: 1000 lux
- Angle: 45° from top-left
- Shadow: Soft, 0.3 opacity

**Point Lights** (Highlights):
- Used sparingly for emphasis
- Attached to critical elements (alerts)

### Iconography

**Icon Style**:
- SF Symbols (visionOS optimized)
- Size: 24pt - 48pt
- Weight: Regular to Semibold
- Render mode: Hierarchical or multicolor

**Financial Icons**:
```swift
// Metrics
Image(systemName: "chart.line.uptrend.xyaxis")  // Growth
Image(systemName: "dollarsign.circle")          // Cash
Image(systemName: "arrow.up.arrow.down")        // Variance
Image(systemName: "gauge.high")                 // Performance

// Actions
Image(systemName: "checkmark.circle.fill")      // Approve
Image(systemName: "xmark.circle.fill")          // Reject
Image(systemName: "doc.text.magnifyingglass")   // Review
Image(systemName: "arrow.triangle.2.circlepath") // Reconcile

// Status
Image(systemName: "clock")                      // Pending
Image(systemName: "checkmark.seal.fill")        // Posted
Image(systemName: "exclamationmark.triangle")   // Warning
```

**3D Icons** (For immersive spaces):
- Simple geometric shapes
- Consistent visual language
- Animated on interaction

---

## User Flows & Navigation

### Primary User Journey: Daily Dashboard Check

```
1. Launch App
   ↓
2. Dashboard Loads (Main Window)
   - View KPIs at a glance
   - Scan recent transactions
   - Check alerts
   ↓
3. Investigate Alert [Optional]
   - Tap alert → Detail window opens
   - Review details
   - Take action or dismiss
   ↓
4. Enter 3D View [Optional]
   - Tap "3D View" button
   - Opens KPI volume or immersive space
   - Explore spatial visualization
   ↓
5. Return to Dashboard
   - Dismiss 3D view
   - Continue monitoring
```

### Transaction Approval Flow

```
1. Dashboard - Pending Transactions Section
   ↓
2. Tap Transaction Row
   ↓
3. Transaction Detail Window Opens
   - Review amount, description, audit trail
   - View supporting documents
   ↓
4. Decision Point
   ├─→ Approve
   │   ├─→ Thumbs Up gesture OR
   │   └─→ Tap "Approve" button
   │       ↓
   │   Success confirmation
   │   Window dismisses
   │
   └─→ Reject / Request More Info
       ├─→ Swipe away gesture OR
       └─→ Tap "Reject" / "Request Info"
           ↓
       Reason dialog
       Submit
```

### Cash Flow Analysis Flow

```
1. Dashboard → Tap "Treasury" Module
   ↓
2. Treasury Command Center Opens
   - View global cash position
   - See 30-day forecast
   - Review optimization opportunities
   ↓
3. Tap "Enter 3D Universe" Button
   ↓
4. Transition to Immersive Space
   - Dissolve transition (1 second)
   - Environment fades in
   ↓
5. Cash Flow Universe Loads
   - Revenue rivers appear
   - Liquidity lakes form
   - Investment forests grow
   ↓
6. Explore & Interact
   - Navigate through landscape
   - Tap elements for details
   - Time travel to see forecasts
   ↓
7. Exit Immersive Space
   - Return gesture or button
   - Fade back to window
```

### Month-End Close Flow

```
1. Dashboard → Tap "Close Management"
   ↓
2. Close Management Window Opens
   - View task checklist
   - See progress percentage
   - Review issues
   ↓
3. [Optional] Enter 3D Close Environment
   - Tap "3D View"
   - Mountain climbing visualization
   ↓
4. Work Through Tasks
   - Select task
   - Complete work
   - Mark complete
   ↓
5. Resolve Issues
   - Tap issue
   - Investigate
   - Take corrective action
   ↓
6. Monitor Team Progress
   - See team member status
   - Collaborate via chat
   ↓
7. Final Review & Close
   - CFO approval
   - Lock period
   - Generate reports
```

### Navigation Patterns

**Window Navigation**:
```
Dashboard (Home)
  ├─→ Transactions
  ├─→ Treasury
  │   └─→ Cash Flow Universe (Immersive)
  ├─→ Analytics
  │   └─→ Performance Galaxy (Immersive)
  ├─→ Close Management
  │   └─→ Close Environment (Immersive)
  └─→ Settings
```

**Navigation Controls**:
- **Tab Bar**: Main modules (always visible)
- **Breadcrumbs**: Show current location
- **Back Button**: Return to previous window
- **Home Button**: Return to dashboard
- **Exit Button**: Leave immersive space

**Spatial Navigation**:
- **Head Tracking**: Look around naturally
- **Hand Gestures**: Point and pinch to navigate
- **Voice**: "Go to [destination]"
- **Teleport**: Pinch and pull to jump locations

---

## Accessibility Design

### VoiceOver Optimization

**Spatial Audio Cues**:
- Focused element: Spatial audio from element's position
- Navigation: Audio breadcrumbs guide user

**Descriptive Labels**:
```swift
// Good
Image(systemName: "dollarsign.circle")
    .accessibilityLabel("Cash position")
    .accessibilityValue("$847 million, up 5.2% from last month")
    .accessibilityHint("Double tap to view details")

// Bad
Image(systemName: "dollarsign.circle")
    .accessibilityLabel("Icon")
```

**Hierarchical Navigation**:
- Logical tab order
- Group related elements
- Skip navigation option

### Motor Accessibility

**Alternatives to Hand Gestures**:
1. **Voice Commands**: Every gesture has voice equivalent
2. **Button Fallbacks**: Traditional buttons always available
3. **Dwell Selection**: Gaze at element for 2 seconds to select
4. **Switch Control**: External switch input support

**Enlarged Hit Targets**:
- Minimum: 60pt x 60pt
- Preferred: 88pt x 88pt
- 3D objects: Collision bounds extended 20%

### Visual Accessibility

**High Contrast Mode**:
```swift
@Environment(\.colorSchemeContrast) var contrast

var backgroundColor: Color {
    contrast == .increased ? .black : .gray.opacity(0.2)
}
```

**Color Blindness Support**:
- Never rely on color alone
- Add patterns/textures
- Use labels and icons

**Dynamic Type**:
- All text supports Dynamic Type
- Layout adapts to larger text
- Critical info never truncated

### Cognitive Accessibility

**Simplified Mode**:
- Toggle to reduce visual complexity
- Remove animations
- Linear navigation only
- Larger, clearer labels

**Focus Indicators**:
- Clear, high-contrast focus rings
- Animated glow on focused element
- Audio confirmation

**Consistent Patterns**:
- Same actions work everywhere
- Predictable navigation
- Clear feedback

---

## Error States & Loading Indicators

### Loading States

**Skeleton Screens**:
```
Dashboard Loading:
┌─────────────────────────────────┐
│ ▓▓▓▓▓▓▓  ▓▓▓▓▓▓▓  ▓▓▓▓▓▓▓      │ ← KPI placeholders
│                                  │
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓    │ ← Chart placeholder
│                                  │
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓    │ ← Table placeholder
└─────────────────────────────────┘
```

**Progress Indicators**:

*Determinate* (Known duration):
```swift
ProgressView(value: progress, total: 1.0)
    .progressViewStyle(.linear)
    .tint(.blue)
```

*Indeterminate* (Unknown duration):
```swift
ProgressView()
    .progressViewStyle(.circular)
    .controlSize(.large)
```

**Spatial Loading** (3D environments):
- Fade in: Entities appear gradually
- Progress sphere: Fills as data loads
- Status text: "Loading cash flow data..."

### Empty States

**No Data**:
```
┌─────────────────────────────────┐
│                                  │
│         📊                       │
│                                  │
│    No Transactions Yet           │
│                                  │
│  Transactions will appear here   │
│  once data is synced.            │
│                                  │
│    [Sync Data Now]               │
│                                  │
└─────────────────────────────────┘
```

**No Results** (After filtering):
```
┌─────────────────────────────────┐
│         🔍                       │
│                                  │
│    No Results Found              │
│                                  │
│  Try adjusting your filters      │
│                                  │
│    [Clear Filters]               │
└─────────────────────────────────┘
```

### Error States

**Network Error**:
```
┌─────────────────────────────────┐
│         ⚠️                       │
│                                  │
│    Connection Error              │
│                                  │
│  Unable to reach server.         │
│  Please check your network       │
│  connection and try again.       │
│                                  │
│    [Retry]  [Work Offline]       │
└─────────────────────────────────┘
```

**Permission Error**:
```
┌─────────────────────────────────┐
│         🔒                       │
│                                  │
│    Access Denied                 │
│                                  │
│  You don't have permission to    │
│  approve transactions.           │
│                                  │
│    [Request Access]  [Cancel]    │
└─────────────────────────────────┘
```

**Data Error**:
```
┌─────────────────────────────────┐
│         ❌                       │
│                                  │
│    Reconciliation Failed         │
│                                  │
│  Account 1001 has a $12K         │
│  variance. Please review.        │
│                                  │
│    [View Details]  [Dismiss]     │
└─────────────────────────────────┘
```

**Validation Error**:
```swift
TextField("Amount", text: $amount)
    .textFieldStyle(.roundedBorder)
    .overlay(
        RoundedRectangle(cornerRadius: 8)
            .stroke(isValid ? Color.clear : Color.red, lineWidth: 2)
    )

if !isValid {
    Text("Please enter a valid amount")
        .font(.caption)
        .foregroundColor(.red)
}
```

### Success States

**Action Confirmation**:
```
┌─────────────────────────────────┐
│         ✅                       │
│                                  │
│    Transaction Approved          │
│                                  │
│  TX-2024-11-17-001 has been      │
│  approved successfully.          │
│                                  │
│         [Dismiss]                │
└─────────────────────────────────┘
```

**Auto-dismiss Toast**:
```swift
struct SuccessToast: View {
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            Text("Saved successfully")
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
```

---

## Animation & Transition Specifications

### Timing Curves

**Standard Curves**:
```swift
// Ease In Out (Default)
.animation(.easeInOut(duration: 0.3), value: state)

// Spring (Interactive elements)
.animation(.spring(response: 0.3, dampingFraction: 0.7), value: state)

// Linear (Progress indicators)
.animation(.linear(duration: 2.0), value: progress)
```

**Financial-Specific Timings**:
- **Value Changes**: 0.5s ease-in-out
- **Status Updates**: 0.3s spring
- **Chart Updates**: 1.0s ease-in-out
- **Navigation**: 0.4s ease-in-out

### Transition Types

**Window Transitions**:

*Appear*:
```swift
.transition(.scale.combined(with: .opacity))
```

*Dismiss*:
```swift
.transition(.move(edge: .bottom).combined(with: .opacity))
```

*Modal*:
```swift
.transition(.asymmetric(
    insertion: .move(edge: .bottom),
    removal: .opacity
))
```

**3D Transitions**:

*Enter Immersive Space*:
1. Dashboard fades to 50% opacity (0.5s)
2. Environment fades in (1.0s)
3. 3D elements materialize (staggered, 0.2s each)

*Exit Immersive Space*:
1. 3D elements dematerialize (0.3s)
2. Environment fades out (0.5s)
3. Dashboard fades to 100% (0.3s)

### Interactive Animations

**Button Press**:
```swift
Button("Approve") {
    approveTransaction()
}
.buttonStyle(.bordered)
.scaleEffect(isPressed ? 0.95 : 1.0)
.animation(.spring(response: 0.2), value: isPressed)
```

**Card Selection**:
```swift
.scaleEffect(isSelected ? 1.05 : 1.0)
.shadow(radius: isSelected ? 20 : 10)
.animation(.spring(), value: isSelected)
```

**3D Entity Interaction**:
```swift
// Hover effect
entity.scale = isHovered ? [1.1, 1.1, 1.1] : [1.0, 1.0, 1.0]

// Rotation on drag
entity.transform.rotation = simd_quatf(angle: dragAngle, axis: [0, 1, 0])
```

### Data-Driven Animations

**Value Counting**:
```swift
struct CountingText: View {
    let value: Decimal
    @State private var displayValue: Decimal = 0

    var body: some View {
        Text(displayValue.formatted(.currency(code: "USD")))
            .onAppear {
                animateValue()
            }
    }

    func animateValue() {
        withAnimation(.easeOut(duration: 1.0)) {
            displayValue = value
        }
    }
}
```

**Chart Reveal**:
```swift
Chart(data) { item in
    LineMark(
        x: .value("Date", item.date),
        y: .value("Amount", item.amount)
    )
}
.chartXScale(domain: dateRange)
.mask(
    Rectangle()
        .offset(x: maskOffset)
)
.onAppear {
    withAnimation(.linear(duration: 1.5)) {
        maskOffset = 0
    }
}
```

**3D Flow Animations**:

*Cash Flow River*:
- Particle emission rate: 100 particles/second
- Particle lifetime: 5 seconds
- Flow speed: 0.5 m/s
- Continuous loop

*Risk Heat Map*:
- Color interpolation: 0.3s
- Height changes: 0.5s ease-in-out
- Pulse on new risk: 1.0s

*KPI Updates*:
- Number increment: 0.5s
- Color change: 0.3s
- Scale pulse: 0.2s (1.0 → 1.1 → 1.0)

### Micro-interactions

**Haptic Feedback** (Future support):
- Light tap: Button press
- Medium tap: Selection
- Heavy tap: Action completion
- Success: Double light tap
- Error: Triple tap pattern

**Audio Cues**:
- Button press: Subtle click (50ms)
- Selection: Soft chime (100ms)
- Approval: Success chime (200ms)
- Error: Alert tone (300ms)

**Visual Feedback**:
- Ripple effect on tap
- Glow on hover
- Bounce on success
- Shake on error

---

## Responsive Design

### Adapt to User Distance

**Near** (< 0.5m):
- Larger hit targets
- More detail visible
- Smaller text acceptable

**Medium** (0.5m - 2m):
- Standard sizing
- Optimal reading distance
- Primary interaction zone

**Far** (> 2m):
- Larger text and elements
- Reduced detail
- Overview-focused

### Adapt to Available Space

**Compact**:
- Single column layout
- Simplified navigation
- Essential info only

**Regular**:
- Multi-column layout
- Full navigation
- Detailed views

**Spacious**:
- Maximum columns
- Side panels
- Auxiliary information

---

## Design Tokens

```swift
// Spacing
enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// Corner Radius
enum CornerRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
}

// Shadows
enum ShadowStyle {
    static let light = Color.black.opacity(0.1)
    static let medium = Color.black.opacity(0.2)
    static let heavy = Color.black.opacity(0.3)
}

// Durations
enum Duration {
    static let fast: TimeInterval = 0.2
    static let normal: TimeInterval = 0.3
    static let slow: TimeInterval = 0.5
}
```

---

## Design Checklist

- [ ] All interactive elements have 60pt minimum hit target
- [ ] Text supports Dynamic Type
- [ ] Color never sole indicator of information
- [ ] All gestures have button alternatives
- [ ] VoiceOver labels on all elements
- [ ] Loading states for all async operations
- [ ] Error states with clear recovery paths
- [ ] Success feedback for all actions
- [ ] Animations respect Reduce Motion setting
- [ ] High contrast mode supported
- [ ] Spatial audio cues implemented
- [ ] Content positioned 10-15° below eye level
- [ ] Glass materials used appropriately
- [ ] 3D assets optimized (LOD implemented)
- [ ] Transitions smooth and purposeful

---

## Conclusion

This design specification establishes a comprehensive visual and interaction language for the Financial Operations Platform on visionOS. The design leverages spatial computing to transform complex financial data into intuitive, navigable 3D experiences while maintaining accessibility and usability standards. By following these specifications, the platform will deliver an enterprise-grade financial tool that feels natural and powerful in spatial computing.
