import Foundation
import SwiftData

final class StoreServiceImpl: StoreService {
    private let repository: StoreRepository
    private let networkClient: NetworkClient

    init(repository: StoreRepository, networkClient: NetworkClient) {
        self.repository = repository
        self.networkClient = networkClient
    }

    func fetchStores() async throws -> [Store] {
        // Try to fetch from local first
        let localStores = try await repository.fetchAll()

        // Then sync with server (fire and forget for now)
        Task {
            try? await syncWithServer()
        }

        return localStores
    }

    func getStore(id: UUID) async throws -> Store? {
        return try await repository.fetch(id: id)
    }

    func createStore(_ store: Store) async throws {
        // Save locally
        try await repository.save(store)

        // Sync to server
        Task {
            try? await networkClient.request(.createStore(store))
        }
    }

    func updateStore(_ store: Store) async throws {
        store.updatedAt = Date()
        try await repository.update(store)

        Task {
            try? await networkClient.request(.updateStore(store))
        }
    }

    func deleteStore(id: UUID) async throws {
        try await repository.delete(id: id)

        Task {
            try? await networkClient.request(.deleteStore(id: id))
        }
    }

    func searchStores(query: String) async throws -> [Store] {
        let allStores = try await repository.fetchAll()
        return allStores.filter { store in
            store.name.localizedCaseInsensitiveContains(query) ||
            store.location.city.localizedCaseInsensitiveContains(query) ||
            store.location.address.localizedCaseInsensitiveContains(query)
        }
    }

    func duplicateStore(id: UUID, newName: String) async throws -> Store {
        guard let original = try await repository.fetch(id: id) else {
            throw StoreServiceError.storeNotFound
        }

        let duplicate = Store(
            name: newName,
            location: original.location,
            dimensions: original.dimensions
        )
        duplicate.layout = original.layout

        // Deep copy fixtures
        for fixture in original.fixtures {
            let newFixture = Fixture(
                type: fixture.type,
                name: fixture.name,
                dimensions: fixture.dimensions
            )
            newFixture.position = fixture.position
            newFixture.rotation = fixture.rotation
            newFixture.products = fixture.products
            duplicate.fixtures.append(newFixture)
        }

        try await repository.save(duplicate)
        return duplicate
    }

    // MARK: - Private Methods
    private func syncWithServer() async throws {
        // Implementation for server sync
    }
}

enum StoreServiceError: Error {
    case storeNotFound
    case saveFailed
    case deleteFailed
    case syncFailed
}
