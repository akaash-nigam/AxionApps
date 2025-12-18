# Smart City Command Platform - UI/UX Design Specification

## 1. Spatial Design Principles

### 1.1 Core Design Philosophy

**"Command Through Space, Not Screens"**

The Smart City Command Platform reimagines urban operations management by transforming data into spatial experiences where city officials can naturally interact with their city's digital twin.

#### Key Principles

1. **Spatial Hierarchy**: Critical information is closer, strategic data is ambient
2. **Progressive Disclosure**: Start simple, reveal complexity as needed
3. **Natural Interactions**: Leverage human spatial reasoning and gestures
4. **Information Density**: Balance detail with clarity in 3D space
5. **Calm Technology**: Urgent alerts are immediate, routine data is passive

### 1.2 Spatial Zones

```
User-Centric Spatial Layout:

┌─────────────────────────────────────────────────────────┐
│             Ambient Zone (3m - 5m)                       │
│  • Historical trends                                     │
│  • Background monitoring                                 │
│  • Environmental context                                 │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│           Strategic Zone (2m - 3m)                       │
│  • 3D City Overview                                      │
│  • Planning Tools                                        │
│  • Predictive Analytics                                  │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│          Operations Zone (1m - 2m)                       │
│  • Department Status                                     │
│  • Real-time Dashboards                                  │
│  • Analytics Panels                                      │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│       Emergency Zone (0.5m - 1m)                         │
│  • Critical Alerts (pulsing red)                         │
│  • Emergency Dispatch                                    │
│  • One-tap Actions                                       │
└─────────────────────────────────────────────────────────┘
```

### 1.3 Ergonomic Guidelines

- **Viewing Angle**: Primary content 10-15° below eye level
- **Comfort Distance**: Main UI at arm's length (0.5m - 1.5m)
- **Depth Range**: Use z-axis from -1m to 3m for layering
- **Lateral Spread**: Content spans 120° horizontal FOV max
- **Vertical Range**: ±30° from neutral eye level

## 2. Window Layouts and Configurations

### 2.1 Primary Operations Center Window

#### Layout Structure
```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃  City Operations Center         [🔔] [⚙️] [👤]     ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃                                                      ┃
┃  ┌──────────────┐  ┌──────────────┐  ┌───────────┐ ┃
┃  │  CRITICAL    │  │  ACTIVE      │  │ RESOURCE  │ ┃
┃  │  ALERTS      │  │  INCIDENTS   │  │ STATUS    │ ┃
┃  │              │  │              │  │           │ ┃
┃  │  🔴 3        │  │  🟡 12       │  │  ✓ 89%   │ ┃
┃  └──────────────┘  └──────────────┘  └───────────┘ ┃
┃                                                      ┃
┃  ┌────────────────────────────────────────────────┐ ┃
┃  │         DEPARTMENT STATUS GRID                 │ ┃
┃  │                                                │ ┃
┃  │  🚒 Fire      🚔 Police    🚑 Medical          │ ┃
┃  │  🔧 Utilities  🚦 Traffic   🏗️ Infrastructure  │ ┃
┃  └────────────────────────────────────────────────┘ ┃
┃                                                      ┃
┃  ┌────────────────────────────────────────────────┐ ┃
┃  │         REAL-TIME CITY METRICS                 │ ┃
┃  │  [Traffic Flow] [Air Quality] [Power Grid]    │ ┃
┃  │  ▁▂▃▅▆▇█     ▃▅▇▆▅▃▁      ▇▇▇▇▇▇▇           │ ┃
┃  └────────────────────────────────────────────────┘ ┃
┃                                                      ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

#### Design Specifications

**Dimensions**: 1400 x 900 points (default)
**Glass Material**: `.ultraThin` with subtle vibrancy
**Corner Radius**: 24pt for outer window
**Padding**: 24pt from edges, 16pt between components
**Typography**: SF Pro Rounded for headings, SF Pro for body

#### Components

**Critical Alerts Card**:
```swift
struct CriticalAlertsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                Text("CRITICAL ALERTS")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }

            Text("3")
                .font(.system(size: 48, weight: .bold))
                .foregroundStyle(.red)
                .contentTransition(.numericText())

            Button("View All") {
                // Action
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .frame(width: 200, height: 160)
        .glassBackgroundEffect(in: .rect(cornerRadius: 16))
    }
}
```

**Department Status Grid**:
```swift
struct DepartmentStatusGrid: View {
    let departments: [Department]

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.adaptive(minimum: 180))
        ], spacing: 16) {
            ForEach(departments) { department in
                DepartmentCard(department: department)
            }
        }
    }
}

struct DepartmentCard: View {
    let department: Department

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: department.icon)
                .font(.title)
                .foregroundStyle(department.color)

            VStack(alignment: .leading) {
                Text(department.name)
                    .font(.headline)
                Text("\(department.activeUnits) active")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            StatusIndicator(status: department.status)
        }
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
        .hoverEffect()
    }
}
```

### 2.2 Analytics Dashboard Window

#### Layout
```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃  City Analytics          [Period: 24h] ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃                                         ┃
┃  ┌─────────────────────────────────┐   ┃
┃  │   Response Time Trends          │   ┃
┃  │   ▁▂▃▅▇█▇▅▃▂▁                  │   ┃
┃  └─────────────────────────────────┘   ┃
┃                                         ┃
┃  ┌──────────┐  ┌──────────────────┐   ┃
┃  │  -32%    │  │  Traffic Flow    │   ┃
┃  │ Response │  │  Optimization    │   ┃
┃  │  Time    │  │                  │   ┃
┃  └──────────┘  └──────────────────┘   ┃
┃                                         ┃
┃  ┌─────────────────────────────────┐   ┃
┃  │   Predictive Insights           │   ┃
┃  │   • Peak congestion at 5:30 PM  │   ┃
┃  │   • Infrastructure alert: Zone 3│   ┃
┃  └─────────────────────────────────┘   ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

**Features**:
- Interactive charts with hover details
- Time period selectors (24h, 7d, 30d, custom)
- Export and report generation
- Comparison views (YoY, MoM)

### 2.3 Emergency Command Window

#### Crisis Mode Layout
```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃  🚨 EMERGENCY COMMAND CENTER                 ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃                                               ┃
┃  ┌─────────────────────────────────────────┐ ┃
┃  │  ACTIVE INCIDENT: Structure Fire        │ ┃
┃  │  📍 123 Main St, Downtown               │ ┃
┃  │  ⏱️  Reported: 2 min ago                 │ ┃
┃  │  👥 Estimated: 50 people affected       │ ┃
┃  └─────────────────────────────────────────┘ ┃
┃                                               ┃
┃  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┃
┃  │ 🚒       │  │ 🚑       │  │ 🚔       │  ┃
┃  │ EN ROUTE │  │ DISPATCH │  │ ON SCENE │  ┃
┃  │ ETA 3min │  │          │  │          │  ┃
┃  └──────────┘  └──────────┘  └──────────┘  ┃
┃                                               ┃
┃  ┌─────────────────────────────────────────┐ ┃
┃  │         🗺️ MAP VIEW                      │ ┃
┃  │  [Mini map with units and incident]     │ ┃
┃  └─────────────────────────────────────────┘ ┃
┃                                               ┃
┃  [🎙️ Open Comms] [📋 Protocols] [🚁 Drone]  ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

**Design Notes**:
- High contrast red accents for emergency state
- Large, tappable action buttons (min 60x60pt)
- Real-time updates with smooth animations
- Audio alerts for critical changes

### 2.4 Ornaments & Toolbars

#### Bottom Toolbar
```swift
struct CommandCenterToolbar: View {
    @Environment(\.openWindow) var openWindow
    @Environment(\.openImmersiveSpace) var openImmersive

    var body: some View {
        HStack(spacing: 24) {
            ToolbarButton(icon: "building.2", label: "3D City") {
                openWindow(id: "city-3d")
            }

            ToolbarButton(icon: "chart.bar", label: "Analytics") {
                openWindow(id: "analytics")
            }

            ToolbarButton(icon: "map", label: "Immersive") {
                Task {
                    await openImmersive(id: "city-immersive")
                }
            }

            ToolbarButton(icon: "gearshape", label: "Settings") {
                // Action
            }
        }
        .padding()
        .glassBackgroundEffect(in: .capsule)
    }
}
```

#### Notification Ornament
```swift
struct NotificationOrnament: View {
    @State private var notifications: [Notification] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(notifications.prefix(3)) { notification in
                NotificationRow(notification: notification)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding()
        .frame(width: 320)
        .glassBackgroundEffect(in: .rect(cornerRadius: 16))
    }
}
```

## 3. Volume Designs (3D Bounded Spaces)

### 3.1 3D City Model Volume

#### Visual Design

**Dimensions**: 1.0m (W) × 0.8m (H) × 0.6m (D)
**Scale**: 1cm = 100m real-world distance
**Viewing Distance**: 1.5m from user

#### Layer System
```
┌─────────────────────────────────┐
│  City Visualization Layers      │
├─────────────────────────────────┤
│  ✓ Buildings (Base)             │
│  ☐ Underground Infrastructure   │
│  ✓ Roads & Transportation       │
│  ✓ IoT Sensor Points            │
│  ☐ Air Quality Overlay          │
│  ☐ Traffic Flow Streams         │
│  ☐ Emergency Zones              │
│  ✓ District Boundaries          │
└─────────────────────────────────┘
```

#### Building Representation

**Material Design**:
```swift
func buildingMaterial(for type: BuildingType, status: OperationalStatus) -> Material {
    var material = PhysicallyBasedMaterial()

    // Base color by building type
    material.baseColor = PhysicallyBasedMaterial.BaseColor(
        tint: colorForBuildingType(type)
    )

    // Glass-like transparency
    material.opacity = PhysicallyBasedMaterial.Opacity(floatLiteral: 0.9)

    // Status indication via emissive
    if status != .operational {
        material.emissiveColor = PhysicallyBasedMaterial.EmissiveColor(
            color: statusColor(status)
        )
        material.emissiveIntensity = 2.0
    }

    material.roughness = 0.6
    material.metallic = 0.1

    return material
}
```

**Color Scheme**:
- Residential: Soft blue (#4A90E2)
- Commercial: Vibrant purple (#9B59B6)
- Industrial: Steel gray (#7F8C8D)
- Government: Gold (#F39C12)
- Emergency: Red (#E74C3C)
- Parks: Green (#27AE60)

#### Infrastructure Visualization

**Underground Utilities** (X-Ray Mode):
```swift
struct UndergroundInfrastructure: View {
    var body: some View {
        RealityView { content in
            // Water pipes
            let waterNetwork = createPipelineNetwork(
                type: .water,
                color: .blue,
                opacity: 0.7
            )

            // Power lines
            let powerNetwork = createPipelineNetwork(
                type: .power,
                color: .yellow,
                opacity: 0.7
            )

            content.add(waterNetwork)
            content.add(powerNetwork)
        }
    }
}
```

**Visual Style**:
- Flow animations in pipes/lines
- Pulsing at connection points
- Color-coded by utility type
- Semi-transparent to show depth

#### IoT Sensor Markers

```swift
struct SensorMarker: View {
    let sensor: IoTSensor

    var body: some View {
        RealityView { content in
            let sphere = createSensorSphere(sensor)

            // Pulsing animation for active sensors
            if sensor.status == .active {
                sphere.addPulsingAnimation()
            }

            content.add(sphere)
        }
    }
}

func createSensorSphere(_ sensor: IoTSensor) -> ModelEntity {
    let mesh = MeshResource.generateSphere(radius: 0.005) // 5mm
    var material = UnlitMaterial()

    // Color by sensor type
    material.color = .init(tint: colorForSensorType(sensor.type))

    // Add glow
    material.blending = .transparent(opacity: 0.8)

    let entity = ModelEntity(mesh: mesh, materials: [material])
    return entity
}
```

#### Traffic Flow Visualization

**Particle River System**:
```swift
struct TrafficFlowVisualization: View {
    var body: some View {
        RealityView { content in
            // Create particle system for traffic flow
            var particleEmitter = ParticleEmitterComponent()

            particleEmitter.mainEmitter.birthRate = 100
            particleEmitter.mainEmitter.lifeSpan = 2.0
            particleEmitter.mainEmitter.speed = 0.1

            // Color by congestion level
            particleEmitter.mainEmitter.color = .evolving(
                start: .green,   // Free flow
                end: .red        // Congested
            )

            particleEmitter.mainEmitter.size = 0.003 // 3mm particles

            let entity = Entity()
            entity.components.set(particleEmitter)
            content.add(entity)
        }
    }
}
```

**Flow Colors**:
- Green: Free flow (>45 mph)
- Yellow: Moderate (25-45 mph)
- Orange: Slow (10-25 mph)
- Red: Congested (<10 mph)

### 3.2 Infrastructure Systems Volume

**Specialized View**: Focus on single infrastructure type

#### Water System Volume
```
Visual Representation:
├── Treatment Plants (Large blue spheres)
├── Main Lines (Thick blue pipes)
├── Distribution Network (Thin blue lines)
├── Pumping Stations (Animated arrows)
├── Leak Detection (Red pulses)
└── Flow Direction (Particle animation)
```

#### Power Grid Volume
```
Visual Representation:
├── Power Plants (Large yellow cores)
├── Substations (Medium yellow nodes)
├── High-Voltage Lines (Thick yellow lines)
├── Distribution Grid (Thin yellow lines)
├── Load Centers (Pulsing intensity)
└── Outage Areas (Red highlights)
```

## 4. Full Space / Immersive Experiences

### 4.1 City Exploration Immersive Space

#### Environment Design

**Skybox**: Photorealistic city sky with time-of-day
**Ground Plane**: City map texture with streets and landmarks
**Scale**: 1:1000 - walk through scaled city
**Lighting**: Dynamic based on time of day

#### Navigation System

**Movement Modes**:

1. **Walk Mode**: Natural walking through city
2. **Fly Mode**: Birds-eye view, gesture-controlled
3. **Teleport Mode**: Jump to districts/landmarks

```swift
struct CityImmersiveView: View {
    @State private var navigationMode: NavigationMode = .walk
    @State private var currentPosition: SIMD3<Float> = .zero

    var body: some View {
        RealityView { content in
            let cityEntity = loadCityEnvironment()
            content.add(cityEntity)
        }
        .gesture(
            navigationGesture
        )
        .upperLimbVisibility(.visible)
    }

    var navigationGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                switch navigationMode {
                case .walk:
                    movePlayer(by: value.translation)
                case .fly:
                    flyPlayer(by: value.translation)
                case .teleport:
                    showTeleportTarget(at: value.location)
                }
            }
    }
}
```

#### Information Layers

**On-Demand Overlays**:
- Building information (tap to reveal)
- Live traffic data (colored road overlays)
- Incident markers (3D pins)
- Sensor data (floating panels)

#### Crisis Management Mode

**Full Immersion for Major Incidents**:

```
User surrounded by:
├── Central Incident Hologram (life-size)
├── Response Unit Positions (miniature avatars)
├── Resource Status Panels (floating at eye level)
├── Communication Feeds (spatial audio from units)
├── Timeline Scrubber (bottom arc)
└── Action Palettes (hand-accessible menus)
```

**Visual Design**:
- Dark environment (reduce distractions)
- High-contrast emergency indicators
- Spatial audio for unit communications
- Haptic feedback for critical updates

### 4.2 Urban Planning Immersive Space

#### Features

**Before/After Comparisons**:
```swift
struct PlanningComparisonView: View {
    @State private var showFuture = false

    var body: some View {
        RealityView { content in
            if showFuture {
                content.add(futureCityModel)
            } else {
                content.add(currentCityModel)
            }
        }
        .toolbar {
            Toggle("Show Future", isOn: $showFuture)
                .toggleStyle(.switch)
        }
        .animation(.default, value: showFuture)
    }
}
```

**Development Simulation**:
- Ghost buildings for proposed developments
- Impact visualization (traffic, population)
- Environmental assessment overlays
- Sunlight/shadow studies (time scrubber)

## 5. Interaction Patterns

### 5.1 Gaze and Pinch

#### Primary Interactions

**Building Selection**:
```
User Action: Gaze at building → Pinch
Result: Highlight building, show info panel
Feedback: Haptic tap, visual highlight, sound effect
```

**Emergency Dispatch**:
```
User Action: Gaze at incident → Double pinch
Result: Activate emergency response protocol
Feedback: Strong haptic, alarm sound, visual confirmation
```

**Resource Deployment**:
```
User Action: Gaze at location → Pinch and hold → Release
Result: Deploy selected resource to location
Feedback: Progressive haptic (hold), success tone
```

### 5.2 Hand Tracking Gestures

#### Custom City Gestures

**1. Point-and-Deploy**
```
Gesture: Index finger extended, other fingers curled
Action: Point at location → Tap thumb to index
Result: Deploy selected resource
Visual: Beam from finger to target point
```

**2. Palm-Scan Navigate**
```
Gesture: Open palm facing city model
Action: Move palm in direction
Result: Pan/navigate city view
Visual: City follows palm movement
```

**3. Two-Hand Measure**
```
Gesture: Index fingers pointing at two locations
Action: Hold both points
Result: Display distance measurement
Visual: Line between points with distance label
```

**4. Fist-Zoom**
```
Gesture: Closed fist → Open hand rapidly
Action: Expand gesture
Result: Zoom into city area
Visual: Smooth zoom animation
```

### 5.3 Voice Commands

#### Natural Language Processing

**Examples**:
```
"Show me all emergency incidents"
→ Filter and highlight active incidents

"What's the traffic status on Highway 101?"
→ Display traffic flow visualization

"Deploy ambulance to downtown"
→ Open deployment interface

"Zoom into Mission District"
→ Navigate to district

"Show infrastructure problems"
→ Filter critical infrastructure alerts
```

#### Voice Feedback
```swift
struct VoiceAssistant {
    func respond(to command: String) async {
        // Process command
        let action = parseCommand(command)

        // Visual confirmation
        showCommandConfirmation(action)

        // Spatial audio response
        speakResponse(action.confirmation, at: userLocation)

        // Execute action
        await executeAction(action)
    }
}
```

## 6. Visual Design System

### 6.1 Color Palette

#### Primary Colors

**Command Blue** - Primary actions and highlights
```swift
Color(red: 0.29, green: 0.56, blue: 0.89) // #4A90E2
```

**Success Green** - Operational status, confirmations
```swift
Color(red: 0.15, green: 0.68, blue: 0.38) // #27AE60
```

**Warning Amber** - Cautions, degraded status
```swift
Color(red: 0.95, green: 0.61, blue: 0.07) // #F39C12
```

**Critical Red** - Emergencies, failures
```swift
Color(red: 0.91, green: 0.30, blue: 0.24) // #E74C3C
```

#### Semantic Colors

**Infrastructure Types**:
- Water: `#3498DB` (Deep Blue)
- Power: `#F1C40F` (Electric Yellow)
- Gas: `#E67E22` (Orange)
- Telecommunications: `#9B59B6` (Purple)
- Roads: `#95A5A6` (Concrete Gray)

**Department Colors**:
- Fire: `#E74C3C` (Fire Red)
- Police: `#3498DB` (Police Blue)
- Medical: `#E74C3C` (Medical Red)
- Utilities: `#F39C12` (Construction Orange)

#### Glass Materials

```swift
// Ultra-thin glass for primary windows
.background(.ultraThinMaterial)

// Thin glass for secondary panels
.background(.thinMaterial)

// Regular glass for cards
.background(.regularMaterial)

// Thick glass for emphasis
.background(.thickMaterial)
```

### 6.2 Typography

#### Type Scale

```swift
// Display - Hero numbers and critical alerts
.font(.system(size: 64, weight: .bold))

// Title 1 - Window titles
.font(.system(size: 34, weight: .semibold))

// Title 2 - Section headers
.font(.system(size: 28, weight: .semibold))

// Title 3 - Card titles
.font(.system(size: 22, weight: .semibold))

// Headline - Emphasis
.font(.headline)

// Body - Default text
.font(.body)

// Caption - Labels and metadata
.font(.caption)

// Caption 2 - Timestamps
.font(.caption2)
```

#### Font Families

**SF Pro Rounded** - Friendly, modern (headings, labels)
**SF Pro** - Clean, readable (body text, data)
**SF Mono** - Technical data (coordinates, IDs, codes)

#### Spatial Text Rendering

```swift
Text("City Operations")
    .font(.system(size: 40, weight: .bold, design: .rounded))
    .foregroundStyle(
        .linearGradient(
            colors: [.blue, .cyan],
            startPoint: .leading,
            endPoint: .trailing
        )
    )
```

### 6.3 Materials and Lighting

#### Glass Materials in 3D Space

```swift
// Building materials with glass effect
var buildingMaterial: PhysicallyBasedMaterial {
    var material = PhysicallyBasedMaterial()

    // Glass-like properties
    material.opacity = .init(floatLiteral: 0.85)
    material.roughness = .init(floatLiteral: 0.3)
    material.metallic = .init(floatLiteral: 0.1)

    // Reflection
    material.clearcoat = .init(floatLiteral: 0.5)

    return material
}
```

#### Lighting Strategy

**3D City Model Lighting**:
```swift
// Directional light (sun)
let sunlight = DirectionalLight()
sunlight.light.intensity = 1000
sunlight.light.color = .white
sunlight.look(at: [0, 0, 0], from: [5, 10, 5], relativeTo: nil)

// Ambient light (sky)
let ambient = PointLight()
ambient.light.intensity = 500
ambient.light.color = UIColor(white: 0.9, alpha: 1.0)

// Building accent lights
let buildingLight = SpotLight()
buildingLight.light.intensity = 300
buildingLight.light.color = .init(white: 1.0, alpha: 1.0)
```

**Time-of-Day Lighting**:
- Morning: Warm golden (6 AM - 10 AM)
- Day: Bright white (10 AM - 4 PM)
- Evening: Warm orange (4 PM - 7 PM)
- Night: Cool blue with city lights (7 PM - 6 AM)

### 6.4 Iconography in 3D Space

#### Icon System

**SF Symbols** for 2D UI:
- Scale: 17pt (compact), 22pt (regular), 28pt (large)
- Weight: Match surrounding text
- Rendering: Hierarchical with accent color

**3D Icons** for spatial markers:
```swift
func create3DIcon(systemName: String, color: UIColor) -> ModelEntity {
    // Convert SF Symbol to 3D extruded mesh
    let symbolMesh = createExtrudedSymbol(systemName)

    var material = SimpleMaterial()
    material.color = .init(tint: color)

    return ModelEntity(mesh: symbolMesh, materials: [material])
}
```

#### Emergency Icons

**3D Markers** for incidents:
- Fire: 🔥 Flame icon with particle effects
- Medical: ⚕️ Medical cross pulsing
- Crime: 🚔 Police badge rotating
- Infrastructure: ⚠️ Warning triangle
- Traffic: 🚦 Signal light animation

## 7. User Flows and Navigation

### 7.1 App Launch Flow

```
1. App Launch
   ↓
2. City Selection (if multiple cities)
   ↓
3. Operations Center Window Opens
   ↓
4. Load City Data (progress indicator)
   ↓
5. Dashboard Ready
   ↓
6. User can:
   - View incidents in operations center
   - Open 3D city model volume
   - Access analytics dashboard
   - Enter immersive mode
```

### 7.2 Emergency Response Flow

```
1. Alert Received
   ↓
2. Notification Ornament Appears (pulsing red)
   ↓
3. User taps notification
   ↓
4. Emergency Command Window Opens
   ↓
5. Incident Details Displayed
   ↓
6. AI Suggests Optimal Response
   ↓
7. User Reviews and Confirms
   ↓
8. Units Dispatched (real-time tracking)
   ↓
9. Incident Status Updates
   ↓
10. Resolution and Reporting
```

### 7.3 Planning Session Flow

```
1. User Opens Planning Mode
   ↓
2. Enters Immersive Space
   ↓
3. Select Development Proposal
   ↓
4. Place Ghost Buildings
   ↓
5. Run Impact Simulations
   - Traffic impact
   - Population density
   - Environmental effects
   ↓
6. Adjust and Iterate
   ↓
7. Save Scenario
   ↓
8. Generate Report
   ↓
9. Share with Stakeholders
```

### 7.4 Navigation Patterns

**Window Management**:
```swift
// Open secondary windows
@Environment(\.openWindow) var openWindow

Button("View Analytics") {
    openWindow(id: "analytics")
}

// Dismiss window
@Environment(\.dismissWindow) var dismissWindow

Button("Close") {
    dismissWindow(id: "analytics")
}
```

**Immersive Transitions**:
```swift
@Environment(\.openImmersiveSpace) var openImmersive
@Environment(\.dismissImmersiveSpace) var dismissImmersive

// Smooth transition to immersive
Button("Enter City") {
    Task {
        await openImmersive(id: "city-immersive")
    }
}

// Exit immersive
Button("Exit") {
    Task {
        await dismissImmersive()
    }
}
```

## 8. Accessibility Design

### 8.1 VoiceOver Integration

**Spatial Labels**:
```swift
Model3D(named: "building_123")
    .accessibilityLabel("Commercial building at 123 Main Street")
    .accessibilityValue("Status: Operational, Occupancy: 450 people")
    .accessibilityHint("Double tap to view building details and utilities")
    .accessibilityAddTraits(.isButton)
    .accessibilitySpatialExperience()
```

**Navigation Rotor**:
```swift
// Custom rotor for incident navigation
.accessibilityRotor("Incidents") {
    ForEach(incidents) { incident in
        AccessibilityRotorEntry(incident.description, id: incident.id) {
            focusIncident(incident)
        }
    }
}
```

### 8.2 Visual Accessibility

**High Contrast Mode**:
```swift
@Environment(\.accessibilityContrastLevel) var contrast

var strokeWidth: CGFloat {
    contrast == .high ? 4 : 2
}

var backgroundColor: Color {
    contrast == .high ? .black : Color(.systemBackground)
}
```

**Dynamic Type**:
```swift
Text("Critical Alert")
    .font(.headline)
    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    .lineLimit(2)
    .minimumScaleFactor(0.8)
```

### 8.3 Motion Accessibility

**Reduce Motion**:
```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

if reduceMotion {
    // Static indicators instead of animations
    StatusIcon(status: .critical)
} else {
    // Animated pulsing alert
    PulsingAlert(status: .critical)
}
```

### 8.4 Alternative Inputs

**Keyboard Navigation**:
- Tab: Navigate between controls
- Space: Activate buttons
- Arrow keys: Pan 3D view
- +/-: Zoom
- Numbers: Quick access to departments (1=Fire, 2=Police, etc.)

**Voice Control**:
- "Show numbers" - Overlay numbers on interactive elements
- "Tap 5" - Activate element #5
- "Scroll down" - Navigate lists

## 9. Error States and Loading Indicators

### 9.1 Loading States

**City Data Loading**:
```swift
struct CityLoadingView: View {
    @State private var loadingProgress = 0.0

    var body: some View {
        VStack(spacing: 24) {
            ProgressView(value: loadingProgress, total: 1.0)
                .progressViewStyle(.circular)
                .scaleEffect(2)

            Text("Loading City Data...")
                .font(.headline)

            Text("\(Int(loadingProgress * 100))% Complete")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(width: 400, height: 300)
        .glassBackgroundEffect()
    }
}
```

**3D Model Streaming**:
```swift
RealityView { content in
    // Show low-poly placeholder
    let placeholder = createPlaceholderCity()
    content.add(placeholder)

    // Load high-poly asynchronously
    Task {
        let fullModel = try await loadDetailedCity()
        content.replace(placeholder, with: fullModel)
    }
}
```

### 9.2 Error States

**Network Error**:
```swift
struct NetworkErrorView: View {
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 60))
                .foregroundStyle(.red)

            Text("Connection Lost")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Unable to connect to city data services")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Retry") {
                onRetry()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(40)
        .frame(width: 400)
        .glassBackgroundEffect()
    }
}
```

**Data Not Available**:
```swift
struct EmptyStateView: View {
    let message: String

    var body: some View {
        ContentUnavailableView(
            "No Active Incidents",
            systemImage: "checkmark.circle",
            description: Text("All systems operational")
        )
    }
}
```

### 9.3 Skeleton Loading

```swift
struct DepartmentCardSkeleton: View {
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(.quaternary)
                .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 4) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(.quaternary)
                    .frame(width: 100, height: 16)

                RoundedRectangle(cornerRadius: 4)
                    .fill(.quaternary)
                    .frame(width: 60, height: 12)
            }
        }
        .padding()
        .redacted(reason: .placeholder)
        .shimmer() // Custom shimmer effect
    }
}
```

## 10. Animation and Transition Specifications

### 10.1 UI Animations

**Durations**:
- Instant: 0.1s (acknowledgements)
- Quick: 0.2s (button taps, toggles)
- Standard: 0.3s (view transitions, slides)
- Slow: 0.5s (major state changes)
- Dramatic: 1.0s (immersive transitions)

**Easing**:
```swift
// Default smooth easing
.animation(.spring(response: 0.3, dampingFraction: 0.7), value: state)

// Quick snap
.animation(.easeOut(duration: 0.2), value: state)

// Bouncy feedback
.animation(.spring(response: 0.4, dampingFraction: 0.6), value: state)
```

### 10.2 3D Transitions

**Building Emergence**:
```swift
func animateBuildingAppearance(_ entity: ModelEntity) {
    // Start from underground
    entity.position.y = -buildingHeight

    // Rise up smoothly
    entity.move(
        to: Transform(translation: targetPosition),
        relativeTo: nil,
        duration: 0.8,
        timingFunction: .easeOut
    )
}
```

**Layer Toggle Animation**:
```swift
func toggleInfrastructureLayer(visible: Bool) {
    infrastructureEntities.forEach { entity in
        if visible {
            entity.fadeIn(duration: 0.3)
        } else {
            entity.fadeOut(duration: 0.3)
        }
    }
}
```

### 10.3 Particle Effects

**Emergency Alert Pulse**:
```swift
var alertParticles: ParticleEmitterComponent {
    var emitter = ParticleEmitterComponent()

    emitter.mainEmitter.birthRate = 50
    emitter.mainEmitter.lifeSpan = 1.0
    emitter.mainEmitter.color = .evolving(
        start: .red.withAlphaComponent(1.0),
        end: .red.withAlphaComponent(0.0)
    )
    emitter.mainEmitter.size = 0.01
    emitter.mainEmitter.speed = 0.05

    return emitter
}
```

**Success Confirmation**:
```swift
func playSuccessEffect(at position: SIMD3<Float>) {
    let particles = createSuccessParticles()
    particles.position = position

    // Green burst
    // Sound effect
    // Haptic feedback

    // Auto-cleanup after 2 seconds
    Task {
        try await Task.sleep(for: .seconds(2))
        particles.removeFromParent()
    }
}
```

### 10.4 Transition Choreography

**Window to Immersive**:
```
1. User taps "Enter City" (0.0s)
2. Window content fades out (0.0s - 0.3s)
3. Environment darkens (0.2s - 0.5s)
4. City model scales up from window (0.3s - 0.8s)
5. Immersive environment fades in (0.5s - 1.0s)
6. Full immersion (1.0s)
```

---

This design specification provides comprehensive guidelines for creating an intuitive, accessible, and visually stunning Smart City Command Platform on visionOS.
