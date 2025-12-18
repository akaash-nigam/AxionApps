# UI/UX Design & Interaction Specification
## Reality Annotation Platform

**Version**: 1.0
**Date**: November 2024
**Status**: Draft

---

## 1. Overview

This document defines the user interface, user experience, and interaction patterns for the Reality Annotation Platform on visionOS. It covers spatial UI, gestures, voice commands, and navigation.

---

## 2. visionOS Design Principles

### 2.1 Spatial Design Fundamentals

1. **Depth & Dimension**: Use 3D space effectively
2. **Clarity**: Make UI elements easy to understand and interact with
3. **Comfort**: Design for extended use without eye strain
4. **Intentionality**: Require deliberate user actions
5. **Spatial Awareness**: Respect user's physical environment

### 2.2 visionOS Window Types

```swift
// 1. Window - Traditional 2D interface
WindowGroup {
    ContentView()
}

// 2. Volume - 3D bounded space
WindowGroup(id: "volume") {
    VolumeView()
}
.windowStyle(.volumetric)

// 3. Immersive Space - Full AR experience
ImmersiveSpace(id: "immersive") {
    ImmersiveView()
}
.immersionStyle(selection: .constant(.mixed), in: .mixed)
```

---

## 3. Application Structure

### 3.1 Main Navigation

```
App Structure:
├── Window (2D UI)
│   ├── Home Tab
│   │   ├── Recent Annotations
│   │   ├── Layers List
│   │   └── Quick Actions
│   ├── Search Tab
│   │   ├── Search Bar
│   │   ├── Filters
│   │   └── Results
│   ├── Activity Tab
│   │   ├── Activity Feed
│   │   └── Notifications
│   └── Settings Tab
│       ├── Account
│       ├── Preferences
│       └── About
│
└── Immersive Space (AR)
    ├── Spatial Annotations (RealityKit)
    ├── Floating Controls (Attachments)
    └── Contextual Menus
```

### 3.2 App Entry Point

```swift
@main
struct RealityAnnotationApp: App {
    @StateObject private var appState = AppState.shared

    var body: some Scene {
        // Main 2D window
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
        .windowResizability(.contentSize)

        // AR immersive space
        ImmersiveSpace(id: "ar-space") {
            ImmersiveView()
                .environmentObject(appState)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
```

---

## 4. Screen Designs

### 4.1 Home Screen (Window)

```swift
struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = HomeViewModel()
    @Environment(\.openImmersiveSpace) var openImmersiveSpace

    var body: some View {
        NavigationSplitView {
            // Sidebar
            List {
                Section("Quick Actions") {
                    Button {
                        Task {
                            await openImmersiveSpace(id: "ar-space")
                        }
                    } label: {
                        Label("Enter AR Mode", systemImage: "visionpro")
                    }
                }

                Section("Layers") {
                    ForEach(viewModel.layers) { layer in
                        LayerRow(layer: layer)
                    }
                }
            }
            .navigationTitle("Reality Annotations")
        } detail: {
            // Detail view
            RecentAnnotationsView()
        }
    }
}

struct LayerRow: View {
    let layer: Layer

    var body: some View {
        HStack {
            Image(systemName: layer.icon)
                .foregroundStyle(layer.color.swiftUIColor)

            Text(layer.name)

            Spacer()

            Text("\(layer.annotations.count)")
                .foregroundStyle(.secondary)
                .font(.caption)
        }
    }
}
```

### 4.2 Immersive AR View

```swift
struct ImmersiveView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ImmersiveViewModel()

    var body: some View {
        RealityView { content, attachments in
            // Setup AR scene
            await viewModel.setupScene(content: content)
        } update: { content, attachments in
            // Update annotations
            viewModel.updateAnnotations(content: content)
        } attachments: {
            // Floating controls
            Attachment(id: "controls") {
                ARControlsView(viewModel: viewModel)
            }

            // Annotation creation panel
            Attachment(id: "create-panel") {
                CreateAnnotationPanel(viewModel: viewModel)
            }
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    viewModel.handleTap(on: value.entity, at: value.location3D)
                }
        )
    }
}
```

### 4.3 AR Controls (Floating Attachment)

```swift
struct ARControlsView: View {
    @ObservedObject var viewModel: ImmersiveViewModel

    var body: some View {
        HStack(spacing: 20) {
            // Layer toggle
            Menu {
                ForEach(viewModel.layers) { layer in
                    Button {
                        viewModel.toggleLayer(layer.id)
                    } label: {
                        Label(
                            layer.name,
                            systemImage: layer.isVisible ? "checkmark" : ""
                        )
                    }
                }
            } label: {
                Label("Layers", systemImage: "square.stack.3d.up")
            }

            Divider()

            // Create annotation
            Button {
                viewModel.showCreatePanel()
            } label: {
                Label("Create", systemImage: "plus")
            }

            // Search
            Button {
                viewModel.showSearch()
            } label: {
                Label("Search", systemImage: "magnifyingglass")
            }

            // Settings
            Button {
                viewModel.showSettings()
            } label: {
                Label("Settings", systemImage: "gear")
            }
        }
        .padding()
        .glassBackgroundEffect()
    }
}
```

### 4.4 Annotation Creation Panel

```swift
struct CreateAnnotationPanel: View {
    @ObservedObject var viewModel: ImmersiveViewModel
    @State private var text = ""
    @State private var selectedType: AnnotationType = .text
    @State private var selectedLayer: Layer?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Create Annotation")
                .font(.title2)

            // Type picker
            Picker("Type", selection: $selectedType) {
                Label("Text", systemImage: "text.bubble").tag(AnnotationType.text)
                Label("Photo", systemImage: "photo").tag(AnnotationType.photo)
                Label("Voice", systemImage: "mic").tag(AnnotationType.voiceMemo)
                Label("Drawing", systemImage: "pencil.tip").tag(AnnotationType.drawing)
            }
            .pickerStyle(.segmented)

            // Content input
            switch selectedType {
            case .text:
                TextEditor(text: $text)
                    .frame(height: 150)
                    .padding(8)
                    .background(.regularMaterial)
                    .cornerRadius(8)

            case .photo:
                PhotoPicker(selection: $viewModel.selectedPhoto)

            case .voiceMemo:
                VoiceRecorderView()

            case .drawing:
                DrawingCanvasView()

            default:
                EmptyView()
            }

            // Layer selection
            Picker("Layer", selection: $selectedLayer) {
                ForEach(viewModel.layers) { layer in
                    HStack {
                        Image(systemName: layer.icon)
                        Text(layer.name)
                    }
                    .tag(layer as Layer?)
                }
            }

            // Actions
            HStack {
                Button("Cancel") {
                    viewModel.dismissCreatePanel()
                }
                .buttonStyle(.bordered)

                Spacer()

                Button("Create") {
                    Task {
                        await viewModel.createAnnotation(
                            content: text,
                            type: selectedType,
                            layer: selectedLayer
                        )
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(text.isEmpty && selectedType == .text)
            }
        }
        .padding()
        .frame(width: 400)
        .glassBackgroundEffect()
    }
}
```

### 4.5 Annotation Detail View

```swift
struct AnnotationDetailView: View {
    let annotation: Annotation
    @StateObject private var viewModel: AnnotationDetailViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    Image(systemName: annotation.type.icon)
                        .font(.title)

                    VStack(alignment: .leading) {
                        Text(annotation.title ?? "Annotation")
                            .font(.title2)

                        Text(annotation.createdAt, style: .relative)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    // More menu
                    Menu {
                        Button("Edit", systemImage: "pencil") {
                            viewModel.edit()
                        }

                        Button("Share", systemImage: "square.and.arrow.up") {
                            viewModel.share()
                        }

                        Button("Delete", systemImage: "trash", role: .destructive) {
                            viewModel.delete()
                        }
                    } label: {
                        Label("More", systemImage: "ellipsis.circle")
                    }
                }

                Divider()

                // Content
                switch annotation.type {
                case .text:
                    Text(annotation.content.text ?? "")
                        .font(.body)

                case .photo:
                    if let url = annotation.content.mediaURL {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(maxHeight: 300)
                        .cornerRadius(12)
                    }

                case .voiceMemo:
                    AudioPlayerView(url: annotation.content.mediaURL)

                default:
                    Text("Unsupported content type")
                        .foregroundStyle(.secondary)
                }

                Divider()

                // Metadata
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("Layer", systemImage: "square.stack")
                        Spacer()
                        Text(annotation.layer?.name ?? "Unknown")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Label("Created", systemImage: "calendar")
                        Spacer()
                        Text(annotation.createdAt, style: .date)
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Label("Owner", systemImage: "person")
                        Spacer()
                        Text(viewModel.ownerName)
                            .foregroundStyle(.secondary)
                    }
                }
                .font(.subheadline)

                Divider()

                // Reactions
                ReactionBar(annotation: annotation)

                Divider()

                // Comments
                CommentsSection(annotation: annotation)
            }
            .padding()
        }
        .frame(width: 500)
    }
}
```

---

## 5. Interaction Patterns

### 5.1 Spatial Gestures

```swift
// Tap to select
SpatialTapGesture()
    .targetedToAnyEntity()
    .onEnded { value in
        if let annotation = value.entity as? AnnotationEntity {
            showDetail(annotation)
        }
    }

// Long press for context menu
LongPressGesture(minimumDuration: 0.5)
    .targetedToEntity(annotationEntity)
    .onEnded { _ in
        showContextMenu()
    }

// Drag to move
DragGesture()
    .targetedToEntity(annotationEntity)
    .onChanged { value in
        moveAnnotation(to: value.location3D)
    }
    .onEnded { _ in
        saveAnnotationPosition()
    }
```

### 5.2 Gaze + Pinch

```swift
class GazeInteractionManager {
    func handleGaze(at point: SIMD3<Float>) {
        // Highlight annotation under gaze
        if let annotation = findAnnotation(at: point) {
            highlight(annotation)
        }
    }

    func handlePinch() {
        // Select highlighted annotation
        if let highlighted = currentHighlighted {
            select(highlighted)
        }
    }
}

// In RealityView
.gesture(
    TapGesture()
        .targetedToAnyEntity()
        .onEnded { value in
            gazeManager.handlePinch()
        }
)
```

### 5.3 Voice Commands

```swift
import Speech

class VoiceCommandManager {
    func startListening() {
        // Request authorization
        // Start speech recognition
    }

    func processCommand(_ text: String) {
        let lowercased = text.lowercased()

        if lowercased.contains("create note") {
            showCreatePanel()
        } else if lowercased.contains("show all") {
            showAllAnnotations()
        } else if lowercased.contains("hide layer") {
            // Extract layer name and hide it
        } else if lowercased.contains("search for") {
            // Extract search query
            let query = extractQuery(from: text)
            performSearch(query)
        }
    }
}

// Supported commands:
// "Create note here"
// "Show all annotations"
// "Hide layer [name]"
// "Search for [query]"
// "Delete this annotation"
// "Share with [person]"
```

---

## 6. Spatial Annotation Appearance

### 6.1 Annotation Entity Design

```swift
class AnnotationEntity: Entity {
    // Visual components
    var cardEntity: ModelEntity
    var iconEntity: ModelEntity
    var textAttachment: ViewAttachmentEntity

    func setupAppearance(for annotation: Annotation) {
        // Card background
        let card = createCard(
            width: 0.3,
            height: 0.2,
            color: annotation.layer?.color ?? .blue
        )
        addChild(card)

        // Icon
        let icon = createIcon(annotation.type.systemImage)
        icon.position = SIMD3(-0.14, 0.08, 0.01)
        addChild(icon)

        // Text content (SwiftUI attachment)
        let textView = ViewAttachmentEntity(
            AnnotationContentView(annotation: annotation)
        )
        textView.position = SIMD3(0, 0, 0.01)
        addChild(textView)
    }

    private func createCard(width: Float, height: Float, color: LayerColor) -> ModelEntity {
        let mesh = MeshResource.generatePlane(width: width, height: height)

        var material = UnlitMaterial()
        material.color = .init(tint: color.uiColor.withAlphaComponent(0.9))
        material.blending = .transparent

        return ModelEntity(mesh: mesh, materials: [material])
    }
}

struct AnnotationContentView: View {
    let annotation: Annotation

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let title = annotation.title {
                Text(title)
                    .font(.headline)
            }

            if let text = annotation.content.text {
                Text(text)
                    .font(.body)
                    .lineLimit(3)
            }

            HStack {
                Text(annotation.createdAt, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Spacer()

                if annotation.comments.count > 0 {
                    Label("\(annotation.comments.count)", systemImage: "bubble.left")
                        .font(.caption2)
                }
            }
        }
        .padding(8)
        .frame(width: 250)
    }
}
```

### 6.2 Billboard Behavior

```swift
extension AnnotationEntity {
    func updateBillboard(cameraPosition: SIMD3<Float>) {
        let position = position(relativeTo: nil)
        let direction = normalize(cameraPosition - position)

        // Calculate rotation to face camera
        let up = SIMD3<Float>(0, 1, 0)
        let right = normalize(cross(up, direction))
        let trueUp = cross(direction, right)

        let rotation = simd_quatf(
            simd_float3x3(right, trueUp, direction)
        )

        // Apply rotation smoothly
        let currentRotation = orientation
        orientation = simd_slerp(currentRotation, rotation, 0.1)
    }
}
```

---

## 7. Ornaments & Floating UI

### 7.1 Ornaments (attached to windows)

```swift
struct ContentView: View {
    var body: some View {
        NavigationStack {
            AnnotationListView()
        }
        .ornament(attachmentAnchor: .scene(.bottom)) {
            BottomToolbar()
        }
    }
}

struct BottomToolbar: View {
    var body: some View {
        HStack(spacing: 16) {
            Button("New", systemImage: "plus") { }
            Button("Search", systemImage: "magnifyingglass") { }
            Button("Filter", systemImage: "line.3.horizontal.decrease") { }
        }
        .padding()
        .glassBackgroundEffect()
    }
}
```

### 7.2 Floating Attachments (in AR)

```swift
// In RealityView attachments
Attachment(id: "floating-menu") {
    Menu {
        Button("Edit") { }
        Button("Share") { }
        Button("Delete") { }
    } label: {
        Label("Actions", systemImage: "ellipsis")
    }
    .menuStyle(.borderlessButton)
    .padding()
    .glassBackgroundEffect()
}

// Position attachment in 3D space
if let menuAttachment = attachments.entity(for: "floating-menu") {
    menuAttachment.position = SIMD3(0, 1.5, -1.0) // In front of user
}
```

---

## 8. Animation & Transitions

### 8.1 Annotation Appearance

```swift
extension AnnotationEntity {
    func animateAppearance() {
        // Start small and transparent
        scale = SIMD3(repeating: 0.01)
        opacity = 0

        // Animate to full size
        let scaleAnimation = FromToByAnimation(
            to: Transform(scale: SIMD3(repeating: 1.0)),
            duration: 0.3,
            timing: .easeOut
        )

        let opacityAnimation = FromToByAnimation(
            to: Transform(), // opacity handled separately
            duration: 0.3,
            timing: .easeIn
        )

        playAnimation(scaleAnimation)

        // Fade in
        Task {
            try await Task.sleep(for: .milliseconds(100))
            opacity = 1.0
        }
    }

    func animateDisappearance() async {
        let animation = FromToByAnimation(
            to: Transform(scale: SIMD3(repeating: 0.01)),
            duration: 0.2,
            timing: .easeIn
        )

        playAnimation(animation)

        // Fade out
        opacity = 0

        try? await Task.sleep(for: .milliseconds(200))
    }
}
```

### 8.2 UI Transitions

```swift
struct AnnotationListView: View {
    @State private var annotations: [Annotation] = []

    var body: some View {
        List(annotations) { annotation in
            AnnotationRow(annotation: annotation)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
        }
        .animation(.smooth, value: annotations)
    }
}
```

---

## 9. Accessibility

### 9.1 VoiceOver Support

```swift
struct AnnotationRow: View {
    let annotation: Annotation

    var body: some View {
        HStack {
            Image(systemName: annotation.type.icon)
            Text(annotation.title ?? "Untitled")
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(annotation.type.rawValue) annotation: \(annotation.title ?? "Untitled")")
        .accessibilityHint("Double-tap to open")
        .accessibilityAddTraits(.isButton)
    }
}
```

### 9.2 Spatial Audio Cues

```swift
class SpatialAudioManager {
    func playFeedback(for action: UserAction, at position: SIMD3<Float>) {
        let audioResource = getAudioResource(for: action)

        let audioEntity = Entity()
        audioEntity.position = position

        let audioController = audioEntity.prepareAudio(audioResource)
        audioController.play()

        // Clean up after playback
        Task {
            try await Task.sleep(for: .seconds(audioResource.duration))
            audioEntity.removeFromParent()
        }
    }

    private func getAudioResource(for action: UserAction) -> AudioFileResource {
        switch action {
        case .created:
            return AudioFileResource.created
        case .deleted:
            return AudioFileResource.deleted
        case .selected:
            return AudioFileResource.selected
        }
    }
}

enum UserAction {
    case created
    case deleted
    case selected
}
```

---

## 10. Dark Mode & Appearance

```swift
struct AnnotationView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            Text("Annotation")
        }
        .foregroundStyle(colorScheme == .dark ? .white : .black)
        .background(colorScheme == .dark ? .black.opacity(0.8) : .white.opacity(0.8))
    }
}

// Adaptive colors
extension Color {
    static let adaptiveBackground = Color(
        light: Color(white: 0.95),
        dark: Color(white: 0.1)
    )

    static let adaptiveText = Color(
        light: .black,
        dark: .white
    )
}
```

---

## 11. Loading States

```swift
struct AnnotationListView: View {
    @StateObject private var viewModel = AnnotationListViewModel()

    var body: some View {
        Group {
            switch viewModel.loadingState {
            case .idle:
                Text("Tap to load annotations")

            case .loading:
                ProgressView("Loading annotations...")

            case .loaded(let annotations):
                if annotations.isEmpty {
                    ContentUnavailableView(
                        "No Annotations",
                        systemImage: "note.text",
                        description: Text("Create your first annotation in AR mode")
                    )
                } else {
                    List(annotations) { annotation in
                        AnnotationRow(annotation: annotation)
                    }
                }

            case .error(let error):
                ContentUnavailableView(
                    "Error Loading Annotations",
                    systemImage: "exclamationmark.triangle",
                    description: Text(error.localizedDescription)
                )
            }
        }
        .task {
            await viewModel.loadAnnotations()
        }
    }
}

enum LoadingState {
    case idle
    case loading
    case loaded([Annotation])
    case error(Error)
}
```

---

## 12. Appendix

### 12.1 Design Assets

**SF Symbols Used**:
- `note.text` - Text annotations
- `photo` - Photo annotations
- `mic` - Voice memos
- `pencil.tip` - Drawings
- `square.stack.3d.up` - Layers
- `person.3` - Collaboration
- `magnifyingglass` - Search
- `visionpro` - AR mode

### 12.2 Color Palette

```swift
extension LayerColor {
    var swiftUIColor: Color {
        switch self {
        case .red: return .red
        case .orange: return .orange
        case .yellow: return .yellow
        case .green: return .green
        case .blue: return .blue
        case .purple: return .purple
        case .pink: return .pink
        case .gray: return .gray
        }
    }
}
```

### 12.3 References

- [visionOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/visionos)
- [SwiftUI for visionOS](https://developer.apple.com/documentation/swiftui/bringing-your-app-to-visionos)
- [RealityKit UI](https://developer.apple.com/documentation/realitykit/creating-3d-content-with-realitykit)

---

**Document Status**: ✅ Ready for Implementation
**Dependencies**: System Architecture, Data Model
**Next Steps**: Create Performance & Optimization Plan document
