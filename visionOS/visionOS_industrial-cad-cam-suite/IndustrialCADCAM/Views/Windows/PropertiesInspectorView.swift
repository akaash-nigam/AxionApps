//
//  PropertiesInspectorView.swift
//  IndustrialCADCAM
//
//  Properties inspector panel for selected objects
//

import SwiftUI
import SwiftData

struct PropertiesInspectorView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Text("Properties")
                        .font(.title2)
                        .fontWeight(.bold)

                    Spacer()

                    Button(action: {}) {
                        Image(systemName: "ellipsis.circle")
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                .padding(.top)

                // Content based on selection
                if appState.selectedParts.isEmpty {
                    noSelectionView
                } else if appState.selectedParts.count == 1 {
                    if let partId = appState.selectedParts.first {
                        singlePartProperties(partId: partId)
                    }
                } else {
                    multipleSelectionView
                }

                Spacer()
            }
        }
        .frame(minWidth: 350)
    }

    // MARK: - No Selection View

    private var noSelectionView: some View {
        VStack(spacing: 16) {
            Image(systemName: "hand.tap")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)

            Text("No Selection")
                .font(.title3)
                .foregroundStyle(.secondary)

            Text("Select a part or feature to view its properties")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .padding(.top, 80)
    }

    // MARK: - Multiple Selection View

    private var multipleSelectionView: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.stack.3d.up")
                .font(.system(size: 48))
                .foregroundStyle(.blue)

            Text("\(appState.selectedParts.count) Items Selected")
                .font(.title3)

            // Common properties for multiple selections
            GroupBox("Common Actions") {
                VStack(spacing: 8) {
                    Button(action: {}) {
                        Label("Group Selection", systemImage: "folder")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)

                    Button(action: {}) {
                        Label("Create Assembly", systemImage: "square.stack.3d.up")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)

                    Divider()

                    Button(action: {}) {
                        Label("Delete All", systemImage: "trash")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.red)
                }
                .padding(8)
            }
            .padding(.horizontal)
        }
        .padding()
    }

    // MARK: - Single Part Properties

    private func singlePartProperties(partId: UUID) -> some View {
        // Note: In a real implementation, we'd fetch the Part from the model context
        // For now, we'll create a placeholder view
        VStack(alignment: .leading, spacing: 20) {
            // Part Header
            HStack {
                Image(systemName: "cube.fill")
                    .font(.title)
                    .foregroundStyle(.blue)

                VStack(alignment: .leading) {
                    Text("Bracket Assembly")
                        .font(.headline)
                    Text("Part ID: \(partId.uuidString.prefix(8))...")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)

            // Dimensions Section
            GroupBox("Dimensions") {
                VStack(spacing: 12) {
                    DimensionRow(label: "Length", value: 125.5, unit: "mm")
                    DimensionRow(label: "Width", value: 80.3, unit: "mm")
                    DimensionRow(label: "Height", value: 45.0, unit: "mm")
                }
                .padding(8)
            }
            .padding(.horizontal)

            // Material Section
            GroupBox("Material") {
                VStack(spacing: 12) {
                    Picker("Material", selection: .constant("Steel 1045")) {
                        Text("Steel 1045").tag("Steel 1045")
                        Text("Aluminum 6061-T6").tag("Aluminum 6061-T6")
                        Text("Titanium Ti-6Al-4V").tag("Titanium Ti-6Al-4V")
                        Text("ABS Plastic").tag("ABS Plastic")
                    }

                    Divider()

                    InfoRow(label: "Density", value: "7.85 g/cm³")
                    InfoRow(label: "Yield Strength", value: "310 MPa")
                }
                .padding(8)
            }
            .padding(.horizontal)

            // Mass Properties Section
            GroupBox("Mass Properties") {
                VStack(spacing: 12) {
                    InfoRow(label: "Mass", value: "245.8 g")
                    InfoRow(label: "Volume", value: "91.0 cm³")
                    InfoRow(label: "Surface Area", value: "312.5 cm²")

                    Button(action: {}) {
                        Label("Show Center of Gravity", systemImage: "scope")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                .padding(8)
            }
            .padding(.horizontal)

            // Manufacturing Section
            GroupBox("Manufacturing") {
                VStack(spacing: 12) {
                    Picker("Tolerance", selection: .constant("±0.1mm")) {
                        Text("±0.05 mm").tag("±0.05mm")
                        Text("±0.1 mm").tag("±0.1mm")
                        Text("±0.2 mm").tag("±0.2mm")
                        Text("±0.5 mm").tag("±0.5mm")
                    }

                    Picker("Surface Finish", selection: .constant("Ra 3.2")) {
                        Text("Ra 0.8 μm").tag("Ra 0.8")
                        Text("Ra 1.6 μm").tag("Ra 1.6")
                        Text("Ra 3.2 μm").tag("Ra 3.2")
                        Text("Ra 6.3 μm").tag("Ra 6.3")
                    }

                    Picker("Process", selection: .constant("CNC Milling")) {
                        Text("CNC Milling").tag("CNC Milling")
                        Text("CNC Turning").tag("CNC Turning")
                        Text("3D Printing").tag("3D Printing")
                        Text("Sheet Metal").tag("Sheet Metal")
                    }
                }
                .padding(8)
            }
            .padding(.horizontal)

            // Feature Tree Section
            GroupBox("Feature Tree") {
                VStack(alignment: .leading, spacing: 8) {
                    FeatureTreeItem(icon: "pencil.line", name: "Base Sketch", isActive: true)
                    FeatureTreeItem(icon: "arrow.up", name: "Extrude 50mm", isActive: true)
                    FeatureTreeItem(icon: "circle.dotted", name: "Fillet R5", isActive: true)
                    FeatureTreeItem(icon: "circle", name: "Hole Ø8 (4x)", isActive: true)
                    FeatureTreeItem(icon: "square.slash", name: "Chamfer 1×45°", isActive: true)
                }
                .padding(8)
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Dimension Row

struct DimensionRow: View {
    let label: String
    let value: Double
    let unit: String

    @State private var isEditing = false

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)

            Spacer()

            if isEditing {
                TextField("Value", value: .constant(value), format: .number)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
                    .multilineTextAlignment(.trailing)
            } else {
                Text(String(format: "%.1f", value))
                    .fontWeight(.medium)
                    .fontDesign(.monospaced)
            }

            Text(unit)
                .font(.caption)
                .foregroundStyle(.tertiary)
                .frame(width: 30, alignment: .leading)

            Button(action: { isEditing.toggle() }) {
                Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil.circle")
            }
            .buttonStyle(.plain)
            .font(.caption)
        }
    }
}

// MARK: - Feature Tree Item

struct FeatureTreeItem: View {
    let icon: String
    let name: String
    let isActive: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(isActive ? .blue : .secondary)
                .frame(width: 20)

            Text(name)
                .font(.caption)
                .foregroundStyle(isActive ? .primary : .secondary)

            Spacer()

            if isActive {
                Image(systemName: "eye.fill")
                    .font(.caption2)
                    .foregroundStyle(.blue)
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(isActive ? Color.blue.opacity(0.1) : Color.clear)
        .cornerRadius(6)
    }
}

#Preview {
    PropertiesInspectorView()
        .frame(width: 400, height: 800)
}
