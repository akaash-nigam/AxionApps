//
//  PhotoService.swift
//  PhysicalDigitalTwins
//
//  Protocol for photo storage operations
//

import Foundation
import UIKit

protocol PhotoService: Sendable {
    func savePhoto(_ image: UIImage, itemId: UUID) async throws -> String
    func loadPhoto(path: String) async throws -> UIImage
    func deletePhoto(path: String) async throws
    func deleteAllPhotos(paths: [String]) async throws
}

actor FileSystemPhotoService: PhotoService {

    private let fileManager = FileManager.default

    private var photosDirectory: URL {
        get throws {
            let documentsURL = try fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            let photosURL = documentsURL.appendingPathComponent("ItemPhotos", isDirectory: true)

            // Create directory if it doesn't exist
            if !fileManager.fileExists(atPath: photosURL.path) {
                try fileManager.createDirectory(
                    at: photosURL,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            }

            return photosURL
        }
    }

    func savePhoto(_ image: UIImage, itemId: UUID) async throws -> String {
        // Generate unique filename
        let timestamp = Date().timeIntervalSince1970
        let filename = "\(itemId.uuidString)_\(timestamp).jpg"

        let photoURL = try photosDirectory.appendingPathComponent(filename)

        // Convert to JPEG data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw PhotoError.compressionFailed
        }

        // Save to disk
        try imageData.write(to: photoURL)

        // Return relative path (just filename for simplicity)
        return filename
    }

    func loadPhoto(path: String) async throws -> UIImage {
        let photoURL = try photosDirectory.appendingPathComponent(path)

        guard fileManager.fileExists(atPath: photoURL.path) else {
            throw PhotoError.fileNotFound
        }

        let imageData = try Data(contentsOf: photoURL)

        guard let image = UIImage(data: imageData) else {
            throw PhotoError.invalidImageData
        }

        return image
    }

    func deletePhoto(path: String) async throws {
        let photoURL = try photosDirectory.appendingPathComponent(path)

        guard fileManager.fileExists(atPath: photoURL.path) else {
            return // Already deleted, no error
        }

        try fileManager.removeItem(at: photoURL)
    }

    func deleteAllPhotos(paths: [String]) async throws {
        for path in paths {
            try await deletePhoto(path: path)
        }
    }
}

// MARK: - Errors

enum PhotoError: LocalizedError {
    case compressionFailed
    case fileNotFound
    case invalidImageData
    case saveFailed
    case deleteFailed

    var errorDescription: String? {
        switch self {
        case .compressionFailed:
            return "Failed to compress image"
        case .fileNotFound:
            return "Photo file not found"
        case .invalidImageData:
            return "Invalid image data"
        case .saveFailed:
            return "Failed to save photo"
        case .deleteFailed:
            return "Failed to delete photo"
        }
    }
}
