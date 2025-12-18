//
//  ContentView.swift
//  SmartCityCommandPlatform
//
//  Root view for the application
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openImmersiveSpace) private var openImmersive

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "building.2.crop.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.blue.gradient)

                    Text("Smart City Command Platform")
                        .font(.system(size: 40, weight: .bold, design: .rounded))

                    Text("Immersive Urban Operations Management")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                // Quick Actions
                VStack(spacing: 20) {
                    Text("Launch Command Center")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 200))
                    ], spacing: 16) {
                        QuickActionCard(
                            icon: "building.2",
                            title: "Operations Center",
                            description: "Main command dashboard",
                            color: .blue
                        ) {
                            openWindow(id: "operations-center")
                        }

                        QuickActionCard(
                            icon: "chart.bar.fill",
                            title: "Analytics",
                            description: "City performance metrics",
                            color: .purple
                        ) {
                            openWindow(id: "analytics")
                        }

                        QuickActionCard(
                            icon: "exclamationmark.triangle.fill",
                            title: "Emergency Command",
                            description: "Incident response center",
                            color: .red
                        ) {
                            openWindow(id: "emergency-command")
                        }

                        QuickActionCard(
                            icon: "cube.fill",
                            title: "3D City Model",
                            description: "Volumetric visualization",
                            color: .green
                        ) {
                            openWindow(id: "city-3d")
                        }
                    }

                    Divider()
                        .padding(.vertical)

                    // Immersive Experiences
                    VStack(spacing: 12) {
                        Text("Immersive Experiences")
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 16) {
                            Button {
                                Task {
                                    await openImmersive(id: "city-immersive")
                                }
                            } label: {
                                Label("Explore City", systemImage: "map.fill")
                            }
                            .buttonStyle(.borderedProminent)
                            .buttonBorderShape(.capsule)

                            Button {
                                Task {
                                    await openImmersive(id: "crisis-management")
                                }
                            } label: {
                                Label("Crisis Mode", systemImage: "exclamationmark.shield.fill")
                            }
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.capsule)
                        }
                    }
                }
            }
            .padding(60)
            .navigationTitle("Smart City")
        }
    }
}

// MARK: - Quick Action Card

struct QuickActionCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundStyle(color.gradient)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.regularMaterial, in: .rect(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .hoverEffect()
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
