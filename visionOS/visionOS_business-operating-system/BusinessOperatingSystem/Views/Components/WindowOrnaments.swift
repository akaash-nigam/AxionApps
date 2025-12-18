//
//  WindowOrnaments.swift
//  BusinessOperatingSystem
//
//  Created by BOS Team on 2025-01-20.
//

import SwiftUI

// MARK: - Window Ornaments

/// visionOS window ornaments for enhanced spatial UI
/// Ornaments appear outside the window bounds for additional controls

// MARK: - Ornament Position

enum OrnamentPosition {
    case top
    case bottom
    case leading
    case trailing
    case topLeading
    case topTrailing
    case bottomLeading
    case bottomTrailing

    var alignment: Alignment {
        switch self {
        case .top: return .top
        case .bottom: return .bottom
        case .leading: return .leading
        case .trailing: return .trailing
        case .topLeading: return .topLeading
        case .topTrailing: return .topTrailing
        case .bottomLeading: return .bottomLeading
        case .bottomTrailing: return .bottomTrailing
        }
    }

    var edge: Edge {
        switch self {
        case .top, .topLeading, .topTrailing: return .top
        case .bottom, .bottomLeading, .bottomTrailing: return .bottom
        case .leading: return .leading
        case .trailing: return .trailing
        }
    }
}

// MARK: - Dashboard Toolbar Ornament

/// Toolbar ornament for the main dashboard window
struct DashboardToolbarOrnament: View {
    @Binding var selectedView: DashboardSection
    @Environment(AppState.self) private var appState

    enum DashboardSection: String, CaseIterable {
        case overview = "Overview"
        case departments = "Departments"
        case kpis = "KPIs"
        case reports = "Reports"

        var icon: String {
            switch self {
            case .overview: return "square.grid.2x2"
            case .departments: return "building.2"
            case .kpis: return "chart.bar"
            case .reports: return "doc.text"
            }
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(DashboardSection.allCases, id: \.self) { section in
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selectedView = section
                    }
                } label: {
                    Label(section.rawValue, systemImage: section.icon)
                        .labelStyle(.iconOnly)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(selectedView == section ? .blue.opacity(0.2) : .clear)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .glassBackgroundEffect()
    }
}

// MARK: - Quick Actions Ornament

/// Quick actions ornament with common operations
struct QuickActionsOrnament: View {
    var onNewReport: () -> Void = {}
    var onRefresh: () -> Void = {}
    var onSettings: () -> Void = {}
    var onEnterImmersive: () -> Void = {}

    var body: some View {
        HStack(spacing: 12) {
            OrnamentButton(icon: "doc.badge.plus", label: "New Report") {
                onNewReport()
            }

            OrnamentButton(icon: "arrow.clockwise", label: "Refresh") {
                onRefresh()
            }

            Divider()
                .frame(height: 24)

            OrnamentButton(icon: "cube.transparent", label: "Immersive") {
                onEnterImmersive()
            }

            OrnamentButton(icon: "gear", label: "Settings") {
                onSettings()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .glassBackgroundEffect()
    }
}

// MARK: - Status Ornament

/// Status indicator ornament showing connection and sync state
struct StatusOrnament: View {
    @Environment(AppState.self) private var appState
    @State private var isExpanded = false

    var body: some View {
        HStack(spacing: 8) {
            // Connection status
            Circle()
                .fill(appState.isLoading ? .yellow : .green)
                .frame(width: 8, height: 8)

            if isExpanded {
                VStack(alignment: .leading, spacing: 2) {
                    Text(appState.isLoading ? "Syncing..." : "Connected")
                        .font(.caption)
                    if let org = appState.organization {
                        Text(org.name)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .leading)))
            }
        }
        .padding(.horizontal, isExpanded ? 12 : 8)
        .padding(.vertical, 6)
        .glassBackgroundEffect()
        .onTapGesture {
            withAnimation(.spring(response: 0.3)) {
                isExpanded.toggle()
            }
        }
    }
}

// MARK: - Immersion Control Ornament

/// Ornament for controlling immersion level
struct ImmersionControlOrnament: View {
    @Bindable var immersionManager = ImmersionManager.shared

    var body: some View {
        HStack(spacing: 8) {
            Button {
                Task {
                    await immersionManager.decreaseImmersion()
                }
            } label: {
                Image(systemName: "minus")
                    .font(.caption)
            }
            .buttonStyle(.plain)
            .disabled(immersionManager.currentLevel == .none)

            Image(systemName: immersionManager.currentLevel.iconName)
                .font(.body)
                .frame(width: 24)

            Button {
                Task {
                    await immersionManager.increaseImmersion()
                }
            } label: {
                Image(systemName: "plus")
                    .font(.caption)
            }
            .buttonStyle(.plain)
            .disabled(immersionManager.currentLevel >= immersionManager.maximumAllowedLevel)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .glassBackgroundEffect()
    }
}

// MARK: - KPI Summary Ornament

/// Compact KPI summary ornament
struct KPISummaryOrnament: View {
    let kpis: [KPI]

    private var healthyCount: Int {
        kpis.filter { $0.performanceStatus == .exceeding || $0.performanceStatus == .onTrack }.count
    }

    private var warningCount: Int {
        kpis.filter { $0.performanceStatus == .belowTarget }.count
    }

    private var criticalCount: Int {
        kpis.filter { $0.performanceStatus == .critical }.count
    }

    var body: some View {
        HStack(spacing: 16) {
            KPIStatusIndicator(count: healthyCount, color: .green, icon: "checkmark.circle")
            KPIStatusIndicator(count: warningCount, color: .yellow, icon: "exclamationmark.triangle")
            KPIStatusIndicator(count: criticalCount, color: .red, icon: "xmark.circle")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .glassBackgroundEffect()
    }
}

private struct KPIStatusIndicator: View {
    let count: Int
    let color: Color
    let icon: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text("\(count)")
                .font(.caption)
                .monospacedDigit()
        }
    }
}

// MARK: - Navigation Breadcrumb Ornament

/// Breadcrumb navigation ornament
struct BreadcrumbOrnament: View {
    let path: [String]
    var onNavigate: (Int) -> Void = { _ in }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(path.enumerated()), id: \.offset) { index, item in
                if index > 0 {
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Button {
                    onNavigate(index)
                } label: {
                    Text(item)
                        .font(.caption)
                        .foregroundStyle(index == path.count - 1 ? .primary : .secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .glassBackgroundEffect()
    }
}

// MARK: - Ornament Button

/// Reusable ornament button style
struct OrnamentButton: View {
    let icon: String
    let label: String
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.body)
                Text(label)
                    .font(.caption2)
            }
            .frame(minWidth: 44)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - View Extension for Ornaments

extension View {
    /// Add a toolbar ornament to the window
    func dashboardToolbar(selection: Binding<DashboardToolbarOrnament.DashboardSection>) -> some View {
        self.ornament(
            visibility: .visible,
            attachmentAnchor: .scene(.bottom),
            contentAlignment: .center
        ) {
            DashboardToolbarOrnament(selectedView: selection)
        }
    }

    /// Add quick actions ornament
    func quickActionsOrnament(
        onNewReport: @escaping () -> Void = {},
        onRefresh: @escaping () -> Void = {},
        onSettings: @escaping () -> Void = {},
        onEnterImmersive: @escaping () -> Void = {}
    ) -> some View {
        self.ornament(
            visibility: .visible,
            attachmentAnchor: .scene(.top),
            contentAlignment: .center
        ) {
            QuickActionsOrnament(
                onNewReport: onNewReport,
                onRefresh: onRefresh,
                onSettings: onSettings,
                onEnterImmersive: onEnterImmersive
            )
        }
    }

    /// Add status ornament
    func statusOrnament() -> some View {
        self.ornament(
            visibility: .visible,
            attachmentAnchor: .scene(.topTrailing),
            contentAlignment: .topTrailing
        ) {
            StatusOrnament()
        }
    }

    /// Add immersion control ornament
    func immersionControlOrnament() -> some View {
        self.ornament(
            visibility: .visible,
            attachmentAnchor: .scene(.trailing),
            contentAlignment: .center
        ) {
            ImmersionControlOrnament()
        }
    }

    /// Add KPI summary ornament
    func kpiSummaryOrnament(kpis: [KPI]) -> some View {
        self.ornament(
            visibility: .visible,
            attachmentAnchor: .scene(.bottomLeading),
            contentAlignment: .bottomLeading
        ) {
            KPISummaryOrnament(kpis: kpis)
        }
    }

    /// Add breadcrumb navigation ornament
    func breadcrumbOrnament(path: [String], onNavigate: @escaping (Int) -> Void = { _ in }) -> some View {
        self.ornament(
            visibility: .visible,
            attachmentAnchor: .scene(.topLeading),
            contentAlignment: .topLeading
        ) {
            BreadcrumbOrnament(path: path, onNavigate: onNavigate)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        QuickActionsOrnament()
        StatusOrnament()
        ImmersionControlOrnament()
        BreadcrumbOrnament(path: ["Home", "Departments", "Engineering"])
    }
    .padding()
}
