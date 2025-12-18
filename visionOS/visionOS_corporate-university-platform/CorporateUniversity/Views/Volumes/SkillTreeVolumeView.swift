//
//  SkillTreeVolumeView.swift
//  CorporateUniversity
//

import SwiftUI
import RealityKit

struct SkillTreeVolumeView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        RealityView { content in
            // TODO: Create 3D skill tree
            let sphere = ModelEntity(
                mesh: .generateSphere(radius: 0.1),
                materials: [SimpleMaterial(color: .blue, isMetallic: false)]
            )
            content.add(sphere)
        }
    }
}
