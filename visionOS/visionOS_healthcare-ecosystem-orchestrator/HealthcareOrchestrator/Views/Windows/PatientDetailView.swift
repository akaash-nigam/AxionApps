import SwiftUI
import SwiftData

struct PatientDetailView: View {
    // MARK: - Environment
    @Environment(\.modelContext) private var modelContext
    @Query private var allPatients: [Patient]

    // MARK: - Properties
    let patientId: UUID

    // MARK: - State
    @State private var selectedTab: PatientTab = .overview

    // MARK: - Computed Properties
    private var patient: Patient? {
        allPatients.first { $0.id == patientId }
    }

    // MARK: - Body
    var body: some View {
        Group {
            if let patient = patient {
                NavigationStack {
                    VStack(spacing: 0) {
                        // Patient Header
                        patientHeader(patient)
                            .padding()
                            .background(.regularMaterial)

                        // Tab Selection
                        tabSelector

                        // Content
                        ScrollView {
                            tabContent(patient)
                                .padding()
                        }
                    }
                    .navigationTitle("Patient Details")
                }
            } else {
                ContentUnavailableView(
                    "Patient Not Found",
                    systemImage: "person.crop.circle.badge.xmark",
                    description: Text("The requested patient could not be found.")
                )
            }
        }
    }

    // MARK: - Patient Header
    private func patientHeader(_ patient: Patient) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(patient.fullName)
                        .font(.system(size: 28, weight: .bold))

                    HStack(spacing: 16) {
                        Label("MRN: \(patient.mrn)", systemImage: "number")
                        Label("\(patient.age) yrs, \(patient.gender)", systemImage: "person.fill")
                        if let location = patient.currentLocation {
                            Label(location, systemImage: "bed.double.fill")
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                Spacer()

                // Status Badge
                Text(patient.status.rawValue)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(statusColor(patient.status))
                    .clipShape(Capsule())
            }

            // Current Vitals
            if let vitals = patient.latestVitalSign {
                VitalSignsBar(vitalSign: vitals)
            }
        }
    }

    // MARK: - Tab Selector
    private var tabSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(PatientTab.allCases) { tab in
                    Button {
                        withAnimation {
                            selectedTab = tab
                        }
                    } label: {
                        Label(tab.rawValue, systemImage: tab.icon)
                            .font(.subheadline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedTab == tab ? Color.accentColor : Color.clear)
                            .foregroundStyle(selectedTab == tab ? .white : .primary)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    // MARK: - Tab Content
    @ViewBuilder
    private func tabContent(_ patient: Patient) -> some View {
        switch selectedTab {
        case .overview:
            OverviewTab(patient: patient)
        case .vitals:
            VitalsTab(patient: patient)
        case .medications:
            MedicationsTab(patient: patient)
        case .carePlan:
            CarePlanTab(patient: patient)
        case .notes:
            NotesTab(patient: patient)
        }
    }

    private func statusColor(_ status: PatientStatus) -> Color {
        switch status {
        case .active: return .blue
        case .critical: return .red
        case .stable: return .green
        case .discharged: return .gray
        case .deceased: return .black
        }
    }
}

// MARK: - Patient Tabs
enum PatientTab: String, CaseIterable, Identifiable {
    case overview = "Overview"
    case vitals = "Vitals"
    case medications = "Medications"
    case carePlan = "Care Plan"
    case notes = "Notes"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .overview: return "info.circle.fill"
        case .vitals: return "waveform.path.ecg"
        case .medications: return "pills.fill"
        case .carePlan: return "list.clipboard.fill"
        case .notes: return "doc.text.fill"
        }
    }
}

// MARK: - Overview Tab
struct OverviewTab: View {
    let patient: Patient

    var body: some View {
        VStack(spacing: 20) {
            // Active Problems
            SectionCard(title: "Active Problems", icon: "exclamationmark.triangle.fill") {
                if let diagnosis = patient.primaryDiagnosis {
                    ProblemRow(diagnosis: diagnosis, isPrimary: true)
                } else {
                    Text("No active problems recorded")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            // Recent Encounters
            SectionCard(title: "Recent Encounters", icon: "building.2.fill") {
                if patient.encounters.isEmpty {
                    Text("No encounters recorded")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    ForEach(patient.encounters.prefix(3)) { encounter in
                        EncounterRow(encounter: encounter)
                    }
                }
            }

            // Care Team
            SectionCard(title: "Care Team", icon: "person.3.fill") {
                if let provider = patient.assignedProvider {
                    CareTeamMemberRow(name: provider, role: "Attending Physician")
                } else {
                    Text("No care team assigned")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

// MARK: - Vitals Tab
struct VitalsTab: View {
    let patient: Patient

    var body: some View {
        VStack(spacing: 16) {
            if patient.vitalSigns.isEmpty {
                ContentUnavailableView(
                    "No Vital Signs",
                    systemImage: "waveform.path.ecg",
                    description: Text("No vital signs have been recorded for this patient")
                )
            } else {
                ForEach(patient.vitalSigns.sorted { $0.recordedAt > $1.recordedAt }) { vital in
                    VitalSignDetailCard(vitalSign: vital)
                }
            }
        }
    }
}

// MARK: - Medications Tab
struct MedicationsTab: View {
    let patient: Patient

    var body: some View {
        VStack(spacing: 16) {
            if patient.medications.isEmpty {
                ContentUnavailableView(
                    "No Medications",
                    systemImage: "pills.fill",
                    description: Text("No medications have been prescribed")
                )
            } else {
                ForEach(patient.medications) { medication in
                    MedicationCard(medication: medication)
                }
            }
        }
    }
}

// MARK: - Care Plan Tab
struct CarePlanTab: View {
    let patient: Patient

    var body: some View {
        VStack(spacing: 16) {
            if patient.carePlans.isEmpty {
                ContentUnavailableView(
                    "No Care Plans",
                    systemImage: "list.clipboard.fill",
                    description: Text("No care plans have been created")
                )
            } else {
                ForEach(patient.carePlans) { carePlan in
                    CarePlanCard(carePlan: carePlan)
                }
            }
        }
    }
}

// MARK: - Notes Tab
struct NotesTab: View {
    let patient: Patient

    var body: some View {
        VStack(spacing: 16) {
            if patient.clinicalNotes.isEmpty {
                ContentUnavailableView(
                    "No Notes",
                    systemImage: "doc.text.fill",
                    description: Text("No clinical notes have been recorded")
                )
            } else {
                ForEach(patient.clinicalNotes.sorted { $0.createdAt > $1.createdAt }) { note in
                    ClinicalNoteCard(note: note)
                }
            }
        }
    }
}

// MARK: - Supporting Components

struct VitalSignsBar: View {
    let vitalSign: VitalSign

    var body: some View {
        HStack(spacing: 20) {
            if let hr = vitalSign.heartRate {
                VitalMetric(label: "HR", value: "\(hr)", unit: "BPM", isAbnormal: hr < 60 || hr > 100)
            }
            if let bp = vitalSign.bloodPressureString {
                VitalMetric(label: "BP", value: bp, unit: "mmHg", isAbnormal: vitalSign.bloodPressureSystolic ?? 0 < 90)
            }
            if let rr = vitalSign.respiratoryRate {
                VitalMetric(label: "RR", value: "\(rr)", unit: "/min", isAbnormal: rr < 12 || rr > 20)
            }
            if let spo2 = vitalSign.oxygenSaturation {
                VitalMetric(label: "SpO₂", value: "\(spo2)", unit: "%", isAbnormal: spo2 < 95)
            }
            if let temp = vitalSign.temperature {
                VitalMetric(label: "Temp", value: String(format: "%.1f", temp), unit: "°C", isAbnormal: temp > 38.0)
            }
        }
    }
}

struct VitalMetric: View {
    let label: String
    let value: String
    let unit: String
    let isAbnormal: Bool

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(isAbnormal ? .red : .primary)
            Text(unit)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }
}

struct SectionCard<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.headline)

            content
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct ProblemRow: View {
    let diagnosis: String
    let isPrimary: Bool

    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(isPrimary ? .red : .orange)
            Text(diagnosis)
            if isPrimary {
                Text("Primary")
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.red.opacity(0.2))
                    .clipShape(Capsule())
            }
            Spacer()
        }
    }
}

struct EncounterRow: View {
    let encounter: Encounter

    var body: some View {
        HStack {
            Image(systemName: encounter.encounterType.systemImage)
            VStack(alignment: .leading) {
                Text(encounter.encounterType.rawValue)
                    .font(.subheadline)
                Text(encounter.admissionDate.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
}

struct CareTeamMemberRow: View {
    let name: String
    let role: String

    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .font(.title2)
            VStack(alignment: .leading) {
                Text(name)
                    .font(.subheadline)
                Text(role)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
}

struct VitalSignDetailCard: View {
    let vitalSign: VitalSign

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(vitalSign.recordedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.headline)
                Spacer()
                AlertBadge(level: vitalSign.alertLevel)
            }

            VitalSignsBar(vitalSign: vitalSign)

            if !vitalSign.criticalValues.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Critical Values:")
                        .font(.caption.bold())
                        .foregroundStyle(.red)
                    ForEach(vitalSign.criticalValues, id: \.self) { value in
                        Text("• \(value)")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct AlertBadge: View {
    let level: AlertLevel

    var body: some View {
        Text(level.rawValue)
            .font(.caption.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
            .clipShape(Capsule())
    }

    var color: Color {
        switch level {
        case .normal: return .blue
        case .warning: return .yellow
        case .critical: return .orange
        case .emergency: return .red
        }
    }
}

struct MedicationCard: View {
    let medication: Medication

    var body: some View {
        HStack {
            Image(systemName: medication.route.systemImage)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(medication.displayName)
                    .font(.headline)
                Text("\(medication.dosage) - \(medication.frequency)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(medication.route.rawValue)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            Text(medication.status.rawValue)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.2))
                .clipShape(Capsule())
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct CarePlanCard: View {
    let carePlan: CarePlan

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(carePlan.title)
                    .font(.headline)
                Spacer()
                Text(carePlan.status.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .clipShape(Capsule())
            }

            Text(carePlan.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if !carePlan.goals.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Goals:")
                        .font(.caption.bold())
                    ForEach(carePlan.goals, id: \.self) { goal in
                        Text("• \(goal)")
                            .font(.caption)
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct ClinicalNoteCard: View {
    let note: ClinicalNote

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(note.noteType.rawValue)
                    .font(.headline)
                Spacer()
                Text(note.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text("By: \(note.author)")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(note.content)
                .font(.subheadline)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Previews
#if DEBUG
#Preview {
    PatientDetailView(patientId: UUID())
        .modelContainer(for: Patient.self, inMemory: true)
}
#endif
