//
//  EvidenceUniverseView.swift
//  Legal Discovery Universe
//
//  Created on 2025-11-17.
//

import SwiftUI
import RealityKit

struct EvidenceUniverseView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    @State private var selectedDocument: LegalDocument?

    var body: some View {
        RealityView { content in
            // Create immersive 3D environment
            let rootEntity = Entity()

            // Add ambient lighting
            let ambientLight = createAmbientLight()
            rootEntity.addChild(ambientLight)

            // Create document galaxies (placeholder)
            if let currentCase = appState.currentCase {
                let documentGalaxy = createDocumentGalaxy(for: currentCase)
                rootEntity.addChild(documentGalaxy)
            }

            content.add(rootEntity)

        } update: { content in
            // Update 3D content when data changes
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    // Handle document selection
                    handleDocumentSelection(value.entity)
                }
        )
        .overlay(alignment: .topLeading) {
            // Floating UI controls
            evidenceUniverseControls
        }
        .onAppear {
            appState.immersiveSpaceActive = true
        }
        .onDisappear {
            appState.immersiveSpaceActive = false
        }
    }

    private var evidenceUniverseControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Evidence Universe")
                .font(.title2)
                .bold()

            if let currentCase = appState.currentCase {
                Text(currentCase.title)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("\(currentCase.totalDocuments) documents")
                    .font(.caption)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Toggle("Show Connections", isOn: .constant(true))
                Toggle("Cluster by Topic", isOn: .constant(false))
                Toggle("Timeline Mode", isOn: .constant(false))
            }
            .font(.caption)

            Divider()

            Button("Exit") {
                Task {
                    await dismissImmersiveSpace()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .glassBackgroundEffect()
        .padding()
    }

    // MARK: - 3D Content Creation

    private func createAmbientLight() -> Entity {
        let light = Entity()
        let lightComponent = AmbientLightComponent(color: .white, intensity: 500)
        light.components[AmbientLightComponent.self] = lightComponent
        return light
    }

    private func createDocumentGalaxy(for legalCase: LegalCase) -> Entity {
        let galaxy = Entity()

        // Create placeholder document spheres
        for (index, document) in legalCase.documents.prefix(50).enumerated() {
            let sphere = createDocumentSphere(for: document, index: index)
            galaxy.addChild(sphere)
        }

        return galaxy
    }

    private func createDocumentSphere(for document: LegalDocument, index: Int) -> ModelEntity {
        // Create sphere with size based on relevance
        let radius = Float(0.02 + document.relevanceScore * 0.06) // 2-8cm

        let sphere = ModelEntity(
            mesh: .generateSphere(radius: radius),
            materials: [SimpleMaterial(color: documentColor(for: document), isMetallic: false)]
        )

        // Position in 3D space (placeholder algorithm)
        let angle = Float(index) * .pi * 0.2
        let distance = Float(1.0 + document.relevanceScore)
        sphere.position = SIMD3<Float>(
            cos(angle) * distance,
            Float.random(in: -0.5...0.5),
            -sin(angle) * distance
        )

        // Add collision for interaction
        sphere.generateCollisionShapes(recursive: false)

        // Add input target component for gestures
        sphere.components[InputTargetComponent.self] = InputTargetComponent()

        // Add hover effect
        sphere.components[HoverEffectComponent.self] = HoverEffectComponent()

        return sphere
    }

    private func documentColor(for document: LegalDocument) -> UIColor {
        // Color based on relevance
        switch document.relevanceScore {
        case 0.9...1.0: return .red       // Smoking gun
        case 0.7..<0.9: return .orange    // High relevance
        case 0.5..<0.7: return .yellow    // Medium
        case 0.3..<0.5: return .blue      // Low
        default: return .gray             // Not relevant
        }
    }

    private func handleDocumentSelection(_ entity: Entity) {
        // Handle document selection from 3D space
        print("Document selected: \(entity)")
    }
}

#Preview {
    EvidenceUniverseView()
        .environment(AppState())
}
