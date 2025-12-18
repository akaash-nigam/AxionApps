# UI/UX Design Specifications Document

## Document Information
- **Version**: 1.0
- **Last Updated**: 2025-11-24
- **Status**: Draft
- **Owner**: Engineering Team

## 1. Overview

This document specifies the user interface and user experience design for Spatial Code Reviewer, including interaction patterns, visual design, accessibility features, and spatial UI components.

## 2. Design Principles

### 2.1 Core Principles

1. **Spatial First**: Design for 3D space, not adapting 2D paradigms
2. **Contextual**: Information appears where it's needed
3. **Minimal Cognitive Load**: Reduce mental overhead through spatial arrangement
4. **Accessible**: Support all users including those with disabilities
5. **Performance**: UI should never compromise frame rate (60fps minimum)

### 2.2 Interaction Philosophy

- **Look to Select**: Gaze-first interaction model
- **Gesture to Manipulate**: Hand gestures for spatial manipulation
- **Voice for Commands**: Natural language for complex operations
- **Progressive Disclosure**: Show details only when needed

## 3. Visual Design System

### 3.1 Color Palette

```swift
enum AppColor {
    // Primary Colors
    static let primary = Color(red: 0/255, green: 122/255, blue: 255/255) // #007AFF
    static let secondary = Color(red: 88/255, green: 86/255, blue: 214/255) // #5856D6

    // Semantic Colors
    static let success = Color(red: 52/255, green: 199/255, blue: 89/255) // #34C759
    static let warning = Color(red: 255/255, green: 149/255, blue: 0/255) // #FF9500
    static let error = Color(red: 255/255, green: 59/255, blue: 48/255) // #FF3B30
    static let info = Color(red: 0/255, green: 122/255, blue: 255/255) // #007AFF

    // Neutral Colors (Light Mode)
    static let background = Color(white: 0.95, opacity: 0.95)
    static let surface = Color(white: 1.0, opacity: 0.9)
    static let border = Color(white: 0.8)
    static let textPrimary = Color(white: 0.1)
    static let textSecondary = Color(white: 0.4)

    // Neutral Colors (Dark Mode)
    static let backgroundDark = Color(white: 0.1, opacity: 0.95)
    static let surfaceDark = Color(white: 0.15, opacity: 0.9)
    static let borderDark = Color(white: 0.3)
    static let textPrimaryDark = Color(white: 0.95)
    static let textSecondaryDark = Color(white: 0.6)

    // Syntax Highlighting
    static let syntaxKeyword = Color(red: 175/255, green: 0/255, blue: 219/255)
    static let syntaxString = Color(red: 209/255, green: 47/255, blue: 27/255)
    static let syntaxNumber = Color(red: 28/255, green: 0/255, blue: 207/255)
    static let syntaxComment = Color(white: 0.5)
    static let syntaxFunction = Color(red: 62/255, green: 0/255, blue: 255/255)
    static let syntaxType = Color(red: 0/255, green: 134/255, blue: 140/255)

    // Dependency Type Colors
    static let dependencyImport = Color.blue
    static let dependencyInheritance = Color.green
    static let dependencyCall = Color.orange
    static let dependencyReference = Color.gray
}
```

### 3.2 Typography

```swift
enum AppFont {
    // Code Fonts
    static let codeRegular = Font.custom("SF Mono", size: 14)
    static let codeMedium = Font.custom("SF Mono", size: 16)
    static let codeLarge = Font.custom("SF Mono", size: 18)

    // UI Fonts
    static let largeTitle = Font.largeTitle.weight(.bold)
    static let title = Font.title.weight(.semibold)
    static let title2 = Font.title2.weight(.semibold)
    static let title3 = Font.title3.weight(.semibold)
    static let headline = Font.headline
    static let body = Font.body
    static let callout = Font.callout
    static let subheadline = Font.subheadline
    static let footnote = Font.footnote
    static let caption = Font.caption
    static let caption2 = Font.caption2

    // Line Heights
    static let codeLineHeight: CGFloat = 1.5
    static let bodyLineHeight: CGFloat = 1.4
}
```

### 3.3 Spacing System

```swift
enum Spacing {
    static let xxxs: CGFloat = 2
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64

    // Spatial Distances (meters)
    static let spatialClose: Float = 0.5
    static let spatialComfortable: Float = 1.5
    static let spatialFar: Float = 3.0
    static let spatialMaximum: Float = 5.0
}
```

### 3.4 Corner Radius

```swift
enum CornerRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let xlarge: CGFloat = 24
}
```

## 4. SwiftUI Components

### 4.1 Code Window

```swift
struct CodeWindowView: View {
    let file: CodeFile
    @Binding var scrollOffset: CGFloat
    @Binding var isFocused: Bool

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            CodeWindowHeader(file: file)

            Divider()

            // Code Content
            ScrollView {
                CodeContentView(
                    code: file.content,
                    language: file.language,
                    highlights: file.syntaxHighlights
                )
            }
            .frame(width: 600, height: 800)
            .background(backgroundColor)
        }
        .background(glassMorphism)
        .cornerRadius(CornerRadius.large)
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.large)
                .stroke(borderColor, lineWidth: isFocused ? 3 : 1)
        )
        .shadow(radius: 10)
    }

    private var backgroundColor: Color {
        colorScheme == .dark ? AppColor.backgroundDark : AppColor.background
    }

    private var borderColor: Color {
        isFocused ? AppColor.primary : (colorScheme == .dark ? AppColor.borderDark : AppColor.border)
    }

    private var glassMorphism: some ShapeStyle {
        .ultraThinMaterial
    }
}

struct CodeWindowHeader: View {
    let file: CodeFile

    var body: some View {
        HStack {
            // File icon
            Image(systemName: iconForLanguage(file.language))
                .foregroundColor(colorForLanguage(file.language))

            // File path
            VStack(alignment: .leading, spacing: 2) {
                Text(file.name)
                    .font(AppFont.headline)

                Text(file.relativePath)
                    .font(AppFont.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Metadata
            HStack(spacing: Spacing.md) {
                Label("\(file.lineCount) lines", systemImage: "text.alignleft")
                    .font(AppFont.caption)
                    .foregroundColor(.secondary)

                Label(file.language.rawValue, systemImage: "chevron.left.forwardslash.chevron.right")
                    .font(AppFont.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(Spacing.md)
    }

    private func iconForLanguage(_ language: Language) -> String {
        switch language {
        case .swift: return "swift"
        case .javascript, .typescript: return "curlybraces"
        case .python: return "function"
        default: return "doc.text"
        }
    }

    private func colorForLanguage(_ language: Language) -> Color {
        switch language {
        case .swift: return .orange
        case .javascript: return .yellow
        case .typescript: return .blue
        case .python: return .green
        default: return .gray
        }
    }
}
```

### 4.2 Code Content with Syntax Highlighting

```swift
struct CodeContentView: View {
    let code: String
    let language: Language
    let highlights: [SyntaxHighlight]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(code.components(separatedBy: .newlines).enumerated()), id: \.offset) { lineNumber, line in
                HStack(alignment: .top, spacing: Spacing.sm) {
                    // Line number
                    Text("\(lineNumber + 1)")
                        .font(AppFont.codeRegular)
                        .foregroundColor(.secondary)
                        .frame(width: 40, alignment: .trailing)
                        .padding(.trailing, Spacing.xs)

                    // Code line with syntax highlighting
                    SyntaxHighlightedText(
                        text: line,
                        highlights: highlights.filter { highlight in
                            isInLine(highlight, lineNumber: lineNumber)
                        }
                    )
                    .font(AppFont.codeRegular)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer()
                }
                .padding(.vertical, 2)
                .background(lineNumber % 2 == 0 ? Color.clear : Color.gray.opacity(0.05))
            }
        }
        .padding(Spacing.md)
    }

    private func isInLine(_ highlight: SyntaxHighlight, lineNumber: Int) -> Bool {
        // Determine if highlight applies to this line
        // Would need to calculate based on highlight.range and line breaks
        return true // Simplified
    }
}

struct SyntaxHighlightedText: View {
    let text: String
    let highlights: [SyntaxHighlight]

    var body: some View {
        // This would need to properly apply highlighting
        // For now, showing simplified version
        Text(text)
            .foregroundColor(AppColor.textPrimary)
    }
}
```

### 4.3 Issue Card

```swift
struct IssueCardView: View {
    let issue: Issue

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Header
            HStack {
                Image(systemName: iconForSeverity(issue.severity))
                    .foregroundColor(colorForSeverity(issue.severity))

                VStack(alignment: .leading, spacing: 2) {
                    Text(issue.title)
                        .font(AppFont.headline)

                    Text("#\(issue.number)")
                        .font(AppFont.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: { isExpanded.toggle() }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
            }

            if isExpanded {
                Divider()

                // Description
                if let description = issue.description {
                    Text(description)
                        .font(AppFont.body)
                        .lineLimit(5)
                }

                // Metadata
                HStack {
                    Label(issue.author, systemImage: "person")
                        .font(AppFont.caption)

                    Spacer()

                    Label(issue.createdAt.formatted(), systemImage: "clock")
                        .font(AppFont.caption)
                }
                .foregroundColor(.secondary)

                // Actions
                HStack {
                    Button("View on GitHub") {
                        // Open in browser
                    }
                    .buttonStyle(.bordered)

                    Button("Link to Code") {
                        // Link issue to code location
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding(Spacing.md)
        .frame(width: 300)
        .background(.ultraThinMaterial)
        .cornerRadius(CornerRadius.medium)
        .shadow(radius: 5)
    }

    private func iconForSeverity(_ severity: Issue.Severity) -> String {
        switch severity {
        case .critical: return "exclamationmark.triangle.fill"
        case .major: return "exclamationmark.circle.fill"
        case .minor: return "info.circle.fill"
        case .info: return "info.circle"
        }
    }

    private func colorForSeverity(_ severity: Issue.Severity) -> Color {
        switch severity {
        case .critical: return AppColor.error
        case .major: return AppColor.warning
        case .minor: return AppColor.info
        case .info: return AppColor.secondary
        }
    }
}
```

### 4.4 Participant Avatar UI

```swift
struct ParticipantAvatarView: View {
    let participant: Participant
    @Binding var isActive: Bool

    var body: some View {
        VStack(spacing: Spacing.xs) {
            // Avatar
            AsyncImage(url: participant.avatarURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .resizable()
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(isActive ? AppColor.success : Color.gray, lineWidth: 3)
            )
            .shadow(radius: 5)

            // Name label
            Text(participant.name)
                .font(AppFont.caption)
                .padding(.horizontal, Spacing.xs)
                .padding(.vertical, Spacing.xxs)
                .background(.ultraThinMaterial)
                .cornerRadius(CornerRadius.small)
        }
    }
}
```

### 4.5 Git History Timeline

```swift
struct GitHistoryTimelineView: View {
    let commits: [Commit]
    @Binding var selectedCommit: Commit?

    var body: some View {
        VStack(spacing: 0) {
            // Timeline scrubber
            Slider(
                value: Binding(
                    get: { Double(commits.firstIndex { $0.id == selectedCommit?.id } ?? 0) },
                    set: { selectedCommit = commits[Int($0)] }
                ),
                in: 0...Double(commits.count - 1),
                step: 1.0
            )
            .padding(Spacing.md)

            // Commit details
            if let commit = selectedCommit {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text(commit.message)
                        .font(AppFont.headline)

                    HStack {
                        Label(commit.author, systemImage: "person")
                        Spacer()
                        Label(commit.date.formatted(), systemImage: "clock")
                    }
                    .font(AppFont.caption)
                    .foregroundColor(.secondary)

                    // Play/Pause controls
                    HStack {
                        Button(action: { /* Previous */ }) {
                            Image(systemName: "backward.fill")
                        }

                        Button(action: { /* Play/Pause */ }) {
                            Image(systemName: "play.fill")
                        }

                        Button(action: { /* Next */ }) {
                            Image(systemName: "forward.fill")
                        }

                        Spacer()

                        // Playback speed
                        Menu {
                            Button("1x") { /* Set speed */ }
                            Button("2x") { /* Set speed */ }
                            Button("5x") { /* Set speed */ }
                            Button("10x") { /* Set speed */ }
                        } label: {
                            Label("Speed", systemImage: "gauge")
                        }
                    }
                }
                .padding(Spacing.md)
            }
        }
        .frame(width: 400)
        .background(.ultraThinMaterial)
        .cornerRadius(CornerRadius.medium)
        .shadow(radius: 10)
    }
}
```

## 5. Gesture Interactions

### 5.1 Gesture Definitions

```swift
enum SpatialGesture {
    case tap(location: CGPoint)
    case doubleTap(location: CGPoint)
    case longPress(location: CGPoint, duration: TimeInterval)
    case pinch(scale: Float, location: CGPoint)
    case drag(translation: SIMD3<Float>, location: CGPoint)
    case rotate(angle: Float, location: CGPoint)
}

struct GestureHandler {
    func handle(_ gesture: SpatialGesture, on entity: Entity) {
        switch gesture {
        case .tap(let location):
            handleTap(on: entity, at: location)

        case .doubleTap(let location):
            handleDoubleTap(on: entity, at: location)

        case .longPress(let location, let duration):
            handleLongPress(on: entity, at: location, duration: duration)

        case .pinch(let scale, _):
            handlePinch(on: entity, scale: scale)

        case .drag(let translation, _):
            handleDrag(on: entity, translation: translation)

        case .rotate(let angle, _):
            handleRotate(on: entity, angle: angle)
        }
    }

    private func handleTap(on entity: Entity, at location: CGPoint) {
        if let codeWindow = entity as? CodeWindowEntity {
            // Focus on code window
            codeWindow.setFocus(true)
        } else if let issueMarker = entity as? IssueMarkerEntity {
            // Show issue details
            showIssueDetails(issueMarker.issue)
        }
    }

    private func handleDoubleTap(on entity: Entity, at location: CGPoint) {
        if let codeWindow = entity as? CodeWindowEntity {
            // Maximize code window
            animateToFocusMode(codeWindow)
        }
    }

    private func handleLongPress(on entity: Entity, at location: CGPoint, duration: TimeInterval) {
        // Show context menu
        showContextMenu(for: entity, at: location)
    }

    private func handlePinch(on entity: Entity, scale: Float) {
        // Scale entity
        var transform = entity.transform
        transform.scale *= SIMD3<Float>(repeating: scale)
        entity.transform = transform
    }

    private func handleDrag(on entity: Entity, translation: SIMD3<Float>) {
        // Move entity
        entity.position += translation
    }

    private func handleRotate(on entity: Entity, angle: Float) {
        // Rotate entity
        let rotation = simd_quatf(angle: angle, axis: SIMD3<Float>(0, 1, 0))
        entity.orientation *= rotation
    }
}
```

### 5.2 Eye Tracking Interactions

```swift
struct EyeTrackingInteraction {
    func handleGaze(on entity: Entity, duration: TimeInterval) {
        if duration > 0.5 {
            // Highlight entity after brief gaze
            highlightEntity(entity)
        }

        if duration > 1.5 {
            // Auto-focus after sustained gaze
            focusEntity(entity)
        }
    }

    private func highlightEntity(_ entity: Entity) {
        // Add subtle highlight effect
        if let model = entity as? ModelEntity {
            // Pulse animation or glow effect
        }
    }

    private func focusEntity(_ entity: Entity) {
        // Bring entity to front, show details
    }
}
```

## 6. Voice Commands

### 6.1 Voice Command System

```swift
enum VoiceCommand {
    case showFile(String)
    case hideFile(String)
    case showDependencies(String)
    case focusOn(String)
    case openPullRequest(Int)
    case showIssues
    case switchLayout(LayoutType)
    case zoomIn
    case zoomOut
    case reset
}

class VoiceCommandProcessor {
    func process(_ utterance: String) -> VoiceCommand? {
        let lowercased = utterance.lowercased()

        // Pattern matching for commands
        if lowercased.contains("show file") || lowercased.contains("open file") {
            let filename = extractFilename(from: utterance)
            return .showFile(filename)
        }

        if lowercased.contains("hide file") || lowercased.contains("close file") {
            let filename = extractFilename(from: utterance)
            return .hideFile(filename)
        }

        if lowercased.contains("show dependencies") {
            let filename = extractFilename(from: utterance)
            return .showDependencies(filename)
        }

        if lowercased.contains("focus on") {
            let target = extractTarget(from: utterance)
            return .focusOn(target)
        }

        if lowercased.contains("pull request") || lowercased.contains("pr") {
            if let number = extractNumber(from: utterance) {
                return .openPullRequest(number)
            }
        }

        if lowercased.contains("show issues") || lowercased.contains("list issues") {
            return .showIssues
        }

        if lowercased.contains("hemisphere") || lowercased.contains("default layout") {
            return .switchLayout(.hemisphere)
        }

        if lowercased.contains("focus mode") {
            return .switchLayout(.focus)
        }

        if lowercased.contains("comparison") || lowercased.contains("side by side") {
            return .switchLayout(.comparison)
        }

        if lowercased.contains("architecture") || lowercased.contains("graph view") {
            return .switchLayout(.architecture)
        }

        if lowercased.contains("zoom in") || lowercased.contains("closer") {
            return .zoomIn
        }

        if lowercased.contains("zoom out") || lowercased.contains("farther") {
            return .zoomOut
        }

        if lowercased.contains("reset") {
            return .reset
        }

        return nil
    }

    private func extractFilename(from utterance: String) -> String {
        // Extract filename from utterance
        // Simplified implementation
        let words = utterance.components(separatedBy: .whitespaces)
        return words.last ?? ""
    }

    private func extractTarget(from utterance: String) -> String {
        // Extract target from utterance
        return ""
    }

    private func extractNumber(from utterance: String) -> Int? {
        // Extract number from utterance
        let components = utterance.components(separatedBy: CharacterSet.decimalDigits.inverted)
        for component in components {
            if let number = Int(component) {
                return number
            }
        }
        return nil
    }
}
```

## 7. Accessibility

### 7.1 VoiceOver Support

```swift
extension CodeWindowEntity {
    func configureAccessibility() {
        // Enable VoiceOver
        accessibilityLabel = "Code window for \(codeWindow.filePath)"
        accessibilityHint = "Double tap to focus, pinch to resize"
        accessibilityTraits = [.button, .updatesFrequently]

        // Custom actions
        accessibilityCustomActions = [
            UIAccessibilityCustomAction(name: "Focus") { _ in
                self.setFocus(true)
                return true
            },
            UIAccessibilityCustomAction(name: "Close") { _ in
                self.removeFromParent()
                return true
            },
            UIAccessibilityCustomAction(name: "Show dependencies") { _ in
                // Show dependencies
                return true
            }
        ]
    }
}
```

### 7.2 Reduced Motion

```swift
struct ReducedMotionModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    func body(content: Content) -> some View {
        content
            .animation(reduceMotion ? .none : .default, value: UUID())
    }
}

extension View {
    func respectReducedMotion() -> some View {
        modifier(ReducedMotionModifier())
    }
}
```

### 7.3 High Contrast Mode

```swift
struct HighContrastModifier: ViewModifier {
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency

    func body(content: Content) -> some View {
        content
            .if(differentiateWithoutColor) { view in
                view.border(Color.primary, width: 2)
            }
            .if(reduceTransparency) { view in
                view.background(.background)
            }
    }
}

extension View {
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        condition ? AnyView(transform(self)) : AnyView(self)
    }
}
```

## 8. Onboarding & Tutorials

### 8.1 Onboarding Flow

```swift
struct OnboardingView: View {
    @State private var currentStep = 0

    var body: some View {
        TabView(selection: $currentStep) {
            WelcomeStep()
                .tag(0)

            GesturesTutorialStep()
                .tag(1)

            VoiceCommandsTutorialStep()
                .tag(2)

            LayoutsTutorialStep()
                .tag(3)

            CompletionStep()
                .tag(4)
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

struct GesturesTutorialStep: View {
    @State private var hasCompletedTap = false
    @State private var hasCompletedPinch = false
    @State private var hasCompletedDrag = false

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Text("Learn Gestures")
                .font(AppFont.largeTitle)

            VStack(alignment: .leading, spacing: Spacing.md) {
                GestureInstructionRow(
                    icon: "hand.tap",
                    title: "Tap",
                    description: "Select code windows",
                    completed: hasCompletedTap
                )

                GestureInstructionRow(
                    icon: "hand.pinch",
                    title: "Pinch",
                    description: "Resize code windows",
                    completed: hasCompletedPinch
                )

                GestureInstructionRow(
                    icon: "hand.drag",
                    title: "Drag",
                    description: "Move code windows",
                    completed: hasCompletedDrag
                )
            }

            Spacer()

            // Practice area
            Text("Try it out!")
                .font(AppFont.headline)

            // Interactive tutorial content
        }
        .padding(Spacing.xl)
    }
}

struct GestureInstructionRow: View {
    let icon: String
    let title: String
    let description: String
    let completed: Bool

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.title)
                .frame(width: 50)

            VStack(alignment: .leading) {
                Text(title)
                    .font(AppFont.headline)
                Text(description)
                    .font(AppFont.body)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if completed {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(AppColor.success)
            }
        }
        .padding(Spacing.md)
        .background(completed ? AppColor.success.opacity(0.1) : Color.gray.opacity(0.1))
        .cornerRadius(CornerRadius.medium)
    }
}
```

## 9. Performance UI Feedback

### 9.1 Loading States

```swift
struct LoadingOverlay: View {
    let message: String

    var body: some View {
        VStack(spacing: Spacing.md) {
            ProgressView()
                .scaleEffect(1.5)

            Text(message)
                .font(AppFont.headline)
        }
        .padding(Spacing.xl)
        .background(.ultraThinMaterial)
        .cornerRadius(CornerRadius.large)
        .shadow(radius: 10)
    }
}
```

### 9.2 Frame Rate Indicator

```swift
struct FrameRateIndicator: View {
    @ObservedObject var performanceMonitor: PerformanceMonitor

    var body: some View {
        HStack {
            Circle()
                .fill(colorForFPS(performanceMonitor.currentFPS))
                .frame(width: 8, height: 8)

            Text("\(Int(performanceMonitor.currentFPS)) FPS")
                .font(AppFont.caption)
                .monospacedDigit()
        }
        .padding(Spacing.xs)
        .background(.ultraThinMaterial)
        .cornerRadius(CornerRadius.small)
    }

    private func colorForFPS(_ fps: Double) -> Color {
        if fps >= 55 { return AppColor.success }
        if fps >= 30 { return AppColor.warning }
        return AppColor.error
    }
}
```

## 10. Error States

### 10.1 Error Dialog

```swift
struct ErrorDialog: View {
    let error: Error
    let retry: (() -> Void)?

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(AppColor.error)

            Text("Something went wrong")
                .font(AppFont.title2)

            Text(error.localizedDescription)
                .font(AppFont.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: Spacing.md) {
                Button("Dismiss") {
                    // Dismiss
                }
                .buttonStyle(.bordered)

                if let retry = retry {
                    Button("Try Again") {
                        retry()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding(Spacing.xl)
        .frame(width: 400)
        .background(.ultraThinMaterial)
        .cornerRadius(CornerRadius.large)
        .shadow(radius: 20)
    }
}
```

## 11. References

- [System Architecture Document](./01-system-architecture.md)
- [3D Rendering & Spatial Layout](./03-spatial-rendering.md)
- Apple Human Interface Guidelines for visionOS
- Apple Accessibility Guidelines

## 12. Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-11-24 | Engineering Team | Initial draft |
