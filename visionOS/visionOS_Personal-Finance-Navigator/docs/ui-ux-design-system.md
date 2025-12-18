# UI/UX Design System & Spatial Layouts
# Personal Finance Navigator

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Draft

## Table of Contents
1. [Design Philosophy](#design-philosophy)
2. [Color System](#color-system)
3. [Typography](#typography)
4. [Spatial Layout](#spatial-layout)
5. [Component Library](#component-library)
6. [Interaction Patterns](#interaction-patterns)
7. [Accessibility](#accessibility)

## Design Philosophy

### Spatial Computing Principles
- **Immersive yet comfortable**: Balance 3D immersion with usability
- **Spatial awareness**: Use depth and positioning meaningfully
- **Glanceable information**: Quick understanding at a distance
- **Minimal cognitive load**: Intuitive spatial organization
- **Physical metaphors**: Real-world analogies for financial concepts

### Design Goals
- **Clarity**: Financial data presented clearly
- **Trust**: Professional, secure appearance
- **Motivation**: Positive reinforcement for good habits
- **Control**: User feels in command of their finances

## Color System

### Primary Palette

```swift
// Colors.swift
extension Color {
    // Primary
    static let pfnPrimary = Color(hex: "#007AFF")      // Apple Blue
    static let pfnSecondary = Color(hex: "#5856D6")    // Indigo

    // Income & Positive
    static let pfnIncome = Color(hex: "#34C759")       // Green
    static let pfnSavings = Color(hex: "#FFD700")      // Gold
    static let pfnGain = Color(hex: "#30D158")         // Light Green

    // Expenses & Negative
    static let pfnExpense = Color(hex: "#FF3B30")      // Red
    static let pfnDebt = Color(hex: "#8B0000")         // Dark Red
    static let pfnLoss = Color(hex: "#FF453A")         // Light Red

    // Categories
    static let pfnHousing = Color(hex: "#FF9500")      // Orange
    static let pfnTransport = Color(hex: "#007AFF")    // Blue
    static let pfnFood = Color(hex: "#34C759")         // Green
    static let pfnShopping = Color(hex: "#FF2D55")     // Pink
    static let pfnEntertainment = Color(hex: "#AF52DE")// Purple
    static let pfnHealthcare = Color(hex: "#FF3B30")   // Red
    static let pfnUtilities = Color(hex: "#FFC400")    // Yellow

    // Budget Status
    static let pfnBudgetSafe = Color(hex: "#A8D8B9")   // Light Green
    static let pfnBudgetWarning = Color(hex: "#FFC400")// Yellow
    static let pfnBudgetDanger = Color(hex: "#FF1744") // Bright Red

    // Neutrals
    static let pfnBackground = Color(hex: "#000000")   // Black (visionOS)
    static let pfnSurface = Color(hex: "#1C1C1E")      // Dark Gray
    static let pfnOnSurface = Color(hex: "#FFFFFF")    // White
    static let pfnDivider = Color(hex: "#38383A")      // Medium Gray
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
```

### Glass Morphism for visionOS

```swift
// GlassMaterial.swift
struct GlassMaterial: View {
    var body: some View {
        Rectangle()
            .foregroundStyle(.ultraThinMaterial)
            .opacity(0.8)
    }
}

// Usage
struct BalanceCard: View {
    let balance: Decimal

    var body: some View {
        ZStack {
            GlassMaterial()

            VStack(alignment: .leading, spacing: 12) {
                Text("Total Balance")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(balance.formatted(.currency(code: "USD")))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
            }
            .padding(24)
        }
        .frame(width: 400, height: 200)
        .cornerRadius(24)
    }
}
```

## Typography

### Type Scale

```swift
// Typography.swift
extension Font {
    // Display (Large titles, hero numbers)
    static let pfnDisplayLarge = Font.system(size: 72, weight: .bold, design: .rounded)
    static let pfnDisplayMedium = Font.system(size: 56, weight: .bold, design: .rounded)
    static let pfnDisplaySmall = Font.system(size: 44, weight: .semibold, design: .rounded)

    // Headline (Section titles)
    static let pfnHeadlineLarge = Font.system(size: 32, weight: .bold, design: .default)
    static let pfnHeadlineMedium = Font.system(size: 24, weight: .semibold, design: .default)
    static let pfnHeadlineSmall = Font.system(size: 20, weight: .semibold, design: .default)

    // Body (Regular text)
    static let pfnBodyLarge = Font.system(size: 18, weight: .regular, design: .default)
    static let pfnBodyMedium = Font.system(size: 16, weight: .regular, design: .default)
    static let pfnBodySmall = Font.system(size: 14, weight: .regular, design: .default)

    // Label (Captions, metadata)
    static let pfnLabelLarge = Font.system(size: 14, weight: .medium, design: .default)
    static let pfnLabelMedium = Font.system(size: 12, weight: .medium, design: .default)
    static let pfnLabelSmall = Font.system(size: 10, weight: .medium, design: .default)

    // Monospace (Currency, numbers)
    static let pfnMonoLarge = Font.system(size: 32, weight: .semibold, design: .monospaced)
    static let pfnMonoMedium = Font.system(size: 24, weight: .medium, design: .monospaced)
    static let pfnMonoSmall = Font.system(size: 16, weight: .regular, design: .monospaced)
}
```

### Currency Formatting

```swift
// CurrencyFormatting.swift
extension Decimal {
    func formattedCurrency(code: String = "USD", compact: Bool = false) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code

        if compact {
            formatter.maximumFractionDigits = 0
        }

        return formatter.string(from: self as NSDecimalNumber) ?? "$0.00"
    }

    func formattedCompact() -> String {
        let absValue = abs(self)

        if absValue >= 1_000_000 {
            return String(format: "$%.1fM", Double(truncating: self / 1_000_000 as NSDecimalNumber))
        } else if absValue >= 1_000 {
            return String(format: "$%.1fK", Double(truncating: self / 1_000 as NSDecimalNumber))
        } else {
            return formattedCurrency(compact: true)
        }
    }
}
```

## Spatial Layout

### Financial Command Center (Default View)

```
            ┌─────────────────────────────────────┐
            │      Bills Calendar (Floating)      │
            │  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐     │
            │  │📄│  │📄│  │📄│  │📄│  │📄│     │
            │  └──┘  └──┘  └──┘  └──┘  └──┘     │
            └─────────────────────────────────────┘
                           ↑ 2m above

┌─────────────┐    ┌─────────────────────┐    ┌─────────────┐
│   Budget    │    │                     │    │ Investment  │
│   Walls     │←1m→│   Money Flow        │←1m→│   Growth    │
│             │    │   Visualization     │    │  Structure  │
│  ┌────────┐ │    │                     │    │             │
│  │ Dining │ │    │      🌊💰💸         │    │     🌳      │
│  │  85%   │ │    │                     │    │   Portfolio │
│  └────────┘ │    │                     │    │             │
└─────────────┘    └─────────────────────┘    └─────────────┘
     ← Left               Center                   Right →

                           ↓ 1m below
            ┌─────────────────────────────────────┐
            │       Goals Progress                 │
            │  ┌──┐  ┌──┐  ┌──┐  ┌──┐            │
            │  │🏖│  │🏠│  │🚗│  │📚│            │
            │  └──┘  └──┘  └──┘  └──┘            │
            └─────────────────────────────────────┘
```

### RealityKit Scene Setup

```swift
// FinancialCommandCenterScene.swift
struct FinancialCommandCenterScene: View {
    var body: some View {
        RealityView { content in
            // Center: Money flow
            let moneyFlowEntity = await createMoneyFlowEntity()
            moneyFlowEntity.position = [0, 1.5, -2] // 2m in front, 1.5m high
            content.add(moneyFlowEntity)

            // Left: Budget walls
            let budgetWallsEntity = await createBudgetWallsEntity()
            budgetWallsEntity.position = [-1.5, 1.5, -2]
            content.add(budgetWallsEntity)

            // Right: Investment growth
            let investmentEntity = await createInvestmentGrowthEntity()
            investmentEntity.position = [1.5, 1.5, -2]
            content.add(investmentEntity)

            // Top: Bills calendar
            let billsEntity = await createBillsCalendarEntity()
            billsEntity.position = [0, 3.5, -2] // 2m above center
            content.add(billsEntity)

            // Bottom: Goals
            let goalsEntity = await createGoalsEntity()
            goalsEntity.position = [0, 0.5, -2] // 1m below center
            content.add(goalsEntity)

            // Add ambient lighting
            let ambientLight = AmbientLightComponent(color: .white, intensity: 500)
            let lightEntity = Entity()
            lightEntity.components[AmbientLightComponent.self] = ambientLight
            content.add(lightEntity)
        }
    }
}
```

### Depth and Layering

```swift
// Depth levels (Z-axis positioning)
enum DepthLevel {
    static let foreground: Float = -1.0    // 1m from user
    static let main: Float = -2.0          // 2m from user (default)
    static let background: Float = -3.0    // 3m from user
    static let distant: Float = -5.0       // 5m from user
}

// Size guidelines for different distances
enum SpatialSizing {
    // At 2m distance
    static let cardWidth: Float = 0.4      // 40cm
    static let cardHeight: Float = 0.25    // 25cm

    // At 1m distance (closer, smaller)
    static let closeCardWidth: Float = 0.25
    static let closeCardHeight: Float = 0.15

    // At 3m distance (farther, larger)
    static let farCardWidth: Float = 0.6
    static let farCardHeight: Float = 0.4
}
```

## Component Library

### Cards

```swift
// FinancialCard.swift
struct FinancialCard<Content: View>: View {
    let title: String
    let icon: String?
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(.regularMaterial)

            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    if let icon {
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundStyle(.primary)
                    }

                    Text(title)
                        .font(.pfnHeadlineSmall)
                        .foregroundStyle(.primary)

                    Spacer()
                }

                // Content
                content()
            }
            .padding(24)
        }
    }
}

// Usage
FinancialCard(title: "Total Balance", icon: "dollarsign.circle.fill") {
    Text("$12,345.67")
        .font(.pfnDisplayMedium)
        .foregroundStyle(.pfnIncome)
}
```

### Progress Indicators

```swift
// BudgetProgressRing.swift
struct BudgetProgressRing: View {
    let spent: Decimal
    let allocated: Decimal
    let category: String

    private var percentage: Double {
        guard allocated > 0 else { return 0 }
        return Double(truncating: (spent / allocated) as NSDecimalNumber)
    }

    private var statusColor: Color {
        if percentage >= 1.0 {
            return .pfnBudgetDanger
        } else if percentage >= 0.75 {
            return .pfnBudgetWarning
        } else {
            return .pfnBudgetSafe
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 12)

                Circle()
                    .trim(from: 0, to: min(percentage, 1.0))
                    .stroke(statusColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: percentage)

                VStack(spacing: 4) {
                    Text("\(Int(percentage * 100))%")
                        .font(.pfnMonoLarge)
                        .foregroundStyle(statusColor)

                    Text(spent.formattedCurrency())
                        .font(.pfnBodySmall)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 150, height: 150)

            Text(category)
                .font(.pfnHeadlineSmall)
                .foregroundStyle(.primary)
        }
    }
}
```

### Transaction Row

```swift
// TransactionRow.swift
struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: 16) {
            // Category icon
            CategoryIcon(category: transaction.category)
                .frame(width: 44, height: 44)

            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.merchantName ?? transaction.name)
                    .font(.pfnBodyMedium)
                    .foregroundStyle(.primary)

                Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.pfnLabelMedium)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Amount
            Text(transaction.amount.formattedCurrency())
                .font(.pfnMonoMedium)
                .foregroundStyle(transaction.isExpense ? .pfnExpense : .pfnIncome)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.pfnSurface)
        .cornerRadius(12)
    }
}
```

## Interaction Patterns

### Gesture Interactions

```swift
// InteractionGuide.swift

// Tap: Select/Open
.onTapGesture {
    coordinator.navigate(to: .transactionDetail(transaction))
}

// Long Press: Context Menu
.onLongPressGesture {
    showContextMenu = true
}

// Drag: Reorder/Move
.gesture(
    DragGesture()
        .onChanged { value in
            offset = value.translation
        }
        .onEnded { value in
            handleDragEnd(value)
        }
)

// Pinch: Zoom/Scale
.gesture(
    MagnificationGesture()
        .onChanged { value in
            scale = value
        }
)

// Rotate: Change view angle
.gesture(
    RotationGesture()
        .onChanged { angle in
            rotation = angle
        }
)
```

### Voice Commands

```swift
// VoiceCommandHandler.swift
enum VoiceCommand: String, CaseIterable {
    case showDashboard = "show dashboard"
    case showBudget = "show budget"
    case showTransactions = "show transactions"
    case addTransaction = "add transaction"
    case howMuchSpent = "how much have I spent"
    case remainingBudget = "what's my remaining budget"
    case nextBill = "when is my next bill"
    case totalBalance = "what's my total balance"
}

class VoiceCommandHandler {
    func handle(_ command: String) async {
        // Parse command
        guard let voiceCommand = VoiceCommand(rawValue: command.lowercased()) else {
            return
        }

        // Execute command
        switch voiceCommand {
        case .showDashboard:
            coordinator.popToRoot()

        case .showBudget:
            coordinator.navigate(to: .budget)

        case .howMuchSpent:
            let spent = await calculateTotalSpent()
            speak("You've spent \(spent.formattedCurrency()) this month")

        case .remainingBudget:
            let remaining = await calculateRemainingBudget()
            speak("You have \(remaining.formattedCurrency()) remaining in your budget")

        default:
            break
        }
    }
}
```

### Haptic Feedback

```swift
// HapticManager.swift
import CoreHaptics

class HapticManager {
    static let shared = HapticManager()
    private var engine: CHHapticEngine?

    init() {
        prepareHaptics()
    }

    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            Logger.haptics.error("Haptic engine failed to start: \(error)")
        }
    }

    // Budget warning (approaching limit)
    func budgetWarning() {
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)

        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [intensity, sharpness],
            relativeTime: 0
        )

        playPattern([event])
    }

    // Budget exceeded (broke through wall)
    func budgetExceeded() {
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)

        let events = [
            CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0),
            CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0.1),
            CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0.2)
        ]

        playPattern(events)
    }

    // Goal achieved (success)
    func goalAchieved() {
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)

        let events = (0..<5).map { i in
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [intensity, sharpness],
                relativeTime: TimeInterval(i) * 0.1
            )
        }

        playPattern(events)
    }

    private func playPattern(_ events: [CHHapticEvent]) {
        guard let engine = engine else { return }

        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            Logger.haptics.error("Failed to play haptic: \(error)")
        }
    }
}
```

## Accessibility

### VoiceOver Support

```swift
// Accessibility labels
struct AccountCard: View {
    let account: Account

    var body: some View {
        VStack {
            Text(account.name)
            Text(account.currentBalance.formattedCurrency())
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(account.name) account")
        .accessibilityValue("Balance: \(account.currentBalance.formattedCurrency())")
        .accessibilityHint("Double tap to view details")
    }
}
```

### Dynamic Type

```swift
// Support Dynamic Type
Text("Total Balance")
    .font(.pfnHeadlineSmall)
    .dynamicTypeSize(...DynamicTypeSize.xxxLarge) // Cap at xxxLarge for layout
```

### Reduced Motion

```swift
// Respect reduced motion preference
@Environment(\.accessibilityReduceMotion) var reduceMotion

var body: some View {
    particle
        .modifier(
            ParticleAnimationModifier(
                isAnimating: !reduceMotion
            )
        )
}
```

---

**Document Status**: Ready for Implementation
**Next Steps**: 3D Visualization Technical Spec
