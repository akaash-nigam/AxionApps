import Foundation

/// Service for managing stores
protocol StoreService {
    /// Fetch all stores
    func fetchStores() async throws -> [Store]

    /// Fetch a specific store by ID
    func getStore(id: UUID) async throws -> Store?

    /// Create a new store
    func createStore(_ store: Store) async throws

    /// Update an existing store
    func updateStore(_ store: Store) async throws

    /// Delete a store
    func deleteStore(id: UUID) async throws

    /// Search stores by name or location
    func searchStores(query: String) async throws -> [Store]

    /// Duplicate a store
    func duplicateStore(id: UUID, newName: String) async throws -> Store
}
