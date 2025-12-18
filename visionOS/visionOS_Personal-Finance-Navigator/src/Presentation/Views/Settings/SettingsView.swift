// SettingsView.swift
// Personal Finance Navigator
// Main settings screen

import SwiftUI

struct SettingsView: View {
    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss

    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Security & Privacy
                Section {
                    NavigationLink {
                        SecuritySettingsView()
                    } label: {
                        Label {
                            Text("Security & Privacy")
                        } icon: {
                            Image(systemName: "lock.shield.fill")
                                .foregroundStyle(.blue)
                        }
                    }
                } header: {
                    Text("Privacy")
                }

                // MARK: - Preferences
                Section {
                    NavigationLink {
                        GeneralSettingsView()
                    } label: {
                        Label {
                            Text("General")
                        } icon: {
                            Image(systemName: "gear")
                                .foregroundStyle(.gray)
                        }
                    }

                    NavigationLink {
                        NotificationSettingsView()
                    } label: {
                        Label {
                            Text("Notifications")
                        } icon: {
                            Image(systemName: "bell.fill")
                                .foregroundStyle(.orange)
                        }
                    }

                    NavigationLink {
                        DisplaySettingsView()
                    } label: {
                        Label {
                            Text("Display")
                        } icon: {
                            Image(systemName: "paintbrush.fill")
                                .foregroundStyle(.purple)
                        }
                    }
                } header: {
                    Text("Preferences")
                }

                // MARK: - Data Management
                Section {
                    NavigationLink {
                        DataManagementView()
                    } label: {
                        Label {
                            Text("Data Management")
                        } icon: {
                            Image(systemName: "externaldrive.fill")
                                .foregroundStyle(.green)
                        }
                    }

                    NavigationLink {
                        ExportDataView()
                    } label: {
                        Label {
                            Text("Export Data")
                        } icon: {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundStyle(.blue)
                        }
                    }
                } header: {
                    Text("Data")
                }

                // MARK: - Support
                Section {
                    Link(destination: URL(string: "https://example.com/help")!) {
                        Label {
                            Text("Help & Support")
                        } icon: {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundStyle(.cyan)
                        }
                    }

                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        Label {
                            Text("Privacy Policy")
                        } icon: {
                            Image(systemName: "hand.raised.fill")
                                .foregroundStyle(.indigo)
                        }
                    }

                    Link(destination: URL(string: "https://example.com/terms")!) {
                        Label {
                            Text("Terms of Service")
                        } icon: {
                            Image(systemName: "doc.text.fill")
                                .foregroundStyle(.brown)
                        }
                    }
                } header: {
                    Text("Support & Legal")
                }

                // MARK: - App Info
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0 (MVP)")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Build")
                        Spacer()
                        Text("2025.01")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

// MARK: - Placeholder Views (to be implemented)

struct GeneralSettingsView: View {
    var body: some View {
        Form {
            Section {
                Text("Currency, date formats, fiscal year settings will go here")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("General")
    }
}

struct NotificationSettingsView: View {
    @State private var budgetAlerts = true
    @State private var billReminders = true
    @State private var transactionAlerts = true

    var body: some View {
        Form {
            Section {
                Toggle("Budget Alerts", isOn: $budgetAlerts)
                Toggle("Bill Reminders", isOn: $billReminders)
                Toggle("Transaction Alerts", isOn: $transactionAlerts)
            } header: {
                Text("Notification Preferences")
            } footer: {
                Text("Receive notifications about budget limits, upcoming bills, and unusual transactions.")
            }
        }
        .navigationTitle("Notifications")
    }
}

struct DisplaySettingsView: View {
    @State private var selectedTheme = "System"
    private let themes = ["System", "Light", "Dark"]

    var body: some View {
        Form {
            Section {
                Picker("Theme", selection: $selectedTheme) {
                    ForEach(themes, id: \.self) { theme in
                        Text(theme)
                    }
                }
            } header: {
                Text("Appearance")
            }

            Section {
                Text("Chart styles, color schemes, and 3D visualization settings will go here")
                    .foregroundStyle(.secondary)
            } header: {
                Text("Visualization")
            }
        }
        .navigationTitle("Display")
    }
}

struct DataManagementView: View {
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Local Storage Used")
                    Spacer()
                    Text("12.4 MB")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("iCloud Storage Used")
                    Spacer()
                    Text("8.7 MB")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Storage")
            }

            Section {
                Button("Clear Cache") {
                    // TODO: Implement
                }

                Button("Reset All Settings") {
                    // TODO: Implement
                }
                .foregroundStyle(.orange)
            } header: {
                Text("Maintenance")
            }

            Section {
                Button("Delete All Data") {
                    // TODO: Implement
                }
                .foregroundStyle(.red)
            } header: {
                Text("Danger Zone")
            } footer: {
                Text("This action cannot be undone. All your financial data will be permanently deleted.")
            }
        }
        .navigationTitle("Data Management")
    }
}

struct ExportDataView: View {
    var body: some View {
        Form {
            Section {
                Button {
                    // TODO: Implement CSV export
                } label: {
                    Label("Export as CSV", systemImage: "doc.text")
                }

                Button {
                    // TODO: Implement JSON export
                } label: {
                    Label("Export as JSON", systemImage: "doc.badge.gearshape")
                }

                Button {
                    // TODO: Implement PDF report
                } label: {
                    Label("Generate PDF Report", systemImage: "doc.richtext")
                }
            } header: {
                Text("Export Options")
            } footer: {
                Text("Export your financial data for backup or analysis in other applications.")
            }
        }
        .navigationTitle("Export Data")
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
        .environment(SessionManager())
}
