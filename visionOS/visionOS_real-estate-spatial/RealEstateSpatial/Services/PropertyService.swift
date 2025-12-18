//
//  PropertyService.swift
//  RealEstateSpatial
//
//  Service for property data management
//

import Foundation
import SwiftData

// MARK: - Property Service Protocol

protocol PropertyService {
    func fetchProperties(query: SearchQuery) async throws -> [Property]
    func fetchProperty(id: UUID) async throws -> Property
    func saveProperty(_ property: Property) async throws
    func updateProperty(_ property: Property) async throws
    func deleteProperty(id: UUID) async throws
    func searchProperties(criteria: SearchCriteria) async throws -> [Property]
}

// MARK: - Property Service Implementation

@Observable
final class PropertyServiceImpl: PropertyService {
    private let networkClient: NetworkClient
    private let cacheManager: CacheManager
    private let context: ModelContext

    init(
        networkClient: NetworkClient,
        cacheManager: CacheManager,
        context: ModelContext
    ) {
        self.networkClient = networkClient
        self.cacheManager = cacheManager
        self.context = context
    }

    func fetchProperties(query: SearchQuery) async throws -> [Property] {
        // Check cache first
        if let cached = await cacheManager.getCachedProperties(for: query) {
            return cached
        }

        // Fetch from network (in real implementation)
        // For now, return local properties from SwiftData
        let descriptor = FetchDescriptor<Property>(
            sortBy: [SortDescriptor(\.metadata.listedDate, order: .reverse)]
        )

        let properties = try context.fetch(descriptor)

        // Cache results
        await cacheManager.cacheProperties(properties, for: query)

        return properties
    }

    func fetchProperty(id: UUID) async throws -> Property {
        // Try local database first
        let descriptor = FetchDescriptor<Property>(
            predicate: #Predicate { $0.id == id }
        )

        if let local = try context.fetch(descriptor).first {
            return local
        }

        // In real implementation, fetch from network
        throw PropertyServiceError.propertyNotFound
    }

    func saveProperty(_ property: Property) async throws {
        context.insert(property)
        try context.save()
    }

    func updateProperty(_ property: Property) async throws {
        property.metadata.updatedDate = Date()
        try context.save()
    }

    func deleteProperty(id: UUID) async throws {
        let descriptor = FetchDescriptor<Property>(
            predicate: #Predicate { $0.id == id }
        )

        if let property = try context.fetch(descriptor).first {
            context.delete(property)
            try context.save()
        }
    }

    func searchProperties(criteria: SearchCriteria) async throws -> [Property] {
        var predicates: [Predicate<Property>] = []

        // Build predicate based on criteria
        let descriptor = FetchDescriptor<Property>(
            sortBy: [SortDescriptor(\.pricing.listPrice, order: .ascending)]
        )

        let properties = try context.fetch(descriptor)

        // Filter in memory (in real app, use predicates)
        return properties.filter { property in
            var matches = true

            // Price range
            if let priceRange = criteria.priceRange {
                matches = matches && (
                    property.pricing.listPrice >= priceRange.min &&
                    property.pricing.listPrice <= priceRange.max
                )
            }

            // Bedrooms
            if let bedroomRange = criteria.bedrooms {
                matches = matches && (
                    property.specifications.bedrooms >= bedroomRange.min &&
                    property.specifications.bedrooms <= bedroomRange.max
                )
            }

            // Property types
            if !criteria.propertyTypes.isEmpty {
                matches = matches && criteria.propertyTypes.contains(property.specifications.propertyType)
            }

            return matches
        }
    }
}

// MARK: - Errors

enum PropertyServiceError: Error {
    case propertyNotFound
    case saveFailed
    case networkError
    case invalidData
}

// MARK: - Cache Manager

actor CacheManager {
    private var propertyCache: [String: [Property]] = [:]
    private let cacheExpiration: TimeInterval = 300 // 5 minutes

    func getCachedProperties(for query: SearchQuery) async -> [Property]? {
        let key = query.cacheKey
        return propertyCache[key]
    }

    func cacheProperties(_ properties: [Property], for query: SearchQuery) async {
        let key = query.cacheKey
        propertyCache[key] = properties
    }

    func clearCache() async {
        propertyCache.removeAll()
    }
}

extension SearchQuery {
    var cacheKey: String {
        "\(query)_\(filters.hashValue)"
    }
}
