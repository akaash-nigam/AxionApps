//
//  BookTwin.swift
//  PhysicalDigitalTwins
//
//  Digital twin for books
//

import Foundation

struct BookTwin: DigitalTwin {
    // DigitalTwin conformance
    let id: UUID
    let objectType: ObjectCategory = .book
    var createdAt: Date
    var updatedAt: Date
    let recognitionMethod: RecognitionMethod

    // Book-specific properties
    var title: String
    var author: String
    var isbn: String?
    var isbn13: String?

    // Metadata
    var publisher: String?
    var publishDate: String?
    var pageCount: Int?
    var language: String?
    var genre: [String] = []

    // Ratings & Reviews
    var averageRating: Double?
    var ratingsCount: Int?
    var goodreadsID: String?

    // Reading Status
    var readingStatus: ReadingStatus = .unread
    var currentPage: Int?
    var startedReading: Date?
    var finishedReading: Date?

    // Personal
    var personalRating: Int? // 1-5 stars
    var notes: String?
    var isFavorite: Bool = false
    var tags: [String] = []

    // Images
    var coverImageURL: String?

    // Computed
    var displayName: String {
        title
    }

    // MARK: - Initializer

    init(
        id: UUID = UUID(),
        title: String,
        author: String,
        isbn: String? = nil,
        recognitionMethod: RecognitionMethod = .manual,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.isbn = isbn
        self.recognitionMethod = recognitionMethod
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Reading Status

enum ReadingStatus: String, Codable, Sendable {
    case unread
    case reading
    case finished
    case dnf // did not finish

    var displayName: String {
        switch self {
        case .unread: return "To Read"
        case .reading: return "Currently Reading"
        case .finished: return "Finished"
        case .dnf: return "Did Not Finish"
        }
    }
}
