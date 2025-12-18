//
//  AddItemViewModel.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

@MainActor
class AddItemViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var category: ClothingCategory = .tShirt
    @Published var brand: String = ""
    @Published var size: String = ""
    @Published var primaryColor: Color = .blue
    @Published var secondaryColor: Color?
    @Published var useSecondaryColor: Bool = false
    @Published var fabricType: FabricType = .cotton
    @Published var pattern: ClothingPattern = .solid
    @Published var selectedSeasons: Set<Season> = []
    @Published var selectedOccasions: Set<OccasionType> = [.casual]
    @Published var purchaseDate: Date = Date()
    @Published var purchasePrice: String = ""
    @Published var condition: ItemCondition = .excellent
    @Published var retailer: String = ""
    @Published var notes: String = ""
    @Published var careInstructions: String = ""
    @Published var tags: [String] = []

    @Published var capturedImage: UIImage?
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Dependencies
    private let wardrobeRepository: WardrobeRepository
    private let photoStorage: PhotoStorageService

    // MARK: - Initialization
    init(
        wardrobeRepository: WardrobeRepository = CoreDataWardrobeRepository.shared,
        photoStorage: PhotoStorageService = PhotoStorageService.shared
    ) {
        self.wardrobeRepository = wardrobeRepository
        self.photoStorage = photoStorage
    }

    // MARK: - Validation
    func validate() -> Bool {
        // Basic validation
        guard !size.isEmpty else {
            errorMessage = "Please enter a size"
            return false
        }

        return true
    }

    // MARK: - Save Item
    func saveItem() async -> Bool {
        guard validate() else { return false }

        isLoading = true
        errorMessage = nil

        do {
            let itemID = UUID()

            // Save photo if captured
            var photoURL: URL?
            var thumbnailURL: URL?

            if let image = capturedImage {
                let urls = try await photoStorage.savePhoto(image, for: itemID)
                photoURL = urls.photoURL
                thumbnailURL = urls.thumbnailURL
            }

            // Create wardrobe item
            let item = WardrobeItem(
                id: itemID,
                category: category,
                primaryColor: primaryColor.toHex(),
                secondaryColor: useSecondaryColor ? secondaryColor?.toHex() : nil,
                brand: brand.isEmpty ? nil : brand,
                size: size,
                fabricType: fabricType,
                pattern: pattern,
                season: selectedSeasons,
                occasions: selectedOccasions,
                purchaseDate: purchaseDate,
                purchasePrice: purchasePrice.isEmpty ? nil : Decimal(string: purchasePrice),
                condition: condition,
                timesWorn: 0,
                lastWornDate: nil,
                isFavorite: false,
                photoURL: photoURL,
                thumbnailURL: thumbnailURL,
                tags: tags,
                notes: notes.isEmpty ? nil : notes,
                retailer: retailer.isEmpty ? nil : retailer,
                careInstructions: careInstructions.isEmpty ? nil : careInstructions,
                createdAt: Date(),
                updatedAt: Date()
            )

            _ = try await wardrobeRepository.create(item)
            isLoading = false
            return true
        } catch {
            errorMessage = "Failed to save item: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }

    // MARK: - Photo Actions
    func clearPhoto() {
        capturedImage = nil
    }
}

// MARK: - Color Extension
extension Color {
    func toHex() -> String {
        guard let components = UIColor(self).cgColor.components else {
            return "#000000"
        }

        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])

        return String(format: "#%02lX%02lX%02lX",
                     lroundf(r * 255),
                     lroundf(g * 255),
                     lroundf(b * 255))
    }
}
