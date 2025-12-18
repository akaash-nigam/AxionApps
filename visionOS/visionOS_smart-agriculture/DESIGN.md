# Smart Agriculture System - Design Specifications

## Document Information
**Version:** 1.0
**Last Updated:** 2025-11-17
**Platform:** visionOS 2.0+ for Apple Vision Pro
**Design System:** Apple visionOS Human Interface Guidelines

---

## 1. Spatial Design Philosophy

### 1.1 Core Design Principles

**"Farming Intelligence in Space"**

Our design transforms abstract agricultural data into intuitive spatial understanding, enabling farmers to literally see their entire operation and make informed decisions at a glance.

#### Key Principles

1. **Spatial Clarity**: Place information where it provides maximum insight
2. **Progressive Disclosure**: Start simple, reveal complexity when needed
3. **Data Transparency**: Show confidence levels and data sources
4. **Actionable Insights**: Every visualization leads to clear next steps
5. **Respectful Interruption**: Critical alerts only, everything else is available on-demand

### 1.2 Design Values

```
┌─────────────────────────────────────────────────────┐
│  CLARITY                                             │
│  Every farmer, regardless of technical expertise,   │
│  understands their farm's health instantly          │
├─────────────────────────────────────────────────────┤
│  EFFICIENCY                                          │
│  Common tasks complete in seconds, not minutes      │
├─────────────────────────────────────────────────────┤
│  CONFIDENCE                                          │
│  Show data provenance and AI prediction confidence  │
├─────────────────────────────────────────────────────┤
│  DELIGHT                                             │
│  Subtle animations and satisfying interactions      │
└─────────────────────────────────────────────────────┘
```

---

## 2. Visual Design System

### 2.1 Color Palette

#### Primary Colors

```swift
// Agricultural health spectrum
enum HealthColor {
    // Excellent health: 80-100%
    static let vibrantGreen = Color(red: 0.2, green: 0.8, blue: 0.3)  // #33CC4D

    // Good health: 60-80%
    static let healthyGreen = Color(red: 0.5, green: 0.9, blue: 0.4)  // #80E666

    // Moderate: 40-60%
    static let cautionYellow = Color(red: 1.0, green: 0.8, blue: 0.0) // #FFCC00

    // Poor: 20-40%
    static let warningOrange = Color(red: 1.0, green: 0.53, blue: 0.0) // #FF8800

    // Critical: 0-20%
    static let alertRed = Color(red: 0.87, green: 0.2, blue: 0.2)     // #DD3333
}
```

**Color Application:**
- Health overlays on 3D fields
- Status indicators in dashboards
- Alert badges and notifications

#### Secondary Colors

```swift
enum BrandColor {
    // Primary brand
    static let farmBlue = Color(red: 0.2, green: 0.4, blue: 0.8)      // #3366CC
    static let earthBrown = Color(red: 0.45, green: 0.35, blue: 0.25) // #735A40

    // Accent colors
    static let skyBlue = Color(red: 0.53, green: 0.81, blue: 0.98)    // #87CEEB
    static let sunYellow = Color(red: 1.0, green: 0.84, blue: 0.0)    // #FFD700

    // Neutral tones
    static let soil = Color(red: 0.35, green: 0.25, blue: 0.15)       // #594025
    static let wheat = Color(red: 0.96, green: 0.87, blue: 0.70)      // #F5DEB3
}
```

#### Glass Materials

```swift
// visionOS glass backgrounds
enum GlassMaterial {
    static let dashboard = Material.regular                    // Standard window background
    static let controlPanel = Material.thick                   // Emphasize controls
    static let tooltip = Material.ultraThin                    // Subtle overlays
    static let modal = Material.thickChrome                    // Important dialogs
}
```

### 2.2 Typography

#### Font Hierarchy

```swift
enum TypographyStyle {
    // Display - Large titles in immersive views
    static let display = Font.system(size: 48, weight: .bold, design: .default)

    // Title 1 - Main headers
    static let title1 = Font.system(size: 34, weight: .bold, design: .default)

    // Title 2 - Section headers
    static let title2 = Font.system(size: 28, weight: .semibold, design: .default)

    // Title 3 - Subsection headers
    static let title3 = Font.system(size: 22, weight: .semibold, design: .default)

    // Headline - List items, cards
    static let headline = Font.system(size: 17, weight: .semibold, design: .default)

    // Body - Primary content
    static let body = Font.system(size: 17, weight: .regular, design: .default)

    // Callout - Secondary content
    static let callout = Font.system(size: 16, weight: .regular, design: .default)

    // Subheadline - Metadata
    static let subheadline = Font.system(size: 15, weight: .regular, design: .default)

    // Footnote - Timestamps, sources
    static let footnote = Font.system(size: 13, weight: .regular, design: .default)

    // Caption - Labels, hints
    static let caption = Font.system(size: 12, weight: .regular, design: .default)

    // Monospaced - Data values, coordinates
    static let data = Font.system(size: 17, weight: .regular, design: .monospaced)
}
```

#### Typography Guidelines

- **Minimum size in space**: 17pt body text
- **Maximum line length**: 60 characters
- **Line height**: 1.4× font size
- **Letter spacing**: Default (no adjustment needed)

### 2.3 Iconography

#### Icon System

```swift
enum AgriIcon {
    // Farm elements
    case farm              // "building.2.crop.circle"
    case field             // "square.grid.3x3"
    case crop              // "leaf"
    case equipment         // "cart"

    // Health indicators
    case healthy           // "checkmark.circle.fill"
    case warning           // "exclamationmark.triangle.fill"
    case critical          // "xmark.octagon.fill"

    // Data sources
    case satellite         // "globe.americas"
    case sensor            // "sensor"
    case weather           // "cloud.sun"
    case ai                // "brain"

    // Actions
    case analyze           // "chart.xyaxis.line"
    case plan              // "square.and.pencil"
    case execute           // "play.circle"
    case share             // "square.and.arrow.up"

    var systemName: String {
        switch self {
        case .farm: return "building.2.crop.circle"
        case .field: return "square.grid.3x3"
        case .crop: return "leaf"
        // ... etc
        }
    }

    var color: Color {
        switch self {
        case .healthy: return HealthColor.vibrantGreen
        case .warning: return HealthColor.cautionYellow
        case .critical: return HealthColor.alertRed
        default: return .primary
        }
    }
}
```

**Icon Sizes:**
- **Small**: 16×16 pt (inline with text)
- **Medium**: 24×24 pt (list items)
- **Large**: 32×32 pt (feature cards)
- **Hero**: 48×48 pt (main actions)

**3D Icon Treatment:**
- Subtle depth (2-3mm extrusion)
- Matte material finish
- Soft lighting from above

---

## 3. Spatial Layout Design

### 3.1 Window Layouts

#### Dashboard Window (Primary)

```
┌─────────────────────────────────────────────────────────────────┐
│  Smart Agriculture                    🔔 ⚙️  👤                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────────┐  ┌──────────────────────────────────┐ │
│  │  Farm Overview       │  │  Today's Priorities              │ │
│  │                      │  │                                  │ │
│  │  🏠 Riverside Farm  │  │  ⚠️ Field 7: Low Nitrogen       │ │
│  │  📊 5,200 acres     │  │  💧 Irrigation Schedule Today   │ │
│  │  🌾 8 fields        │  │  🐛 Pest Alert: North Fields   │ │
│  │  ✅ 82% avg health  │  │                                  │ │
│  │                      │  │  [View All Tasks →]             │ │
│  └──────────────────────┘  └──────────────────────────────────┘ │
│                                                                  │
│  Field Health Overview                                          │
│  ┌──────────┬──────────┬──────────┬──────────┬──────────┐      │
│  │ Field 1  │ Field 2  │ Field 3  │ Field 4  │ Field 5  │      │
│  │          │          │          │          │          │      │
│  │  Corn    │  Soybeans│  Wheat   │  Corn    │  Corn    │      │
│  │  92%     │  85%     │  78%     │  88%     │  94%     │      │
│  │  🟢      │  🟢      │  🟡      │  🟢      │  🟢      │      │
│  │  320 ac  │  280 ac  │  450 ac  │  310 ac  │  290 ac  │      │
│  │          │          │          │          │          │      │
│  └──────────┴──────────┴──────────┴──────────┴──────────┘      │
│  ┌──────────┬──────────┬──────────┐                            │
│  │ Field 6  │ Field 7  │ Field 8  │                            │
│  │  Wheat   │  Soybeans│  Corn    │                            │
│  │  81%     │  62% ⚠️ │  89%     │                            │
│  │  🟢      │  🟡      │  🟢      │                            │
│  │  380 ac  │  420 ac  │  350 ac  │                            │
│  └──────────┴──────────┴──────────┘                            │
│                                                                  │
│  Recent Updates                                                 │
│  🛰️ Satellite imagery updated 2 hours ago                      │
│  🌡️ Weather: 72°F, Partly cloudy, 15% rain chance             │
│  📊 Yield prediction updated for all fields                    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**Layout Specifications:**
- **Grid**: 12-column responsive grid
- **Padding**: 24pt outer, 16pt inner
- **Card spacing**: 16pt gaps
- **Corner radius**: 12pt for cards
- **Glass material**: .regular

#### Field Detail View

```
┌─────────────────────────────────────────────────────────────────┐
│  ← Back to Dashboard          Field 7 - Soybeans          ⋯     │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                    Health Score                            │ │
│  │                                                            │ │
│  │                         62%                                │ │
│  │                     ━━━━━━━━━━                            │ │
│  │                     ⚠️ Below Target                        │ │
│  │                                                            │ │
│  │   NDVI: 0.68     Moisture: 32%     Temp: 74°F            │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  Issues Detected                    Recommendations             │
│  ┌────────────────────────┐  ┌────────────────────────────────┐ │
│  │ 🔶 Nitrogen Deficiency │  │ Apply 30 lbs/acre nitrogen     │ │
│  │   12.3 acres affected  │  │ Est. cost: $1,764              │ │
│  │   Confidence: 94%      │  │ Expected yield gain: +18%      │ │
│  │                        │  │ ROI: 215%                      │ │
│  │ 💧 Low Soil Moisture  │  │                                │ │
│  │   8.7 acres affected   │  │ [Schedule Application]         │ │
│  │   Confidence: 89%      │  │                                │ │
│  └────────────────────────┘  └────────────────────────────────┘ │
│                                                                  │
│  Health Trend (30 days)                                         │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ 100% ┤                                                     │ │
│  │  80% ┤  ●━━●━━●━━●━━●━━●━━●━━●━━●                        │ │
│  │  60% ┤                              ●━━●━━●               │ │
│  │  40% ┤                                                     │ │
│  │  20% ┤                                                     │ │
│  │   0% └────────────────────────────────────────────        │ │
│  │      Oct 18        Nov 1          Nov 15                  │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  [View 3D Model]  [Satellite History]  [Generate Report]       │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 Volume Designs

#### 3D Field Volume

**Visual Design:**

```
         ┌─────────────────────────────┐
        ╱                             ╱│
       ╱      FIELD VISUALIZATION    ╱ │
      ╱                             ╱  │
     ╱                             ╱   │
    ╱─────────────────────────────╱    │
    │                            │     │
    │   🟢🟢🟢🟢🟢🟢🟢🟢          │     │
    │   🟢🟢🟢🟡🟡🟢🟢🟢          │     │
    │   🟢🟡🟡🟡🟡🟡🟢🟢          │     │  Height =
    │   🟢🟡🟡🔴🔴🟡🟢🟢          │     │  Elevation
    │   🟢🟡🟡🟡🟡🟡🟢🟢          │     │
    │   🟢🟢🟢🟡🟡🟢🟢🟢          │     │
    │   🟢🟢🟢🟢🟢🟢🟢🟢          │     │
    │                            │     │
    │   Legend:                  │     │
    │   🟢 Healthy (80%+)        │     │
    │   🟡 Moderate (40-80%)     │     │
    │   🔴 Poor (<40%)           │     ╱
    │                            │    ╱
    │                            │   ╱
    └────────────────────────────┴──╱
                2m × 2m × 1.5m
```

**Interaction Layers:**

1. **Base Layer**: Terrain mesh with elevation
2. **Health Overlay**: Color-coded health heatmap
3. **Zone Boundaries**: Dotted lines for management zones
4. **Annotations**: Floating labels for problem areas
5. **Equipment**: Real-time equipment positions

**Level of Detail (LOD):**

| Distance | Detail Level | Visual Representation |
|----------|--------------|----------------------|
| < 0.5m | **Ultra Detail** | Individual plant models, leaf details |
| 0.5-1.5m | **High Detail** | Crop clusters, texture variation |
| 1.5-3m | **Medium Detail** | Zone colors, terrain mesh |
| > 3m | **Low Detail** | Simplified mesh, average color |

#### Crop Model Volume

**Design:**

```
       🌿                      Individual Plant Model
      🌿🌿                     - Accurate to species
     🌿🌿🌿                    - Growth stage shown
    🌿🌿🌿🌿                   - Health indicators
   🌿🌿 🌿🌿🌿
  🌿🌿  🌿  🌿🌿               Tap leaves to see:
 🌿🌿   🌿   🌿🌿              • Disease spots
  🌿   🌿    🌿               • Nutrient deficiency
  🌿  🌿🌿   🌿               • Pest damage
   🌿  🌿   🌿
    🌿🌿🌿🌿                   Rotate to inspect
      ││││                    all angles
     ═╧╧╧╧═
  ──────────────
     Soil Level
```

**Annotations:**
- Floating labels for plant parts
- Color-coded health indicators on leaves
- Timeline scrubber for growth animation

### 3.3 Immersive Space Layouts

#### Farm Walkthrough (Full Immersion)

**Environment Design:**

```
                    ☁️        ☁️      ☁️
              ☀️                           Sky Dome
         ════════════════════════════════════════
                   User Position
                       👁️
                      ╱│╲
                     ╱ │ ╲

    🌾🌾🌾🌾         🌽🌽🌽🌽         🌾🌾🌾🌾
    Field 1          Field 2          Field 3
    🟢 92%          🟢 88%          🟡 78%

                    🚜 (Equipment)

══════════════════════════════════════════════════
                    Ground Plane
```

**UI Elements:**

- **Heads-Up Display** (top): Farm name, current view mode
- **Floating Panels** (sides): Field information cards
- **Minimap** (bottom right): Overview with current position
- **Toolbar** (bottom center): View controls, filters

**Navigation:**
- **Gaze + Pinch**: Teleport to field
- **Hand Gesture**: Walk/fly through farm
- **Minimap Tap**: Jump to location
- **Voice**: "Show Field 7", "Go to equipment"

#### Planning Mode (Mixed Reality)

**Spatial Anchoring:**

```
     Physical Table Surface
    ┌────────────────────────┐
    │                        │
    │   [Farm hologram       │  ← Anchored to table
    │    appears here]       │
    │                        │
    │    🌾  🌽  🌾         │
    │    🌾  🌽  🌾         │
    │                        │
    │  Virtual Tools:        │
    │  ✏️ Draw  📏 Measure   │
    └────────────────────────┘

      User's hands interact
      with virtual farm
```

**Drawing Tools:**
- **Pen**: Draw management zones
- **Eraser**: Remove zones
- **Ruler**: Measure distances
- **Annotate**: Add notes

---

## 4. Component Design Library

### 4.1 Cards

#### Field Card

```swift
struct FieldCard: View {
    let field: Field

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "leaf")
                    .foregroundStyle(.green)

                Text(field.name)
                    .font(.headline)

                Spacer()

                HealthBadge(score: field.healthScore)
            }

            // Stats
            HStack(spacing: 20) {
                StatItem(label: "Crop", value: field.cropType.displayName)
                StatItem(label: "Acres", value: "\\(field.acreage, specifier: \"%.0f\")")
                StatItem(label: "Health", value: "\\(field.healthScore)%")
            }

            // Progress bar
            HealthProgressBar(score: field.healthScore)

            // Quick actions
            HStack {
                Button("Analyze", systemImage: "chart.xyaxis.line") { }
                Button("View 3D", systemImage: "view.3d") { }
            }
            .buttonStyle(.bordered)
        }
        .padding(16)
        .background(.regularMaterial)
        .cornerRadius(12)
        .hoverEffect()
    }
}
```

**Visual:**
```
┌────────────────────────────────────┐
│  🌾 Field 7            62% ⚠️     │
├────────────────────────────────────┤
│                                    │
│  Crop: Soybeans                   │
│  Acres: 420                        │
│  Health: 62%                       │
│                                    │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━      │
│  ⚠️ Below target                  │
│                                    │
│  [Analyze] [View 3D]              │
│                                    │
└────────────────────────────────────┘
```

#### Recommendation Card

```swift
struct RecommendationCard: View {
    let recommendation: Recommendation

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: recommendation.icon)
                .font(.system(size: 32))
                .foregroundStyle(recommendation.priority.color)
                .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 4) {
                // Title
                Text(recommendation.title)
                    .font(.headline)

                // Description
                Text(recommendation.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // ROI
                HStack {
                    Text("Cost: $\\(recommendation.cost, specifier: \"%.0f\")")
                    Text("•")
                    Text("ROI: \\(recommendation.roi)%")
                        .foregroundStyle(.green)
                }
                .font(.caption)
            }

            Spacer()

            // Action
            Button("Apply") {
                applyRecommendation()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(.thickMaterial)
        .cornerRadius(12)
    }
}
```

### 4.2 Charts & Visualizations

#### Health Trend Chart

```swift
struct HealthTrendChart: View {
    let data: [HealthSnapshot]

    var body: some View {
        Chart {
            ForEach(data) { snapshot in
                LineMark(
                    x: .value("Date", snapshot.timestamp),
                    y: .value("Health", snapshot.metrics.overallScore)
                )
                .foregroundStyle(.green)
                .lineStyle(StrokeStyle(lineWidth: 3))

                AreaMark(
                    x: .value("Date", snapshot.timestamp),
                    y: .value("Health", snapshot.metrics.overallScore)
                )
                .foregroundStyle(
                    .linearGradient(
                        colors: [.green.opacity(0.3), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }

            // Target line
            RuleMark(y: .value("Target", 80.0))
                .foregroundStyle(.orange)
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
        }
        .chartYScale(domain: 0...100)
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 7))
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .frame(height: 200)
    }
}
```

#### Yield Prediction Gauge

```swift
struct YieldGauge: View {
    let predicted: Double
    let target: Double

    var body: some View {
        Gauge(value: predicted, in: 0...target) {
            Text("Yield")
        } currentValueLabel: {
            Text("\\(predicted, specifier: \"%.0f\") bu/ac")
        } minimumValueLabel: {
            Text("0")
        } maximumValueLabel: {
            Text("\\(target, specifier: \"%.0f\")")
        }
        .gaugeStyle(.accessoryCircular)
        .tint(gaugeColor)
    }

    var gaugeColor: Color {
        let percentage = predicted / target
        switch percentage {
        case 0.9...1.2: return .green
        case 0.7..<0.9: return .yellow
        default: return .red
        }
    }
}
```

### 4.3 Interactive Elements

#### Health Indicator

```swift
struct HealthIndicator: View {
    let health: Double
    let size: CGFloat = 60

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 8)

            // Health arc
            Circle()
                .trim(from: 0, to: health / 100)
                .stroke(
                    healthColor,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: health)

            // Percentage
            VStack(spacing: 2) {
                Text("\\(Int(health))%")
                    .font(.system(size: 18, weight: .bold, design: .rounded))

                Text("Health")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
    }

    var healthColor: Color {
        switch health {
        case 80...100: return HealthColor.vibrantGreen
        case 60..<80: return HealthColor.healthyGreen
        case 40..<60: return HealthColor.cautionYellow
        case 20..<40: return HealthColor.warningOrange
        default: return HealthColor.alertRed
        }
    }
}
```

#### Spatial Button

```swift
struct SpatialButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20))

                Text(title)
                    .font(.headline)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.regularMaterial)
            .cornerRadius(12)
        }
        .buttonStyle(.borderless)
        .hoverEffect(.highlight)
        .scaleEffect(isPressed ? 0.95 : 1.0)
    }
}
```

---

## 5. User Flows & Navigation

### 5.1 Primary User Flows

#### Flow 1: Check Farm Health (Daily Workflow)

```
┌─────────────┐
│   Launch    │
│     App     │
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│   Dashboard     │  ← Farm overview
│   Loads         │    All fields visible
└──────┬──────────┘
       │
       ▼
  ┌────────────┐
  │ Scan for   │  ← Visual scan
  │ Alerts     │    Red/yellow fields
  └──────┬─────┘
         │
         ▼
  ┌─────────────┐
  │ Select      │  ← Tap problem field
  │ Field 7     │
  └──────┬──────┘
         │
         ▼
  ┌─────────────┐
  │ View        │  ← See detailed analysis
  │ Details     │    Health metrics
  └──────┬──────┘
         │
         ▼
  ┌─────────────┐
  │ Review      │  ← AI recommendations
  │ Recommend.  │    with ROI
  └──────┬──────┘
         │
         ▼
  ┌─────────────┐
  │ Schedule    │  ← One-tap action
  │ Treatment   │
  └─────────────┘

Total time: 2-3 minutes
```

#### Flow 2: Plan Management Zone

```
┌─────────────┐
│ Select      │
│ Field       │
└──────┬──────┘
       │
       ▼
┌──────────────┐
│ Open         │  ← Tap "View 3D"
│ 3D Volume    │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Analyze      │  ← Rotate, zoom
│ Health       │    Identify zones
│ Pattern      │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Enter        │  ← Tap "Planning Mode"
│ Planning     │    Immersive space
│ Mode         │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Draw Zone    │  ← Hand gestures
│ Boundaries   │    on 3D field
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Set Zone     │  ← Select treatment type
│ Type         │    (fertilizer, irrigation)
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Review       │  ← See cost, expected outcome
│ & Confirm    │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Export to    │  ← Send to equipment
│ Equipment    │
└──────────────┘

Total time: 5-8 minutes
```

### 5.2 Navigation Patterns

#### Window-Based Navigation

```swift
@Observable
final class NavigationManager {
    var path = NavigationPath()

    enum Destination: Hashable {
        case farmList
        case farmDetail(Farm)
        case fieldDetail(Field)
        case analytics
        case settings
    }

    func navigate(to destination: Destination) {
        path.append(destination)
    }

    func pop() {
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }
}
```

**Navigation UI:**

```
Dashboard (Root)
├── Farm List
│   └── Farm Detail
│       ├── Field Detail
│       │   ├── Health Analysis
│       │   ├── Satellite History
│       │   └── Recommendations
│       ├── Analytics
│       └── Settings
```

#### Spatial Navigation

```swift
enum SpatialView {
    case windows        // Multiple 2D windows
    case volumeSingle   // One 3D volume
    case volumeMultiple // Multiple volumes
    case immersive      // Full immersion

    var immersionStyle: ImmersionStyle {
        switch self {
        case .windows, .volumeSingle, .volumeMultiple:
            return .mixed
        case .immersive:
            return .full
        }
    }
}
```

**Spatial Transitions:**

```
Windows ⟷ Volume ⟷ Immersive
   ↓        ↓         ↓
2D Info  3D Model  Full Farm
```

---

## 6. Animation & Transitions

### 6.1 Animation Principles

1. **Purposeful**: Every animation communicates state or guides attention
2. **Swift**: Complete in 200-400ms
3. **Natural**: Follow real-world physics
4. **Interruptible**: User actions take priority

### 6.2 Micro-interactions

#### Button Press

```swift
.pressEvents { phase in
    switch phase {
    case .began:
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
            scale = 0.95
        }
    case .ended:
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            scale = 1.0
        }
    }
}
```

#### Card Hover

```swift
.hoverEffect { effect, isActive, _ in
    effect
        .scaleEffect(isActive ? 1.02 : 1.0)
        .shadow(color: .black.opacity(isActive ? 0.3 : 0.1), radius: isActive ? 20 : 10)
}
```

#### Health Score Update

```swift
// Animate number counting
withAnimation(.easeOut(duration: 1.0)) {
    displayedScore = newScore
}

// Pulse effect on change
.onChange(of: healthScore) { oldValue, newValue in
    withAnimation(.spring(response: 0.3, dampingFraction: 0.6).repeatCount(1)) {
        pulseScale = 1.1
    }
    withAnimation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.3)) {
        pulseScale = 1.0
    }
}
```

### 6.3 Spatial Transitions

#### Window to Volume

```swift
.onAppear {
    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
        // Fade in
        opacity = 1.0

        // Scale from center
        scale = 1.0

        // Slight rotation for depth
        rotation = 0
    }
}
```

#### Volume Rotation

```swift
DragGesture()
    .onChanged { value in
        let rotation = value.translation.width / 100
        withAnimation(.interactiveSpring()) {
            currentRotation = lastRotation + rotation
        }
    }
    .onEnded { value in
        lastRotation = currentRotation
    }
```

#### Immersive Space Entry

```swift
// Fade out windows
withAnimation(.easeOut(duration: 0.3)) {
    windowOpacity = 0
}

// Open immersive space
try await openImmersiveSpace(id: "farmWalkthrough")

// Fade in environment
withAnimation(.easeIn(duration: 0.5).delay(0.2)) {
    environmentOpacity = 1.0
}
```

---

## 7. Accessibility Design

### 7.1 VoiceOver Labels

```swift
// Field card accessibility
.accessibilityElement(children: .combine)
.accessibilityLabel("Field 7, Soybeans, 420 acres")
.accessibilityValue("Health: 62%, Below target")
.accessibilityHint("Tap to view detailed analysis and recommendations")

// Health indicator
.accessibilityLabel("Health score")
.accessibilityValue("\\(healthScore)%, \\(healthStatus)")
.accessibilityAddTraits(.updatesFrequently)

// Action buttons
.accessibilityLabel("Analyze field health")
.accessibilityHint("Runs AI analysis on current field data")
```

### 7.2 Dynamic Type Support

```swift
@ScaledMetric(relativeTo: .body) private var imageSize: CGFloat = 24
@ScaledMetric(relativeTo: .headline) private var cardPadding: CGFloat = 16

var body: some View {
    HStack(spacing: cardPadding) {
        Image(systemName: "leaf")
            .font(.system(size: imageSize))

        Text(field.name)
            .font(.headline)
            .dynamicTypeSize(.large ... .xxxLarge)
    }
}
```

### 7.3 Color Blindness Considerations

```swift
enum AccessibleHealthColor {
    static func color(for health: Double, colorBlind: Bool = false) -> Color {
        if colorBlind {
            // Use patterns or different color scheme
            switch health {
            case 80...100: return .blue      // Deuteranopia safe
            case 60..<80: return .cyan
            case 40..<60: return .orange
            default: return .purple
            }
        } else {
            // Standard green-yellow-red
            // ... (as before)
        }
    }
}

// Add pattern overlay for severe deficiency
if healthScore < 40 {
    // Add striped pattern or icon
}
```

### 7.4 Reduce Motion

```swift
@Environment(\\.accessibilityReduceMotion) private var reduceMotion

var animationStyle: Animation {
    reduceMotion ? .none : .spring(response: 0.3, dampingFraction: 0.7)
}

// Use crossfade instead of movement
if reduceMotion {
    CrossfadeTransition()
} else {
    SlideTransition()
}
```

---

## 8. Error States & Loading Indicators

### 8.1 Loading States

#### Skeleton Loading

```swift
struct FieldCardSkeleton: View {
    @State private var shimmer = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Circle()
                    .frame(width: 24, height: 24)

                RoundedRectangle(cornerRadius: 4)
                    .frame(width: 120, height: 20)

                Spacer()

                Circle()
                    .frame(width: 40, height: 40)
            }

            // Stats
            HStack {
                ForEach(0..<3) { _ in
                    RoundedRectangle(cornerRadius: 4)
                        .frame(width: 80, height: 16)
                }
            }

            // Progress bar
            RoundedRectangle(cornerRadius: 4)
                .frame(height: 8)
        }
        .foregroundStyle(.gray.opacity(0.3))
        .overlay(
            LinearGradient(
                colors: [.clear, .white.opacity(0.3), .clear],
                startPoint: shimmer ? .leading : .trailing,
                endPoint: shimmer ? .trailing : .leading
            )
        )
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                shimmer.toggle()
            }
        }
    }
}
```

#### Progress Indicator

```swift
struct AnalysisProgress: View {
    let progress: Double
    let stage: String

    var body: some View {
        VStack(spacing: 16) {
            // Progress ring
            ZStack {
                Circle()
                    .stroke(.gray.opacity(0.2), lineWidth: 8)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(.blue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: progress)

                Text("\\(Int(progress * 100))%")
                    .font(.title2.bold())
            }
            .frame(width: 100, height: 100)

            // Current stage
            VStack(spacing: 4) {
                Text("Analyzing...")
                    .font(.headline)

                Text(stage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThickMaterial)
        .cornerRadius(16)
    }
}
```

### 8.2 Error States

#### Error Message Card

```swift
struct ErrorView: View {
    let error: Error
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)

            VStack(spacing: 8) {
                Text("Unable to Load Data")
                    .font(.headline)

                Text(error.localizedDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button("Try Again") {
                retry()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
```

#### Empty State

```swift
struct EmptyFieldsView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "leaf")
                .font(.system(size: 64))
                .foregroundStyle(.green.opacity(0.5))

            VStack(spacing: 8) {
                Text("No Fields Yet")
                    .font(.title2.bold())

                Text("Add your first field to get started with crop monitoring")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button("Add Field", systemImage: "plus") {
                // Add field action
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
```

---

## 9. Design Checklist

### Pre-Implementation Review

- [ ] All layouts follow 60pt minimum hit targets
- [ ] Text contrast meets WCAG AA (4.5:1 minimum)
- [ ] All interactive elements have hover states
- [ ] Animations respect reduceMotion preference
- [ ] VoiceOver labels provided for all controls
- [ ] Dynamic Type supported (Large to XXXL)
- [ ] Color not sole indicator (patterns/icons added)
- [ ] Loading states designed for all async operations
- [ ] Error recovery paths clearly communicated
- [ ] Empty states provide clear next actions

### Spatial Design Review

- [ ] Content positioned 10-15° below eye level
- [ ] Comfortable viewing distance (1-3m for primary content)
- [ ] LOD system implemented for 3D content
- [ ] Polygon budget respected (< 1M triangles)
- [ ] Glass materials used appropriately
- [ ] Spatial audio enhances but doesn't distract
- [ ] Hand tracking gestures feel natural
- [ ] Immersive transitions smooth and clear

---

## Summary

This design specification provides a comprehensive visual and interaction design foundation for the Smart Agriculture visionOS application. The design embodies:

1. **Spatial Clarity**: Information placed meaningfully in 3D space
2. **Agricultural Context**: Visual language familiar to farmers
3. **Data Transparency**: Clear confidence levels and sources
4. **Actionable Design**: Every view leads to clear next steps
5. **Accessibility First**: Inclusive design for all users
6. **visionOS Native**: Leverages unique spatial capabilities

The design system ensures consistency, clarity, and delight across all user interactions while maintaining the performance and accessibility standards required for enterprise visionOS applications.
