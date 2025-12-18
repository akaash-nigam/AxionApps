import XCTest
@testable import LivingBuildingSystem

final class EnergyServiceTests: XCTestCase {

    var service: EnergyService!

    override func setUp() async throws {
        service = EnergyService()
    }

    override func tearDown() async throws {
        await service.disconnect()
        service = nil
    }

    // MARK: - Connection Tests

    func testConnect() async throws {
        XCTAssertFalse(await service.isConnected())

        try await service.connect(apiIdentifier: "test-meter-001")

        XCTAssertTrue(await service.isConnected())
    }

    func testDisconnect() async throws {
        try await service.connect(apiIdentifier: "test-meter-001")
        XCTAssertTrue(await service.isConnected())

        await service.disconnect()

        XCTAssertFalse(await service.isConnected())
    }

    // MARK: - Current Reading Tests

    func testGetCurrentElectricReading() async throws {
        try await service.connect(apiIdentifier: "test-meter-001")

        let reading = try await service.getCurrentReading(type: .electricity)

        XCTAssertEqual(reading.energyType, .electricity)
        XCTAssertNotNil(reading.instantaneousPower)
        XCTAssertNotNil(reading.cumulativeConsumption)
        XCTAssertGreaterThan(reading.instantaneousPower!, 0)
    }

    func testGetCurrentSolarReading() async throws {
        try await service.connect(apiIdentifier: "test-meter-001")
        await service.configureSolar(baselineKW: 5.0)

        let reading = try await service.getCurrentReading(type: .solar)

        XCTAssertEqual(reading.energyType, .solar)
        XCTAssertNotNil(reading.instantaneousGeneration)
        // Generation might be 0 at night, so we just check it's not nil
    }

    func testGetCurrentGasReading() async throws {
        try await service.connect(apiIdentifier: "test-meter-001")

        let reading = try await service.getCurrentReading(type: .gas)

        XCTAssertEqual(reading.energyType, .gas)
        XCTAssertNotNil(reading.instantaneousPower)
        XCTAssertNotNil(reading.cumulativeConsumption)
    }

    func testGetCurrentWaterReading() async throws {
        try await service.connect(apiIdentifier: "test-meter-001")

        let reading = try await service.getCurrentReading(type: .water)

        XCTAssertEqual(reading.energyType, .water)
        XCTAssertNotNil(reading.instantaneousPower)
        XCTAssertNotNil(reading.cumulativeConsumption)
    }

    func testGetCurrentReadingWithoutConnection() async {
        // Should throw error when not connected
        do {
            _ = try await service.getCurrentReading(type: .electricity)
            XCTFail("Should have thrown an error")
        } catch {
            // Expected error
            XCTAssertTrue(error is LBSError)
        }
    }

    // MARK: - Historical Data Tests

    func testGetHistoricalReadings() async throws {
        try await service.connect(apiIdentifier: "test-meter-001")

        let startDate = Date().addingTimeInterval(-3600 * 24) // 24 hours ago
        let endDate = Date()

        let readings = try await service.getHistoricalReadings(
            type: .electricity,
            startDate: startDate,
            endDate: endDate
        )

        XCTAssertFalse(readings.isEmpty)
        XCTAssertGreaterThan(readings.count, 20) // Should have at least hourly readings

        // Verify timestamps are in range
        for reading in readings {
            XCTAssertGreaterThanOrEqual(reading.timestamp, startDate)
            XCTAssertLessThanOrEqual(reading.timestamp, endDate)
        }

        // Verify timestamps are in order
        for i in 0..<readings.count-1 {
            XCTAssertLessThan(readings[i].timestamp, readings[i+1].timestamp)
        }
    }

    func testHistoricalReadingsHavePower() async throws {
        try await service.connect(apiIdentifier: "test-meter-001")

        let startDate = Date().addingTimeInterval(-3600) // 1 hour ago
        let endDate = Date()

        let readings = try await service.getHistoricalReadings(
            type: .electricity,
            startDate: startDate,
            endDate: endDate
        )

        for reading in readings {
            XCTAssertNotNil(reading.instantaneousPower)
            XCTAssertGreaterThan(reading.instantaneousPower!, 0)
        }
    }

    func testHistoricalReadingsCumulativeIncreases() async throws {
        try await service.connect(apiIdentifier: "test-meter-001")

        let startDate = Date().addingTimeInterval(-3600 * 6) // 6 hours ago
        let endDate = Date()

        let readings = try await service.getHistoricalReadings(
            type: .electricity,
            startDate: startDate,
            endDate: endDate
        )

        // Cumulative consumption should generally increase
        for i in 0..<readings.count-1 {
            let current = readings[i].cumulativeConsumption ?? 0
            let next = readings[i+1].cumulativeConsumption ?? 0
            XCTAssertGreaterThanOrEqual(next, current)
        }
    }

    // MARK: - Monitoring Tests

    func testStartMonitoring() async throws {
        try await service.connect(apiIdentifier: "test-meter-001")

        // Set up handler to receive updates
        let expectation = XCTestExpectation(description: "Receive energy update")
        var receivedReadings: [EnergyReading] = []

        await service.setUpdateHandler { reading in
            receivedReadings.append(reading)
            if receivedReadings.count >= 2 {
                expectation.fulfill()
            }
        }

        try await service.startMonitoring()

        // Wait for at least 2 updates (takes ~10 seconds with 5s interval)
        await fulfillment(of: [expectation], timeout: 15.0)

        XCTAssertGreaterThanOrEqual(receivedReadings.count, 2)

        await service.stopMonitoring()
    }

    func testStopMonitoring() async throws {
        try await service.connect(apiIdentifier: "test-meter-001")

        var updateCount = 0
        await service.setUpdateHandler { _ in
            updateCount += 1
        }

        try await service.startMonitoring()

        // Wait a bit for some updates
        try await Task.sleep(for: .seconds(6))

        let countBeforeStop = updateCount

        await service.stopMonitoring()

        // Wait and verify no more updates
        try await Task.sleep(for: .seconds(6))

        let countAfterStop = updateCount

        // Should have received updates before stopping
        XCTAssertGreaterThan(countBeforeStop, 0)
        // Should not receive updates after stopping (or very few due to timing)
        XCTAssertLessThanOrEqual(countAfterStop - countBeforeStop, 1)
    }

    // MARK: - Anomaly Detection Tests

    func testDetectAnomaliesWithNormalUsage() async throws {
        try await service.connect(apiIdentifier: "test-meter-001")

        // Create readings with normal, consistent usage
        var readings: [EnergyReading] = []
        for i in 0..<20 {
            let reading = EnergyReading(
                timestamp: Date().addingTimeInterval(Double(i * -300)),
                energyType: .electricity
            )
            reading.instantaneousPower = 2.5 + Double.random(in: -0.2...0.2)
            readings.append(reading)
        }

        let config = EnergyConfiguration()
        let anomalies = try await service.detectAnomalies(
            readings: readings,
            configuration: config
        )

        // Normal usage should have no or very few anomalies
        XCTAssertLessThanOrEqual(anomalies.count, 1)
    }

    func testDetectAnomaliesWithSpike() async throws {
        try await service.connect(apiIdentifier: "test-meter-001")

        // Create readings with a spike
        var readings: [EnergyReading] = []
        for i in 0..<20 {
            let reading = EnergyReading(
                timestamp: Date().addingTimeInterval(Double(i * -300)),
                energyType: .electricity
            )
            // Normal usage except for one spike
            reading.instantaneousPower = i == 10 ? 15.0 : 2.5
            readings.append(reading)
        }

        let config = EnergyConfiguration()
        let anomalies = try await service.detectAnomalies(
            readings: readings,
            configuration: config
        )

        // Should detect the spike
        XCTAssertGreaterThan(anomalies.count, 0)

        let spikeAnomalies = anomalies.filter { $0.anomalyType == .spikage }
        XCTAssertGreaterThan(spikeAnomalies.count, 0)
    }

    func testDetectAnomaliesWithHighUsage() async throws {
        try await service.connect(apiIdentifier: "test-meter-001")

        // Create readings with consistently high usage
        var readings: [EnergyReading] = []
        for i in 0..<20 {
            let reading = EnergyReading(
                timestamp: Date().addingTimeInterval(Double(i * -300)),
                energyType: .electricity
            )
            reading.instantaneousPower = i < 10 ? 2.5 : 6.0 // Jump to high usage
            readings.append(reading)
        }

        let config = EnergyConfiguration()
        let anomalies = try await service.detectAnomalies(
            readings: readings,
            configuration: config
        )

        // Should detect unusually high usage
        XCTAssertGreaterThan(anomalies.count, 0)

        let highUsageAnomalies = anomalies.filter { $0.anomalyType == .unusuallyHigh }
        XCTAssertGreaterThan(highUsageAnomalies.count, 0)
    }

    func testDetectAnomaliesWithContinuousUsage() async throws {
        try await service.connect(apiIdentifier: "test-meter-001")

        // Create readings with very consistent usage (no variation)
        var readings: [EnergyReading] = []
        for i in 0..<20 {
            let reading = EnergyReading(
                timestamp: Date().addingTimeInterval(Double(i * -300)),
                energyType: .electricity
            )
            reading.instantaneousPower = 2.0 // Exactly the same
            readings.append(reading)
        }

        let config = EnergyConfiguration()
        let anomalies = try await service.detectAnomalies(
            readings: readings,
            configuration: config
        )

        // Should detect continuous usage
        let continuousAnomalies = anomalies.filter { $0.anomalyType == .continuousUsage }
        XCTAssertGreaterThan(continuousAnomalies.count, 0)
    }

    func testDetectAnomaliesWithEmptyReadings() async throws {
        try await service.connect(apiIdentifier: "test-meter-001")

        let config = EnergyConfiguration()
        let anomalies = try await service.detectAnomalies(
            readings: [],
            configuration: config
        )

        XCTAssertEqual(anomalies.count, 0)
    }

    // MARK: - Configuration Tests

    func testConfigureSolar() async throws {
        await service.configureSolar(baselineKW: 8.0)

        try await service.connect(apiIdentifier: "test-meter-001")

        let reading = try await service.getCurrentReading(type: .solar)

        // During daylight hours, should have generation
        // We can't test exact values due to time-of-day dependency
        XCTAssertNotNil(reading.instantaneousGeneration)
    }

    func testConfigureElectricity() async throws {
        await service.configureElectricity(baselineKW: 5.0)

        try await service.connect(apiIdentifier: "test-meter-001")

        let reading = try await service.getCurrentReading(type: .electricity)

        // Power should be around the baseline (with some variation)
        XCTAssertGreaterThan(reading.instantaneousPower!, 3.0)
        XCTAssertLessThan(reading.instantaneousPower!, 10.0)
    }

    func testResetCounters() async throws {
        try await service.connect(apiIdentifier: "test-meter-001")

        // Get initial reading
        let reading1 = try await service.getCurrentReading(type: .electricity)
        let cumulative1 = reading1.cumulativeConsumption!

        // Wait and get another reading (cumulative should increase)
        try await Task.sleep(for: .seconds(1))
        let reading2 = try await service.getCurrentReading(type: .electricity)
        let cumulative2 = reading2.cumulativeConsumption!

        XCTAssertGreaterThan(cumulative2, cumulative1)

        // Reset counters
        await service.resetCounters()

        // Next reading should start from zero
        let reading3 = try await service.getCurrentReading(type: .electricity)
        let cumulative3 = reading3.cumulativeConsumption!

        XCTAssertLessThan(cumulative3, cumulative2)
    }

    // MARK: - Circuit Breakdown Tests

    func testElectricReadingHasCircuitBreakdown() async throws {
        try await service.connect(apiIdentifier: "test-meter-001")

        let reading = try await service.getCurrentReading(type: .electricity)

        XCTAssertNotNil(reading.circuitBreakdown)
        XCTAssertFalse(reading.circuitBreakdown!.isEmpty)

        // Should have common circuits
        let breakdown = reading.circuitBreakdown!
        XCTAssertTrue(breakdown.keys.contains("HVAC"))
        XCTAssertTrue(breakdown.keys.contains("Kitchen"))

        // All values should be positive
        for (_, power) in breakdown {
            XCTAssertGreaterThan(power, 0)
        }
    }
}
