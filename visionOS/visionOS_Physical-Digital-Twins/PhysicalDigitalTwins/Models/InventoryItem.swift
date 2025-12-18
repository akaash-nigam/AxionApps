//
//  InventoryItem.swift
//  PhysicalDigitalTwins
//
//  Inventory item wrapper for digital twins
//

import Foundation

struct InventoryItem: Identifiable, Codable, Sendable {
    let id: UUID
    var digitalTwin: AnyDigitalTwin

    // Financial
    var purchaseDate: Date?
    var purchasePrice: Decimal?
    var purchaseStore: String?
    var currentValue: Decimal?

    // Location
    var locationName: String?
    var specificLocation: String? // "Top shelf", "Drawer 2"

    // Condition
    var condition: ItemCondition = .good
    var conditionNotes: String?

    // Photos
    var photosPaths: [String] = []

    // Lending
    var isLent: Bool = false
    var lentTo: String?
    var lentDate: Date?
    var expectedReturnDate: Date?

    // User notes
    var notes: String?
    var tags: [String] = []
    var isFavorite: Bool = false

    // Metadata
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Initializer

    init(
        id: UUID = UUID(),
        digitalTwin: any DigitalTwin,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.digitalTwin = AnyDigitalTwin(digitalTwin)
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Item Condition

enum ItemCondition: String, Codable, Sendable {
    case new
    case excellent
    case good
    case fair
    case poor
    case broken

    var displayName: String {
        rawValue.capitalized
    }
}

// MARK: - Type Erased Digital Twin

struct AnyDigitalTwin: Codable, Sendable {
    let id: UUID
    let objectType: ObjectCategory
    let displayName: String
    let createdAt: Date
    var updatedAt: Date
    let recognitionMethod: RecognitionMethod

    private let _underlying: any DigitalTwin

    init(_ twin: any DigitalTwin) {
        self._underlying = twin
        self.id = twin.id
        self.objectType = twin.objectType
        self.displayName = twin.displayName
        self.createdAt = twin.createdAt
        self.updatedAt = twin.updatedAt
        self.recognitionMethod = twin.recognitionMethod
    }

    // Get strongly typed twin
    func asTwin<T: DigitalTwin>() -> T? {
        _underlying as? T
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case type, data
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(objectType, forKey: .type)

        switch objectType {
        case .book:
            if let book = _underlying as? BookTwin {
                try container.encode(book, forKey: .data)
            }
        default:
            // For now, only support books in MVP
            throw EncodingError.invalidValue(
                objectType,
                EncodingError.Context(
                    codingPath: encoder.codingPath,
                    debugDescription: "Unsupported object type for encoding: \(objectType)"
                )
            )
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ObjectCategory.self, forKey: .type)

        switch type {
        case .book:
            let book = try container.decode(BookTwin.self, forKey: .data)
            self.init(book)
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unsupported object type: \(type)"
            )
        }
    }
}
