import SwiftUI

struct MainMenuView: View {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @EnvironmentObject private var gameStateManager: GameStateManager

    @State private var selectedMode: GameMode?
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [.black, Color(hex: "1a1a1a")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 40) {
                    // Title
                    VStack(spacing: 10) {
                        Text("TACTICAL TEAM SHOOTERS")
                            .font(.system(size: 48, weight: .black, design: .default))
                            .foregroundStyle(.white)

                        Text("Precision. Strategy. Teamwork.")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.gray)
                    }
                    .padding(.top, 60)

                    Spacer()

                    // Main menu buttons
                    VStack(spacing: 20) {
                        MenuButton(
                            title: "Quick Match",
                            subtitle: "Jump into action",
                            icon: "bolt.fill"
                        ) {
                            startQuickMatch()
                        }

                        MenuButton(
                            title: "Competitive",
                            subtitle: "Ranked matchmaking",
                            icon: "shield.fill"
                        ) {
                            startCompetitive()
                        }

                        MenuButton(
                            title: "Training",
                            subtitle: "Improve your skills",
                            icon: "target"
                        ) {
                            startTraining()
                        }

                        MenuButton(
                            title: "Custom Game",
                            subtitle: "Create your match",
                            icon: "slider.horizontal.3"
                        ) {
                            openCustomGame()
                        }
                    }
                    .frame(width: 400)

                    Spacer()

                    // Bottom buttons
                    HStack(spacing: 30) {
                        Button {
                            showSettings = true
                        } label: {
                            Label("Settings", systemImage: "gearshape.fill")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .buttonStyle(.bordered)

                        Button {
                            // Open player profile
                        } label: {
                            Label("Profile", systemImage: "person.fill")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }

    // MARK: - Actions

    private func startQuickMatch() {
        gameStateManager.transition(to: .matchmaking)
        Task {
            await openImmersiveSpace(id: "battlefield")
            dismissWindow(id: "main-menu")
        }
    }

    private func startCompetitive() {
        gameStateManager.transition(to: .matchmaking)
        Task {
            await openImmersiveSpace(id: "battlefield")
            dismissWindow(id: "main-menu")
        }
    }

    private func startTraining() {
        gameStateManager.transition(to: .inGame(.warmup))
        Task {
            await openImmersiveSpace(id: "battlefield")
            dismissWindow(id: "main-menu")
        }
    }

    private func openCustomGame() {
        openWindow(id: "lobby")
    }
}

// MARK: - Menu Button

struct MenuButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundStyle(Color(hex: "00A8E8"))
                    .frame(width: 50)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)

                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundStyle(.gray)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: isHovered ?
                                [Color(hex: "00A8E8").opacity(0.3), Color(hex: "0077B6").opacity(0.2)] :
                                [Color(hex: "2A2A2A"), Color(hex: "1F1F1F")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isHovered ? Color(hex: "00A8E8") : Color.white.opacity(0.1),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

enum GameMode {
    case quickMatch
    case competitive
    case training
    case custom
}
