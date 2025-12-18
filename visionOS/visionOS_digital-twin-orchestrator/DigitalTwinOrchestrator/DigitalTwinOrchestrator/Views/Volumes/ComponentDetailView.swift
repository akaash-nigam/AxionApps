import SwiftUI
import RealityKit

struct ComponentDetailView: View {
    let componentId: UUID

    var body: some View {
        RealityView { content in
            // Component detail 3D view
            let entity = ModelEntity(
                mesh: .generateSphere(radius: 0.2),
                materials: [SimpleMaterial(color: .systemGreen, isMetallic: true)]
            )
            content.add(entity)
        }
        .ornament(attachmentAnchor: .scene(.bottom)) {
            Text("Component Detail View")
                .padding()
                .glassBackgroundEffect()
        }
    }
}
