//
//  OperationsCenterView.swift
//  SmartCityCommandPlatform
//
//  Main city operations command center
//

import SwiftUI
import SwiftData

struct OperationsCenterView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \EmergencyIncident.reportedAt, order: .reverse)
    private var incidents: [EmergencyIncident]

    @State private var selectedTab = "overview"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Stats
                    HeaderStatsSection()

                    // Critical Alerts
                    CriticalAlertsSection(incidents: criticalIncidents)

                    // Department Status Grid
                    DepartmentStatusSection()

                    // Real-time Metrics
                    CityMetricsSection()
                }
                .padding()
            }
            .navigationTitle("City Operations Center")
            .toolbar {
                ToolbarItemGroup(placement: .automatic) {
                    Button {
                        // Notifications
                    } label: {
                        Label("Notifications", systemImage: "bell.fill")
                    }

                    Button {
                        // Settings
                    } label: {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                }
            }
        }
    }

    private var criticalIncidents: [EmergencyIncident] {
        incidents.filter { $0.severity == .critical || $0.severity == .catastrophic }
    }
}

// MARK: - Header Stats Section

struct HeaderStatsSection: View {
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            StatCard(
                title: "CRITICAL ALERTS",
                value: "3",
                icon: "exclamationmark.triangle.fill",
                color: .red
            )

            StatCard(
                title: "ACTIVE INCIDENTS",
                value: "12",
                icon: "flame.fill",
                color: .orange
            )

            StatCard(
                title: "RESOURCE STATUS",
                value: "89%",
                icon: "checkmark.circle.fill",
                color: .green
            )
        }
    }
}

// MARK: - Critical Alerts Section

struct CriticalAlertsSection: View {
    let incidents: [EmergencyIncident]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CRITICAL ALERTS")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            if incidents.isEmpty {
                ContentUnavailableView(
                    "No Critical Alerts",
                    systemImage: "checkmark.circle",
                    description: Text("All systems operational")
                )
                .frame(height: 200)
            } else {
                VStack(spacing: 12) {
                    ForEach(incidents.prefix(5)) { incident in
                        IncidentRow(incident: incident)
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: .rect(cornerRadius: 16))
    }
}

// MARK: - Department Status Section

struct DepartmentStatusSection: View {
    private let departments = [
        Department(name: "Fire Services", icon: "flame.fill", activeUnits: 8, color: .red, status: .operational),
        Department(name: "Police", icon: "shield.fill", activeUnits: 15, color: .blue, status: .operational),
        Department(name: "Medical", icon: "cross.case.fill", activeUnits: 12, color: .red, status: .operational),
        Department(name: "Utilities", icon: "wrench.and.screwdriver.fill", activeUnits: 6, color: .orange, status: .operational),
        Department(name: "Traffic", icon: "car.fill", activeUnits: 10, color: .green, status: .degraded),
        Department(name: "Infrastructure", icon: "building.2.fill", activeUnits: 5, color: .purple, status: .operational)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DEPARTMENT STATUS")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 180))
            ], spacing: 12) {
                ForEach(departments) { department in
                    DepartmentCard(department: department)
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: .rect(cornerRadius: 16))
    }
}

// MARK: - City Metrics Section

struct CityMetricsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("REAL-TIME CITY METRICS")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                MetricChart(title: "Traffic Flow", value: 0.7, color: .green)
                MetricChart(title: "Air Quality", value: 0.85, color: .blue)
                MetricChart(title: "Power Grid", value: 0.92, color: .yellow)
            }
        }
        .padding()
        .background(.regularMaterial, in: .rect(cornerRadius: 16))
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                Spacer()
            }

            HStack {
                Text(value)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(color)
                Spacer()
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
    }
}

struct IncidentRow: View {
    let incident: EmergencyIncident

    var body: some View {
        HStack {
            Image(systemName: iconForIncidentType(incident.type))
                .foregroundStyle(colorForSeverity(incident.severity))

            VStack(alignment: .leading, spacing: 4) {
                Text(incident.type.rawValue.capitalized)
                    .font(.headline)
                Text(incident.address.isEmpty ? "Location pending" : incident.address)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(incident.reportedAt, style: .relative)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.thinMaterial, in: .rect(cornerRadius: 8))
    }

    private func iconForIncidentType(_ type: IncidentType) -> String {
        switch type {
        case .fire: return "flame.fill"
        case .medical: return "cross.case.fill"
        case .crime: return "shield.fill"
        case .accident: return "car.fill"
        case .infrastructure: return "exclamationmark.triangle.fill"
        case .natural: return "cloud.bolt.fill"
        case .hazmat: return "drop.triangle.fill"
        case .civil: return "person.3.fill"
        }
    }

    private func colorForSeverity(_ severity: IncidentSeverity) -> Color {
        switch severity {
        case .low: return .blue
        case .medium: return .yellow
        case .high: return .orange
        case .critical, .catastrophic: return .red
        }
    }
}

struct DepartmentCard: View {
    let department: Department

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: department.icon)
                .font(.title2)
                .foregroundStyle(department.color)

            VStack(alignment: .leading, spacing: 4) {
                Text(department.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("\(department.activeUnits) active")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            StatusIndicator(status: department.status)
        }
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 8))
        .hoverEffect()
    }
}

struct StatusIndicator: View {
    let status: OperationalStatus

    var body: some View {
        Circle()
            .fill(colorForStatus(status))
            .frame(width: 12, height: 12)
    }

    private func colorForStatus(_ status: OperationalStatus) -> Color {
        switch status {
        case .operational: return .green
        case .degraded: return .yellow
        case .maintenance: return .blue
        case .failure, .emergency: return .red
        }
    }
}

struct MetricChart: View {
    let title: String
    let value: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            ProgressView(value: value)
                .tint(color)

            Text("\(Int(value * 100))%")
                .font(.headline)
        }
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 8))
    }
}

// MARK: - Supporting Types

struct Department: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let activeUnits: Int
    let color: Color
    let status: OperationalStatus
}

#Preview {
    OperationsCenterView()
        .environment(AppState())
}
