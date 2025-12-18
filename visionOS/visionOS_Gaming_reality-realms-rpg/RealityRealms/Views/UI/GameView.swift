//
//  GameView.swift
//  Reality Realms RPG
//
//  Main immersive game view
//

import SwiftUI
import RealityKit

struct GameView: View {
    @EnvironmentObject var gameStateManager: GameStateManager
    @StateObject private var gameLoop = GameLoop()

    @State private var showHUD = true
    @State private var showInventory = false

    var body: some View {
        ZStack {
            // RealityKit view for 3D content
            RealityView { content in
                setupScene(content: content)
            } update: { content in
                updateScene(content: content)
            }

            // HUD overlay
            if showHUD {
                HUDView()
                    .environmentObject(gameStateManager)
            }

            // Inventory overlay
            if showInventory {
                InventoryView()
                    .transition(.move(edge: .trailing))
            }

            // Debug overlay
            #if DEBUG
            DebugOverlay()
            #endif
        }
        .onAppear {
            gameLoop.start()
        }
        .onDisappear {
            gameLoop.stop()
        }
        .gesture(
            SpatialTapGesture()
                .onEnded { value in
                    handleTap(at: value.location)
                }
        )
    }

    // MARK: - Scene Setup

    private func setupScene(content: RealityViewContent) {
        print("🎬 Setting up game scene")

        // Create root entity
        let rootEntity = Entity()
        content.add(rootEntity)

        // Add ambient lighting
        let ambientLight = Entity()
        var ambientComponent = AmbientLightComponent()
        ambientComponent.intensity = 1000
        ambientLight.components[AmbientLightComponent.self] = ambientComponent
        rootEntity.addChild(ambientLight)

        // Add directional light
        let directionalLight = Entity()
        var dirLightComponent = DirectionalLightComponent()
        dirLightComponent.intensity = 2000
        dirLightComponent.shadow = DirectionalLightComponent.Shadow()
        directionalLight.components[DirectionalLightComponent.self] = dirLightComponent
        directionalLight.look(at: [0, -1, 0], from: [0, 5, 0], relativeTo: nil)
        rootEntity.addChild(directionalLight)

        print("✅ Game scene setup complete")
    }

    private func updateScene(content: RealityViewContent) {
        // Update scene based on game state
        switch gameStateManager.currentState {
        case .gameplay(let gameplayState):
            updateGameplayScene(content: content, state: gameplayState)
        case .roomScanning:
            // Show room scanning UI
            break
        case .tutorial:
            // Show tutorial elements
            break
        default:
            break
        }
    }

    private func updateGameplayScene(content: RealityViewContent, state: GameplayState) {
        // Update based on gameplay state
        switch state {
        case .exploration:
            break
        case .combat(let enemyCount):
            // Update combat UI
            break
        default:
            break
        }
    }

    // MARK: - Interaction

    private func handleTap(at location: SIMD3<Double>) {
        print("👆 Tap at: \(location)")
        // Handle tap interaction
    }
}

// MARK: - HUD View

struct HUDView: View {
    @EnvironmentObject var gameStateManager: GameStateManager
    @StateObject private var performanceMonitor = PerformanceMonitor.shared

    var body: some View {
        ZStack {
            // Top: Quest tracker
            VStack {
                HStack {
                    QuestTrackerView()
                        .padding()
                    Spacer()
                }
                Spacer()
            }

            // Health/Mana orbs (left and right wrists)
            VStack {
                Spacer()
                HStack {
                    HealthOrbView(health: 85, maxHealth: 120)
                        .padding(.leading, 50)
                        .padding(.bottom, 100)

                    Spacer()

                    ManaOrbView(mana: 100, maxMana: 150)
                        .padding(.trailing, 50)
                        .padding(.bottom, 100)
                }
            }

            // Bottom: Active abilities
            VStack {
                Spacer()
                AbilityBarView()
                    .padding(.bottom, 20)
            }
        }
    }
}

// MARK: - HUD Components

struct QuestTrackerView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Active Quest")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))

            Text("Defend Your Throne")
                .font(.headline)
                .foregroundColor(.white)

            HStack {
                Text("Enemies Defeated: 5/10")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.6))
                .blur(radius: 10)
        )
    }
}

struct HealthOrbView: View {
    let health: Int
    let maxHealth: Int

    var healthPercent: Double {
        Double(health) / Double(maxHealth)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.red.opacity(0.3), lineWidth: 8)
                .frame(width: 80, height: 80)

            Circle()
                .trim(from: 0, to: healthPercent)
                .stroke(
                    LinearGradient(
                        colors: [.red, .pink],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 80, height: 80)
                .rotationEffect(.degrees(-90))

            VStack(spacing: 2) {
                Text("\(health)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("HP")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .shadow(color: .red.opacity(0.5), radius: 10)
    }
}

struct ManaOrbView: View {
    let mana: Int
    let maxMana: Int

    var manaPercent: Double {
        Double(mana) / Double(maxMana)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.blue.opacity(0.3), lineWidth: 8)
                .frame(width: 80, height: 80)

            Circle()
                .trim(from: 0, to: manaPercent)
                .stroke(
                    LinearGradient(
                        colors: [.blue, .cyan],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 80, height: 80)
                .rotationEffect(.degrees(-90))

            VStack(spacing: 2) {
                Text("\(mana)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("MP")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .shadow(color: .blue.opacity(0.5), radius: 10)
    }
}

struct AbilityBarView: View {
    var body: some View {
        HStack(spacing: 15) {
            AbilitySlot(icon: "flame.fill", cooldown: 0, color: .orange)
            AbilitySlot(icon: "snowflake", cooldown: 2.5, color: .cyan)
            AbilitySlot(icon: "bolt.fill", cooldown: 0, color: .yellow)
            AbilitySlot(icon: "heart.fill", cooldown: 5.0, color: .green)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.black.opacity(0.5))
                .blur(radius: 10)
        )
    }
}

struct AbilitySlot: View {
    let icon: String
    let cooldown: Double
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.3))
                .frame(width: 60, height: 60)

            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)

            if cooldown > 0 {
                Circle()
                    .fill(Color.black.opacity(0.7))
                    .frame(width: 60, height: 60)

                Text(String(format: "%.1f", cooldown))
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
        .shadow(color: color.opacity(0.5), radius: 5)
    }
}

// MARK: - Inventory View

struct InventoryView: View {
    var body: some View {
        VStack {
            Text("Inventory")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            Text("Coming soon...")
                .foregroundColor(.secondary)

            Spacer()
        }
        .frame(width: 400, height: 600)
        .background(Color.black.opacity(0.8))
        .cornerRadius(20)
    }
}

// MARK: - Debug Overlay

struct DebugOverlay: View {
    @StateObject private var performanceMonitor = PerformanceMonitor.shared

    var body: some View {
        VStack {
            HStack {
                Spacer()
                VStack(alignment: .trailing, spacing: 5) {
                    Text("FPS: \(String(format: "%.1f", performanceMonitor.currentFPS))")
                        .font(.system(.caption, design: .monospaced))
                    Text("Frame: \(String(format: "%.2f", performanceMonitor.frameTime * 1000))ms")
                        .font(.system(.caption, design: .monospaced))
                    Text("Memory: \(String(format: "%.0f", performanceMonitor.getMemoryUsageMB()))MB")
                        .font(.system(.caption, design: .monospaced))
                    Text("Quality: \(performanceMonitor.qualityLevel.rawValue)")
                        .font(.system(.caption, design: .monospaced))
                }
                .foregroundColor(.green)
                .padding(8)
                .background(Color.black.opacity(0.7))
                .cornerRadius(8)
                .padding()
            }
            Spacer()
        }
    }
}

#Preview {
    GameView()
        .environmentObject(GameStateManager.shared)
}
