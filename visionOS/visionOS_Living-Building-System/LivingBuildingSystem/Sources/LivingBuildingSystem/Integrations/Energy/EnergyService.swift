import Foundation

/// Concrete implementation of energy monitoring service
/// This is a simulator that generates realistic energy data for development and testing
actor EnergyService: EnergyServiceProtocol {
    private var isMonitoring = false
    private var connected = false
    private var monitoringTask: Task<Void, Never>?
    private var updateHandler: ((EnergyReading) -> Void)?

    // Simulation state
    private var baselineElectric: Double = 2.5 // kW
    private var baselineSolar: Double = 0.0 // kW
    private var cumulativeElectric: Double = 0.0 // kWh
    private var cumulativeSolar: Double = 0.0 // kWh

    func connect(apiIdentifier: String) async throws {
        Logger.shared.log("Connecting to energy meter: \(apiIdentifier)", category: "Energy")

        // Simulate connection delay
        try await Task.sleep(for: .seconds(1))

        connected = true
        Logger.shared.log("Connected to energy meter", category: "Energy")
    }

    func disconnect() async {
        Logger.shared.log("Disconnecting from energy meter", category: "Energy")
        await stopMonitoring()
        connected = false
    }

    func isConnected() async -> Bool {
        return connected
    }

    func startMonitoring() async throws {
        guard connected else {
            throw LBSError.serviceUnavailable(message: "Energy meter not connected")
        }

        guard !isMonitoring else {
            Logger.shared.log("Monitoring already active", category: "Energy")
            return
        }

        isMonitoring = true
        Logger.shared.log("Starting energy monitoring", category: "Energy")

        // Start monitoring task
        monitoringTask = Task {
            while !Task.isCancelled && isMonitoring {
                // Generate and send updates every 5 seconds
                let electricReading = await generateElectricReading()
                updateHandler?(electricReading)

                // If solar is configured, send solar reading
                if baselineSolar > 0 {
                    let solarReading = await generateSolarReading()
                    updateHandler?(solarReading)
                }

                try? await Task.sleep(for: .seconds(5))
            }
        }
    }

    func stopMonitoring() async {
        isMonitoring = false
        monitoringTask?.cancel()
        monitoringTask = nil
        Logger.shared.log("Stopped energy monitoring", category: "Energy")
    }

    func getCurrentReading(type: EnergyType) async throws -> EnergyReading {
        guard connected else {
            throw LBSError.serviceUnavailable(message: "Energy meter not connected")
        }

        switch type {
        case .electricity:
            return await generateElectricReading()
        case .solar:
            return await generateSolarReading()
        case .gas:
            return await generateGasReading()
        case .water:
            return await generateWaterReading()
        }
    }

    func getHistoricalReadings(
        type: EnergyType,
        startDate: Date,
        endDate: Date
    ) async throws -> [EnergyReading] {
        guard connected else {
            throw LBSError.serviceUnavailable(message: "Energy meter not connected")
        }

        Logger.shared.log("Fetching historical readings from \(startDate) to \(endDate)", category: "Energy")

        // Generate historical data
        var readings: [EnergyReading] = []
        let interval: TimeInterval = 3600 // 1 hour
        var currentDate = startDate

        while currentDate <= endDate {
            let reading = EnergyReading(timestamp: currentDate, energyType: type)

            // Simulate usage patterns based on time of day
            let hour = Calendar.current.component(.hour, from: currentDate)
            let isPeakHour = (8...20).contains(hour)

            switch type {
            case .electricity:
                reading.instantaneousPower = baselineElectric + (isPeakHour ? Double.random(in: 1.0...3.0) : Double.random(in: -0.5...0.5))
                reading.cumulativeConsumption = readings.last?.cumulativeConsumption ?? 0.0 + (reading.instantaneousPower ?? 0) * (interval / 3600)

            case .solar:
                // Solar only generates during daylight hours
                let isSunnyHour = (7...18).contains(hour)
                reading.instantaneousGeneration = isSunnyHour ? Double.random(in: 2.0...6.0) : 0.0
                reading.cumulativeGeneration = readings.last?.cumulativeGeneration ?? 0.0 + (reading.instantaneousGeneration ?? 0) * (interval / 3600)

            case .gas:
                reading.instantaneousPower = isPeakHour ? Double.random(in: 0.5...2.0) : Double.random(in: 0.1...0.5)
                reading.cumulativeConsumption = readings.last?.cumulativeConsumption ?? 0.0 + (reading.instantaneousPower ?? 0) * (interval / 3600)

            case .water:
                reading.instantaneousPower = Double.random(in: 0.0...2.0)
                reading.cumulativeConsumption = readings.last?.cumulativeConsumption ?? 0.0 + (reading.instantaneousPower ?? 0) * (interval / 3600)
            }

            readings.append(reading)
            currentDate = currentDate.addingTimeInterval(interval)
        }

        Logger.shared.log("Generated \(readings.count) historical readings", category: "Energy")
        return readings
    }

    func setUpdateHandler(_ handler: @escaping (EnergyReading) -> Void) async {
        self.updateHandler = handler
        Logger.shared.log("Energy update handler registered", category: "Energy")
    }

    func detectAnomalies(
        readings: [EnergyReading],
        configuration: EnergyConfiguration
    ) async throws -> [EnergyAnomaly] {
        var anomalies: [EnergyAnomaly] = []

        guard !readings.isEmpty else { return anomalies }

        // Calculate baseline (average of readings)
        let powers = readings.compactMap { $0.instantaneousPower }
        guard !powers.isEmpty else { return anomalies }

        let average = powers.reduce(0, +) / Double(powers.count)
        let stdDev = calculateStandardDeviation(powers, mean: average)

        // Check each reading for anomalies
        for reading in readings {
            guard let power = reading.instantaneousPower else { continue }

            // Detect spikes (> 2 standard deviations above mean)
            if power > average + (2 * stdDev) {
                let anomaly = EnergyAnomaly(
                    detectedAt: reading.timestamp,
                    anomalyType: .spikage,
                    severity: power > average + (3 * stdDev) ? .high : .medium,
                    energyType: reading.energyType,
                    expectedValue: average,
                    actualValue: power,
                    description: "Power spike detected - \(Int(power))kW (expected ~\(Int(average))kW)"
                )
                anomalies.append(anomaly)
            }

            // Detect unusually high continuous usage
            if power > average * 1.5 {
                let anomaly = EnergyAnomaly(
                    detectedAt: reading.timestamp,
                    anomalyType: .unusuallyHigh,
                    severity: .medium,
                    energyType: reading.energyType,
                    expectedValue: average,
                    actualValue: power,
                    description: "Usage \(Int((power / average - 1) * 100))% higher than normal"
                )
                anomalies.append(anomaly)
            }
        }

        // Detect continuous usage (no significant drops over long period)
        if readings.count > 10 {
            let lastTenPowers = powers.suffix(10)
            let minPower = lastTenPowers.min() ?? 0
            let maxPower = lastTenPowers.max() ?? 0
            let variation = maxPower - minPower

            if variation < 0.5 && average > 0.5 {
                let anomaly = EnergyAnomaly(
                    detectedAt: readings.last?.timestamp ?? Date(),
                    anomalyType: .continuousUsage,
                    severity: .low,
                    energyType: readings.first?.energyType ?? .electricity,
                    expectedValue: 0.0,
                    actualValue: average,
                    description: "Continuous usage detected for extended period (~\(Int(average))kW)"
                )
                anomalies.append(anomaly)
            }
        }

        Logger.shared.log("Detected \(anomalies.count) anomalies", category: "Energy")
        return anomalies
    }

    // MARK: - Private Helpers

    private func generateElectricReading() -> EnergyReading {
        let reading = EnergyReading(timestamp: Date(), energyType: .electricity)

        // Simulate realistic usage patterns
        let hour = Calendar.current.component(.hour, from: Date())
        let isPeakHour = (8...20).contains(hour)

        // Add some randomness to baseline
        let variation = Double.random(in: -0.5...0.5)
        let peakBoost = isPeakHour ? Double.random(in: 1.0...3.0) : 0.0

        reading.instantaneousPower = max(0.5, baselineElectric + variation + peakBoost)
        cumulativeElectric += reading.instantaneousPower! * (5.0 / 3600.0) // 5 seconds in hours
        reading.cumulativeConsumption = cumulativeElectric

        // Simulate circuit breakdown
        reading.circuitBreakdown = [
            "HVAC": reading.instantaneousPower! * 0.4,
            "Kitchen": reading.instantaneousPower! * 0.25,
            "Living Room": reading.instantaneousPower! * 0.15,
            "Bedrooms": reading.instantaneousPower! * 0.1,
            "Other": reading.instantaneousPower! * 0.1
        ]

        return reading
    }

    private func generateSolarReading() -> EnergyReading {
        let reading = EnergyReading(timestamp: Date(), energyType: .solar)

        // Solar only generates during daylight
        let hour = Calendar.current.component(.hour, from: Date())
        let isSunnyHour = (7...18).contains(hour)

        if isSunnyHour {
            // Peak generation around noon
            let distanceFromNoon = abs(12 - hour)
            let efficiency = max(0.3, 1.0 - (Double(distanceFromNoon) / 6.0))

            reading.instantaneousGeneration = baselineSolar * efficiency + Double.random(in: -0.5...0.5)
            cumulativeSolar += reading.instantaneousGeneration! * (5.0 / 3600.0)
            reading.cumulativeGeneration = cumulativeSolar
        } else {
            reading.instantaneousGeneration = 0.0
            reading.cumulativeGeneration = cumulativeSolar
        }

        return reading
    }

    private func generateGasReading() -> EnergyReading {
        let reading = EnergyReading(timestamp: Date(), energyType: .gas)

        // Gas usage is typically for heating/cooking
        let hour = Calendar.current.component(.hour, from: Date())
        let isCookingTime = [6, 7, 8, 17, 18, 19].contains(hour)

        reading.instantaneousPower = isCookingTime ? Double.random(in: 0.5...2.0) : Double.random(in: 0.1...0.5)
        reading.cumulativeConsumption = Double.random(in: 50...200) // Daily therms

        return reading
    }

    private func generateWaterReading() -> EnergyReading {
        let reading = EnergyReading(timestamp: Date(), energyType: .water)

        // Water usage varies throughout day
        let hour = Calendar.current.component(.hour, from: Date())
        let isHighUsageTime = (6...9).contains(hour) || (17...21).contains(hour)

        reading.instantaneousPower = isHighUsageTime ? Double.random(in: 0.5...3.0) : Double.random(in: 0.0...0.5)
        reading.cumulativeConsumption = Double.random(in: 50...300) // Daily gallons

        return reading
    }

    private func calculateStandardDeviation(_ values: [Double], mean: Double) -> Double {
        guard !values.isEmpty else { return 0 }

        let squaredDifferences = values.map { pow($0 - mean, 2) }
        let variance = squaredDifferences.reduce(0, +) / Double(values.count)
        return sqrt(variance)
    }

    // MARK: - Configuration

    /// Configure solar generation capacity (for simulation)
    func configureSolar(baselineKW: Double) async {
        self.baselineSolar = baselineKW
        Logger.shared.log("Solar configured: \(baselineKW)kW", category: "Energy")
    }

    /// Configure electricity baseline (for simulation)
    func configureElectricity(baselineKW: Double) async {
        self.baselineElectric = baselineKW
        Logger.shared.log("Electric configured: \(baselineKW)kW", category: "Energy")
    }

    /// Reset cumulative counters (for testing)
    func resetCounters() async {
        cumulativeElectric = 0.0
        cumulativeSolar = 0.0
        Logger.shared.log("Counters reset", category: "Energy")
    }
}
