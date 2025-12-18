import Foundation
import simd

/// Manages building placement validation and logic
final class BuildingPlacementSystem {
    // MARK: - Properties

    /// Grid cell size for snapping (in meters)
    let gridSize: Float = 0.05  // 5cm grid cells

    /// Snap threshold distance (in meters)
    let snapThreshold: Float = 0.025  // 2.5cm snap distance

    /// Maximum road distance for building access (in meters)
    let maxRoadDistance: Float = 0.15  // 15cm

    // MARK: - Public Methods

    /// Check if a building can be placed at the given position
    /// - Parameters:
    ///   - position: The proposed position for the building
    ///   - type: The type of building to place
    ///   - cityData: The current city data
    /// - Returns: True if placement is valid, false otherwise
    func canPlaceBuilding(
        at position: SIMD3<Float>,
        type: BuildingType,
        cityData: CityData
    ) -> Bool {
        // Check zone compatibility
        guard isValidZone(position, for: type, zones: cityData.zones) else {
            return false
        }

        // Check for overlaps with existing buildings
        guard !hasOverlap(
            at: position,
            size: type.footprint,
            buildings: cityData.buildings
        ) else {
            return false
        }

        // Check terrain suitability (within bounds)
        guard isValidTerrain(at: position, surfaceSize: cityData.surfaceSize) else {
            return false
        }

        // Check road access (if roads exist)
        if !cityData.roads.isEmpty {
            guard hasRoadAccess(position, within: maxRoadDistance, roads: cityData.roads) else {
                return false
            }
        }

        return true
    }

    /// Snap position to grid
    /// - Parameter position: The position to snap
    /// - Returns: The snapped position
    func snapToGrid(_ position: SIMD3<Float>) -> SIMD3<Float> {
        return SIMD3(
            round(position.x / gridSize) * gridSize,
            position.y,  // Keep Y unchanged
            round(position.z / gridSize) * gridSize
        )
    }

    /// Create a building with validation
    /// - Parameters:
    ///   - type: The type of building to create
    ///   - position: The position to place the building
    ///   - cityData: The current city data
    /// - Returns: A new building if placement is valid, nil otherwise
    func createBuilding(
        type: BuildingType,
        at position: SIMD3<Float>,
        cityData: CityData
    ) -> Building? {
        guard canPlaceBuilding(at: position, type: type, cityData: cityData) else {
            return nil
        }

        let snappedPosition = snapToGrid(position)

        return Building(
            type: type,
            position: snappedPosition,
            capacity: defaultCapacity(for: type),
            constructionProgress: 0.0
        )
    }

    // MARK: - Private Methods

    /// Check if position is in a valid zone for the building type
    private func isValidZone(
        _ position: SIMD3<Float>,
        for type: BuildingType,
        zones: [Zone]
    ) -> Bool {
        // If no zones defined, allow anywhere
        guard !zones.isEmpty else { return true }

        let position2D = SIMD2(position.x, position.z)

        for zone in zones {
            if isPointInPolygon(position2D, polygon: zone.area) {
                // Check zone compatibility
                return isZoneCompatible(buildingType: type, zoneType: zone.zoneType)
            }
        }

        // Not in any zone
        return false
    }

    /// Check if building type is compatible with zone type
    private func isZoneCompatible(buildingType: BuildingType, zoneType: ZoneType) -> Bool {
        switch (buildingType, zoneType) {
        case (.residential, .residential), (.residential, .mixed):
            return true
        case (.commercial, .commercial), (.commercial, .mixed):
            return true
        case (.industrial, .industrial):
            return true
        case (.infrastructure, _):
            return true  // Infrastructure can go anywhere
        default:
            return false
        }
    }

    /// Check if there's an overlap with existing buildings
    private func hasOverlap(
        at position: SIMD3<Float>,
        size: SIMD2<Float>,
        buildings: [Building]
    ) -> Bool {
        let position2D = SIMD2(position.x, position.z)

        for building in buildings {
            let buildingPos2D = SIMD2(building.position.x, building.position.z)

            // Simple AABB collision detection
            let distance = simd_distance(position2D, buildingPos2D)
            let minDistance = (size.x + building.bounds.x) / 2

            if distance < minDistance {
                return true
            }
        }

        return false
    }

    /// Check if position is within valid terrain
    private func isValidTerrain(
        at position: SIMD3<Float>,
        surfaceSize: SIMD2<Float>
    ) -> Bool {
        let halfSize = surfaceSize / 2

        return position.x >= -halfSize.x &&
               position.x <= halfSize.x &&
               position.z >= -halfSize.y &&
               position.z <= halfSize.y
    }

    /// Check if building has road access
    private func hasRoadAccess(
        _ position: SIMD3<Float>,
        within maxDistance: Float,
        roads: [Road]
    ) -> Bool {
        let position2D = SIMD2(position.x, position.z)

        for road in roads {
            // Check distance to any point on the road
            for roadPoint in road.path {
                let roadPoint2D = SIMD2(roadPoint.x, roadPoint.z)
                let distance = simd_distance(position2D, roadPoint2D)

                if distance <= maxDistance {
                    return true
                }
            }
        }

        return false
    }

    /// Check if a point is inside a polygon (2D)
    private func isPointInPolygon(_ point: SIMD2<Float>, polygon: [SIMD2<Float>]) -> Bool {
        guard polygon.count >= 3 else { return false }

        var inside = false
        var j = polygon.count - 1

        for i in 0..<polygon.count {
            let xi = polygon[i].x
            let yi = polygon[i].y
            let xj = polygon[j].x
            let yj = polygon[j].y

            if ((yi > point.y) != (yj > point.y)) &&
               (point.x < (xj - xi) * (point.y - yi) / (yj - yi) + xi) {
                inside = !inside
            }

            j = i
        }

        return inside
    }

    /// Get default capacity for building type
    private func defaultCapacity(for type: BuildingType) -> Int {
        switch type {
        case .residential(let residentialType):
            switch residentialType {
            case .smallHouse: return 4
            case .mediumHouse: return 6
            case .largeHouse: return 8
            case .apartment: return 24
            case .tower: return 100
            }
        case .commercial(let commercialType):
            switch commercialType {
            case .smallShop: return 5
            case .largeShop: return 15
            case .office: return 50
            case .mall: return 200
            case .hotel: return 80
            }
        case .industrial(let industrialType):
            switch industrialType {
            case .smallFactory: return 20
            case .largeFactory: return 100
            case .warehouse: return 30
            case .powerPlant: return 50
            case .waterTreatment: return 30
            }
        case .infrastructure(let infrastructureType):
            switch infrastructureType {
            case .school: return 500
            case .hospital: return 200
            case .policeStation: return 50
            case .fireStation: return 30
            case .park: return 0
            }
        }
    }
}
