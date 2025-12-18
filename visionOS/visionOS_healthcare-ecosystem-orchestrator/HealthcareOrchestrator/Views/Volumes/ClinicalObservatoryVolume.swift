import SwiftUI
import RealityKit
import SwiftData

struct ClinicalObservatoryVolume: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var patients: [Patient]

    @State private var selectedDepartment: String = "All"

    var body: some View {
        RealityView { content in
            // Create 3D multi-patient monitoring scene
            let observatoryEntity = await createClinicalObservatory()
            content.add(observatoryEntity)
        } update: { content in
            // Real-time updates
        }
        .overlay(alignment: .topLeading) {
            controlPanel
        }
        .overlay(alignment: .bottomTrailing) {
            legendPanel
        }
    }

    // MARK: - Control Panel
    private var controlPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Clinical Observatory")
                .font(.title2)
                .bold()

            Text("\(filteredPatients.count) patients")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Divider()

            // Department Filter
            Menu {
                Button("All Departments") {
                    selectedDepartment = "All"
                }
                ForEach(departments, id: \.self) { dept in
                    Button(dept) {
                        selectedDepartment = dept
                    }
                }
            } label: {
                Label(selectedDepartment, systemImage: "line.3.horizontal.decrease.circle")
            }
            .buttonStyle(.bordered)

            // Quick Stats
            VStack(alignment: .leading, spacing: 8) {
                statRow(label: "Critical", value: criticalCount, color: .red)
                statRow(label: "Warning", value: warningCount, color: .yellow)
                statRow(label: "Normal", value: normalCount, color: .green)
            }
            .font(.caption)
        }
        .padding()
        .frame(width: 250)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
    }

    // MARK: - Legend Panel
    private var legendPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Status Legend")
                .font(.caption.bold())

            HStack(spacing: 4) {
                Circle().fill(.red).frame(width: 12, height: 12)
                Text("Critical")
                    .font(.caption)
            }

            HStack(spacing: 4) {
                Circle().fill(.yellow).frame(width: 12, height: 12)
                Text("Warning")
                    .font(.caption)
            }

            HStack(spacing: 4) {
                Circle().fill(.green).frame(width: 12, height: 12)
                Text("Normal")
                    .font(.caption)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding()
    }

    // MARK: - Helper Views
    private func statRow(label: String, value: Int, color: Color) -> some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
            Spacer()
            Text("\(value)")
                .bold()
        }
    }

    // MARK: - Computed Properties
    private var filteredPatients: [Patient] {
        if selectedDepartment == "All" {
            return patients
        }
        return patients.filter { $0.currentLocation?.contains(selectedDepartment) == true }
    }

    private var departments: [String] {
        Array(Set(patients.compactMap { $0.currentLocation })).sorted()
    }

    private var criticalCount: Int {
        filteredPatients.filter { patient in
            patient.latestVitalSign?.alertLevel == .critical ||
            patient.latestVitalSign?.alertLevel == .emergency
        }.count
    }

    private var warningCount: Int {
        filteredPatients.filter { $0.latestVitalSign?.alertLevel == .warning }.count
    }

    private var normalCount: Int {
        filteredPatients.filter { $0.latestVitalSign?.alertLevel == .normal }.count
    }

    // MARK: - 3D Scene Creation
    private func createClinicalObservatory() async -> Entity {
        let rootEntity = Entity()

        // Create patient cards in 3D space
        let spacing: Float = 0.3
        let columns = 5

        for (index, patient) in filteredPatients.prefix(20).enumerated() {
            let row = Float(index / columns)
            let col = Float(index % columns)

            let cardEntity = await createPatientCard(patient: patient)
            cardEntity.position = [
                col * spacing - Float(columns / 2) * spacing,
                row * spacing,
                0
            ]

            rootEntity.addChild(cardEntity)
        }

        // Add lighting
        let light = Entity()
        light.components.set(DirectionalLightComponent())
        rootEntity.addChild(light)

        return rootEntity
    }

    private func createPatientCard(patient: Patient) async -> Entity {
        let cardEntity = Entity()

        // Determine color based on patient status
        let cardColor: UIColor = {
            guard let vitals = patient.latestVitalSign else { return .blue }
            switch vitals.alertLevel {
            case .emergency, .critical: return .red
            case .warning: return .yellow
            case .normal: return .green
            }
        }()

        // Create card mesh
        let boxMesh = MeshResource.generateBox(size: [0.25, 0.15, 0.02])
        var material = SimpleMaterial()
        material.color = .init(tint: cardColor.withAlphaComponent(0.8))
        material.metallic = 0.5
        material.roughness = 0.3

        cardEntity.components.set(ModelComponent(mesh: boxMesh, materials: [material]))

        // Add interaction
        cardEntity.components.set(InputTargetComponent())
        cardEntity.components.set(CollisionComponent(shapes: [.generateBox(size: [0.25, 0.15, 0.02])]))

        // Add pulsing animation for critical patients
        if patient.latestVitalSign?.alertLevel == .critical || patient.latestVitalSign?.alertLevel == .emergency {
            let pulseAnimation = FromToByAnimation<Transform>(
                from: .init(scale: [1, 1, 1]),
                to: .init(scale: [1.1, 1.1, 1.1]),
                duration: 1,
                timing: .easeInOut,
                isAdditive: false,
                bindTarget: .transform,
                repeatMode: .autoReverse
            )

            if let animationResource = try? AnimationResource.generate(with: pulseAnimation) {
                cardEntity.playAnimation(animationResource)
            }
        }

        return cardEntity
    }
}

#Preview {
    ClinicalObservatoryVolume()
        .modelContainer(for: Patient.self, inMemory: true)
}
