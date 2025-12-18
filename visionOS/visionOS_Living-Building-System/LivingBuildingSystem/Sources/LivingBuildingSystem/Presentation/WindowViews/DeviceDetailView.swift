import SwiftUI

struct DeviceDetailView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    let device: SmartDevice

    @State private var deviceManager: DeviceManager?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Device Icon
                    DeviceIconSection(device: device)

                    // Device Info
                    DeviceInfoSection(device: device)

                    // Controls
                    if device.isReachable {
                        DeviceControlsSection(device: device, deviceManager: deviceManager)
                    } else {
                        DeviceUnreachableSection()
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle(device.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            let service = HomeKitService()
            deviceManager = DeviceManager(appState: appState, homeKitService: service)
        }
    }
}

// MARK: - Device Icon Section

struct DeviceIconSection: View {
    let device: SmartDevice

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconBackgroundColor)
                    .frame(width: 100, height: 100)

                Image(systemName: device.deviceType.icon)
                    .font(.system(size: 48))
                    .foregroundStyle(iconColor)
            }

            Text(device.deviceType.displayName)
                .font(.headline)
                .foregroundStyle(.secondary)
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

    private var iconBackgroundColor: Color {
        if device.currentState?.isOn == true {
            return .yellow.opacity(0.2)
        }

        return .gray.opacity(0.1)
    }
}

// MARK: - Device Info Section

struct DeviceInfoSection: View {
    let device: SmartDevice

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Information")
                .font(.headline)

            VStack(spacing: 8) {
                InfoRow(label: "Name", value: device.name)

                if let room = device.room {
                    InfoRow(label: "Room", value: room.name)
                }

                if let manufacturer = device.manufacturer {
                    InfoRow(label: "Manufacturer", value: manufacturer)
                }

                if let model = device.model {
                    InfoRow(label: "Model", value: model)
                }

                InfoRow(
                    label: "Status",
                    value: device.isReachable ? "Reachable" : "Unreachable",
                    valueColor: device.isReachable ? .green : .red
                )

                if let lastSeen = device.lastSeen {
                    InfoRow(label: "Last Seen", value: lastSeen.formatted(date: .abbreviated, time: .shortened))
                }
            }
            .padding()
            .background(.regularMaterial)
            .cornerRadius(12)
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    var valueColor: Color = .primary

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .fontWeight(.medium)
                .foregroundStyle(valueColor)
        }
    }
}

// MARK: - Device Controls Section

struct DeviceControlsSection: View {
    let device: SmartDevice
    let deviceManager: DeviceManager?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Controls")
                .font(.headline)

            VStack(spacing: 16) {
                // On/Off control
                if device.deviceType.supportsOnOff {
                    OnOffControl(device: device, deviceManager: deviceManager)
                }

                // Brightness control
                if device.deviceType.supportsBrightness {
                    BrightnessControl(device: device, deviceManager: deviceManager)
                }

                // Temperature control
                if device.deviceType.supportsTemperature {
                    TemperatureControl(device: device, deviceManager: deviceManager)
                }
            }
            .padding()
            .background(.regularMaterial)
            .cornerRadius(12)
        }
    }
}

// MARK: - On/Off Control

struct OnOffControl: View {
    let device: SmartDevice
    let deviceManager: DeviceManager?

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Power")
                    .font(.headline)

                Text(device.currentState?.isOn == true ? "On" : "Off")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { device.currentState?.isOn ?? false },
                set: { _ in
                    Task {
                        try? await deviceManager?.toggleDevice(device)
                    }
                }
            ))
            .labelsHidden()
        }
    }
}

// MARK: - Brightness Control

struct BrightnessControl: View {
    let device: SmartDevice
    let deviceManager: DeviceManager?

    @State private var brightness: Double = 0.5

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Brightness")
                    .font(.headline)

                Spacer()

                Text("\(Int(brightness * 100))%")
                    .font(.headline)
                    .monospacedDigit()
            }

            Slider(value: $brightness, in: 0...1) { editing in
                if !editing {
                    // User finished dragging
                    Task {
                        try? await deviceManager?.setBrightness(device, brightness: brightness)
                    }
                }
            }
        }
        .onAppear {
            brightness = device.currentState?.brightness ?? 0.5
        }
    }
}

// MARK: - Temperature Control

struct TemperatureControl: View {
    let device: SmartDevice
    let deviceManager: DeviceManager?

    @State private var targetTemperature: Double = 70

    var body: some View {
        VStack(spacing: 16) {
            // Current temperature
            if let currentTemp = device.currentState?.temperature {
                VStack(spacing: 4) {
                    Text("Current Temperature")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("\(Int(currentTemp))°F")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .monospacedDigit()
                }
            }

            Divider()

            // Target temperature
            VStack(spacing: 12) {
                Text("Target Temperature")
                    .font(.headline)

                HStack(spacing: 24) {
                    Button {
                        targetTemperature -= 1
                        updateTemperature()
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.largeTitle)
                    }
                    .buttonStyle(.borderless)

                    Text("\(Int(targetTemperature))°F")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .frame(minWidth: 100)

                    Button {
                        targetTemperature += 1
                        updateTemperature()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.largeTitle)
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
        .onAppear {
            targetTemperature = device.currentState?.targetTemperature ?? 70
        }
    }

    private func updateTemperature() {
        Task {
            try? await deviceManager?.setTargetTemperature(device, temperature: targetTemperature)
        }
    }
}

// MARK: - Unreachable Section

struct DeviceUnreachableSection: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundStyle(.red)

            Text("Device Unreachable")
                .font(.headline)

            Text("Make sure the device is powered on and connected to your network")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
    }
}

// MARK: - Preview

#Preview {
    DeviceDetailView(device: SmartDevice.preview)
        .environment(AppState.preview)
}
