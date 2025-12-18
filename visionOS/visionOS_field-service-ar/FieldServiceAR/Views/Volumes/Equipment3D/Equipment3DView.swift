//
//  Equipment3DView.swift
//  FieldServiceAR
//
//  3D equipment preview volume
//

import SwiftUI
import RealityKit

struct Equipment3DView: View {
    let equipmentId: UUID

    @State private var equipment: Equipment?
    @State private var selectedMode: ViewMode = .inspection
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 0) {
            // 3D View
            if isLoading {
                ProgressView("Loading 3D model...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if equipment != nil {
                RealityView { content in
                    await setup3DContent(content: content)
                } update: { content in
                    await update3DContent(content: content, mode: selectedMode)
                }
            } else {
                ContentUnavailableView(
                    "Model Not Available",
                    systemImage: "cube",
                    description: Text("3D model not found for this equipment")
                )
            }

            // Controls ornament
            controlsOrnament
                .frame(height: 60)
                .background(.regularMaterial)
        }
        .task {
            await loadEquipment()
        }
    }

    // MARK: - Controls

    private var controlsOrnament: some View {
        HStack(spacing: 20) {
            ForEach(ViewMode.allCases, id: \.self) { mode in
                Button {
                    selectedMode = mode
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: mode.icon)
                            .font(.title3)
                        Text(mode.rawValue)
                            .font(.caption)
                    }
                    .foregroundStyle(selectedMode == mode ? Color.accentColor : .primary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
    }

    // MARK: - 3D Setup

    private func setup3DContent(content: RealityViewContent) async {
        guard let equipment = equipment else { return }

        // Load 3D model
        // Setup lighting
        // Add to content
    }

    private func update3DContent(content: RealityViewContent, mode: ViewMode) async {
        // Update visualization based on mode
        switch mode {
        case .inspection:
            // Normal view
            break
        case .exploded:
            // Explode components
            break
        case .components:
            // Highlight individual components
            break
        case .measurements:
            // Show dimensional annotations
            break
        }
    }

    private func loadEquipment() async {
        isLoading = true
        defer { isLoading = false }

        let container = DependencyContainer()
        let repository = EquipmentRepository(modelContainer: container.modelContainer)

        do {
            equipment = try await repository.fetchById(equipmentId)
        } catch {
            print("Error loading equipment: \(error)")
        }
    }
}

// View Mode
enum ViewMode: String, CaseIterable {
    case inspection = "Inspect"
    case exploded = "Explode"
    case components = "Parts"
    case measurements = "Measure"

    var icon: String {
        switch self {
        case .inspection: return "rotate.3d"
        case .exploded: return "square.3.layers.3d"
        case .components: return "list.bullet"
        case .measurements: return "ruler"
        }
    }
}

#Preview {
    Equipment3DView(equipmentId: UUID())
}
