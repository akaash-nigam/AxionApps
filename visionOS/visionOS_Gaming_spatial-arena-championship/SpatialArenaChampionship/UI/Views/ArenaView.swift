//
//  ArenaView.swift
//  Spatial Arena Championship
//
//  Main arena immersive space view
//

import SwiftUI
import RealityKit

struct ArenaView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        RealityView { content in
            // TODO: Initialize RealityKit scene
            // - Create arena entities
            // - Set up player entity
            // - Initialize game systems
            // - Start game loop

            // Placeholder: Add a simple entity for testing
            let mesh = MeshResource.generateSphere(radius: 0.1)
            let material = SimpleMaterial(color: .cyan, isMetallic: false)
            let sphere = ModelEntity(mesh: mesh, materials: [material])
            sphere.position = [0, 1.5, -1.0]

            content.add(sphere)

            // Add ambient lighting
            let light = DirectionalLight()
            light.light.intensity = 1000
            light.look(at: [0, 0, 0], from: [1, 2, 1], relativeTo: nil)
            content.add(light)

        } update: { content in
            // Update loop for RealityKit scene
            // This will be called when appState changes
        }
        .upperLimbVisibility(.visible)
        .overlay(alignment: .topLeading) {
            // HUD Overlay
            HUDView()
                .environment(appState)
        }
    }
}

// MARK: - HUD View

struct HUDView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Match info
            if appState.isInMatch, let match = appState.currentMatch {
                HStack {
                    // Timer
                    Text(formatTime(match.duration))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Spacer()

                    // Score
                    HStack(spacing: 30) {
                        VStack {
                            Text("\(match.team1.score)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: 0x00BFFF))

                            Text(match.team1.name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Text("-")
                            .font(.title2)
                            .foregroundColor(.secondary)

                        VStack {
                            Text("\(match.team2.score)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: 0xFF4444))

                            Text(match.team2.name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            // Player stats (health, shields, energy)
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    // Health
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(Color(hex: 0x00ff88))

                        Text("Health")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    ProgressView(value: 0.8)
                        .tint(Color(hex: 0x00ff88))

                    // Shields
                    HStack {
                        Image(systemName: "shield.fill")
                            .foregroundColor(Color(hex: 0x00bfff))

                        Text("Shields")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    ProgressView(value: 0.6)
                        .tint(Color(hex: 0x00bfff))

                    // Energy
                    HStack {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(Color(hex: 0xffaa00))

                        Text("Energy")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    ProgressView(value: 0.7)
                        .tint(Color(hex: 0xffaa00))
                }
                .frame(width: 200)
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Abilities (placeholder)
            VStack(alignment: .leading, spacing: 8) {
                Text("ABILITIES")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)

                HStack(spacing: 12) {
                    AbilityIcon(letter: "Q", cooldown: 0, isReady: true)
                    AbilityIcon(letter: "E", cooldown: 3.5, isReady: false)
                    AbilityIcon(letter: "R", cooldown: 0, isReady: true, isUltimate: true)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Spacer()
        }
        .padding()
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Ability Icon

struct AbilityIcon: View {
    let letter: String
    let cooldown: Double
    let isReady: Bool
    var isUltimate: Bool = false

    var body: some View {
        ZStack {
            Circle()
                .fill(isReady ?
                    (isUltimate ? Color(hex: 0xaa00ff) : Color(hex: 0x00d4ff)).opacity(0.3) :
                    Color.gray.opacity(0.3)
                )
                .frame(width: 50, height: 50)

            if !isReady {
                Circle()
                    .trim(from: 0, to: cooldown / 10.0)
                    .stroke(Color.gray, lineWidth: 3)
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))

                Text(String(format: "%.1f", cooldown))
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            } else {
                Text(letter)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ArenaView()
        .environment(AppState())
}
