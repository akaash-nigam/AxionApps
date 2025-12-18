//
//  CommunityView.swift
//  SpatialWellness
//
//  Created by Claude on 2025-11-17.
//  Copyright © 2025 Spatial Wellness Platform. All rights reserved.
//

import SwiftUI

/// Community view - social features and challenges
struct CommunityView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Community")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Challenges, leaderboards, and social features")
                .foregroundStyle(.secondary)

            Spacer()

            Image(systemName: "person.3.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue)

            Text("Coming Soon")
                .font(.title2)
                .fontWeight(.semibold)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    CommunityView()
}
