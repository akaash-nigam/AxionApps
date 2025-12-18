//
//  JobDetailsView.swift
//  FieldServiceAR
//
//  Job details window
//

import SwiftUI
import SwiftData

struct JobDetailsView: View {
    let jobId: UUID

    @Environment(\.appState) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissWindow) private var dismissWindow

    @State private var job: ServiceJob?
    @State private var equipment: Equipment?
    @State private var procedures: [RepairProcedure] = []
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            if isLoading {
                ProgressView("Loading job details...")
            } else if let job = job {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Equipment section
                        equipmentSection(job: job)

                        Divider()

                        // Job info
                        jobInfoSection(job: job)

                        Divider()

                        // Procedures
                        proceduresSection(procedures: procedures)

                        Divider()

                        // Required parts
                        partsSection(job: job)

                        Divider()

                        // Actions
                        actionsSection(job: job)
                    }
                    .padding()
                }
            } else {
                ContentUnavailableView(
                    "Job Not Found",
                    systemImage: "exclamationmark.triangle",
                    description: Text("Unable to load job details")
                )
            }
        }
        .navigationTitle(job?.workOrderNumber ?? "Job Details")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button("Close") {
                    dismissWindow(id: "job-details")
                }
            }
        }
        .task {
            await loadJobDetails()
        }
    }

    // MARK: - Equipment Section

    private func equipmentSection(job: ServiceJob) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Equipment")
                .font(.headline)

            HStack(spacing: 16) {
                // 3D preview placeholder
                RoundedRectangle(cornerRadius: 12)
                    .fill(.tertiary)
                    .frame(width: 200, height: 150)
                    .overlay {
                        VStack {
                            Image(systemName: "cube.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(.secondary)

                            Text("3D Preview")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                VStack(alignment: .leading, spacing: 8) {
                    Text("\(job.equipmentManufacturer) \(job.equipmentModel)")
                        .font(.title3)
                        .fontWeight(.semibold)

                    if let equipment = equipment {
                        Text(equipment.category.rawValue)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        if let description = equipment.equipmentDescription {
                            Text(description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Button {
                        openWindow(id: "equipment-3d", value: job.equipmentId)
                    } label: {
                        Label("View in 3D", systemImage: "cube")
                    }
                    .buttonStyle(.bordered)
                }

                Spacer()
            }
        }
    }

    // MARK: - Job Info Section

    private func jobInfoSection(job: ServiceJob) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Job Information")
                .font(.headline)

            Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 8) {
                GridRow {
                    Text("Customer:")
                        .foregroundStyle(.secondary)
                    Text(job.customerName)
                }

                GridRow {
                    Text("Site:")
                        .foregroundStyle(.secondary)
                    Text(job.siteName)
                }

                GridRow {
                    Text("Address:")
                        .foregroundStyle(.secondary)
                    Text(job.address)
                }

                GridRow {
                    Text("Scheduled:")
                        .foregroundStyle(.secondary)
                    Text(job.scheduledDate, style: .date)
                        + Text(" at ")
                        + Text(job.scheduledDate, style: .time)
                }

                GridRow {
                    Text("Duration:")
                        .foregroundStyle(.secondary)
                    Text(formatDuration(job.estimatedDuration))
                }

                GridRow {
                    Text("Priority:")
                        .foregroundStyle(.secondary)
                    HStack(spacing: 4) {
                        Circle()
                            .fill(priorityColor(job.priority))
                            .frame(width: 8, height: 8)
                        Text(job.priority.rawValue)
                    }
                }
            }
            .font(.subheadline)
        }
    }

    // MARK: - Procedures Section

    private func proceduresSection(procedures: [RepairProcedure]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Repair Procedures")
                .font(.headline)

            if procedures.isEmpty {
                Text("No procedures defined for this job")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(procedures) { procedure in
                    ProcedureCard(procedure: procedure)
                }
            }
        }
    }

    // MARK: - Parts Section

    private func partsSection(job: ServiceJob) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Required Parts")
                .font(.headline)

            if job.requiredPartNumbers.isEmpty {
                Text("No parts required")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(job.requiredPartNumbers, id: \.self) { partNumber in
                    HStack {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(.blue)

                        VStack(alignment: .leading) {
                            Text(partNumber)
                                .font(.subheadline)

                            Text("In Stock")
                                .font(.caption)
                                .foregroundStyle(.green)
                        }

                        Spacer()

                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    // MARK: - Actions Section

    private func actionsSection(job: ServiceJob) -> some View {
        VStack(spacing: 12) {
            Button {
                Task {
                    await startARMode(job: job)
                }
            } label: {
                Label("Start AR Repair Mode", systemImage: "visionpro")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            HStack(spacing: 12) {
                Button {
                    // Start job without AR
                } label: {
                    Label("Start Without AR", systemImage: "play.fill")
                }
                .buttonStyle(.bordered)

                Button {
                    // Call expert
                } label: {
                    Label("Call Expert", systemImage: "phone.fill")
                }
                .buttonStyle(.bordered)
            }
        }
    }

    // MARK: - Helper Functions

    private func loadJobDetails() async {
        let container = DependencyContainer()
        let jobRepo = JobRepository(modelContainer: container.modelContainer)
        let equipRepo = EquipmentRepository(modelContainer: container.modelContainer)
        let procRepo = ProcedureRepository(modelContainer: container.modelContainer)

        do {
            job = try await jobRepo.fetchById(jobId)

            if let job = job {
                equipment = try await equipRepo.fetchById(job.equipmentId)
                procedures = try await procRepo.fetchForEquipment(job.equipmentId)
            }
        } catch {
            print("Error loading job: \(error)")
        }

        isLoading = false
    }

    private func startARMode(job: ServiceJob) async {
        appState.selectedJob = job
        await openImmersiveSpace(id: "ar-repair")
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    private func priorityColor(_ priority: JobPriority) -> Color {
        switch priority {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .orange
        case .critical: return .red
        }
    }
}

// MARK: - Procedure Card

struct ProcedureCard: View {
    let procedure: RepairProcedure

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(procedure.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Spacer()

                Text("\(procedure.steps.count) steps")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let description = procedure.procedureDescription {
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            HStack {
                Label("\(formatTime(procedure.estimatedTime))", systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                DifficultyBadge(difficulty: procedure.difficulty)
            }

            // Step preview
            if !procedure.steps.isEmpty {
                Divider()

                ForEach(procedure.steps.prefix(3)) { step in
                    HStack(spacing: 8) {
                        Image(systemName: step.status == .completed ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(step.status == .completed ? .green : .secondary)

                        Text("Step \(step.sequenceNumber): \(step.instruction)")
                            .font(.caption)
                            .lineLimit(1)
                    }
                }

                if procedure.steps.count > 3 {
                    Text("+ \(procedure.steps.count - 3) more steps")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        return "\(minutes) min"
    }
}

// MARK: - Difficulty Badge

struct DifficultyBadge: View {
    let difficulty: DifficultyLevel

    var body: some View {
        Text(difficulty.rawValue)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(backgroundColor.opacity(0.2))
            .foregroundStyle(backgroundColor)
            .clipShape(Capsule())
    }

    private var backgroundColor: Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .yellow
        case .hard: return .orange
        case .expert: return .red
        }
    }
}

#Preview {
    JobDetailsView(jobId: UUID())
        .frame(width: 1000, height: 700)
}
