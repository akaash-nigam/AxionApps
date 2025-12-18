// MoneyFlowRealityView.swift
// Personal Finance Navigator
// 3D money flow visualization using RealityKit

import SwiftUI
import RealityKit

/// 3D visualization of money flow by category
struct MoneyFlowRealityView: View {
    @State private var viewModel: MoneyFlowViewModel

    init(viewModel: MoneyFlowViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // RealityView for 3D content
                RealityView { content in
                    // Set up the 3D scene
                    await viewModel.setupScene(in: content)
                } update: { content in
                    // Update the scene when data changes
                    await viewModel.updateScene(in: content)
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            viewModel.handleDrag(value)
                        }
                )
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            viewModel.handleZoom(value)
                        }
                )

                // Overlay UI
                VStack {
                    // Info panel
                    if viewModel.showInfo {
                        MoneyFlowInfoPanel(
                            flows: viewModel.categoryFlows,
                            totalAmount: viewModel.totalAmount,
                            formatCurrency: viewModel.formatCurrency
                        )
                        .padding()
                    }

                    Spacer()

                    // Controls
                    MoneyFlowControls(viewModel: viewModel)
                        .padding()
                }
            }
            .navigationTitle("Money Flow")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        viewModel.showInfo.toggle()
                    }) {
                        Image(systemName: "info.circle")
                    }
                }

                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        Task {
                            await viewModel.refresh()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .task {
                await viewModel.loadData()
            }
        }
    }
}

// MARK: - Money Flow ViewModel

@MainActor
@Observable
class MoneyFlowViewModel {
    // MARK: - State

    private(set) var categoryFlows: [CategoryFlow] = []
    private(set) var totalAmount: Decimal = 0
    private(set) var isLoading = false
    var showInfo = true

    // Scene state
    private var particleSystems: [UUID: ParticleSystem] = [:]
    private var rootEntity: Entity?

    // Camera controls
    private var cameraDistance: Float = 3.0
    private var cameraRotation: Float = 0.0

    // MARK: - Dependencies

    private let transactionRepository: TransactionRepository
    private let categoryRepository: CategoryRepository

    init(
        transactionRepository: TransactionRepository,
        categoryRepository: CategoryRepository
    ) {
        self.transactionRepository = transactionRepository
        self.categoryRepository = categoryRepository
    }

    // MARK: - Data Loading

    func loadData() async {
        isLoading = true

        do {
            // Get transactions for current month
            let calendar = Calendar.current
            let now = Date()
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!

            let transactions = try await transactionRepository.fetchTransactions(
                from: startOfMonth,
                to: now
            )

            // Group by category and calculate totals
            let expenseTransactions = transactions.filter { $0.amount < 0 && !$0.isExcludedFromBudget }
            let grouped = Dictionary(grouping: expenseTransactions) { $0.categoryId }

            var flows: [CategoryFlow] = []
            totalAmount = 0

            for (categoryId, categoryTransactions) in grouped {
                guard let categoryId = categoryId else { continue }

                // Get category details
                if let category = try? await categoryRepository.fetch(by: categoryId) {
                    let amount = categoryTransactions.reduce(Decimal.zero) { $0 + abs($1.amount) }
                    totalAmount += amount

                    flows.append(CategoryFlow(
                        id: categoryId,
                        name: category.name,
                        amount: amount,
                        color: category.color,
                        transactionCount: categoryTransactions.count
                    ))
                }
            }

            // Sort by amount descending
            categoryFlows = flows.sorted { $0.amount > $1.amount }

        } catch {
            print("Failed to load money flow data: \(error)")
        }

        isLoading = false
    }

    func refresh() async {
        await loadData()
        // Recreate particle systems with new data
        if let root = rootEntity {
            await updateParticleSystems(in: root)
        }
    }

    // MARK: - Scene Setup

    func setupScene(in content: RealityViewContent) async {
        let root = Entity()
        rootEntity = root

        // Add lighting
        let directionalLight = DirectionalLight()
        directionalLight.light.intensity = 5000
        directionalLight.position = [0, 2, 0]
        directionalLight.look(at: [0, 0, 0], from: directionalLight.position, relativeTo: nil)
        root.addChild(directionalLight)

        // Add ambient light
        let ambientLight = PointLight()
        ambientLight.light.intensity = 2000
        ambientLight.position = [0, 1, 0]
        root.addChild(ambientLight)

        // Create particle systems for each category
        await updateParticleSystems(in: root)

        content.add(root)
    }

    func updateScene(in content: RealityViewContent) async {
        guard let root = rootEntity else { return }
        await updateParticleSystems(in: root)
    }

    // MARK: - Particle Systems

    private func updateParticleSystems(in root: Entity) async {
        // Remove existing particle systems
        for (_, system) in particleSystems {
            system.entity.removeFromParent()
        }
        particleSystems.removeAll()

        // Create new particle systems for each category
        let flowCount = categoryFlows.count
        guard flowCount > 0 else { return }

        for (index, flow) in categoryFlows.enumerated() {
            let angle = Float(index) * (2 * .pi / Float(flowCount))
            let radius: Float = 1.5

            let x = cos(angle) * radius
            let z = sin(angle) * radius

            let particleSystem = createParticleSystem(
                for: flow,
                at: [x, 1.5, z]
            )

            root.addChild(particleSystem.entity)
            particleSystems[flow.id] = particleSystem
        }
    }

    private func createParticleSystem(for flow: CategoryFlow, at position: SIMD3<Float>) -> ParticleSystem {
        // Create container entity
        let entity = Entity()
        entity.position = position

        // Create emitter sphere
        let emitterMesh = MeshResource.generateSphere(radius: 0.1)
        let emitterMaterial = SimpleMaterial(color: flow.color.uiColor, isMetallic: false)
        let emitter = ModelEntity(mesh: emitterMesh, materials: [emitterMaterial])
        entity.addChild(emitter)

        // Create particle stream (using spheres as particles)
        let particleCount = min(Int(flow.relativeAmount * 50), 100)

        for i in 0..<particleCount {
            let particle = createParticle(
                color: flow.color,
                delay: Float(i) * 0.05,
                duration: 3.0
            )

            // Position particle below emitter
            let yOffset = -Float(i) * 0.03
            particle.position = [0, yOffset, 0]

            entity.addChild(particle)

            // Animate particle
            animateParticle(particle, delay: Float(i) * 0.05)
        }

        // Add category label (3D text would require more setup)
        // For now, we'll use a simple model as a placeholder

        return ParticleSystem(entity: entity, flow: flow)
    }

    private func createParticle(color: Color, delay: Float, duration: Float) -> ModelEntity {
        let mesh = MeshResource.generateSphere(radius: 0.02)
        let material = SimpleMaterial(color: color.uiColor.withAlphaComponent(0.7), isMetallic: true)
        let particle = ModelEntity(mesh: mesh, materials: [material])
        return particle
    }

    private func animateParticle(_ particle: ModelEntity, delay: Float) {
        // Animate particle falling
        let startY = particle.position.y
        let endY = startY - 2.0

        Task {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))

            // Simple animation loop
            while true {
                var transform = particle.transform
                transform.translation.y = endY

                // Fade out as it falls
                particle.model?.materials = particle.model?.materials.map { material in
                    guard var simpleMaterial = material as? SimpleMaterial else { return material }
                    simpleMaterial.color.tint = simpleMaterial.color.tint.withAlphaComponent(0.1)
                    return simpleMaterial
                } ?? []

                // Reset to top
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                transform.translation.y = startY
                particle.transform = transform

                // Fade in
                particle.model?.materials = particle.model?.materials.map { material in
                    guard var simpleMaterial = material as? SimpleMaterial else { return material }
                    simpleMaterial.color.tint = simpleMaterial.color.tint.withAlphaComponent(0.7)
                    return simpleMaterial
                } ?? []
            }
        }
    }

    // MARK: - Gesture Handling

    func handleDrag(_ value: DragGesture.Value) {
        let rotation = Float(value.translation.width) * 0.01
        cameraRotation += rotation

        // Apply rotation to all entities
        if let root = rootEntity {
            root.orientation = simd_quatf(angle: cameraRotation, axis: [0, 1, 0])
        }
    }

    func handleZoom(_ value: MagnificationGesture.Value) {
        let newDistance = cameraDistance / Float(value.magnitude)
        cameraDistance = max(1.0, min(newDistance, 5.0))

        // Apply scale to root entity
        if let root = rootEntity {
            root.scale = [1.0 / cameraDistance, 1.0 / cameraDistance, 1.0 / cameraDistance]
        }
    }

    // MARK: - Formatting

    func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0.00"
    }
}

// MARK: - Supporting Types

struct CategoryFlow: Identifiable {
    let id: UUID
    let name: String
    let amount: Decimal
    let color: Color
    let transactionCount: Int

    var relativeAmount: Float {
        // This will be calculated relative to total in the view model
        0.5
    }
}

struct ParticleSystem {
    let entity: Entity
    let flow: CategoryFlow
}

extension Color {
    var uiColor: UIColor {
        UIColor(self)
    }
}

// MARK: - Info Panel

struct MoneyFlowInfoPanel: View {
    let flows: [CategoryFlow]
    let totalAmount: Decimal
    let formatCurrency: (Decimal) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spending by Category")
                .font(.headline)

            Text(formatCurrency(totalAmount))
                .font(.title)
                .fontWeight(.bold)

            Divider()

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(flows) { flow in
                        HStack {
                            Circle()
                                .fill(flow.color)
                                .frame(width: 12, height: 12)

                            Text(flow.name)
                                .font(.subheadline)

                            Spacer()

                            Text(formatCurrency(flow.amount))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            .frame(maxHeight: 200)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Controls

struct MoneyFlowControls: View {
    @Bindable var viewModel: MoneyFlowViewModel

    var body: some View {
        HStack(spacing: 16) {
            Button(action: {
                viewModel.showInfo.toggle()
            }) {
                Label(
                    viewModel.showInfo ? "Hide Info" : "Show Info",
                    systemImage: viewModel.showInfo ? "eye.slash" : "eye"
                )
            }
            .buttonStyle(.bordered)

            Button(action: {
                Task {
                    await viewModel.refresh()
                }
            }) {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Preview

#Preview {
    let container = DependencyContainer()
    let viewModel = MoneyFlowViewModel(
        transactionRepository: container.transactionRepository,
        categoryRepository: container.categoryRepository
    )
    return MoneyFlowRealityView(viewModel: viewModel)
}
