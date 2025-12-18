import SwiftUI
import SwiftData
import Charts

struct EnergyDashboardView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    @State private var energyManager: EnergyManager?
    @State private var currentElectricReading: EnergyReading?
    @State private var currentSolarReading: EnergyReading?
    @State private var todayCost: Double = 0.0
    @State private var weekCost: Double = 0.0
    @State private var topConsumers: [(name: String, power: Double)] = []
    @State private var activeAnomalies: [EnergyAnomaly] = []
    @State private var dailyData: [(date: Date, consumption: Double, cost: Double)] = []

    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showConfiguration = false
    @State private var selectedTimeRange: TimeRange = .today

    @Query private var energyConfigurations: [EnergyConfiguration]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection

                // Current Status Cards
                if !isLoading {
                    currentStatusSection
                }

                // Cost Summary
                if !isLoading {
                    costSummarySection
                }

                // Charts
                if !dailyData.isEmpty {
                    consumptionChartSection
                }

                // Top Consumers
                if !topConsumers.isEmpty {
                    topConsumersSection
                }

                // Anomalies
                if !activeAnomalies.isEmpty {
                    anomaliesSection
                }
            }
            .padding()
        }
        .navigationTitle("Energy Monitoring")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showConfiguration = true
                } label: {
                    Label("Settings", systemImage: "gear")
                }
            }
        }
        .sheet(isPresented: $showConfiguration) {
            EnergyConfigurationView()
        }
        .task {
            await loadEnergyData()
        }
        .refreshable {
            await refreshData()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Energy Monitoring")
                .font(.largeTitle)
                .fontWeight(.bold)

            if let config = energyConfigurations.first, config.isConfigured {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Connected to smart meter")
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline)
            } else {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Text("Energy monitoring not configured")
                        .foregroundStyle(.secondary)
                    Button("Configure") {
                        showConfiguration = true
                    }
                    .buttonStyle(.bordered)
                }
                .font(.subheadline)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Current Status

    private var currentStatusSection: some View {
        HStack(spacing: 16) {
            // Electricity
            EnergyStatusCard(
                title: "Electricity",
                icon: "bolt.fill",
                color: .yellow,
                power: currentElectricReading?.instantaneousPower,
                unit: "kW",
                subtitle: "Current usage"
            )

            // Solar (if configured)
            if let solarReading = currentSolarReading, solarReading.instantaneousGeneration ?? 0 > 0 {
                EnergyStatusCard(
                    title: "Solar",
                    icon: "sun.max.fill",
                    color: .orange,
                    power: solarReading.instantaneousGeneration,
                    unit: "kW",
                    subtitle: "Generating"
                )
            }

            // Net Power
            if let electric = currentElectricReading?.instantaneousPower,
               let solar = currentSolarReading?.instantaneousGeneration {
                let net = solar - electric
                EnergyStatusCard(
                    title: "Net",
                    icon: net >= 0 ? "arrow.down.circle.fill" : "arrow.up.circle.fill",
                    color: net >= 0 ? .green : .red,
                    power: abs(net),
                    unit: "kW",
                    subtitle: net >= 0 ? "To grid" : "From grid"
                )
            }
        }
    }

    // MARK: - Cost Summary

    private var costSummarySection: some View {
        GroupBox {
            HStack(spacing: 32) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("$\(todayCost, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.bold)
                }

                Divider()

                VStack(alignment: .leading, spacing: 4) {
                    Text("This Week")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("$\(weekCost, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.bold)
                }

                Spacer()

                if let config = energyConfigurations.first {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Rate")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("$\(config.electricityRatePerKWh, specifier: "%.3f")/kWh")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.vertical, 8)
        } label: {
            Label("Cost Summary", systemImage: "dollarsign.circle.fill")
        }
    }

    // MARK: - Chart

    private var consumptionChartSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Picker("Time Range", selection: $selectedTimeRange) {
                    Text("Today").tag(TimeRange.today)
                    Text("Week").tag(TimeRange.week)
                }
                .pickerStyle(.segmented)

                if dailyData.isEmpty {
                    Text("No data available")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    Chart(dailyData, id: \.date) { item in
                        BarMark(
                            x: .value("Date", item.date, unit: .day),
                            y: .value("Consumption", item.consumption)
                        )
                        .foregroundStyle(.blue.gradient)
                    }
                    .frame(height: 200)
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                }
            }
        } label: {
            Label("Consumption Trends", systemImage: "chart.bar.fill")
        }
        .onChange(of: selectedTimeRange) { _, _ in
            Task {
                await loadChartData()
            }
        }
    }

    // MARK: - Top Consumers

    private var topConsumersSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(topConsumers, id: \.name) { consumer in
                    HStack {
                        Circle()
                            .fill(.blue)
                            .frame(width: 8, height: 8)

                        Text(consumer.name)
                            .font(.subheadline)

                        Spacer()

                        Text("\(consumer.power, specifier: "%.2f") kW")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        // Progress bar
                        GeometryReader { geometry in
                            let maxPower = topConsumers.first?.power ?? 1.0
                            let percentage = consumer.power / maxPower

                            RoundedRectangle(cornerRadius: 2)
                                .fill(.blue.opacity(0.3))
                                .overlay(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(.blue)
                                        .frame(width: geometry.size.width * percentage)
                                }
                        }
                        .frame(width: 60, height: 6)
                    }
                }
            }
        } label: {
            Label("Top Consumers", systemImage: "flame.fill")
        }
    }

    // MARK: - Anomalies

    private var anomaliesSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(activeAnomalies) { anomaly in
                    AnomalyRow(anomaly: anomaly) {
                        dismissAnomaly(anomaly)
                    }
                }
            }
        } label: {
            Label("Alerts (\(activeAnomalies.count))", systemImage: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
        }
    }

    // MARK: - Data Loading

    private func loadEnergyData() async {
        isLoading = true
        errorMessage = nil

        do {
            // Get or create energy configuration
            let config = try getOrCreateEnergyConfiguration()

            // Initialize energy manager
            let service = EnergyService()
            let manager = EnergyManager(
                appState: appState,
                energyService: service,
                modelContext: modelContext
            )
            self.energyManager = manager

            // Connect if configured
            if config.isConfigured {
                try await manager.connect(configuration: config)

                // Load current readings
                currentElectricReading = try await manager.getCurrentElectricReading()

                if config.hasSolar {
                    currentSolarReading = try await manager.getCurrentSolarReading()
                }

                // Load costs
                todayCost = try await manager.calculateTodayCost(configuration: config)
                weekCost = try await manager.calculateWeeklyCost(configuration: config)

                // Load top consumers
                topConsumers = try await manager.getTopConsumers(limit: 5)

                // Load anomalies
                activeAnomalies = try manager.getActiveAnomalies()

                // Load chart data
                await loadChartData()
            }

            isLoading = false
        } catch {
            errorMessage = "Failed to load energy data: \(error.localizedDescription)"
            isLoading = false
            Logger.shared.log("Failed to load energy data: \(error)", category: "EnergyDashboard", type: .error)
        }
    }

    private func refreshData() async {
        await loadEnergyData()
    }

    private func loadChartData() async {
        guard let manager = energyManager else { return }

        do {
            let days = selectedTimeRange == .today ? 1 : 7
            dailyData = try await manager.getDailyAggregates(type: .electricity, days: days)
        } catch {
            Logger.shared.log("Failed to load chart data: \(error)", category: "EnergyDashboard", type: .error)
        }
    }

    private func dismissAnomaly(_ anomaly: EnergyAnomaly) {
        energyManager?.dismissAnomaly(anomaly)
        activeAnomalies.removeAll { $0.id == anomaly.id }
    }

    private func getOrCreateEnergyConfiguration() throws -> EnergyConfiguration {
        if let existing = energyConfigurations.first {
            return existing
        }

        let config = EnergyConfiguration()
        modelContext.insert(config)
        try modelContext.save()
        return config
    }

    enum TimeRange {
        case today
        case week
    }
}

// MARK: - Energy Status Card

struct EnergyStatusCard: View {
    let title: String
    let icon: String
    let color: Color
    let power: Double?
    let unit: String
    let subtitle: String

    var body: some View {
        GroupBox {
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .foregroundStyle(color)
                        .font(.title2)

                    Spacer()

                    Text(title)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    if let power = power {
                        Text("\(power, specifier: "%.2f")")
                            .font(.title)
                            .fontWeight(.bold)
                        + Text(" \(unit)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("--")
                            .font(.title)
                            .foregroundStyle(.secondary)
                    }

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

// MARK: - Anomaly Row

struct AnomalyRow: View {
    let anomaly: EnergyAnomaly
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: anomaly.severity.icon)
                .foregroundStyle(Color(anomaly.severity.color))
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                Text(anomaly.anomalyType.rawValue.capitalized)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(anomaly.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(anomaly.detectedAt, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Energy Configuration View

struct EnergyConfigurationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query private var configurations: [EnergyConfiguration]

    @State private var hasSmartMeter = false
    @State private var hasSolar = false
    @State private var hasBattery = false
    @State private var electricityRate = 0.15
    @State private var gasRate = 1.5
    @State private var waterRate = 0.006
    @State private var meterAPIIdentifier = "sim-meter-001"

    var body: some View {
        NavigationStack {
            Form {
                Section("Energy Sources") {
                    Toggle("Smart Meter", isOn: $hasSmartMeter)
                    Toggle("Solar Panels", isOn: $hasSolar)
                    Toggle("Battery Storage", isOn: $hasBattery)
                }

                if hasSmartMeter {
                    Section("Meter Configuration") {
                        TextField("API Identifier", text: $meterAPIIdentifier)
                            .textContentType(.none)
                            .autocorrectionDisabled()
                    }
                }

                Section("Utility Rates") {
                    HStack {
                        Text("Electricity")
                        Spacer()
                        TextField("Rate", value: $electricityRate, format: .number.precision(.fractionLength(3)))
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("$/kWh")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Gas")
                        Spacer()
                        TextField("Rate", value: $gasRate, format: .number.precision(.fractionLength(3)))
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("$/therm")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Water")
                        Spacer()
                        TextField("Rate", value: $waterRate, format: .number.precision(.fractionLength(3)))
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("$/gal")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Energy Configuration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveConfiguration()
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadConfiguration()
            }
        }
    }

    private func loadConfiguration() {
        guard let config = configurations.first else { return }

        hasSmartMeter = config.hasSmartMeter
        hasSolar = config.hasSolar
        hasBattery = config.hasBattery
        electricityRate = config.electricityRatePerKWh
        gasRate = config.gasRatePerTherm ?? 1.5
        waterRate = config.waterRatePerGallon
        meterAPIIdentifier = config.meterAPIIdentifier ?? "sim-meter-001"
    }

    private func saveConfiguration() {
        let config = configurations.first ?? EnergyConfiguration()

        config.hasSmartMeter = hasSmartMeter
        config.hasSolar = hasSolar
        config.hasBattery = hasBattery
        config.electricityRatePerKWh = electricityRate
        config.gasRatePerTherm = gasRate
        config.waterRatePerGallon = waterRate
        config.meterAPIIdentifier = hasSmartMeter ? meterAPIIdentifier : nil
        config.updatedAt = Date()

        if configurations.isEmpty {
            modelContext.insert(config)
        }

        try? modelContext.save()
        Logger.shared.log("Energy configuration saved", category: "EnergyConfiguration")
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        EnergyDashboardView()
            .environment(AppState())
            .modelContainer(for: [
                Home.self,
                Room.self,
                SmartDevice.self,
                DeviceState.self,
                User.self,
                UserPreferences.self,
                RoomAnchor.self,
                EnergyConfiguration.self,
                EnergyReading.self,
                EnergyAnomaly.self
            ], inMemory: true)
    }
}
