//
//  DigitalTwin.swift
//  PhysicalDigitalTwins
//
//  Base protocol for all digital twins
//

import Foundation

// MARK: - DigitalTwin Protocol

protocol DigitalTwin: Identifiable, Codable, Sendable {
    var id: UUID { get }
    var objectType: ObjectCategory { get }
    var displayName: String { get }
    var createdAt: Date { get }
    var updatedAt: Date { get set }
    var recognitionMethod: RecognitionMethod { get }
}

// MARK: - Object Category

enum ObjectCategory: String, Codable, CaseIterable, Sendable {
    case book
    case food
    case furniture
    case electronics
    case clothing
    case games
    case tools
    case plants
    case unknown

    var displayName: String {
        switch self {
        case .book: return "Books"
        case .food: return "Food & Groceries"
        case .furniture: return "Furniture"
        case .electronics: return "Electronics"
        case .clothing: return "Clothing"
        case .games: return "Games & Media"
        case .tools: return "Tools"
        case .plants: return "Plants"
        case .unknown: return "Other"
        }
    }

    var iconName: String {
        switch self {
        case .book: return "book.fill"
        case .food: return "cart.fill"
        case .furniture: return "chair.fill"
        case .electronics: return "tv.fill"
        case .clothing: return "tshirt.fill"
        case .games: return "gamecontroller.fill"
        case .tools: return "wrench.and.screwdriver.fill"
        case .plants: return "leaf.fill"
        case .unknown: return "questionmark.circle.fill"
        }
    }
}

// MARK: - Recognition Method

enum RecognitionMethod: String, Codable, Sendable {
    case barcode        // Scanned barcode/QR
    case vision         // Visual recognition (ML)
    case manual         // User entered
    case imageSimilarity // Visual search
}
