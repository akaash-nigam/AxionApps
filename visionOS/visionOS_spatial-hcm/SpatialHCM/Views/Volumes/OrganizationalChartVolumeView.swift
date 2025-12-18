import SwiftUI
import RealityKit

struct OrganizationalChartVolumeView: View {
    @Environment(AppState.self) private var appState
    @State private var rotation: Angle = .zero

    var body: some View {
        RealityView { content in
            // Create 3D organizational chart
            let orgChartEntity = await createOrgChart()
            content.add(orgChartEntity)

            // Add lighting
            let light = await createLighting()
            content.add(light)
        } update: { content in
            // Update visualization based on state changes
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    rotation = .degrees(Double(value.translation.width))
                }
        )
        .task {
            await loadOrganizationData()
        }
    }

    private func loadOrganizationData() async {
        await appState.organizationState.loadOrganization(using: appState.hrService)
    }

    private func createOrgChart() async -> Entity {
        let container = Entity()

        // Create employee nodes
        let employees = appState.organizationState.employees
        for (index, employee) in employees.prefix(100).enumerated() {
            let node = await createEmployeeNode(for: employee, index: index)
            container.addChild(node)
        }

        return container
    }

    private func createEmployeeNode(for employee: Employee, index: Int) async -> ModelEntity {
        // Create a simple sphere for each employee
        let sphere = MeshResource.generateSphere(radius: 0.02)

        var material = SimpleMaterial()
        material.color = .init(tint: .blue)

        // Color coding based on performance
        if employee.performanceRating >= 90 {
            material.color = .init(tint: .green)
        } else if employee.performanceRating >= 70 {
            material.color = .init(tint: .blue)
        } else {
            material.color = .init(tint: .orange)
        }

        let entity = ModelEntity(mesh: sphere, materials: [material])

        // Position in 3D space (simplified layout)
        let angle = Float(index) * (2.0 * .pi / 100.0)
        let radius: Float = 0.3
        entity.position = SIMD3<Float>(
            cos(angle) * radius,
            sin(angle) * radius * 0.5,
            sin(angle) * radius
        )

        return entity
    }

    private func createLighting() async -> Entity {
        let light = PointLight()
        light.light.intensity = 1000
        light.light.color = .white
        light.position = [0, 0.5, 0]
        return light
    }
}

#Preview {
    OrganizationalChartVolumeView()
        .environment(AppState())
}
