import XCTest
import simd
@testable import SustainabilityCommand

final class SpatialExtensionsTests: XCTestCase {

    // MARK: - SIMD3 Extensions Tests

    func testSIMD3Length() {
        let vector = SIMD3<Float>(3, 4, 0)
        XCTAssertEqual(vector.length, 5.0, accuracy: 0.001)

        let unitVector = SIMD3<Float>(1, 0, 0)
        XCTAssertEqual(unitVector.length, 1.0, accuracy: 0.001)

        let zero = SIMD3<Float>(0, 0, 0)
        XCTAssertEqual(zero.length, 0.0, accuracy: 0.001)
    }

    func testSIMD3Normalized() {
        let vector = SIMD3<Float>(3, 4, 0)
        let normalized = vector.normalized

        XCTAssertEqual(normalized.length, 1.0, accuracy: 0.001)
        XCTAssertEqual(normalized.x, 0.6, accuracy: 0.001)
        XCTAssertEqual(normalized.y, 0.8, accuracy: 0.001)
    }

    func testSIMD3Distance() {
        let point1 = SIMD3<Float>(0, 0, 0)
        let point2 = SIMD3<Float>(3, 4, 0)

        let distance = point1.distance(to: point2)
        XCTAssertEqual(distance, 5.0, accuracy: 0.001)
    }

    func testSIMD3Lerp() {
        let start = SIMD3<Float>(0, 0, 0)
        let end = SIMD3<Float>(10, 10, 10)

        let mid = SIMD3<Float>.lerp(from: start, to: end, t: 0.5)
        XCTAssertEqual(mid.x, 5.0, accuracy: 0.001)
        XCTAssertEqual(mid.y, 5.0, accuracy: 0.001)
        XCTAssertEqual(mid.z, 5.0, accuracy: 0.001)

        let atStart = SIMD3<Float>.lerp(from: start, to: end, t: 0.0)
        XCTAssertEqual(atStart, start)

        let atEnd = SIMD3<Float>.lerp(from: start, to: end, t: 1.0)
        XCTAssertEqual(atEnd, end)
    }

    func testSIMD3DotProduct() {
        let v1 = SIMD3<Float>(1, 2, 3)
        let v2 = SIMD3<Float>(4, 5, 6)

        let dot = v1.dot(v2)
        XCTAssertEqual(dot, 32.0, accuracy: 0.001) // 1*4 + 2*5 + 3*6 = 32
    }

    func testSIMD3CrossProduct() {
        let xAxis = SIMD3<Float>(1, 0, 0)
        let yAxis = SIMD3<Float>(0, 1, 0)

        let cross = xAxis.cross(yAxis)
        XCTAssertEqual(cross.x, 0.0, accuracy: 0.001)
        XCTAssertEqual(cross.y, 0.0, accuracy: 0.001)
        XCTAssertEqual(cross.z, 1.0, accuracy: 0.001) // Should be z-axis
    }

    // MARK: - Geographic Utilities Tests

    func testLatLongToPosition() {
        let radius: Float = 1.5

        // North pole
        let northPole = SIMD3<Float>.fromLatLong(latitude: 90, longitude: 0, radius: radius)
        XCTAssertEqual(northPole.y, radius, accuracy: 0.001)

        // Equator at prime meridian
        let equator = SIMD3<Float>.fromLatLong(latitude: 0, longitude: 0, radius: radius)
        XCTAssertEqual(equator.x, radius, accuracy: 0.001)
        XCTAssertEqual(equator.y, 0.0, accuracy: 0.001)

        // South pole
        let southPole = SIMD3<Float>.fromLatLong(latitude: -90, longitude: 0, radius: radius)
        XCTAssertEqual(southPole.y, -radius, accuracy: 0.001)
    }

    func testPositionToLatLong() {
        let radius: Float = 1.5

        // North pole
        let northPole = SIMD3<Float>(0, radius, 0)
        let (lat1, lon1) = northPole.toLatLong(radius: radius)
        XCTAssertEqual(lat1, 90, accuracy: 0.1)

        // Equator
        let equator = SIMD3<Float>(radius, 0, 0)
        let (lat2, lon2) = equator.toLatLong(radius: radius)
        XCTAssertEqual(lat2, 0, accuracy: 0.1)
        XCTAssertEqual(lon2, 0, accuracy: 0.1)
    }

    // MARK: - Math Utilities Tests

    func testMathUtilsClamp() {
        XCTAssertEqual(MathUtils.clamp(5, min: 0, max: 10), 5)
        XCTAssertEqual(MathUtils.clamp(-5, min: 0, max: 10), 0)
        XCTAssertEqual(MathUtils.clamp(15, min: 0, max: 10), 10)
    }

    func testMathUtilsLerp() {
        XCTAssertEqual(MathUtils.lerp(from: 0, to: 10, t: 0.5), 5.0, accuracy: 0.001)
        XCTAssertEqual(MathUtils.lerp(from: 0, to: 10, t: 0.0), 0.0, accuracy: 0.001)
        XCTAssertEqual(MathUtils.lerp(from: 0, to: 10, t: 1.0), 10.0, accuracy: 0.001)
        XCTAssertEqual(MathUtils.lerp(from: 0, to: 10, t: 2.0), 10.0, accuracy: 0.001) // Clamped
    }

    func testMathUtilsSmoothstep() {
        let result = MathUtils.smoothstep(from: 0, to: 1, t: 0.5)
        XCTAssertTrue(result > 0.4 && result < 0.6) // Should be around 0.5 but smoothed
    }

    func testMathUtilsMap() {
        // Map 5 from range [0,10] to range [0,100]
        let result = MathUtils.map(value: 5, fromMin: 0, fromMax: 10, toMin: 0, toMax: 100)
        XCTAssertEqual(result, 50.0, accuracy: 0.001)
    }

    func testMathUtilsAngleConversions() {
        let degrees: Float = 180
        let radians = MathUtils.degreesToRadians(degrees)
        XCTAssertEqual(radians, Float.pi, accuracy: 0.001)

        let backToDegrees = MathUtils.radiansToDegrees(radians)
        XCTAssertEqual(backToDegrees, degrees, accuracy: 0.001)
    }

    // MARK: - Bezier Curve Tests

    func testBezierCurvePoints() {
        let start = SIMD3<Float>(0, 0, 0)
        let control = SIMD3<Float>(5, 10, 0)
        let end = SIMD3<Float>(10, 0, 0)

        let curve = BezierCurve(start: start, control: control, end: end)

        // Test endpoints
        let startPoint = curve.point(at: 0.0)
        XCTAssertEqual(startPoint, start)

        let endPoint = curve.point(at: 1.0)
        XCTAssertEqual(endPoint, end)

        // Test midpoint
        let midPoint = curve.point(at: 0.5)
        XCTAssertTrue(midPoint.y > 0) // Should be above the line
    }

    func testBezierCurveMultiplePoints() {
        let start = SIMD3<Float>(0, 0, 0)
        let control = SIMD3<Float>(5, 5, 0)
        let end = SIMD3<Float>(10, 0, 0)

        let curve = BezierCurve(start: start, control: control, end: end)
        let points = curve.points(count: 5)

        XCTAssertEqual(points.count, 5)
        XCTAssertEqual(points.first, start)
        XCTAssertEqual(points.last, end)
    }

    // MARK: - Color Utilities Tests

    func testColorLerp() {
        let red = (r: Float(1.0), g: Float(0.0), b: Float(0.0))
        let blue = (r: Float(0.0), g: Float(0.0), b: Float(1.0))

        let mid = ColorUtils.lerp(from: red, to: blue, t: 0.5)
        XCTAssertEqual(mid.r, 0.5, accuracy: 0.001)
        XCTAssertEqual(mid.g, 0.0, accuracy: 0.001)
        XCTAssertEqual(mid.b, 0.5, accuracy: 0.001)
    }

    func testEmissionColor() {
        // Test low emissions (should be greenish)
        let lowColor = ColorUtils.emissionColor(value: 0, min: 0, max: 100)
        XCTAssertTrue(lowColor.g > 0.5) // More green

        // Test high emissions (should be reddish)
        let highColor = ColorUtils.emissionColor(value: 100, min: 0, max: 100)
        XCTAssertTrue(highColor.r > 0.5) // More red

        // Test mid emissions (should be yellowish)
        let midColor = ColorUtils.emissionColor(value: 50, min: 0, max: 100)
        XCTAssertTrue(midColor.r > 0.5 && midColor.g > 0.5) // Yellow
    }
}
