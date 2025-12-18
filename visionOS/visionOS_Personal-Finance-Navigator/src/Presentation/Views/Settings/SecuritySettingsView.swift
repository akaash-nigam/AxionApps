// SecuritySettingsView.swift
// Personal Finance Navigator
// Security and privacy settings

import SwiftUI

struct SecuritySettingsView: View {
    // MARK: - Environment
    @Environment(SessionManager.self) private var sessionManager

    // MARK: - State
    @State private var biometricAvailable = false
    @State private var biometricType: String?
    @State private var showLockTimeoutSheet = false

    // MARK: - Body
    var body: some View {
        @Bindable var bindableSession = sessionManager

        Form {
            // MARK: - Biometric Authentication
            Section {
                Toggle(isOn: $bindableSession.requiresBiometric) {
                    HStack(spacing: 12) {
                        Image(systemName: "faceid")
                            .font(.title3)
                            .foregroundStyle(.blue)
                            .frame(width: 30)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Require \(biometricType ?? "Biometric") Authentication")
                                .font(.body)

                            Text("Lock app when going to background")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onChange(of: bindableSession.requiresBiometric) { _, _ in
                    sessionManager.saveSettings()
                }
                .disabled(!biometricAvailable)

                if !biometricAvailable {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text("Biometric authentication is not available on this device")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text("Authentication")
            } footer: {
                Text("When enabled, you'll need to authenticate with \(biometricType?.lowercased() ?? "biometrics") each time you open the app.")
            }

            // MARK: - Auto-Lock
            Section {
                Toggle(isOn: $bindableSession.autoLockEnabled) {
                    HStack(spacing: 12) {
                        Image(systemName: "lock.rotation")
                            .font(.title3)
                            .foregroundStyle(.blue)
                            .frame(width: 30)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Auto-Lock")
                                .font(.body)

                            Text("Lock after inactivity or background")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onChange(of: bindableSession.autoLockEnabled) { _, _ in
                    sessionManager.saveSettings()
                }

                if bindableSession.autoLockEnabled {
                    Button {
                        showLockTimeoutSheet = true
                    } label: {
                        HStack {
                            Text("Lock After")
                                .foregroundStyle(.primary)

                            Spacer()

                            Text(formatTimeout(bindableSession.autoLockTimeout))
                                .foregroundStyle(.secondary)

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
            } header: {
                Text("Security")
            } footer: {
                if bindableSession.autoLockEnabled {
                    Text("The app will automatically lock after \(formatTimeout(bindableSession.autoLockTimeout)) of inactivity or when you switch to another app.")
                } else {
                    Text("Auto-lock is disabled. The app will only lock when you manually close it.")
                }
            }

            // MARK: - Session Info
            Section {
                HStack {
                    Text("Session Status")
                    Spacer()
                    Text(sessionManager.isAuthenticated ? "Unlocked" : "Locked")
                        .foregroundStyle(sessionManager.isAuthenticated ? .green : .red)
                }

                Button {
                    sessionManager.lock()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "lock.fill")
                            .font(.title3)
                            .foregroundStyle(.red)
                            .frame(width: 30)

                        Text("Lock Now")
                            .foregroundStyle(.red)
                    }
                }
            } header: {
                Text("Current Session")
            }

            // MARK: - Privacy Information
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Label {
                        Text("Local Storage Only")
                    } icon: {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundStyle(.green)
                    }

                    Label {
                        Text("AES-256-GCM Encryption")
                    } icon: {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundStyle(.green)
                    }

                    Label {
                        Text("Keychain Protected")
                    } icon: {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundStyle(.green)
                    }

                    Label {
                        Text("No Third-Party Analytics")
                    } icon: {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundStyle(.green)
                    }
                }
                .font(.caption)
            } header: {
                Text("Privacy & Security Features")
            } footer: {
                Text("Your financial data is encrypted and stored locally on your device. We never share your data with third parties.")
            }
        }
        .navigationTitle("Security & Privacy")
        .sheet(isPresented: $showLockTimeoutSheet) {
            LockTimeoutPickerView(selectedTimeout: $bindableSession.autoLockTimeout) {
                sessionManager.saveSettings()
                showLockTimeoutSheet = false
            }
        }
        .task {
            let result = await sessionManager.checkBiometricAvailability()
            biometricAvailable = result.available
            biometricType = result.biometricType
        }
    }

    // MARK: - Helper Methods
    private func formatTimeout(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        if minutes == 0 {
            return "Immediately"
        } else if minutes == 1 {
            return "1 minute"
        } else if minutes < 60 {
            return "\(minutes) minutes"
        } else {
            let hours = minutes / 60
            return hours == 1 ? "1 hour" : "\(hours) hours"
        }
    }
}

// MARK: - Lock Timeout Picker
struct LockTimeoutPickerView: View {
    @Binding var selectedTimeout: TimeInterval
    let onSave: () -> Void

    private let timeoutOptions: [(String, TimeInterval)] = [
        ("Immediately", 0),
        ("30 seconds", 30),
        ("1 minute", 60),
        ("2 minutes", 120),
        ("5 minutes", 300),
        ("10 minutes", 600),
        ("15 minutes", 900),
        ("30 minutes", 1800),
        ("1 hour", 3600)
    ]

    var body: some View {
        NavigationStack {
            List {
                ForEach(timeoutOptions, id: \.1) { option in
                    Button {
                        selectedTimeout = option.1
                        onSave()
                    } label: {
                        HStack {
                            Text(option.0)
                                .foregroundStyle(.primary)

                            Spacer()

                            if selectedTimeout == option.1 {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Lock After")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        SecuritySettingsView()
            .environment(SessionManager())
    }
}
