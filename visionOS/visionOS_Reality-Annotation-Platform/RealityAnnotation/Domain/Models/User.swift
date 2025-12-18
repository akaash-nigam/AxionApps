//
//  User.swift
//  Reality Annotation Platform
//
//  User model
//

import Foundation
import SwiftData

@Model
final class User {
    // Identity
    @Attribute(.unique) var id: String // CloudKit user record name
    var cloudKitRecordName: String?

    // Profile
    var displayName: String?
    var email: String?

    // Settings
    var defaultLayerColorHex: String
    var showAnnotationsOnStartup: Bool
    var enableNotifications: Bool
    var annotationDisplayDistance: Float

    // Subscription
    var subscriptionTier: String // "free", "plus", "family", "pro"
    var subscriptionExpiresAt: Date?

    // Usage tracking
    var annotationCount: Int
    var layerCount: Int

    // Metadata
    var createdAt: Date
    var lastActiveAt: Date

    init(id: String) {
        self.id = id
        self.defaultLayerColorHex = LayerColor.blue.hex
        self.showAnnotationsOnStartup = true
        self.enableNotifications = true
        self.annotationDisplayDistance = 10.0
        self.subscriptionTier = "free"
        self.annotationCount = 0
        self.layerCount = 0
        self.createdAt = Date()
        self.lastActiveAt = Date()
    }

    // MARK: - Computed Properties

    var tier: SubscriptionTier {
        get { SubscriptionTier(rawValue: subscriptionTier) ?? .free }
        set { subscriptionTier = newValue.rawValue }
    }

    var isSubscriptionActive: Bool {
        if tier == .free {
            return true
        }
        guard let expiresAt = subscriptionExpiresAt else {
            return false
        }
        return expiresAt > Date()
    }
}

// MARK: - Subscription Tier

enum SubscriptionTier: String, Codable {
    case free
    case plus
    case family
    case pro

    var maxAnnotations: Int {
        switch self {
        case .free: return 25
        case .plus, .family, .pro: return Int.max
        }
    }

    var maxLayers: Int {
        switch self {
        case .free: return 1
        case .plus, .family, .pro: return Int.max
        }
    }

    var canShare: Bool {
        self != .free
    }

    var displayName: String {
        switch self {
        case .free: return "Free"
        case .plus: return "Plus"
        case .family: return "Family"
        case .pro: return "Pro"
        }
    }

    var price: String {
        switch self {
        case .free: return "Free"
        case .plus: return "$4.99/month"
        case .family: return "$9.99/month"
        case .pro: return "$14.99/month"
        }
    }
}
