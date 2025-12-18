import XCTest
@testable import LivingBuildingSystem

final class EnergyReadingTests: XCTestCase {

    // MARK: - Initialization Tests

    func testEnergyReadingInitialization() {
        let timestamp = Date()
        let reading = EnergyReading(timestamp: timestamp, energyType: .electricity)

        XCTAssertNotNil(reading.id)
        XCTAssertEqual(reading.timestamp, timestamp)
        XCTAssertEqual(reading.energyType, .electricity)
        XCTAssertNil(reading.instantaneousPower)
        XCTAssertNil(reading.cumulativeConsumption)
    }

    // MARK: - Cost Calculation Tests

    func testElectricityCostCalculation() {
        let reading = EnergyReading(timestamp: Date(), energyType: .electricity)
        reading.cumulativeConsumption = 100.0 // 100 kWh

        let config = EnergyConfiguration()
        config.electricityRatePerKWh = 0.15 // $0.15 per kWh

        let cost = reading.calculateCost(configuration: config)
        XCTAssertEqual(cost, 15.0, accuracy: 0.01) // $15.00
    }

    func testGasCostCalculation() {
        let reading = EnergyReading(timestamp: Date(), energyType: .gas)
        reading.cumulativeConsumption = 50.0 // 50 therms

        let config = EnergyConfiguration()
        config.gasRatePerTherm = 1.5 // $1.50 per therm

        let cost = reading.calculateCost(configuration: config)
        XCTAssertEqual(cost, 75.0, accuracy: 0.01) // $75.00
    }

    func testWaterCostCalculation() {
        let reading = EnergyReading(timestamp: Date(), energyType: .water)
        reading.cumulativeConsumption = 1000.0 // 1000 gallons

        let config = EnergyConfiguration()
        config.waterRatePerGallon = 0.006 // $0.006 per gallon

        let cost = reading.calculateCost(configuration: config)
        XCTAssertEqual(cost, 6.0, accuracy: 0.01) // $6.00
    }

    func testSolarCostCalculation() {
        let reading = EnergyReading(timestamp: Date(), energyType: .solar)
        reading.cumulativeGeneration = 50.0 // 50 kWh generated

        let config = EnergyConfiguration()

        let cost = reading.calculateCost(configuration: config)
        XCTAssertEqual(cost, 0.0) // Solar is generation, not cost
    }

    // MARK: - Net Power Tests

    func testNetPowerPositive() {
        let reading = EnergyReading(timestamp: Date(), energyType: .solar)
        reading.instantaneousGeneration = 5.0 // 5 kW generating
        reading.instantaneousPower = 3.0 // 3 kW consuming

        let netPower = reading.netPower
        XCTAssertNotNil(netPower)
        XCTAssertEqual(netPower!, 2.0, accuracy: 0.01) // +2 kW to grid
    }

    func testNetPowerNegative() {
        let reading = EnergyReading(timestamp: Date(), energyType: .solar)
        reading.instantaneousGeneration = 2.0 // 2 kW generating
        reading.instantaneousPower = 5.0 // 5 kW consuming

        let netPower = reading.netPower
        XCTAssertNotNil(netPower)
        XCTAssertEqual(netPower!, -3.0, accuracy: 0.01) // -3 kW from grid
    }

    func testNetPowerNilWhenMissingData() {
        let reading = EnergyReading(timestamp: Date(), energyType: .solar)
        reading.instantaneousGeneration = 5.0
        // No instantaneousPower set

        XCTAssertNil(reading.netPower)
    }

    // MARK: - Circuit Breakdown Tests

    func testCircuitBreakdownEncoding() {
        let reading = EnergyReading(timestamp: Date(), energyType: .electricity)
        let breakdown = ["HVAC": 2.5, "Kitchen": 1.2, "Living Room": 0.8]

        reading.circuitBreakdown = breakdown

        XCTAssertNotNil(reading.circuitBreakdownData)
        XCTAssertEqual(reading.circuitBreakdown?.count, 3)
        XCTAssertEqual(reading.circuitBreakdown?["HVAC"], 2.5)
        XCTAssertEqual(reading.circuitBreakdown?["Kitchen"], 1.2)
        XCTAssertEqual(reading.circuitBreakdown?["Living Room"], 0.8)
    }

    func testCircuitBreakdownDecoding() {
        let reading = EnergyReading(timestamp: Date(), energyType: .electricity)
        let breakdown = ["HVAC": 2.5]
        reading.circuitBreakdown = breakdown

        // Retrieve and verify
        let retrieved = reading.circuitBreakdown
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?["HVAC"], 2.5)
    }

    // MARK: - Edge Cases

    func testZeroCostCalculation() {
        let reading = EnergyReading(timestamp: Date(), energyType: .electricity)
        reading.cumulativeConsumption = 0.0

        let config = EnergyConfiguration()
        config.electricityRatePerKWh = 0.15

        let cost = reading.calculateCost(configuration: config)
        XCTAssertEqual(cost, 0.0)
    }

    func testNilCostCalculation() {
        let reading = EnergyReading(timestamp: Date(), energyType: .electricity)
        // No cumulativeConsumption set

        let config = EnergyConfiguration()
        config.electricityRatePerKWh = 0.15

        let cost = reading.calculateCost(configuration: config)
        XCTAssertEqual(cost, 0.0) // Should handle nil gracefully
    }

    // MARK: - Preview Data Tests

    func testPreviewData() {
        let preview = EnergyReading.preview

        XCTAssertNotNil(preview.id)
        XCTAssertEqual(preview.energyType, .electricity)
        XCTAssertNotNil(preview.instantaneousPower)
        XCTAssertNotNil(preview.cumulativeConsumption)
    }

    func testPreviewSolarData() {
        let preview = EnergyReading.previewSolar

        XCTAssertNotNil(preview.id)
        XCTAssertEqual(preview.energyType, .solar)
        XCTAssertNotNil(preview.instantaneousGeneration)
        XCTAssertNotNil(preview.cumulativeGeneration)
    }

    func testPreviewMultipleData() {
        let previews = EnergyReading.previewMultiple

        XCTAssertEqual(previews.count, 24) // 24 hours

        // Verify timestamps are in order
        for i in 0..<previews.count-1 {
            XCTAssertLessThan(previews[i].timestamp, previews[i+1].timestamp)
        }

        // Verify all are electricity type
        for preview in previews {
            XCTAssertEqual(preview.energyType, .electricity)
        }
    }
}
