//
//  GeometryExtensions.swift
//  SupplyChainControlTower
//
//  Geometry and coordinate conversion utilities
//

import Foundation
import simd

// MARK: - Geographic Coordinate Extensions

extension GeographicCoordinate {
    /// Convert geographic coordinates to 3D Cartesian coordinates on a sphere
    func toCartesian(radius: Float) -> SIMD3<Float> {
        let lat = Float(latitude) * .pi / 180
        let lon = Float(longitude) * .pi / 180

        let x = radius * cos(lat) * cos(lon)
        let y = radius * sin(lat)
        let z = radius * cos(lat) * sin(lon)

        return SIMD3(x: x, y: y, z: z)
    }

    /// Calculate distance to another coordinate in kilometers
    func distance(to other: GeographicCoordinate) -> Double {
        let earthRadius = 6371.0 // km

        let lat1 = latitude * .pi / 180
        let lat2 = other.latitude * .pi / 180
        let deltaLat = (other.latitude - latitude) * .pi / 180
        let deltaLon = (other.longitude - longitude) * .pi / 180

        let a = sin(deltaLat / 2) * sin(deltaLat / 2) +
                cos(lat1) * cos(lat2) *
                sin(deltaLon / 2) * sin(deltaLon / 2)

        let c = 2 * atan2(sqrt(a), sqrt(1 - a))

        return earthRadius * c
    }

    /// Calculate bearing to another coordinate in degrees
    func bearing(to other: GeographicCoordinate) -> Double {
        let lat1 = latitude * .pi / 180
        let lat2 = other.latitude * .pi / 180
        let deltaLon = (other.longitude - longitude) * .pi / 180

        let y = sin(deltaLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLon)
        let bearing = atan2(y, x)

        return (bearing * 180 / .pi + 360).truncatingRemainder(dividingBy: 360)
    }

    /// Get intermediate point along great circle route
    func intermediate(to destination: GeographicCoordinate, fraction: Double) -> GeographicCoordinate {
        let d = distance(to: destination)
        let earthRadius = 6371.0
        let delta = d / earthRadius

        let lat1 = latitude * .pi / 180
        let lon1 = longitude * .pi / 180
        let lat2 = destination.latitude * .pi / 180
        let lon2 = destination.longitude * .pi / 180

        let a = sin((1 - fraction) * delta) / sin(delta)
        let b = sin(fraction * delta) / sin(delta)

        let x = a * cos(lat1) * cos(lon1) + b * cos(lat2) * cos(lon2)
        let y = a * cos(lat1) * sin(lon1) + b * cos(lat2) * sin(lon2)
        let z = a * sin(lat1) + b * sin(lat2)

        let lat = atan2(z, sqrt(x * x + y * y))
        let lon = atan2(y, x)

        return GeographicCoordinate(
            latitude: lat * 180 / .pi,
            longitude: lon * 180 / .pi
        )
    }
}

// MARK: - SIMD Extensions

extension SIMD3 where Scalar == Float {
    /// Normalize vector (unit vector)
    var normalized: SIMD3<Float> {
        let len = length(self)
        return len > 0 ? self / len : self
    }

    /// Linear interpolation
    func lerp(to: SIMD3<Float>, t: Float) -> SIMD3<Float> {
        return self + (to - self) * t
    }

    /// Spherical linear interpolation (for rotations)
    func slerp(to: SIMD3<Float>, t: Float) -> SIMD3<Float> {
        let dot = simd_dot(self.normalized, to.normalized)
        let clampedDot = max(-1, min(1, dot))
        let theta = acos(clampedDot) * t

        let relative = (to - self * clampedDot).normalized
        return self * cos(theta) + relative * sin(theta)
    }
}

// MARK: - Route Calculations

extension Route {
    /// Generate waypoints along the route using great circle interpolation
    static func generateWaypoints(
        from start: GeographicCoordinate,
        to end: GeographicCoordinate,
        numPoints: Int = 20
    ) -> [GeographicCoordinate] {
        var waypoints: [GeographicCoordinate] = []

        for i in 0...numPoints {
            let fraction = Double(i) / Double(numPoints)
            let point = start.intermediate(to: end, fraction: fraction)
            waypoints.append(point)
        }

        return waypoints
    }

    /// Calculate total route distance
    var totalDistance: Double {
        var total = 0.0
        for i in 0..<(waypoints.count - 1) {
            total += waypoints[i].distance(to: waypoints[i + 1])
        }
        return total
    }
}

// MARK: - Math Utilities

struct MathUtils {
    /// Clamp value between min and max
    static func clamp<T: Comparable>(_ value: T, min minValue: T, max maxValue: T) -> T {
        return max(minValue, min(maxValue, value))
    }

    /// Map value from one range to another
    static func map(
        _ value: Double,
        fromMin: Double,
        fromMax: Double,
        toMin: Double,
        toMax: Double
    ) -> Double {
        let normalized = (value - fromMin) / (fromMax - fromMin)
        return toMin + normalized * (toMax - toMin)
    }

    /// Smooth step interpolation
    static func smoothStep(_ t: Double) -> Double {
        let x = clamp(t, min: 0.0, max: 1.0)
        return x * x * (3.0 - 2.0 * x)
    }

    /// Smoother step interpolation (Ken Perlin)
    static func smootherStep(_ t: Double) -> Double {
        let x = clamp(t, min: 0.0, max: 1.0)
        return x * x * x * (x * (x * 6.0 - 15.0) + 10.0)
    }
}

// MARK: - Color Utilities

import SwiftUI

extension Color {
    /// Create color from status
    static func from(status: NodeStatus) -> Color {
        switch status {
        case .healthy: return .green
        case .warning: return .yellow
        case .critical: return .red
        case .offline: return .gray
        }
    }

    /// Create color from flow status
    static func from(flowStatus: FlowStatus) -> Color {
        switch flowStatus {
        case .pending: return .blue
        case .inTransit: return .green
        case .delayed: return .orange
        case .delivered: return .green
        case .cancelled: return .red
        }
    }

    /// Create color from severity
    static func from(severity: Severity) -> Color {
        switch severity {
        case .low: return .blue
        case .medium: return .yellow
        case .high: return .orange
        case .critical: return .red
        }
    }

    /// Interpolate between two colors
    func interpolate(to: Color, fraction: Double) -> Color {
        // Simplified - in production would convert to RGB and interpolate
        return fraction < 0.5 ? self : to
    }
}

// MARK: - Date Extensions

extension Date {
    /// Format as relative time (e.g., "2 hours ago")
    var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    /// Format as ETA (e.g., "2h 15m")
    var etaFormat: String {
        let interval = timeIntervalSinceNow

        guard interval > 0 else { return "Overdue" }

        let hours = Int(interval / 3600)
        let minutes = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Collection Extensions

extension Collection {
    /// Safe subscript that returns nil instead of crashing
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Array where Element: Hashable {
    /// Remove duplicates while preserving order
    func removingDuplicates() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
