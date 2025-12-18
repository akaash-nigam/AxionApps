import SwiftUI
import RealityKit

struct TalentGalaxyView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        RealityView { content in
            // Create the organizational galaxy
            let galaxy = await createGalaxy()
            content.add(galaxy)

            // Add ambient particles
            let particles = await createParticleSystem()
            content.add(particles)
        }
        .onAppear {
            print("🌌 Entering Talent Galaxy immersive space")
        }
        .onDisappear {
            print("👋 Exiting Talent Galaxy")
        }
    }

    private func createGalaxy() async -> Entity {
        let container = Entity()

        let employees = appState.organizationState.employees

        // Create departments as solar systems
        for (deptIndex, department) in appState.organizationState.departments.enumerated() {
            let deptEmployees = employees.filter { $0.departmentName == department.name }

            // Position department clusters in space
            let angle = Float(deptIndex) * (2.0 * .pi / Float(appState.organizationState.departments.count))
            let radius: Float = 1.5

            for (empIndex, employee) in deptEmployees.enumerated() {
                let node = await createGalaxyNode(for: employee)

                let subAngle = Float(empIndex) * (2.0 * .pi / Float(deptEmployees.count))
                let subRadius: Float = 0.3

                node.position = SIMD3<Float>(
                    cos(angle) * radius + cos(subAngle) * subRadius,
                    sin(subAngle) * subRadius * 0.5,
                    sin(angle) * radius + sin(subAngle) * subRadius
                )

                container.addChild(node)
            }
        }

        return container
    }

    private func createGalaxyNode(for employee: Employee) async -> ModelEntity {
        let sphere = MeshResource.generateSphere(radius: 0.015)

        var material = SimpleMaterial()

        // Color based on department (simplified)
        let departmentColors: [String: UIColor] = [
            "Engineering": .systemBlue,
            "Product": .systemPurple,
            "Design": .systemOrange,
            "Sales": .systemTeal,
            "Marketing": .systemRed
        ]

        material.color = .init(tint: departmentColors[employee.departmentName] ?? .systemGray)

        // Add glow for high performers
        if employee.performanceRating >= 90 {
            material.emissiveColor = .init(color: .white)
            material.emissiveIntensity = 0.5
        }

        return ModelEntity(mesh: sphere, materials: [material])
    }

    private func createParticleSystem() async -> Entity {
        // Create ambient particles for atmosphere
        let particles = Entity()

        // In a full implementation, use ParticleEmitterComponent
        // For now, return empty entity

        return particles
    }
}

#Preview {
    TalentGalaxyView()
        .environment(AppState())
}
