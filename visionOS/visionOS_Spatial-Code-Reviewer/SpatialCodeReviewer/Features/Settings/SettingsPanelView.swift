//
//  SettingsPanelView.swift
//  SpatialCodeReviewer
//
//  Created by Claude on 2025-11-25.
//  Story 0.9: Settings & Preferences - UI Component
//

import SwiftUI

/// Floating settings panel for immersive space
struct SettingsPanelView: View {
    @ObservedObject var settings = SettingsManager.shared
    @Environment(\.dismissWindow) private var dismissWindow
    @State private var showExportAlert = false
    @State private var showImportSheet = false
    @State private var exportedJSON: String = ""

    var body: some View {
        NavigationStack {
            Form {
                // Theme Section
                Section {
                    Picker("Theme", selection: $settings.selectedTheme) {
                        ForEach(CodeTheme.allThemes, id: \.name) { theme in
                            Text(theme.name).tag(theme.name)
                        }
                    }
                    .pickerStyle(.menu)
                } header: {
                    Label("Appearance", systemImage: "paintbrush.fill")
                }

                // Display Section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Font Size: \(Int(settings.fontSize))pt")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Slider(value: $settings.fontSize, in: 10...20, step: 1) {
                            Text("Font Size")
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Visible Lines: \(settings.visibleLines)")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Slider(value: Binding(
                            get: { Double(settings.visibleLines) },
                            set: { settings.visibleLines = Int($0) }
                        ), in: 20...60, step: 5) {
                            Text("Visible Lines")
                        }
                    }

                    Toggle("Show Line Numbers", isOn: $settings.showLineNumbers)

                } header: {
                    Label("Display", systemImage: "textformat.size")
                }

                // Layout Section
                Section {
                    Picker("Default Layout", selection: $settings.defaultLayout) {
                        Text("Hemisphere").tag("hemisphere")
                        Text("Focus").tag("focus")
                        Text("Grid").tag("grid")
                        Text("Nested").tag("nested")
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Label("Layout", systemImage: "square.grid.3x3")
                }

                // Performance Section
                Section {
                    Toggle("Entity Pooling", isOn: $settings.enableEntityPooling)
                    Toggle("Level of Detail (LOD)", isOn: $settings.enableLOD)

                    Picker("Texture Quality", selection: $settings.textureQuality) {
                        ForEach(SettingsManager.TextureQuality.allCases, id: \.self) { quality in
                            Text(quality.rawValue).tag(quality)
                        }
                    }
                    .pickerStyle(.menu)

                } header: {
                    Label("Performance", systemImage: "gauge.with.dots.needle.50percent")
                } footer: {
                    Text("Entity pooling reuses 3D objects. LOD reduces detail at distance. Higher texture quality uses more memory.")
                        .font(.caption)
                }

                // Import/Export Section
                Section {
                    Button {
                        exportSettings()
                    } label: {
                        Label("Export Settings", systemImage: "square.and.arrow.up")
                    }

                    Button {
                        showImportSheet = true
                    } label: {
                        Label("Import Settings", systemImage: "square.and.arrow.down")
                    }

                    Button(role: .destructive) {
                        settings.resetToDefaults()
                    } label: {
                        Label("Reset to Defaults", systemImage: "arrow.counterclockwise")
                    }

                } header: {
                    Label("Preferences", systemImage: "gearshape.2")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismissWindow()
                    }
                }
            }
            .alert("Settings Exported", isPresented: $showExportAlert) {
                Button("Copy to Clipboard") {
                    #if os(iOS) || os(visionOS)
                    UIPasteboard.general.string = exportedJSON
                    #else
                    NSPasteboard.general.setString(exportedJSON, forType: .string)
                    #endif
                }
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your settings have been exported as JSON. You can copy them to the clipboard or save to a file.")
            }
            .sheet(isPresented: $showImportSheet) {
                ImportSettingsView()
            }
        }
        .frame(width: 450, height: 600)
    }

    private func exportSettings() {
        if let json = settings.exportSettings() {
            exportedJSON = json
            showExportAlert = true
            print("📤 Settings exported:\n\(json)")
        }
    }
}

// MARK: - Import Settings View

struct ImportSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var settings = SettingsManager.shared
    @State private var jsonInput: String = ""
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Paste your exported settings JSON below:")
                    .font(.headline)

                TextEditor(text: $jsonInput)
                    .font(.system(.body, design: .monospaced))
                    .frame(minHeight: 300)
                    .border(Color.secondary.opacity(0.3), width: 1)
                    .padding()

                HStack {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                    .buttonStyle(.bordered)

                    Spacer()

                    Button("Import") {
                        importSettings()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(jsonInput.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Import Settings")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Import Failed", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
        .frame(width: 500, height: 500)
    }

    private func importSettings() {
        if settings.importSettings(from: jsonInput) {
            print("✅ Settings imported successfully")
            dismiss()
        } else {
            errorMessage = "Invalid JSON format. Please check your input and try again."
            showError = true
        }
    }
}

// MARK: - Settings Button Overlay

/// Floating settings button for immersive space
struct SettingsButtonOverlay: View {
    @Binding var showSettings: Bool

    var body: some View {
        VStack {
            HStack {
                Spacer()

                Button {
                    showSettings.toggle()
                } label: {
                    Label("Settings", systemImage: "gearshape.fill")
                        .font(.title2)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .buttonStyle(.borderless)
                .padding()
            }

            Spacer()
        }
    }
}

// MARK: - Preview

#Preview("Settings Panel") {
    SettingsPanelView()
}

#Preview("Import View") {
    ImportSettingsView()
}
