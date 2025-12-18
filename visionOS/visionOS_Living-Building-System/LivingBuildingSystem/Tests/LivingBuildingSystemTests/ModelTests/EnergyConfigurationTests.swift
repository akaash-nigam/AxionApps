import XCTest
@testable import LivingBuildingSystem

final class EnergyConfigurationTests: XCTestCase {

    // MARK: - Initialization Tests

    func testDefaultInitialization() {
        let config = EnergyConfiguration()

        XCTAssertNotNil(config.id)
        XCTAssertFalse(config.hasSmartMeter)
        XCTAssertFalse(config.hasSolar)
        XCTAssertFalse(config.hasBattery)
        XCTAssertEqual(config.electricityRatePerKWh, 0.15)
        XCTAssertNil(config.gasRatePerTherm)
        XCTAssertEqual(config.waterRatePerGallon, 0.006)
        XCTAssertNil(config.meterAPIIdentifier)
        XCTAssertNil(config.solarAPIIdentifier)
        XCTAssertNil(config.batteryAPIIdentifier)
    }

    // MARK: - Configuration State Tests

    func testIsConfiguredWhenNotConfigured() {
        let config = EnergyConfiguration()

        XCTAssertFalse(config.isConfigured)
    }

    func testIsConfiguredWithSmartMeter() {
        let config = EnergyConfiguration()
        config.hasSmartMeter = true

        XCTAssertTrue(config.isConfigured)
    }

    func testIsConfiguredWithSolar() {
        let config = EnergyConfiguration()
        config.hasSolar = true

        XCTAssertTrue(config.isConfigured)
    }

    func testIsConfiguredWithBattery() {
        let config = EnergyConfiguration()
        config.hasBattery = true

        XCTAssertTrue(config.isConfigured)
    }

    func testIsConfiguredWithMultipleSources() {
        let config = EnergyConfiguration()
        config.hasSmartMeter = true
        config.hasSolar = true
        config.hasBattery = true

        XCTAssertTrue(config.isConfigured)
    }

    // MARK: - Rate Update Tests

    func testUpdateElectricityRate() {
        let config = EnergyConfiguration()
        let originalUpdatedAt = config.updatedAt

        // Wait a tiny bit to ensure timestamp changes
        Thread.sleep(forTimeInterval: 0.01)

        config.updateRates(electricity: 0.20)

        XCTAssertEqual(config.electricityRatePerKWh, 0.20)
        XCTAssertGreaterThan(config.updatedAt, originalUpdatedAt)
    }

    func testUpdateGasRate() {
        let config = EnergyConfiguration()
        let originalUpdatedAt = config.updatedAt

        Thread.sleep(forTimeInterval: 0.01)

        config.updateRates(gas: 1.75)

        XCTAssertEqual(config.gasRatePerTherm, 1.75)
        XCTAssertGreaterThan(config.updatedAt, originalUpdatedAt)
    }

    func testUpdateWaterRate() {
        let config = EnergyConfiguration()
        let originalUpdatedAt = config.updatedAt

        Thread.sleep(forTimeInterval: 0.01)

        config.updateRates(water: 0.008)

        XCTAssertEqual(config.waterRatePerGallon, 0.008)
        XCTAssertGreaterThan(config.updatedAt, originalUpdatedAt)
    }

    func testUpdateMultipleRates() {
        let config = EnergyConfiguration()
        let originalUpdatedAt = config.updatedAt

        Thread.sleep(forTimeInterval: 0.01)

        config.updateRates(electricity: 0.18, gas: 1.60, water: 0.007)

        XCTAssertEqual(config.electricityRatePerKWh, 0.18)
        XCTAssertEqual(config.gasRatePerTherm, 1.60)
        XCTAssertEqual(config.waterRatePerGallon, 0.007)
        XCTAssertGreaterThan(config.updatedAt, originalUpdatedAt)
    }

    func testUpdateRatesWithNilValues() {
        let config = EnergyConfiguration()
        config.electricityRatePerKWh = 0.20
        config.gasRatePerTherm = 1.50
        config.waterRatePerGallon = 0.008

        config.updateRates(electricity: nil, gas: nil, water: nil)

        // Values should remain unchanged
        XCTAssertEqual(config.electricityRatePerKWh, 0.20)
        XCTAssertEqual(config.gasRatePerTherm, 1.50)
        XCTAssertEqual(config.waterRatePerGallon, 0.008)
    }

    func testUpdateRatesPartial() {
        let config = EnergyConfiguration()
        config.electricityRatePerKWh = 0.20
        config.waterRatePerGallon = 0.008

        config.updateRates(electricity: 0.22) // Only update electricity

        XCTAssertEqual(config.electricityRatePerKWh, 0.22)
        XCTAssertEqual(config.waterRatePerGallon, 0.008) // Unchanged
    }

    // MARK: - API Identifier Tests

    func testSetMeterAPIIdentifier() {
        let config = EnergyConfiguration()
        config.meterAPIIdentifier = "meter-123"

        XCTAssertEqual(config.meterAPIIdentifier, "meter-123")
    }

    func testSetSolarAPIIdentifier() {
        let config = EnergyConfiguration()
        config.solarAPIIdentifier = "solar-456"

        XCTAssertEqual(config.solarAPIIdentifier, "solar-456")
    }

    func testSetBatteryAPIIdentifier() {
        let config = EnergyConfiguration()
        config.batteryAPIIdentifier = "battery-789"

        XCTAssertEqual(config.batteryAPIIdentifier, "battery-789")
    }

    // MARK: - Realistic Configuration Tests

    func testTypicalHomeConfiguration() {
        let config = EnergyConfiguration()
        config.hasSmartMeter = true
        config.hasSolar = false
        config.hasBattery = false
        config.electricityRatePerKWh = 0.13
        config.gasRatePerTherm = 1.20
        config.waterRatePerGallon = 0.005
        config.meterAPIIdentifier = "smart-meter-001"

        XCTAssertTrue(config.isConfigured)
        XCTAssertNotNil(config.meterAPIIdentifier)
        XCTAssertNil(config.solarAPIIdentifier)
        XCTAssertNil(config.batteryAPIIdentifier)
    }

    func testSolarHomeConfiguration() {
        let config = EnergyConfiguration()
        config.hasSmartMeter = true
        config.hasSolar = true
        config.hasBattery = true
        config.electricityRatePerKWh = 0.16
        config.waterRatePerGallon = 0.007
        config.meterAPIIdentifier = "smart-meter-002"
        config.solarAPIIdentifier = "solar-inverter-001"
        config.batteryAPIIdentifier = "tesla-powerwall-001"

        XCTAssertTrue(config.isConfigured)
        XCTAssertTrue(config.hasSmartMeter)
        XCTAssertTrue(config.hasSolar)
        XCTAssertTrue(config.hasBattery)
        XCTAssertNotNil(config.meterAPIIdentifier)
        XCTAssertNotNil(config.solarAPIIdentifier)
        XCTAssertNotNil(config.batteryAPIIdentifier)
    }

    // MARK: - Edge Cases

    func testZeroRates() {
        let config = EnergyConfiguration()
        config.updateRates(electricity: 0.0, gas: 0.0, water: 0.0)

        XCTAssertEqual(config.electricityRatePerKWh, 0.0)
        XCTAssertEqual(config.gasRatePerTherm, 0.0)
        XCTAssertEqual(config.waterRatePerGallon, 0.0)
    }

    func testVeryHighRates() {
        let config = EnergyConfiguration()
        config.updateRates(electricity: 1.50, gas: 10.0, water: 0.5)

        XCTAssertEqual(config.electricityRatePerKWh, 1.50)
        XCTAssertEqual(config.gasRatePerTherm, 10.0)
        XCTAssertEqual(config.waterRatePerGallon, 0.5)
    }
}
