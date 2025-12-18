import SwiftUI

struct GameHUDView: View {
    @EnvironmentObject private var gameStateManager: GameStateManager

    var body: some View {
        ZStack {
            // Top bar: Score and timer
            VStack {
                TopBarView()
                    .padding()

                Spacer()

                // Bottom bar: Player info
                BottomBarView()
                    .padding()
            }

            // Center: Crosshair
            CrosshairView()
        }
        .allowsHitTesting(false)  // Allow interaction to pass through
    }
}

// MARK: - Top Bar

struct TopBarView: View {
    @EnvironmentObject private var gameStateManager: GameStateManager

    var body: some View {
        HStack {
            // Attackers score
            TeamScoreView(
                teamName: "ATTACKERS",
                score: gameStateManager.matchState?.attackersScore ?? 0,
                color: .orange
            )

            Spacer()

            // Timer
            TimerView(
                timeRemaining: gameStateManager.matchState?.roundTimeRemaining ?? 120
            )

            Spacer()

            // Defenders score
            TeamScoreView(
                teamName: "DEFENDERS",
                score: gameStateManager.matchState?.defendersScore ?? 0,
                color: .blue
            )
        }
        .padding(.horizontal)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

struct TeamScoreView: View {
    let teamName: String
    let score: Int
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(teamName)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("\(score)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(color)
        }
        .padding()
    }
}

struct TimerView: View {
    let timeRemaining: TimeInterval

    var body: some View {
        VStack(spacing: 4) {
            Text("TIME")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(timeString)
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundStyle(timeRemaining < 30 ? .red : .white)
        }
        .padding()
    }

    private var timeString: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Bottom Bar

struct BottomBarView: View {
    @State private var health: Float = 100
    @State private var armor: Float = 50
    @State private var currentAmmo: Int = 25
    @State private var reserveAmmo: Int = 75

    var body: some View {
        HStack {
            // Left: Health and armor
            VStack(alignment: .leading, spacing: 8) {
                HealthBar(health: health)
                ArmorBar(armor: armor)
            }

            Spacer()

            // Center: Weapon and ammo
            VStack(spacing: 4) {
                Text("AK-47")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)

                HStack(spacing: 4) {
                    Text("\(currentAmmo)")
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)

                    Text("/")
                        .font(.system(size: 24))
                        .foregroundStyle(.secondary)

                    Text("\(reserveAmmo)")
                        .font(.system(size: 24, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Right: Mini map (placeholder)
            MiniMapView()
                .frame(width: 150, height: 150)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

struct HealthBar: View {
    let health: Float

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("HEALTH")
                .font(.caption2)
                .foregroundStyle(.secondary)

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(.black.opacity(0.3))
                    .frame(width: 200, height: 24)

                RoundedRectangle(cornerRadius: 4)
                    .fill(healthColor)
                    .frame(width: 200 * CGFloat(health / 100), height: 24)

                Text("\(Int(health))")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
            }
            .frame(width: 200)
        }
    }

    private var healthColor: Color {
        if health > 66 {
            return .green
        } else if health > 33 {
            return .orange
        } else {
            return .red
        }
    }
}

struct ArmorBar: View {
    let armor: Float

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("ARMOR")
                .font(.caption2)
                .foregroundStyle(.secondary)

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(.black.opacity(0.3))
                    .frame(width: 200, height: 20)

                RoundedRectangle(cornerRadius: 4)
                    .fill(.blue)
                    .frame(width: 200 * CGFloat(armor / 100), height: 20)

                Text("\(Int(armor))")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
            }
            .frame(width: 200)
        }
    }
}

struct MiniMapView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(.black.opacity(0.5))

            // Placeholder minimap
            Text("MAP")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
        }
    }
}

// MARK: - Crosshair

struct CrosshairView: View {
    var body: some View {
        ZStack {
            // Center dot
            Circle()
                .fill(.white)
                .frame(width: 2, height: 2)

            // Cross lines
            Rectangle()
                .fill(.white)
                .frame(width: 12, height: 2)

            Rectangle()
                .fill(.white)
                .frame(width: 2, height: 12)
        }
        .shadow(color: .black.opacity(0.5), radius: 1)
    }
}
