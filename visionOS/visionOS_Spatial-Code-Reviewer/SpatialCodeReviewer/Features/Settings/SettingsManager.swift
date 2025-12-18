//
//  SettingsManager.swift
//  SpatialCodeReviewer
//
//  Created by Claude on 2025-11-24.
//  Story 0.9: Settings & Preferences
//

import Foundation
import SwiftUI

/// Manages user preferences and settings
@MainActor
class SettingsManager: ObservableObject {

    // MARK: - Singleton

    static let shared = SettingsManager()

    // MARK: - Published Settings

    @Published var selectedTheme: String = "visionOS Dark" {
        didSet {
            saveSettings()
            applyTheme()
        }
    }

    @Published var fontSize: CGFloat = 12 {
        didSet { saveSettings() }
    }

    @Published var visibleLines: Int = 40 {
        didSet { saveSettings() }
    }

    @Published var defaultLayout: String = "hemisphere" {
        didSet { saveSettings() }
    }

    @Published var showLineNumbers: Bool = true {
        didSet { saveSettings() }
    }

    @Published var enableEntityPooling: Bool = true {
        didSet { saveSettings() }
    }

    @Published var enableLOD: Bool = true {
        didSet { saveSettings() }
    }

    @Published var textureQuality: TextureQuality = .high {
        didSet { saveSettings() }
    }

    // MARK: - Enums

    enum TextureQuality: String, Codable, CaseIterable {
        case low = "Low (512x768)"
        case medium = "Medium (1024x1536)"
        case high = "High (2048x3072)"

        var resolution: (width: Int, height: Int) {
            switch self {
            case .low: return (512, 768)
            case .medium: return (1024, 1536)
            case .high: return (2048, 3072)
            }
        }
    }

    // MARK: - Codable Model

    private struct UserPreferences: Codable {
        var selectedTheme: String
        var fontSize: CGFloat
        var visibleLines: Int
        var defaultLayout: String
        var showLineNumbers: Bool
        var enableEntityPooling: Bool
        var enableLOD: Bool
        var textureQuality: TextureQuality
    }

    // MARK: - UserDefaults Keys

    private let preferencesKey = "com.spatialcodereViewer.preferences"

    // MARK: - Initialization

    private init() {
        loadSettings()
        applyTheme()
    }

    // MARK: - Public Methods

    /// Resets all settings to defaults
    func resetToDefaults() {
        selectedTheme = "visionOS Dark"
        fontSize = 12
        visibleLines = 40
        defaultLayout = "hemisphere"
        showLineNumbers = true
        enableEntityPooling = true
        enableLOD = true
        textureQuality = .high

        saveSettings()
    }

    /// Exports settings to JSON string
    func exportSettings() -> String? {
        let preferences = UserPreferences(
            selectedTheme: selectedTheme,
            fontSize: fontSize,
            visibleLines: visibleLines,
            defaultLayout: defaultLayout,
            showLineNumbers: showLineNumbers,
            enableEntityPooling: enableEntityPooling,
            enableLOD: enableLOD,
            textureQuality: textureQuality
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        guard let data = try? encoder.encode(preferences),
              let json = String(data: data, encoding: .utf8) else {
            return nil
        }

        return json
    }

    /// Imports settings from JSON string
    func importSettings(from json: String) -> Bool {
        guard let data = json.data(using: .utf8),
              let preferences = try? JSONDecoder().decode(UserPreferences.self, from: data) else {
            return false
        }

        selectedTheme = preferences.selectedTheme
        fontSize = preferences.fontSize
        visibleLines = preferences.visibleLines
        defaultLayout = preferences.defaultLayout
        showLineNumbers = preferences.showLineNumbers
        enableEntityPooling = preferences.enableEntityPooling
        enableLOD = preferences.enableLOD
        textureQuality = preferences.textureQuality

        saveSettings()
        return true
    }

    // MARK: - Private Methods

    private func saveSettings() {
        let preferences = UserPreferences(
            selectedTheme: selectedTheme,
            fontSize: fontSize,
            visibleLines: visibleLines,
            defaultLayout: defaultLayout,
            showLineNumbers: showLineNumbers,
            enableEntityPooling: enableEntityPooling,
            enableLOD: enableLOD,
            textureQuality: textureQuality
        )

        if let data = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(data, forKey: preferencesKey)
            print("✅ Settings saved")
        }
    }

    private func loadSettings() {
        guard let data = UserDefaults.standard.data(forKey: preferencesKey),
              let preferences = try? JSONDecoder().decode(UserPreferences.self, from: data) else {
            print("ℹ️ No saved settings, using defaults")
            return
        }

        selectedTheme = preferences.selectedTheme
        fontSize = preferences.fontSize
        visibleLines = preferences.visibleLines
        defaultLayout = preferences.defaultLayout
        showLineNumbers = preferences.showLineNumbers
        enableEntityPooling = preferences.enableEntityPooling
        enableLOD = preferences.enableLOD
        textureQuality = preferences.textureQuality

        print("✅ Settings loaded")
    }

    private func applyTheme() {
        CodeTheme.setTheme(name: selectedTheme)
        print("🎨 Applied theme: \(selectedTheme)")
    }
}

// MARK: - Entity Pooling System

/// Manages pool of reusable entities for performance
@MainActor
class EntityPool {
    private var availableEntities: [Entity] = []
    private var inUseEntities: Set<ObjectIdentifier> = []

    private let maxPoolSize: Int = 50
    private let initialPoolSize: Int = 10

    init() {
        // Pre-populate pool
        for _ in 0..<initialPoolSize {
            let entity = createEntity()
            availableEntities.append(entity)
        }

        print("✅ Entity pool initialized with \(initialPoolSize) entities")
    }

    func acquire() -> Entity {
        let entity: Entity

        if let available = availableEntities.popLast() {
            entity = available
            print("♻️ Reused entity from pool")
        } else {
            entity = createEntity()
            print("🆕 Created new entity (pool empty)")
        }

        inUseEntities.insert(ObjectIdentifier(entity))
        entity.isEnabled = true

        return entity
    }

    func release(_ entity: Entity) {
        let id = ObjectIdentifier(entity)
        guard inUseEntities.contains(id) else { return }

        inUseEntities.remove(id)
        entity.isEnabled = false
        entity.removeFromParent()

        // Reset entity state
        entity.position = [0, 0, 0]
        entity.scale = [1, 1, 1]
        entity.orientation = simd_quatf(angle: 0, axis: [0, 1, 0])

        if availableEntities.count < maxPoolSize {
            availableEntities.append(entity)
            print("♻️ Returned entity to pool (\(availableEntities.count)/\(maxPoolSize))")
        } else {
            print("🗑️ Pool full, entity deallocated")
        }
    }

    func clear() {
        availableEntities.removeAll()
        inUseEntities.removeAll()
        print("🧹 Entity pool cleared")
    }

    private func createEntity() -> Entity {
        return Entity()
    }

    var poolStats: (available: Int, inUse: Int) {
        return (availableEntities.count, inUseEntities.count)
    }
}

// MARK: - Level of Detail System

/// Manages level-of-detail based on distance from camera
@MainActor
class LODSystem {
    enum DetailLevel {
        case high   // < 2m: Full detail
        case medium // 2-4m: Reduced detail
        case low    // > 4m: Minimal detail
    }

    func updateLOD(for entity: Entity, cameraPosition: SIMD3<Float>) {
        let distance = simd_distance(entity.position, cameraPosition)
        let detailLevel = getDetailLevel(for: distance)

        applyDetailLevel(detailLevel, to: entity)
    }

    private func getDetailLevel(for distance: Float) -> DetailLevel {
        if distance < 2.0 {
            return .high
        } else if distance < 4.0 {
            return .medium
        } else {
            return .low
        }
    }

    private func applyDetailLevel(_ level: DetailLevel, to entity: Entity) {
        // Adjust texture resolution, geometry complexity, etc.
        switch level {
        case .high:
            entity.scale = [1, 1, 1]
        case .medium:
            entity.scale = [0.8, 0.8, 1]
        case .low:
            entity.scale = [0.6, 0.6, 1]
        }
    }
}

// MARK: - Performance Monitor

/// Monitors performance metrics
@MainActor
class PerformanceMonitor: ObservableObject {
    @Published var fps: Double = 60.0
    @Published var memoryUsage: UInt64 = 0
    @Published var entityCount: Int = 0

    private var lastUpdateTime: Date = Date()
    private var frameCount: Int = 0

    func recordFrame() {
        frameCount += 1

        let now = Date()
        let elapsed = now.timeIntervalSince(lastUpdateTime)

        if elapsed >= 1.0 {
            fps = Double(frameCount) / elapsed
            frameCount = 0
            lastUpdateTime = now

            updateMemoryUsage()
        }
    }

    private func updateMemoryUsage() {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4

        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        if result == KERN_SUCCESS {
            memoryUsage = info.resident_size
        }
    }

    var formattedMemory: String {
        let mb = Double(memoryUsage) / 1024.0 / 1024.0
        return String(format: "%.1f MB", mb)
    }
}
