//
//  LearningEnvironmentView.swift
//  CorporateUniversity
//

import SwiftUI
import RealityKit

struct LearningEnvironmentView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        RealityView { content in
            // TODO: Create immersive learning environment
            // This would load from Reality Composer Pro

            // Placeholder: Create a simple room
            let floor = ModelEntity(
                mesh: .generatePlane(width: 10, depth: 10),
                materials: [SimpleMaterial(color: .gray, isMetallic: false)]
            )
            floor.position = [0, 0, 0]
            content.add(floor)

            // Add some objects
            for i in 0..<5 {
                let cube = ModelEntity(
                    mesh: .generateBox(size: 0.2),
                    materials: [SimpleMaterial(color: .blue, isMetallic: false)]
                )
                cube.position = [Float(i) * 0.5 - 1.0, 0.5, -2.0]
                content.add(cube)
            }
        }
    }
}
