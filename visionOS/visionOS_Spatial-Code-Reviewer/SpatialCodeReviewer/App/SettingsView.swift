//
//  SettingsView.swift
//  SpatialCodeReviewer
//
//  Created by Claude on 2025-11-24.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("theme") private var theme = "auto"
    @AppStorage("fontSize") private var fontSize = 16.0
    @AppStorage("enableTelemetry") private var enableTelemetry = true
    @AppStorage("maxConcurrentWindows") private var maxConcurrentWindows = 20.0

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Appearance
                Section("Appearance") {
                    Picker("Theme", selection: $theme) {
                        Text("Auto").tag("auto")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }

                    VStack(alignment: .leading) {
                        Text("Font Size")
                        Slider(value: $fontSize, in: 12...20, step: 1) {
                            Text("Font Size")
                        } minimumValueLabel: {
                            Text("A").font(.caption)
                        } maximumValueLabel: {
                            Text("A").font(.title3)
                        }
                        Text("\(Int(fontSize)) pt")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // MARK: - Performance
                Section("Performance") {
                    VStack(alignment: .leading) {
                        Text("Max Concurrent Windows")
                        Slider(value: $maxConcurrentWindows, in: 10...50, step: 5) {
                            Text("Max Windows")
                        }
                        Text("\(Int(maxConcurrentWindows)) windows")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Toggle("Enable Caching", isOn: .constant(true))
                        .disabled(true)

                    Toggle("Reduce Motion", isOn: .constant(false))
                        .disabled(true)
                }

                // MARK: - Privacy
                Section("Privacy") {
                    Toggle("Enable Telemetry", isOn: $enableTelemetry)

                    NavigationLink("Privacy Policy") {
                        PrivacyPolicyView()
                    }

                    NavigationLink("Terms of Service") {
                        TermsOfServiceView()
                    }
                }

                // MARK: - About
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("0.1.0 (MVP)")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundStyle(.secondary)
                    }

                    Link("GitHub Repository", destination: URL(string: "https://github.com/akaash-nigam/visionOS_Spatial-Code-Reviewer")!)

                    Button("Report an Issue") {
                        // TODO: Open GitHub issues
                    }
                }

                // MARK: - Advanced
                Section("Advanced") {
                    Button("Clear Cache") {
                        // TODO: Clear caches
                    }

                    Button("Reset Settings", role: .destructive) {
                        resetSettings()
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func resetSettings() {
        theme = "auto"
        fontSize = 16.0
        enableTelemetry = true
        maxConcurrentWindows = 20.0
    }
}

// MARK: - Privacy Policy View

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Last Updated: 2025-11-24")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Divider()

                Text("""
                    # Data Collection

                    Spatial Code Reviewer collects minimal data to provide the service:

                    ## What We Collect
                    - OAuth tokens (stored securely in Keychain)
                    - Repository metadata (stored locally)
                    - Anonymous usage statistics (if telemetry enabled)

                    ## What We Don't Collect
                    - Your code content (never uploaded to our servers)
                    - Eye tracking data
                    - Voice recordings
                    - Personal information beyond GitHub profile

                    # Data Storage

                    - All repository data stored locally on your device
                    - OAuth tokens stored in Apple Keychain (encrypted)
                    - CloudKit used only for collaboration sessions

                    # Third-Party Services

                    - GitHub API for repository access
                    - Apple CloudKit for collaboration (optional)

                    # Your Rights

                    - Access your data
                    - Delete your data
                    - Opt-out of telemetry
                    - Export your settings

                    For questions: privacy@spatialcodereviewer.com
                    """)
                    .font(.body)
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
    }
}

// MARK: - Terms of Service View

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Terms of Service")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Last Updated: 2025-11-24")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Divider()

                Text("""
                    # Acceptance of Terms

                    By using Spatial Code Reviewer, you agree to these terms.

                    # Use License

                    You are granted a limited license to use this software for code review purposes.

                    # Restrictions

                    - Do not reverse engineer the application
                    - Do not use for malicious purposes
                    - Respect GitHub's terms of service
                    - Do not exceed API rate limits

                    # Disclaimer

                    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

                    # Liability Limitation

                    We are not liable for any damages arising from use of this software.

                    # GitHub Integration

                    You are responsible for maintaining your GitHub account security.

                    # Changes

                    We reserve the right to modify these terms at any time.

                    For questions: legal@spatialcodereviewer.com
                    """)
                    .font(.body)
            }
            .padding()
        }
        .navigationTitle("Terms of Service")
    }
}

#Preview {
    SettingsView()
}
