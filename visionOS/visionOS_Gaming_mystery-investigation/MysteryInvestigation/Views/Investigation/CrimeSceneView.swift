//
//  CrimeSceneView.swift
//  Mystery Investigation
//
//  Main immersive space for crime scene investigation
//

import SwiftUI
import RealityKit

struct CrimeSceneView: View {
    @Environment(GameCoordinator.self) private var coordinator
    @State private var rootEntity = Entity()

    var body: some View {
        RealityView { content in
            // Setup root entity
            content.add(rootEntity)

            // Start room scanning
            Task {
                await coordinator.spatialManager.startRoomScanning()
            }

            // Place evidence in the scene
            if let caseData = coordinator.activeCase {
                await placeEvidenceInScene(caseData.evidence, in: content)
            }
        } update: { content in
            // Update scene when case changes
        }
        .onDisappear {
            coordinator.spatialManager.stopRoomScanning()
        }
    }

    // MARK: - Evidence Placement
    @MainActor
    private func placeEvidenceInScene(_ evidenceList: [Evidence], in content: RealityViewContent) async {
        for evidence in evidenceList {
            if let entity = coordinator.spatialManager.placeEvidence(evidence, in: content.entities.first!) {
                print("Placed evidence: \(evidence.name)")
            }
        }
    }
}

#Preview {
    CrimeSceneView()
        .environment(GameCoordinator())
}
