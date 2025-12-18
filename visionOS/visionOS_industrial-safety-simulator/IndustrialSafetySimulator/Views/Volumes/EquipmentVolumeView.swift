import SwiftUI
import RealityKit

struct EquipmentVolumeView: View {
    @State private var rotationAngle: Angle = .zero
    @State private var selectedEquipment: EquipmentType = .fireExtinguisher
    @State private var checklistItems: [ChecklistItem] = []

    var body: some View {
        ZStack {
            RealityView { content in
                await setupEquipmentView(content: content)
            } update: { content in
                updateEquipment(content: content)
            }
            .gesture(
                RotateGesture3D()
                    .onChanged { value in
                        rotationAngle = value.rotation.angle
                    }
            )

            VStack {
                Spacer()

                checklistOverlay
                    .padding(24)
            }
        }
    }

    private var checklistOverlay: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Equipment Inspection")
                .font(.headline)
                .fontWeight(.semibold)

            ForEach(checklistItems) { item in
                HStack {
                    Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(item.isChecked ? .green : .secondary)

                    Text(item.title)
                        .font(.callout)

                    Spacer()
                }
                .onTapGesture {
                    toggleChecklistItem(item)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    @MainActor
    private func setupEquipmentView(content: RealityViewContent) async {
        // Load equipment model
        let equipmentEntity = await loadEquipment(selectedEquipment)
        content.add(equipmentEntity)

        // Initialize checklist
        checklistItems = selectedEquipment.checklistItems
    }

    private func updateEquipment(content: RealityViewContent) {
        // Update equipment rotation
    }

    @MainActor
    private func loadEquipment(_ type: EquipmentType) async -> Entity {
        // In production, load from Reality Composer Pro
        // For now, create placeholder
        let mesh = MeshResource.generateBox(size: [0.2, 0.5, 0.1])
        let material = SimpleMaterial(color: .red, isMetallic: false)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.position = SIMD3<Float>(0, 0, 0)

        return entity
    }

    private func toggleChecklistItem(_ item: ChecklistItem) {
        if let index = checklistItems.firstIndex(where: { $0.id == item.id }) {
            checklistItems[index].isChecked.toggle()
        }
    }
}

enum EquipmentType: String, CaseIterable {
    case fireExtinguisher = "Fire Extinguisher"
    case hardHat = "Hard Hat"
    case safetyHarness = "Safety Harness"
    case lockoutDevice = "Lockout Device"

    var checklistItems: [ChecklistItem] {
        switch self {
        case .fireExtinguisher:
            return [
                ChecklistItem(title: "Check pressure gauge"),
                ChecklistItem(title: "Inspect safety pin"),
                ChecklistItem(title: "Verify expiration date"),
                ChecklistItem(title: "Check for damage")
            ]
        case .hardHat:
            return [
                ChecklistItem(title: "Check for cracks"),
                ChecklistItem(title: "Inspect suspension system"),
                ChecklistItem(title: "Verify date stamp"),
                ChecklistItem(title: "Check chin strap")
            ]
        case .safetyHarness:
            return [
                ChecklistItem(title: "Inspect webbing for cuts"),
                ChecklistItem(title: "Check D-ring"),
                ChecklistItem(title: "Verify buckles"),
                ChecklistItem(title: "Confirm date stamp")
            ]
        case .lockoutDevice:
            return [
                ChecklistItem(title: "Test lock mechanism"),
                ChecklistItem(title: "Verify tag is attached"),
                ChecklistItem(title: "Check for damage"),
                ChecklistItem(title: "Confirm unique key")
            ]
        }
    }
}

struct ChecklistItem: Identifiable {
    let id = UUID()
    let title: String
    var isChecked: Bool = false
}

#Preview(windowStyle: .volumetric) {
    EquipmentVolumeView()
}
