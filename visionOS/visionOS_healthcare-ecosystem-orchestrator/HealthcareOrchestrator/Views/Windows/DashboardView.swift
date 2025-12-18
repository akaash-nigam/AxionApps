import SwiftUI
import SwiftData

struct DashboardView: View {
    // MARK: - Environment
    @Environment(\.modelContext) private var modelContext
    @Environment(NavigationCoordinator.self) private var navigationCoordinator
    @Environment(\.openWindow) private var openWindow

    // MARK: - State
    @State private var viewModel: DashboardViewModel?
    @State private var selectedPatient: Patient?

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    headerSection

                    // Quick Stats Section
                    if let stats = viewModel?.statistics {
                        statsSection(stats)
                    }

                    // Active Alerts Section
                    if viewModel?.hasActiveAlerts == true {
                        alertsSection
                    }

                    // Patient List Section
                    patientListSection

                    // Action Buttons
                    actionButtonsSection
                }
                .padding()
            }
            .navigationTitle("Healthcare Orchestrator")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    refreshButton
                }
                ToolbarItem(placement: .automatic) {
                    filterMenu
                }
            }
        }
        .task {
            if viewModel == nil {
                viewModel = DashboardViewModel(modelContext: modelContext)
                await viewModel?.loadData()
                viewModel?.startAutoRefresh()
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Command Center")
                    .font(.system(size: 34, weight: .bold))
                Text(Date.now.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Alert Badge
            if let count = viewModel?.alertCount, count > 0 {
                Label("\(count)", systemImage: "bell.fill")
                    .font(.title2)
                    .foregroundStyle(.red)
                    .padding()
                    .background(.red.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Stats Section
    private func statsSection(_ stats: HealthcareStatistics) -> some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Total Patients",
                value: "\(stats.totalPatients)",
                icon: "person.3.fill",
                color: .blue
            )

            StatCard(
                title: "Active",
                value: "\(stats.activePatients)",
                icon: "waveform.path.ecg",
                color: .green
            )

            StatCard(
                title: "Critical",
                value: "\(stats.criticalPatients)",
                icon: "exclamationmark.triangle.fill",
                color: .red
            )

            StatCard(
                title: "Stable",
                value: "\(stats.stablePatients)",
                icon: "heart.fill",
                color: .mint
            )
        }
    }

    // MARK: - Alerts Section
    private var alertsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Active Alerts")
                .font(.headline)

            ForEach(viewModel?.activeAlerts ?? []) { alert in
                AlertCard(alert: alert) {
                    viewModel?.acknowledgeAlert(alert, by: "Current User")
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Patient List Section
    private var patientListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Patients")
                    .font(.headline)
                Spacer()
                Text("\(viewModel?.displayedPatients.count ?? 0) patients")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            LazyVStack(spacing: 8) {
                ForEach(viewModel?.displayedPatients ?? []) { patient in
                    PatientCard(patient: patient)
                        .onTapGesture {
                            openWindow(id: "patientDetail", value: patient.id)
                        }
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        HStack(spacing: 16) {
            Button {
                openWindow(id: "careCoordination")
            } label: {
                Label("Care Coordination", systemImage: "square.stack.3d.up.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)

            Button {
                openWindow(id: "clinicalObservatory")
            } label: {
                Label("Clinical Observatory", systemImage: "chart.line.uptrend.xyaxis")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)

            Button {
                openWindow(id: "analytics")
            } label: {
                Label("Analytics", systemImage: "chart.bar.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
    }

    // MARK: - Refresh Button
    private var refreshButton: some View {
        Button {
            Task {
                await viewModel?.refreshData()
            }
        } label: {
            Label("Refresh", systemImage: "arrow.clockwise")
        }
        .disabled(viewModel?.isLoading == true)
    }

    // MARK: - Filter Menu
    private var filterMenu: some View {
        Menu {
            Button("All Patients") {
                viewModel?.applyFilter(.all)
            }
            Button("Active Only") {
                viewModel?.applyFilter(.active)
            }
            Button("Critical Only") {
                viewModel?.applyFilter(.critical)
            }
        } label: {
            Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.system(size: 32, weight: .bold))

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Previews
#if DEBUG
#Preview {
    DashboardView()
        .modelContainer(for: Patient.self, inMemory: true)
        .environment(NavigationCoordinator())
}
#endif
