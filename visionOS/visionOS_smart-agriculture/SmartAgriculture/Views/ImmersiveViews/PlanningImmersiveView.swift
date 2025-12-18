//
//  PlanningImmersiveView.swift
//  SmartAgriculture
//
//  Created by Claude Code
//  Copyright © 2025 Smart Agriculture. All rights reserved.
//

import SwiftUI
import RealityKit

struct PlanningImmersiveView: View {
    @Environment(FarmManager.self) private var farmManager

    var body: some View {
        ZStack {
            Text("Planning Mode (Mixed Reality)")
                .font(.title)
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    PlanningImmersiveView()
        .environment(FarmManager())
}
