//
//  TwinFactory.swift
//  PhysicalDigitalTwins
//
//  Factory for creating digital twins from various sources
//

import Foundation

@MainActor
class TwinFactory {
    private let apiService: ProductAPIService

    init(apiService: ProductAPIService) {
        self.apiService = apiService
    }

    // Create twin from barcode scan
    func createTwin(from barcode: BarcodeResult) async throws -> any DigitalTwin {
        // Try to fetch info from API
        do {
            let bookInfo = try await apiService.fetchBookInfo(isbn: barcode.value)
            return createBookTwin(from: bookInfo, barcode: barcode.value)
        } catch {
            // If API fails, create basic twin with barcode only
            return BookTwin(
                title: "Unknown Item",
                author: "Unknown",
                isbn: barcode.value,
                recognitionMethod: .barcode
            )
        }
    }

    // Create book twin from API info
    func createBookTwin(from bookInfo: BookInfo, barcode: String? = nil) -> BookTwin {
        var twin = BookTwin(
            title: bookInfo.title,
            author: bookInfo.authors.first ?? "Unknown",
            isbn: bookInfo.isbn13 ?? bookInfo.isbn10 ?? barcode,
            recognitionMethod: barcode != nil ? .barcode : .manual
        )

        twin.isbn13 = bookInfo.isbn13
        twin.publisher = bookInfo.publisher
        twin.publishDate = bookInfo.publishedDate
        twin.pageCount = bookInfo.pageCount
        twin.averageRating = bookInfo.averageRating
        twin.ratingsCount = bookInfo.ratingsCount
        twin.coverImageURL = bookInfo.imageURL

        return twin
    }

    // Create twin manually
    func createManualTwin(title: String, author: String) -> BookTwin {
        return BookTwin(
            title: title,
            author: author,
            recognitionMethod: .manual
        )
    }
}
