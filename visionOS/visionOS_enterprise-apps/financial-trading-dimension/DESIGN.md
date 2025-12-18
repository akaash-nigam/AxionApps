# Financial Trading Dimension - Design Specification

## 1. Spatial Design Principles

### 1.1 Core Design Philosophy

Financial Trading Dimension leverages spatial computing to transform abstract financial data into intuitive 3D experiences. The design prioritizes:

- **Information Clarity**: Complex market data made comprehensible through spatial organization
- **Rapid Decision-Making**: Critical trading information immediately accessible
- **Ergonomic Comfort**: Extended trading sessions without fatigue
- **Collaborative Intelligence**: Shared understanding through spatial visualization

### 1.2 visionOS Design Patterns

**Depth Hierarchy**
- Foreground (Z: 0-0.3m): Active trading controls and critical alerts
- Mid-ground (Z: 0.3-1.0m): Market data visualization and portfolio monitoring
- Background (Z: 1.0-3.0m): Contextual information and ambient market indicators

**Spatial Ergonomics**
- Primary content positioned 10-15° below eye level
- Interactive elements within comfortable reach (0.4-0.8m)
- Secondary information at peripheral viewing angles (±30°)

**Progressive Disclosure**
- Start with 2D windows for familiar interface
- Expand to volumetric spaces for deeper analysis
- Full immersion for comprehensive market exploration

## 2. Window Layouts and Configurations

### 2.1 Market Overview Window

**Primary Dashboard (1200 x 800 pt)**

```
┌─────────────────────────────────────────────────────────┐
│ Market Overview                                    [≡]  │ ← Toolbar
├─────────────────────────────────────────────────────────┤
│ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐       │
│ │  S&P 500    │ │  NASDAQ     │ │  DOW JONES  │       │
│ │  5,234.56   │ │  16,789.12  │ │  42,156.78  │       │
│ │  +0.87%  ▲  │ │  +1.23%  ▲  │ │  -0.34%  ▼  │       │
│ └─────────────┘ └─────────────┘ └─────────────┘       │
├─────────────────────────────────────────────────────────┤
│ Top Gainers               │ Top Losers                 │
│ ┌────────────────────────┐│┌────────────────────────┐ │
│ │ AAPL    $189.45  +5.2%││││ MSFT   $412.34  -2.1% │ │
│ │ GOOGL   $142.78  +3.8%││││ TSLA   $245.67  -3.4% │ │
│ │ NVDA    $789.23  +7.1%││││ AMZN   $178.90  -1.8% │ │
│ └────────────────────────┘│└────────────────────────┘ │
├─────────────────────────────────────────────────────────┤
│ Market Heatmap (Asset Classes)                          │
│ ┌──────────────────────────────────────────────────────┐│
│ │ [Equities ████] [Fixed Income ██] [Commodities ███] ││
│ │ [Currencies ██] [Crypto █████] [Real Estate ██]     ││
│ └──────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────┘
```

**Design Specifications:**
- **Glass Material**: Thick background with medium blur
- **Typography**: SF Pro Display for numbers, SF Pro Text for labels
- **Color Coding**: Green (#34C759) for gains, Red (#FF3B30) for losses
- **Spacing**: 16pt padding, 12pt gaps between elements
- **Accessibility**: VoiceOver labels for all data points

### 2.2 Portfolio Window

**Portfolio Management Interface (1000 x 900 pt)**

```
┌──────────────────────────────────────────────────────────┐
│ My Portfolio                       Refresh [⟳] [Settings]│
├──────────────────────────────────────────────────────────┤
│ Total Value: $1,234,567.89        Day P&L: +$12,345 ▲   │
│ Cash: $234,567.00                 Total Return: +15.8%   │
├──────────────────────────────────────────────────────────┤
│ Positions                                                │
│ ┌────────────────────────────────────────────────────┐   │
│ │ Symbol  Qty    Avg Cost  Current  P&L      %      │   │
│ │ AAPL    500    $175.00   $189.45  +$7,225  +8.3%  │   │
│ │ GOOGL   200    $138.50   $142.78  +$856    +3.1%  │   │
│ │ MSFT    300    $420.00   $412.34  -$2,298  -1.8%  │   │
│ │ NVDA    100    $720.00   $789.23  +$6,923  +9.6%  │   │
│ └────────────────────────────────────────────────────┘   │
├──────────────────────────────────────────────────────────┤
│ Performance Chart (YTD)                                  │
│ ┌────────────────────────────────────────────────────┐   │
│ │        Portfolio ──                                │   │
│ │        S&P 500  ─ ─                                │   │
│ │   $1.4M  •••••                                     │   │
│ │   $1.2M    ••••                                    │   │
│ │   $1.0M      ••••••                                │   │
│ │    Jan  Feb  Mar  Apr  May  Jun  Jul  Aug  Sep    │   │
│ └────────────────────────────────────────────────────┘   │
├──────────────────────────────────────────────────────────┤
│ [View Risk Analysis] [Trade] [3D Visualization]         │
└──────────────────────────────────────────────────────────┘
```

**Design Specifications:**
- **Data Presentation**: Tabular format with alternating row tints
- **Interactive Charts**: Swift Charts with gesture support
- **Quick Actions**: Swipe gestures on positions for quick trade
- **Ornaments**: Floating toolbar with key actions

### 2.3 Trading Execution Window

**Order Entry Interface (600 x 800 pt)**

```
┌──────────────────────────────────────┐
│ Trade Execution              [Close] │
├──────────────────────────────────────┤
│ Symbol                               │
│ ┌──────────────────────────────────┐ │
│ │ AAPL ▼                           │ │
│ └──────────────────────────────────┘ │
│                                      │
│ Current Price: $189.45               │
│ Bid: $189.44  Ask: $189.46           │
├──────────────────────────────────────┤
│ Order Type                           │
│ ⦿ Market   ○ Limit   ○ Stop         │
├──────────────────────────────────────┤
│ Quantity                             │
│ ┌──────────────────────────────────┐ │
│ │ 100                    [ + ] [-] │ │
│ └──────────────────────────────────┘ │
├──────────────────────────────────────┤
│ Side                                 │
│ [ BUY ]          [ SELL ]           │
│  Green            Red                │
├──────────────────────────────────────┤
│ Estimated Cost: $18,945.00           │
│ Commission: $0.00                    │
│ Total: $18,945.00                    │
├──────────────────────────────────────┤
│ ┌──────────────────────────────────┐ │
│ │    [Submit Order]                │ │
│ │     Large button                 │ │
│ └──────────────────────────────────┘ │
└──────────────────────────────────────┘
```

**Design Specifications:**
- **Visual Hierarchy**: Large, prominent submit button
- **Color Psychology**: Green for buy, red for sell
- **Input Validation**: Real-time validation with error states
- **Confirmation**: Modal dialog before final submission
- **Accessibility**: Clear labels and minimum 60pt tap targets

## 3. Volume Designs (3D Bounded Spaces)

### 3.1 Market Correlation Volume (1.0m³)

**3D Asset Correlation Visualization**

```
Concept: Floating spheres representing assets in 3D space
- Position determined by multi-dimensional correlation analysis
- Size indicates market capitalization
- Color shows performance (green/red spectrum)
- Connecting lines show correlation strength
- Distance between spheres = inverse correlation

3D Layout:
    Y-Axis: Volatility (low → high)
      ↑
      │    ○ NVDA (high volatility, large cap)
      │
      │  ○ AAPL     ○ GOOGL
      │    (medium volatility)
      │
      │ ○ MSFT ○ JPM
      │  (low volatility)
      │
      └─────────────────→ X-Axis: Market Cap
     /
    /
   ↙ Z-Axis: Sector correlation
```

**Interaction Model:**
- **Tap**: Select asset, highlight correlations
- **Pinch & Drag**: Rotate entire visualization
- **Two-finger drag**: Pan through space
- **Magnify**: Zoom in/out
- **Long press**: Show detailed asset information

**Visual Design:**
- **Spheres**: Glass material with depth
- **Connection Lines**: Gradient based on correlation strength
- **Labels**: Floating text with billboarding
- **Lighting**: Directional light from above-front

### 3.2 Portfolio Risk Volume (1.0 x 1.0 x 0.8m)

**3D Risk Exposure Visualization**

```
Concept: Stacked 3D bar chart showing risk distribution
- Bars represent different risk factors
- Height = exposure amount
- Color = risk severity
- Segments within bars = individual positions contributing

3D Layout:
      ↑ Exposure ($M)
    8 │     ████  Market Risk
      │     ████
    6 │     ████  ████  Credit Risk
      │ ████████  ████
    4 │ ████████  ████  ████  Liquidity Risk
      │ ████████  ████  ████
    2 │ ████████  ████  ████  ████  Currency Risk
      │ ████████  ████  ████  ████
    0 └─────────────────────────────→
      Market   Credit  Liquid  FX
```

**Interaction Model:**
- **Tap bar**: Drill down into specific risk factor
- **Hover**: Show tooltip with exact values
- **Swipe**: Navigate between time periods
- **Pinch**: Zoom into specific risk category

### 3.3 Technical Analysis Volume (1.5 x 1.0 x 0.8m)

**3D Multi-Timeframe Chart**

```
Concept: Price chart as 3D landscape
- X-axis: Time
- Y-axis: Price
- Z-axis: Different timeframes (1D, 1W, 1M, 1Y)
- Surface represents price movement
- Volume shown as bars below surface

3D Layout:
  Price
    ↑
    │   1Y timeframe (back)
    │    ╱╲╱╲╱╲╱
    │   ╱      ╲  1M
    │  ╱        ╲╱╲
    │ ╱  1W      ╲  1D (front)
    │╱────────────╲
    └──────────────→ Time
   ╱
  ╱ Timeframe depth
 ↙
```

**Interaction Model:**
- **Drag finger along chart**: Scrub through time
- **Pinch on Z-axis**: Expand/compress timeframes
- **Tap on surface**: Show OHLCV data for that point
- **Two-hand rotation**: View from different angles

## 4. Full Space / Immersive Experiences

### 4.1 Trading Floor Immersion

**360° Market Environment**

**Spatial Layout:**

```
                     ┌─ Ceiling: Market News Ticker
                     │
        ┌────────────┼────────────┐
        │                         │
  Left: │    Center: Main View    │ Right:
  Watch │    ┌──────────────┐    │ Quick
  Lists │    │  Portfolio   │    │ Actions
  Panel │    │  3D Sphere   │    │ Panel
        │    └──────────────┘    │
        │                         │
        └─────────────┬───────────┘
                      │
         Floor: Order Entry Controls
```

**Design Zones:**

**Front/Center (0°-30°):**
- Primary portfolio visualization as 3D sphere
- Real-time price movements
- Key performance indicators
- Main interaction area

**Left Peripheral (30°-90°):**
- Watchlist with live prices
- Sector performance indicators
- Market indices
- News feed

**Right Peripheral (30°-90°):**
- Quick trade panel
- Recent orders
- Alerts and notifications
- Risk metrics

**Above (30°-60° up):**
- Global market overview
- Major indices ticker
- Economic calendar
- Time zone clocks

**Below (30°-45° down):**
- Order entry interface
- Trade history
- Account information
- Settings

**Interaction in Immersive Space:**
- **Gaze + Pinch**: Select and interact
- **Hand rays**: Point at distant elements
- **Voice**: "Show AAPL", "Buy 100 shares"
- **Gestures**: Swipe to dismiss, pinch to zoom

### 4.2 Strategy Collaboration Space

**Multi-User Shared Environment**

**Spatial Layout:**
```
        User 2 viewpoint
              ↑
              │
User 3 ←──────●──────→ User 1
viewpoint   Shared   viewpoint
            Center
              │
              ↓
        User 4 viewpoint
```

**Shared Center:**
- 3D market visualization visible to all
- Collaborative annotation tools
- Shared trading scenarios
- Real-time strategy simulation

**Individual Zones:**
- Private notes and calculations
- Personal portfolio view
- Individual order entry

**Collaboration Features:**
- Spatial pointers to highlight areas
- Voice communication with spatial audio
- Screen sharing for specific windows
- Collaborative drawing on 3D charts

## 5. Visual Design System

### 5.1 Color Palette

**Primary Colors:**
- **Background Glass**: rgba(28, 28, 30, 0.7) - Dark glass with blur
- **Surface Glass**: rgba(44, 44, 46, 0.8) - Slightly lighter glass
- **Elevation**: rgba(58, 58, 60, 0.9) - Elevated elements

**Semantic Colors:**
- **Bullish/Positive**: #34C759 (System Green)
- **Bearish/Negative**: #FF3B30 (System Red)
- **Neutral**: #8E8E93 (System Gray)
- **Warning**: #FF9500 (System Orange)
- **Critical Alert**: #FF2D55 (System Pink)

**Data Visualization Palette:**
- **Series 1**: #0A84FF (Blue)
- **Series 2**: #30D158 (Green)
- **Series 3**: #FF9F0A (Orange)
- **Series 4**: #BF5AF2 (Purple)
- **Series 5**: #FF375F (Pink)
- **Series 6**: #5AC8FA (Cyan)

**Accessibility:**
- Minimum contrast ratio 4.5:1 for text
- Distinct colors for colorblind users
- Patterns in addition to colors for critical information

### 5.2 Typography

**Font Family:**
- **Primary**: SF Pro Display (for large numbers and headlines)
- **Secondary**: SF Pro Text (for body text)
- **Monospace**: SF Mono (for tabular data)

**Type Scale:**
```
Display Large:   56pt / 62pt line - Portfolio totals
Display Medium:  48pt / 54pt line - Window titles
Headline:        34pt / 41pt line - Section headers
Title 1:         28pt / 34pt line - Card titles
Title 2:         22pt / 28pt line - List headers
Title 3:         20pt / 25pt line - Subsections
Body Large:      17pt / 22pt line - Primary content
Body:            15pt / 20pt line - Secondary content
Caption 1:       13pt / 18pt line - Labels
Caption 2:       11pt / 13pt line - Fine print
```

**Spatial Text Rendering:**
- Use `Text3D` for critical 3D labels
- Billboard text for entity labels (always faces user)
- Depth-based scaling for readability
- Minimum readable size at 2m distance: 24pt

**Numeric Formatting:**
```swift
// Price: $189.45 (2 decimal places)
Decimal: 2 decimal places, thousands separator

// Percentage: +5.8% (1 decimal place)
Percentage: 1 decimal place, + for positive

// Large numbers: $1.2M (abbreviated)
Currency: K for thousands, M for millions, B for billions

// Dates: 12:34:56 or Sep 15, 2024
Time: HH:mm:ss for intraday, MMM dd for historical
```

### 5.3 Materials and Lighting

**Glass Materials:**
```swift
// Window backgrounds
.glassBackgroundEffect(
    in: RoundedRectangle(cornerRadius: 32),
    displayMode: .always
)

// Elevated surfaces
.background(.regularMaterial, in: .rect(cornerRadius: 16))

// Interactive elements
.background(.thickMaterial, in: .capsule)
```

**Lighting for 3D Scenes:**
```swift
// Directional light (simulates sun)
DirectionalLight(
    color: .white,
    intensity: 500,
    direction: SIMD3(x: 0, y: -1, z: -0.5)
)

// Ambient light (soft fill)
AmbientLight(
    color: .white,
    intensity: 200
)

// Point lights for emphasis
PointLight(
    color: .blue,
    intensity: 300,
    attenuationRadius: 2.0,
    position: SIMD3(x: 0, y: 1, z: 0.5)
)
```

**Material Properties:**
- **Metal spheres**: Metallic = 1.0, Roughness = 0.2 (shiny)
- **Glass panels**: Opacity = 0.3, Roughness = 0.0
- **Chart elements**: Emissive color for glow effect

### 5.4 Iconography in 3D Space

**Icon Design Principles:**
- SF Symbols as base for 2D icons
- Custom 3D icons for spatial elements
- Consistent stroke width: 2pt
- Minimum size: 44pt tap target

**Key Icons:**
- Trade: Arrow up/down in circle
- Portfolio: Pie chart
- Alerts: Bell with badge
- Settings: Gear
- Market: Bar chart
- Risk: Shield with exclamation

**3D Icon Integration:**
```swift
// Floating action button in 3D space
Model3D(named: "trade_icon") { model in
    model
        .resizable()
        .frame(width: 0.1, height: 0.1, depth: 0.01)
        .offset(z: 0.5)
}
```

## 6. User Flows and Navigation

### 6.1 Primary User Flows

**Flow 1: Quick Trade Execution**
```
1. Launch App → Market Overview
2. Tap Asset (e.g., AAPL)
3. Quick Trade Panel appears
4. Select Quantity
5. Confirm Buy/Sell
6. Order Submitted → Confirmation
```

**Flow 2: Portfolio Analysis**
```
1. Open Portfolio Window
2. View positions and performance
3. Tap "3D Visualization"
4. Volume opens with risk analysis
5. Rotate and explore exposures
6. Identify rebalancing opportunities
7. Execute trades from 3D view
```

**Flow 3: Market Research**
```
1. Market Overview → Select Sector
2. View sector heatmap
3. Tap "Correlation Analysis"
4. Correlation Volume opens
5. Explore asset relationships
6. Add symbols to watchlist
7. Set price alerts
```

**Flow 4: Immersive Trading Session**
```
1. Open Immersive Space
2. Trading floor environment loads
3. Arrange windows spatially
4. Monitor multiple assets
5. Execute trades via voice or gesture
6. Collaborate with team members
7. Exit to normal mode
```

### 6.2 Navigation Patterns

**Window Management:**
- **Open Window**: Menu → Select window type
- **Move Window**: Grab title bar, drag
- **Resize**: Grab edges (where supported)
- **Close**: X button or gesture

**3D Navigation:**
- **Orbit**: Two-finger drag
- **Pan**: Two-finger drag (modifier)
- **Zoom**: Pinch gesture
- **Reset View**: Double-tap background

**Spatial Navigation:**
- **Look Around**: Physical head movement
- **Teleport**: Gaze + tap on floor
- **Reach**: Hand ray for distant objects

### 6.3 Information Architecture

```
App Structure:
├── Market Overview (Default)
│   ├── Indices
│   ├── Gainers/Losers
│   ├── Heatmap
│   └── News Feed
├── Portfolio
│   ├── Positions
│   ├── Performance
│   ├── Risk Analysis
│   └── Trade History
├── Trading
│   ├── Order Entry
│   ├── Order Status
│   └── Quick Trade
├── Watchlists
│   ├── Custom Lists
│   ├── Pre-defined Lists
│   └── Alerts
├── Analytics
│   ├── Correlation (3D)
│   ├── Technical Analysis (3D)
│   └── Risk Visualization (3D)
└── Settings
    ├── Account
    ├── Preferences
    ├── Notifications
    └── Security
```

## 7. Interaction Patterns

### 7.1 Standard Interactions

**Selection:**
- **Gaze + Dwell**: 2 seconds to select
- **Gaze + Pinch**: Instant selection
- **Direct Touch**: Tap with finger (close objects)

**Manipulation:**
- **Move**: Pinch + drag
- **Rotate**: Two-hand rotation gesture
- **Scale**: Pinch to zoom

**Scrolling:**
- **Vertical**: Swipe up/down
- **Horizontal**: Swipe left/right
- **3D Scroll**: Drag with depth

### 7.2 Trading-Specific Interactions

**Quick Buy/Sell:**
```
1. Gaze at asset
2. Pinch thumb + index (buy) or thumb + middle (sell)
3. Pull hand toward body (quantity increases with distance)
4. Release to submit
```

**Price Alert Setting:**
```
1. Tap asset in chart
2. Drag horizontal line to target price
3. Tap line to set alert
```

**Portfolio Rebalancing:**
```
1. In 3D portfolio view
2. Grab position sphere
3. Drag to target allocation zone
4. Release to rebalance
```

### 7.3 Gesture Vocabulary

| Gesture | Action | Context |
|---------|--------|---------|
| Single Tap | Select | Universal |
| Double Tap | Execute/Confirm | Trading |
| Long Press | Context Menu | Universal |
| Pinch + Drag | Move Object | 3D Views |
| Two-Finger Drag | Rotate View | 3D Views |
| Swipe Left | Previous | Charts/Lists |
| Swipe Right | Next | Charts/Lists |
| Swipe Up | Details | Asset Cards |
| Swipe Down | Dismiss | Modals |
| Spread Fingers | Expand | Windows |
| Pinch Fingers | Collapse | Windows |

## 8. Animation and Transition Specifications

### 8.1 Micro-Animations

**Price Updates:**
```swift
// Smooth number transitions
Text("\(price, format: .currency(code: "USD"))")
    .contentTransition(.numericText())
    .animation(.smooth(duration: 0.3), value: price)
```

**Color Changes:**
```swift
// Pulse animation for alerts
Circle()
    .foregroundStyle(alertColor)
    .scaleEffect(isPulsing ? 1.2 : 1.0)
    .animation(.easeInOut(duration: 0.6).repeatForever(), value: isPulsing)
```

**Chart Updates:**
```swift
// Smooth line graph transitions
LineMark(x: .value("Time", date), y: .value("Price", price))
    .interpolationMethod(.catmullRom)
    .animation(.spring(duration: 0.5), value: data)
```

### 8.2 Window Transitions

**Opening Windows:**
```swift
.transition(.asymmetric(
    insertion: .scale(scale: 0.8).combined(with: .opacity),
    removal: .opacity
))
.animation(.spring(response: 0.4, dampingFraction: 0.7))
```

**3D Volume Appearance:**
```swift
// Grow from center point
.scaleEffect(isPresented ? 1.0 : 0.01)
.opacity(isPresented ? 1.0 : 0.0)
.animation(.spring(response: 0.6, dampingFraction: 0.75), value: isPresented)
```

### 8.3 Immersive Transitions

**Entering Immersion:**
```swift
// Fade current windows, expand environment
.task {
    await openImmersiveSpace(id: "trading-floor")
}
.immersiveSpaceTransition(.fade(duration: 1.0))
```

**Exiting Immersion:**
```swift
// Restore window arrangement
.task {
    await dismissImmersiveSpace()
}
.transition(.move(edge: .bottom).combined(with: .opacity))
```

### 8.4 Motion Design Principles

**Timing:**
- **Instant**: < 100ms (direct responses)
- **Quick**: 200-300ms (UI feedback)
- **Moderate**: 400-600ms (window transitions)
- **Slow**: 800-1000ms (immersive transitions)

**Easing:**
- **Spring**: Natural, organic movement (preferred)
- **EaseInOut**: Smooth acceleration/deceleration
- **Linear**: Constant motion (data updates)

**Reduce Motion:**
```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

func animate() {
    if reduceMotion {
        // Instant transition
        updateView()
    } else {
        // Animated transition
        withAnimation(.spring()) {
            updateView()
        }
    }
}
```

## 9. Accessibility Design

### 9.1 VoiceOver Support

**Descriptive Labels:**
```swift
Button {
    executeTrade()
} label: {
    Image(systemName: "cart")
}
.accessibilityLabel("Execute buy order for 100 shares of AAPL")
.accessibilityHint("Double tap to confirm purchase")
```

**Value Descriptions:**
```swift
Text("$\(portfolioValue)")
    .accessibilityLabel("Portfolio value: \(portfolioValue, format: .currency(code: "USD"))")
    .accessibilityValue("Up \(percentChange)% today")
```

**3D Entity Accessibility:**
```swift
// Make 3D entities accessible
entity.components[AccessibilityComponent.self] = AccessibilityComponent(
    label: "Apple stock, price $189.45",
    hint: "Pinch to view details",
    isAccessibilityElement: true
)
```

### 9.2 Visual Accessibility

**High Contrast Mode:**
```swift
@Environment(\.colorSchemeContrast) var contrast

var foregroundColor: Color {
    contrast == .increased ? .primary : .secondary
}
```

**Dynamic Type:**
```swift
Text("Portfolio Value")
    .font(.headline)
    .dynamicTypeSize(...DynamicTypeSize.xxxLarge) // Cap maximum size
```

**Color Independence:**
```
Don't rely solely on color:
❌ Red = bad, Green = good (color only)
✓ ▼ Red = bad, ▲ Green = good (symbol + color)
```

### 9.3 Alternative Interactions

**Voice Commands:**
- "Show my portfolio"
- "What's the price of Apple?"
- "Buy 100 shares of Google"
- "Alert me when Tesla reaches $250"

**Keyboard Navigation:**
- Tab: Next element
- Shift+Tab: Previous element
- Enter: Activate
- Escape: Cancel/Close

**Switch Control:**
- Scanning mode for sequential selection
- Dwell activation for hands-free operation

## 10. Error States and Loading Indicators

### 10.1 Loading States

**Initial Load:**
```swift
if isLoading {
    VStack {
        ProgressView()
            .scaleEffect(1.5)
        Text("Loading market data...")
            .font(.caption)
            .foregroundStyle(.secondary)
    }
}
```

**Skeleton Loading:**
```swift
// Shimmer effect for data placeholders
RoundedRectangle(cornerRadius: 8)
    .fill(.gray.opacity(0.3))
    .overlay {
        RoundedRectangle(cornerRadius: 8)
            .fill(
                LinearGradient(
                    colors: [.clear, .white.opacity(0.3), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .offset(x: shimmerOffset)
    }
```

**Progressive Loading:**
```
1. Show cached data immediately
2. Display "Updating..." indicator
3. Fade in new data when available
```

### 10.2 Error States

**Network Error:**
```swift
ContentUnavailableView {
    Label("Connection Lost", systemImage: "wifi.slash")
} description: {
    Text("Unable to reach trading servers. Check your connection.")
} actions: {
    Button("Retry") {
        reconnect()
    }
    .buttonStyle(.borderedProminent)
}
```

**Order Rejection:**
```swift
// Alert dialog
.alert("Order Rejected", isPresented: $showError) {
    Button("OK", role: .cancel) { }
    Button("Contact Support") {
        openSupport()
    }
} message: {
    Text(errorMessage)
}
```

**Data Validation:**
```swift
TextField("Quantity", value: $quantity, format: .number)
    .textFieldStyle(.roundedBorder)
    .border(isValid ? .clear : .red, width: 2)

if !isValid {
    Text("Quantity must be greater than 0")
        .font(.caption)
        .foregroundStyle(.red)
}
```

### 10.3 Empty States

**Empty Watchlist:**
```swift
ContentUnavailableView {
    Label("No Watchlists", systemImage: "star.slash")
} description: {
    Text("Create a watchlist to track your favorite assets")
} actions: {
    Button("Create Watchlist") {
        createWatchlist()
    }
}
```

**No Positions:**
```swift
VStack(spacing: 20) {
    Image(systemName: "chart.line.uptrend.xyaxis")
        .font(.system(size: 64))
        .foregroundStyle(.secondary)

    Text("No Positions")
        .font(.title2)

    Text("Start trading to build your portfolio")
        .foregroundStyle(.secondary)

    Button("Browse Markets") {
        showMarketOverview()
    }
    .buttonStyle(.borderedProminent)
}
```

## 11. Responsive Design

### 11.1 Adaptive Layouts

**Window Size Adaptation:**
```swift
@Environment(\.horizontalSizeClass) var sizeClass

var body: some View {
    if sizeClass == .compact {
        // Single column layout
        VStack { content }
    } else {
        // Multi-column layout
        HStack { content }
    }
}
```

**3D LOD (Level of Detail):**
```swift
// Reduce complexity at distance
func updateLOD(distance: Float) {
    if distance < 1.0 {
        // High detail: show all data points
        entity.model?.mesh = highDetailMesh
    } else if distance < 3.0 {
        // Medium detail: reduce data points
        entity.model?.mesh = mediumDetailMesh
    } else {
        // Low detail: simple shapes
        entity.model?.mesh = lowDetailMesh
    }
}
```

### 11.2 Performance Optimization

**Lazy Loading:**
```swift
LazyVStack {
    ForEach(positions) { position in
        PositionRow(position: position)
    }
}
```

**Efficient Rendering:**
```swift
// Use Canvas for complex visualizations
Canvas { context, size in
    // Draw directly, avoid SwiftUI overhead
    for dataPoint in chartData {
        context.fill(
            Path(ellipseIn: CGRect(x: dataPoint.x, y: dataPoint.y, width: 4, height: 4)),
            with: .color(.blue)
        )
    }
}
```

## Conclusion

This design specification provides a comprehensive blueprint for creating an intuitive, accessible, and visually stunning visionOS trading application. The spatial design leverages the unique capabilities of Apple Vision Pro to transform complex financial data into comprehensible 3D experiences, while maintaining the ergonomic comfort and accessibility necessary for professional trading environments.
