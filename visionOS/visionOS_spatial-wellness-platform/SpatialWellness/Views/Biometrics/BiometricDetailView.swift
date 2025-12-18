//
//  BiometricDetailView.swift
//  SpatialWellness
//
//  Created by Claude on 2025-11-17.
//  Copyright © 2025 Spatial Wellness Platform. All rights reserved.
//

import SwiftUI

/// Biometric detail view - displays detailed health metrics
struct BiometricDetailView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Biometric Details")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Detailed health metrics and trends")
                .foregroundStyle(.secondary)

            Spacer()

            // Placeholder content
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 80))
                .foregroundStyle(.red)

            Text("Coming Soon")
                .font(.title2)
                .fontWeight(.semibold)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    BiometricDetailView()
}
