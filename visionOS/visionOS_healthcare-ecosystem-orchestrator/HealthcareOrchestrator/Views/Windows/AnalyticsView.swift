import SwiftUI
import SwiftData
import Charts

struct AnalyticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var patients: [Patient]

    @State private var selectedTimeRange: TimeRange = .week
    @State private var selectedMetric: HealthcareMetric = .patientVolume

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    header

                    // Key Metrics
                    keyMetricsSection

                    // Charts Section
                    chartsSection

                    // Department Comparison
                    departmentSection

                    // Quality Metrics
                    qualityMetricsSection
                }
                .padding()
            }
            .navigationTitle("Analytics Dashboard")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    timeRangeMenu
                }
            }
        }
    }

    // MARK: - Header
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Population Health Analytics")
                .font(.title.bold())

            Text("Data updated \(Date.now.formatted(date: .omitted, time: .shortened))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Key Metrics Section
    private var keyMetricsSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            MetricCard(
                title: "Total Patients",
                value: "\(patients.count)",
                change: "+5.2%",
                isPositive: true,
                icon: "person.3.fill",
                color: .blue
            )

            MetricCard(
                title: "Average LOS",
                value: "4.2 days",
                change: "-8%",
                isPositive: true,
                icon: "clock.fill",
                color: .green
            )

            MetricCard(
                title: "Readmission Rate",
                value: "8.5%",
                change: "-12%",
                isPositive: true,
                icon: "arrow.uturn.left.circle.fill",
                color: .orange
            )

            MetricCard(
                title: "Patient Satisfaction",
                value: "92%",
                change: "+3%",
                isPositive: true,
                icon: "star.fill",
                color: .mint
            )
        }
    }

    // MARK: - Charts Section
    private var chartsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Trends")
                .font(.headline)

            HStack(spacing: 12) {
                ForEach(HealthcareMetric.allCases) { metric in
                    Button {
                        selectedMetric = metric
                    } label: {
                        Text(metric.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedMetric == metric ? Color.accentColor : Color.clear)
                            .foregroundStyle(selectedMetric == metric ? .white : .primary)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }

            // Chart
            chartView
                .frame(height: 300)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Chart View
    private var chartView: some View {
        Chart(sampleData) { dataPoint in
            LineMark(
                x: .value("Time", dataPoint.date),
                y: .value("Value", dataPoint.value)
            )
            .foregroundStyle(.blue)
            .interpolationMethod(.catmullRom)

            AreaMark(
                x: .value("Time", dataPoint.date),
                y: .value("Value", dataPoint.value)
            )
            .foregroundStyle(.blue.opacity(0.2))
            .interpolationMethod(.catmullRom)
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel()
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel()
            }
        }
    }

    // MARK: - Department Section
    private var departmentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Department Performance")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                DepartmentCard(name: "Emergency", patients: 32, capacity: 40, utilization: 0.8)
                DepartmentCard(name: "ICU", patients: 18, capacity: 20, utilization: 0.9)
                DepartmentCard(name: "Medical", patients: 156, capacity: 200, utilization: 0.78)
                DepartmentCard(name: "Surgical", patients: 89, capacity: 120, utilization: 0.74)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Quality Metrics Section
    private var qualityMetricsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quality Indicators")
                .font(.headline)

            QualityIndicatorRow(
                title: "Clinical Quality Score",
                value: 92,
                target: 90,
                unit: "%"
            )

            QualityIndicatorRow(
                title: "Patient Safety Index",
                value: 88,
                target: 85,
                unit: "%"
            )

            QualityIndicatorRow(
                title: "Care Coordination",
                value: 95,
                target: 90,
                unit: "%"
            )

            QualityIndicatorRow(
                title: "Documentation Completeness",
                value: 96,
                target: 95,
                unit: "%"
            )
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Time Range Menu
    private var timeRangeMenu: some View {
        Menu {
            ForEach(TimeRange.allCases) { range in
                Button(range.rawValue) {
                    selectedTimeRange = range
                }
            }
        } label: {
            Label(selectedTimeRange.rawValue, systemImage: "calendar")
        }
    }

    // MARK: - Sample Data
    private var sampleData: [DataPoint] {
        let calendar = Calendar.current
        let now = Date()

        return (0..<30).map { day in
            let date = calendar.date(byAdding: .day, value: -day, to: now)!
            let value = Double.random(in: 200...300) + sin(Double(day) * 0.5) * 20
            return DataPoint(date: date, value: value)
        }.reversed()
    }
}

// MARK: - Supporting Views

struct MetricCard: View {
    let title: String
    let value: String
    let change: String
    let isPositive: Bool
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                    Text(change)
                }
                .font(.caption)
                .foregroundStyle(isPositive ? .green : .red)
            }

            Text(value)
                .font(.system(size: 28, weight: .bold))

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct DepartmentCard: View {
    let name: String
    let patients: Int
    let capacity: Int
    let utilization: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(name)
                .font(.headline)

            HStack {
                Text("\(patients)/\(capacity)")
                    .font(.title3.bold())
                Spacer()
                Text("\(Int(utilization * 100))%")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: utilization)
                .tint(utilizationColor)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var utilizationColor: Color {
        if utilization > 0.9 { return .red }
        if utilization > 0.75 { return .orange }
        return .green
    }
}

struct QualityIndicatorRow: View {
    let title: String
    let value: Int
    let target: Int
    let unit: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                Spacer()
                Text("\(value)\(unit)")
                    .font(.headline)
                    .foregroundStyle(value >= target ? .green : .orange)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(.tertiary)
                        .frame(height: 8)

                    Rectangle()
                        .fill(value >= target ? Color.green : Color.orange)
                        .frame(width: geometry.size.width * Double(value) / 100, height: 8)

                    // Target line
                    Rectangle()
                        .fill(.white)
                        .frame(width: 2, height: 12)
                        .offset(x: geometry.size.width * Double(target) / 100)
                }
            }
            .frame(height: 12)
            .clipShape(Capsule())
        }
    }
}

// MARK: - Supporting Types

enum TimeRange: String, CaseIterable, Identifiable {
    case day = "24 Hours"
    case week = "7 Days"
    case month = "30 Days"
    case quarter = "90 Days"

    var id: String { rawValue }
}

enum HealthcareMetric: String, CaseIterable, Identifiable {
    case patientVolume = "Volume"
    case lengthOfStay = "LOS"
    case readmissions = "Readmissions"
    case satisfaction = "Satisfaction"

    var id: String { rawValue }
}

struct DataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

// MARK: - Previews
#Preview {
    AnalyticsView()
        .modelContainer(for: Patient.self, inMemory: true)
}
