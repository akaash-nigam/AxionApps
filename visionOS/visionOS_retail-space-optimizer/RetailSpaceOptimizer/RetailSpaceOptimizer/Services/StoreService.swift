import Foundation
import SwiftData

@Observable
class StoreService {
    private let apiClient: APIClient
    private let dataStore: DataStore
    private let cache: CacheService

    init(apiClient: APIClient, dataStore: DataStore, cache: CacheService) {
        self.apiClient = apiClient
        self.dataStore = dataStore
        self.cache = cache
    }

    // MARK: - Fetch Operations

    func fetchStores() async throws -> [Store] {
        #if DEBUG
        if Configuration.useMockData {
            return Store.mockArray(count: 5)
        }
        #endif

        let stores: [Store] = try await apiClient.request(.stores)
        return stores
    }

    func fetchStore(id: UUID) async throws -> Store {
        #if DEBUG
        if Configuration.useMockData {
            return Store.mock()
        }
        #endif

        let store: Store = try await apiClient.request(.store(id: id))
        return store
    }

    // MARK: - Create Operations

    func createStore(_ store: Store) async throws -> Store {
        #if DEBUG
        if Configuration.useMockData {
            // Save to local data store
            try await dataStore.save(store)
            return store
        }
        #endif

        let created: Store = try await apiClient.request(.createStore(store))

        // Save to local cache
        try await dataStore.save(created)

        return created
    }

    // MARK: - Update Operations

    func updateStore(_ store: Store) async throws -> Store {
        #if DEBUG
        if Configuration.useMockData {
            store.modifiedDate = Date()
            try await dataStore.save(store)
            return store
        }
        #endif

        let updated: Store = try await apiClient.request(.updateStore(store.id, store))

        // Update local cache
        try await dataStore.save(updated)

        return updated
    }

    // MARK: - Delete Operations

    func deleteStore(id: UUID) async throws {
        #if DEBUG
        if Configuration.useMockData {
            try await dataStore.delete(Store.self, id: id)
            return
        }
        #endif

        let _: EmptyResponse = try await apiClient.request(.deleteStore(id))

        // Delete from local cache
        try await dataStore.delete(Store.self, id: id)
    }

    // MARK: - Utility Operations

    func duplicateStore(id: UUID) async throws -> Store {
        let original = try await fetchStore(id: id)

        let duplicate = Store(
            name: "\(original.name) (Copy)",
            location: original.location,
            dimensions: original.dimensions
        )

        return try await createStore(duplicate)
    }
}

// MARK: - Empty Response

struct EmptyResponse: Codable {}
