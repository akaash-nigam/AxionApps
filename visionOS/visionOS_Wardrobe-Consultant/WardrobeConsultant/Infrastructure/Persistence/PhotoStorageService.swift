//
//  PhotoStorageService.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import Foundation
import UIKit

/// Service for storing and retrieving wardrobe photos
class PhotoStorageService {
    static let shared = PhotoStorageService()

    private let fileManager = FileManager.default
    private let compressionQuality: CGFloat = 0.7

    // MARK: - Directory Management
    private var photosDirectory: URL {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let photosDir = appSupport.appendingPathComponent("WardrobePhotos", isDirectory: true)

        // Create if needed
        if !fileManager.fileExists(atPath: photosDir.path) {
            try? fileManager.createDirectory(
                at: photosDir,
                withIntermediateDirectories: true,
                attributes: [FileAttributeKey.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication]
            )
        }

        return photosDir
    }

    private var thumbnailsDirectory: URL {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let thumbDir = appSupport.appendingPathComponent("WardrobeThumbnails", isDirectory: true)

        // Create if needed
        if !fileManager.fileExists(atPath: thumbDir.path) {
            try? fileManager.createDirectory(
                at: thumbDir,
                withIntermediateDirectories: true,
                attributes: [FileAttributeKey.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication]
            )
        }

        return thumbDir
    }

    // MARK: - Save Photo
    func savePhoto(_ image: UIImage, for itemID: UUID) async throws -> (photoURL: URL, thumbnailURL: URL) {
        // Compress and save full photo
        guard let photoData = image.jpegData(compressionQuality: compressionQuality) else {
            throw PhotoStorageError.compressionFailed
        }

        let photoURL = photosDirectory.appendingPathComponent("\(itemID.uuidString).jpg")
        try photoData.write(to: photoURL, options: .completeFileProtection)

        // Generate and save thumbnail
        let thumbnail = generateThumbnail(from: image, size: CGSize(width: 200, height: 200))
        guard let thumbnailData = thumbnail.jpegData(compressionQuality: 0.6) else {
            throw PhotoStorageError.thumbnailGenerationFailed
        }

        let thumbnailURL = thumbnailsDirectory.appendingPathComponent("\(itemID.uuidString).jpg")
        try thumbnailData.write(to: thumbnailURL, options: .completeFileProtection)

        return (photoURL, thumbnailURL)
    }

    // MARK: - Load Photo
    func loadPhoto(from url: URL) async throws -> UIImage {
        guard fileManager.fileExists(atPath: url.path) else {
            throw PhotoStorageError.fileNotFound(url)
        }

        let data = try Data(contentsOf: url)

        guard let image = UIImage(data: data) else {
            throw PhotoStorageError.invalidImageData
        }

        return image
    }

    // MARK: - Delete Photo
    func deletePhoto(at url: URL) async throws {
        guard fileManager.fileExists(atPath: url.path) else {
            return // Already deleted
        }

        try fileManager.removeItem(at: url)
    }

    // MARK: - Delete Photos for Item
    func deletePhotos(for itemID: UUID) async throws {
        let photoURL = photosDirectory.appendingPathComponent("\(itemID.uuidString).jpg")
        let thumbnailURL = thumbnailsDirectory.appendingPathComponent("\(itemID.uuidString).jpg")

        try? await deletePhoto(at: photoURL)
        try? await deletePhoto(at: thumbnailURL)
    }

    // MARK: - Delete All Photos
    func deleteAllPhotos() async throws {
        let photoFiles = try fileManager.contentsOfDirectory(at: photosDirectory, includingPropertiesForKeys: nil)
        let thumbnailFiles = try fileManager.contentsOfDirectory(at: thumbnailsDirectory, includingPropertiesForKeys: nil)

        for file in photoFiles + thumbnailFiles {
            try fileManager.removeItem(at: file)
        }
    }

    // MARK: - Storage Statistics
    func getStorageSize() async throws -> UInt64 {
        var totalSize: UInt64 = 0

        let photoFiles = try fileManager.contentsOfDirectory(at: photosDirectory, includingPropertiesForKeys: [.fileSizeKey])
        let thumbnailFiles = try fileManager.contentsOfDirectory(at: thumbnailsDirectory, includingPropertiesForKeys: [.fileSizeKey])

        for file in photoFiles + thumbnailFiles {
            let attributes = try fileManager.attributesOfItem(atPath: file.path)
            if let size = attributes[.size] as? UInt64 {
                totalSize += size
            }
        }

        return totalSize
    }

    // MARK: - Thumbnail Generation
    private func generateThumbnail(from image: UIImage, size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

// MARK: - Errors
enum PhotoStorageError: Error {
    case compressionFailed
    case thumbnailGenerationFailed
    case fileNotFound(URL)
    case invalidImageData
    case saveFailed(Error)

    var localizedDescription: String {
        switch self {
        case .compressionFailed:
            return "Failed to compress image"
        case .thumbnailGenerationFailed:
            return "Failed to generate thumbnail"
        case .fileNotFound(let url):
            return "Photo not found at \(url.path)"
        case .invalidImageData:
            return "Invalid image data"
        case .saveFailed(let error):
            return "Failed to save photo: \(error.localizedDescription)"
        }
    }
}

// MARK: - UIImage Extension for HEIC
extension UIImage {
    func heicData(compressionQuality: CGFloat) -> Data? {
        // Note: HEIC compression requires iOS 11+
        // For now, using JPEG as fallback
        return jpegData(compressionQuality: compressionQuality)
    }
}
