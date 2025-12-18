//
//  SettingsView.swift
//  SpatialWellness
//
//  Created by Claude on 2025-11-17.
//  Copyright © 2025 Spatial Wellness Platform. All rights reserved.
//

import SwiftUI

/// Settings view - app configuration and preferences
struct SettingsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Privacy, permissions, and preferences")
                .foregroundStyle(.secondary)

            Spacer()

            Image(systemName: "gearshape.2.fill")
                .font(.system(size: 80))
                .foregroundStyle(.gray)

            Text("Coming Soon")
                .font(.title2)
                .fontWeight(.semibold)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    SettingsView()
}
