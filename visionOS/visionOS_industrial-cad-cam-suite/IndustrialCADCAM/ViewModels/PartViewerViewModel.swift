import Foundation
import RealityKit
import SwiftData
import Observation
import simd

/// ViewModel for the Part Viewer volumetric window
@Observable
@MainActor
public class PartViewerViewModel {

    // MARK: - Dependencies

    private let modelContext: ModelContext

    // MARK: - State

    /// Currently displayed part
    public var part: Part? {
        didSet {
            if part != nil {
                partDidChange()
            }
        }
    }

    /// RealityKit entity for the part
    public var partEntity: ModelEntity?

    /// Loading state
    public var isLoading: Bool = false

    /// Error message
    public var errorMessage: String?

    // MARK: - View Settings

    /// Show wireframe overlay
    public var showWireframe: Bool = false {
        didSet {
            updateVisualization()
        }
    }

    /// Show dimensions
    public var showDimensions: Bool = false {
        didSet {
            updateVisualization()
        }
    }

    /// Show coordinate axes
    public var showAxes: Bool = true {
        didSet {
            updateVisualization()
        }
    }

    /// Show bounding box
    public var showBoundingBox: Bool = false {
        didSet {
            updateVisualization()
        }
    }

    /// Show grid floor
    public var showGrid: Bool = true {
        didSet {
            updateVisualization()
        }
    }

    /// Shading mode
    public enum ShadingMode: String, CaseIterable {
        case solid = "Solid"
        case wireframe = "Wireframe"
        case shadedWithEdges = "Shaded with Edges"
        case xray = "X-Ray"

        var displayName: String {
            return rawValue
        }
    }

    public var shadingMode: ShadingMode = .solid {
        didSet {
            updateMaterial()
        }
    }

    // MARK: - Camera Control

    /// Camera distance from part
    public var cameraDistance: Float = 2.0

    /// Camera azimuth angle (rotation around Y axis)
    public var cameraAzimuth: Float = 0.0

    /// Camera elevation angle
    public var cameraElevation: Float = 0.3

    /// Auto-rotate enabled
    public var autoRotate: Bool = false

    /// Auto-rotate speed
    public var autoRotateSpeed: Float = 0.5

    // MARK: - Measurements

    /// Measurement mode
    public enum MeasurementMode: String, CaseIterable {
        case none = "None"
        case distance = "Distance"
        case angle = "Angle"
        case area = "Area"

        var displayName: String {
            return rawValue
        }
    }

    public var measurementMode: MeasurementMode = .none

    /// Measurement points (for distance/angle measurements)
    public var measurementPoints: [SIMD3<Float>] = []

    /// Current measurement value
    public var measurementValue: String = ""

    // MARK: - Animation

    /// Animation state
    public var isAnimating: Bool = false

    /// Animation progress (0-1)
    public var animationProgress: Float = 0

    // MARK: - Initialization

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Setup

    /// Setup RealityKit content
    /// - Parameter content: RealityViewContent
    public func setup(content: RealityViewContent) async {
        guard let part = part else { return }

        isLoading = true
        errorMessage = nil

        do {
            // Create part entity
            let entity = try await createPartEntity(for: part)
            partEntity = entity

            // Add to scene
            content.add(entity)

            // Add grid if enabled
            if showGrid {
                let grid = createGridFloor()
                content.add(grid)
            }

            // Add axes if enabled
            if showAxes {
                let axes = createCoordinateAxes()
                content.add(axes)
            }

            // Center camera on part
            centerCamera()

        } catch {
            errorMessage = "Failed to load part: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Part Loading

    private func partDidChange() {
        // Reset view settings
        cameraDistance = 2.0
        cameraAzimuth = 0.0
        cameraElevation = 0.3
        measurementPoints = []
        measurementValue = ""
    }

    private func createPartEntity(for part: Part) async throws -> ModelEntity {
        // In a real implementation, this would load the actual geometry
        // For now, create a placeholder based on bounding box

        let width = Float(part.boundingBoxWidth) / 1000.0 // Convert mm to m
        let height = Float(part.boundingBoxHeight) / 1000.0
        let depth = Float(part.boundingBoxDepth) / 1000.0

        let mesh = MeshResource.generateBox(width: width, height: height, depth: depth)

        // Create material based on shading mode
        var material = SimpleMaterial()
        material.color = .init(tint: .blue)

        let entity = ModelEntity(mesh: mesh, materials: [material])

        return entity
    }

    // MARK: - Visualization Helpers

    private func createGridFloor() -> Entity {
        let anchor = AnchorEntity(.plane(.horizontal, classification: .floor, minimumBounds: .zero))

        // Create grid lines
        let gridSize: Float = 10.0
        let gridSpacing: Float = 0.1

        // In a real implementation, create actual grid geometry
        // For now, return empty anchor

        return anchor
    }

    private func createCoordinateAxes() -> Entity {
        let anchor = AnchorEntity()

        // Create X, Y, Z axes
        // In a real implementation, create colored lines for each axis

        return anchor
    }

    private func updateVisualization() {
        // Update visualization based on current settings
        // This would update the RealityKit scene
    }

    private func updateMaterial() {
        guard let entity = partEntity else { return }

        // Update material based on shading mode
        var material = SimpleMaterial()

        switch shadingMode {
        case .solid:
            material.color = .init(tint: .blue)
        case .wireframe:
            material.color = .init(tint: .white)
            // Enable wireframe rendering
        case .shadedWithEdges:
            material.color = .init(tint: .blue)
            // Enable edge rendering
        case .xray:
            material.color = .init(tint: .blue.withAlphaComponent(0.3))
        }

        entity.model?.materials = [material]
    }

    // MARK: - Camera Control

    private func centerCamera() {
        // Center camera on part bounding box
        guard let part = part else { return }

        let maxDimension = max(part.boundingBoxWidth, part.boundingBoxHeight, part.boundingBoxDepth)
        cameraDistance = Float(maxDimension) / 500.0 // Adjust distance based on part size
    }

    /// Reset camera to default view
    public func resetCamera() {
        centerCamera()
        cameraAzimuth = 0.0
        cameraElevation = 0.3
    }

    /// Fit part to view
    public func fitToView() {
        centerCamera()
    }

    // MARK: - Gesture Handling

    /// Handle drag gesture for rotation
    /// - Parameter value: Drag gesture value
    public func handleDrag(_ value: Any) {
        // In a real implementation, this would handle the drag gesture
        // and update camera angles
    }

    /// Handle magnification gesture for zoom
    /// - Parameter value: Magnification value
    public func handleMagnification(_ value: Float) {
        cameraDistance /= value
        cameraDistance = max(0.5, min(cameraDistance, 10.0)) // Clamp
    }

    /// Handle tap gesture
    /// - Parameter location: Tap location
    public func handleTap(at location: SIMD3<Float>) {
        switch measurementMode {
        case .none:
            break
        case .distance:
            handleDistanceMeasurement(at: location)
        case .angle:
            handleAngleMeasurement(at: location)
        case .area:
            handleAreaMeasurement(at: location)
        }
    }

    // MARK: - Measurement

    private func handleDistanceMeasurement(at location: SIMD3<Float>) {
        measurementPoints.append(location)

        if measurementPoints.count == 2 {
            let distance = simd_distance(measurementPoints[0], measurementPoints[1])
            measurementValue = String(format: "%.2f mm", distance * 1000) // Convert to mm
        } else if measurementPoints.count > 2 {
            // Reset for new measurement
            measurementPoints = [location]
            measurementValue = ""
        }
    }

    private func handleAngleMeasurement(at location: SIMD3<Float>) {
        measurementPoints.append(location)

        if measurementPoints.count == 3 {
            let v1 = measurementPoints[1] - measurementPoints[0]
            let v2 = measurementPoints[2] - measurementPoints[1]
            let angle = GeometryUtilities.angleBetweenVectors(v1, v2)
            measurementValue = String(format: "%.1f°", angle * 180.0 / .pi)
        } else if measurementPoints.count > 3 {
            // Reset for new measurement
            measurementPoints = [location]
            measurementValue = ""
        }
    }

    private func handleAreaMeasurement(at location: SIMD3<Float>) {
        // Simplified area measurement
        // In real implementation, would calculate polygon area
    }

    /// Clear measurements
    public func clearMeasurements() {
        measurementPoints = []
        measurementValue = ""
    }

    // MARK: - View Presets

    /// Set view to front
    public func setFrontView() {
        cameraAzimuth = 0.0
        cameraElevation = 0.0
    }

    /// Set view to top
    public func setTopView() {
        cameraAzimuth = 0.0
        cameraElevation = .pi / 2
    }

    /// Set view to side
    public func setSideView() {
        cameraAzimuth = .pi / 2
        cameraElevation = 0.0
    }

    /// Set view to isometric
    public func setIsometricView() {
        cameraAzimuth = .pi / 4
        cameraElevation = .pi / 6
    }

    // MARK: - Computed Properties

    public var hasPart: Bool {
        return part != nil
    }

    public var canMeasure: Bool {
        return hasPart && measurementMode != .none
    }

    public var hasMeasurement: Bool {
        return !measurementValue.isEmpty
    }
}
