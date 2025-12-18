//
//  DashboardView.swift
//  SmartAgriculture
//
//  Created by Claude Code
//  Copyright © 2025 Smart Agriculture. All rights reserved.
//

import SwiftUI

struct DashboardView: View {
    @Environment(FarmManager.self) private var farmManager
    @Environment(AppModel.self) private var appModel
    @Environment(ServiceContainer.self) private var services

    var body: some View {
        @Bindable var farmManager = farmManager

        NavigationSplitView {
            // MARK: - Sidebar (Farm List)
            FarmListView()
        } detail: {
            // MARK: - Main Content
            if let farm = farmManager.activeFarm {
                FarmDetailView(farm: farm)
            } else {
                EmptyFarmView()
            }
        }
        .navigationTitle("Smart Agriculture")
        .onAppear {
            if farmManager.farms.isEmpty {
                farmManager.loadFarms()
            }
        }
    }
}

// MARK: - Farm List View

struct FarmListView: View {
    @Environment(FarmManager.self) private var farmManager

    var body: some View {
        @Bindable var farmManager = farmManager

        List(farmManager.farms, id: \.id, selection: $farmManager.activeFarm) { farm in
            FarmListItem(farm: farm)
        }
        .listStyle(.sidebar)
        .navigationTitle("Farms")
    }
}

// MARK: - Farm List Item

struct FarmListItem: View {
    let farm: Farm

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "building.2.crop.circle")
                    .foregroundStyle(BrandColor.farmBlue)

                Text(farm.name)
                    .font(.headline)

                Spacer()

                HealthBadge(score: farm.averageHealth)
            }

            HStack(spacing: 16) {
                Label("\(Int(farm.totalAcres)) acres", systemImage: "map")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Label("\(farm.totalFields) fields", systemImage: "square.grid.3x3")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Farm Detail View

struct FarmDetailView: View {
    let farm: Farm

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: Farm Overview
                FarmOverviewCard(farm: farm)
                    .padding(.horizontal)

                // MARK: Field Grid
                FieldGridView(farm: farm)
                    .padding(.horizontal)

                // MARK: Recent Updates
                RecentUpdatesCard()
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle(farm.name)
    }
}

// MARK: - Farm Overview Card

struct FarmOverviewCard: View {
    let farm: Farm

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Farm Overview")
                .font(.title2.bold())

            HStack(spacing: 32) {
                StatView(
                    label: "Total Acres",
                    value: "\(Int(farm.totalAcres))",
                    icon: "map"
                )

                StatView(
                    label: "Fields",
                    value: "\(farm.totalFields)",
                    icon: "square.grid.3x3"
                )

                StatView(
                    label: "Avg Health",
                    value: "\(Int(farm.averageHealth))%",
                    icon: "heart.fill",
                    color: HealthColor.color(for: farm.averageHealth)
                )

                StatView(
                    label: "Status",
                    value: farm.healthStatus.rawValue,
                    icon: farm.healthStatus.iconName,
                    color: HealthColor.color(for: farm.averageHealth)
                )
            }
        }
        .padding(24)
        .background(.regularMaterial)
        .cornerRadius(16)
    }
}

struct StatView: View {
    let label: String
    let value: String
    let icon: String
    var color: Color = .primary

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.title.bold())

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Field Grid View

struct FieldGridView: View {
    let farm: Farm

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Field Health Overview")
                .font(.title2.bold())

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(farm.fields, id: \.id) { field in
                    FieldCard(field: field)
                }
            }
        }
    }
}

// MARK: - Empty Farm View

struct EmptyFarmView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "leaf")
                .font(.system(size: 64))
                .foregroundStyle(.green.opacity(0.5))

            VStack(spacing: 8) {
                Text("No Farm Selected")
                    .font(.title2.bold())

                Text("Select a farm from the sidebar to view details")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Recent Updates Card

struct RecentUpdatesCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Updates")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                UpdateItem(
                    icon: "globe.americas",
                    text: "Satellite imagery updated 2 hours ago"
                )

                UpdateItem(
                    icon: "cloud.sun",
                    text: "Weather: 72°F, Partly cloudy, 15% rain chance"
                )

                UpdateItem(
                    icon: "chart.xyaxis.line",
                    text: "Yield prediction updated for all fields"
                )
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

struct UpdateItem: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Preview

#Preview {
    DashboardView()
        .environment(FarmManager())
        .environment(AppModel())
        .environment(ServiceContainer())
}
