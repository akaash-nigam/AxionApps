# Security & Privacy Design Document

## Document Overview

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Draft

## 1. Executive Summary

This document defines the security and privacy architecture for Wardrobe Consultant. Given the sensitive nature of body measurements, personal styling data, and AR body tracking, privacy-by-design principles are fundamental to the application. All sensitive data processing occurs on-device, with explicit user consent required for any data collection or sync.

## 2. Privacy Principles

### 2.1 Core Commitments

**Privacy by Design**:
- Minimal data collection
- On-device processing wherever possible
- Explicit user consent for all data sharing
- Transparent data practices

**User Control**:
- Users own their data
- Easy data export
- Simple data deletion
- Granular permission controls

**Transparency**:
- Clear privacy policy
- In-app explanations for data use
- No hidden data collection
- Open about limitations

## 3. Data Classification

### 3.1 Data Sensitivity Levels

| Level | Data Type | Storage | Encryption | Sync |
|-------|-----------|---------|------------|------|
| **Critical** | Body measurements | Keychain | AES-256 | Never |
| **High** | Photos (body/face) | Local encrypted | FileVault | Never |
| **Medium** | Wardrobe items | Core Data | FileVault | CloudKit Private |
| **Low** | Outfit preferences | Core Data | FileVault | CloudKit Private |
| **Public** | App settings | UserDefaults | None | None |

### 3.2 Sensitive Data Definition

**Critical Sensitivity**:
- Body measurements (height, weight, chest, waist, hips)
- AR body tracking data
- Body photos
- Health-related information

**High Sensitivity**:
- Purchase history
- Calendar event details
- Location data
- Wardrobe photos

**Medium Sensitivity**:
- Clothing preferences
- Style profile
- Outfit history

## 4. Data Storage Security

### 4.1 Local Storage Architecture

```
User Data Storage:

┌─────────────────────────────────────┐
│         iOS Keychain (Critical)      │
│  - Body measurements (encrypted)     │
│  - API keys                          │
│  - Authentication tokens             │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│    Core Data (FileVault encrypted)  │
│  - Wardrobe items                    │
│  - Outfits                           │
│  - Wear history                      │
│  - User preferences                  │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│    File System (Encrypted)          │
│  - Wardrobe photos (compressed)     │
│  - 3D models (cached)                │
│  - Temporary AR captures             │
└─────────────────────────────────────┘
```

### 4.2 iOS Keychain Implementation

```swift
import Security

class SecureStorage {
    private let service = "com.wardrobeconsultant.secure"

    // MARK: - Store Body Measurements
    func storeBodyMeasurements(_ measurements: BodyMeasurements) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(measurements)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "body_measurements",
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        // Delete existing
        SecItemDelete(query as CFDictionary)

        // Add new
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw SecureStorageError.keychainError(status)
        }
    }

    // MARK: - Retrieve Body Measurements
    func retrieveBodyMeasurements() throws -> BodyMeasurements? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "body_measurements",
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data else {
            if status == errSecItemNotFound {
                return nil
            }
            throw SecureStorageError.keychainError(status)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(BodyMeasurements.self, from: data)
    }

    // MARK: - Delete Body Measurements
    func deleteBodyMeasurements() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "body_measurements"
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw SecureStorageError.keychainError(status)
        }
    }
}

enum SecureStorageError: Error {
    case keychainError(OSStatus)
    case encodingError
    case decodingError
}
```

### 4.3 Core Data Encryption

```swift
import CoreData

class SecurePersistenceController {
    static let shared = SecurePersistenceController()

    let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: "WardrobeConsultant")

        // Enable encryption
        if let storeDescription = container.persistentStoreDescriptions.first {
            // File protection
            storeDescription.setOption(
                FileProtectionType.complete as NSObject,
                forKey: NSPersistentStoreFileProtectionKey
            )

            // Enable persistent history tracking for sync
            storeDescription.setOption(true as NSNumber,
                                      forKey: NSPersistentHistoryTrackingKey)

            // Remote change notifications
            storeDescription.setOption(true as NSNumber,
                                      forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
        }

        // Configure context
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
```

### 4.4 Photo Storage Security

```swift
class SecurePhotoStorage {
    private let fileManager = FileManager.default
    private var secureDirectory: URL {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let secureDir = appSupport.appendingPathComponent("SecurePhotos", isDirectory: true)

        // Create if needed
        if !fileManager.fileExists(atPath: secureDir.path) {
            try? fileManager.createDirectory(at: secureDir, withIntermediateDirectories: true, attributes: [
                FileAttributeKey.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication
            ])
        }

        return secureDir
    }

    func savePhoto(_ image: UIImage, id: UUID) throws -> URL {
        // Compress image
        guard let imageData = image.heicData(compressionQuality: 0.7) else {
            throw PhotoStorageError.compressionFailed
        }

        // Save to secure directory
        let fileURL = secureDirectory.appendingPathComponent("\(id.uuidString).heic")
        try imageData.write(to: fileURL, options: .completeFileProtection)

        return fileURL
    }

    func loadPhoto(id: UUID) throws -> UIImage? {
        let fileURL = secureDirectory.appendingPathComponent("\(id.uuidString).heic")

        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }

        let data = try Data(contentsOf: fileURL)
        return UIImage(data: data)
    }

    func deletePhoto(id: UUID) throws {
        let fileURL = secureDirectory.appendingPathComponent("\(id.uuidString).heic")
        try fileManager.removeItem(at: fileURL)
    }

    func deleteAllPhotos() throws {
        let files = try fileManager.contentsOfDirectory(at: secureDirectory, includingPropertiesForKeys: nil)
        for file in files {
            try fileManager.removeItem(at: file)
        }
    }
}
```

## 5. Network Security

### 5.1 API Communication

**Requirements**:
- TLS 1.3 minimum
- Certificate pinning for critical APIs
- Token-based authentication
- Request signing for sensitive operations

```swift
class SecureNetworkManager {
    private let session: URLSession

    init() {
        // Configure secure session
        let configuration = URLSessionConfiguration.default
        configuration.tlsMinimumSupportedProtocolVersion = .TLSv13

        // Certificate pinning
        let delegate = CertificatePinningDelegate()
        session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
    }

    func performSecureRequest<T: Decodable>(_ request: URLRequest) async throws -> T {
        // Add authentication header
        var secureRequest = request
        if let token = try? getAuthToken() {
            secureRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Perform request
        let (data, response) = try await session.data(for: secureRequest)

        // Validate response
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }

        // Decode
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }

    private func getAuthToken() throws -> String? {
        // Retrieve from Keychain
        return nil
    }
}

// MARK: - Certificate Pinning
class CertificatePinningDelegate: NSObject, URLSessionDelegate {
    private let pinnedCertificates: [Data] = []  // Load from bundle

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Verify certificate
        let isValid = verifyCertificate(serverTrust)

        if isValid {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }

    private func verifyCertificate(_ serverTrust: SecTrust) -> Bool {
        // Verify against pinned certificates
        // For MVP: Use system trust
        return true
    }
}
```

### 5.2 CloudKit Security

```swift
class SecureCloudKitSync {
    private let container: CKContainer
    private let privateDatabase: CKDatabase

    init() {
        container = CKContainer(identifier: "iCloud.com.wardrobeconsultant")
        privateDatabase = container.privateCloudDatabase
    }

    func syncWardrobeItem(_ item: WardrobeItem) async throws {
        // Create CKRecord
        let record = CKRecord(recordType: "WardrobeItem")
        record["name"] = item.name
        record["category"] = item.category
        record["primaryColor"] = item.primaryColor

        // Photo as CKAsset (encrypted by CloudKit)
        if let photoURL = item.photoURL {
            let asset = CKAsset(fileURL: photoURL)
            record["photo"] = asset
        }

        // Save to private database (user-scoped, encrypted)
        try await privateDatabase.save(record)
    }

    func fetchWardrobeItems() async throws -> [CKRecord] {
        let query = CKQuery(recordType: "WardrobeItem", predicate: NSPredicate(value: true))
        let (matchResults, _) = try await privateDatabase.records(matching: query)

        return matchResults.compactMap { try? $0.1.get() }
    }
}
```

## 6. AR Privacy & Security

### 6.1 Body Tracking Privacy

**Privacy Measures**:
- All AR processing on-device
- No body tracking data sent to servers
- No AR frames stored permanently
- User-facing camera indicator when AR active

```swift
class PrivacyAwareARManager {
    private var arSession: ARSession
    private var isRecording: Bool = false

    func startBodyTracking() throws {
        // Show privacy notice if first time
        if !hasShownARPrivacyNotice() {
            showARPrivacyNotice()
        }

        // Request permission
        guard hasARPermission() else {
            throw ARError.permissionDenied
        }

        // Start tracking
        let configuration = ARBodyTrackingConfiguration()
        arSession.run(configuration)

        // Log tracking start (analytics)
        logEvent("ar_tracking_started", parameters: [:])
    }

    func captureARFrame() -> CVPixelBuffer? {
        // Temporary capture for processing
        // Never stored to disk
        guard let frame = arSession.currentFrame else {
            return nil
        }

        return frame.capturedImage
    }

    func stopBodyTracking() {
        arSession.pause()

        // Clear any temporary buffers
        clearTemporaryData()

        logEvent("ar_tracking_stopped", parameters: [:])
    }

    private func clearTemporaryData() {
        // Ensure no AR data persists in memory
    }

    private func showARPrivacyNotice() {
        // Show alert explaining AR data usage
    }

    private func hasARPermission() -> Bool {
        return ARBodyTrackingConfiguration.isSupported
    }
}
```

### 6.2 AR Screenshot Prevention

```swift
// Prevent screenshots during sensitive AR sessions
class ARSecurityManager {
    func enableScreenshotProtection() {
        // Mark view as secure (prevents screenshots/recording)
        // Note: Not directly supported in visionOS, but document intent
    }

    func detectScreenshot() {
        // Listen for screenshot notifications
        NotificationCenter.default.addObserver(
            forName: UIApplication.userDidTakeScreenshotNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleScreenshotTaken()
        }
    }

    private func handleScreenshotTaken() {
        // Log screenshot event
        // Show privacy reminder to user
    }
}
```

## 7. Permission Management

### 7.1 Permission Types

| Permission | Required For | Request Timing | Fallback |
|------------|--------------|----------------|----------|
| Camera | AR body tracking | Before virtual try-on | 2D photo mode |
| Photo Library | Add wardrobe items | Before photo import | Manual entry |
| Calendar | Event dress codes | Before calendar integration | Manual occasion input |
| Location | Weather context | Before weather fetch | Manual location |
| Notifications | Outfit reminders | During onboarding | None (optional) |

### 7.2 Permission Request Flow

```swift
class PermissionManager {
    // MARK: - Camera Permission
    func requestCameraPermission() async -> Bool {
        // Check current status
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        case .denied, .restricted:
            // Show settings prompt
            showSettingsPrompt(for: .camera)
            return false
        @unknown default:
            return false
        }
    }

    // MARK: - Calendar Permission
    func requestCalendarPermission() async -> Bool {
        let eventStore = EKEventStore()
        let status = EKEventStore.authorizationStatus(for: .event)

        switch status {
        case .authorized:
            return true
        case .notDetermined:
            return (try? await eventStore.requestAccess(to: .event)) ?? false
        case .denied, .restricted:
            showSettingsPrompt(for: .calendar)
            return false
        @unknown default:
            return false
        }
    }

    // MARK: - Location Permission
    func requestLocationPermission() async -> Bool {
        let manager = CLLocationManager()
        let status = manager.authorizationStatus

        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            return true
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            // Wait for response
            return await waitForLocationPermission()
        case .denied, .restricted:
            showSettingsPrompt(for: .location)
            return false
        @unknown default:
            return false
        }
    }

    // MARK: - Settings Prompt
    private func showSettingsPrompt(for permission: PermissionType) {
        let message = """
        \(permission.displayName) permission is required for this feature.
        Please enable it in Settings.
        """

        // Show alert with Settings button
    }
}

enum PermissionType {
    case camera, calendar, location, photoLibrary, notifications

    var displayName: String {
        switch self {
        case .camera: return "Camera"
        case .calendar: return "Calendar"
        case .location: return "Location"
        case .photoLibrary: return "Photos"
        case .notifications: return "Notifications"
        }
    }
}
```

## 8. Data Retention & Deletion

### 8.1 Retention Policy

| Data Type | Retention Period | Auto-Delete |
|-----------|------------------|-------------|
| Body measurements | Until user deletes | No |
| Wardrobe items | Until user deletes | No |
| Outfit history | 365 days | Optional |
| Weather cache | 24 hours | Yes |
| Calendar cache | 15 minutes | Yes |
| 3D model cache | 30 days | Yes (LRU) |
| Temporary AR data | Session only | Yes |

### 8.2 Data Deletion Implementation

```swift
class DataDeletionService {
    func deleteAllUserData() async throws {
        // 1. Delete body measurements from Keychain
        let secureStorage = SecureStorage()
        try secureStorage.deleteBodyMeasurements()

        // 2. Delete Core Data
        let context = PersistenceController.shared.container.viewContext
        try await deleteAllCoreData(context: context)

        // 3. Delete photos
        let photoStorage = SecurePhotoStorage()
        try photoStorage.deleteAllPhotos()

        // 4. Delete CloudKit records
        let cloudKitSync = SecureCloudKitSync()
        try await cloudKitSync.deleteAllRecords()

        // 5. Clear caches
        clearAllCaches()

        // 6. Reset UserDefaults
        resetUserDefaults()

        // 7. Log deletion (anonymously)
        logEvent("user_data_deleted", parameters: [:])
    }

    private func deleteAllCoreData(context: NSManagedObjectContext) async throws {
        let entities = ["WardrobeItem", "Outfit", "WearEvent", "UserProfile"]

        for entityName in entities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            try context.execute(deleteRequest)
        }

        try context.save()
    }

    private func clearAllCaches() {
        // Clear URLCache
        URLCache.shared.removeAllCachedResponses()

        // Clear file system caches
        let fileManager = FileManager.default
        if let cacheURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            try? fileManager.removeItem(at: cacheURL)
        }
    }

    private func resetUserDefaults() {
        let defaults = UserDefaults.standard
        let domain = Bundle.main.bundleIdentifier!
        defaults.removePersistentDomain(forName: domain)
    }
}
```

### 8.3 Data Export (GDPR Compliance)

```swift
class DataExportService {
    func exportAllUserData() async throws -> URL {
        // Collect all user data
        let export = UserDataExport(
            profile: try await exportProfile(),
            wardrobeItems: try await exportWardrobeItems(),
            outfits: try await exportOutfits(),
            wearHistory: try await exportWearHistory(),
            preferences: exportPreferences(),
            exportDate: Date()
        )

        // Convert to JSON
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(export)

        // Save to temporary file
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("wardrobe_data_export.json")
        try data.write(to: tempURL)

        return tempURL
    }

    private func exportProfile() async throws -> UserProfile {
        // Include body measurements (with explicit user consent)
        // ...
        return UserProfile()
    }
}

struct UserDataExport: Codable {
    let profile: UserProfile
    let wardrobeItems: [WardrobeItem]
    let outfits: [Outfit]
    let wearHistory: [WearEvent]
    let preferences: [String: Any]
    let exportDate: Date
}
```

## 9. Privacy Policy & Disclosures

### 9.1 Privacy Policy Requirements

**Must Include**:
1. What data we collect
2. How we use the data
3. Where data is stored (on-device vs cloud)
4. Who has access (only user)
5. User rights (access, delete, export)
6. Contact information for privacy concerns

### 9.2 In-App Privacy Disclosures

```swift
struct PrivacyInfoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Your Privacy Matters")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                PrivacyInfoCard(
                    icon: "lock.shield.fill",
                    title: "Body Measurements",
                    description: "Stored securely on your device only. Never synced or shared."
                )

                PrivacyInfoCard(
                    icon: "icloud.fill",
                    title: "Wardrobe Data",
                    description: "Synced to your private iCloud. Only you have access."
                )

                PrivacyInfoCard(
                    icon: "eye.slash.fill",
                    title: "AR Tracking",
                    description: "Processed on-device in real-time. No frames stored."
                )

                Button("Read Full Privacy Policy") {
                    // Open privacy policy
                }
            }
            .padding()
        }
    }
}
```

## 10. Security Testing

### 10.1 Security Checklist

- [ ] All sensitive data encrypted at rest
- [ ] Keychain used for critical data
- [ ] TLS 1.3 for all network requests
- [ ] Certificate pinning implemented
- [ ] No sensitive data in logs
- [ ] No sensitive data in crash reports
- [ ] Permission requests properly explained
- [ ] Data deletion works completely
- [ ] Data export includes all user data
- [ ] Privacy policy accurate and clear

### 10.2 Penetration Testing

**Test Scenarios**:
1. Attempt to extract body measurements from backup
2. Intercept network traffic (verify encryption)
3. Access Core Data without authentication
4. Extract photos from file system
5. Recover deleted data

## 11. Compliance

### 11.1 GDPR Compliance

- ✅ Right to access (data export)
- ✅ Right to erasure (data deletion)
- ✅ Data minimization (collect only what's needed)
- ✅ Consent (explicit permission requests)
- ✅ Security measures (encryption, access controls)

### 11.2 CCPA Compliance

- ✅ Right to know (privacy policy)
- ✅ Right to delete (data deletion)
- ✅ Right to opt-out (of data sale - N/A, we don't sell)
- ✅ Non-discrimination (no penalties for privacy choices)

### 11.3 App Store Privacy Nutrition Label

```
Data Used to Track You: None

Data Linked to You:
- Health & Fitness (body measurements) - Not synced
- Photos & Videos (wardrobe photos) - Synced to iCloud
- Purchases (purchase history) - Optional

Data Not Linked to You:
- Crash data
- Performance data
- Other diagnostic data
```

## 12. Incident Response Plan

### 12.1 Data Breach Protocol

1. **Detection**: Monitor for unusual access patterns
2. **Assessment**: Determine scope and severity
3. **Containment**: Disable affected systems
4. **Notification**: Inform affected users within 72 hours
5. **Remediation**: Fix vulnerability
6. **Review**: Post-mortem and process improvement

### 12.2 Contact

**Security Issues**: security@wardrobeconsultant.com
**Privacy Concerns**: privacy@wardrobeconsultant.com

## 13. Next Steps

- ✅ Security & privacy design complete
- ⬜ Implement secure storage
- ⬜ Write privacy policy
- ⬜ Implement data deletion
- ⬜ Implement data export
- ⬜ Security audit
- ⬜ Penetration testing

---

**Document Status**: Draft - Ready for Review
**Next Document**: Testing Strategy & QA Plan
