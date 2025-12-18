import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.modelContext) private var modelContext

    @State private var deviceManager: DeviceManager?
    @State private var persistenceManager: PersistenceManager?
    @State private var showImmersiveSpace = false
    @State private var showOnboarding = false
    @State private var onboardingComplete = false

    @Query private var homes: [Home]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HeaderSection()

                    // Status Overview
                    StatusSection()

                    // Device Grid
                    DeviceGridSection()

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Living Building System")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        openWindow(id: "settings")
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                }

                ToolbarItem(placement: .automatic) {
                    Button {
                        openWindow(id: "energy")
                    } label: {
                        Label("Energy", systemImage: "bolt.fill")
                    }
                }

                ToolbarItem(placement: .automatic) {
                    Button {
                        Task {
                            await enterImmersiveSpace()
                        }
                    } label: {
                        Label("Enter Immersive View", systemImage: "view.3d")
                    }
                    .disabled(showImmersiveSpace)
                }

                ToolbarItem(placement: .automatic) {
                    Button {
                        Task {
                            try? await deviceManager?.discoverDevices()
                        }
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                    .disabled(appState.isLoadingDevices)
                }
            }
        }
        .task {
            // Initialize managers
            let service = HomeKitService()
            deviceManager = DeviceManager(appState: appState, homeKitService: service)
            persistenceManager = PersistenceManager(modelContext: modelContext, appState: appState)

            // Check if onboarding needed
            if homes.isEmpty && !onboardingComplete {
                showOnboarding = true
            } else {
                // Load saved state
                do {
                    try await persistenceManager?.loadSavedState()
                } catch {
                    Logger.shared.log("Failed to load saved state", level: .error, error: error)
                }

                // Request authorization and discover devices
                do {
                    try await service.requestAuthorization()
                    try await deviceManager?.discoverDevices()
                } catch {
                    appState.handleError(error)
                }

                // Start auto-save
                persistenceManager?.startAutoSave()
            }
        }
        .overlay {
            if appState.isLoadingDevices {
                ProgressView("Discovering devices...")
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
            }
        }
        .overlay(alignment: .top) {
            if let error = appState.currentError {
                ErrorBanner(error: error) {
                    appState.dismissError()
                }
                .padding()
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .sheet(isPresented: $showOnboarding) {
            OnboardingView(onboardingComplete: $onboardingComplete)
                .interactiveDismissDisabled()
        }
        .onChange(of: onboardingComplete) { _, isComplete in
            if isComplete {
                // Reload after onboarding
                Task {
                    try? await persistenceManager?.loadSavedState()

                    // Discover devices
                    let service = HomeKitService()
                    deviceManager = DeviceManager(appState: appState, homeKitService: service)
                    try? await service.requestAuthorization()
                    try? await deviceManager?.discoverDevices()

                    // Start auto-save
                    persistenceManager?.startAutoSave()
                }
            }
        }
    }

    // MARK: - Actions

    private func enterImmersiveSpace() async {
        Logger.shared.log("Entering immersive space", category: "Dashboard")

        showImmersiveSpace = true

        switch await openImmersiveSpace(id: "home-view") {
        case .opened:
            Logger.shared.log("Immersive space opened", category: "Dashboard")
            // Optionally dismiss dashboard window
            dismissWindow(id: "dashboard")

        case .error:
            Logger.shared.log("Failed to open immersive space", level: .error, category: "Dashboard")
            showImmersiveSpace = false
            appState.handleError(LBSError.unknown(NSError(domain: "ImmersiveSpace", code: -1)))

        case .userCancelled:
            Logger.shared.log("User cancelled immersive space", category: "Dashboard")
            showImmersiveSpace = false

        @unknown default:
            showImmersiveSpace = false
        }
    }
}

// MARK: - Header Section

struct HeaderSection: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let home = appState.currentHome {
                Text(home.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                if let address = home.address {
                    Text(address)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("Welcome")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Set up your home to get started")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text(Date.now, style: .date)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Status Section

struct StatusSection: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        HStack(spacing: 16) {
            StatusCard(
                title: "Devices",
                value: "\(appState.devices.count)",
                icon: "app.connected.to.app.below.fill",
                color: .blue
            )

            StatusCard(
                title: "Active",
                value: "\(appState.activeDeviceCount)",
                icon: "power",
                color: .green
            )

            StatusCard(
                title: "Reachable",
                value: "\(appState.reachableDeviceCount)",
                icon: "wifi",
                color: .orange
            )
        }
    }
}

struct StatusCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.title)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
    }
}

// MARK: - Device Grid Section

struct DeviceGridSection: View {
    @Environment(AppState.self) private var appState
    @Environment(\.openWindow) private var openWindow

    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Devices")
                .font(.title2)
                .fontWeight(.semibold)

            if appState.devices.isEmpty {
                ContentUnavailableView(
                    "No Devices",
                    systemImage: "app.connected.to.app.below.fill",
                    description: Text("Tap the refresh button to discover devices")
                )
                .frame(height: 300)
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(appState.devicesList, id: \.id) { device in
                        DeviceCard(device: device)
                            .onTapGesture {
                                appState.selectedDeviceID = device.id
                                openWindow(id: "device-detail", value: device.id)
                            }
                    }
                }
            }
        }
    }
}

// MARK: - Device Card

struct DeviceCard: View {
    @Environment(AppState.self) private var appState
    let device: SmartDevice

    @State private var deviceManager: DeviceManager?

    var body: some View {
        VStack(spacing: 12) {
            // Icon
            Image(systemName: device.deviceType.icon)
                .font(.largeTitle)
                .foregroundStyle(iconColor)

            // Name
            Text(device.name)
                .font(.headline)
                .lineLimit(2)
                .multilineTextAlignment(.center)

            // State
            if let state = device.currentState {
                if device.deviceType.supportsOnOff {
                    Toggle("", isOn: Binding(
                        get: { state.isOn ?? false },
                        set: { _ in
                            Task {
                                try? await toggleDevice()
                            }
                        }
                    ))
                    .labelsHidden()
                } else if device.deviceType == .thermostat {
                    if let temp = state.targetTemperature {
                        Text("\(Int(temp))°F")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
            }

            // Status indicator
            if !device.isReachable {
                Label("Unreachable", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .padding()
        .frame(width: 150, height: 150)
        .background(.regularMaterial)
        .cornerRadius(16)
        .opacity(device.isReachable ? 1.0 : 0.6)
        .task {
            let service = HomeKitService()
            deviceManager = DeviceManager(appState: appState, homeKitService: service)
        }
    }

    private var iconColor: Color {
        if !device.isReachable {
            return .gray
        }

        if device.currentState?.isOn == true {
            return .yellow
        }

        return .primary
    }

    private func toggleDevice() async throws {
        guard let manager = deviceManager else { return }
        try await manager.toggleDevice(device)
    }
}

// MARK: - Error Banner

struct ErrorBanner: View {
    let error: LBSError
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)

            VStack(alignment: .leading, spacing: 4) {
                Text(error.localizedDescription)
                    .font(.headline)

                if let suggestion = error.recoverySuggestion {
                    Text(suggestion)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button("Dismiss", action: onDismiss)
                .buttonStyle(.bordered)
        }
        .padding()
        .background(.red.opacity(0.1))
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}

// MARK: - Preview

#Preview {
    DashboardView()
        .environment(AppState.preview)
}
