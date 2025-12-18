import Foundation
import simd

// MARK: - SIMD3 Extensions

extension SIMD3 where Scalar == Float {
    /// Returns the length (magnitude) of the vector
    var length: Float {
        sqrt(x * x + y * y + z * z)
    }

    /// Returns a normalized version of the vector
    var normalized: SIMD3<Float> {
        let len = length
        return len > 0 ? self / len : self
    }

    /// Returns the distance between two points
    func distance(to other: SIMD3<Float>) -> Float {
        (self - other).length
    }

    /// Linear interpolation between two vectors
    static func lerp(from: SIMD3<Float>, to: SIMD3<Float>, t: Float) -> SIMD3<Float> {
        from + (to - from) * t
    }

    /// Dot product
    func dot(_ other: SIMD3<Float>) -> Float {
        x * other.x + y * other.y + z * other.z
    }

    /// Cross product
    func cross(_ other: SIMD3<Float>) -> SIMD3<Float> {
        SIMD3<Float>(
            y * other.z - z * other.y,
            z * other.x - x * other.z,
            x * other.y - y * other.x
        )
    }

    /// Returns a string representation
    var description: String {
        String(format: "(%.2f, %.2f, %.2f)", x, y, z)
    }
}

// MARK: - Geographic Utilities

extension SIMD3 where Scalar == Float {
    /// Creates a position on a sphere from latitude/longitude
    /// - Parameters:
    ///   - latitude: Latitude in degrees (-90 to 90)
    ///   - longitude: Longitude in degrees (-180 to 180)
    ///   - radius: Radius of the sphere
    /// - Returns: 3D position on the sphere
    static func fromLatLong(
        latitude: Double,
        longitude: Double,
        radius: Float
    ) -> SIMD3<Float> {
        let lat = Float(latitude) * .pi / 180.0
        let lon = Float(longitude) * .pi / 180.0

        let x = radius * cos(lat) * cos(lon)
        let y = radius * sin(lat)
        let z = radius * cos(lat) * sin(lon)

        return SIMD3<Float>(x, y, z)
    }

    /// Converts a position on a sphere to latitude/longitude
    /// - Parameter radius: Radius of the sphere
    /// - Returns: Tuple of (latitude, longitude) in degrees
    func toLatLong(radius: Float) -> (latitude: Double, longitude: Double) {
        let lat = asin(y / radius)
        let lon = atan2(z, x)

        return (
            latitude: Double(lat) * 180.0 / .pi,
            longitude: Double(lon) * 180.0 / .pi
        )
    }
}

// MARK: - Quaternion Extensions

extension simd_quatf {
    /// Creates a quaternion from Euler angles (in radians)
    /// - Parameters:
    ///   - pitch: Rotation around X axis
    ///   - yaw: Rotation around Y axis
    ///   - roll: Rotation around Z axis
    init(pitch: Float, yaw: Float, roll: Float) {
        let cy = cos(yaw * 0.5)
        let sy = sin(yaw * 0.5)
        let cp = cos(pitch * 0.5)
        let sp = sin(pitch * 0.5)
        let cr = cos(roll * 0.5)
        let sr = sin(roll * 0.5)

        self.init(
            ix: sr * cp * cy - cr * sp * sy,
            iy: cr * sp * cy + sr * cp * sy,
            iz: cr * cp * sy - sr * sp * cy,
            r: cr * cp * cy + sr * sp * sy
        )
    }

    /// Returns the Euler angles (in radians)
    var eulerAngles: (pitch: Float, yaw: Float, roll: Float) {
        let sinr_cosp = 2 * (real * imag.x + imag.y * imag.z)
        let cosr_cosp = 1 - 2 * (imag.x * imag.x + imag.y * imag.y)
        let roll = atan2(sinr_cosp, cosr_cosp)

        let sinp = 2 * (real * imag.y - imag.z * imag.x)
        let pitch = abs(sinp) >= 1 ? copysign(.pi / 2, sinp) : asin(sinp)

        let siny_cosp = 2 * (real * imag.z + imag.x * imag.y)
        let cosy_cosp = 1 - 2 * (imag.y * imag.y + imag.z * imag.z)
        let yaw = atan2(siny_cosp, cosy_cosp)

        return (pitch, yaw, roll)
    }
}

// MARK: - Math Utilities

enum MathUtils {
    /// Clamps a value between min and max
    static func clamp<T: Comparable>(_ value: T, min: T, max: T) -> T {
        Swift.min(Swift.max(value, min), max)
    }

    /// Linear interpolation
    static func lerp(from: Float, to: Float, t: Float) -> Float {
        from + (to - from) * clamp(t, min: 0, max: 1)
    }

    /// Smooth interpolation (smoothstep)
    static func smoothstep(from: Float, to: Float, t: Float) -> Float {
        let x = clamp((t - from) / (to - from), min: 0, max: 1)
        return x * x * (3 - 2 * x)
    }

    /// Maps a value from one range to another
    static func map(
        value: Float,
        fromMin: Float,
        fromMax: Float,
        toMin: Float,
        toMax: Float
    ) -> Float {
        let normalized = (value - fromMin) / (fromMax - fromMin)
        return toMin + normalized * (toMax - toMin)
    }

    /// Converts degrees to radians
    static func degreesToRadians(_ degrees: Float) -> Float {
        degrees * .pi / 180.0
    }

    /// Converts radians to degrees
    static func radiansToDegrees(_ radians: Float) -> Float {
        radians * 180.0 / .pi
    }
}

// MARK: - Bezier Curve Utilities

struct BezierCurve {
    let start: SIMD3<Float>
    let control: SIMD3<Float>
    let end: SIMD3<Float>

    /// Returns a point on the curve at parameter t (0 to 1)
    func point(at t: Float) -> SIMD3<Float> {
        let oneMinusT = 1 - t
        let term1 = oneMinusT * oneMinusT * start
        let term2 = 2 * oneMinusT * t * control
        let term3 = t * t * end
        return term1 + term2 + term3
    }

    /// Returns multiple points along the curve
    func points(count: Int) -> [SIMD3<Float>] {
        guard count > 1 else { return [start] }
        return (0..<count).map { i in
            let t = Float(i) / Float(count - 1)
            return point(at: t)
        }
    }

    /// Returns the tangent (direction) at parameter t
    func tangent(at t: Float) -> SIMD3<Float> {
        let oneMinusT = 1 - t
        let term1 = 2 * oneMinusT * (control - start)
        let term2 = 2 * t * (end - control)
        return (term1 + term2).normalized
    }

    /// Creates a control point for an arc between two points on a sphere
    static func arcControlPoint(
        from start: SIMD3<Float>,
        to end: SIMD3<Float>,
        height: Float
    ) -> SIMD3<Float> {
        let midpoint = (start + end) / 2
        let direction = midpoint.normalized
        return midpoint + direction * height
    }
}

// MARK: - Color Utilities

struct ColorUtils {
    /// Interpolates between two colors
    static func lerp(
        from: (r: Float, g: Float, b: Float),
        to: (r: Float, g: Float, b: Float),
        t: Float
    ) -> (r: Float, g: Float, b: Float) {
        let clampedT = MathUtils.clamp(t, min: 0, max: 1)
        return (
            r: from.r + (to.r - from.r) * clampedT,
            g: from.g + (to.g - from.g) * clampedT,
            b: from.b + (to.b - from.b) * clampedT
        )
    }

    /// Returns a color for a value in a gradient (green to yellow to red)
    static func emissionColor(value: Double, min: Double, max: Double) -> (r: Float, g: Float, b: Float) {
        let normalized = Float((value - min) / (max - min))
        let clamped = MathUtils.clamp(normalized, min: 0, max: 1)

        if clamped < 0.5 {
            // Green to Yellow
            let t = clamped * 2
            return lerp(
                from: (r: 0.2, g: 0.78, b: 0.35), // Green
                to: (r: 0.95, g: 0.77, b: 0.06),  // Yellow
                t: t
            )
        } else {
            // Yellow to Red
            let t = (clamped - 0.5) * 2
            return lerp(
                from: (r: 0.95, g: 0.77, b: 0.06), // Yellow
                to: (r: 0.89, g: 0.24, b: 0.21),   // Red
                t: t
            )
        }
    }
}
