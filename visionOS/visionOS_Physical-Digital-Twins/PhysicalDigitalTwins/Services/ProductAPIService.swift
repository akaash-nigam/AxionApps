//
//  ProductAPIService.swift
//  PhysicalDigitalTwins
//
//  Product API aggregator
//

import Foundation

// MARK: - Protocol

protocol ProductAPIService: Sendable {
    func fetchBookInfo(isbn: String) async throws -> BookInfo
    func searchBook(title: String, author: String?) async throws -> [BookInfo]
}

// MARK: - Book Info

struct BookInfo: Codable, Sendable {
    let title: String
    let authors: [String]
    let isbn10: String?
    let isbn13: String?
    let publisher: String?
    let publishedDate: String?
    let description: String?
    let pageCount: Int?
    let imageURL: String?
    let averageRating: Double?
    let ratingsCount: Int?
}

// MARK: - Aggregator

class ProductAPIAggregator: ProductAPIService {
    private let googleBooksAPI: GoogleBooksAPI
    private let upcDatabaseAPI: UPCDatabaseAPI

    init(googleBooksAPI: GoogleBooksAPI, upcDatabaseAPI: UPCDatabaseAPI) {
        self.googleBooksAPI = googleBooksAPI
        self.upcDatabaseAPI = upcDatabaseAPI
    }

    func fetchBookInfo(isbn: String) async throws -> BookInfo {
        // Try Google Books first
        return try await googleBooksAPI.searchByISBN(isbn)
    }

    func searchBook(title: String, author: String?) async throws -> [BookInfo] {
        return try await googleBooksAPI.searchByTitle(title, author: author)
    }
}

// MARK: - Google Books API

class GoogleBooksAPI: Sendable {
    private let baseURL = "https://www.googleapis.com/books/v1/volumes"

    func searchByISBN(_ isbn: String) async throws -> BookInfo {
        let cleanISBN = isbn.replacingOccurrences(of: "-", with: "")
        let urlString = "\(baseURL)?q=isbn:\(cleanISBN)"

        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidResponse
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 404 {
                throw NetworkError.notFound
            }
            throw NetworkError.serverError(httpResponse.statusCode)
        }

        let googleResponse = try JSONDecoder().decode(GoogleBooksResponse.self, from: data)

        guard let firstItem = googleResponse.items?.first else {
            throw NetworkError.notFound
        }

        return BookInfo(from: firstItem.volumeInfo)
    }

    func searchByTitle(_ title: String, author: String?) async throws -> [BookInfo] {
        var query = "intitle:\(title)"
        if let author = author {
            query += "+inauthor:\(author)"
        }

        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)?q=\(encodedQuery)&maxResults=5") else {
            throw NetworkError.invalidResponse
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let googleResponse = try JSONDecoder().decode(GoogleBooksResponse.self, from: data)

        return googleResponse.items?.map { BookInfo(from: $0.volumeInfo) } ?? []
    }
}

// MARK: - UPC Database API (Stub for future)

class UPCDatabaseAPI: Sendable {
    // Placeholder for future implementation
}

// MARK: - Google Books Response Models

private struct GoogleBooksResponse: Codable {
    let items: [BookItem]?

    struct BookItem: Codable {
        let volumeInfo: VolumeInfo

        struct VolumeInfo: Codable {
            let title: String
            let authors: [String]?
            let publisher: String?
            let publishedDate: String?
            let description: String?
            let pageCount: Int?
            let imageLinks: ImageLinks?
            let averageRating: Double?
            let ratingsCount: Int?
            let industryIdentifiers: [Identifier]?

            struct ImageLinks: Codable {
                let thumbnail: String?
                let smallThumbnail: String?
            }

            struct Identifier: Codable {
                let type: String
                let identifier: String
            }
        }
    }
}

// MARK: - BookInfo Extension

extension BookInfo {
    init(from volumeInfo: GoogleBooksResponse.BookItem.VolumeInfo) {
        self.title = volumeInfo.title
        self.authors = volumeInfo.authors ?? []
        self.publisher = volumeInfo.publisher
        self.publishedDate = volumeInfo.publishedDate
        self.description = volumeInfo.description
        self.pageCount = volumeInfo.pageCount
        self.imageURL = volumeInfo.imageLinks?.thumbnail
        self.averageRating = volumeInfo.averageRating
        self.ratingsCount = volumeInfo.ratingsCount

        // Extract ISBNs
        var isbn10: String?
        var isbn13: String?
        if let identifiers = volumeInfo.industryIdentifiers {
            for identifier in identifiers {
                if identifier.type == "ISBN_10" {
                    isbn10 = identifier.identifier
                } else if identifier.type == "ISBN_13" {
                    isbn13 = identifier.identifier
                }
            }
        }
        self.isbn10 = isbn10
        self.isbn13 = isbn13
    }
}
