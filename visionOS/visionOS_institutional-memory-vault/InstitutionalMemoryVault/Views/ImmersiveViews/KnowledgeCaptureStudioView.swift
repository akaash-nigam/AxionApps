//
//  KnowledgeCaptureStudioView.swift
//  Institutional Memory Vault
//
//  Immersive environment for capturing new knowledge
//

import SwiftUI
import RealityKit

struct KnowledgeCaptureStudioView: View {
    @State private var isRecording = false
    @State private var title = ""
    @State private var content = ""

    var body: some View {
        RealityView { content in
            // Simple recording environment
            let backdropMesh = MeshResource.generatePlane(width: 3, height: 2)
            let backdropMaterial = SimpleMaterial(color: .blue.withAlphaComponent(0.1), isMetallic: false)
            let backdrop = ModelEntity(mesh: backdropMesh, materials: [backdropMaterial])
            backdrop.position = [0, 1, -2]
            content.add(backdrop)
        }
        .overlay(alignment: .center) {
            VStack(spacing: 30) {
                Text("Knowledge Capture Studio")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                VStack(spacing: 15) {
                    TextField("Knowledge Title", text: $title)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 400)

                    TextEditor(text: $content)
                        .frame(width: 400, height: 200)
                        .background(.quaternary.opacity(0.5))
                        .cornerRadius(8)
                }

                HStack(spacing: 20) {
                    Button(isRecording ? "Stop Recording" : "Start Recording") {
                        isRecording.toggle()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(isRecording ? .red : .blue)

                    Button("Save Knowledge") {
                        // Save the captured knowledge
                    }
                    .buttonStyle(.bordered)
                    .disabled(title.isEmpty)
                }
            }
            .padding(40)
            .glassBackgroundEffect()
        }
    }
}

#Preview {
    KnowledgeCaptureStudioView()
}
