# Healthcare Ecosystem Orchestrator - Design Specifications

## Spatial Design Principles

### Core Healthcare Design Philosophy

1. **Patient-Centered Spatial Organization**
   - All information radiates from the patient
   - Critical data closest to user (0.5-1m)
   - Supporting information at comfortable viewing distance (1-2m)
   - Context and analytics in peripheral vision (2-3m)

2. **Clinical Clarity First**
   - Minimal visual noise
   - High contrast for critical information
   - Color-coded by clinical significance
   - Progressive disclosure of complexity

3. **Natural Healthcare Workflows**
   - Gestures mirror clinical actions
   - Spatial organization matches clinical thinking
   - Seamless transitions between care activities
   - Collaborative by default

4. **Safety and Compliance**
   - Always-visible patient identification
   - Clear indication of data sensitivity
   - Confirmation for critical actions
   - Audit trail of all interactions

## Window Layouts and Configurations

### Dashboard Window (Primary Entry Point)

**Dimensions**: 1200x800pt (default), resizable 1000-1600pt width

**Layout Zones**:
```
┌─────────────────────────────────────────────────────────┐
│  Header: Hospital Overview & User Info       [Alerts: 3]│
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌──────────────────┐  ┌───────────────────────────┐   │
│  │  Quick Stats     │  │  Patient Census           │   │
│  │  • Active: 247   │  │  ┌─────┐ ┌─────┐ ┌─────┐ │   │
│  │  • Critical: 12  │  │  │ ICU │ │ ED  │ │ Med │ │   │
│  │  • Alerts: 3     │  │  │ 18  │ │ 32  │ │ 156 │ │   │
│  └──────────────────┘  └───────────────────────────┘   │
│                                                           │
│  ┌─────────────────────────────────────────────────┐   │
│  │  Active Patients (Priority View)                │   │
│  │  ┌──────────────────────────────────────────┐  │   │
│  │  │ [!] Smith, John - ICU 4 - BP Critical    │  │   │
│  │  │ [!] Johnson, M - ED 2 - Deteriorating    │  │   │
│  │  │ [ ] Williams, S - Med 3 - Stable         │  │   │
│  │  └──────────────────────────────────────────┘  │   │
│  └─────────────────────────────────────────────────┘   │
│                                                           │
│  [Open Care Coordination] [Launch Clinical Observatory] │
└─────────────────────────────────────────────────────────┘
```

**Visual Hierarchy**:
- Critical alerts: Pulsing red glow, elevated in z-space
- High priority: Amber accent, subtle animation
- Normal status: Calm blue-gray tones
- Background: Translucent glass material

### Patient Detail Window

**Dimensions**: 1400x1000pt (default), resizable

**Tab Structure**:
```
┌─────────────────────────────────────────────────────────┐
│ Patient: SMITH, John (MRN: 12345678)        Age: 67  M  │
│ Location: ICU-4  |  Attending: Dr. Martinez             │
├─────────────────────────────────────────────────────────┤
│ [Overview] [Vitals] [Labs] [Meds] [Notes] [Care Plan]  │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌─────────────────┐  ┌─────────────────────────────┐  │
│  │ Vital Signs     │  │ Active Problems             │  │
│  │ HR:  112 ↑      │  │ • Acute respiratory failure │  │
│  │ BP:  90/60 ↓    │  │ • Sepsis                    │  │
│  │ RR:  24 ↑       │  │ • Atrial fibrillation       │  │
│  │ O2:  94%        │  │                             │  │
│  │ Temp: 38.5°C ↑  │  └─────────────────────────────┘  │
│  └─────────────────┘                                    │
│                                                           │
│  ┌─────────────────────────────────────────────────┐   │
│  │ Timeline View                                    │   │
│  │ ═══════════════════════════════════════════════ │   │
│  │ [Admission] → [ICU] → [Surgery] → [Recovery]   │   │
│  └─────────────────────────────────────────────────┘   │
│                                                           │
│  [View in 3D] [Team Communication] [Discharge Plan]     │
└─────────────────────────────────────────────────────────┘
```

### Analytics Window

**Dimensions**: 1600x900pt (default)

**Dashboard Layout**:
```
┌─────────────────────────────────────────────────────────┐
│ Population Health Analytics                              │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌───────────────┐ ┌───────────────┐ ┌───────────────┐ │
│  │ Quality Score │ │ Readmission   │ │ Length of Stay│ │
│  │      92%      │ │ Rate: 8.5%    │ │   4.2 days    │ │
│  │    ↑ 5pts     │ │   ↓ 2.1pts    │ │    ↓ 0.3d     │ │
│  └───────────────┘ └───────────────┘ └───────────────┘ │
│                                                           │
│  ┌─────────────────────────────────────────────────┐   │
│  │ Department Performance Comparison                │   │
│  │ [Bar chart visualization]                        │   │
│  └─────────────────────────────────────────────────┘   │
│                                                           │
│  ┌─────────────────────────────────────────────────┐   │
│  │ Risk Stratification                              │   │
│  │ [Heat map of patient populations]                │   │
│  └─────────────────────────────────────────────────┘   │
│                                                           │
└─────────────────────────────────────────────────────────┘
```

## Volume Designs (3D Bounded Spaces)

### Care Coordination Volume

**Dimensions**: 2m x 2m x 2m

**Spatial Organization**:
```
            Top View
         ┌─────────┐
         │    🏥   │  Hospital (center)
         │         │
    ┌────┼────●────┼────┐
    │    │   / \   │    │
    │ 🏠 │  /   \  │ 🏥 │  Home ← Patient → Clinic
    │    │ /     \ │    │
    └────┼/───────\┼────┘
         │ Care    │
         │ Journey │
         └─────────┘
```

**3D Elements**:
- **Central Patient Sphere**: Rotating, data-rich core
- **Care Pathway Lines**: Glowing trails showing journey
- **Milestone Nodes**: Interactive touchpoints for events
- **Team Avatars**: Floating indicators of care team members
- **Temporal Slider**: Arc at bottom for time navigation

**Interactions**:
- Pinch and drag to rotate view
- Tap nodes to see details
- Swipe timeline to navigate history
- Pull outward to zoom into specific period

### Clinical Observatory Volume

**Dimensions**: 3m x 2m x 2m (wider for multi-patient view)

**Spatial Layout**:
```
         Side View

    2m  ╔═══════════════════════════╗
    ↕   ║   Critical Patients       ║  Elevated, close
    1m  ║─────────────────────────  ║
    ↕   ║   Monitored Patients      ║  Middle tier
    0m  ║─────────────────────────  ║
        ╚═══════════════════════════╝  Stable patients, lower

        ├───────── 3m ─────────────┤
```

**Visual Elements**:
- **Patient Cards**: Floating panels with vital signs
- **Vital Sign Graphs**: Real-time sparklines
- **Alert Indicators**: Pulsing halos by severity
- **Department Zones**: Color-coded regions
- **Staff Indicators**: Small avatars showing assignments

**Interactions**:
- Gaze at patient to highlight
- Pinch card to bring forward
- Double-tap to open detail window
- Swipe to filter by department

## Full Space/Immersive Experiences

### Emergency Response Space (Full Immersion)

**Environment Design**:
```
        360° Immersive View

              [Critical Info]
               Vital Signs
                    ↑
    [Team Comms] ← USER → [Patient View]
                    ↓
              [Actions Bar]
```

**Spatial Zones**:
- **0°-60° (Center-Right)**: Primary patient information
- **60°-120° (Right)**: Supporting data and labs
- **120°-180° (Behind)**: Team communication
- **180°-240° (Left-Behind)**: Historical context
- **240°-300° (Left)**: Intervention options
- **300°-360° (Center-Left)**: Monitoring and alerts

**Visual Treatment**:
- Red ambient lighting for emergency context
- High-contrast text for visibility
- Minimal animations to reduce distraction
- Spatial audio for alerts

### Medical Education Space

**Environment Design**:
- Central anatomical model (1.5m scale)
- Surrounding clinical data layers
- Instructor position (elevated view)
- Student observation points
- Interactive annotation tools

## 3D Visualization Specifications

### Patient Journey River Visualization

**Concept**: Patient's healthcare journey as a flowing river

**Visual Metaphor**:
```
Source (Admission)
    ↓ ～～～
    ↓ ～～～  Smooth flow = normal progress
    ↓ ～～～
Rapids ≋≋≋≋  Critical events, procedures
    ↓ ～～～
Tributaries   Other departments join
    ↓ ～～～～～
    ↓ ～～～～～  Widening = recovery
    ↓ ～～～～～
Ocean (Discharge)
```

**Implementation Details**:
- Particle system for water flow
- Flow rate indicates vitals stability
- Color gradient: Blue (stable) → Amber (concern) → Red (critical)
- Eddies represent complications
- Smooth vs. turbulent indicates patient status

### Clinical Status Landscape

**Concept**: Vital signs as terrain elevation

**Topography**:
```
     Mountain peaks = High values (fever, tachycardia)
        /\    /\
       /  \  /  \
      /    \/    \___   Normal plateau
     /              \____ Valleys = Low values (hypotension)
```

**Visual Properties**:
- Height mapped to vital sign values
- Color by clinical significance
- Smooth terrain = stable
- Jagged peaks = volatile
- Fog in valleys = danger zones

### Population Health Galaxy

**Concept**: Patient population as star field

**Visualization**:
```
        ★ ★ ★           ★ ★
      ★ ★ ★ ★ ★       ★ ★ ★
        ★ ★ ★           ★    Constellation patterns

    ★ Bright = High risk
    · Dim = Low risk
    Color = Condition type
    Position = Demographics
```

**Interaction**:
- Zoom to individual patient stars
- Filter by condition (constellations light up)
- Time-lapse shows population changes
- Connecting lines show care relationships

## Interaction Patterns

### Gaze and Pinch Gestures

**Primary Selection**:
1. Look at target (gaze highlights)
2. Pinch fingers (thumb + index)
3. Item selected, detail appears

**Use Cases**:
- Select patient from list
- Choose care action
- Navigate timeline
- Acknowledge alerts

### Hand Tracking Gestures

**Clinical Gestures**:

**Approve Treatment** (Thumbs Up):
```
     👍
```
- Used for: Confirming orders, approving care plans
- Feedback: Green glow, checkmark animation

**Urgent Flag** (Point with Index):
```
     ☝️
```
- Used for: Marking urgent items, requesting attention
- Feedback: Red pulse, notification sent

**Examine Detail** (Pinch and Pull):
```
  🤏 ← →  expanding motion
```
- Used for: Opening patient detail, zooming x-rays
- Feedback: Smooth zoom animation

**Team Communication** (Open Palm):
```
     🖐️
```
- Used for: Activating voice input, summoning assistance
- Feedback: Microphone icon appears

### Voice Commands

**Command Structure**: `[Action] [Target] [Modifier]`

**Examples**:
- "Show critical patients" → Filters dashboard
- "Next patient" → Navigates list
- "Acknowledge alert" → Dismisses notification
- "Call Dr. Martinez" → Initiates communication
- "Show vitals history" → Displays timeline graph

## Visual Design System

### Color Palette

**Clinical Status Colors**:
```swift
enum ClinicalColor {
    static let critical = Color(red: 0.90, green: 0.20, blue: 0.20)      // #E63333
    static let warning = Color(red: 0.95, green: 0.65, blue: 0.20)       // #F2A633
    static let normal = Color(red: 0.30, green: 0.70, blue: 0.90)        // #4DB3E6
    static let improving = Color(red: 0.30, green: 0.80, blue: 0.40)     // #4DCC66
    static let concern = Color(red: 0.60, green: 0.40, blue: 0.90)       // #9966E6
}
```

**UI Colors**:
```swift
enum UIColor {
    static let background = Color(white: 0.12, opacity: 0.85)             // Translucent dark
    static let surface = Color(white: 0.20, opacity: 0.90)                // Card backgrounds
    static let text = Color(white: 0.95)                                  // Primary text
    static let textSecondary = Color(white: 0.70)                         // Secondary text
    static let accent = Color(red: 0.00, green: 0.48, blue: 0.80)        // #007ACC
}
```

### Typography (Spatial Text Rendering)

**Font System**:
```swift
enum HealthcareFont {
    static let title = Font.system(size: 34, weight: .bold, design: .default)
    static let headline = Font.system(size: 24, weight: .semibold, design: .default)
    static let body = Font.system(size: 17, weight: .regular, design: .default)
    static let caption = Font.system(size: 14, weight: .regular, design: .default)

    // Clinical data (monospaced for alignment)
    static let clinical = Font.system(size: 17, weight: .medium, design: .monospaced)
}
```

**Text Rendering Best Practices**:
- Always use black or white background plates for readability
- Minimum font size: 14pt for critical information
- Line height: 1.4x for body text
- Letter spacing: -0.5pt for headlines

### Materials and Lighting

**Glass Materials**:
```swift
// Primary window background
.background(.ultraThinMaterial)

// Card and panel backgrounds
.background(.regularMaterial)

// Critical alert backgrounds
.background(.thickMaterial)
```

**Lighting Strategy**:
- Ambient: Soft, neutral (simulates clinical environment)
- Directional: Top-down (mimics overhead hospital lighting)
- Spot: For emphasis on critical elements
- Emission: For self-lit UI elements and alerts

### Iconography in 3D Space

**Icon Design Principles**:
- Minimum size: 44pt hit target
- 3D depth: 4-8pt extrusion for buttons
- Line weight: 2-3pt for clarity
- Color: Status-based or neutral gray

**Common Healthcare Icons**:
```
🏥 Hospital/Facility    ❤️ Cardiology          🧪 Laboratory
👤 Patient              🫁 Respiratory         💊 Pharmacy
👨‍⚕️ Provider             🧠 Neurology           📋 Notes
⚕️ Medical Care         🦴 Orthopedics         📊 Analytics
🚑 Emergency            👁️ Ophthalmology       ⚠️ Alert
```

## User Flows and Navigation

### Primary User Flow: Morning Rounds

```
1. Launch App
   └─→ Dashboard Window opens
       └─→ See patient census and critical alerts

2. Review Critical Patients
   └─→ Tap "Critical" filter
       └─→ List shows only critical status patients
           └─→ Tap patient card
               └─→ Patient Detail Window opens

3. Examine Patient Details
   └─→ Review vitals, labs, medications
       └─→ Switch to Care Plan tab
           └─→ Update interventions
               └─→ Voice note: "Plan for today"

4. Collaborate with Team
   └─→ Tap "Team Communication"
       └─→ Team members join in shared view
           └─→ Discuss patient in 3D care coordination
               └─→ Assign tasks to team members

5. Continue Rounds
   └─→ Swipe to next patient
       └─→ Repeat steps 3-4
```

### Secondary Flow: Emergency Response

```
1. Emergency Alert Received
   └─→ Immersive Space activates automatically
       └─→ Patient info surrounds user (360°)

2. Assess Situation
   └─→ Critical vitals in center view
       └─→ Recent trends on periphery
           └─→ AI recommendations appear

3. Take Action
   └─→ Voice command: "Start sepsis protocol"
       └─→ Checklist appears
           └─→ Check off each intervention
               └─→ Real-time updates to team

4. Monitor Response
   └─→ Vitals update in real-time
       └─→ Status improves → Green indicators
           └─→ Exit immersive mode
               └─→ Return to dashboard
```

## Accessibility Design

### VoiceOver Experience

**Announcement Structure**:
- Element type
- Element label
- Element value
- Status/state
- Hint (how to interact)

**Example**:
> "Patient card button. Smith, John. Medical Record Number 12345678. Status: Critical. Heart rate 112, elevated. Location ICU room 4. Double tap to view patient details."

### High Contrast Mode

**Adjustments**:
- Increase contrast ratio to 7:1 minimum
- Remove gradient backgrounds
- Use solid colors for status
- Thicker borders and dividers
- Eliminate transparency

### Reduce Motion

**Modifications**:
- Disable particle effects
- Remove flowing animations
- Instant transitions instead of smooth
- Static visualizations (no real-time updates)
- Simplified 3D to 2D representations

## Error States and Loading Indicators

### Error States

**Network Error**:
```
┌─────────────────────────────┐
│          ⚠️                  │
│  Connection Lost             │
│                              │
│  Unable to reach EHR system  │
│                              │
│  [ Retry ]  [ Go Offline ]   │
└─────────────────────────────┘
```

**Data Sync Error**:
```
┌─────────────────────────────┐
│          ⚠️                  │
│  Sync Failed                 │
│                              │
│  Patient data may be stale   │
│  Last update: 5 minutes ago  │
│                              │
│  [ Force Sync ]              │
└─────────────────────────────┘
```

### Loading Indicators

**Initial Load**:
- Skeleton screens for windows
- Shimmer effect on placeholder cards
- Progress bar for large data sets

**Real-time Updates**:
- Subtle pulse on updating cards
- Gentle fade-in for new data
- Smooth number transitions

**Background Sync**:
- Small sync icon in status bar
- No blocking UI
- Toast notification on completion

## Animation and Transition Specifications

### Window Transitions

**Opening Window**:
```swift
.transition(.asymmetric(
    insertion: .scale(scale: 0.8).combined(with: .opacity),
    removal: .scale(scale: 0.95).combined(with: .opacity)
))
.animation(.spring(response: 0.4, dampingFraction: 0.8), value: isPresented)
```

**Tab Switching**:
```swift
.transition(.asymmetric(
    insertion: .move(edge: .trailing).combined(with: .opacity),
    removal: .move(edge: .leading).combined(with: .opacity)
))
.animation(.easeInOut(duration: 0.25), value: selectedTab)
```

### Alert Animations

**Critical Alert Appearance**:
```swift
// Pulsing glow effect
.overlay {
    RoundedRectangle(cornerRadius: 12)
        .stroke(Color.red, lineWidth: 3)
        .opacity(pulseOpacity)
        .animation(
            .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
            value: pulseOpacity
        )
}
```

### 3D Entity Animations

**Patient Selection**:
```swift
// Scale up and brighten
entity.scale = [1.2, 1.2, 1.2]
entity.components[ModelComponent.self]?.materials = highlightedMaterials

// Animate over 0.3 seconds
entity.animate(to: targetTransform, duration: 0.3, curve: .easeOut)
```

---

*This design system creates a cohesive, intuitive, and clinically effective spatial computing experience for healthcare professionals, ensuring patient safety, operational efficiency, and medical excellence.*
