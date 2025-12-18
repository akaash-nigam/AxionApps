//
//  BusinessEntity3D.swift
//  BusinessOperatingSystem
//
//  Created by BOS Team on 2025-01-20.
//

import SwiftUI
import RealityKit

// MARK: - Department 3D Entity Builder

/// Creates rich 3D visualizations for departments
/// Uses EntityPool for efficient entity management
@MainActor
final class DepartmentEntityBuilder {
    // MARK: - Properties

    private let department: Department
    private let layoutEngine = SpatialLayoutEngine()
    private let entityPool = EntityPool.shared
    private let materialPool = MaterialPool.shared

    /// Tracks pooled entities for cleanup
    private var pooledEntities: [(ModelEntity, EntityPool.EntityType)] = []

    // MARK: - Configuration

    struct Configuration {
        var baseSize: Float = 0.3
        var heightPerEmployee: Float = 0.005  // Height grows with headcount
        var maxHeight: Float = 0.8
        var showLabels: Bool = true
        var animationEnabled: Bool = true
        var usePooledEntities: Bool = true  // Enable entity pooling
    }

    // MARK: - Initialization

    init(department: Department) {
        self.department = department
    }

    // MARK: - Cleanup

    /// Release all pooled entities back to the pool
    func releasePooledEntities() {
        for (entity, type) in pooledEntities {
            entityPool.releaseAndRemove(entity, type: type)
        }
        pooledEntities.removeAll()
    }

    // MARK: - Building

    /// Build a complete 3D representation of the department
    func build(configuration: Configuration = Configuration()) async -> Entity {
        let container = Entity()
        container.name = "department-\(department.id)"

        // Add the main building structure
        let building = await createBuilding(configuration: configuration)
        container.addChild(building)

        // Add performance indicator ring
        let performanceRing = await createPerformanceRing(configuration: configuration)
        performanceRing.position = [0, -0.02, 0]
        container.addChild(performanceRing)

        // Add floating label if enabled
        if configuration.showLabels {
            let label = await createLabel(configuration: configuration)
            let height = calculateHeight(configuration: configuration)
            label.position = [0, height + 0.1, 0]
            container.addChild(label)
        }

        // Add budget utilization indicator
        let budgetIndicator = await createBudgetIndicator(configuration: configuration)
        budgetIndicator.position = [configuration.baseSize * 0.6, 0, 0]
        container.addChild(budgetIndicator)

        // Add ambient glow based on department type
        let glow = await createAmbientGlow(configuration: configuration)
        container.addChild(glow)

        // Add interaction components
        container.components.set(InputTargetComponent())
        container.components.set(CollisionComponent(shapes: [.generateBox(size: [
            configuration.baseSize,
            calculateHeight(configuration: configuration),
            configuration.baseSize
        ])]))

        return container
    }

    // MARK: - Building Components

    private func createBuilding(configuration: Configuration) async -> Entity {
        let height = calculateHeight(configuration: configuration)
        let size = configuration.baseSize

        // Multi-floor building representation
        let building = Entity()

        // Base platform
        let baseMesh = MeshResource.generateBox(size: [size * 1.1, 0.02, size * 1.1], cornerRadius: 0.005)
        var baseMaterial = PhysicallyBasedMaterial()
        baseMaterial.baseColor = .init(tint: .darkGray)
        baseMaterial.metallic = .init(floatLiteral: 0.8)
        baseMaterial.roughness = .init(floatLiteral: 0.3)

        let baseEntity = ModelEntity(mesh: baseMesh, materials: [baseMaterial])
        baseEntity.position = [0, 0.01, 0]
        building.addChild(baseEntity)

        // Main building body
        let bodyMesh = MeshResource.generateBox(
            size: [size, height, size],
            cornerRadius: 0.01
        )

        var bodyMaterial = PhysicallyBasedMaterial()
        let color = UIColor(Color(hex: department.type.defaultColor))
        bodyMaterial.baseColor = .init(tint: color)
        bodyMaterial.metallic = .init(floatLiteral: 0.3)
        bodyMaterial.roughness = .init(floatLiteral: 0.6)

        let bodyEntity = ModelEntity(mesh: bodyMesh, materials: [bodyMaterial])
        bodyEntity.position = [0, height / 2 + 0.02, 0]
        building.addChild(bodyEntity)

        // Add floor lines to visualize employee count
        let floorCount = min(department.headcount / 25, 10)  // One floor per 25 employees, max 10
        for i in 0..<floorCount {
            let floorLine = createFloorLine(
                at: Float(i + 1) * (height / Float(floorCount + 1)),
                width: size
            )
            building.addChild(floorLine)
        }

        // Roof accent
        let roofMesh = MeshResource.generateBox(size: [size * 0.9, 0.015, size * 0.9], cornerRadius: 0.003)
        var roofMaterial = PhysicallyBasedMaterial()
        roofMaterial.baseColor = .init(tint: color.withAlphaComponent(0.8))
        roofMaterial.metallic = .init(floatLiteral: 0.9)

        let roofEntity = ModelEntity(mesh: roofMesh, materials: [roofMaterial])
        roofEntity.position = [0, height + 0.03, 0]
        building.addChild(roofEntity)

        return building
    }

    private func createFloorLine(at height: Float, width: Float) -> Entity {
        let lineMesh = MeshResource.generateBox(size: [width + 0.01, 0.003, width + 0.01])
        var lineMaterial = PhysicallyBasedMaterial()
        lineMaterial.baseColor = .init(tint: .white.withAlphaComponent(0.3))

        let lineEntity = ModelEntity(mesh: lineMesh, materials: [lineMaterial])
        lineEntity.position = [0, height + 0.02, 0]
        return lineEntity
    }

    private func createPerformanceRing(configuration: Configuration) async -> Entity {
        let ring = Entity()

        // Calculate average KPI performance
        let avgPerformance = department.kpis.isEmpty ? 1.0 :
            department.kpis.reduce(0.0) { $0 + $1.performance } / Double(department.kpis.count)

        // Create ring segments
        let segmentCount = 32
        let radius = configuration.baseSize * 0.7
        let ringHeight: Float = 0.01

        for i in 0..<segmentCount {
            let progress = Double(i) / Double(segmentCount)
            let isLit = progress <= avgPerformance

            let angle = Float(i) * (2 * .pi / Float(segmentCount))
            let nextAngle = Float(i + 1) * (2 * .pi / Float(segmentCount))

            let segment = createRingSegment(
                innerRadius: radius - 0.02,
                outerRadius: radius,
                startAngle: angle,
                endAngle: nextAngle,
                height: ringHeight,
                isLit: isLit,
                usePool: configuration.usePooledEntities
            )
            ring.addChild(segment)
        }

        return ring
    }

    private func createRingSegment(
        innerRadius: Float,
        outerRadius: Float,
        startAngle: Float,
        endAngle: Float,
        height: Float,
        isLit: Bool,
        usePool: Bool
    ) -> Entity {
        let midAngle = (startAngle + endAngle) / 2
        let midRadius = (innerRadius + outerRadius) / 2

        let x = midRadius * cos(midAngle)
        let z = midRadius * sin(midAngle)

        let segmentWidth = outerRadius - innerRadius
        let segmentLength = midRadius * (endAngle - startAngle)

        let material: RealityKit.Material
        if isLit {
            let color = performanceColor(for: department.kpis.first?.performanceStatus ?? .onTrack)
            material = materialPool.emissiveMaterial(color: color, intensity: 0.5)
        } else {
            material = materialPool.material(for: .defaultGray)
        }

        let segment: ModelEntity
        let entityType = EntityPool.EntityType.box(size: [segmentWidth, height, segmentLength], cornerRadius: 0)

        if usePool {
            segment = entityPool.acquire(type: entityType, material: material)
            pooledEntities.append((segment, entityType))
        } else {
            let mesh = MeshResource.generateBox(size: [segmentWidth, height, segmentLength])
            segment = ModelEntity(mesh: mesh, materials: [material])
        }

        segment.position = [x, 0, z]
        segment.orientation = simd_quatf(angle: midAngle, axis: [0, 1, 0])

        return segment
    }

    private func createLabel(configuration: Configuration) async -> Entity {
        let label = Entity()

        // Create text mesh for department name
        let textMesh = MeshResource.generateText(
            department.name,
            extrusionDepth: 0.002,
            font: .systemFont(ofSize: 0.03, weight: .semibold),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )

        var textMaterial = UnlitMaterial(color: .white)

        let textEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])
        textEntity.position = [-Float(department.name.count) * 0.008, 0, 0]  // Center text

        // Billboard behavior - always face the user
        label.addChild(textEntity)

        return label
    }

    private func createBudgetIndicator(configuration: Configuration) async -> Entity {
        let indicator = Entity()

        let utilization = Float(department.budget.utilizationPercent) / 100.0
        let maxHeight: Float = 0.15
        let width: Float = 0.02

        // Background bar
        let bgMesh = MeshResource.generateBox(size: [width, maxHeight, width], cornerRadius: 0.005)
        var bgMaterial = PhysicallyBasedMaterial()
        bgMaterial.baseColor = .init(tint: .darkGray.withAlphaComponent(0.5))

        let bgEntity = ModelEntity(mesh: bgMesh, materials: [bgMaterial])
        bgEntity.position = [0, maxHeight / 2, 0]
        indicator.addChild(bgEntity)

        // Fill bar
        let fillHeight = maxHeight * min(utilization, 1.0)
        let fillMesh = MeshResource.generateBox(size: [width * 0.8, fillHeight, width * 0.8], cornerRadius: 0.003)

        var fillMaterial = PhysicallyBasedMaterial()
        let fillColor: UIColor
        switch utilization {
        case ..<0.7:
            fillColor = .systemGreen
        case 0.7..<0.9:
            fillColor = .systemYellow
        default:
            fillColor = .systemRed
        }
        fillMaterial.baseColor = .init(tint: fillColor)
        fillMaterial.emissiveColor = .init(color: fillColor)
        fillMaterial.emissiveIntensity = 0.3

        let fillEntity = ModelEntity(mesh: fillMesh, materials: [fillMaterial])
        fillEntity.position = [0, fillHeight / 2, 0]
        indicator.addChild(fillEntity)

        return indicator
    }

    private func createAmbientGlow(configuration: Configuration) async -> Entity {
        let glow = Entity()

        // Point light with department color
        let color = UIColor(Color(hex: department.type.defaultColor))

        var pointLight = PointLightComponent()
        pointLight.color = color
        pointLight.intensity = 500
        pointLight.attenuationRadius = 0.5

        glow.components.set(pointLight)
        glow.position = [0, calculateHeight(configuration: configuration) / 2, 0]

        return glow
    }

    // MARK: - Helpers

    private func calculateHeight(configuration: Configuration) -> Float {
        let baseHeight: Float = 0.15
        let employeeHeight = Float(department.headcount) * configuration.heightPerEmployee
        return min(baseHeight + employeeHeight, configuration.maxHeight)
    }

    private func performanceColor(for status: KPI.PerformanceStatus) -> UIColor {
        switch status {
        case .exceeding: return .systemGreen
        case .onTrack: return .systemBlue
        case .belowTarget: return .systemOrange
        case .critical: return .systemRed
        }
    }
}

// MARK: - KPI 3D Visualization

/// Creates 3D KPI gauge visualizations
/// Uses EntityPool for efficient entity management
@MainActor
final class KPIEntityBuilder {
    private let kpi: KPI
    private let entityPool = EntityPool.shared
    private let materialPool = MaterialPool.shared

    /// Tracks pooled entities for cleanup
    private var pooledEntities: [(ModelEntity, EntityPool.EntityType)] = []

    struct Configuration {
        var usePooledEntities: Bool = true
        var gaugeRadius: Float = 0.12
        var segmentCount: Int = 20
    }

    init(kpi: KPI) {
        self.kpi = kpi
    }

    /// Release all pooled entities back to the pool
    func releasePooledEntities() {
        for (entity, type) in pooledEntities {
            entityPool.releaseAndRemove(entity, type: type)
        }
        pooledEntities.removeAll()
    }

    func build(configuration: Configuration = Configuration()) async -> Entity {
        let container = Entity()
        container.name = "kpi-\(kpi.id)"

        // Create gauge arc
        let gauge = await createGaugeArc(configuration: configuration)
        container.addChild(gauge)

        // Create value display
        let valueDisplay = await createValueDisplay()
        valueDisplay.position = [0, 0, 0.05]
        container.addChild(valueDisplay)

        // Add interaction
        container.components.set(InputTargetComponent())
        container.components.set(CollisionComponent(shapes: [.generateSphere(radius: 0.15)]))

        return container
    }

    private func createGaugeArc(configuration: Configuration) async -> Entity {
        let arc = Entity()

        let performance = min(Float(kpi.performance), 1.5)  // Cap at 150%
        let segments = configuration.segmentCount
        let radius = configuration.gaugeRadius

        for i in 0..<segments {
            let progress = Float(i) / Float(segments)
            let isFilled = progress <= performance

            let angle = Float.pi * (0.25 + progress * 0.5)  // 45° to 135° arc

            let segment = createArcSegment(
                radius: radius,
                angle: angle,
                isFilled: isFilled,
                usePool: configuration.usePooledEntities
            )
            arc.addChild(segment)
        }

        return arc
    }

    private func createArcSegment(radius: Float, angle: Float, isFilled: Bool, usePool: Bool) -> Entity {
        let x = radius * cos(angle)
        let y = radius * sin(angle)

        let material: RealityKit.Material
        if isFilled {
            let color = performanceColor()
            material = materialPool.emissiveMaterial(color: color, intensity: 0.8)
        } else {
            material = materialPool.material(for: .defaultGray)
        }

        let segment: ModelEntity
        let entityType = EntityPool.EntityType.smallSphere

        if usePool {
            segment = entityPool.acquire(type: entityType, material: material)
            pooledEntities.append((segment, entityType))
        } else {
            let mesh = MeshResource.generateSphere(radius: 0.008)
            segment = ModelEntity(mesh: mesh, materials: [material])
        }

        segment.position = [x, y, 0]

        return segment
    }

    private func createValueDisplay() async -> Entity {
        let display = Entity()

        // Value text
        let valueText = kpi.displayFormat.formatStyle == .currency ?
            "$\(Int(truncating: kpi.value as NSNumber))" :
            "\(Int(truncating: kpi.value as NSNumber))"

        let textMesh = MeshResource.generateText(
            valueText,
            extrusionDepth: 0.001,
            font: .monospacedDigitSystemFont(ofSize: 0.025, weight: .bold),
            alignment: .center
        )

        let textEntity = ModelEntity(mesh: textMesh, materials: [UnlitMaterial(color: .white)])
        textEntity.position = [-0.04, 0, 0]
        display.addChild(textEntity)

        return display
    }

    private func performanceColor() -> UIColor {
        switch kpi.performanceStatus {
        case .exceeding: return .systemGreen
        case .onTrack: return .systemBlue
        case .belowTarget: return .systemOrange
        case .critical: return .systemRed
        }
    }
}

// MARK: - Data Flow Visualization

/// Creates animated data flow paths between entities
/// Uses EntityPool for efficient entity management
@MainActor
final class DataFlowVisualizer {
    // MARK: - Properties

    private let entityPool = EntityPool.shared
    private let materialPool = MaterialPool.shared

    /// Tracks pooled entities for cleanup
    private var pooledEntities: [(ModelEntity, EntityPool.EntityType)] = []

    /// Tracks created flows for batch cleanup
    private var activeFlows: [Entity] = []

    // MARK: - Configuration

    struct Configuration {
        var usePooledEntities: Bool = true
        var arcHeight: Float = 0.3
        var pathSteps: Int = 30
        var particleCount: Int = 10
        var segmentSize: Float = 0.003
    }

    // MARK: - Cleanup

    /// Release all pooled entities back to the pool
    func releasePooledEntities() {
        for (entity, type) in pooledEntities {
            entityPool.releaseAndRemove(entity, type: type)
        }
        pooledEntities.removeAll()
        activeFlows.removeAll()
    }

    /// Release a specific flow and its entities
    func releaseFlow(_ flow: Entity) {
        flow.removeFromParent()
        activeFlows.removeAll { $0 === flow }
        // Note: Individual entity cleanup happens in bulk via releasePooledEntities()
    }

    // MARK: - Flow Creation

    func createFlowPath(
        from source: SIMD3<Float>,
        to destination: SIMD3<Float>,
        color: UIColor = .systemBlue,
        configuration: Configuration = Configuration()
    ) async -> Entity {
        let flow = Entity()
        flow.name = "data-flow"

        let layoutEngine = SpatialLayoutEngine()
        let path = layoutEngine.generatePath(
            from: source,
            to: destination,
            arcHeight: configuration.arcHeight,
            steps: configuration.pathSteps
        )

        // Create path segments
        for i in 0..<(path.count - 1) {
            let segment = createPathSegment(
                from: path[i],
                to: path[i + 1],
                color: color,
                usePool: configuration.usePooledEntities,
                segmentSize: configuration.segmentSize
            )
            flow.addChild(segment)
        }

        // Create particles along path
        for i in 0..<configuration.particleCount {
            let particle = createParticle(
                color: color,
                usePool: configuration.usePooledEntities
            )
            let pathIndex = (i * path.count) / configuration.particleCount
            particle.position = path[min(pathIndex, path.count - 1)]
            flow.addChild(particle)
        }

        activeFlows.append(flow)
        return flow
    }

    private func createPathSegment(
        from start: SIMD3<Float>,
        to end: SIMD3<Float>,
        color: UIColor,
        usePool: Bool,
        segmentSize: Float
    ) -> Entity {
        let direction = end - start
        let length = simd_length(direction)
        let midpoint = (start + end) / 2

        let material = materialPool.material(color: color.withAlphaComponent(0.5), metallic: 0.3, roughness: 0.6)

        let segment: ModelEntity
        let entityType = EntityPool.EntityType.box(
            size: [segmentSize, segmentSize, length],
            cornerRadius: 0
        )

        if usePool {
            segment = entityPool.acquire(type: entityType, material: material)
            pooledEntities.append((segment, entityType))
        } else {
            let mesh = MeshResource.generateBox(size: [segmentSize, segmentSize, length])
            segment = ModelEntity(mesh: mesh, materials: [material])
        }

        segment.position = midpoint

        // Orient towards destination
        if length > 0.001 {
            segment.look(at: end, from: midpoint, relativeTo: nil)
        }

        return segment
    }

    private func createParticle(color: UIColor, usePool: Bool) -> ModelEntity {
        let material = materialPool.emissiveMaterial(color: color, intensity: 1.0)

        let particle: ModelEntity
        let entityType = EntityPool.EntityType.smallSphere

        if usePool {
            particle = entityPool.acquire(type: entityType, material: material)
            pooledEntities.append((particle, entityType))
        } else {
            let mesh = MeshResource.generateSphere(radius: 0.008)
            particle = ModelEntity(mesh: mesh, materials: [material])
        }

        return particle
    }

    // MARK: - Static Convenience Methods (Non-Pooled)

    /// Creates a flow path without pooling - for one-off visualizations
    static func createStaticFlowPath(
        from source: SIMD3<Float>,
        to destination: SIMD3<Float>,
        color: UIColor = .systemBlue,
        particleCount: Int = 10
    ) async -> Entity {
        let flow = Entity()
        flow.name = "data-flow"

        let layoutEngine = SpatialLayoutEngine()
        let path = layoutEngine.generatePath(
            from: source,
            to: destination,
            arcHeight: 0.3,
            steps: 30
        )

        // Create path line
        for i in 0..<(path.count - 1) {
            let segment = createStaticPathSegment(from: path[i], to: path[i + 1], color: color)
            flow.addChild(segment)
        }

        // Add particles
        for i in 0..<particleCount {
            let particle = createStaticParticle(color: color)
            let pathIndex = (i * path.count) / particleCount
            particle.position = path[min(pathIndex, path.count - 1)]
            flow.addChild(particle)
        }

        return flow
    }

    private static func createStaticPathSegment(
        from start: SIMD3<Float>,
        to end: SIMD3<Float>,
        color: UIColor
    ) -> Entity {
        let direction = end - start
        let length = simd_length(direction)
        let midpoint = (start + end) / 2

        let mesh = MeshResource.generateBox(size: [0.003, 0.003, length])
        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: color.withAlphaComponent(0.5))

        let segment = ModelEntity(mesh: mesh, materials: [material])
        segment.position = midpoint

        if length > 0.001 {
            segment.look(at: end, from: midpoint, relativeTo: nil)
        }

        return segment
    }

    private static func createStaticParticle(color: UIColor) -> ModelEntity {
        let mesh = MeshResource.generateSphere(radius: 0.008)
        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: color)
        material.emissiveColor = .init(color: color)
        material.emissiveIntensity = 1.0

        return ModelEntity(mesh: mesh, materials: [material])
    }
}

// MARK: - Scene Entity Manager

/// Manages entity lifecycle for entire scenes
/// Integrates with EntityPool for automatic cleanup
@MainActor
final class SceneEntityManager {
    // MARK: - Properties

    private let entityPool = EntityPool.shared
    private var departmentBuilders: [UUID: DepartmentEntityBuilder] = [:]
    private var kpiBuilders: [UUID: KPIEntityBuilder] = [:]
    private var flowVisualizers: [DataFlowVisualizer] = []

    // MARK: - Department Management

    func createDepartmentEntity(for department: Department, configuration: DepartmentEntityBuilder.Configuration = .init()) async -> Entity {
        let builder = DepartmentEntityBuilder(department: department)
        departmentBuilders[department.id] = builder
        return await builder.build(configuration: configuration)
    }

    func releaseDepartmentEntity(id: UUID) {
        departmentBuilders[id]?.releasePooledEntities()
        departmentBuilders.removeValue(forKey: id)
    }

    // MARK: - KPI Management

    func createKPIEntity(for kpi: KPI, configuration: KPIEntityBuilder.Configuration = .init()) async -> Entity {
        let builder = KPIEntityBuilder(kpi: kpi)
        kpiBuilders[kpi.id] = builder
        return await builder.build(configuration: configuration)
    }

    func releaseKPIEntity(id: UUID) {
        kpiBuilders[id]?.releasePooledEntities()
        kpiBuilders.removeValue(forKey: id)
    }

    // MARK: - Flow Management

    func createFlowVisualizer() -> DataFlowVisualizer {
        let visualizer = DataFlowVisualizer()
        flowVisualizers.append(visualizer)
        return visualizer
    }

    // MARK: - Cleanup

    /// Release all managed entities back to the pool
    func releaseAll() {
        for (_, builder) in departmentBuilders {
            builder.releasePooledEntities()
        }
        departmentBuilders.removeAll()

        for (_, builder) in kpiBuilders {
            builder.releasePooledEntities()
        }
        kpiBuilders.removeAll()

        for visualizer in flowVisualizers {
            visualizer.releasePooledEntities()
        }
        flowVisualizers.removeAll()
    }

    /// Trim all pools to reduce memory
    func trimPools(keepRatio: Float = 0.5) {
        entityPool.trim(keepRatio: keepRatio)
    }

    /// Pre-warm pools for visualization
    func prewarmPools() async {
        await entityPool.prewarmForBusinessVisualization()
    }
}
