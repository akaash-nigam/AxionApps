import SwiftUI
import RealityKit

struct EmergencyResponseSpace: View {
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(NavigationCoordinator.self) private var navigationCoordinator

    @State private var selectedProtocol: EmergencyProtocol?

    var body: some View {
        RealityView { content in
            // Create 360° emergency response environment
            let emergencyEnvironment = await createEmergencyEnvironment()
            content.add(emergencyEnvironment)
        }
        .overlay(alignment: .top) {
            emergencyHeader
        }
        .overlay(alignment: .center) {
            if let protocol = selectedProtocol {
                protocolChecklist(protocol)
            }
        }
        .overlay(alignment: .bottom) {
            actionBar
        }
    }

    // MARK: - Emergency Header
    private var emergencyHeader: some View {
        HStack {
            Image(systemName: "alarm.fill")
                .foregroundStyle(.red)
                .font(.title)

            Text("EMERGENCY MODE")
                .font(.title.bold())
                .foregroundStyle(.red)

            Spacer()

            Button {
                Task {
                    await dismissImmersiveSpace()
                }
            } label: {
                Label("Exit", systemImage: "xmark.circle.fill")
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
    }

    // MARK: - Protocol Checklist
    private func protocolChecklist(_ protocol: EmergencyProtocol) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(protocol.name)
                .font(.title2.bold())

            Text("Critical Actions:")
                .font(.headline)

            ForEach(protocol.steps, id: \.self) { step in
                HStack {
                    Button {
                        // Mark step as complete
                    } label: {
                        Image(systemName: "circle")
                            .font(.title3)
                    }
                    .buttonStyle(.plain)

                    Text(step)
                        .font(.body)
                }
            }

            HStack {
                Button("Complete Protocol") {
                    selectedProtocol = nil
                }
                .buttonStyle(.borderedProminent)

                Button("Cancel") {
                    selectedProtocol = nil
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(24)
        .frame(width: 500)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Action Bar
    private var actionBar: some View {
        HStack(spacing: 20) {
            Button {
                selectedProtocol = .sepsis
            } label: {
                VStack {
                    Image(systemName: "waveform.path.ecg")
                        .font(.title)
                    Text("Sepsis")
                        .font(.caption)
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.large)

            Button {
                selectedProtocol = .cardiac
            } label: {
                VStack {
                    Image(systemName: "heart.fill")
                        .font(.title)
                    Text("Cardiac")
                        .font(.caption)
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.large)

            Button {
                selectedProtocol = .stroke
            } label: {
                VStack {
                    Image(systemName: "brain")
                        .font(.title)
                    Text("Stroke")
                        .font(.caption)
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.large)

            Button {
                selectedProtocol = .trauma
            } label: {
                VStack {
                    Image(systemName: "cross.case.fill")
                        .font(.title)
                    Text("Trauma")
                        .font(.caption)
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
    }

    // MARK: - 3D Environment Creation
    private func createEmergencyEnvironment() async -> Entity {
        let rootEntity = Entity()

        // Create 360° sphere for immersive environment
        let sphereMesh = MeshResource.generateSphere(radius: 5.0)
        var material = SimpleMaterial()
        material.color = .init(tint: .red.withAlphaComponent(0.1))

        let environmentEntity = Entity()
        environmentEntity.components.set(ModelComponent(mesh: sphereMesh, materials: [material]))
        environmentEntity.scale = [-1, 1, 1] // Invert to see inside

        rootEntity.addChild(environmentEntity)

        // Add critical information panels around user
        let panels = await createInformationPanels()
        for panel in panels {
            rootEntity.addChild(panel)
        }

        // Add lighting
        let ambientLight = Entity()
        ambientLight.components.set(AmbientLightComponent(color: .red, intensity: 500))
        rootEntity.addChild(ambientLight)

        return rootEntity
    }

    private func createInformationPanels() async -> [Entity] {
        var panels: [Entity] = []

        // Panel positions in a circle around user (at eye level)
        let radius: Float = 2.0
        let panelCount = 8

        for i in 0..<panelCount {
            let angle = Float(i) * (2 * .pi / Float(panelCount))
            let x = radius * cos(angle)
            let z = radius * sin(angle)

            let panelEntity = Entity()

            // Create panel mesh
            let planeMesh = MeshResource.generatePlane(width: 0.5, height: 0.4)
            var material = SimpleMaterial()
            material.color = .init(tint: .white.withAlphaComponent(0.9))

            panelEntity.components.set(ModelComponent(mesh: planeMesh, materials: [material]))
            panelEntity.position = [x, 0, z]

            // Rotate panel to face center
            let lookRotation = simd_quatf(angle: atan2(x, z), axis: [0, 1, 0])
            panelEntity.orientation = lookRotation

            panels.append(panelEntity)
        }

        return panels
    }
}

// MARK: - Emergency Protocols
enum EmergencyProtocol {
    case sepsis
    case cardiac
    case stroke
    case trauma

    var name: String {
        switch self {
        case .sepsis: return "Sepsis Protocol"
        case .cardiac: return "Cardiac Emergency"
        case .stroke: return "Stroke Alert"
        case .trauma: return "Trauma Response"
        }
    }

    var steps: [String] {
        switch self {
        case .sepsis:
            return [
                "Obtain blood cultures",
                "Administer broad-spectrum antibiotics",
                "Start IV fluid resuscitation",
                "Monitor lactate levels",
                "Initiate sepsis bundle"
            ]
        case .cardiac:
            return [
                "Assess airway and breathing",
                "Obtain 12-lead ECG",
                "Administer aspirin",
                "Establish IV access",
                "Activate cath lab if STEMI"
            ]
        case .stroke:
            return [
                "Verify time of symptom onset",
                "Obtain CT scan stat",
                "Check contraindications for tPA",
                "Notify stroke team",
                "Monitor neuro status"
            ]
        case .trauma:
            return [
                "Primary survey (ABCDE)",
                "Control hemorrhage",
                "Establish two large-bore IVs",
                "Order trauma panel",
                "Notify trauma surgeon"
            ]
        }
    }
}

#Preview {
    EmergencyResponseSpace()
        .environment(NavigationCoordinator())
}
