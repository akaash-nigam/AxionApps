# 3D Visualization Technical Specification
# Personal Finance Navigator

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Draft

## Table of Contents
1. [Overview](#overview)
2. [Money Flow Visualization](#money-flow-visualization)
3. [Budget Walls](#budget-walls)
4. [Investment Growth Structures](#investment-growth-structures)
5. [Bill Calendar](#bill-calendar)
6. [Debt Visualization](#debt-visualization)
7. [Performance Optimization](#performance-optimization)

## Overview

All 3D visualizations use RealityKit for rendering spatial content in visionOS. This document specifies the technical implementation of each visualization feature.

### RealityKit Setup

```swift
// RealityKitConfiguration.swift
struct RealityKitConfiguration {
    static let targetFrameRate: Int = 60
    static let maxParticles: Int = 10_000
    static let particlePoolSize: Int = 15_000
    static let cullingDistance: Float = 10.0 // meters
}
```

## Money Flow Visualization

### Particle System Architecture

```swift
// MoneyFlowParticleSystem.swift
import RealityKit

actor MoneyFlowParticleSystem {
    private var particlePool: [ParticleEntity] = []
    private var activeParticles: [ParticleEntity] = []
    private let maxParticles = RealityKitConfiguration.maxParticles

    // Initialize particle pool
    init() {
        createParticlePool()
    }

    private func createParticlePool() {
        for _ in 0..<RealityKitConfiguration.particlePoolSize {
            let particle = ParticleEntity()
            particle.isEnabled = false
            particlePool.append(particle)
        }
    }

    // Get particle from pool
    func getParticle() -> ParticleEntity? {
        guard !particlePool.isEmpty else { return nil }
        let particle = particlePool.removeFirst()
        particle.isEnabled = true
        activeParticles.append(particle)
        return particle
    }

    // Return particle to pool
    func returnParticle(_ particle: ParticleEntity) {
        particle.isEnabled = false
        particle.reset()

        if let index = activeParticles.firstIndex(where: { $0 == particle }) {
            activeParticles.remove(at: index)
        }

        particlePool.append(particle)
    }
}
```

### Particle Entity

```swift
// ParticleEntity.swift
class ParticleEntity: Entity, HasModel, HasPhysics {
    var velocity: SIMD3<Float> = [0, 0, 0]
    var lifetime: Float = 0
    var maxLifetime: Float = 5.0
    var category: TransactionCategory?

    required init() {
        super.init()
        setupModel()
        setupPhysics()
    }

    private func setupModel() {
        // Create sphere mesh for particle
        let mesh = MeshResource.generateSphere(radius: 0.01) // 1cm sphere

        // Create material with category color
        var material = SimpleMaterial()
        material.color = .init(tint: .cyan.withAlphaComponent(0.8))
        material.isMetallic = true
        material.roughness = 0.3

        model = ModelComponent(mesh: mesh, materials: [material])
    }

    private func setupPhysics() {
        let shape = ShapeResource.generateSphere(radius: 0.01)
        physics = PhysicsBodyComponent(
            massProperties: .default,
            material: .default,
            mode: .kinematic
        )
        collision = CollisionComponent(shapes: [shape])
    }

    func updateColor(for category: TransactionCategory?) {
        guard let model = model else { return }

        var material = SimpleMaterial()
        material.color = .init(tint: categoryColor(for: category))
        material.isMetallic = true
        material.roughness = 0.3

        self.model = ModelComponent(mesh: model.mesh, materials: [material])
    }

    private func categoryColor(for category: TransactionCategory?) -> UIColor {
        guard let category else { return .gray }

        switch category.name {
        case "Housing": return .systemOrange
        case "Transportation": return .systemBlue
        case "Food & Drink": return .systemGreen
        case "Shopping": return .systemPink
        case "Entertainment": return .systemPurple
        case "Healthcare": return .systemRed
        case "Utilities": return .systemYellow
        default: return .systemGray
        }
    }

    func reset() {
        velocity = [0, 0, 0]
        lifetime = 0
        category = nil
        position = [0, 0, 0]
    }
}
```

### Money Flow System

```swift
// MoneyFlowSystem.swift
class MoneyFlowSystem: System {
    private let particleSystem = MoneyFlowParticleSystem()
    private var flowStreams: [FlowStream] = []

    required init(scene: Scene) {
        super.init(scene: scene)
    }

    func update(context: SceneUpdateContext) {
        let deltaTime = Float(context.deltaTime)

        // Update all active particles
        Task {
            let particles = await particleSystem.activeParticles

            for particle in particles {
                updateParticle(particle, deltaTime: deltaTime)
            }
        }

        // Spawn new particles based on transaction flow
        for stream in flowStreams {
            spawnParticlesForStream(stream, deltaTime: deltaTime)
        }
    }

    private func updateParticle(_ particle: ParticleEntity, deltaTime: Float) {
        // Update position based on velocity
        particle.position += particle.velocity * deltaTime

        // Update lifetime
        particle.lifetime += deltaTime

        // Return to pool if expired
        if particle.lifetime >= particle.maxLifetime {
            Task {
                await particleSystem.returnParticle(particle)
            }
        }

        // Apply gravity/flow forces
        applyFlowForces(to: particle)
    }

    private func applyFlowForces(to particle: ParticleEntity) {
        // Flow downward (expenses flowing out)
        let gravity: SIMD3<Float> = [0, -0.5, 0]

        // Slight horizontal spread based on category
        let spread: SIMD3<Float> = [
            Float.random(in: -0.1...0.1),
            0,
            Float.random(in: -0.1...0.1)
        ]

        particle.velocity += gravity + spread
    }

    private func spawnParticlesForStream(_ stream: FlowStream, deltaTime: Float) {
        stream.spawnTimer += deltaTime

        // Spawn rate based on transaction amount
        let spawnRate = stream.spawnRate
        let spawnInterval = 1.0 / spawnRate

        if stream.spawnTimer >= spawnInterval {
            stream.spawnTimer = 0

            Task {
                if let particle = await particleSystem.getParticle() {
                    particle.position = stream.sourcePosition
                    particle.velocity = stream.initialVelocity
                    particle.category = stream.category
                    particle.updateColor(for: stream.category)
                }
            }
        }
    }

    func addFlowStream(for transaction: Transaction) {
        let stream = FlowStream(
            sourcePosition: calculateSourcePosition(for: transaction),
            initialVelocity: calculateInitialVelocity(for: transaction),
            category: transaction.category,
            spawnRate: calculateSpawnRate(for: transaction)
        )

        flowStreams.append(stream)
    }

    private func calculateSourcePosition(for transaction: Transaction) -> SIMD3<Float> {
        // Income flows from top
        if transaction.amount > 0 {
            return [0, 2, -2]
        }

        // Expenses flow from sides based on category
        let angle = categoryAngle(for: transaction.category)
        let radius: Float = 0.5

        return [
            cos(angle) * radius,
            1.5,
            -2 + sin(angle) * radius
        ]
    }

    private func calculateInitialVelocity(for transaction: Transaction) -> SIMD3<Float> {
        if transaction.amount > 0 {
            // Income flows down into center
            return [0, -0.3, 0]
        } else {
            // Expenses flow outward and down
            let angle = categoryAngle(for: transaction.category)
            return [
                cos(angle) * 0.2,
                -0.5,
                sin(angle) * 0.2
            ]
        }
    }

    private func calculateSpawnRate(for transaction: Transaction) -> Float {
        // More particles for larger amounts
        let amount = abs(Float(truncating: transaction.amount as NSDecimalNumber))
        return min(amount / 10.0, 100.0) // Max 100 particles/second
    }

    private func categoryAngle(for category: TransactionCategory?) -> Float {
        guard let category else { return 0 }

        // Distribute categories around circle
        let categories = ["Housing", "Transportation", "Food & Drink", "Shopping",
                         "Entertainment", "Healthcare", "Utilities"]

        guard let index = categories.firstIndex(of: category.name) else { return 0 }

        let angleStep = (2 * Float.pi) / Float(categories.count)
        return Float(index) * angleStep
    }
}

struct FlowStream {
    var sourcePosition: SIMD3<Float>
    var initialVelocity: SIMD3<Float>
    var category: TransactionCategory?
    var spawnRate: Float
    var spawnTimer: Float = 0
}
```

## Budget Walls

### Budget Wall Entity

```swift
// BudgetWallEntity.swift
class BudgetWallEntity: Entity, HasModel, HasCollision {
    var budgetCategory: BudgetCategory
    var status: BudgetStatus = .safe

    init(budgetCategory: BudgetCategory) {
        self.budgetCategory = budgetCategory
        super.init()
        setupWall()
        updateStatus()
    }

    private func setupWall() {
        // Create wall mesh
        let height: Float = 1.0
        let width: Float = 0.6
        let depth: Float = 0.05

        let mesh = MeshResource.generateBox(
            width: width,
            height: height,
            depth: depth
        )

        // Create material
        var material = SimpleMaterial()
        material.color = .init(tint: statusColor().withAlphaComponent(0.6))
        material.roughness = 0.5

        model = ModelComponent(mesh: mesh, materials: [material])

        // Setup collision
        let shape = ShapeResource.generateBox(
            width: width,
            height: height,
            depth: depth
        )
        collision = CollisionComponent(shapes: [shape])
    }

    func updateStatus() {
        let percentage = budgetCategory.spent / budgetCategory.allocated

        if percentage >= 1.0 {
            status = .exceeded
            addCracks()
        } else if percentage >= 0.9 {
            status = .danger
        } else if percentage >= 0.75 {
            status = .warning
        } else {
            status = .safe
        }

        updateMaterial()
    }

    private func statusColor() -> UIColor {
        switch status {
        case .safe: return .systemGreen
        case .warning: return .systemYellow
        case .danger: return .systemOrange
        case .exceeded: return .systemRed
        }
    }

    private func updateMaterial() {
        guard let model = model else { return }

        var material = SimpleMaterial()
        material.color = .init(tint: statusColor().withAlphaComponent(0.6))
        material.roughness = 0.5

        self.model = ModelComponent(mesh: model.mesh, materials: [material])
    }

    private func addCracks() {
        // Add crack texture overlay when budget exceeded
        // This would use a custom texture map
    }
}

enum BudgetStatus {
    case safe
    case warning
    case danger
    case exceeded
}
```

## Investment Growth Structures

### Tree Growth Entity

```swift
// InvestmentTreeEntity.swift
class InvestmentTreeEntity: Entity, HasModel {
    var portfolio: InvestmentAccount
    private var growthHeight: Float = 0

    init(portfolio: InvestmentAccount) {
        self.portfolio = portfolio
        super.init()
        buildTree()
    }

    private func buildTree() {
        // Calculate height based on portfolio value
        let baseValue: Float = 10_000 // $10k
        let currentValue = Float(truncating: portfolio.totalValue as NSDecimalNumber)
        growthHeight = log10(currentValue / baseValue) * 0.5 // Log scale

        // Trunk
        let trunkMesh = MeshResource.generateCylinder(
            height: growthHeight * 0.6,
            radius: 0.05
        )

        var trunkMaterial = SimpleMaterial()
        trunkMaterial.color = .init(tint: .brown)
        trunkMaterial.roughness = 0.8

        let trunk = ModelEntity(mesh: trunkMesh, materials: [trunkMaterial])
        trunk.position = [0, growthHeight * 0.3, 0]
        addChild(trunk)

        // Branches (holdings)
        addBranches()

        // Leaves (gains)
        if portfolio.totalGain > 0 {
            addLeaves()
        }
    }

    private func addBranches() {
        let branchCount = min(portfolio.holdings.count, 8)

        for i in 0..<branchCount {
            let angle = (Float(i) / Float(branchCount)) * 2 * .pi

            let branchLength: Float = 0.2
            let branchMesh = MeshResource.generateCylinder(
                height: branchLength,
                radius: 0.02
            )

            var material = SimpleMaterial()
            material.color = .init(tint: .brown.withAlphaComponent(0.8))

            let branch = ModelEntity(mesh: branchMesh, materials: [material])

            // Position branch around trunk
            let height = growthHeight * 0.5 + Float(i) * 0.1
            let radius: Float = 0.1

            branch.position = [
                cos(angle) * radius,
                height,
                sin(angle) * radius
            ]

            branch.orientation = simd_quatf(
                angle: .pi / 4,
                axis: [cos(angle), 0, sin(angle)]
            )

            addChild(branch)
        }
    }

    private func addLeaves() {
        // Add green spheres representing gains
        let gainPercentage = portfolio.totalGainPercent
        let leafCount = Int(gainPercentage / 5) // More leaves = more gains

        for _ in 0..<leafCount {
            let leafMesh = MeshResource.generateSphere(radius: 0.02)

            var material = SimpleMaterial()
            material.color = .init(tint: .systemGreen)

            let leaf = ModelEntity(mesh: leafMesh, materials: [material])

            // Random position in canopy
            leaf.position = [
                Float.random(in: -0.2...0.2),
                growthHeight * Float.random(in: 0.7...0.9),
                Float.random(in: -0.2...0.2)
            ]

            addChild(leaf)
        }
    }

    func animateGrowth(to newPortfolio: InvestmentAccount) {
        // Animate tree growing taller
        let newValue = Float(truncating: newPortfolio.totalValue as NSDecimalNumber)
        let baseValue: Float = 10_000
        let newHeight = log10(newValue / baseValue) * 0.5

        // Smooth growth animation
        var transform = self.transform
        let scaleFactor = newHeight / growthHeight

        let animation = FromToByAnimation(
            from: transform,
            to: Transform(scale: [1, scaleFactor, 1], translation: transform.translation),
            duration: 2.0,
            timing: .easeInOut
        )

        // Play animation
        // playAnimation(animation)

        growthHeight = newHeight
        portfolio = newPortfolio
    }
}
```

## Bill Calendar

### Calendar Grid Entity

```swift
// BillCalendarEntity.swift
class BillCalendarEntity: Entity {
    private let gridSpacing: Float = 0.15
    private let cardSize: SIMD2<Float> = [0.12, 0.08]
    private var billCards: [UUID: BillCardEntity] = [:]

    func layoutBills(_ bills: [Bill]) {
        // Group bills by date
        let calendar = Calendar.current
        let today = Date()

        for bill in bills {
            let daysUntilDue = calendar.dateComponents([.day], from: today, to: bill.dueDate).day ?? 0

            // Position based on days until due
            let row = daysUntilDue / 7 // Week
            let col = daysUntilDue % 7 // Day of week

            let position: SIMD3<Float> = [
                Float(col) * gridSpacing - (gridSpacing * 3), // Center on 7 days
                Float(row) * -gridSpacing, // Rows go down
                0
            ]

            // Create or update card
            if let existingCard = billCards[bill.id] {
                existingCard.position = position
                existingCard.update(with: bill)
            } else {
                let card = BillCardEntity(bill: bill)
                card.position = position
                billCards[bill.id] = card
                addChild(card)
            }
        }
    }
}

class BillCardEntity: Entity, HasModel {
    var bill: Bill

    init(bill: Bill) {
        self.bill = bill
        super.init()
        setupCard()
    }

    private func setupCard() {
        // Create card mesh
        let mesh = MeshResource.generatePlane(
            width: 0.12,
            height: 0.08,
            cornerRadius: 0.01
        )

        // Color based on status
        var material = SimpleMaterial()
        material.color = .init(tint: billColor())
        material.roughness = 0.4

        model = ModelComponent(mesh: mesh, materials: [material])

        // Add text (would need TextEntity in real implementation)
        addBillInfo()
    }

    private func billColor() -> UIColor {
        if bill.isPaid {
            return .systemGray
        } else if bill.dueDate < Date() {
            return .systemRed // Overdue
        } else if bill.dueDate.timeIntervalSinceNow < 86400 * 3 {
            return .systemOrange // Due soon
        } else {
            return .systemBlue // Normal
        }
    }

    private func addBillInfo() {
        // In production, use TextEntity or 2D overlay
        // This is simplified for spec
    }

    func update(with bill: Bill) {
        self.bill = bill
        setupCard()
    }
}
```

## Debt Visualization

### Debt Snowball Entity

```swift
// DebtSnowballEntity.swift
class DebtSnowballEntity: Entity, HasModel {
    var debt: Debt
    private var currentSize: Float

    init(debt: Debt) {
        self.debt = debt
        self.currentSize = calculateSize(for: debt.currentBalance)
        super.init()
        createSnowball()
    }

    private func createSnowball() {
        let mesh = MeshResource.generateSphere(radius: currentSize)

        var material = SimpleMaterial()
        material.color = .init(tint: .white.withAlphaComponent(0.8))
        material.roughness = 0.9
        material.isMetallic = false

        model = ModelComponent(mesh: mesh, materials: [material])
    }

    private func calculateSize(for balance: Decimal) -> Float {
        // Log scale for debt size
        let amount = Float(truncating: balance as NSDecimalNumber)
        return log10(amount / 100) * 0.05 // Scale to reasonable size
    }

    func animatePayment(newBalance: Decimal) {
        let newSize = calculateSize(for: newBalance)

        // Shrink animation
        let animation = FromToByAnimation(
            from: Transform(scale: [currentSize, currentSize, currentSize]),
            to: Transform(scale: [newSize, newSize, newSize]),
            duration: 1.0,
            timing: .easeOut
        )

        // Play shrinking animation with particles
        // playAnimation(animation)
        emitMeltParticles()

        currentSize = newSize
        debt.currentBalance = newBalance
    }

    private func emitMeltParticles() {
        // Emit white particles as snowball melts
        // Would use ParticleEmitterComponent
    }

    func celebratePayoff() {
        // Dramatic melting animation
        let animation = FromToByAnimation(
            from: transform,
            to: Transform(scale: [0.01, 0.01, 0.01]),
            duration: 2.0,
            timing: .easeIn
        )

        // Play with confetti particles
        emitConfetti()
    }

    private func emitConfetti() {
        // Celebratory particle effect
    }
}
```

## Performance Optimization

### Level of Detail (LOD)

```swift
// LODManager.swift
class LODManager {
    enum LODLevel {
        case high      // < 3m: Full detail
        case medium    // 3-6m: Reduced particles
        case low       // 6-10m: Simplified geometry
        case culled    // > 10m: Hidden
    }

    func determineLOD(for entity: Entity, cameraPosition: SIMD3<Float>) -> LODLevel {
        let distance = simd_distance(entity.position, cameraPosition)

        if distance < 3.0 {
            return .high
        } else if distance < 6.0 {
            return .medium
        } else if distance < 10.0 {
            return .low
        } else {
            return .culled
        }
    }

    func applyLOD(_ level: LODLevel, to entity: Entity) {
        switch level {
        case .high:
            entity.isEnabled = true
            // Full detail

        case .medium:
            entity.isEnabled = true
            // Reduce particles by 50%
            if let particleEntity = entity as? ParticleEntity {
                particleEntity.particleRate *= 0.5
            }

        case .low:
            entity.isEnabled = true
            // Use simplified geometry
            simplifyGeometry(entity)

        case .culled:
            entity.isEnabled = false
        }
    }

    private func simplifyGeometry(_ entity: Entity) {
        // Replace high-poly meshes with low-poly versions
    }
}
```

### Occlusion Culling

```swift
// Automatic in RealityKit, but can be optimized
func setupOcclusion(for entity: Entity) {
    // Enable occlusion for entities behind others
    entity.components[ModelComponent.self]?.mesh.contents.primitives.forEach { primitive in
        // Configure occlusion settings
    }
}
```

---

**Document Status**: Ready for Implementation
**Next Steps**: Testing Strategy Document
