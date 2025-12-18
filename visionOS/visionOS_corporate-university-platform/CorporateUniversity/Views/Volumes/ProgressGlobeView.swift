//
//  ProgressGlobeView.swift
//  CorporateUniversity
//

import SwiftUI
import RealityKit

struct ProgressGlobeView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        RealityView { content in
            // TODO: Create rotating progress globe
            let sphere = ModelEntity(
                mesh: .generateSphere(radius: 0.3),
                materials: [SimpleMaterial(color: .green, isMetallic: true)]
            )
            sphere.transform.translation = [0, 0, -0.5]
            content.add(sphere)
        }
    }
}
