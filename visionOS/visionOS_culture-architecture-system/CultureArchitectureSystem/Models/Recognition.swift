//
//  Recognition.swift
//  CultureArchitectureSystem
//
//  Created on 2025-01-20
//

import Foundation
import SwiftData

@Model
final class Recognition {
    @Attribute(.unique) var id: UUID
    var giverAnonymousId: UUID
    var receiverAnonymousId: UUID
    var valueId: UUID
    var message: String
    var timestamp: Date
    var visibility: RecognitionVisibility
    var isSynced: Bool

    init(
        id: UUID = UUID(),
        giverAnonymousId: UUID,
        receiverAnonymousId: UUID,
        valueId: UUID,
        message: String,
        visibility: RecognitionVisibility = .team,
        isSynced: Bool = false
    ) {
        self.id = id
        self.giverAnonymousId = giverAnonymousId
        self.receiverAnonymousId = receiverAnonymousId
        self.valueId = valueId
        self.message = message
        self.timestamp = Date()
        self.visibility = visibility
        self.isSynced = isSynced
    }
}

// MARK: - Visibility Levels
enum RecognitionVisibility: String, Codable {
    case private_      // Only recipient
    case team          // Team members
    case organization  // Entire org
}

// MARK: - JSON Serialization Helpers
extension Recognition {
    func toDictionary() -> [String: Any] {
        [
            "id": id.uuidString,
            "giver_anonymous_id": giverAnonymousId.uuidString,
            "receiver_anonymous_id": receiverAnonymousId.uuidString,
            "value_id": valueId.uuidString,
            "message": message,
            "timestamp": timestamp.timeIntervalSince1970,
            "visibility": visibility.rawValue,
            "is_synced": isSynced
        ]
    }
}

// MARK: - Mock data
extension Recognition {
    static func mock() -> Recognition {
        Recognition(
            giverAnonymousId: UUID(),
            receiverAnonymousId: UUID(),
            valueId: UUID(),
            message: "Great work on the innovation project!",
            visibility: .team
        )
    }
}
