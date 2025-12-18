import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var gameCoordinator: GameCoordinator
    @State private var showCaseSelection = false
    @State private var showSettings = false
    @State private var showProfile = false

    var body: some View {
        ZStack {
            // Background
            backgroundGradient

            VStack(spacing: 40) {
                // Title
                titleSection

                Spacer()

                // Main Menu Buttons
                menuButtons

                Spacer()

                // Footer
                footerSection
            }
            .padding(60)
        }
        .sheet(isPresented: $showCaseSelection) {
            CaseSelectionView()
                .environmentObject(gameCoordinator)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(appState)
        }
        .sheet(isPresented: $showProfile) {
            ProfileView()
                .environmentObject(appState)
        }
    }

    // MARK: - View Components

    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.1, green: 0.15, blue: 0.2),
                Color(red: 0.05, green: 0.1, blue: 0.15)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var titleSection: some View {
        VStack(spacing: 10) {
            Image(systemName: "magnifyingglass.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.yellow)

            Text("Mystery Investigation")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.white)

            Text("Become the detective")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.gray)
        }
    }

    private var menuButtons: some View {
        VStack(spacing: 20) {
            // Continue Case (if exists)
            if !gameCoordinator.investigationState.discoveredEvidence.isEmpty {
                MenuButton(
                    title: "Continue Case",
                    icon: "play.circle.fill",
                    color: .green
                ) {
                    continueCurrentCase()
                }
            }

            // New Case
            MenuButton(
                title: "New Case",
                icon: "folder.badge.plus",
                color: .blue
            ) {
                showCaseSelection = true
            }

            // Case Archive
            MenuButton(
                title: "Case Archive",
                icon: "archivebox.fill",
                color: .purple
            ) {
                showCaseSelection = true
            }

            // Profile & Stats
            MenuButton(
                title: "Profile & Stats",
                icon: "person.circle.fill",
                color: .orange
            ) {
                showProfile = true
            }

            // Settings
            MenuButton(
                title: "Settings",
                icon: "gearshape.fill",
                color: .gray
            ) {
                showSettings = true
            }
        }
        .frame(maxWidth: 500)
    }

    private var footerSection: some View {
        VStack(spacing: 8) {
            // Player Rank
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text(appState.playerProgress.currentRank.rawValue)
                    .font(.headline)
                    .foregroundColor(.white)
            }

            // Experience
            ProgressView(value: Float(appState.playerProgress.experience % 500), total: 500)
                .tint(.yellow)
                .frame(width: 200)

            Text("XP: \(appState.playerProgress.experience)")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }

    // MARK: - Actions

    private func continueCurrentCase() {
        appState.transitionToState(.investigating)
    }
}

// MARK: - Menu Button Component

struct MenuButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(color)
                    .frame(width: 40)

                Text(title)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isHovered ? Color.white.opacity(0.1) : Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.3), lineWidth: isHovered ? 2 : 0)
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

// MARK: - Preview

#Preview {
    MainMenuView()
        .environmentObject(AppState())
        .environmentObject(GameCoordinator())
}
