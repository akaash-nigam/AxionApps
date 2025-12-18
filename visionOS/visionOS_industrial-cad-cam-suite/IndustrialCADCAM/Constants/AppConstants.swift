import Foundation

/// Application-wide constants
public enum AppConstants {

    // MARK: - App Information

    public static let appName = "Industrial CAD/CAM Suite"
    public static let appVersion = "1.0.0"
    public static let appBuild = "1"
    public static let appIdentifier = "com.company.industrial-cadcam"

    // MARK: - CloudKit

    public static let cloudKitContainer = "iCloud.com.company.industrial-cadcam"
    public static let cloudKitDatabase = "private"

    // MARK: - File Limits

    public static let maxFileSize: Int64 = 500_000_000 // 500 MB
    public static let maxImportFileSize: Int64 = 100_000_000 // 100 MB
    public static let maxExportFileSize: Int64 = 200_000_000 // 200 MB

    // MARK: - String Limits

    public static let maxProjectNameLength = 100
    public static let maxPartNameLength = 100
    public static let maxDescriptionLength = 500
    public static let maxNotesLength = 1000

    // MARK: - Collection Limits

    public static let maxPartsPerProject = 10_000
    public static let maxPartsPerAssembly = 1_000
    public static let maxAssembliesPerProject = 100

    // MARK: - Performance

    public static let targetFrameRate: Double = 90.0
    public static let minimumFrameRate: Double = 60.0
    public static let maxMemoryUsage: Int64 = 4_000_000_000 // 4 GB

    // MARK: - Timeouts

    public static let networkTimeout: TimeInterval = 30.0
    public static let operationTimeout: TimeInterval = 300.0 // 5 minutes
    public static let simulationTimeout: TimeInterval = 600.0 // 10 minutes

    // MARK: - Cache

    public static let cacheSize: Int64 = 500_000_000 // 500 MB
    public static let cacheDuration: TimeInterval = 3600.0 // 1 hour

    // MARK: - Collaboration

    public static let maxCollaborators = 10
    public static let collaborationSyncInterval: TimeInterval = 1.0
    public static let collaborationHeartbeatInterval: TimeInterval = 5.0

    // MARK: - Autosave

    public static let autosaveInterval: TimeInterval = 300.0 // 5 minutes
    public static let maxAutosaveVersions = 10

    // MARK: - Undo/Redo

    public static let maxUndoSteps = 100
    public static let maxRedoSteps = 100

    // MARK: - URLs

    public static let supportURL = URL(string: "https://support.example.com")!
    public static let documentationURL = URL(string: "https://docs.example.com")!
    public static let feedbackURL = URL(string: "https://feedback.example.com")!
}
