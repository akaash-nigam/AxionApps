import SwiftUI

struct DashboardView: View {
    @State private var patientName = ""
    @State private var selectedView: MedicalView = .anatomy
    @State private var showImmersive = false
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Text("Healthcare Orchestrator")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.green, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Text("Medical Visualization in Spatial Reality")
                    .font(.title2)
                    .foregroundStyle(.secondary)

                // Patient info
                VStack(alignment: .leading, spacing: 20) {
                    Text("Patient Information")
                        .font(.title3)
                        .fontWeight(.semibold)

                    TextField("Patient Name", text: $patientName)
                        .textFieldStyle(.roundedBorder)
                        .font(.title3)

                    Picker("Visualization Type", selection: $selectedView) {
                        ForEach(MedicalView.allCases) { view in
                            HStack {
                                Text(view.icon)
                                Text(view.rawValue)
                            }
                            .tag(view)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(15)

                // Medical modules
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    ModuleCard(icon: "heart.fill", title: "Cardiology", color: .red, count: 12)
                    ModuleCard(icon: "brain.head.profile", title: "Neurology", color: .purple, count: 8)
                    ModuleCard(icon: "cross.case.fill", title: "Emergency", color: .orange, count: 5)
                    ModuleCard(icon: "pills.fill", title: "Pharmacy", color: .blue, count: 24)
                }
                .padding()

                Button(action: startVisualization) {
                    Label("Start 3D Visualization", systemImage: "cube.transparent")
                        .font(.title2)
                        .padding()
                        .frame(minWidth: 350)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .disabled(patientName.isEmpty)
            }
            .padding(60)
        }
    }

    func startVisualization() {
        Task {
            if showImmersive {
                await dismissImmersiveSpace()
                showImmersive = false
            } else {
                await openImmersiveSpace(id: "MedicalView")
                showImmersive = true
            }
        }
    }
}

struct ModuleCard: View {
    let icon: String
    let title: String
    let color: Color
    let count: Int

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(color)

            Text(title)
                .font(.headline)

            Text("\(count) records")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.15))
        .cornerRadius(12)
    }
}

enum MedicalView: String, CaseIterable, Identifiable {
    case anatomy = "Anatomy"
    case scans = "Scans"
    case vitals = "Vitals"
    case records = "Records"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .anatomy: return "🫀"
        case .scans: return "🔬"
        case .vitals: return "📊"
        case .records: return "📋"
        }
    }
}

#Preview {
    DashboardView()
}
