# UI/UX & Design System

## Overview

This document defines the user interface, user experience patterns, and design system for Physical-Digital Twins on visionOS. The app leverages spatial computing paradigms while maintaining familiarity and usability.

## visionOS Design Principles

1. **Spatial First**: Content exists in 3D space, not just 2D screens
2. **Depth and Dimensionality**: Use z-axis for hierarchy
3. **Eye and Hand Interaction**: Gaze + pinch as primary input
4. **Familiar Yet New**: iOS patterns adapted for spatial computing
5. **Comfort**: Avoid eye strain, respect personal space
6. **Context Aware**: Adapt to user's physical environment

## App Structure

### Navigation Model

```
┌─────────────────────────────────────────┐
│         Main Window (2D)                │
│  ┌──────────────────────────────────┐  │
│  │  Tab Bar Navigation              │  │
│  │  ┌─────┬─────┬─────┬─────────┐  │  │
│  │  │Home │Scan │Inven│Settings │  │  │
│  │  └─────┴─────┴─────┴─────────┘  │  │
│  └──────────────────────────────────┘  │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│    Immersive Space (Scanning)           │
│                                         │
│   [Physical objects with AR overlays]   │
│                                         │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│    Volume (3D Assembly Instructions)    │
│                                         │
│   [3D furniture model with highlights]  │
│                                         │
└─────────────────────────────────────────┘
```

### Primary Views

#### 1. Home View (Window)

```swift
struct HomeView: View {
    @Environment(AppState.self) private var appState
    @State private var recentItems: [InventoryItem] = []
    @State private var expiringFood: [FoodTwin] = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Quick stats
                    StatsCard(
                        totalItems: appState.inventory.items.count,
                        totalValue: appState.inventory.totalValue,
                        expiringCount: expiringFood.count
                    )

                    // Expiring food alert
                    if !expiringFood.isEmpty {
                        ExpiringFoodSection(items: expiringFood)
                    }

                    // Recent items
                    RecentItemsSection(items: recentItems)

                    // Quick actions
                    QuickActionsSection()
                }
                .padding()
            }
            .navigationTitle("Physical-Digital Twins")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Scan", systemImage: "viewfinder") {
                        openImmersiveSpace(id: "scanning")
                    }
                }
            }
        }
    }
}
```

#### 2. Scanning View (Immersive Space)

```swift
struct ScanningSpaceView: View {
    @Environment(AppState.self) private var appState
    @State private var scanningViewModel = ScanningViewModel()

    var body: some View {
        RealityView { content in
            // Set up RealityKit scene
            let scene = createScanningScene()
            content.add(scene)
        } update: { content in
            // Update AR content based on recognition
            updateRecognizedObjects(in: content)
        }
        .overlay(alignment: .top) {
            // Scanning UI overlay
            ScanningOverlay(viewModel: scanningViewModel)
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    handleTap(on: value.entity)
                }
        )
    }
}

struct ScanningOverlay: View {
    @Bindable var viewModel: ScanningViewModel

    var body: some View {
        VStack {
            if viewModel.isProcessing {
                HStack {
                    ProgressView()
                    Text("Recognizing object...")
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
            }

            if let result = viewModel.recognitionResult {
                RecognitionResultCard(result: result)
                    .transition(.scale.combined(with: .opacity))
            }

            Spacer()

            // Instructions
            Text("Point at an object to identify it")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(8)
        }
        .padding()
    }
}
```

#### 3. Inventory View (Window)

```swift
struct InventoryView: View {
    @Environment(AppState.self) private var appState
    @State private var searchText = ""
    @State private var selectedCategory: ObjectCategory?
    @State private var sortOrder: SortOrder = .dateAdded

    var body: some View {
        NavigationSplitView {
            // Sidebar: Categories
            List(selection: $selectedCategory) {
                Label("All Items", systemImage: "square.grid.2x2")
                    .tag(nil as ObjectCategory?)

                Section("Categories") {
                    ForEach(ObjectCategory.allCases, id: \.self) { category in
                        Label(category.displayName, systemImage: category.iconName)
                            .tag(category as ObjectCategory?)
                            .badge(count(for: category))
                    }
                }

                Section("Smart Lists") {
                    Label("Expiring Soon", systemImage: "clock.badge.exclamationmark")
                    Label("Recently Added", systemImage: "clock")
                    Label("Favorites", systemImage: "star.fill")
                    Label("Lent Items", systemImage: "arrow.uturn.forward")
                }
            }
            .navigationTitle("Inventory")
        } detail: {
            // Main content: Item grid/list
            ItemListView(
                category: selectedCategory,
                searchText: searchText,
                sortOrder: sortOrder
            )
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem {
                    Menu("Sort", systemImage: "arrow.up.arrow.down") {
                        Picker("Sort By", selection: $sortOrder) {
                            Text("Date Added").tag(SortOrder.dateAdded)
                            Text("Name").tag(SortOrder.name)
                            Text("Value").tag(SortOrder.value)
                            Text("Category").tag(SortOrder.category)
                        }
                    }
                }
            }
        }
    }

    private func count(for category: ObjectCategory) -> Int {
        appState.inventory.items.filter { $0.digitalTwin.objectType == category }.count
    }
}
```

## Design System

### Typography

```swift
extension Font {
    // visionOS optimized typography
    static let displayLarge = Font.system(size: 48, weight: .bold)
    static let displayMedium = Font.system(size: 36, weight: .semibold)
    static let headlineLarge = Font.system(size: 24, weight: .semibold)
    static let headlineMedium = Font.system(size: 20, weight: .medium)
    static let body = Font.system(size: 17, weight: .regular)
    static let bodyEmphasized = Font.system(size: 17, weight: .semibold)
    static let caption = Font.system(size: 14, weight: .regular)
    static let captionEmphasized = Font.system(size: 14, weight: .medium)
}
```

### Colors

```swift
extension Color {
    // Brand colors
    static let primary = Color("Primary") // Custom blue
    static let secondary = Color("Secondary") // Custom gray
    static let accent = Color.accentColor

    // Semantic colors
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    static let info = Color.blue

    // Object category colors
    static func categoryColor(_ category: ObjectCategory) -> Color {
        switch category {
        case .book: return .blue
        case .food: return .green
        case .furniture: return .brown
        case .electronics: return .purple
        case .clothing: return .pink
        case .games: return .red
        case .tools: return .orange
        case .plants: return .mint
        case .unknown: return .gray
        }
    }

    // Freshness colors
    static let fresh = Color.green
    static let useSoon = Color.yellow
    static let useToday = Color.orange
    static let expired = Color.red
}
```

### Spacing

```swift
enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}
```

### Materials & Depth

```swift
extension Material {
    // visionOS glass materials
    static let cardBackground: Material = .ultraThinMaterial
    static let overlayBackground: Material = .thinMaterial
    static let solidBackground: Material = .regularMaterial
}

// Depth levels for z-positioning
enum DepthLevel {
    static let background: Float = -0.5
    static let content: Float = 0.0
    static let elevated: Float = 0.1
    static let overlay: Float = 0.2
    static let modal: Float = 0.3
}
```

## Component Library

### 1. Digital Twin Card

```swift
struct DigitalTwinCardView: View {
    let twin: any DigitalTwin
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    categoryIcon
                    Text(twin.displayName)
                        .font(.headline)
                        .lineLimit(2)
                    Spacer()
                }

                // Content (varies by type)
                twinContent

                Spacer()

                // Footer
                HStack {
                    Text("Added \(twin.createdAt, style: .relative)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding()
            .frame(width: 280, height: 200)
            .background(.ultraThinMaterial)
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
        .hoverEffect()
    }

    @ViewBuilder
    private var categoryIcon: some View {
        Image(systemName: twin.objectType.iconName)
            .font(.title2)
            .foregroundStyle(Color.categoryColor(twin.objectType))
    }

    @ViewBuilder
    private var twinContent: some View {
        if let book = twin as? BookTwin {
            BookCardContent(book: book)
        } else if let food = twin as? FoodTwin {
            FoodCardContent(food: food)
        } else {
            GenericCardContent(twin: twin)
        }
    }
}
```

### 2. Expiration Badge

```swift
struct ExpirationBadge: View {
    let expirationDate: Date?
    let status: FreshnessStatus

    var body: some View {
        if let expirationDate = expirationDate {
            HStack(spacing: 4) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)

                Text(expirationText)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .cornerRadius(8)
        }
    }

    private var statusColor: Color {
        switch status {
        case .fresh: return .fresh
        case .useSoon: return .useSoon
        case .useToday: return .useToday
        case .expired: return .expired
        }
    }

    private var expirationText: String {
        guard let date = expirationDate else { return "No expiration" }

        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0

        if days < 0 {
            return "Expired"
        } else if days == 0 {
            return "Expires today"
        } else if days == 1 {
            return "Expires tomorrow"
        } else {
            return "Expires in \(days) days"
        }
    }
}
```

### 3. Quick Stats Card

```swift
struct StatsCard: View {
    let totalItems: Int
    let totalValue: Decimal
    let expiringCount: Int

    var body: some View {
        HStack(spacing: 16) {
            StatItem(
                title: "Total Items",
                value: "\(totalItems)",
                icon: "square.stack.3d.up",
                color: .blue
            )

            Divider()

            StatItem(
                title: "Total Value",
                value: formatCurrency(totalValue),
                icon: "dollarsign.circle",
                color: .green
            )

            if expiringCount > 0 {
                Divider()

                StatItem(
                    title: "Expiring Soon",
                    value: "\(expiringCount)",
                    icon: "clock.badge.exclamationmark",
                    color: .orange
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(color)

            Text(value)
                .font(.title2)
                .fontWeight(.semibold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
```

## Interaction Patterns

### 1. Hover Effects

```swift
extension View {
    func cardHoverEffect() -> some View {
        self.hoverEffect(.highlight)
            .hoverEffectDisabled(false)
    }
}
```

### 2. Contextual Menus

```swift
struct ItemContextMenu: View {
    let item: InventoryItem

    var body: some View {
        Button("View Details", systemImage: "info.circle") {
            showDetails(item)
        }

        Button("Edit", systemImage: "pencil") {
            editItem(item)
        }

        Divider()

        if item.isLent {
            Button("Mark as Returned", systemImage: "arrow.uturn.backward") {
                markAsReturned(item)
            }
        } else {
            Button("Lend to Someone", systemImage: "arrow.uturn.forward") {
                lendItem(item)
            }
        }

        Button("Add to Favorites", systemImage: "star") {
            toggleFavorite(item)
        }

        Divider()

        Button("Delete", systemImage: "trash", role: .destructive) {
            deleteItem(item)
        }
    }
}
```

### 3. Onboarding Flow

```swift
struct OnboardingView: View {
    @State private var currentStep = 0
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        TabView(selection: $currentStep) {
            OnboardingStep(
                title: "Welcome",
                description: "Create digital twins for every physical object",
                image: "cube.transparent",
                step: 0
            )

            OnboardingStep(
                title: "Scan Objects",
                description: "Point at any object to identify and catalog it",
                image: "viewfinder",
                step: 1
            )

            OnboardingStep(
                title: "Track Everything",
                description: "Monitor expiration dates, warranties, and more",
                image: "clock.badge",
                step: 2
            )

            OnboardingStep(
                title: "Get Started",
                description: "Ready to enhance your physical world?",
                image: "checkmark.circle",
                step: 3
            )
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .overlay(alignment: .bottom) {
            Button(currentStep == 3 ? "Get Started" : "Next") {
                if currentStep == 3 {
                    dismiss()
                } else {
                    withAnimation {
                        currentStep += 1
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
    }
}
```

## Accessibility

### 1. VoiceOver Labels

```swift
extension DigitalTwinCardView {
    var accessibilityLabel: String {
        "\(twin.objectType.displayName): \(twin.displayName)"
    }

    var accessibilityHint: String {
        "Double tap to view details"
    }
}
```

### 2. Dynamic Type Support

```swift
extension View {
    func responsiveText() -> some View {
        self.dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }
}
```

### 3. Reduced Motion

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion

var animation: Animation? {
    reduceMotion ? nil : .easeInOut
}
```

## Dark Mode

```swift
// Automatic adaptation to system appearance
// Custom adjustments for spatial UI
extension Color {
    static let cardBackground = Color(
        light: Color.white.opacity(0.9),
        dark: Color.black.opacity(0.7)
    )
}
```

## Responsive Design

### Window Sizes

```
- Minimum: 800x600 points
- Default: 1200x800 points
- Maximum: Unlimited (user resizable)
```

### Spatial Constraints

```
- AR cards: 30cm from user minimum
- Max AR entities: 50 visible
- Comfortable viewing distance: 0.5m - 3m
```

## Summary

This design system provides:
- **Consistency**: Reusable components across views
- **visionOS Native**: Leverages spatial computing paradigms
- **Accessible**: VoiceOver, Dynamic Type, Reduced Motion
- **Beautiful**: Glass materials, depth, smooth animations
- **Intuitive**: Familiar iOS patterns adapted for spatial UI

The UI should feel natural on visionOS while taking advantage of its unique spatial capabilities.
