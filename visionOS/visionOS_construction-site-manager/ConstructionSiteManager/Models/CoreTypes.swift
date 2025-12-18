//
//  CoreTypes.swift
//  Construction Site Manager
//
//  Core type definitions and enumerations
//

import Foundation
import SwiftUI
import simd

// MARK: - Enumerations

/// Type of construction project
enum ProjectType: String, Codable, CaseIterable {
    case residential
    case commercial
    case industrial
    case infrastructure
    case renovation

    var displayName: String {
        switch self {
        case .residential: return "Residential"
        case .commercial: return "Commercial"
        case .industrial: return "Industrial"
        case .infrastructure: return "Infrastructure"
        case .renovation: return "Renovation"
        }
    }
}

/// Building discipline/trade
enum Discipline: String, Codable, CaseIterable {
    case architectural
    case structural
    case mechanical
    case electrical
    case plumbing
    case fireProtection
    case civilEngineering

    var displayName: String {
        switch self {
        case .architectural: return "Architectural"
        case .structural: return "Structural"
        case .mechanical: return "Mechanical"
        case .electrical: return "Electrical"
        case .plumbing: return "Plumbing"
        case .fireProtection: return "Fire Protection"
        case .civilEngineering: return "Civil Engineering"
        }
    }

    var color: Color {
        switch self {
        case .architectural: return Color(hex: "#8D6E63")  // Brown
        case .structural: return Color(hex: "#757575")     // Dark Gray
        case .mechanical: return Color(hex: "#2196F3")     // Blue
        case .electrical: return Color(hex: "#FFC107")     // Amber
        case .plumbing: return Color(hex: "#4CAF50")       // Green
        case .fireProtection: return Color(hex: "#F44336") // Red
        case .civilEngineering: return Color(hex: "#9C27B0") // Purple
        }
    }
}

/// Status of construction element
enum ElementStatus: String, Codable, CaseIterable, Comparable {
    case notStarted
    case inProgress
    case completed
    case approved
    case rejected
    case onHold

    var displayName: String {
        switch self {
        case .notStarted: return "Not Started"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        case .approved: return "Approved"
        case .rejected: return "Rejected"
        case .onHold: return "On Hold"
        }
    }

    var color: Color {
        switch self {
        case .notStarted: return Color(hex: "#CCCCCC")  // Gray
        case .inProgress: return Color(hex: "#FFA500")  // Orange
        case .completed: return Color(hex: "#4CAF50")   // Green
        case .approved: return Color(hex: "#2196F3")    // Blue
        case .rejected: return Color(hex: "#F44336")    // Red
        case .onHold: return Color(hex: "#9C27B0")      // Purple
        }
    }

    static func < (lhs: ElementStatus, rhs: ElementStatus) -> Bool {
        let order: [ElementStatus] = [.notStarted, .inProgress, .completed, .approved, .onHold, .rejected]
        return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
    }
}

/// Type of safety hazard
enum DangerType: String, Codable, CaseIterable {
    case fallHazard
    case craneOperatingZone
    case excavation
    case confinedSpace
    case heavyEquipment
    case electricalWork
    case hotWork
    case overhead

    var displayName: String {
        switch self {
        case .fallHazard: return "Fall Hazard"
        case .craneOperatingZone: return "Crane Operating Zone"
        case .excavation: return "Excavation"
        case .confinedSpace: return "Confined Space"
        case .heavyEquipment: return "Heavy Equipment"
        case .electricalWork: return "Electrical Work"
        case .hotWork: return "Hot Work"
        case .overhead: return "Overhead Hazard"
        }
    }

    var icon: String {
        switch self {
        case .fallHazard: return "arrow.down.circle.fill"
        case .craneOperatingZone: return "crane.fill"
        case .excavation: return "arrow.down.to.line"
        case .confinedSpace: return "door.left.hand.closed"
        case .heavyEquipment: return "truck.box.fill"
        case .electricalWork: return "bolt.fill"
        case .hotWork: return "flame.fill"
        case .overhead: return "arrow.up.circle.fill"
        }
    }
}

/// Safety severity level
enum SafetySeverity: String, Codable, CaseIterable, Comparable {
    case low
    case medium
    case high
    case critical

    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .critical: return "Critical"
        }
    }

    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .orange
        case .critical: return .red
        }
    }

    static func < (lhs: SafetySeverity, rhs: SafetySeverity) -> Bool {
        let order: [SafetySeverity] = [.low, .medium, .high, .critical]
        return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
    }
}

/// BIM file format
enum BIMFormat: String, Codable {
    case ifc = "IFC"
    case rvt = "RVT"
    case dwg = "DWG"
    case usdz = "USDZ"

    var fileExtension: String {
        rawValue.lowercased()
    }
}

/// Issue priority level
enum IssuePriority: String, Codable, CaseIterable, Comparable {
    case low
    case medium
    case high
    case critical

    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .critical: return "Critical"
        }
    }

    var color: Color {
        switch self {
        case .low: return .blue
        case .medium: return .yellow
        case .high: return .orange
        case .critical: return .red
        }
    }

    var icon: String {
        switch self {
        case .low: return "arrow.down.circle"
        case .medium: return "equal.circle"
        case .high: return "arrow.up.circle"
        case .critical: return "exclamationmark.triangle.fill"
        }
    }

    static func < (lhs: IssuePriority, rhs: IssuePriority) -> Bool {
        let order: [IssuePriority] = [.low, .medium, .high, .critical]
        return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
    }
}

/// Issue type
enum IssueType: String, Codable, CaseIterable {
    case quality
    case safety
    case coordination
    case design
    case scheduling
    case cost

    var displayName: String {
        switch self {
        case .quality: return "Quality"
        case .safety: return "Safety"
        case .coordination: return "Coordination"
        case .design: return "Design"
        case .scheduling: return "Scheduling"
        case .cost: return "Cost"
        }
    }

    var icon: String {
        switch self {
        case .quality: return "checkmark.seal"
        case .safety: return "exclamationmark.triangle"
        case .coordination: return "arrow.triangle.merge"
        case .design: return "pencil.and.ruler"
        case .scheduling: return "calendar"
        case .cost: return "dollarsign.circle"
        }
    }
}

/// Issue status
enum IssueStatus: String, Codable, CaseIterable {
    case open
    case inProgress
    case resolved
    case closed
    case rejected

    var displayName: String {
        switch self {
        case .open: return "Open"
        case .inProgress: return "In Progress"
        case .resolved: return "Resolved"
        case .closed: return "Closed"
        case .rejected: return "Rejected"
        }
    }

    var color: Color {
        switch self {
        case .open: return .red
        case .inProgress: return .orange
        case .resolved: return .blue
        case .closed: return .green
        case .rejected: return .gray
        }
    }

    var icon: String {
        switch self {
        case .open: return "circle"
        case .inProgress: return "clock"
        case .resolved: return "checkmark.circle"
        case .closed: return "checkmark.circle.fill"
        case .rejected: return "xmark.circle"
        }
    }
}

// MARK: - Value Types

/// 3D transformation (position, rotation, scale)
struct Transform3D: Equatable {
    var position: SIMD3<Float>
    var rotation: simd_quatf
    var scale: SIMD3<Float>

    init(
        position: SIMD3<Float> = .zero,
        rotation: simd_quatf = simd_quatf(angle: 0, axis: [0, 1, 0]),
        scale: SIMD3<Float> = SIMD3<Float>(repeating: 1.0)
    ) {
        self.position = position
        self.rotation = rotation
        self.scale = scale
    }

    /// Convert to 4x4 transformation matrix
    func toMatrix() -> float4x4 {
        let translationMatrix = float4x4(translation: position)
        let rotationMatrix = float4x4(rotation)
        let scaleMatrix = float4x4(scale: scale)
        return translationMatrix * rotationMatrix * scaleMatrix
    }
}

extension Transform3D: Codable {
    enum CodingKeys: String, CodingKey {
        case position, rotation, scale
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode([position.x, position.y, position.z], forKey: .position)
        try container.encode([rotation.vector.x, rotation.vector.y, rotation.vector.z, rotation.vector.w], forKey: .rotation)
        try container.encode([scale.x, scale.y, scale.z], forKey: .scale)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let posArray = try container.decode([Float].self, forKey: .position)
        let rotArray = try container.decode([Float].self, forKey: .rotation)
        let scaleArray = try container.decode([Float].self, forKey: .scale)

        self.position = SIMD3<Float>(posArray[0], posArray[1], posArray[2])
        self.rotation = simd_quatf(ix: rotArray[0], iy: rotArray[1], iz: rotArray[2], r: rotArray[3])
        self.scale = SIMD3<Float>(scaleArray[0], scaleArray[1], scaleArray[2])
    }
}

/// Site coordinate (georeferenced)
struct SiteCoordinate: Codable, Equatable {
    var x: Double  // Easting
    var y: Double  // Northing
    var elevation: Double
    var coordinateSystem: String  // e.g., "EPSG:4326"

    init(x: Double, y: Double, elevation: Double, coordinateSystem: String = "EPSG:4326") {
        self.x = x
        self.y = y
        self.elevation = elevation
        self.coordinateSystem = coordinateSystem
    }
}

/// Address information
struct Address: Codable, Equatable {
    var street: String
    var city: String
    var state: String
    var zipCode: String
    var country: String

    var formatted: String {
        "\(street), \(city), \(state) \(zipCode), \(country)"
    }
}

// MARK: - Helper Extensions

extension Color {
    /// Initialize Color from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension float4x4 {
    /// Create translation matrix
    init(translation: SIMD3<Float>) {
        self.init(
            SIMD4<Float>(1, 0, 0, 0),
            SIMD4<Float>(0, 1, 0, 0),
            SIMD4<Float>(0, 0, 1, 0),
            SIMD4<Float>(translation.x, translation.y, translation.z, 1)
        )
    }

    /// Create scale matrix
    init(scale: SIMD3<Float>) {
        self.init(
            SIMD4<Float>(scale.x, 0, 0, 0),
            SIMD4<Float>(0, scale.y, 0, 0),
            SIMD4<Float>(0, 0, scale.z, 0),
            SIMD4<Float>(0, 0, 0, 1)
        )
    }

    /// Create rotation matrix from quaternion
    init(_ quaternion: simd_quatf) {
        let matrix = simd_matrix4x4(quaternion)
        self = matrix
    }
}
