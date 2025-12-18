//
//  SpatialGestureHandlers.swift
//  BusinessOperatingSystem
//
//  Created by BOS Team on 2025-01-20.
//

import SwiftUI
import RealityKit

// MARK: - Spatial Gesture State

@Observable
final class SpatialInteractionState {
    var selectedEntityID: String?
    var hoveredEntityID: String?
    var isDragging: Bool = false
    var dragOffset: SIMD3<Float> = .zero

    func selectEntity(_ id: String?) {
        selectedEntityID = id
    }

    func hoverEntity(_ id: String?) {
        hoveredEntityID = id
    }

    func startDrag() {
        isDragging = true
    }

    func endDrag() {
        isDragging = false
        dragOffset = .zero
    }
}

// MARK: - Gesture-Enabled Immersive View

struct GestureEnabledRealityView<Content: View>: View {
    @Environment(\.openWindow) private var openWindow
    @State private var interactionState = SpatialInteractionState()

    let content: @MainActor @Sendable (RealityViewContent) async -> Void
    let onEntityTapped: ((String) -> Void)?
    let onEntityDragged: ((String, SIMD3<Float>) -> Void)?

    init(
        @ViewBuilder content: @escaping @MainActor @Sendable (RealityViewContent) async -> Void,
        onEntityTapped: ((String) -> Void)? = nil,
        onEntityDragged: ((String, SIMD3<Float>) -> Void)? = nil
    ) {
        self.content = content
        self.onEntityTapped = onEntityTapped
        self.onEntityDragged = onEntityDragged
    }

    var body: some View {
        RealityView { realityContent in
            await content(realityContent)
        }
        .gesture(tapGesture)
        .gesture(dragGesture)
        .gesture(longPressGesture)
    }

    // MARK: - Tap Gesture

    private var tapGesture: some Gesture {
        TapGesture()
            .targetedToAnyEntity()
            .onEnded { value in
                handleTap(on: value.entity)
            }
    }

    private func handleTap(on entity: Entity) {
        // Find the root entity with a meaningful name
        var current: Entity? = entity
        while let parent = current?.parent {
            if current?.name.hasPrefix("department-") == true ||
               current?.name.hasPrefix("kpi-") == true ||
               current?.name == "central-hub" {
                break
            }
            current = parent
        }

        guard let targetEntity = current else { return }
        let name = targetEntity.name

        // Apply visual feedback
        applySelectionFeedback(to: targetEntity)

        // Notify handler
        onEntityTapped?(name)

        // Update state
        interactionState.selectEntity(name)

        // Handle specific entity types
        if name.hasPrefix("department-") {
            let idString = String(name.dropFirst("department-".count))
            if let uuid = UUID(uuidString: idString) {
                openWindow(id: "department", value: uuid)
            }
        }
    }

    private func applySelectionFeedback(to entity: Entity) {
        // Scale up briefly for visual feedback
        let originalScale = entity.scale

        Task { @MainActor in
            withAnimation(.easeOut(duration: 0.1)) {
                entity.scale = originalScale * 1.1
            }

            try? await Task.sleep(for: .milliseconds(100))

            withAnimation(.easeIn(duration: 0.1)) {
                entity.scale = originalScale
            }
        }
    }

    // MARK: - Drag Gesture

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0.01)
            .targetedToAnyEntity()
            .onChanged { value in
                handleDrag(value: value)
            }
            .onEnded { value in
                handleDragEnd(value: value)
            }
    }

    private func handleDrag(value: EntityTargetValue<DragGesture.Value>) {
        let entity = value.entity

        // Find draggable parent
        var current: Entity? = entity
        while let parent = current?.parent {
            if current?.name.hasPrefix("department-") == true {
                break
            }
            current = parent
        }

        guard let targetEntity = current else { return }

        if !interactionState.isDragging {
            interactionState.startDrag()
        }

        // Convert drag to 3D space
        let translation = value.translation3D
        let offset = SIMD3<Float>(
            Float(translation.x) * 0.001,
            Float(translation.y) * 0.001,
            Float(translation.z) * 0.001
        )

        targetEntity.position += offset
        interactionState.dragOffset = offset

        onEntityDragged?(targetEntity.name ?? "", offset)
    }

    private func handleDragEnd(value: EntityTargetValue<DragGesture.Value>) {
        interactionState.endDrag()
    }

    // MARK: - Long Press Gesture

    private var longPressGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.5)
            .targetedToAnyEntity()
            .onEnded { value in
                handleLongPress(on: value.entity)
            }
    }

    private func handleLongPress(on entity: Entity) {
        // Find the parent entity with a meaningful name
        var current: Entity? = entity
        while let parent = current?.parent {
            if current?.name.hasPrefix("department-") == true {
                break
            }
            current = parent
        }

        guard let targetEntity = current else { return }
        let name = targetEntity.name

        // Show context menu or detailed info
        if name.hasPrefix("department-") {
            let idString = String(name.dropFirst("department-".count))
            if let uuid = UUID(uuidString: idString) {
                // Open volumetric view for department
                openWindow(id: "department-volume", value: uuid)
            }
        }
    }
}

// MARK: - Hover Effects

struct HoverEffectModifier: ViewModifier {
    @State private var isHovered = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isHovered ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

extension View {
    func spatialHoverEffect() -> some View {
        modifier(HoverEffectModifier())
    }
}

// MARK: - Entity Highlight Component

struct EntityHighlightComponent: Component {
    var isHighlighted: Bool = false
    var highlightColor: UIColor = .systemYellow
    var originalMaterials: [RealityKit.Material] = []
}

// MARK: - Interaction Feedback System

@MainActor
final class InteractionFeedbackSystem {
    static let shared = InteractionFeedbackSystem()

    private init() {}

    func playSelectionFeedback() {
        // Haptic feedback would be played here on supported devices
        #if os(visionOS)
        // visionOS doesn't have traditional haptics, but we could use audio
        #endif
    }

    func playHoverFeedback() {
        // Subtle audio feedback for hover
    }

    func playErrorFeedback() {
        // Error sound
    }
}

// MARK: - Gaze Tracking Support

@Observable
final class GazeTracker {
    var gazePoint: SIMD3<Float>?
    var gazedEntityID: String?

    private var updateTask: Task<Void, Never>?

    func startTracking() {
        // In a real implementation, this would use ARKit's gaze tracking
        // For now, we simulate with hover detection
    }

    func stopTracking() {
        updateTask?.cancel()
        updateTask = nil
    }

    func entityAtGaze(in entities: [Entity]) -> Entity? {
        guard let gaze = gazePoint else { return nil }

        // Find closest entity to gaze point
        var closestEntity: Entity?
        var closestDistance: Float = .infinity

        for entity in entities {
            let distance = simd_distance(entity.position, gaze)
            if distance < closestDistance {
                closestDistance = distance
                closestEntity = entity
            }
        }

        return closestEntity
    }
}

// MARK: - SIMD Extensions

extension SIMD3 where Scalar == Float {
    var normalized: SIMD3<Float> {
        let length = simd_length(self)
        guard length > 0 else { return .zero }
        return self / length
    }
}
