# Real Estate Spatial Platform - Design Specification

## Document Information
- **Version**: 1.0
- **Last Updated**: 2025-11-17
- **Platform**: visionOS 2.0+
- **Design System**: Real Estate Spatial Design Language
- **Status**: Design Phase

---

## 1. Spatial Design Principles

### 1.1 Core Principles

#### **Spatial Hierarchy**
```
Content organization by proximity and depth:
- Primary content: Eye level, 1.5-2m distance
- Secondary content: Peripheral, 2-3m distance
- Background context: 3-5m distance
- Immersive content: Full environment replacement
```

#### **Progressive Disclosure**
```
User Journey:
1. Start: 2D windows (familiar interface)
2. Explore: 3D volumes (spatial preview)
3. Immerse: Full spaces (photorealistic experience)
4. Expert: Multi-window + volume workflow
```

#### **Comfort and Ergonomics**
- Content placement: 10-15° below eye level
- Minimum viewing distance: 0.5m
- Optimal distance: 1.5m
- Maximum interactive distance: 5m
- Reading angle: Slight tilt toward user

#### **Visual Clarity**
- Glass materials with appropriate opacity
- High contrast text (WCAG AA minimum)
- Lighting that complements environment
- Depth cues through shadows and parallax

#### **Intuitive Interactions**
- Gaze + pinch as primary input
- Direct manipulation where possible
- Predictable spatial behaviors
- Clear affordances for interactive elements

---

## 2. Window Layouts and Configurations

### 2.1 Primary Window: Property Browser

```
┌─────────────────────────────────────────────────────────────────┐
│  Real Estate Spatial                          🔍 Search   👤 Me │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────┐  🏠 All Properties  💰 Price  📍 Location  ⭐ Saved│
│  │ FILTERS  │                                                    │
│  │          │  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐  │
│  │ Price    │  │ Photo  │  │ Photo  │  │ Photo  │  │ Photo  │  │
│  │ $500K-2M │  │        │  │        │  │        │  │        │  │
│  │          │  ├────────┤  ├────────┤  ├────────┤  ├────────┤  │
│  │ Beds     │  │3bd 2ba │  │4bd 3ba │  │2bd 1ba │  │5bd 4ba │  │
│  │ 2-5      │  │$850K   │  │$1.2M   │  │$625K   │  │$1.8M   │  │
│  │          │  │SF, CA  │  │SF, CA  │  │SF, CA  │  │SF, CA  │  │
│  │ Type     │  └────────┘  └────────┘  └────────┘  └────────┘  │
│  │ House    │                                                    │
│  │ Condo    │  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐  │
│  │          │  │ Photo  │  │ Photo  │  │ Photo  │  │ Photo  │  │
│  │ Location │  │        │  │        │  │        │  │        │  │
│  │ SF, CA   │  ├────────┤  ├────────┤  ├────────┤  ├────────┤  │
│  │          │  │3bd 2ba │  │4bd 2ba │  │3bd 3ba │  │6bd 5ba │  │
│  │ Clear    │  │$920K   │  │$1.1M   │  │$780K   │  │$2.2M   │  │
│  └──────────┘  │SF, CA  │  │SF, CA  │  │SF, CA  │  │SF, CA  │  │
│                └────────┘  └────────┘  └────────┘  └────────┘  │
│                                                                  │
│                        [Load More Properties]                   │
└─────────────────────────────────────────────────────────────────┘

Specifications:
- Default size: 1200 x 800 points
- Resizable: 800-1600 width, 600-1200 height
- Glass material: .regularMaterial with vibrancy
- Grid: 4 columns, adaptive spacing
- Card size: 250 x 280 points
- Filter sidebar: 200 points width, collapsible
```

#### Property Card Component
```
┌─────────────────────────┐
│                         │ ← Photo (16:9 ratio)
│      Property Photo     │   Hover: Subtle glow
│                         │   Tap: Open details
├─────────────────────────┤
│ 📍 123 Main Street      │ ← Address (1 line, ellipsis)
│ 🛏️ 3 bd  🛁 2 ba        │ ← Quick specs
│ 📐 2,400 sq ft          │   (icons + text)
│ 💰 $850,000             │ ← Price (prominent)
│                         │
│ [❤️ Save]   [👁️ Tour]   │ ← Action buttons
└─────────────────────────┘

Interactions:
- Hover: Scale 1.05x, add soft shadow
- Tap card: Open detail window
- Tap heart: Toggle saved (haptic feedback)
- Tap eye: Launch immersive tour
```

### 2.2 Property Detail Window

```
┌───────────────────────────────────────────────────────────────────┐
│  ← Back                123 Main Street, San Francisco            │
├───────────────────────────────────────────────────────────────────┤
│                                                                    │
│  ┌────────────────────────────────────┐  ┌──────────────────────┐│
│  │                                    │  │  $850,000            ││
│  │                                    │  │  Est. $3,200/mo      ││
│  │         Main Photo                 │  │                      ││
│  │      (Large, 16:9)                 │  │  [Start Tour 👁️]     ││
│  │                                    │  │  [Save Property ❤️]   ││
│  │       [◀ Prev]  [Next ▶]           │  │  [Share 📤]          ││
│  └────────────────────────────────────┘  │  [Schedule Visit]    ││
│                                           └──────────────────────┘│
│  [Photos] [Floor Plan] [3D Model] [Map] [Street View]            │
│                                                                    │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                                                    │
│  Property Details                    Features                     │
│  ────────────────                    ────────                     │
│  🛏️ Bedrooms: 3                      ✓ Hardwood floors           │
│  🛁 Bathrooms: 2                     ✓ Granite counters          │
│  📐 Size: 2,400 sq ft                ✓ Stainless appliances      │
│  🏗️ Year Built: 2015                 ✓ Central AC               │
│  🅿️ Parking: 2 car garage            ✓ Fireplace                │
│  📊 HOA: $250/mo                     ✓ Private yard             │
│                                                                    │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                                                    │
│  Description                                                       │
│  ───────────                                                       │
│  Beautiful modern home in desirable neighborhood. Recently        │
│  updated kitchen and bathrooms. Large backyard perfect for...     │
│  [Read More]                                                       │
│                                                                    │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                                                    │
│  Neighborhood                                                      │
│  ────────────                                                      │
│  🏫 Schools: Roosevelt Elementary (9/10) - 0.3 mi                │
│  🚌 Transit: BART Powell St - 12 min walk                        │
│  🏪 Amenities: Whole Foods - 5 min walk                          │
│  [View Neighborhood Details]                                      │
│                                                                    │
└───────────────────────────────────────────────────────────────────┘

Specifications:
- Default size: 900 x 1000 points
- Scrollable content area
- Glass material with vibrancy
- Tab bar for media switching
- CTA section always visible (pinned)
```

### 2.3 Agent Dashboard Window

```
┌───────────────────────────────────────────────────────────────────┐
│  Agent Dashboard                    John Smith, Realtor®   [⚙️]   │
├───────────────────────────────────────────────────────────────────┤
│                                                                    │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐│
│  │ Active      │ │ Showings    │ │ Offers      │ │ Closed      ││
│  │ Listings    │ │ This Week   │ │ Pending     │ │ This Month  ││
│  │             │ │             │ │             │ │             ││
│  │    24       │ │     18      │ │      5      │ │     3       ││
│  │    +2       │ │    +3       │ │     -1      │ │    +1       ││
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘│
│                                                                    │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                                                    │
│  Today's Schedule                        Top Performing Listings  │
│  ────────────────                        ────────────────────────  │
│                                                                    │
│  9:00 AM  Virtual Tour - 123 Main St    1. 789 Oak Ave           │
│           Client: Sarah Chen             48 views, 12 saves       │
│           [Join]                         [Analytics]              │
│                                                                    │
│  11:00 AM Open House - 456 Elm St       2. 123 Main St            │
│           Expected: 15 attendees         35 views, 8 saves        │
│           [Prepare]                      [Analytics]              │
│                                                                    │
│  2:00 PM  Client Meeting - Virtual      3. 456 Elm St             │
│           Buyers Workshop                28 views, 5 saves        │
│           [Start]                        [Analytics]              │
│                                                                    │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                                                    │
│  Client Pipeline                         Quick Actions            │
│  ───────────────                         ─────────────            │
│                                                                    │
│  [New Leads: 8]    [Active: 12]          [+ New Listing]         │
│  [Qualified: 5]    [Under Contract: 3]   [Schedule Showing]      │
│                                           [Upload Property]       │
│  [View Full Pipeline]                    [Analytics Report]      │
│                                                                    │
└───────────────────────────────────────────────────────────────────┘

Specifications:
- Default size: 1400 x 900 points
- Dashboard grid layout
- Real-time data updates (WebSocket)
- Glass material for cards
- Color-coded metrics (green positive, red negative)
```

---

## 3. Volume Designs (3D Bounded Spaces)

### 3.1 Floor Plan Volume

```
Visual Layout (Top-Down View):

      ┌─────────────────────────────┐
      │                             │
      │    3D Floor Plan Volume     │
      │    (1.5m × 1.2m × 1.5m)    │
      │                             │
      │         ┌───────┐           │
      │         │Kitchen│           │
      │         └───┬───┘           │
      │             │               │
      │    ┌────────┼────────┐      │
      │    │ Living Room     │      │
      │    │                 │      │
      │    └────────┬────────┘      │
      │             │               │
      │    ┌────────┴────────┐      │
      │    │  Master Bedroom │      │
      │    └─────────────────┘      │
      │                             │
      └─────────────────────────────┘

Features:
- Extruded wall heights (proportional)
- Room labels floating above
- Furniture layout visible
- Tap room to highlight
- Dimensions displayed on edges
- Color-coded by room type
- Rotate with drag gesture
- Pinch to scale (0.5x - 2x)
```

#### Room Type Colors
```swift
Room Colors (with glass material):
- Living Room: Soft blue (#4A90E2, 60% opacity)
- Bedrooms: Lavender (#9B59B6, 60% opacity)
- Kitchen: Warm yellow (#F39C12, 60% opacity)
- Bathrooms: Aqua (#1ABC9C, 60% opacity)
- Office: Green (#27AE60, 60% opacity)
- Garage: Gray (#95A5A6, 60% opacity)

Hover state: Increase opacity to 80%
Selected state: Full opacity with glow
```

#### Interactive Elements
```
Floor Plan Ornament (Bottom):
┌────────────────────────────────────────────────┐
│ [Rotate↻] [Reset⟳] [Measure📏] [Rooms🏠] [Info] │
└────────────────────────────────────────────────┘

Room Info Panel (on selection):
┌─────────────────────┐
│ Master Bedroom      │
│ 15' × 12' (180 sqft)│
│ Carpet flooring     │
│ Walk-in closet      │
│ [View in Tour]      │
└─────────────────────┘
```

### 3.2 Property Model Volume

```
Visual Layout (Isometric View):

              Roof
         ┌────────────┐
        ╱│            │╲
       ╱ │            │ ╲
      ╱  │   House    │  ╲
     ╱   │            │   ╲
    ╱    │            │    ╲
   └─────┴────────────┴─────┘
   │                         │
   │      Front Yard         │
   │                         │
   └─────────────────────────┘

Features:
- Photorealistic textures
- Landscaping included
- Driveway and garage
- Roof and siding details
- Outdoor lighting
- Scale: 1:100 default
- Ambient lighting
- Shadow casting
```

#### Interaction Controls
```
Model Ornament (Bottom):
┌──────────────────────────────────────────────────────┐
│ [Spin↻] [Top View⬆️] [Front View➡️] [Info ℹ️] [AR🎯] │
└──────────────────────────────────────────────────────┘

Info Overlays (toggleable):
- Lot dimensions
- Building footprint
- Setback lines
- Property boundaries
- Easements
```

### 3.3 Neighborhood Context Volume

```
Visual Layout (Aerial View):

    Parks & Schools           Subject Property
         🌳                        🏠

    ─────────────────────────────────────
              Main Street
    ─────────────────────────────────────

    🏪  🏪  🏪                   🏠  🏠
    Shops                        Homes

    🚌 Transit Stop

Features:
- 3D buildings (simplified)
- Points of interest marked
- Street network
- Transit routes highlighted
- Parks and green spaces
- Walking radius circles
- Scale: 1:1000
```

#### Interactive POI Markers
```
Marker Types:
🏫 Schools (rated, distance shown)
🏪 Shopping (grocery, retail)
🏥 Healthcare (hospitals, clinics)
🍽️ Dining (restaurants, cafes)
🏋️ Fitness (gyms, parks)
🚌 Transit (bus, train, subway)
🎭 Entertainment (theaters, venues)

On Tap:
┌─────────────────────────┐
│ Roosevelt Elementary    │
│ Rating: 9/10            │
│ Distance: 0.3 miles     │
│ Walking: 6 minutes      │
│ [Get Directions]        │
│ [More Info]             │
└─────────────────────────┘
```

---

## 4. Full Space / Immersive Experiences

### 4.1 Property Tour Immersive Space

#### Environment Setup
```
Immersion Level: Progressive (user-controlled)
- Mixed: Property overlaid on passthrough
- Progressive: Gradual environment replacement
- Full: Complete immersion in property

Default Starting Room: Living Room (main entrance alternative)
Camera Position: 1.6m height (average eye level)
Movement: Teleport primary, walk optional
```

#### Room Environment
```
Visual Composition (Living Room Example):

                   Ceiling (with lighting)
    ┌────────────────────────────────────────────┐
    │                                            │
    │    Floor Lamp        Sofa        Window   │
    │        💡          ▬▬▬▬▬          ▢▢▢    │
    │                                   ▢▢▢    │
    │                   Coffee                  │
    │    TV Stand       Table                   │
    │    ▬▬▬▬▬          ▬▬▬                    │
    │                                            │
    └────────────────────────────────────────────┘
                   Floor (hardwood texture)

Photorealistic Elements:
- 8K texture resolution
- PBR materials (realistic lighting)
- Baked ambient occlusion
- Real-time shadows
- HDR lighting
- Spatial audio ambience
```

#### Navigation System
```
Teleport Indicators:
┌─────────────────────────────────┐
│                                 │
│    [Floating Room Buttons]      │
│                                 │
│    🛋️ Living Room (current)     │
│    🍳 Kitchen                   │
│    🛏️ Master Bedroom            │
│    🛁 Master Bath               │
│    🛏️ Bedroom 2                 │
│    🛏️ Bedroom 3                 │
│    🚗 Garage                    │
│    🌳 Backyard                  │
│                                 │
└─────────────────────────────────┘

Position: Left side, 1.5m away, eye level
Material: Glass with vibrancy
Interaction: Gaze + pinch to teleport
Animation: Fade out → move camera → fade in (500ms total)
```

#### Interactive Hotspots
```
Hotspot Types:

1. Feature Highlights
   ┌─────────────────┐
   │    ℹ️           │ ← Floating above feature
   │  Granite        │    (e.g., kitchen counter)
   │  Countertops    │
   └─────────────────┘

   On Tap: Detailed info panel

2. Measurements
   ├─────── 12 ft ────────┤
   │                       │

   Always visible, unobtrusive

3. Staging Toggle
   [👁️ Show Staging]
   [🏠 Show Empty]

   Bottom center, persistent

4. Media Points
   📷 Photo Gallery
   📹 Video Tour
   📄 Floor Plan

   Contextual, appear near relevant areas
```

#### Control Panel (Persistent)
```
Bottom Center Ornament:

┌────────────────────────────────────────────────────┐
│ [🏠 Rooms] [📏 Measure] [🪑 Staging] [💬 Notes] [❌ Exit] │
└────────────────────────────────────────────────────┘

Specifications:
- Position: 0.5m below eye level, 1m away
- Material: Ultra-thin glass
- Auto-hide: After 5 seconds of inactivity
- Reappear: On hand raise or gaze down
```

### 4.2 Virtual Open House Space

#### Multi-User Setup
```
Participant Avatars:
┌─────────┐
│   👤    │ ← Simple avatar representation
│  John   │    (head + shoulders)
│ (Agent) │
└─────────┘

Avatar Features:
- Name label below
- Role badge (Agent, Buyer, etc.)
- Spatial audio (voice from avatar position)
- Gaze direction indicator
- Muted indicator (if applicable)
```

#### Shared Interaction System
```
Agent Controls (Enhanced):
┌──────────────────────────────────────────────────────┐
│ [Navigate All] [Highlight Feature] [Share Doc] [Q&A] │
└──────────────────────────────────────────────────────┘

- Navigate All: Move all participants to agent's room
- Highlight: Draw attention to specific features
- Share Doc: Show documents to participants
- Q&A: Toggle question panel

Participant View:
┌──────────────────────────────────────────────────────┐
│ [Follow Agent] [Free Roam] [Raise Hand ✋] [Leave]   │
└──────────────────────────────────────────────────────┘
```

#### Annotation System
```
Shared Annotations:
┌──────────────────────┐
│  Agent: "New granite │ ← Floating note
│  counters installed" │    Visible to all
│  2 minutes ago       │    Auto-fade after 5 min
└──────────────────────┘

Drawing Tool:
- Agent draws arrows/circles in 3D space
- Visible to all participants
- Red highlight color
- Fade after 10 seconds
```

### 4.3 Renovation Preview Space

#### Before/After Visualization
```
Split View Mode:

     ┌─────────────────┬─────────────────┐
     │     BEFORE      │      AFTER      │
     │                 │                 │
     │   [Current]     │   [Renovated]   │
     │                 │                 │
     │   Old Kitchen   │   New Kitchen   │
     │   White Cabinets│   Gray Cabinets │
     │   Laminate      │   Granite       │
     │                 │                 │
     └─────────────────┴─────────────────┘
            ↕ Drag slider to compare

Slider Interaction:
- Vertical divider, drag left/right
- Smooth transition (60fps)
- Snap to center option
- [Before] [Compare] [After] buttons
```

#### Interactive Renovation Tools
```
Renovation Panel:

┌─────────────────────────────────┐
│ Renovation Options              │
├─────────────────────────────────┤
│ Walls                           │
│  [Remove Wall] [Add Wall]       │
│                                 │
│ Cabinets                        │
│  Style: [Modern▼]               │
│  Color: [Gray▼] [⬜ Preview]   │
│                                 │
│ Countertops                     │
│  Material: [Granite▼]           │
│  Color: [White▼] [⬜ Preview]  │
│                                 │
│ Flooring                        │
│  Type: [Hardwood▼]              │
│  [⬜ Preview]                   │
│                                 │
│ ─────────────────────────────   │
│ Estimated Cost: $45,000         │
│                                 │
│ [Save Plan] [Share] [Reset]     │
└─────────────────────────────────┘

Position: Right side, scrollable
Material: Glass panel
Updates: Real-time preview in space
```

---

## 5. Interaction Patterns

### 5.1 Gaze and Pinch Gestures

#### Primary Interactions
```swift
Interaction Hierarchy:

1. Look (Gaze)
   - Triggers hover state (200ms delay)
   - Highlights interactive elements
   - Shows tooltips

2. Pinch (Select)
   - Thumb + index finger
   - Confirms selection
   - Haptic feedback on success

3. Hold (Sustained Action)
   - Pinch and hold (500ms+)
   - Activates context menu
   - Drag operations
```

#### Hover States
```
Default → Hover → Pressed

Button:
Default:  [  Save Property  ]  (opacity 80%)
Hover:    [  Save Property  ]  (opacity 100%, scale 1.05)
Pressed:  [  Save Property  ]  (scale 0.98, haptic)

Card:
Default:  No border, standard shadow
Hover:    Soft glow, elevated shadow
Pressed:  Brighten, deeper shadow
```

### 5.2 Hand Tracking Gestures

#### Custom Gestures
```
1. Pinch and Drag (Move Objects)
   👌 → 🤏 (while moving hand)
   Use: Furniture placement, annotation drawing

2. Two-Hand Pinch (Scale)
   👌        👌
     ←   →
   Use: Resize 3D models, adjust volume size

3. Point (Indicate)
   ☝️
   Use: Directional highlights, "look here"

4. Swipe (Navigate)
   ✋ → 👋 (horizontal)
   Use: Photo gallery, next room

5. Grab (Rotate)
   ✊ (rotate wrist)
   Use: 3D model rotation
```

#### Gesture Feedback
```
Visual Feedback:
- Pinch: Small circle at pinch point
- Drag: Trail line following hand
- Scale: Scale percentage indicator
- Point: Raycast line from finger

Audio Feedback:
- Pinch start: Soft "tick"
- Pinch release: Soft "tock"
- Successful action: Gentle "ding"
- Invalid action: Subtle "buzz"

Haptic Feedback:
- On selection: Light tap
- On drag: Continuous light buzz
- On completion: Double tap
- On error: Sharp buzz
```

### 5.3 Voice Commands (Optional)

```
Supported Commands:

Navigation:
"Show me the kitchen"
"Go to the master bedroom"
"Take me to the backyard"
"Go back"
"Show all rooms"

Information:
"What's the square footage?"
"How much is this property?"
"What are the school ratings?"
"Show me the neighborhood"

Actions:
"Turn on staging"
"Turn off staging"
"Measure this wall"
"Take a screenshot"
"Share this property"
"Add to favorites"

Comparison:
"Compare to my saved properties"
"Show similar properties"

Response Format:
┌─────────────────────────────┐
│ 🎤 Voice Assistant          │
├─────────────────────────────┤
│ You: "Show me the kitchen"  │
│                             │
│ Assistant: "Taking you to   │
│ the kitchen now. This is a  │
│ 240 sq ft space with        │
│ granite countertops and     │
│ stainless appliances."      │
└─────────────────────────────┘

Position: Bottom left, expandable
Voice visualization: Audio waveform
```

---

## 6. Visual Design System

### 6.1 Color Palette

#### Primary Colors
```
Brand Primary:
- Estate Blue: #2C5F8D (Trust, professionalism)
- Usage: Primary buttons, links, accents

Brand Secondary:
- Warm Gold: #D4A574 (Luxury, warmth)
- Usage: Highlights, featured badges, CTAs

Success/Status:
- Success Green: #27AE60
- Warning Yellow: #F39C12
- Error Red: #E74C3C
- Info Blue: #3498DB
```

#### Neutral Colors
```
Backgrounds (Glass Materials):
- Glass Primary: White 10% opacity
- Glass Secondary: White 5% opacity
- Glass Tertiary: White 2% opacity

Text Colors:
- Primary Text: Black 100%
- Secondary Text: Black 70%
- Tertiary Text: Black 50%
- Disabled Text: Black 30%

Borders:
- Subtle Border: Black 10%
- Standard Border: Black 20%
- Strong Border: Black 40%
```

#### Semantic Colors
```
Property Status:
- Active: #27AE60 (Green)
- Pending: #F39C12 (Orange)
- Sold: #E74C3C (Red)
- Off Market: #95A5A6 (Gray)

Price Indicators:
- Price Increase: #E74C3C (Red)
- Price Decrease: #27AE60 (Green)
- No Change: Black 70%
```

### 6.2 Typography

#### Font System
```
Primary Font: SF Pro (San Francisco)
- Native to visionOS
- Optimized for spatial rendering
- Full Dynamic Type support

Type Scale:

Display (Hero text):
  - Size: 64pt
  - Weight: Bold
  - Use: Property prices, hero numbers

Title 1:
  - Size: 34pt
  - Weight: Bold
  - Use: Page titles, primary headings

Title 2:
  - Size: 28pt
  - Weight: Semibold
  - Use: Section headers

Title 3:
  - Size: 24pt
  - Weight: Semibold
  - Use: Card titles, subsection headers

Headline:
  - Size: 20pt
  - Weight: Semibold
  - Use: Emphasis text, important labels

Body:
  - Size: 17pt (default)
  - Weight: Regular
  - Use: Standard content, descriptions

Callout:
  - Size: 16pt
  - Weight: Regular
  - Use: Secondary information

Subheadline:
  - Size: 15pt
  - Weight: Regular
  - Use: Supporting text

Footnote:
  - Size: 13pt
  - Weight: Regular
  - Use: Captions, metadata

Caption 1:
  - Size: 12pt
  - Weight: Regular
  - Use: Timestamps, fine print

Caption 2:
  - Size: 11pt
  - Weight: Regular
  - Use: Legal text, disclaimers
```

#### Text Rendering for Spatial
```
Best Practices:
- Minimum size: 14pt for legibility
- Maximum line length: 60 characters
- Line height: 1.4x font size
- Letter spacing: Default (no adjustment needed)
- Contrast: WCAG AA minimum (4.5:1)

Spatial Considerations:
- Text always faces user
- Billboarding for 3D labels
- Distance-based scaling
- Anti-aliasing enabled
- Subpixel rendering off
```

### 6.3 Materials and Lighting

#### Glass Materials
```swift
Material Styles:

.regularMaterial
- Use: Main windows, primary panels
- Opacity: Adaptive to environment
- Vibrancy: Medium

.thinMaterial
- Use: Overlays, tooltips
- Opacity: Lower, more transparent
- Vibrancy: High

.ultraThinMaterial
- Use: HUDs, temporary overlays
- Opacity: Minimal
- Vibrancy: Maximum

.thickMaterial
- Use: Modals, important dialogs
- Opacity: Higher, more opaque
- Vibrancy: Low

Custom Materials:
- Property Cards: .regularMaterial + subtle shadow
- Buttons: .thinMaterial + hover glow
- Navigation: .ultraThinMaterial + auto-hide
```

#### Lighting System
```
Immersive Space Lighting:

Ambient Light:
- Color: Warm white (3000K)
- Intensity: 300 lux
- Source: Ceiling fixtures, windows

Directional Light:
- Color: Cool white (5000K)
- Intensity: 500 lux
- Source: Primary window/sun direction
- Shadows: Soft, realistic

Point Lights:
- Lamps and fixtures in scene
- Dynamic based on time of day
- Color temperature varies by source

Image-Based Lighting (IBL):
- HDR environment map
- Realistic reflections
- Ambient occlusion
```

### 6.4 Iconography

#### Icon System
```
Primary: SF Symbols
- Native to visionOS
- Scalable and crisp
- Color and weight variants

Icon Sizes:
- Small: 16×16 pt (inline text)
- Medium: 24×24 pt (buttons, lists)
- Large: 48×48 pt (features, empty states)
- Extra Large: 64×64 pt (hero graphics)

Custom Icons (Property-Specific):
🏠 Property type indicators
🛏️ Bedroom count
🛁 Bathroom count
📐 Square footage
💰 Price/financing
📍 Location/map
⭐ Favorites/saved
👁️ Virtual tour
📷 Photo gallery
📊 Analytics
🔧 Renovations
```

#### Icon Style
```
Design Guidelines:
- Stroke width: 2pt at 24×24 pt
- Rounded corners: 2pt radius
- Optical alignment, not geometric
- Consistent visual weight
- Outline style preferred
- Filled style for selected state

Color Usage:
- Default: Primary text color
- Active: Brand blue
- Disabled: 30% opacity
- Error: Error red
- Success: Success green
```

---

## 7. User Flows and Navigation

### 7.1 Primary User Journey: Home Buyer

```
Journey Map:

1. Browse Properties
   ├── Open app
   ├── View property grid
   ├── Apply filters (price, location, beds)
   ├── Scroll through results
   └── Spot interesting property

2. Property Details
   ├── Tap property card
   ├── New detail window opens
   ├── Review photos, specs
   ├── Check neighborhood data
   └── Calculate mortgage

3. Virtual Tour
   ├── Tap "Start Tour" button
   ├── Immersive space launches
   ├── Explore rooms via teleport
   ├── Measure walls for furniture
   ├── Toggle staging on/off
   └── Add notes

4. Decision Making
   ├── Save property to favorites
   ├── Share with partner/family
   ├── Schedule in-person visit
   └── Continue browsing or exit

Time Estimate: 15-20 minutes per property
Success Metric: Qualified leads (saved + scheduled)
```

### 7.2 Agent Workflow

```
Agent Daily Workflow:

Morning:
├── Open dashboard
├── Review today's schedule
├── Check new leads (8 overnight)
├── Respond to client messages
└── Prepare virtual tour presentations

Midday:
├── Conduct virtual open house
│   ├── Welcome participants (15 people)
│   ├── Guide through property
│   ├── Answer questions in real-time
│   ├── Share documents (inspection report)
│   └── Collect contact info
└── Follow up with interested buyers

Afternoon:
├── Upload new listing
│   ├── Import MLS data
│   ├── Add photos and 3D tour
│   ├── Configure staging options
│   └── Publish to platform
├── Review analytics
│   ├── Which properties getting views
│   ├── Client engagement scores
│   └── Showing conversion rates
└── Schedule tomorrow's appointments

Evening:
├── Check offer status
├── Update pipeline in CRM
└── Prepare next day

Time Savings: 10+ hours per week
Efficiency Gain: 3x more showings
```

### 7.3 Navigation Patterns

#### Window Management
```
Multi-Window Workflow:

Scenario: Agent showing property to client

┌──────────────┐         ┌──────────────┐
│ Dashboard    │         │ Property     │
│ (Main)       │         │ Detail       │
│              │         │              │
│ - Schedule   │◄───────►│ - Photos     │
│ - Clients    │         │ - Specs      │
│ - Analytics  │         │ - Docs       │
└──────────────┘         └──────────────┘
       │                        │
       │    ┌──────────────┐    │
       └───►│ 3D Floor     │◄───┘
            │ Plan Volume  │
            │              │
            └──────────────┘

User can:
- Arrange windows spatially
- Reference multiple views simultaneously
- Minimize/maximize as needed
- Quick switch with window picker
```

#### Depth-Based Navigation
```
Content Layers (Z-axis):

Far (3-5m):
└── Background context
    └── Neighborhood volume

Mid (1.5-3m):
└── Primary content
    ├── Browser window
    ├── Detail window
    └── Dashboard

Near (0.5-1.5m):
└── Active focus
    ├── Modal dialogs
    ├── Context menus
    └── Tooltips

Very Near (<0.5m):
└── Alerts and notifications
    └── System messages
```

---

## 8. Accessibility Design

### 8.1 VoiceOver Optimization

```
Screen Reader UX:

Property Card Announcement:
"Property at 123 Main Street, San Francisco.
 3 bedrooms, 2 bathrooms, 2,400 square feet.
 Listed at $850,000.
 Button. Double-tap to view details."

Navigation in Immersive Space:
"Current room: Living Room.
 25 feet by 18 feet.
 Available rooms: Kitchen, Master Bedroom, Bathroom.
 Swipe right to navigate options."

Action Feedback:
"Property saved to favorites."
"Virtual tour starting."
"Measurement tool active."
```

### 8.2 Alternative Interactions

```
For Limited Hand Mobility:

Head Tracking:
- Gaze-based selection (dwell time: 1 second)
- Head nod for confirm (accessibility setting)
- Shake head for cancel

Voice Control:
- All features accessible via voice
- Custom vocabulary for real estate terms
- Dictation for notes and messages

Switch Control:
- External switch support
- Sequential navigation
- Scan speed configurable
```

### 8.3 Visual Accommodations

```
Contrast Modes:

Standard Contrast:
- Text: Black on glass
- Buttons: Blue (#2C5F8D)
- Borders: Subtle (10% opacity)

Increased Contrast:
- Text: Pure black (#000000)
- Buttons: Darker blue (#1A3A57)
- Borders: Strong (40% opacity)
- Materials: Thicker, less transparent

Color Blind Modes:

Deuteranopia (Red-Green):
- Replace red/green indicators
- Use blue/yellow alternatives
- Add pattern fills

Tritanopia (Blue-Yellow):
- Replace blue/yellow indicators
- Use red/green alternatives
- Add texture overlays
```

### 8.4 Motion Sensitivity

```
Reduce Motion Settings:

Standard Animation:
- Smooth transitions (300ms)
- Parallax effects
- Bounce animations
- Particle effects

Reduced Motion:
- Instant transitions (0ms)
- No parallax
- Simple fades only
- No particles

Immersive Space:
- Teleport: Instant (no fade)
- Camera: No momentum
- Rotation: Snap to angles
```

---

## 9. Error States and Loading Indicators

### 9.1 Loading States

```
Progressive Loading:

Property List:
┌────────────────────┐
│ ▮▮▮▮▮▮            │ ← Skeleton loading
│ ▮▮▮▮              │    (shimmer animation)
│ ▮▮▮▮▮▮▮           │
└────────────────────┘
  ↓
┌────────────────────┐
│ [Photo]            │ ← Content appears
│ 3 bd, 2 ba         │    (fade in)
│ $850,000           │
└────────────────────┘

3D Model Loading:
1. Low-poly placeholder (instant)
2. Medium detail (2 seconds)
3. High detail textures (5 seconds)
4. Complete with lighting (8 seconds)

Progress Indicator:
┌─────────────────────────┐
│ Loading property tour... │
│ ▰▰▰▰▰▰▰▰▰▱▱▱▱▱▱ 60%     │
└─────────────────────────┘

Spinner (for indeterminate):
     ⟳   Loading...
```

### 9.2 Empty States

```
No Search Results:
┌───────────────────────────────┐
│                               │
│        🏠                      │
│                               │
│   No properties found         │
│                               │
│   Try adjusting your filters  │
│   or search in a different    │
│   location.                   │
│                               │
│   [Clear Filters]             │
│                               │
└───────────────────────────────┘

No Saved Properties:
┌───────────────────────────────┐
│                               │
│        ⭐                      │
│                               │
│   No saved properties yet     │
│                               │
│   Tap the heart icon on any   │
│   property to save it here.   │
│                               │
│   [Browse Properties]         │
│                               │
└───────────────────────────────┘

First Time User (Dashboard):
┌───────────────────────────────┐
│                               │
│        👋                      │
│                               │
│   Welcome to Real Estate      │
│   Spatial Platform!           │
│                               │
│   Let's get you started.      │
│                               │
│   [Take Tour] [Skip]          │
│                               │
└───────────────────────────────┘
```

### 9.3 Error States

```
Network Error:
┌───────────────────────────────┐
│        ⚠️                      │
│                               │
│   Connection Lost             │
│                               │
│   Check your internet         │
│   connection and try again.   │
│                               │
│   [Retry] [View Cached]       │
└───────────────────────────────┘

Asset Loading Failure:
┌───────────────────────────────┐
│        📦                      │
│                               │
│   Failed to Load 3D Model     │
│                               │
│   This property's 3D tour is  │
│   temporarily unavailable.    │
│                               │
│   [View Photos] [Retry]       │
└───────────────────────────────┘

Authentication Error:
┌───────────────────────────────┐
│        🔒                      │
│                               │
│   Session Expired             │
│                               │
│   Please sign in again to     │
│   continue.                   │
│                               │
│   [Sign In]                   │
└───────────────────────────────┘

Permission Denied:
┌───────────────────────────────┐
│        🚫                      │
│                               │
│   Location Access Required    │
│                               │
│   Enable location services to │
│   find properties near you.   │
│                               │
│   [Open Settings] [Skip]      │
└───────────────────────────────┘
```

### 9.4 Success States

```
Action Confirmation:
┌───────────────────────────────┐
│        ✓                       │
│   Property Saved!             │
└───────────────────────────────┘
(Auto-dismiss after 2 seconds)

Toast Notifications:
┌────────────────────────────┐
│ ✓ Tour link copied         │ (Top right)
│ ✓ Showing scheduled        │
│ ✓ Message sent to agent    │
└────────────────────────────┘
(Stack, auto-dismiss)
```

---

## 10. Animation and Transition Specifications

### 10.1 Window Transitions

```swift
Window Animations:

Open Window:
- Duration: 300ms
- Curve: easeOut
- Effect: Scale from 0.8 → 1.0, fade in
- Origin: From tapped element position

Close Window:
- Duration: 250ms
- Curve: easeIn
- Effect: Scale 1.0 → 0.9, fade out
- Destination: Toward close button

Minimize/Maximize:
- Duration: 400ms
- Curve: spring (response: 0.5, damping: 0.8)
- Effect: Smooth scale and position change
```

### 10.2 Immersive Space Transitions

```swift
Enter Immersive Space:
- Duration: 800ms total
  - Fade out windows: 200ms
  - Environment load: 400ms
  - Fade in environment: 200ms
- Effect: Gradual immersion increase
- Audio: Crossfade (400ms)

Exit Immersive Space:
- Duration: 600ms total
  - Fade out environment: 200ms
  - Environment unload: 200ms
  - Fade in windows: 200ms
- Effect: Return to previous state
- Audio: Crossfade to ambient
```

### 10.3 Room Teleportation

```swift
Teleport Animation:

Phase 1 - Fade Out (150ms):
- Screen opacity: 100% → 0%
- Curve: easeIn

Phase 2 - Camera Move (100ms):
- Position: Room A → Room B
- Instant move during fade

Phase 3 - Fade In (150ms):
- Screen opacity: 0% → 100%
- Curve: easeOut

Phase 4 - Settle (100ms):
- Subtle camera adjustment
- Spring animation

Total: 500ms

Audio:
- "Whoosh" sound (300ms)
- Spatial audio transition
- Room ambience crossfade
```

### 10.4 Gesture Feedback

```swift
Button Press:
- Hover: Scale 1.0 → 1.05 (100ms, easeOut)
- Press: Scale 1.05 → 0.98 (50ms, easeIn)
- Release: Scale 0.98 → 1.0 (150ms, spring)
- Haptic: Light tap on press

Card Selection:
- Hover: Elevation increase (200ms, easeOut)
         Glow opacity 0% → 30%
- Select: Scale 1.0 → 1.02 (100ms)
          Glow opacity 30% → 50%
- Deselect: Return to default (200ms, easeInOut)

Drag Object:
- Pick up: Scale 1.0 → 1.1 (100ms, easeOut)
- Dragging: Subtle float animation (continuous)
- Drop: Scale 1.1 → 1.0 (150ms, spring)
         Position snap (200ms, easeOut)
```

### 10.5 Loading Animations

```swift
Skeleton Loading:
- Shimmer effect travels left to right
- Duration: 1.5 seconds
- Repeat: Infinite
- Gradient:
  - Start: White 0%
  - Peak: White 40%
  - End: White 0%

Spinner:
- Rotation: 360° per second
- Smooth, continuous
- Color: Brand blue
- Size: 24pt × 24pt

Progress Bar:
- Fill animation: Linear
- Update interval: 100ms
- Smoothing: Spring interpolation
- Color: Brand blue → Green (as it completes)
```

### 10.6 Micro-interactions

```swift
Favorites Heart:
- Unfilled → Filled:
  - Scale burst: 1.0 → 1.3 → 1.0 (400ms)
  - Color: Gray → Red
  - Particle burst (10 small hearts)
  - Haptic: Medium impact

Toggle Switch:
- Off → On:
  - Thumb slide: 200ms, easeInOut
  - Background color: Gray → Green (200ms)
  - Haptic: Light tap

Photo Gallery Swipe:
- Swipe gesture recognized
- Current photo: Slide + fade out (250ms)
- Next photo: Slide + fade in (250ms)
- Parallax: Background slides slower
- Momentum: Respect gesture velocity
```

---

## 11. Responsive Design

### 11.1 Dynamic Window Sizing

```
Window Size Breakpoints:

Compact (800×600 pt):
- Single column layout
- Collapsed filter sidebar
- Stacked property cards
- Reduced margins

Regular (1200×800 pt):
- Two-column layout
- Visible filter sidebar
- Grid property cards (4 columns)
- Standard margins

Large (1600×1000 pt):
- Three-column layout
- Expanded filter sidebar with previews
- Grid property cards (5 columns)
- Generous margins
```

### 11.2 Text Scaling

```
Dynamic Type Support:

Base Size (Body):
- Standard: 17pt
- Large: 19pt
- XXL: 23pt
- XXXL: 28pt
- Accessibility 1: 34pt
- Accessibility 5: 53pt

Layout Adjustments:
- Lines break earlier at larger sizes
- Buttons expand vertically
- Spacing increases proportionally
- Images resize or reposition
- Truncation points adjust
```

---

## 12. Design Deliverables Checklist

```
✓ Color palette defined
✓ Typography system specified
✓ Icon library documented
✓ Window layouts designed
✓ Volume interactions defined
✓ Immersive experiences mapped
✓ Interaction patterns specified
✓ Animations documented
✓ Accessibility guidelines set
✓ Error states designed
✓ Loading states defined
✓ User flows mapped
✓ Navigation patterns established
```

---

## 13. Conclusion

This design specification provides comprehensive spatial UI/UX guidelines for the Real Estate Spatial Platform. The design prioritizes:

1. **Spatial Comfort**: Ergonomic placement, appropriate depth usage
2. **Progressive Complexity**: Simple windows → Volumes → Immersive
3. **Clarity**: High contrast, readable typography, clear affordances
4. **Accessibility**: VoiceOver, Dynamic Type, motion sensitivity
5. **Delight**: Smooth animations, haptic feedback, spatial audio

The design leverages visionOS's unique capabilities while maintaining professional real estate industry standards.

---

**Next Document**: IMPLEMENTATION_PLAN.md for development roadmap
