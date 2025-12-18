//
//  ControlPanelView.swift
//  SmartAgriculture
//
//  Created by Claude Code
//  Copyright © 2025 Smart Agriculture. All rights reserved.
//

import SwiftUI

struct ControlPanelView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(FarmManager.self) private var farmManager

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Controls")
                .font(.title.bold())

            // Quick Actions
            QuickActionsSection()

            // Settings
            SettingsSection()

            Spacer()
        }
        .padding()
    }
}

struct QuickActionsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)

            VStack(spacing: 8) {
                ActionButton(title: "Refresh Data", icon: "arrow.clockwise")
                ActionButton(title: "Open Analytics", icon: "chart.xyaxis.line")
                ActionButton(title: "View 3D Field", icon: "view.3d")
                ActionButton(title: "Generate Report", icon: "doc.text")
            }
        }
    }
}

struct ActionButton: View {
    let title: String
    let icon: String

    var body: some View {
        Button {
            // Action placeholder
        } label: {
            HStack {
                Image(systemName: icon)
                Text(title)
                Spacer()
            }
            .padding()
            .background(.regularMaterial)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

struct SettingsSection: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        @Bindable var appModel = appModel

        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(.headline)

            VStack(alignment: .leading, spacing: 16) {
                Toggle("Use Metric Units", isOn: $appModel.settings.useMetricUnits)
                Toggle("Enable Notifications", isOn: $appModel.settings.enableNotifications)
                Toggle("Offline Mode", isOn: $appModel.settings.offlineMode)
            }
            .padding()
            .background(.regularMaterial)
            .cornerRadius(12)
        }
    }
}

#Preview {
    ControlPanelView()
        .environment(AppModel())
        .environment(FarmManager())
}
