import SwiftUI
import RealityKit

struct SharedContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack {
            if let content = appState.selectedContent {
                ContentViewer(content: content)
            } else {
                EmptyContentView()
            }
        }
    }
}

struct ContentViewer: View {
    let content: SharedContent

    var body: some View {
        VStack {
            Text(content.title)
                .font(.title2)
                .padding()

            RealityView { viewContent in
                await displayContent(content, in: viewContent)
            }
        }
    }

    private func displayContent(_ content: SharedContent, in viewContent: RealityViewContent) async {
        let entity = Entity()

        switch content.type {
        case .document, .presentation:
            // Display document as a flat panel
            let document = ModelEntity(
                mesh: .generatePlane(width: 1.0, height: 1.4),
                materials: [SimpleMaterial(color: .white, isMetallic: false)]
            )
            entity.addChild(document)

        case .model3D:
            // Display 3D model
            // In production: load from content.url
            let model = ModelEntity(
                mesh: .generateBox(size: 0.5),
                materials: [SimpleMaterial(color: .gray, isMetallic: true)]
            )
            entity.addChild(model)

        case .whiteboard:
            // Display whiteboard surface
            let whiteboard = ModelEntity(
                mesh: .generatePlane(width: 2.0, height: 1.5),
                materials: [SimpleMaterial(color: .white, isMetallic: false)]
            )
            entity.addChild(whiteboard)

        default:
            // Generic content display
            let placeholder = ModelEntity(
                mesh: .generateBox(size: 0.3),
                materials: [SimpleMaterial(color: .blue, isMetallic: false)]
            )
            entity.addChild(placeholder)
        }

        viewContent.add(entity)
    }
}

struct EmptyContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.on.doc")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No content shared yet")
                .font(.title3)
                .foregroundStyle(.secondary)

            Text("Share content from the meeting controls")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    SharedContentView()
        .environment(AppState())
}
