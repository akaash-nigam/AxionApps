//
//  FarmImmersiveView.swift
//  SmartAgriculture
//
//  Created by Claude Code
//  Copyright © 2025 Smart Agriculture. All rights reserved.
//

import SwiftUI
import RealityKit

struct FarmImmersiveView: View {
    @Environment(FarmManager.self) private var farmManager

    var body: some View {
        ZStack {
            Text("Farm Walkthrough (Immersive)")
                .font(.title)
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    FarmImmersiveView()
        .environment(FarmManager())
}
