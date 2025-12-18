//
//  DepartmentVolumeView.swift
//  BusinessOperatingSystem
//
//  Created by BOS Team on 2025-01-20.
//

import SwiftUI
import RealityKit

struct DepartmentVolumeView: View {
    let departmentID: Department.ID

    @Environment(\.appState) private var appState
    @Environment(\.services) private var services

    @State private var department: Department?

    var body: some View {
        RealityView { content in
            // Create 3D department visualization
            await createDepartmentVisualization(content: content)
        }
        .task {
            await loadDepartment()
        }
    }

    private func loadDepartment() async {
        do {
            let dept = try await services.repository.fetchDepartment(id: departmentID)
            department = dept
        } catch {
            print("Error loading department: \(error)")
        }
    }

    private func createDepartmentVisualization(content: RealityViewContent) async {
        // Create a simple cube as placeholder
        let mesh = MeshResource.generateBox(size: 0.5)
        var material = SimpleMaterial(color: .blue, isMetallic: false)

        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.position = [0, 0, -1]

        content.add(entity)
    }
}
