//
//  EvidenceClusterView.swift
//  Legal Discovery Universe
//
//  Created on 2025-11-17.
//

import SwiftUI
import RealityKit

struct EvidenceClusterView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        RealityView { content in
            let cluster = createCluster()
            content.add(cluster)
        }
    }

    private func createCluster() -> Entity {
        let root = Entity()

        // Create bounded volumetric cluster (placeholder)
        // In real implementation, would create 3D document cluster

        return root
    }
}

#Preview {
    EvidenceClusterView()
        .environment(AppState())
}
