import Foundation
import RealityKit
import SwiftData
import Observation
import simd

/// ViewModel for the Design Studio immersive space
@Observable
@MainActor
public class DesignStudioViewModel {

    // MARK: - Dependencies

    private let modelContext: ModelContext
    private let designService: DesignService

    // MARK: - State

    /// Current project being worked on
    public var currentProject: DesignProject? {
        didSet {
            if currentProject != nil {
                projectDidChange()
            }
        }
    }

    /// Parts in the design space
    public var parts: [Part] = []

    /// Selected parts
    public var selectedParts: Set<UUID> = []

    /// Loading state
    public var isLoading: Bool = false

    /// Error message
    public var errorMessage: String?

    // MARK: - Active Tool

    /// Available design tools
    public enum DesignTool: String, CaseIterable {
        case select = "Select"
        case move = "Move"
        case rotate = "Rotate"
        case scale = "Scale"
        case sketch = "Sketch"
        case extrude = "Extrude"
        case revolve = "Revolve"
        case boolean = "Boolean"
        case measure = "Measure"

        var displayName: String {
            return rawValue
        }

        var iconName: String {
            switch self {
            case .select: return "hand.point.up.left"
            case .move: return "arrow.up.and.down.and.arrow.left.and.right"
            case .rotate: return "arrow.triangle.2.circlepath"
            case .scale: return "arrow.up.left.and.arrow.down.right"
            case .sketch: return "pencil"
            case .extrude: return "cube.fill"
            case .revolve: return "arrow.triangle.2.circlepath.circle"
            case .boolean: return "square.stack.3d.up"
            case .measure: return "ruler"
            }
        }
    }

    public var activeTool: DesignTool = .select {
        didSet {
            toolDidChange()
        }
    }

    // MARK: - Grid and Snap

    /// Show grid floor
    public var showGrid: Bool = true

    /// Grid size
    public var gridSize: Float = 10.0

    /// Grid spacing
    public var gridSpacing: Float = 0.1

    /// Snap to grid enabled
    public var snapToGrid: Bool = true

    /// Snap distance
    public var snapDistance: Float = 0.01

    // MARK: - Transform

    /// Current transform mode
    public enum TransformMode {
        case world
        case local
    }

    public var transformMode: TransformMode = .world

    /// Transform gizmo enabled
    public var showTransformGizmo: Bool = true

    // MARK: - Sketch State (for 2D sketching)

    public struct SketchPoint {
        public let position: SIMD2<Float>
        public let id: UUID

        public init(position: SIMD2<Float>, id: UUID = UUID()) {
            self.position = position
            self.id = id
        }
    }

    public var sketchPoints: [SketchPoint] = []
    public var isSketchMode: Bool = false

    // MARK: - Operation State

    /// Current operation (for multi-step operations)
    public enum Operation {
        case none
        case extruding(height: Float)
        case revolving(angle: Float, axis: SIMD3<Float>)
        case boolean(type: BooleanType, parts: [UUID])
    }

    public enum BooleanType {
        case union
        case subtract
        case intersect
    }

    public var currentOperation: Operation = .none

    // MARK: - History

    /// Undo stack
    private var undoStack: [DesignAction] = []

    /// Redo stack
    private var redoStack: [DesignAction] = []

    private struct DesignAction {
        let description: String
        let undo: () -> Void
        let redo: () -> Void
    }

    // MARK: - Initialization

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.designService = DesignService(modelContext: modelContext)
    }

    // MARK: - Project Management

    private func projectDidChange() {
        guard let project = currentProject else { return }

        // Load project parts
        parts = project.parts
        selectedParts = []
        clearOperation()
    }

    // MARK: - Tool Management

    private func toolDidChange() {
        // Clear selection when changing to certain tools
        switch activeTool {
        case .sketch:
            isSketchMode = true
            sketchPoints = []
        case .extrude, .revolve, .boolean:
            currentOperation = .none
        default:
            isSketchMode = false
        }
    }

    /// Select tool by type
    /// - Parameter tool: Tool to select
    public func selectTool(_ tool: DesignTool) {
        activeTool = tool
    }

    // MARK: - Part Creation

    /// Create primitive part
    /// - Parameters:
    ///   - type: Primitive type
    ///   - position: Position in space
    public func createPrimitive(type: String, at position: SIMD3<Float>) async {
        guard let project = currentProject else { return }

        isLoading = true
        errorMessage = nil

        do {
            let dimensions = PrimitiveDimensions(width: 100, height: 100, depth: 100)
            let part = try await designService.createPrimitive(type: type, dimensions: dimensions)

            project.addPart(part)
            parts.append(part)

            try modelContext.save()

            // Select newly created part
            selectedParts = [part.id]

        } catch {
            errorMessage = "Failed to create primitive: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Part Selection

    /// Select part
    /// - Parameter partID: Part UUID
    public func selectPart(_ partID: UUID) {
        selectedParts.insert(partID)
    }

    /// Deselect part
    /// - Parameter partID: Part UUID
    public func deselectPart(_ partID: UUID) {
        selectedParts.remove(partID)
    }

    /// Toggle part selection
    /// - Parameter partID: Part UUID
    public func togglePartSelection(_ partID: UUID) {
        if selectedParts.contains(partID) {
            selectedParts.remove(partID)
        } else {
            selectedParts.insert(partID)
        }
    }

    /// Clear selection
    public func clearSelection() {
        selectedParts = []
    }

    /// Select all parts
    public func selectAll() {
        selectedParts = Set(parts.map { $0.id })
    }

    // MARK: - Part Transformation

    /// Move selected parts
    /// - Parameter translation: Translation vector
    public func moveSelectedParts(by translation: SIMD3<Float>) {
        // In real implementation, update part positions
        // For now, just track the operation for undo/redo

        let movedParts = selectedParts

        addUndoAction(
            description: "Move parts",
            undo: {
                // Undo movement
            },
            redo: {
                // Redo movement
            }
        )
    }

    /// Rotate selected parts
    /// - Parameters:
    ///   - angle: Rotation angle in radians
    ///   - axis: Rotation axis
    public func rotateSelectedParts(angle: Float, axis: SIMD3<Float>) {
        // Implementation for rotation
        addUndoAction(
            description: "Rotate parts",
            undo: {},
            redo: {}
        )
    }

    /// Scale selected parts
    /// - Parameter factor: Scale factor
    public func scaleSelectedParts(by factor: Float) {
        // Implementation for scaling
        addUndoAction(
            description: "Scale parts",
            undo: {},
            redo: {}
        )
    }

    // MARK: - Sketch Operations

    /// Add sketch point
    /// - Parameter position: 2D position on sketch plane
    public func addSketchPoint(at position: SIMD2<Float>) {
        guard isSketchMode else { return }

        let point = SketchPoint(position: position)
        sketchPoints.append(point)
    }

    /// Complete sketch and create 2D profile
    public func completeSketch() {
        guard isSketchMode, sketchPoints.count >= 3 else { return }

        // Create closed profile from sketch points
        isSketchMode = false

        addUndoAction(
            description: "Create sketch",
            undo: {
                self.sketchPoints = []
            },
            redo: {
                // Recreate sketch
            }
        )
    }

    /// Cancel sketch
    public func cancelSketch() {
        sketchPoints = []
        isSketchMode = false
    }

    // MARK: - 3D Operations

    /// Start extrude operation
    /// - Parameter height: Extrusion height
    public func startExtrude(height: Float) {
        currentOperation = .extruding(height: height)
    }

    /// Complete extrude operation
    public func completeExtrude() async {
        guard case .extruding(let height) = currentOperation else { return }
        guard !selectedParts.isEmpty, let project = currentProject else { return }

        // In real implementation, perform extrusion
        clearOperation()
    }

    /// Start revolve operation
    /// - Parameters:
    ///   - angle: Revolution angle
    ///   - axis: Revolution axis
    public func startRevolve(angle: Float, axis: SIMD3<Float>) {
        currentOperation = .revolving(angle: angle, axis: axis)
    }

    /// Complete revolve operation
    public func completeRevolve() async {
        guard case .revolving = currentOperation else { return }

        // In real implementation, perform revolution
        clearOperation()
    }

    /// Perform boolean operation
    /// - Parameter type: Boolean operation type
    public func performBoolean(type: BooleanType) async {
        guard selectedParts.count >= 2 else { return }

        isLoading = true
        errorMessage = nil

        // In real implementation, perform boolean operation
        // using design service

        isLoading = false
        clearOperation()
    }

    // MARK: - Operation Management

    private func clearOperation() {
        currentOperation = .none
        isSketchMode = false
        sketchPoints = []
    }

    // MARK: - Undo/Redo

    private func addUndoAction(description: String, undo: @escaping () -> Void, redo: @escaping () -> Void) {
        let action = DesignAction(description: description, undo: undo, redo: redo)
        undoStack.append(action)
        redoStack = [] // Clear redo stack
    }

    /// Undo last action
    public func undo() {
        guard let action = undoStack.popLast() else { return }
        action.undo()
        redoStack.append(action)
    }

    /// Redo last undone action
    public func redo() {
        guard let action = redoStack.popLast() else { return }
        action.redo()
        undoStack.append(action)
    }

    /// Clear undo/redo history
    public func clearHistory() {
        undoStack = []
        redoStack = []
    }

    // MARK: - Grid and Snap

    /// Snap position to grid
    /// - Parameter position: Position to snap
    /// - Returns: Snapped position
    public func snapPosition(_ position: SIMD3<Float>) -> SIMD3<Float> {
        guard snapToGrid else { return position }

        let snapped = SIMD3<Float>(
            round(position.x / gridSpacing) * gridSpacing,
            round(position.y / gridSpacing) * gridSpacing,
            round(position.z / gridSpacing) * gridSpacing
        )

        return snapped
    }

    // MARK: - Save

    /// Save current state
    public func save() async {
        guard currentProject != nil else { return }

        do {
            try modelContext.save()
        } catch {
            errorMessage = "Failed to save: \(error.localizedDescription)"
        }
    }

    // MARK: - Computed Properties

    public var hasProject: Bool {
        return currentProject != nil
    }

    public var hasSelection: Bool {
        return !selectedParts.isEmpty
    }

    public var canUndo: Bool {
        return !undoStack.isEmpty
    }

    public var canRedo: Bool {
        return !redoStack.isEmpty
    }

    public var isOperating: Bool {
        if case .none = currentOperation {
            return false
        }
        return true
    }

    public var selectedPartCount: Int {
        return selectedParts.count
    }
}
