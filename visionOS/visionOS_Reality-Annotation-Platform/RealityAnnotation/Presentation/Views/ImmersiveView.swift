//
//  ImmersiveView.swift
//  Reality Annotation Platform
//
//  AR immersive space view
//

import SwiftUI
import RealityKit

struct ImmersiveView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = ImmersiveViewModel()

    var body: some View {
        RealityView { content, attachments in
            // Initialize AR scene
            await viewModel.setupScene(content: content)
        } update: { content, attachments in
            // Update scene with latest annotations
            viewModel.updateAnnotations(content: content)
        } attachments: {
            // Floating AR controls
            Attachment(id: "controls") {
                ARControlsView(viewModel: viewModel)
            }

            // Annotation creation panel (conditional)
            if viewModel.isShowingCreatePanel {
                Attachment(id: "create-panel") {
                    CreateAnnotationPanel(viewModel: viewModel)
                }
            }
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    viewModel.handleTap(at: value.convert(value.location3D, from: .local, to: .scene))
                }
        )
        .task {
            await viewModel.startARSession()
        }
        .onDisappear {
            viewModel.stopARSession()
        }
    }
}

// MARK: - AR Controls View

struct ARControlsView: View {
    @ObservedObject var viewModel: ImmersiveViewModel

    var body: some View {
        HStack(spacing: 20) {
            // Create annotation button
            Button {
                viewModel.showCreatePanel()
            } label: {
                Label("Create", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderedProminent)

            Divider()
                .frame(height: 24)

            // Layer toggle
            Button {
                viewModel.toggleLayersMenu()
            } label: {
                Label("Layers", systemImage: "square.stack.3d.up")
            }
            .buttonStyle(.bordered)

            // Refresh/reload
            Button {
                Task {
                    await viewModel.reloadAnnotations()
                }
            } label: {
                Label("Reload", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .glassBackgroundEffect()
    }
}

// MARK: - Create Annotation Panel

struct CreateAnnotationPanel: View {
    @ObservedObject var viewModel: ImmersiveViewModel
    @State private var text = ""
    @State private var title = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Create Annotation")
                    .font(.title2)
                    .bold()

                Spacer()

                Button {
                    viewModel.dismissCreatePanel()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            Divider()

            // Title input
            VStack(alignment: .leading, spacing: 8) {
                Text("Title (optional)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                TextField("Enter title", text: $title)
                    .textFieldStyle(.roundedBorder)
            }

            // Content input
            VStack(alignment: .leading, spacing: 8) {
                Text("Content")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                TextEditor(text: $text)
                    .frame(height: 150)
                    .padding(8)
                    .background(.regularMaterial)
                    .cornerRadius(8)
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
                            title: title.isEmpty ? nil : title,
                            content: text
                        )
                        text = ""
                        title = ""
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(text.isEmpty)
            }
        }
        .padding(24)
        .frame(width: 400)
        .glassBackgroundEffect()
    }
}

// MARK: - Immersive ViewModel

@MainActor
class ImmersiveViewModel: ObservableObject {
    @Published var isShowingCreatePanel = false
    @Published var annotations: [Annotation] = []
    @Published var arSessionState: ARSessionState = .stopped

    // AR Components
    private let arSessionManager = ARSessionManager()
    private let anchorManager = AnchorManager()
    private var annotationRenderer: AnnotationRenderer?

    // Services
    private let annotationService: AnnotationService
    private let layerService: LayerService

    // State
    private var rootEntity: Entity?
    private var pendingPosition: SIMD3<Float>?
    private var updateTask: Task<Void, Never>?
    private var isSceneSetup = false

    // MARK: - Initialization

    init(
        annotationService: AnnotationService? = nil,
        layerService: LayerService? = nil
    ) {
        let container = ServiceContainer.shared
        self.annotationService = annotationService ?? container.annotationService
        self.layerService = layerService ?? container.layerService
    }

    // MARK: - Scene Setup

    func setupScene(content: RealityViewContent) async {
        guard !isSceneSetup else { return }
        print("🎯 Setting up AR scene")

        // Create root entity for all annotations
        let root = Entity()
        content.add(root)
        self.rootEntity = root

        // Initialize renderer
        let renderer = AnnotationRenderer(anchorManager: anchorManager)
        renderer.setRootEntity(root)
        self.annotationRenderer = renderer

        isSceneSetup = true

        // Load existing annotations
        await loadAnnotations()

        // Start update loop
        startUpdateLoop()
    }

    func updateAnnotations(content: RealityViewContent) {
        // RealityView update callback - not used for frame updates
        // We use startUpdateLoop() instead for continuous updates
    }

    // MARK: - Update Loop

    private func startUpdateLoop() {
        updateTask?.cancel()
        updateTask = Task {
            var lastTime = Date()

            while !Task.isCancelled {
                // Calculate delta time
                let now = Date()
                let deltaTime = now.timeIntervalSince(lastTime)
                lastTime = now

                // Get camera position (simplified - in production use ARKit camera)
                let cameraPosition = SIMD3<Float>(0, 1.6, 0) // Average eye height

                // Update renderer
                annotationRenderer?.update(
                    cameraPosition: cameraPosition,
                    deltaTime: deltaTime
                )

                // Wait for next frame (target ~90 FPS for Vision Pro)
                try? await Task.sleep(nanoseconds: 11_000_000) // ~11ms
            }
        }
    }

    // MARK: - AR Session

    func startARSession() async {
        print("▶️ Starting AR session")
        await arSessionManager.startSession()
        arSessionState = arSessionManager.state

        // Observe state changes
        Task {
            while !Task.isCancelled {
                arSessionState = arSessionManager.state
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
            }
        }
    }

    func stopARSession() {
        print("⏹️ Stopping AR session")
        updateTask?.cancel()
        arSessionManager.stopSession()
        arSessionState = .stopped
    }

    // MARK: - Interaction

    func handleTap(at position: SIMD3<Float>) {
        print("👆 Tap at position: \(position)")
        pendingPosition = position
        showCreatePanel()
    }

    func showCreatePanel() {
        isShowingCreatePanel = true
    }

    func dismissCreatePanel() {
        isShowingCreatePanel = false
        pendingPosition = nil
    }

    func toggleLayersMenu() {
        // TODO: Implement layers menu
        print("📚 Toggle layers menu")
    }

    // MARK: - Annotation Management

    func loadAnnotations() async {
        print("📥 Loading annotations")

        do {
            // Fetch all annotations from service
            let fetchedAnnotations = try await annotationService.fetchAnnotations()
            self.annotations = fetchedAnnotations

            // Render them in AR scene
            if let renderer = annotationRenderer {
                await renderer.reloadAnnotations(fetchedAnnotations)
            }

            print("✅ Loaded \(fetchedAnnotations.count) annotations")
        } catch {
            print("❌ Failed to load annotations: \(error)")
        }
    }

    func reloadAnnotations() async {
        await loadAnnotations()
    }

    func createAnnotation(title: String?, content: String) async {
        guard let position = pendingPosition else {
            print("⚠️ No position for annotation")
            return
        }

        print("✅ Creating annotation at \(position)")

        do {
            // Get default layer
            let layer = try await layerService.getOrCreateDefaultLayer()

            // Create annotation via service
            let annotation = try await annotationService.createAnnotation(
                content: content,
                title: title,
                type: .text,
                position: position,
                layerID: layer.id
            )

            // Add to local list
            annotations.append(annotation)

            // Render in scene
            await annotationRenderer?.createEntity(for: annotation)

            print("✅ Created annotation: \(annotation.id)")
        } catch {
            print("❌ Failed to create annotation: \(error)")
        }

        dismissCreatePanel()
    }

    // MARK: - Cleanup

    deinit {
        updateTask?.cancel()
    }
}

// MARK: - Preview

#Preview {
    ImmersiveView()
        .environmentObject(AppState.shared)
}
