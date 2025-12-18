//
//  AppConstants.swift
//  Legal Discovery Universe
//
//  Created by Claude Code
//  Copyright © 2024 Legal Discovery Universe. All rights reserved.
//

import Foundation
import SwiftUI

enum AppConstants {
    // MARK: - App Information
    static let appName = "Legal Discovery Universe"
    static let appVersion = "1.0.0"
    static let buildNumber = "1"

    // MARK: - Performance Limits
    static let maxDocumentsPerCase = 100_000_000
    static let maxConcurrentUsers = 500
    static let maxDocumentSize: Int64 = 500_000_000 // 500 MB
    static let searchTimeout: TimeInterval = 30.0
    static let cacheSize = 100
    static let batchSize = 100

    // MARK: - UI Constants
    static let defaultWindowWidth: CGFloat = 1200
    static let defaultWindowHeight: CGFloat = 900
    static let minWindowWidth: CGFloat = 800
    static let minWindowHeight: CGFloat = 600

    static let minHitTargetSize: CGFloat = 60 // visionOS minimum
    static let defaultPadding: CGFloat = 20
    static let defaultCornerRadius: CGFloat = 12

    // MARK: - Spatial Constants
    static let readingDistance: Float = 0.7 // meters
    static let analysisDistance: Float = 1.5 // meters
    static let overviewDistance: Float = 3.0 // meters

    static let evidenceUniverseSize: SIMD3<Float> = SIMD3(1.5, 1.5, 1.5)
    static let timelineSize: SIMD3<Float> = SIMD3(2.0, 0.8, 0.5)
    static let networkSize: SIMD3<Float> = SIMD3(1.2, 1.2, 1.2)

    // MARK: - Legal Constants
    static let privilegeKeywords = [
        "attorney-client",
        "privileged",
        "work product",
        "confidential",
        "attorney work product",
        "legal advice",
        "in confidence"
    ]

    static let relevanceThreshold: Double = 0.7
    static let highRelevanceThreshold: Double = 0.9
    static let privilegeConfidenceThreshold: Double = 0.8

    // MARK: - Colors
    enum Colors {
        static let relevantGold = Color(red: 1.0, green: 0.76, blue: 0.03)
        static let privilegedRed = Color(red: 0.96, green: 0.26, blue: 0.21)
        static let keyEvidenceBlue = Color(red: 0.13, green: 0.59, blue: 0.95)
        static let riskOrange = Color(red: 1.0, green: 0.60, blue: 0.0)
        static let neutralGray = Color(red: 0.62, green: 0.62, blue: 0.62)
    }

    // MARK: - File Types
    static let supportedFileTypes: [String] = [
        "pdf", "doc", "docx", "xls", "xlsx",
        "msg", "eml", "txt", "rtf",
        "jpg", "jpeg", "png", "gif", "tiff",
        "mp4", "mov", "avi", "mp3", "wav"
    ]

    static let documentFileTypes = ["pdf", "doc", "docx", "txt", "rtf"]
    static let emailFileTypes = ["msg", "eml"]
    static let imageFileTypes = ["jpg", "jpeg", "png", "gif", "tiff"]
    static let videoFileTypes = ["mp4", "mov", "avi"]
    static let audioFileTypes = ["mp3", "wav", "aac"]

    // MARK: - Security
    static let encryptionKeySize = 256 // AES-256
    static let sessionTimeout: TimeInterval = 3600 // 1 hour
    static let maxLoginAttempts = 3
    static let auditRetentionDays = 2555 // 7 years

    // MARK: - Performance Targets
    static let targetFPS = 90
    static let maxMemoryUsage: Int64 = 2_000_000_000 // 2 GB
    static let searchLatencyTarget: TimeInterval = 0.5 // 500ms
    static let documentImportRate = 1_000_000 // docs per hour

    // MARK: - Notifications
    enum NotificationNames {
        static let documentImported = "documentImported"
        static let caseUpdated = "caseUpdated"
        static let searchCompleted = "searchCompleted"
        static let analysisCompleted = "analysisCompleted"
    }

    // MARK: - UserDefaults Keys
    enum UserDefaultsKeys {
        static let lastOpenedCase = "lastOpenedCaseId"
        static let userPreferences = "userPreferences"
        static let autoSaveEnabled = "autoSaveEnabled"
        static let aiSuggestionsEnabled = "aiSuggestionsEnabled"
    }
}

// MARK: - Typography
enum Typography {
    static let documentTitle = Font.system(size: 24, weight: .bold)
    static let documentBody = Font.system(size: 16, weight: .regular)
    static let heading1 = Font.system(size: 34, weight: .bold)
    static let heading2 = Font.system(size: 28, weight: .semibold)
    static let heading3 = Font.system(size: 22, weight: .semibold)
    static let body = Font.system(size: 17, weight: .regular)
    static let caption = Font.system(size: 13, weight: .regular)
    static let label3D = Font.system(size: 20, weight: .medium)
}
