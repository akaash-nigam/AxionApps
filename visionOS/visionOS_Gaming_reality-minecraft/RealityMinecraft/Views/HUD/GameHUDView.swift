//
//  GameHUDView.swift
//  Reality Minecraft
//
//  In-game HUD (heads-up display)
//

import SwiftUI

struct GameHUDView: View {
    @EnvironmentObject var gameCoordinator: GameCoordinator

    @State private var selectedHotbarSlot: Int = 0

    var body: some View {
        VStack {
            Spacer()

            // Hotbar
            HStack(spacing: 4) {
                ForEach(0..<9, id: \.self) { index in
                    HotbarSlot(
                        index: index,
                        isSelected: index == selectedHotbarSlot
                    )
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.bottom, 40)
        }
        .overlay(alignment: .topLeading) {
            // Health and Hunger
            VStack(alignment: .leading, spacing: 8) {
                HealthBar()
                HungerBar()
            }
            .padding()
        }
        .overlay(alignment: .topTrailing) {
            // FPS Counter (debug)
            Text("FPS: 90")
                .font(.caption)
                .monospaced()
                .foregroundStyle(.secondary)
                .padding()
        }
    }
}

// MARK: - Hotbar Slot

struct HotbarSlot: View {
    let index: Int
    let isSelected: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
                .frame(width: 64, height: 64)

            if isSelected {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color.white, lineWidth: 2)
                    .frame(width: 64, height: 64)
            }

            // Slot number
            Text("\(index + 1)")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .offset(x: -24, y: -24)
        }
    }
}

// MARK: - Health Bar

struct HealthBar: View {
    @State private var health: Int = 10 // 10 hearts

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<10, id: \.self) { index in
                Image(systemName: index < health ? "heart.fill" : "heart")
                    .foregroundStyle(.red)
                    .font(.caption)
            }
        }
        .padding(8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Hunger Bar

struct HungerBar: View {
    @State private var hunger: Int = 10 // 10 drumsticks

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<10, id: \.self) { index in
                Image(systemName: index < hunger ? "bolt.fill" : "bolt")
                    .foregroundStyle(.orange)
                    .font(.caption)
            }
        }
        .padding(8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    GameHUDView()
        .environmentObject(GameCoordinator())
}
