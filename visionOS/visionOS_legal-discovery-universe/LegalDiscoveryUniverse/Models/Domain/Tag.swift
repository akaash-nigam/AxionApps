//
//  Tag.swift
//  Legal Discovery Universe
//
//  Created by Claude Code
//  Copyright © 2024 Legal Discovery Universe. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class Tag {
    @Attribute(.unique) var id: UUID
    var name: String
    var color: String
    var category: TagCategory
    var tagDescription: String?

    @Relationship(inverse: \LegalCase.tags) var legalCase: LegalCase?
    @Relationship var documents: [Document] = []

    var documentCount: Int = 0
    var createdDate: Date
    var createdBy: String?

    init(
        id: UUID = UUID(),
        name: String,
        color: String = "#2196F3",
        category: TagCategory = .custom
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.category = category
        self.createdDate = Date()
    }
}

enum TagCategory: String, Codable {
    case issue
    case topic
    case status
    case priority
    case custom
}
