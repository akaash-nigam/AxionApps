//
//  HomeView.swift
//  HomeMaintenanceOracle
//
//  Created on 2025-11-24.
//  Home/Recognition screen
//

import SwiftUI

struct HomeView: View {

    // MARK: - Properties

    @StateObject private var viewModel = HomeViewModel()
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "viewfinder")
                        .font(.system(size: 80))
                        .foregroundStyle(.blue.gradient)

                    Text("Home Maintenance Oracle")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Point your Vision Pro at any appliance\nto identify it and access information")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                // Action Button
                Button {
                    startRecognition()
                } label: {
                    Label("Scan Appliance", systemImage: "camera.viewfinder")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                // Quick Stats
                quickStatsSection

                // Recent Scans
                if !viewModel.recentAppliances.isEmpty {
                    recentScansSection
                } else {
                    tipsSection
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Home")
        }
    }

    // MARK: - View Components

    private var quickStatsSection: some View {
        HStack(spacing: 20) {
            StatCard(
                icon: "cube.box.fill",
                value: "\(viewModel.recentAppliances.count)",
                label: "Appliances"
            )

            StatCard(
                icon: "wrench.and.screwdriver.fill",
                value: "0",
                label: "Tasks Due"
            )

            StatCard(
                icon: "clock.fill",
                value: "Recent",
                label: "Last Scan"
            )
        }
        .frame(maxWidth: 600)
    }

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Getting Started")
                .font(.headline)

            VStack(alignment: .leading, spacing: 12) {
                TipRow(
                    icon: "camera.viewfinder",
                    text: "Scan your appliances to add them to your inventory"
                )
                TipRow(
                    icon: "doc.text.fill",
                    text: "Access manuals and maintenance schedules instantly"
                )
                TipRow(
                    icon: "bell.fill",
                    text: "Get reminders for regular maintenance tasks"
                )
            }
        }
        .frame(maxWidth: 500)
    }

    private var recentScansSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Scans")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.recentAppliances) { appliance in
                        RecentApplianceCard(appliance: appliance)
                    }
                }
            }
        }
    }

    // MARK: - Actions

    private func startRecognition() {
        #if os(visionOS)
        Task {
            await openImmersiveSpace(id: "recognition-space")
        }
        #else
        viewModel.showingRecognition = true
        #endif
    }
}

// MARK: - Supporting Views

struct RecentApplianceCard: View {
    let appliance: Appliance

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: appliance.categoryIcon)
                .font(.title)
                .foregroundStyle(.blue)

            Text(appliance.brand)
                .font(.headline)

            Text(appliance.model)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(width: 120, height: 120)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct StatCard: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)

            Text(value)
                .font(.headline)
                .fontWeight(.semibold)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct TipRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 24)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    HomeView()
}
