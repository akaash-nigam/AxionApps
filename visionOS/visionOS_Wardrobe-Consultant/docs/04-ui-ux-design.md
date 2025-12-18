# UI/UX Design & Spatial Interface Specifications

## Document Overview

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Draft

## 1. Executive Summary

This document defines the user interface, user experience, and spatial computing design for Wardrobe Consultant on visionOS. The design leverages Apple Vision Pro's unique capabilities including spatial computing, eye tracking, hand gestures, and immersive AR to create an intuitive fashion consultation experience.

## 2. Design Philosophy

### 2.1 Core Principles

**Spatial-First Design**:
- Information floats naturally in 3D space
- UI elements positioned for ergonomic comfort
- Depth used to communicate hierarchy and context

**Minimalist Elegance**:
- Fashion-forward aesthetic with clean lines
- Content takes precedence over chrome
- Subtle animations and transitions

**Effortless Interaction**:
- Natural gestures (look, tap, pinch)
- Voice commands for complex tasks
- Minimal cognitive load

**Privacy & Comfort**:
- Personal data never visible to bystanders
- Comfortable viewing angles
- Non-intrusive notifications

### 2.2 visionOS Design Guidelines

- Follow Apple's Human Interface Guidelines for visionOS
- Use native visionOS components (ornaments, windows, volumes)
- Maintain spatial awareness (avoid cluttering space)
- Respect user's physical environment

## 3. Visual Design System

### 3.1 Color Palette

**Primary Colors**:
```swift
struct AppColors {
    // Primary
    static let roseGold = Color(hex: "#E5C5B5")
    static let charcoal = Color(hex: "#333333")

    // Accent
    static let blushPink = Color(hex: "#FFB6C1")
    static let softGreen = Color(hex: "#A8D8B9")

    // Neutrals
    static let cream = Color(hex: "#FAF9F6")
    static let lightGray = Color(hex: "#E8E8E8")
    static let darkGray = Color(hex: "#666666")

    // System
    static let success = Color(hex: "#4CAF50")
    static let warning = Color(hex: "#FF9800")
    static let error = Color(hex: "#F44336")
}
```

**Color Usage**:
- Background: Cream/Glass (semi-transparent)
- Primary actions: Rose Gold
- Secondary actions: Charcoal
- Success states: Soft Green
- Highlights: Blush Pink

### 3.2 Typography

**Font System**:
```swift
struct AppFonts {
    // Headers (Fashion-forward)
    static let heroTitle = Font.custom("Bodoni 72", size: 48)
    static let largeTitle = Font.custom("Bodoni 72", size: 34)
    static let title = Font.custom("Bodoni 72", size: 28)

    // Body (System, readable)
    static let headline = Font.system(.headline, design: .default)
    static let body = Font.system(.body, design: .default)
    static let caption = Font.system(.caption, design: .default)

    // Monospaced (Technical data)
    static let monospaced = Font.system(.body, design: .monospaced)
}
```

**Typography Scale**:
- Hero Title: 48pt (Main screen headers)
- Large Title: 34pt (Section headers)
- Title: 28pt (Card headers)
- Headline: 17pt (Important labels)
- Body: 17pt (Default text)
- Caption: 12pt (Metadata)

### 3.3 Spacing & Layout

**Spatial Grid**:
```swift
struct Spacing {
    static let xs: CGFloat = 4      // Tight spacing
    static let sm: CGFloat = 8      // Small spacing
    static let md: CGFloat = 16     // Default spacing
    static let lg: CGFloat = 24     // Large spacing
    static let xl: CGFloat = 32     // Extra large spacing
    static let xxl: CGFloat = 48    // Hero spacing
}

struct DepthLayers {
    static let background: Float = 0     // Back wall
    static let content: Float = 100      // Main content
    static let elevated: Float = 200     // Cards, panels
    static let overlay: Float = 300      // Modals, sheets
    static let floating: Float = 400     // Tooltips, popovers
}
```

**Component Sizing**:
- Window default: 800x600pt
- Card: 300x400pt
- Outfit preview: 600x800pt (portrait)
- Thumbnail: 100x100pt

### 3.4 Iconography

**SF Symbols Usage**:
```swift
struct AppIcons {
    // Navigation
    static let home = "house.fill"
    static let wardrobe = "tshirt.fill"
    static let outfits = "square.grid.3x3.fill"
    static let shopping = "bag.fill"
    static let settings = "gearshape.fill"

    // Actions
    static let add = "plus.circle.fill"
    static let edit = "pencil.circle.fill"
    static let delete = "trash.fill"
    static let share = "square.and.arrow.up"
    static let favorite = "heart.fill"
    static let favoriteOutline = "heart"

    // Weather
    static let sunny = "sun.max.fill"
    static let cloudy = "cloud.fill"
    static let rainy = "cloud.rain.fill"
    static let snowy = "cloud.snow.fill"

    // Context
    static let calendar = "calendar"
    static let location = "location.fill"
    static let time = "clock.fill"
}
```

### 3.5 Visual Effects

**Glass Materials**:
```swift
// Primary glass (windows, panels)
.background(.ultraThinMaterial)

// Elevated glass (cards)
.background(.thinMaterial)

// Overlay glass (modals)
.background(.regularMaterial)
```

**Shadows & Depth**:
```swift
// Subtle elevation
.shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)

// Strong elevation
.shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)

// Glow effect (for interactive elements)
.shadow(color: AppColors.roseGold.opacity(0.5), radius: 15)
```

## 4. Spatial Layout Architecture

### 4.1 Window Types

**Primary Window** (Main UI):
- Type: Window
- Default size: 800x600pt
- Resizable: Yes
- Position: Center of user's view
- Content: Main navigation, outfit browser

**Virtual Mirror** (Immersive):
- Type: Full Immersive Space
- Content: AR body tracking + clothing overlay
- Controls: Floating ornaments
- Background: Passthrough

**Wardrobe Volume**:
- Type: Volume (3D)
- Size: 1000x1000x500pt (width x height x depth)
- Content: Spatial grid of clothing items
- Interaction: Walk around, zoom in

### 4.2 Main Window Layout

```
┌──────────────────────────────────────────────────────┐
│  [App Icon]  Wardrobe Consultant         [Settings]  │  ← Title Bar
├──────────────────────────────────────────────────────┤
│                                                       │
│  ┌────────┐  Good morning, User!                    │  ← Context Bar
│  │Weather │  72°F, Sunny                            │
│  │ Icon   │  Meeting at 2PM (Business Casual)       │
│  └────────┘                                          │
│                                                       │
│  ┌────────────────────────────────────────────────┐ │
│  │         Outfit Suggestions for Today           │ │  ← Main Content
│  │                                                 │ │
│  │  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐      │ │
│  │  │      │  │      │  │      │  │      │      │ │
│  │  │  1   │  │  2   │  │  3   │  │  4   │  →   │ │
│  │  │      │  │      │  │      │  │      │      │ │
│  │  └──────┘  └──────┘  └──────┘  └──────┘      │ │
│  │                                                 │ │
│  │  [Try On]  [View Details]  [Save]              │ │
│  └────────────────────────────────────────────────┘ │
│                                                       │
│  ┌────────────────────────────────────────────────┐ │
│  │  Your Wardrobe                                  │ │  ← Quick Access
│  │  [View All]  [Add Item]                        │ │
│  └────────────────────────────────────────────────┘ │
│                                                       │
└──────────────────────────────────────────────────────┘
```

### 4.3 Virtual Mirror Layout (Immersive Space)

```
User's View (First Person):

                    [X Close]  [Settings]
                         ↑
                   Floating Controls


        ┌──────────────────────────┐
        │  Outfit Selection         │
        │  ┌────┐ ┌────┐ ┌────┐   │
        │  │ 1  │ │ 2  │ │ 3  │   │
        │  └────┘ └────┘ └────┘   │
        └──────────────────────────┘
               ↑
         Floating Panel (Left)


                  USER (Passthrough)
                  Clothing Overlay
                  on Body


        ┌──────────────────────────┐
        │  Current Outfit           │
        │                           │
        │  • Blue Shirt             │
        │  • Khaki Pants            │
        │  • Brown Shoes            │
        │                           │
        │  [Accessories]            │
        └──────────────────────────┘
               ↑
         Floating Panel (Right)
```

### 4.4 Wardrobe Volume Layout (3D Space)

```
Top View:

  User Position
       ↓
       👤
       │
       │
   ┌───┼────────────────────────┐
   │   │                        │
   │   │    ┌───┐  ┌───┐        │
   │ ┌─┼─┐  │   │  │   │        │
   │ │ │ │  │ 5 │  │ 6 │        │
   │ │ │ │  └───┘  └───┘        │
   │ │1│2│                      │
   │ │ │ │  ┌───┐  ┌───┐        │
   │ └─┼─┘  │   │  │   │        │
   │   │    │ 7 │  │ 8 │        │
   │ ┌─┼─┐  └───┘  └───┘        │
   │ │ │ │                      │
   │ │3│4│  ... more items      │
   │ │ │ │                      │
   │ └───┘                      │
   └────────────────────────────┘

- Items arranged in spatial grid
- User can walk around
- Look at item → Details appear
- Tap to select
```

## 5. Navigation & Information Architecture

### 5.1 App Structure

```
Root
├── Home (Landing)
│   ├── Today's Suggestions
│   ├── Weather Context
│   └── Calendar Events
│
├── Virtual Try-On (Immersive)
│   ├── Body Tracking
│   ├── Outfit Preview
│   └── Customization
│
├── Wardrobe (Volume)
│   ├── All Items
│   ├── Categories
│   │   ├── Tops
│   │   ├── Bottoms
│   │   ├── Dresses
│   │   └── Accessories
│   ├── Search & Filter
│   └── Add Item
│
├── Outfits (Window)
│   ├── Saved Outfits
│   ├── Recent Outfits
│   ├── Favorites
│   └── Create New
│
├── Shopping (Window)
│   ├── Wishlist
│   ├── Virtual Try-On (Products)
│   └── Price Tracking
│
└── Settings (Window)
    ├── Profile & Measurements
    ├── Style Preferences
    ├── Integrations
    └── Privacy
```

### 5.2 Navigation Patterns

**Tab Bar** (Main Window):
```swift
TabView {
    HomeView()
        .tabItem {
            Label("Home", systemImage: "house.fill")
        }

    WardrobeView()
        .tabItem {
            Label("Wardrobe", systemImage: "tshirt.fill")
        }

    OutfitsView()
        .tabItem {
            Label("Outfits", systemImage: "square.grid.3x3.fill")
        }

    ShoppingView()
        .tabItem {
            Label("Shopping", systemImage: "bag.fill")
        }
}
```

**Immersive Space Trigger**:
```swift
Button("Try On") {
    openImmersiveSpace(id: "virtualMirror")
}
.buttonStyle(.borderedProminent)
.tint(AppColors.roseGold)
```

## 6. Interaction Design

### 6.1 Gesture Patterns

**Look + Tap** (Primary):
- Look at interactive element (highlights)
- Tap fingers together to select
- Visual feedback: Glow effect on hover

**Pinch + Drag** (Manipulation):
- Pinch and hold object
- Drag to move in space
- Release to drop

**Two-Hand Resize**:
- Pinch with both hands on corners
- Move hands apart/together to resize
- Works on windows and volumes

**Swipe** (Navigation):
- Horizontal swipe: Next/previous item
- Vertical swipe: Scroll content

### 6.2 Hover States

```swift
// Interactive element hover effect
.hoverEffect(.highlight)
.hoverEffect(.lift) // For 3D objects

// Custom hover state
struct OutfitCard: View {
    @State private var isHovered = false

    var body: some View {
        VStack {
            // Card content
        }
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .shadow(radius: isHovered ? 20 : 10)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
```

### 6.3 Voice Commands

**Supported Commands**:
```swift
enum VoiceCommand: String {
    case showWorkOutfits = "Show me work outfits"
    case tryOnBlue = "Try on that blue dress"
    case whatToWear = "What should I wear today?"
    case addShirt = "Add this shirt to my wardrobe"
    case planTrip = "Plan outfits for my trip to Paris"
    case findWedding = "Find an outfit for the wedding"
    case showFavorites = "Show my favorite outfits"
    case weatherCheck = "What's the weather today?"
}
```

**Implementation**:
```swift
import Speech

class VoiceCommandHandler: ObservableObject {
    private let speechRecognizer = SFSpeechRecognizer()

    func processCommand(_ text: String) {
        let lowercased = text.lowercased()

        if lowercased.contains("work outfit") {
            // Navigate to work outfits
        } else if lowercased.contains("try on") {
            // Open virtual try-on
        }
        // ... other commands
    }
}
```

### 6.4 Feedback & Affordances

**Visual Feedback**:
- Hover: Subtle glow, slight scale increase
- Tap: Quick flash, haptic feedback
- Loading: Animated spinner or skeleton UI
- Success: Green checkmark, success animation
- Error: Red shake animation, error message

**Spatial Audio**:
- Tap: Subtle click sound
- Success: Pleasant chime
- Error: Gentle error tone
- Transition: Whoosh sound

**Haptic Feedback** (via paired devices):
- Tap: Light impact
- Selection: Selection feedback
- Error: Notification feedback

## 7. Key Screen Designs

### 7.1 Home Screen

**Purpose**: Daily landing page with contextual suggestions.

**Layout**:
```swift
struct HomeView: View {
    @StateObject var viewModel: HomeViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Header with greeting and context
                ContextHeaderView(
                    greeting: "Good morning, Sarah!",
                    weather: viewModel.weather,
                    events: viewModel.todayEvents
                )

                // Primary CTA
                TryOnButtonView {
                    openImmersiveSpace(id: "virtualMirror")
                }

                // Outfit suggestions
                OutfitSuggestionsCarouselView(
                    outfits: viewModel.suggestions
                )

                // Quick actions
                QuickActionsView()

                // Recent activity
                RecentActivityView(
                    recentOutfits: viewModel.recentOutfits
                )
            }
            .padding()
        }
    }
}
```

**Components**:

```swift
struct ContextHeaderView: View {
    let greeting: String
    let weather: CurrentWeather?
    let events: [CalendarEventDTO]

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Weather icon
            if let weather = weather {
                WeatherIconView(condition: weather.condition)
                    .frame(width: 80, height: 80)
            }

            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text(greeting)
                    .font(AppFonts.largeTitle)
                    .foregroundColor(AppColors.charcoal)

                if let weather = weather {
                    Text("\(Int(weather.temperature.value))°F, \(weather.condition.description)")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.darkGray)
                }

                if let event = events.first {
                    HStack {
                        Image(systemName: AppIcons.calendar)
                        Text("\(event.title) at \(event.startDate.formatted(.dateTime.hour().minute()))")
                    }
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.blushPink)
                }
            }

            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
}
```

### 7.2 Virtual Try-On (Immersive)

**Purpose**: AR preview of outfits on user's body.

**Implementation**:
```swift
struct VirtualTryOnView: View {
    @StateObject var viewModel: VirtualTryOnViewModel
    @State private var selectedOutfit: Outfit?

    var body: some View {
        RealityView { content in
            // Setup AR scene with body tracking
            let arView = await viewModel.setupARScene()
            content.add(arView)
        } update: { content in
            // Update clothing overlay when outfit changes
            if let outfit = selectedOutfit {
                viewModel.applyOutfit(outfit)
            }
        }
        .overlay(alignment: .topLeading) {
            // Outfit selection panel
            OutfitSelectionPanel(
                outfits: viewModel.availableOutfits,
                selected: $selectedOutfit
            )
            .padding()
        }
        .overlay(alignment: .topTrailing) {
            // Current outfit details
            CurrentOutfitPanel(outfit: selectedOutfit)
                .padding()
        }
        .overlay(alignment: .top) {
            // Controls
            ControlsBar {
                Button("Close") {
                    dismissImmersiveSpace()
                }
                Button("Save") {
                    viewModel.saveOutfit(selectedOutfit)
                }
            }
            .padding()
        }
    }
}
```

### 7.3 Wardrobe View (Volume)

**Purpose**: Browse entire wardrobe in 3D space.

**Implementation**:
```swift
struct WardrobeVolumeView: View {
    @StateObject var viewModel: WardrobeViewModel
    @State private var selectedItem: WardrobeItem?

    var body: some View {
        RealityView { content in
            // Create 3D grid of wardrobe items
            let volume = await viewModel.createWardrobeVolume()
            content.add(volume)
        }
        .toolbar {
            ToolbarItemGroup {
                CategoryFilterMenu(
                    selectedCategory: $viewModel.filterCategory
                )
                ColorFilterMenu(
                    selectedColor: $viewModel.filterColor
                )
                Button("Add Item", systemImage: AppIcons.add) {
                    viewModel.showAddItemSheet = true
                }
            }
        }
        .sheet(isPresented: $viewModel.showAddItemSheet) {
            AddWardrobeItemView()
        }
        .ornament(attachmentAnchor: .scene(.bottom)) {
            // Item details panel
            if let item = selectedItem {
                ItemDetailsPanel(item: item)
            }
        }
    }
}
```

### 7.4 Outfit Details View

**Purpose**: View and edit outfit details.

```swift
struct OutfitDetailsView: View {
    let outfit: Outfit
    @State private var isEditing = false

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Outfit preview image
                OutfitPreviewImage(outfit: outfit)
                    .frame(height: 400)
                    .cornerRadius(20)

                // Outfit info
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Text(outfit.name ?? "Untitled Outfit")
                        .font(AppFonts.title)

                    HStack {
                        Label(outfit.occasionType.rawValue.capitalized,
                              systemImage: AppIcons.calendar)
                        Spacer()
                        Label("\(outfit.timesWorn) times worn",
                              systemImage: "checkmark.circle")
                    }
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.darkGray)

                    Divider()

                    // Items in outfit
                    Text("Items")
                        .font(AppFonts.headline)

                    ForEach(Array(outfit.items)) { item in
                        WardrobeItemRow(item: item)
                    }
                }
                .padding()

                // Actions
                HStack(spacing: Spacing.md) {
                    Button("Try On") {
                        // Open virtual try-on
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Edit") {
                        isEditing = true
                    }
                    .buttonStyle(.bordered)

                    Button(action: { /* Delete */ }) {
                        Image(systemName: AppIcons.delete)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
                .padding()
            }
        }
        .sheet(isPresented: $isEditing) {
            EditOutfitView(outfit: outfit)
        }
    }
}
```

## 8. Animations & Transitions

### 8.1 View Transitions

```swift
// Fade in/out
.transition(.opacity)

// Slide from edge
.transition(.move(edge: .trailing))

// Scale with fade
.transition(.scale.combined(with: .opacity))

// Custom spring animation
.animation(.spring(response: 0.3, dampingFraction: 0.7), value: isVisible)
```

### 8.2 Loading States

```swift
struct LoadingStateView: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: Spacing.md) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Loading your wardrobe...")
                .font(AppFonts.caption)
                .foregroundColor(AppColors.darkGray)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
}
```

### 8.3 Micro-Interactions

```swift
// Heart icon favorite animation
struct FavoriteButton: View {
    @Binding var isFavorite: Bool
    @State private var animateScale = false

    var body: some View {
        Button {
            isFavorite.toggle()
            animateScale = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                animateScale = false
            }
        } label: {
            Image(systemName: isFavorite ? AppIcons.favorite : AppIcons.favoriteOutline)
                .foregroundColor(isFavorite ? .red : AppColors.darkGray)
                .scaleEffect(animateScale ? 1.3 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: animateScale)
        }
    }
}
```

## 9. Accessibility

### 9.1 VoiceOver Support

```swift
// Meaningful labels
Image(systemName: "heart.fill")
    .accessibilityLabel("Favorite")
    .accessibilityAddTraits(.isButton)

// State descriptions
Button("Try On") {
    // ...
}
.accessibilityHint("Opens virtual try-on view with AR")

// Dynamic content
Text("\(outfit.timesWorn)")
    .accessibilityLabel("Worn \(outfit.timesWorn) times")
```

### 9.2 Reduced Motion

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

var animation: Animation {
    reduceMotion ? .none : .spring()
}
```

### 9.3 Contrast & Readability

- Minimum contrast ratio: 4.5:1 for body text
- 3:1 for large text (>18pt)
- Support for increased contrast mode
- Dynamic Type support

## 10. Responsive Design

### 10.1 Window Sizing

```swift
.defaultSize(width: 800, height: 600, depth: 100)
.windowResizability(.contentSize) // or .automatic
```

### 10.2 Adaptive Layouts

```swift
// Adjust based on available space
GeometryReader { geometry in
    if geometry.size.width > 600 {
        // Wide layout (side-by-side)
        HStack {
            OutfitList()
            OutfitDetails()
        }
    } else {
        // Narrow layout (stacked)
        VStack {
            OutfitList()
        }
    }
}
```

## 11. Empty States & Onboarding

### 11.1 Empty Wardrobe

```swift
struct EmptyWardrobeView: View {
    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "tshirt")
                .font(.system(size: 80))
                .foregroundColor(AppColors.lightGray)

            Text("Your Wardrobe is Empty")
                .font(AppFonts.title)

            Text("Add your first clothing item to get personalized outfit suggestions")
                .font(AppFonts.body)
                .foregroundColor(AppColors.darkGray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Add Your First Item") {
                // Open add item flow
            }
            .buttonStyle(.borderedProminent)
            .tint(AppColors.roseGold)
        }
        .padding()
    }
}
```

### 11.2 Onboarding Tooltips

```swift
// First-time user hints
.popover(isPresented: $showHint) {
    VStack(alignment: .leading, spacing: Spacing.sm) {
        Text("👋 Welcome!")
            .font(AppFonts.headline)

        Text("Look at an outfit and tap to try it on")
            .font(AppFonts.body)

        Button("Got it") {
            showHint = false
        }
    }
    .padding()
}
```

## 12. Design Specifications Summary

| Element | Specification |
|---------|---------------|
| Primary window size | 800x600pt |
| Corner radius | 20pt (large), 12pt (medium), 8pt (small) |
| Default padding | 16pt |
| Card elevation | 10-20pt shadow |
| Animation duration | 0.2-0.3s (quick), 0.5s (standard) |
| Icon size | 20pt (small), 24pt (medium), 32pt (large) |
| Touch target | Minimum 44x44pt |
| Glass material | .ultraThinMaterial |

## 13. Next Steps

- ✅ UI/UX design specifications complete
- ⬜ Create Figma/Sketch mockups
- ⬜ Build component library in SwiftUI
- ⬜ Prototype key interactions
- ⬜ User testing with Vision Pro
- ⬜ Iterate based on feedback

---

**Document Status**: Draft - Ready for Review
**Next Document**: AR/3D Rendering Technical Specification
