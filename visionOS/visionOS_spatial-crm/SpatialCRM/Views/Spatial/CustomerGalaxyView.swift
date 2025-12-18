//
//  CustomerGalaxyView.swift
//  SpatialCRM
//
//  Immersive Customer Galaxy view
//

import SwiftUI
import RealityKit
import SwiftData

struct CustomerGalaxyView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @State private var accounts: [Account] = []

    var body: some View {
        RealityView { content in
            // Setup 3D scene
            await setupGalaxy(in: content, accounts: accounts)
        }
        .onAppear {
            loadAccounts()
        }
        .toolbar {
            ToolbarItem(placement: .bottomOrnament) {
                HStack {
                    Button("Exit Galaxy") {
                        Task {
                            await dismissImmersiveSpace()
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .glassBackgroundEffect()
            }
        }
    }

    private func loadAccounts() {
        let descriptor = FetchDescriptor<Account>()
        accounts = (try? modelContext.fetch(descriptor)) ?? []
    }

    private func setupGalaxy(in content: RealityViewContent, accounts: [Account]) async {
        // Create ambient light
        let ambientLight = AmbientLightComponent(color: .white, intensity: 300)
        let lightEntity = Entity()
        lightEntity.components[AmbientLightComponent.self] = ambientLight
        content.add(lightEntity)

        // Create customer entities in galaxy formation
        for (index, account) in accounts.enumerated() {
            let radius = Float(index % 3 + 1) * 2.0  // Tier-based orbit
            let angle = Float(index) * (2 * .pi / Float(max(accounts.count, 1)))

            let x = radius * cos(angle)
            let z = radius * sin(angle)
            let y: Float = 0

            // Create sphere for company
            let size = Float(truncating: min(account.revenue / 1_000_000, 1.0) as NSDecimalNumber) * 0.2 + 0.1
            let sphere = MeshResource.generateSphere(radius: size)
            let material = SimpleMaterial(color: .blue, isMetallic: true)
            let entity = ModelEntity(mesh: sphere, materials: [material])
            entity.position = SIMD3(x, y, z)

            // Add glow effect
            var glow = ParticleEmitterComponent()
            glow.emitterShape = .sphere
            glow.birthRate = 10
            glow.lifeSpan = 2.0
            entity.components[ParticleEmitterComponent.self] = glow

            content.add(entity)
        }
    }
}

#Preview {
    CustomerGalaxyView()
}
