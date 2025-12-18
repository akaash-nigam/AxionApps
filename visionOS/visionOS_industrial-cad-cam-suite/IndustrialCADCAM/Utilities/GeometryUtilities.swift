import Foundation
import simd

/// Utilities for geometric calculations in CAD operations
public enum GeometryUtilities {

    // MARK: - Volume Calculations

    /// Calculate volume of a rectangular prism (cuboid)
    /// - Parameters:
    ///   - width: Width in millimeters
    ///   - height: Height in millimeters
    ///   - depth: Depth in millimeters
    /// - Returns: Volume in cubic millimeters
    public static func volumeOfCuboid(width: Double, height: Double, depth: Double) -> Double {
        guard width > 0, height > 0, depth > 0 else { return 0 }
        return width * height * depth
    }

    /// Calculate volume of a cylinder
    /// - Parameters:
    ///   - diameter: Diameter in millimeters
    ///   - height: Height in millimeters
    /// - Returns: Volume in cubic millimeters
    public static func volumeOfCylinder(diameter: Double, height: Double) -> Double {
        guard diameter > 0, height > 0 else { return 0 }
        let radius = diameter / 2.0
        return Double.pi * radius * radius * height
    }

    /// Calculate volume of a sphere
    /// - Parameter diameter: Diameter in millimeters
    /// - Returns: Volume in cubic millimeters
    public static func volumeOfSphere(diameter: Double) -> Double {
        guard diameter > 0 else { return 0 }
        let radius = diameter / 2.0
        return (4.0 / 3.0) * Double.pi * radius * radius * radius
    }

    /// Calculate volume of a cone
    /// - Parameters:
    ///   - diameter: Base diameter in millimeters
    ///   - height: Height in millimeters
    /// - Returns: Volume in cubic millimeters
    public static func volumeOfCone(diameter: Double, height: Double) -> Double {
        guard diameter > 0, height > 0 else { return 0 }
        let radius = diameter / 2.0
        return (1.0 / 3.0) * Double.pi * radius * radius * height
    }

    // MARK: - Surface Area Calculations

    /// Calculate surface area of a rectangular prism (cuboid)
    /// - Parameters:
    ///   - width: Width in millimeters
    ///   - height: Height in millimeters
    ///   - depth: Depth in millimeters
    /// - Returns: Surface area in square millimeters
    public static func surfaceAreaOfCuboid(width: Double, height: Double, depth: Double) -> Double {
        guard width > 0, height > 0, depth > 0 else { return 0 }
        return 2 * (width * height + width * depth + height * depth)
    }

    /// Calculate surface area of a cylinder
    /// - Parameters:
    ///   - diameter: Diameter in millimeters
    ///   - height: Height in millimeters
    /// - Returns: Surface area in square millimeters
    public static func surfaceAreaOfCylinder(diameter: Double, height: Double) -> Double {
        guard diameter > 0, height > 0 else { return 0 }
        let radius = diameter / 2.0
        return 2 * Double.pi * radius * (radius + height)
    }

    /// Calculate surface area of a sphere
    /// - Parameter diameter: Diameter in millimeters
    /// - Returns: Surface area in square millimeters
    public static func surfaceAreaOfSphere(diameter: Double) -> Double {
        guard diameter > 0 else { return 0 }
        let radius = diameter / 2.0
        return 4 * Double.pi * radius * radius
    }

    // MARK: - Centroid Calculations

    /// Calculate centroid of a collection of 3D points
    /// - Parameter points: Array of 3D points
    /// - Returns: Centroid point
    public static func calculateCentroid(_ points: [SIMD3<Float>]) -> SIMD3<Float> {
        guard !points.isEmpty else { return .zero }
        let sum = points.reduce(SIMD3<Float>.zero) { $0 + $1 }
        return sum / Float(points.count)
    }

    // MARK: - Bounding Box Calculations

    /// Calculate axis-aligned bounding box for a set of points
    /// - Parameter points: Array of 3D points
    /// - Returns: Tuple of (min, max) points defining the bounding box
    public static func calculateBoundingBox(_ points: [SIMD3<Float>]) -> (min: SIMD3<Float>, max: SIMD3<Float>)? {
        guard !points.isEmpty else { return nil }

        var minPoint = points[0]
        var maxPoint = points[0]

        for point in points {
            minPoint = simd_min(minPoint, point)
            maxPoint = simd_max(maxPoint, point)
        }

        return (minPoint, maxPoint)
    }

    /// Calculate dimensions from bounding box
    /// - Parameter boundingBox: Tuple of (min, max) points
    /// - Returns: SIMD3 with width, height, depth
    public static func dimensionsFromBoundingBox(_ boundingBox: (min: SIMD3<Float>, max: SIMD3<Float>)) -> SIMD3<Float> {
        return boundingBox.max - boundingBox.min
    }

    // MARK: - Distance Calculations

    /// Calculate Euclidean distance between two 3D points
    /// - Parameters:
    ///   - point1: First point
    ///   - point2: Second point
    /// - Returns: Distance
    public static func distance(from point1: SIMD3<Float>, to point2: SIMD3<Float>) -> Float {
        return simd_distance(point1, point2)
    }

    /// Calculate distance from a point to a line segment
    /// - Parameters:
    ///   - point: The point
    ///   - lineStart: Start of line segment
    ///   - lineEnd: End of line segment
    /// - Returns: Shortest distance
    public static func distanceFromPointToLineSegment(
        point: SIMD3<Float>,
        lineStart: SIMD3<Float>,
        lineEnd: SIMD3<Float>
    ) -> Float {
        let lineVector = lineEnd - lineStart
        let pointVector = point - lineStart

        let lineLength = simd_length(lineVector)
        guard lineLength > 0 else { return simd_distance(point, lineStart) }

        let normalizedLine = lineVector / lineLength
        let projection = simd_dot(pointVector, normalizedLine)

        if projection <= 0 {
            return simd_distance(point, lineStart)
        } else if projection >= lineLength {
            return simd_distance(point, lineEnd)
        } else {
            let closestPoint = lineStart + normalizedLine * projection
            return simd_distance(point, closestPoint)
        }
    }

    // MARK: - Angle Calculations

    /// Calculate angle between two vectors in radians
    /// - Parameters:
    ///   - vector1: First vector
    ///   - vector2: Second vector
    /// - Returns: Angle in radians
    public static func angleBetweenVectors(_ vector1: SIMD3<Float>, _ vector2: SIMD3<Float>) -> Float {
        let dot = simd_dot(simd_normalize(vector1), simd_normalize(vector2))
        return acos(simd_clamp(dot, -1.0, 1.0))
    }

    /// Convert radians to degrees
    /// - Parameter radians: Angle in radians
    /// - Returns: Angle in degrees
    public static func radiansToDegrees(_ radians: Double) -> Double {
        return radians * 180.0 / Double.pi
    }

    /// Convert degrees to radians
    /// - Parameter degrees: Angle in degrees
    /// - Returns: Angle in radians
    public static func degreesToRadians(_ degrees: Double) -> Double {
        return degrees * Double.pi / 180.0
    }

    // MARK: - Intersection Tests

    /// Test if a ray intersects with a sphere
    /// - Parameters:
    ///   - rayOrigin: Origin of the ray
    ///   - rayDirection: Direction of the ray (should be normalized)
    ///   - sphereCenter: Center of the sphere
    ///   - sphereRadius: Radius of the sphere
    /// - Returns: True if intersection exists
    public static func rayIntersectsSphere(
        rayOrigin: SIMD3<Float>,
        rayDirection: SIMD3<Float>,
        sphereCenter: SIMD3<Float>,
        sphereRadius: Float
    ) -> Bool {
        let oc = rayOrigin - sphereCenter
        let a = simd_dot(rayDirection, rayDirection)
        let b = 2.0 * simd_dot(oc, rayDirection)
        let c = simd_dot(oc, oc) - sphereRadius * sphereRadius
        let discriminant = b * b - 4 * a * c
        return discriminant >= 0
    }

    // MARK: - Area Calculations

    /// Calculate area of a triangle given three vertices
    /// - Parameters:
    ///   - v1: First vertex
    ///   - v2: Second vertex
    ///   - v3: Third vertex
    /// - Returns: Area of the triangle
    public static func triangleArea(v1: SIMD3<Float>, v2: SIMD3<Float>, v3: SIMD3<Float>) -> Float {
        let edge1 = v2 - v1
        let edge2 = v3 - v1
        let cross = simd_cross(edge1, edge2)
        return simd_length(cross) * 0.5
    }

    // MARK: - Normal Calculations

    /// Calculate surface normal for a triangle
    /// - Parameters:
    ///   - v1: First vertex
    ///   - v2: Second vertex
    ///   - v3: Third vertex
    /// - Returns: Normalized surface normal
    public static func triangleNormal(v1: SIMD3<Float>, v2: SIMD3<Float>, v3: SIMD3<Float>) -> SIMD3<Float> {
        let edge1 = v2 - v1
        let edge2 = v3 - v1
        return simd_normalize(simd_cross(edge1, edge2))
    }

    // MARK: - Tolerance Comparison

    /// Compare two floating point values with tolerance
    /// - Parameters:
    ///   - value1: First value
    ///   - value2: Second value
    ///   - tolerance: Tolerance (default: 0.0001)
    /// - Returns: True if values are equal within tolerance
    public static func isEqual(_ value1: Double, _ value2: Double, tolerance: Double = 0.0001) -> Bool {
        return abs(value1 - value2) < tolerance
    }

    /// Compare two 3D points with tolerance
    /// - Parameters:
    ///   - point1: First point
    ///   - point2: Second point
    ///   - tolerance: Tolerance (default: 0.0001)
    /// - Returns: True if points are equal within tolerance
    public static func isEqual(_ point1: SIMD3<Float>, _ point2: SIMD3<Float>, tolerance: Float = 0.0001) -> Bool {
        return simd_distance(point1, point2) < tolerance
    }
}
