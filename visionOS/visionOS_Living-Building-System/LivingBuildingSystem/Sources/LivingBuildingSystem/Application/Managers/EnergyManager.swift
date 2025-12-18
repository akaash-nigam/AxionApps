import Foundation
import SwiftData

/// Manages energy monitoring, data aggregation, and analysis
@MainActor
class EnergyManager {
    private let appState: AppState
    private let energyService: any EnergyServiceProtocol
    private let modelContext: ModelContext

    // Current readings cache
    private var latestElectricReading: EnergyReading?
    private var latestSolarReading: EnergyReading?
    private var latestGasReading: EnergyReading?
    private var latestWaterReading: EnergyReading?

    init(appState: AppState, energyService: any EnergyServiceProtocol, modelContext: ModelContext) {
        self.appState = appState
        self.energyService = energyService
        self.modelContext = modelContext
    }

    // MARK: - Connection

    func connect(configuration: EnergyConfiguration) async throws {
        guard configuration.isConfigured else {
            throw LBSError.configurationError(message: "Energy configuration not set up")
        }

        guard let apiIdentifier = configuration.meterAPIIdentifier else {
            throw LBSError.configurationError(message: "Energy meter API identifier missing")
        }

        try await energyService.connect(apiIdentifier: apiIdentifier)
        Logger.shared.log("Energy manager connected", category: "EnergyManager")

        // Configure service based on configuration
        if configuration.hasSolar {
            await (energyService as? EnergyService)?.configureSolar(baselineKW: 5.0)
        }

        // Setup real-time monitoring
        await setupMonitoring(configuration: configuration)
    }

    func disconnect() async {
        await energyService.stopMonitoring()
        await energyService.disconnect()
        Logger.shared.log("Energy manager disconnected", category: "EnergyManager")
    }

    // MARK: - Monitoring

    private func setupMonitoring(configuration: EnergyConfiguration) async {
        await energyService.setUpdateHandler { [weak self] reading in
            Task { @MainActor in
                self?.handleEnergyUpdate(reading, configuration: configuration)
            }
        }

        do {
            try await energyService.startMonitoring()
            Logger.shared.log("Energy monitoring started", category: "EnergyManager")
        } catch {
            Logger.shared.log("Failed to start energy monitoring: \(error)", category: "EnergyManager", type: .error)
        }
    }

    private func handleEnergyUpdate(_ reading: EnergyReading, configuration: EnergyConfiguration) {
        // Update cache
        switch reading.energyType {
        case .electricity:
            latestElectricReading = reading
        case .solar:
            latestSolarReading = reading
        case .gas:
            latestGasReading = reading
        case .water:
            latestWaterReading = reading
        }

        // Save to persistence
        modelContext.insert(reading)

        // Check for anomalies on electricity readings
        if reading.energyType == .electricity {
            Task {
                await detectAndSaveAnomalies(for: reading, configuration: configuration)
            }
        }

        Logger.shared.log("Energy reading updated: \(reading.energyType.rawValue) - \(reading.instantaneousPower ?? 0)kW", category: "EnergyManager")
    }

    // MARK: - Current Data

    func getCurrentElectricReading() async throws -> EnergyReading {
        if let cached = latestElectricReading,
           Date().timeIntervalSince(cached.timestamp) < 10 {
            return cached
        }

        let reading = try await energyService.getCurrentReading(type: .electricity)
        latestElectricReading = reading
        return reading
    }

    func getCurrentSolarReading() async throws -> EnergyReading? {
        if let cached = latestSolarReading,
           Date().timeIntervalSince(cached.timestamp) < 10 {
            return cached
        }

        let reading = try await energyService.getCurrentReading(type: .solar)
        latestSolarReading = reading
        return reading
    }

    func getCurrentGasReading() async throws -> EnergyReading {
        if let cached = latestGasReading,
           Date().timeIntervalSince(cached.timestamp) < 10 {
            return cached
        }

        let reading = try await energyService.getCurrentReading(type: .gas)
        latestGasReading = reading
        return reading
    }

    func getCurrentWaterReading() async throws -> EnergyReading {
        if let cached = latestWaterReading,
           Date().timeIntervalSince(cached.timestamp) < 10 {
            return cached
        }

        let reading = try await energyService.getCurrentReading(type: .water)
        latestWaterReading = reading
        return reading
    }

    // MARK: - Historical Data

    func getHistoricalReadings(
        type: EnergyType,
        startDate: Date,
        endDate: Date
    ) async throws -> [EnergyReading] {
        // Try to fetch from persistence first
        let descriptor = FetchDescriptor<EnergyReading>(
            predicate: #Predicate<EnergyReading> { reading in
                reading.energyType == type &&
                reading.timestamp >= startDate &&
                reading.timestamp <= endDate
            },
            sortBy: [SortDescriptor(\.timestamp, order: .forward)]
        )

        let persistedReadings = try modelContext.fetch(descriptor)

        if !persistedReadings.isEmpty {
            Logger.shared.log("Retrieved \(persistedReadings.count) readings from persistence", category: "EnergyManager")
            return persistedReadings
        }

        // Fetch from service if not in persistence
        let readings = try await energyService.getHistoricalReadings(
            type: type,
            startDate: startDate,
            endDate: endDate
        )

        // Save to persistence
        readings.forEach { modelContext.insert($0) }
        try modelContext.save()

        Logger.shared.log("Fetched and saved \(readings.count) historical readings", category: "EnergyManager")
        return readings
    }

    func getTodayReadings(type: EnergyType) async throws -> [EnergyReading] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        return try await getHistoricalReadings(
            type: type,
            startDate: startOfDay,
            endDate: endOfDay
        )
    }

    func getWeekReadings(type: EnergyType) async throws -> [EnergyReading] {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(byAdding: .day, value: -7, to: Date())!

        return try await getHistoricalReadings(
            type: type,
            startDate: startOfWeek,
            endDate: Date()
        )
    }

    // MARK: - Cost Calculations

    func calculateTodayCost(configuration: EnergyConfiguration) async throws -> Double {
        let electricReadings = try await getTodayReadings(type: .electricity)
        let gasReadings = try await getTodayReadings(type: .gas)
        let waterReadings = try await getTodayReadings(type: .water)

        let electricCost = electricReadings.last?.calculateCost(configuration: configuration) ?? 0
        let gasCost = gasReadings.last?.calculateCost(configuration: configuration) ?? 0
        let waterCost = waterReadings.last?.calculateCost(configuration: configuration) ?? 0

        return electricCost + gasCost + waterCost
    }

    func calculateWeeklyCost(configuration: EnergyConfiguration) async throws -> Double {
        let calendar = Calendar.current
        var totalCost: Double = 0

        for dayOffset in 0..<7 {
            guard let dayStart = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else { continue }
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: dayStart))!

            let electricReadings = try await getHistoricalReadings(type: .electricity, startDate: calendar.startOfDay(for: dayStart), endDate: dayEnd)
            let gasReadings = try await getHistoricalReadings(type: .gas, startDate: calendar.startOfDay(for: dayStart), endDate: dayEnd)
            let waterReadings = try await getHistoricalReadings(type: .water, startDate: calendar.startOfDay(for: dayStart), endDate: dayEnd)

            if let lastElectric = electricReadings.last {
                totalCost += lastElectric.calculateCost(configuration: configuration)
            }
            if let lastGas = gasReadings.last {
                totalCost += lastGas.calculateCost(configuration: configuration)
            }
            if let lastWater = waterReadings.last {
                totalCost += lastWater.calculateCost(configuration: configuration)
            }
        }

        return totalCost
    }

    // MARK: - Aggregation

    func getTopConsumers(limit: Int = 5) async throws -> [(name: String, power: Double)] {
        guard let electricReading = latestElectricReading,
              let breakdown = electricReading.circuitBreakdown else {
            return []
        }

        return breakdown.map { (name: $0.key, power: $0.value) }
            .sorted { $0.power > $1.power }
            .prefix(limit)
            .map { $0 }
    }

    func getDailyAggregates(type: EnergyType, days: Int = 7) async throws -> [(date: Date, consumption: Double, cost: Double)] {
        let calendar = Calendar.current
        var aggregates: [(date: Date, consumption: Double, cost: Double)] = []

        for dayOffset in 0..<days {
            guard let dayStart = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else { continue }
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: dayStart))!

            let readings = try await getHistoricalReadings(
                type: type,
                startDate: calendar.startOfDay(for: dayStart),
                endDate: dayEnd
            )

            let totalConsumption = readings.compactMap { $0.cumulativeConsumption }.max() ?? 0

            // Get configuration for cost calculation
            let configuration = try fetchEnergyConfiguration()
            let cost = totalConsumption * (type == .electricity ? configuration.electricityRatePerKWh : configuration.waterRatePerGallon)

            aggregates.append((date: dayStart, consumption: totalConsumption, cost: cost))
        }

        return aggregates.reversed()
    }

    // MARK: - Anomaly Detection

    private func detectAndSaveAnomalies(for reading: EnergyReading, configuration: EnergyConfiguration) async {
        do {
            // Get recent readings for anomaly detection
            let recentReadings = try await getHistoricalReadings(
                type: reading.energyType,
                startDate: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!,
                endDate: Date()
            )

            let anomalies = try await energyService.detectAnomalies(
                readings: recentReadings,
                configuration: configuration
            )

            // Save new anomalies
            for anomaly in anomalies {
                // Check if similar anomaly already exists
                let existingDescriptor = FetchDescriptor<EnergyAnomaly>(
                    predicate: #Predicate<EnergyAnomaly> { existing in
                        existing.anomalyType == anomaly.anomalyType &&
                        existing.isDismissed == false &&
                        existing.detectedAt > Calendar.current.date(byAdding: .hour, value: -1, to: Date())!
                    }
                )

                let existingAnomalies = try modelContext.fetch(existingDescriptor)

                if existingAnomalies.isEmpty {
                    modelContext.insert(anomaly)
                    Logger.shared.log("New anomaly detected: \(anomaly.description)", category: "EnergyManager")
                }
            }

            try modelContext.save()
        } catch {
            Logger.shared.log("Failed to detect anomalies: \(error)", category: "EnergyManager", type: .error)
        }
    }

    func getActiveAnomalies() throws -> [EnergyAnomaly] {
        let descriptor = FetchDescriptor<EnergyAnomaly>(
            predicate: #Predicate<EnergyAnomaly> { $0.isDismissed == false },
            sortBy: [SortDescriptor(\.detectedAt, order: .reverse)]
        )

        return try modelContext.fetch(descriptor)
    }

    func dismissAnomaly(_ anomaly: EnergyAnomaly) {
        anomaly.dismiss()
        try? modelContext.save()
        Logger.shared.log("Anomaly dismissed: \(anomaly.id)", category: "EnergyManager")
    }

    // MARK: - Helpers

    private func fetchEnergyConfiguration() throws -> EnergyConfiguration {
        let descriptor = FetchDescriptor<EnergyConfiguration>()
        let configurations = try modelContext.fetch(descriptor)

        guard let configuration = configurations.first else {
            throw LBSError.configurationError(message: "Energy configuration not found")
        }

        return configuration
    }

    // MARK: - Data Cleanup

    func cleanupOldReadings() async throws {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!

        let descriptor = FetchDescriptor<EnergyReading>(
            predicate: #Predicate<EnergyReading> { $0.timestamp < sevenDaysAgo }
        )

        let oldReadings = try modelContext.fetch(descriptor)
        Logger.shared.log("Cleaning up \(oldReadings.count) old energy readings", category: "EnergyManager")

        oldReadings.forEach { modelContext.delete($0) }
        try modelContext.save()
    }
}
