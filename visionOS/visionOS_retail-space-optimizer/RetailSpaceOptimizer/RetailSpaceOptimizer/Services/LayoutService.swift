import Foundation

@Observable
class LayoutService {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchLayouts(storeId: UUID) async throws -> [StoreLayout] {
        #if DEBUG
        if Configuration.useMockData {
            return [StoreLayout.mock()]
        }
        #endif

        let layouts: [StoreLayout] = try await apiClient.request(.layouts(storeId: storeId))
        return layouts
    }

    func optimizeLayout(
        _ layout: StoreLayout,
        constraints: [LayoutConstraint]
    ) async throws -> StoreLayout {
        // In production, this would call an AI optimization service
        // For now, return the original layout

        #if DEBUG
        if Configuration.useMockData {
            // Simulate optimization delay
            try await Task.sleep(for: .seconds(2))
            return layout
        }
        #endif

        // Call optimization API
        return layout
    }

    func validateLayout(_ layout: StoreLayout) async throws -> ValidationResult {
        var issues: [ValidationIssue] = []

        // Check for overlapping fixtures
        if let fixtures = layout.fixtures {
            for i in 0..<fixtures.count {
                for j in (i + 1)..<fixtures.count {
                    if fixturesOverlap(fixtures[i], fixtures[j]) {
                        issues.append(ValidationIssue(
                            severity: .error,
                            message: "Fixtures \(fixtures[i].name) and \(fixtures[j].name) overlap",
                            fixturIds: [fixtures[i].id, fixtures[j].id]
                        ))
                    }
                }
            }
        }

        // Check for blocked exits
        for exit in layout.exits {
            if isExitBlocked(exit, fixtures: layout.fixtures ?? []) {
                issues.append(ValidationIssue(
                    severity: .warning,
                    message: "Exit at \(exit.position) may be blocked"
                ))
            }
        }

        // Check for accessibility compliance
        // ...

        return ValidationResult(
            isValid: issues.filter { $0.severity == .error }.isEmpty,
            issues: issues
        )
    }

    func generateLayoutVariations(
        _ baseLayout: StoreLayout,
        count: Int
    ) async throws -> [StoreLayout] {
        // Generate variations by:
        // 1. Rotating fixtures
        // 2. Changing fixture positions
        // 3. Swapping fixture types

        #if DEBUG
        if Configuration.useMockData {
            return (0..<count).map { _ in baseLayout }
        }
        #endif

        return []
    }

    // MARK: - Private Helpers

    private func fixturesOverlap(_ a: Fixture, _ b: Fixture) -> Bool {
        // Simple AABB collision detection
        let aMin = a.position - a.dimensions / 2
        let aMax = a.position + a.dimensions / 2
        let bMin = b.position - b.dimensions / 2
        let bMax = b.position + b.dimensions / 2

        return (aMin.x < bMax.x && aMax.x > bMin.x) &&
               (aMin.y < bMax.y && aMax.y > bMin.y) &&
               (aMin.z < bMax.z && aMax.z > bMin.z)
    }

    private func isExitBlocked(_ exit: Exit, fixtures: [Fixture]) -> Bool {
        // Check if any fixtures are near the exit
        for fixture in fixtures {
            let distance = simd_distance(
                SIMD2(exit.position.x, exit.position.y),
                SIMD2(fixture.position.x, fixture.position.z)
            )
            if distance < 2.0 { // 2 meters clearance
                return true
            }
        }
        return false
    }
}

// MARK: - Layout Constraint

struct LayoutConstraint: Codable {
    var type: ConstraintType
    var parameters: [String: String]

    enum ConstraintType: String, Codable {
        case minimumAisle = "minimum_aisle"
        case fireExit = "fire_exit"
        case ada = "ada_compliance"
        case productProximity = "product_proximity"
    }
}

// MARK: - Validation Result

struct ValidationResult: Codable {
    var isValid: Bool
    var issues: [ValidationIssue]
}

struct ValidationIssue: Codable, Identifiable {
    var id: UUID = UUID()
    var severity: Severity
    var message: String
    var fixtureIds: [UUID]?

    enum Severity: String, Codable {
        case error, warning, info
    }

    init(severity: Severity, message: String, fixturIds: [UUID]? = nil) {
        self.severity = severity
        self.message = message
        self.fixtureIds = fixturIds
    }
}
