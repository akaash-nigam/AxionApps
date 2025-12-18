import XCTest
@testable import IndustrialCADCAM
import simd

/// Unit tests for utility classes
final class UtilityTests: XCTestCase {

    // MARK: - GeometryUtilities Tests

    func testVolume OfCuboid() {
        let volume = GeometryUtilities.volumeOfCuboid(width: 100, height: 100, depth: 100)
        XCTAssertEqual(volume, 1_000_000.0, accuracy: 0.1)
    }

    func testVolumeOfCylinder() {
        let volume = GeometryUtilities.volumeOfCylinder(diameter: 100, height: 100)
        let expected = Double.pi * 50 * 50 * 100
        XCTAssertEqual(volume, expected, accuracy: 0.1)
    }

    func testVolumeOfSphere() {
        let volume = GeometryUtilities.volumeOfSphere(diameter: 100)
        let expected = (4.0 / 3.0) * Double.pi * 50 * 50 * 50
        XCTAssertEqual(volume, expected, accuracy: 0.1)
    }

    func testSurfaceAreaOfCuboid() {
        let area = GeometryUtilities.surfaceAreaOfCuboid(width: 100, height: 100, depth: 100)
        XCTAssertEqual(area, 60_000.0, accuracy: 0.1)
    }

    func testCalculateCentroid() {
        let points = [
            SIMD3<Float>(0, 0, 0),
            SIMD3<Float>(10, 0, 0),
            SIMD3<Float>(10, 10, 0),
            SIMD3<Float>(0, 10, 0)
        ]
        let centroid = GeometryUtilities.calculateCentroid(points)
        XCTAssertEqual(centroid.x, 5.0, accuracy: 0.01)
        XCTAssertEqual(centroid.y, 5.0, accuracy: 0.01)
        XCTAssertEqual(centroid.z, 0.0, accuracy: 0.01)
    }

    func testCalculateBoundingBox() {
        let points = [
            SIMD3<Float>(-5, -10, -15),
            SIMD3<Float>(5, 10, 15),
            SIMD3<Float>(0, 0, 0)
        ]
        let bbox = GeometryUtilities.calculateBoundingBox(points)
        XCTAssertNotNil(bbox)
        XCTAssertEqual(bbox!.min.x, -5.0, accuracy: 0.01)
        XCTAssertEqual(bbox!.max.x, 5.0, accuracy: 0.01)
    }

    func testDistance() {
        let p1 = SIMD3<Float>(0, 0, 0)
        let p2 = SIMD3<Float>(3, 4, 0)
        let distance = GeometryUtilities.distance(from: p1, to: p2)
        XCTAssertEqual(distance, 5.0, accuracy: 0.01)
    }

    func testAngleBetweenVectors() {
        let v1 = SIMD3<Float>(1, 0, 0)
        let v2 = SIMD3<Float>(0, 1, 0)
        let angle = GeometryUtilities.angleBetweenVectors(v1, v2)
        XCTAssertEqual(angle, Float.pi / 2, accuracy: 0.01)
    }

    func testDegreesRadiansConversion() {
        let degrees = 180.0
        let radians = GeometryUtilities.degreesToRadians(degrees)
        XCTAssertEqual(radians, Double.pi, accuracy: 0.0001)

        let backToDegrees = GeometryUtilities.radiansToDegrees(radians)
        XCTAssertEqual(backToDegrees, degrees, accuracy: 0.0001)
    }

    func testTriangleArea() {
        let v1 = SIMD3<Float>(0, 0, 0)
        let v2 = SIMD3<Float>(10, 0, 0)
        let v3 = SIMD3<Float>(0, 10, 0)
        let area = GeometryUtilities.triangleArea(v1: v1, v2: v2, v3: v3)
        XCTAssertEqual(area, 50.0, accuracy: 0.1)
    }

    // MARK: - MeasurementUtilities Tests

    func testMillimetersToInches() {
        let inches = MeasurementUtilities.millimetersToInches(25.4)
        XCTAssertEqual(inches, 1.0, accuracy: 0.0001)
    }

    func testInchesToMillimeters() {
        let mm = MeasurementUtilities.inchesToMillimeters(1.0)
        XCTAssertEqual(mm, 25.4, accuracy: 0.0001)
    }

    func testConvertLength() {
        let result = MeasurementUtilities.convertLength(
            1000,
            from: .millimeters,
            to: .meters
        )
        XCTAssertEqual(result, 1.0, accuracy: 0.0001)
    }

    func testVolumeConversions() {
        let cubicInches = MeasurementUtilities.cubicMillimetersToCubicInches(16387.064)
        XCTAssertEqual(cubicInches, 1.0, accuracy: 0.001)
    }

    func testMassConversions() {
        let kg = MeasurementUtilities.gramsToKilograms(1000)
        XCTAssertEqual(kg, 1.0, accuracy: 0.0001)

        let pounds = MeasurementUtilities.kilogramsToPounds(1.0)
        XCTAssertEqual(pounds, 2.20462, accuracy: 0.001)
    }

    func testFormatLength() {
        let formatted = MeasurementUtilities.formatLength(
            123.456,
            unit: .millimeters,
            precision: 2
        )
        XCTAssertEqual(formatted, "123.46 mm")
    }

    func testRoundToDecimalPlaces() {
        let rounded = MeasurementUtilities.round(123.456789, toDecimalPlaces: 2)
        XCTAssertEqual(rounded, 123.46, accuracy: 0.001)
    }

    func testIsWithinTolerance() {
        XCTAssertTrue(MeasurementUtilities.isWithinTolerance(10.0, of: 10.05, tolerance: 0.1))
        XCTAssertFalse(MeasurementUtilities.isWithinTolerance(10.0, of: 10.2, tolerance: 0.1))
    }

    // MARK: - FileFormatUtilities Tests

    func testDetectFormatFromURL() {
        let url = URL(fileURLWithPath: "/test/file.step")
        let format = FileFormatUtilities.detectFormat(from: url)
        XCTAssertEqual(format, .stepAlternate)
    }

    func testIsSupportedFormat() {
        let stepURL = URL(fileURLWithPath: "/test/file.step")
        XCTAssertTrue(FileFormatUtilities.isSupportedFormat(stepURL))

        let txtURL = URL(fileURLWithPath: "/test/file.txt")
        XCTAssertFalse(FileFormatUtilities.isSupportedFormat(txtURL))
    }

    func testIsValidFileName() {
        XCTAssertTrue(FileFormatUtilities.isValidFileName("valid_file_name.step"))
        XCTAssertFalse(FileFormatUtilities.isValidFileName("invalid/file:name.step"))
        XCTAssertFalse(FileFormatUtilities.isValidFileName(""))
    }

    func testSanitizeFileName() {
        let sanitized = FileFormatUtilities.sanitizeFileName("test:file*name?.step")
        XCTAssertEqual(sanitized, "test_file_name_.step")
    }

    func testMIMEType() {
        let mimeType = FileFormatUtilities.mimeType(for: .step)
        XCTAssertEqual(mimeType, "application/step")
    }

    func testRecommendedFormat() {
        let format = FileFormatUtilities.recommendedFormat(for: .manufacturing)
        XCTAssertEqual(format, .step)
    }

    // MARK: - ValidationUtilities Tests

    func testValidateProjectName() {
        let validResult = ValidationUtilities.validateProjectName("Test Project")
        XCTAssertTrue(validResult.isValid)

        let emptyResult = ValidationUtilities.validateProjectName("")
        XCTAssertFalse(emptyResult.isValid)

        let longName = String(repeating: "a", count: 101)
        let tooLongResult = ValidationUtilities.validateProjectName(longName)
        XCTAssertFalse(tooLongResult.isValid)
    }

    func testValidateEmail() {
        XCTAssertTrue(ValidationUtilities.validateEmail("test@example.com").isValid)
        XCTAssertFalse(ValidationUtilities.validateEmail("invalid-email").isValid)
        XCTAssertFalse(ValidationUtilities.validateEmail("@example.com").isValid)
    }

    func testValidateDimension() {
        XCTAssertTrue(ValidationUtilities.validateDimension(100.0).isValid)
        XCTAssertFalse(ValidationUtilities.validateDimension(0.0).isValid)
        XCTAssertFalse(ValidationUtilities.validateDimension(-10.0).isValid)
        XCTAssertFalse(ValidationUtilities.validateDimension(150_000.0).isValid)
    }

    func testValidateDensity() {
        XCTAssertTrue(ValidationUtilities.validateDensity(7.85).isValid) // Steel
        XCTAssertFalse(ValidationUtilities.validateDensity(0.0).isValid)
        XCTAssertFalse(ValidationUtilities.validateDensity(-1.0).isValid)
        XCTAssertFalse(ValidationUtilities.validateDensity(30.0).isValid)
    }

    func testValidateMass() {
        XCTAssertTrue(ValidationUtilities.validateMass(1000.0).isValid)
        XCTAssertTrue(ValidationUtilities.validateMass(0.0).isValid)
        XCTAssertFalse(ValidationUtilities.validateMass(-10.0).isValid)
    }

    func testValidatePercentage() {
        XCTAssertTrue(ValidationUtilities.validatePercentage(50.0).isValid)
        XCTAssertTrue(ValidationUtilities.validatePercentage(0.0).isValid)
        XCTAssertTrue(ValidationUtilities.validatePercentage(100.0).isValid)
        XCTAssertFalse(ValidationUtilities.validatePercentage(-10.0).isValid)
        XCTAssertFalse(ValidationUtilities.validatePercentage(150.0).isValid)
    }

    func testValidateFeedRate() {
        XCTAssertTrue(ValidationUtilities.validateFeedRate(1000.0).isValid)
        XCTAssertFalse(ValidationUtilities.validateFeedRate(0.0).isValid)
        XCTAssertFalse(ValidationUtilities.validateFeedRate(15_000.0).isValid)
    }

    func testValidateSpindleSpeed() {
        XCTAssertTrue(ValidationUtilities.validateSpindleSpeed(3000.0).isValid)
        XCTAssertFalse(ValidationUtilities.validateSpindleSpeed(50.0).isValid)
        XCTAssertFalse(ValidationUtilities.validateSpindleSpeed(50_000.0).isValid)
    }

    func testValidateFactorOfSafety() {
        let result1 = ValidationUtilities.validateFactorOfSafety(2.0)
        XCTAssertTrue(result1.isValid)
        XCTAssertFalse(result1.isWarning)

        let result2 = ValidationUtilities.validateFactorOfSafety(0.9)
        XCTAssertTrue(result2.isValid)
        XCTAssertTrue(result2.isWarning)

        let result3 = ValidationUtilities.validateFactorOfSafety(0.0)
        XCTAssertFalse(result3.isValid)
    }

    func testValidateNotEmpty() {
        XCTAssertTrue(ValidationUtilities.validateNotEmpty([1, 2, 3]).isValid)
        XCTAssertFalse(ValidationUtilities.validateNotEmpty([Int]()).isValid)
    }

    func testValidateCollectionSize() {
        let result = ValidationUtilities.validateCollectionSize(
            5,
            minimum: 1,
            maximum: 10
        )
        XCTAssertTrue(result.isValid)

        let tooSmall = ValidationUtilities.validateCollectionSize(
            0,
            minimum: 1,
            maximum: 10
        )
        XCTAssertFalse(tooSmall.isValid)

        let tooLarge = ValidationUtilities.validateCollectionSize(
            15,
            minimum: 1,
            maximum: 10
        )
        XCTAssertFalse(tooLarge.isValid)
    }

    func testValidateUUID() {
        let validUUID = UUID().uuidString
        XCTAssertTrue(ValidationUtilities.validateUUID(validUUID).isValid)
        XCTAssertFalse(ValidationUtilities.validateUUID("invalid-uuid").isValid)
    }

    func testCombineValidations() {
        let validations: [ValidationUtilities.ValidationResult] = [
            .valid,
            .valid,
            .valid
        ]
        XCTAssertTrue(ValidationUtilities.combineValidations(validations).isValid)

        let withError: [ValidationUtilities.ValidationResult] = [
            .valid,
            .invalid("Error"),
            .valid
        ]
        XCTAssertFalse(ValidationUtilities.combineValidations(withError).isValid)

        let withWarning: [ValidationUtilities.ValidationResult] = [
            .valid,
            .warning("Warning"),
            .valid
        ]
        let result = ValidationUtilities.combineValidations(withWarning)
        XCTAssertTrue(result.isValid)
        XCTAssertTrue(result.isWarning)
    }
}
