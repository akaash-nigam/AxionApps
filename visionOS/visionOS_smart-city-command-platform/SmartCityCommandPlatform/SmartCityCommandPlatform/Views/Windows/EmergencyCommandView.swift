//
//  EmergencyCommandView.swift
//  SmartCityCommandPlatform
//
//  Emergency incident command and coordination
//

import SwiftUI
import SwiftData

struct EmergencyCommandView: View {
    @Query(sort: \EmergencyIncident.reportedAt, order: .reverse)
    private var incidents: [EmergencyIncident]

    @State private var selectedIncident: EmergencyIncident?

    var body: some View {
        NavigationSplitView {
            // Incident List
            List(incidents, selection: $selectedIncident) { incident in
                IncidentListRow(incident: incident)
            }
            .navigationTitle("Active Incidents")
        } detail: {
            // Incident Details
            if let incident = selectedIncident {
                IncidentDetailView(incident: incident)
            } else {
                ContentUnavailableView(
                    "No Incident Selected",
                    systemImage: "checkmark.circle",
                    description: Text("Select an incident from the list to view details")
                )
            }
        }
    }
}

// MARK: - Incident List Row

struct IncidentListRow: View {
    let incident: EmergencyIncident

    var body: some View {
        HStack {
            // Type Icon
            Image(systemName: iconForType(incident.type))
                .font(.title2)
                .foregroundStyle(colorForSeverity(incident.severity))
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(incident.type.rawValue.capitalized)
                    .font(.headline)

                Text(incident.address.isEmpty ? "Location pending" : incident.address)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    Label(incident.reportedAt, style: .relative)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Label(incident.severity.rawValue.capitalized, systemImage: "exclamationmark.triangle")
                        .font(.caption)
                        .foregroundStyle(colorForSeverity(incident.severity))
                }
            }

            Spacer()

            StatusBadge(status: incident.status)
        }
        .padding(.vertical, 4)
    }

    private func iconForType(_ type: IncidentType) -> String {
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

// MARK: - Incident Detail View

struct IncidentDetailView: View {
    let incident: EmergencyIncident

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Incident Header
                IncidentHeaderSection(incident: incident)

                // Response Units
                ResponseUnitsSection(incident: incident)

                // Action Buttons
                ActionButtonsSection()

                // Timeline
                TimelineSection(incident: incident)
            }
            .padding()
        }
        .navigationTitle("Incident \(incident.incidentNumber)")
    }
}

// MARK: - Incident Header Section

struct IncidentHeaderSection: View {
    let incident: EmergencyIncident

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(incident.type.rawValue.capitalized)
                        .font(.title)
                        .fontWeight(.bold)

                    Text(incident.address.isEmpty ? "Location pending" : incident.address)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                StatusBadge(status: incident.status)
            }

            Divider()

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                InfoItem(label: "Reported", value: incident.reportedAt.formatted(date: .omitted, time: .shortened))
                InfoItem(label: "Severity", value: incident.severity.rawValue.capitalized)
                InfoItem(label: "Affected", value: "\(incident.affectedCitizens) people")
            }

            if !incident.description.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(incident.description)
                        .font(.body)
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: .rect(cornerRadius: 16))
    }
}

// MARK: - Response Units Section

struct ResponseUnitsSection: View {
    let incident: EmergencyIncident

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("RESPONSE UNITS")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            if incident.responses.isEmpty {
                ContentUnavailableView(
                    "No Units Dispatched",
                    systemImage: "car.circle",
                    description: Text("Deploy emergency units to respond to this incident")
                )
                .frame(height: 150)
            } else {
                VStack(spacing: 12) {
                    ForEach(incident.responses) { response in
                        ResponseUnitRow(response: response)
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: .rect(cornerRadius: 16))
    }
}

struct ResponseUnitRow: View {
    let response: EmergencyResponse

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconForUnitType(response.unitType))
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(response.unitId)
                    .font(.headline)

                Text(response.unitType.rawValue.capitalized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(response.status.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(colorForStatus(response.status))

                if let eta = response.arrivedAt {
                    Text("Arrived")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                } else {
                    Text("ETA 3 min")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(.thinMaterial, in: .rect(cornerRadius: 8))
    }

    private func iconForUnitType(_ type: EmergencyUnitType) -> String {
        switch type {
        case .fire: return "flame.fill"
        case .police: return "shield.fill"
        case .ambulance: return "cross.case.fill"
        case .hazmat: return "drop.triangle.fill"
        case .rescue: return "lifepreserver.fill"
        case .utility: return "wrench.and.screwdriver.fill"
        }
    }

    private func colorForStatus(_ status: ResponseStatus) -> Color {
        switch status {
        case .dispatched: return .orange
        case .enRoute: return .yellow
        case .onScene: return .green
        case .returning: return .blue
        case .available: return .gray
        }
    }
}

// MARK: - Action Buttons Section

struct ActionButtonsSection: View {
    var body: some View {
        HStack(spacing: 16) {
            Button {
                // Deploy additional resources
            } label: {
                Label("Deploy Units", systemImage: "car.fill")
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)

            Button {
                // Open communications
            } label: {
                Label("Communications", systemImage: "phone.fill")
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)

            Button {
                // View protocols
            } label: {
                Label("Protocols", systemImage: "doc.text.fill")
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
        }
    }
}

// MARK: - Timeline Section

struct TimelineSection: View {
    let incident: EmergencyIncident

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TIMELINE")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 16) {
                TimelineEvent(
                    time: incident.reportedAt,
                    title: "Incident Reported",
                    description: "Initial report received"
                )

                if let dispatched = incident.dispatchedAt {
                    TimelineEvent(
                        time: dispatched,
                        title: "Units Dispatched",
                        description: "\(incident.responses.count) units en route"
                    )
                }

                ForEach(incident.updates) { update in
                    TimelineEvent(
                        time: update.timestamp,
                        title: "Update",
                        description: update.message
                    )
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: .rect(cornerRadius: 16))
    }
}

struct TimelineEvent: View {
    let time: Date
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(.blue)
                .frame(width: 12, height: 12)
                .padding(.top, 4)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Spacer()

                    Text(time.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Supporting Views

struct StatusBadge: View {
    let status: IncidentStatus

    var body: some View {
        Text(status.rawValue.capitalized)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(colorForStatus(status).opacity(0.2), in: .capsule)
            .foregroundStyle(colorForStatus(status))
    }

    private func colorForStatus(_ status: IncidentStatus) -> Color {
        switch status {
        case .reported: return .orange
        case .dispatched, .responding: return .yellow
        case .onScene, .contained: return .blue
        case .resolved, .closed: return .green
        }
    }
}

struct InfoItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.headline)
        }
    }
}

#Preview {
    EmergencyCommandView()
}
