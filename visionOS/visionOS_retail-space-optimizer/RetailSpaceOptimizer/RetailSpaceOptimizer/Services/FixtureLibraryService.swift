import Foundation

@Observable
class FixtureLibraryService {
    private let apiClient: APIClient
    private let cache: CacheService

    init(apiClient: APIClient, cache: CacheService) {
        self.apiClient = apiClient
        self.cache = cache
    }

    func fetchFixtures(category: FixtureCategory? = nil) async throws -> [Fixture] {
        #if DEBUG
        if Configuration.useMockData {
            let allFixtures = Fixture.mockArray(count: 20)
            if let category = category {
                return allFixtures.filter { $0.category == category }
            }
            return allFixtures
        }
        #endif

        let fixtures: [Fixture] = try await apiClient.request(.fixtures)

        if let category = category {
            return fixtures.filter { $0.category == category }
        }

        return fixtures
    }

    func fetchFixture(id: UUID) async throws -> Fixture {
        #if DEBUG
        if Configuration.useMockData {
            return Fixture.mock()
        }
        #endif

        // Check cache first
        if let cached: Fixture = cache.retrieve(forKey: "fixture_\(id.uuidString)") {
            return cached
        }

        // Fetch from API
        let fixture = Fixture.mock() // Replace with actual API call

        // Cache it
        cache.cache(fixture, forKey: "fixture_\(id.uuidString)")

        return fixture
    }
}
