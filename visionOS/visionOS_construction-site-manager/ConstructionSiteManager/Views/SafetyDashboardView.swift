import SwiftUI
import SwiftData
import Charts

/// Real-time safety monitoring dashboard with alerts, metrics, and compliance tracking
/// Integrates with SafetyMonitoringService for live danger zone monitoring
struct SafetyDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var sites: [Site]

    @State private var safetyService = SafetyMonitoringService.shared
    @State private var selectedTimeRange: TimeRange = .today
    @State private var selectedSeverity: AlertSeverity? = nil
    @State private var showingAlertDetail: SafetyAlert?
    @State private var showingIncidentReport = false

    enum TimeRange: String, CaseIterable {
        case today = "Today"
        case week = "This Week"
        case month = "This Month"
        case all = "All Time"

        var startDate: Date {
            let calendar = Calendar.current
            let now = Date()
            switch self {
            case .today:
                return calendar.startOfDay(for: now)
            case .week:
                return calendar.date(byAdding: .day, value: -7, to: now)!
            case .month:
                return calendar.date(byAdding: .month, value: -1, to: now)!
            case .all:
                return Date.distantPast
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Safety score card
                    safetyScoreCard

                    // Active alerts
                    activeAlertsSection

                    // Time range picker
                    timeRangeFilter

                    // Safety metrics
                    metricsSection

                    // Alert trend chart
                    alertTrendChart

                    // Severity breakdown
                    severityBreakdown

                    // Recent incidents
                    recentIncidentsSection

                    // Compliance status
                    complianceSection

                    // Danger zones
                    dangerZonesSection
                }
                .padding()
            }
            .navigationTitle("Safety Dashboard")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(action: { showingIncidentReport = true }) {
                            Label("Report Incident", systemImage: "exclamationmark.triangle")
                        }

                        Button(action: exportSafetyReport) {
                            Label("Export Safety Report", systemImage: "doc.text")
                        }

                        Divider()

                        Button(action: refreshData) {
                            Label("Refresh", systemImage: "arrow.clockwise")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(item: $showingAlertDetail) { alert in
                AlertDetailSheet(alert: alert)
            }
            .sheet(isPresented: $showingIncidentReport) {
                IncidentReportSheet()
            }
        }
    }

    // MARK: - Safety Score Card

    private var safetyScoreCard: some View {
        let score = safetyService.calculateSafetyScore(alerts: safetyService.activeAlerts)
        let scoreColor = safetyScoreColor(score)

        return VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Safety Score")
                        .font(.headline)
                    Text("Real-time assessment")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(String(format: "%.0f", score))
                    .font(.system(size: 60, weight: .bold))
                    .foregroundStyle(scoreColor)
            }

            // Score indicator
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.quaternary)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [.red, .orange, .yellow, .green],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * (score / 100))
                }
            }
            .frame(height: 20)

            // Quick indicators
            HStack(spacing: 16) {
                ScoreIndicator(
                    label: "Active Alerts",
                    value: safetyService.activeAlerts.count,
                    icon: "exclamationmark.triangle.fill",
                    color: .orange
                )

                ScoreIndicator(
                    label: "Critical",
                    value: safetyService.activeAlerts.filter { $0.severity == .critical }.count,
                    icon: "exclamationmark.octagon.fill",
                    color: .red
                )

                ScoreIndicator(
                    label: "Days Since Incident",
                    value: daysSinceLastIncident(),
                    icon: "calendar.badge.checkmark",
                    color: .green
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
                .shadow(color: scoreColor.opacity(0.3), radius: 10)
        )
    }

    // MARK: - Active Alerts Section

    private var activeAlertsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Active Alerts", systemImage: "bell.badge.fill")
                    .font(.headline)
                    .foregroundStyle(safetyService.activeAlerts.isEmpty ? .primary : .orange)

                Spacer()

                if !safetyService.activeAlerts.isEmpty {
                    Text("\(safetyService.activeAlerts.count)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.orange, in: Capsule())
                        .foregroundStyle(.white)
                }
            }

            if safetyService.activeAlerts.isEmpty {
                HStack {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.green)

                    VStack(alignment: .leading) {
                        Text("All Clear")
                            .font(.headline)
                        Text("No active safety alerts")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
                .padding()
                .background(.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
            } else {
                ForEach(safetyService.activeAlerts.sorted(by: { $0.severity > $1.severity })) { alert in
                    AlertRow(alert: alert)
                        .onTapGesture {
                            showingAlertDetail = alert
                        }
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Time Range Filter

    private var timeRangeFilter: some View {
        Picker("Time Range", selection: $selectedTimeRange) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }

    // MARK: - Metrics Section

    private var metricsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Safety Metrics")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                MetricCard(
                    title: "Total Alerts",
                    value: "\(filteredAlerts().count)",
                    icon: "bell.fill",
                    color: .blue,
                    trend: calculateTrend(for: filteredAlerts())
                )

                MetricCard(
                    title: "Avg Response Time",
                    value: formatResponseTime(averageResponseTime()),
                    icon: "clock.fill",
                    color: .orange,
                    trend: nil
                )

                MetricCard(
                    title: "Resolved",
                    value: "\(resolvedCount())",
                    icon: "checkmark.circle.fill",
                    color: .green,
                    trend: nil
                )

                MetricCard(
                    title: "Compliance Rate",
                    value: String(format: "%.0f%%", complianceRate()),
                    icon: "shield.checkmark.fill",
                    color: .purple,
                    trend: nil
                )
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Alert Trend Chart

    private var alertTrendChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Alert Trends")
                .font(.headline)

            Chart {
                ForEach(alertTrendData(), id: \.date) { dataPoint in
                    BarMark(
                        x: .value("Date", dataPoint.date, unit: .day),
                        y: .value("Alerts", dataPoint.count)
                    )
                    .foregroundStyle(by: .value("Severity", dataPoint.severity.rawValue))
                }
            }
            .frame(height: 200)
            .chartForegroundStyleScale([
                "critical": .red,
                "high": .orange,
                "medium": .yellow,
                "low": .blue
            ])
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisValueLabel(format: .dateTime.month().day())
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Severity Breakdown

    private var severityBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Alerts by Severity")
                .font(.headline)

            ForEach(AlertSeverity.allCases.reversed(), id: \.self) { severity in
                let count = filteredAlerts().filter { $0.severity == severity }.count
                let percentage = filteredAlerts().isEmpty ? 0.0 :
                    Double(count) / Double(filteredAlerts().count)

                HStack {
                    Image(systemName: severity.icon)
                        .foregroundStyle(severity.color)

                    Text(severity.rawValue.capitalized)
                        .font(.subheadline)

                    Spacer()

                    Text("\(count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(String(format: "%.0f%%", percentage * 100))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(width: 50, alignment: .trailing)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.quaternary)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(severity.color)
                            .frame(width: geometry.size.width * percentage)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Recent Incidents Section

    private var recentIncidentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Recent Incidents", systemImage: "list.bullet.clipboard")
                    .font(.headline)

                Spacer()

                Button("View All") {
                    // Navigate to full incidents list
                }
                .font(.caption)
            }

            // This would pull from a SafetyIncident model if available
            // For now, showing placeholder
            ForEach(0..<3, id: \.self) { _ in
                HStack {
                    Image(systemName: "doc.text.fill")
                        .foregroundStyle(.orange)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Incident Report")
                            .font(.subheadline)
                        Text("2 days ago")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Compliance Section

    private var complianceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Compliance Status")
                .font(.headline)

            VStack(spacing: 12) {
                ComplianceRow(
                    title: "PPE Requirements",
                    status: .compliant,
                    lastCheck: Date().addingTimeInterval(-3600)
                )

                ComplianceRow(
                    title: "Safety Training",
                    status: .compliant,
                    lastCheck: Date().addingTimeInterval(-86400)
                )

                ComplianceRow(
                    title: "Equipment Inspections",
                    status: .warning,
                    lastCheck: Date().addingTimeInterval(-172800)
                )

                ComplianceRow(
                    title: "Emergency Drills",
                    status: .overdue,
                    lastCheck: Date().addingTimeInterval(-604800)
                )
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Danger Zones Section

    private var dangerZonesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Danger Zones", systemImage: "triangle.fill")
                    .font(.headline)
                    .foregroundStyle(.red)

                Spacer()

                Button("View in 3D") {
                    // Navigate to 3D view
                }
                .buttonStyle(.bordered)
            }

            // Get danger zones from the first site (or allow selection)
            if let firstSite = sites.first {
                let dangerZones = firstSite.projects.flatMap { $0.dangerZones }

                if dangerZones.isEmpty {
                    Text("No danger zones defined")
                        .foregroundStyle(.secondary)
                        .italic()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    ForEach(dangerZones) { zone in
                        DangerZoneRow(zone: zone)
                    }
                }
            } else {
                Text("No sites available")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Helper Functions

    private func safetyScoreColor(_ score: Double) -> Color {
        switch score {
        case 90...100: return .green
        case 70..<90: return .yellow
        case 50..<70: return .orange
        default: return .red
        }
    }

    private func daysSinceLastIncident() -> Int {
        // Placeholder - would pull from incident history
        return 45
    }

    private func filteredAlerts() -> [SafetyAlert] {
        // In real implementation, would filter by selectedTimeRange
        safetyService.activeAlerts
    }

    private func calculateTrend(for alerts: [SafetyAlert]) -> String? {
        // Placeholder - would compare with previous period
        return nil
    }

    private func averageResponseTime() -> TimeInterval {
        let resolvedAlerts = safetyService.activeAlerts.filter { $0.resolvedDate != nil }
        guard !resolvedAlerts.isEmpty else { return 0 }

        let totalTime = resolvedAlerts.reduce(0.0) { sum, alert in
            guard let resolved = alert.resolvedDate else { return sum }
            return sum + resolved.timeIntervalSince(alert.createdDate)
        }

        return totalTime / Double(resolvedAlerts.count)
    }

    private func formatResponseTime(_ interval: TimeInterval) -> String {
        let hours = Int(interval / 3600)
        let minutes = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)
        return "\(hours)h \(minutes)m"
    }

    private func resolvedCount() -> Int {
        safetyService.activeAlerts.filter { $0.resolvedDate != nil }.count
    }

    private func complianceRate() -> Double {
        // Placeholder - would calculate from compliance checks
        return 87.5
    }

    private func alertTrendData() -> [AlertTrendDataPoint] {
        // Placeholder - would aggregate alerts by date
        []
    }

    private func refreshData() {
        // Reload data from services
    }

    private func exportSafetyReport() {
        // Generate PDF safety report
    }
}

// MARK: - Supporting Types

struct AlertTrendDataPoint {
    let date: Date
    let count: Int
    let severity: AlertSeverity
}

// MARK: - Supporting Views

struct ScoreIndicator: View {
    let label: String
    let value: Int
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(color)

            Text("\(value)")
                .font(.title3)
                .fontWeight(.bold)

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct AlertRow: View {
    let alert: SafetyAlert

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: alert.severity.icon)
                .font(.title3)
                .foregroundStyle(alert.severity.color)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(alert.type.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(alert.message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                Text(alert.createdDate, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if alert.resolvedDate == nil {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
        .padding()
        .background(alert.severity.color.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let trend: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Spacer()
                if let trend = trend {
                    Text(trend)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Text(value)
                .font(.title)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

struct ComplianceRow: View {
    enum Status {
        case compliant, warning, overdue

        var color: Color {
            switch self {
            case .compliant: return .green
            case .warning: return .orange
            case .overdue: return .red
            }
        }

        var icon: String {
            switch self {
            case .compliant: return "checkmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .overdue: return "xmark.circle.fill"
            }
        }
    }

    let title: String
    let status: Status
    let lastCheck: Date

    var body: some View {
        HStack {
            Image(systemName: status.icon)
                .foregroundStyle(status.color)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)

                Text("Last check: \(lastCheck, style: .relative)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct DangerZoneRow: View {
    let zone: DangerZone

    var body: some View {
        HStack {
            Image(systemName: zone.type.icon)
                .foregroundStyle(zone.severity.color)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(zone.name)
                    .font(.subheadline)

                HStack(spacing: 4) {
                    Text(zone.type.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                        .font(.caption)

                    Text("•")
                        .font(.caption)

                    Text(zone.isCurrentlyActive ? "Active" : "Inactive")
                        .font(.caption)
                        .foregroundStyle(zone.isCurrentlyActive ? .green : .secondary)
                }
                .foregroundStyle(.secondary)
            }

            Spacer()

            if zone.isCurrentlyActive {
                Circle()
                    .fill(zone.severity.color)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 8)
    }
}

struct AlertDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let alert: SafetyAlert

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Severity badge
                    HStack {
                        Image(systemName: alert.severity.icon)
                            .font(.title)
                            .foregroundStyle(alert.severity.color)

                        VStack(alignment: .leading) {
                            Text(alert.severity.rawValue.capitalized)
                                .font(.headline)
                            Text(alert.type.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(alert.severity.color.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))

                    // Details
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Description")
                            .font(.headline)

                        Text(alert.message)
                            .font(.body)
                    }

                    // Timestamps
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Created:")
                            Spacer()
                            Text(alert.createdDate, style: .date)
                                .foregroundStyle(.secondary)
                        }

                        if let resolved = alert.resolvedDate {
                            HStack {
                                Text("Resolved:")
                                Spacer()
                                Text(resolved, style: .date)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .font(.subheadline)

                    // Actions
                    if alert.resolvedDate == nil {
                        Button(action: {}) {
                            Label("Mark as Resolved", systemImage: "checkmark.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
            }
            .navigationTitle("Alert Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct IncidentReportSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var severity: AlertSeverity = .medium

    var body: some View {
        NavigationStack {
            Form {
                Section("Incident Details") {
                    TextField("Title", text: $title)

                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(5...10)

                    Picker("Severity", selection: $severity) {
                        ForEach(AlertSeverity.allCases, id: \.self) { severity in
                            Label(severity.rawValue.capitalized, systemImage: severity.icon)
                                .tag(severity)
                        }
                    }
                }
            }
            .navigationTitle("Report Incident")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        // Submit incident report
                        dismiss()
                    }
                    .disabled(title.isEmpty || description.isEmpty)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var container: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Site.self, configurations: config)

        // Create test data
        let site = Site(
            name: "Test Site",
            address: Address(
                street: "123 Construction Way",
                city: "San Francisco",
                state: "CA",
                zipCode: "94105",
                country: "USA"
            ),
            gpsLatitude: 37.7749,
            gpsLongitude: -122.4194
        )

        let project = Project(
            name: "Building A",
            projectType: .commercial,
            scheduledEndDate: Date().addingTimeInterval(86400 * 365)
        )

        // Note: DangerZone would need to be added to Site or a separate container
        // since Project doesn't have a dangerZones relationship
        // let zone = DangerZone(...)

        site.projects.append(project)
        container.mainContext.insert(site)

        return container
    }()

    // Note: Cannot set activeAlerts directly in preview as setter is private
    // In actual use, SafetyMonitoringService would populate alerts dynamically

    SafetyDashboardView()
        .modelContainer(container)
}
