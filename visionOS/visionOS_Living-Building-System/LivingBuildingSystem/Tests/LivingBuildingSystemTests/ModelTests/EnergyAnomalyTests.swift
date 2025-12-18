import XCTest
@testable import LivingBuildingSystem

final class EnergyAnomalyTests: XCTestCase {

    // MARK: - Initialization Tests

    func testAnomalyInitialization() {
        let detectedAt = Date()
        let anomaly = EnergyAnomaly(
            detectedAt: detectedAt,
            anomalyType: .unusuallyHigh,
            severity: .medium,
            energyType: .electricity,
            expectedValue: 2.5,
            actualValue: 5.8,
            description: "Test anomaly"
        )

        XCTAssertNotNil(anomaly.id)
        XCTAssertEqual(anomaly.detectedAt, detectedAt)
        XCTAssertEqual(anomaly.anomalyType, .unusuallyHigh)
        XCTAssertEqual(anomaly.severity, .medium)
        XCTAssertEqual(anomaly.energyType, .electricity)
        XCTAssertEqual(anomaly.expectedValue, 2.5)
        XCTAssertEqual(anomaly.actualValue, 5.8)
        XCTAssertEqual(anomaly.description, "Test anomaly")
        XCTAssertFalse(anomaly.isDismissed)
        XCTAssertNil(anomaly.resolvedAt)
    }

    // MARK: - Deviation Calculation Tests

    func testDeviationPercentagePositive() {
        let anomaly = EnergyAnomaly(
            anomalyType: .unusuallyHigh,
            severity: .medium,
            energyType: .electricity,
            expectedValue: 2.0,
            actualValue: 3.0,
            description: "Test"
        )

        let deviation = anomaly.deviationPercentage
        XCTAssertEqual(deviation, 50.0, accuracy: 0.01) // 50% higher
    }

    func testDeviationPercentageNegative() {
        let anomaly = EnergyAnomaly(
            anomalyType: .unusuallyLow,
            severity: .low,
            energyType: .electricity,
            expectedValue: 4.0,
            actualValue: 3.0,
            description: "Test"
        )

        let deviation = anomaly.deviationPercentage
        XCTAssertEqual(deviation, 25.0, accuracy: 0.01) // 25% lower
    }

    func testDeviationPercentageZeroExpected() {
        let anomaly = EnergyAnomaly(
            anomalyType: .continuousUsage,
            severity: .low,
            energyType: .electricity,
            expectedValue: 0.0,
            actualValue: 2.0,
            description: "Test"
        )

        let deviation = anomaly.deviationPercentage
        XCTAssertEqual(deviation, 0.0) // Should handle zero gracefully
    }

    // MARK: - Cost Impact Tests

    func testCostImpactElectricity() {
        let anomaly = EnergyAnomaly(
            anomalyType: .unusuallyHigh,
            severity: .medium,
            energyType: .electricity,
            expectedValue: 2.0,
            actualValue: 5.0, // 3.0 kW excess
            description: "Test"
        )

        let config = EnergyConfiguration()
        config.electricityRatePerKWh = 0.15

        let impact = anomaly.costImpact(configuration: config)
        XCTAssertEqual(impact, 0.45, accuracy: 0.01) // 3.0 * 0.15 = $0.45
    }

    func testCostImpactGas() {
        let anomaly = EnergyAnomaly(
            anomalyType: .unusuallyHigh,
            severity: .medium,
            energyType: .gas,
            expectedValue: 1.0,
            actualValue: 3.0, // 2.0 therm excess
            description: "Test"
        )

        let config = EnergyConfiguration()
        config.gasRatePerTherm = 1.5

        let impact = anomaly.costImpact(configuration: config)
        XCTAssertEqual(impact, 3.0, accuracy: 0.01) // 2.0 * 1.5 = $3.00
    }

    func testCostImpactWater() {
        let anomaly = EnergyAnomaly(
            anomalyType: .suspectedLeak,
            severity: .critical,
            energyType: .water,
            expectedValue: 0.5,
            actualValue: 3.5, // 3.0 gallon excess
            description: "Test"
        )

        let config = EnergyConfiguration()
        config.waterRatePerGallon = 0.006

        let impact = anomaly.costImpact(configuration: config)
        XCTAssertEqual(impact, 0.018, accuracy: 0.001) // 3.0 * 0.006 = $0.018
    }

    func testCostImpactNegativeDeviation() {
        let anomaly = EnergyAnomaly(
            anomalyType: .unusuallyLow,
            severity: .low,
            energyType: .electricity,
            expectedValue: 5.0,
            actualValue: 2.0, // Negative deviation
            description: "Test"
        )

        let config = EnergyConfiguration()
        config.electricityRatePerKWh = 0.15

        let impact = anomaly.costImpact(configuration: config)
        XCTAssertEqual(impact, 0.0) // No cost impact for lower usage
    }

    func testCostImpactSolar() {
        let anomaly = EnergyAnomaly(
            anomalyType: .unusuallyLow,
            severity: .medium,
            energyType: .solar,
            expectedValue: 5.0,
            actualValue: 2.0,
            description: "Test"
        )

        let config = EnergyConfiguration()

        let impact = anomaly.costImpact(configuration: config)
        XCTAssertEqual(impact, 0.0) // Solar has no direct cost impact
    }

    // MARK: - Dismissal Tests

    func testDismissAnomaly() {
        let anomaly = EnergyAnomaly(
            anomalyType: .unusuallyHigh,
            severity: .medium,
            energyType: .electricity,
            expectedValue: 2.0,
            actualValue: 5.0,
            description: "Test"
        )

        XCTAssertFalse(anomaly.isDismissed)

        anomaly.dismiss()

        XCTAssertTrue(anomaly.isDismissed)
        XCTAssertNil(anomaly.resolvedAt) // Dismiss doesn't set resolvedAt
    }

    func testResolveAnomaly() {
        let anomaly = EnergyAnomaly(
            anomalyType: .suspectedLeak,
            severity: .critical,
            energyType: .water,
            expectedValue: 0.5,
            actualValue: 3.5,
            description: "Test"
        )

        XCTAssertFalse(anomaly.isDismissed)
        XCTAssertNil(anomaly.resolvedAt)

        let beforeResolve = Date()
        anomaly.resolve()
        let afterResolve = Date()

        XCTAssertTrue(anomaly.isDismissed)
        XCTAssertNotNil(anomaly.resolvedAt)
        XCTAssertGreaterThanOrEqual(anomaly.resolvedAt!, beforeResolve)
        XCTAssertLessThanOrEqual(anomaly.resolvedAt!, afterResolve)
    }

    // MARK: - Severity Tests

    func testSeverityColors() {
        XCTAssertEqual(AnomalySeverity.low.color, "blue")
        XCTAssertEqual(AnomalySeverity.medium.color, "yellow")
        XCTAssertEqual(AnomalySeverity.high.color, "orange")
        XCTAssertEqual(AnomalySeverity.critical.color, "red")
    }

    func testSeverityIcons() {
        XCTAssertEqual(AnomalySeverity.low.icon, "info.circle")
        XCTAssertEqual(AnomalySeverity.medium.icon, "exclamationmark.triangle")
        XCTAssertEqual(AnomalySeverity.high.icon, "exclamationmark.triangle.fill")
        XCTAssertEqual(AnomalySeverity.critical.icon, "exclamationmark.octagon.fill")
    }

    // MARK: - Preview Data Tests

    func testPreviewData() {
        let preview = EnergyAnomaly.preview

        XCTAssertNotNil(preview.id)
        XCTAssertEqual(preview.anomalyType, .unusuallyHigh)
        XCTAssertEqual(preview.severity, .medium)
        XCTAssertEqual(preview.energyType, .electricity)
        XCTAssertGreaterThan(preview.actualValue, preview.expectedValue)
    }

    func testPreviewLeakData() {
        let preview = EnergyAnomaly.previewLeak

        XCTAssertNotNil(preview.id)
        XCTAssertEqual(preview.anomalyType, .suspectedLeak)
        XCTAssertEqual(preview.severity, .critical)
        XCTAssertEqual(preview.energyType, .water)
    }

    func testPreviewMultipleData() {
        let previews = EnergyAnomaly.previewMultiple

        XCTAssertEqual(previews.count, 3)

        // Verify different types
        let types = Set(previews.map { $0.anomalyType })
        XCTAssertEqual(types.count, 3) // All different types

        // Verify different severities
        let severities = previews.map { $0.severity }
        XCTAssertTrue(severities.contains(.medium))
        XCTAssertTrue(severities.contains(.low))
        XCTAssertTrue(severities.contains(.high))
    }
}
