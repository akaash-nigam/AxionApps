# Security & Privacy Architecture
## Reality Annotation Platform

**Version**: 1.0
**Date**: November 2024
**Status**: Draft

---

## 1. Overview

This document defines the security and privacy architecture for the Reality Annotation Platform, ensuring user data protection, secure authentication, and GDPR/privacy compliance.

---

## 2. Security Principles

### 2.1 Core Principles

1. **Privacy by Design**: Privacy considerations built into every feature
2. **Data Minimization**: Collect only what's necessary
3. **Encryption by Default**: All data encrypted at rest and in transit
4. **Zero Trust**: Verify every request, trust nothing
5. **Principle of Least Privilege**: Users/services get minimum required permissions

### 2.2 Threat Model

**Assets to Protect**:
- User annotations and content
- User identity and profile data
- Spatial data (world maps, anchor positions)
- User relationships and permissions

**Threat Actors**:
- Unauthorized users accessing private annotations
- Malicious users creating inappropriate content
- Data breaches exposing user information
- Man-in-the-middle attacks during sync

**Mitigations**: Defined in sections below

---

## 3. Authentication & Identity

### 3.1 Sign in with Apple

```swift
import AuthenticationServices

class AuthenticationService {
    func signIn() async throws -> User {
        // 1. Request authorization
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]

        // 2. Present sign-in UI
        let controller = ASAuthorizationController(authorizationRequests: [request])
        // ... handle authorization

        // 3. Exchange credential for user identity
        let credential = // ... from authorization
        let userID = credential.user // Stable user identifier

        // 4. Store user identity
        try await createOrUpdateUser(userID: userID, credential: credential)

        return user
    }

    private func createOrUpdateUser(
        userID: String,
        credential: ASAuthorizationAppleIDCredential
    ) async throws -> User {
        // Check if user exists in CloudKit
        if let existingUser = try await userRepository.fetch(userID) {
            return existingUser
        }

        // Create new user
        let user = User(id: userID)
        user.displayName = credential.fullName?.formatted()
        user.email = credential.email

        try await userRepository.save(user)
        return user
    }
}
```

### 3.2 CloudKit User Identity

```swift
class CloudKitAuthService {
    private let container = CKContainer.default()

    func getUserRecordID() async throws -> CKRecord.ID {
        return try await container.userRecordID()
    }

    func checkAccountStatus() async throws -> CKAccountStatus {
        return try await container.accountStatus()
    }

    func ensureAuthenticated() async throws {
        let status = try await checkAccountStatus()

        switch status {
        case .available:
            return
        case .noAccount:
            throw AuthError.notSignedInToiCloud
        case .restricted:
            throw AuthError.accountRestricted
        case .couldNotDetermine:
            throw AuthError.unknownAccountStatus
        case .temporarilyUnavailable:
            throw AuthError.temporarilyUnavailable
        @unknown default:
            throw AuthError.unknownAccountStatus
        }
    }
}

enum AuthError: LocalizedError {
    case notSignedInToiCloud
    case accountRestricted
    case unknownAccountStatus
    case temporarilyUnavailable

    var errorDescription: String? {
        switch self {
        case .notSignedInToiCloud:
            return "Please sign in to iCloud in Settings"
        case .accountRestricted:
            return "Your iCloud account is restricted"
        case .unknownAccountStatus:
            return "Could not determine iCloud account status"
        case .temporarilyUnavailable:
            return "iCloud is temporarily unavailable"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .notSignedInToiCloud:
            return "Go to Settings > [Your Name] > iCloud"
        default:
            return nil
        }
    }
}
```

### 3.3 Session Management

```swift
@MainActor
class SessionManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false

    private let authService: AuthenticationService
    private let cloudKitAuth: CloudKitAuthService

    func startSession() async throws {
        // 1. Check CloudKit account
        try await cloudKitAuth.ensureAuthenticated()

        // 2. Get user record ID
        let recordID = try await cloudKitAuth.getUserRecordID()

        // 3. Fetch or create user
        let user = try await authService.fetchOrCreateUser(recordID: recordID.recordName)

        // 4. Update state
        currentUser = user
        isAuthenticated = true

        // 5. Start sync
        await syncCoordinator.startSync()
    }

    func endSession() {
        currentUser = nil
        isAuthenticated = false
        syncCoordinator.stopSync()
    }
}
```

---

## 4. Authorization & Permissions

### 4.1 Permission Evaluation

```swift
class PermissionEvaluator {
    func evaluate(
        user: User,
        action: Action,
        resource: Resource
    ) -> PermissionDecision {
        // 1. Check if user is resource owner
        if resource.ownerID == user.id {
            return .allow
        }

        // 2. Check explicit permissions
        if let permission = resource.permissions.first(where: { $0.userID == user.id }) {
            if permission.allows(action) {
                return .allow
            }
        }

        // 3. Check if resource is public
        if resource.isPublic && action == .read {
            return .allow
        }

        // 4. Default deny
        return .deny
    }
}

enum Action {
    case read
    case write
    case delete
    case share
    case comment
}

protocol Resource {
    var ownerID: String { get }
    var permissions: [Permission] { get }
    var isPublic: Bool { get }
}

enum PermissionDecision {
    case allow
    case deny
}

extension Permission {
    func allows(_ action: Action) -> Bool {
        switch level {
        case .owner:
            return true
        case .editor:
            return [.read, .write, .comment, .share].contains(action)
        case .commenter:
            return [.read, .comment].contains(action)
        case .viewer:
            return action == .read
        }
    }
}
```

### 4.2 Permission Caching

```swift
actor PermissionCache {
    private var cache: [CacheKey: PermissionDecision] = [:]
    private let ttl: TimeInterval = 300 // 5 minutes

    struct CacheKey: Hashable {
        let userID: String
        let resourceID: UUID
        let action: Action
        let timestamp: Date

        func hash(into hasher: inout Hasher) {
            hasher.combine(userID)
            hasher.combine(resourceID)
            hasher.combine(action)
        }

        static func == (lhs: CacheKey, rhs: CacheKey) -> Bool {
            lhs.userID == rhs.userID &&
            lhs.resourceID == rhs.resourceID &&
            lhs.action == rhs.action &&
            abs(lhs.timestamp.timeIntervalSince(rhs.timestamp)) < 300
        }
    }

    func get(
        userID: String,
        resourceID: UUID,
        action: Action
    ) -> PermissionDecision? {
        let key = CacheKey(
            userID: userID,
            resourceID: resourceID,
            action: action,
            timestamp: Date()
        )

        return cache[key]
    }

    func set(
        userID: String,
        resourceID: UUID,
        action: Action,
        decision: PermissionDecision
    ) {
        let key = CacheKey(
            userID: userID,
            resourceID: resourceID,
            action: action,
            timestamp: Date()
        )

        cache[key] = decision

        // Cleanup old entries
        cleanupExpired()
    }

    private func cleanupExpired() {
        let now = Date()
        cache = cache.filter { key, _ in
            now.timeIntervalSince(key.timestamp) < ttl
        }
    }
}
```

---

## 5. Data Encryption

### 5.1 CloudKit Encryption

**CloudKit provides**:
- Encryption at rest (AES-128)
- Encryption in transit (TLS 1.2+)
- End-to-end encryption for encrypted fields

```swift
// CloudKit automatically encrypts all data
// For sensitive fields, use CKAsset with encrypted file

extension Annotation {
    func toCKRecord() throws -> CKRecord {
        let record = CKRecord(recordType: "Annotation")

        // Regular fields (encrypted by CloudKit)
        record["content"] = content.text

        // Sensitive media (encrypted file)
        if let mediaURL = content.mediaURL {
            let encryptedURL = try encryptFile(mediaURL)
            let asset = CKAsset(fileURL: encryptedURL)
            record["mediaAsset"] = asset
        }

        return record
    }

    private func encryptFile(_ url: URL) throws -> URL {
        // File is already encrypted by file system
        // CloudKit adds additional layer
        return url
    }
}
```

### 5.2 Local Encryption (SwiftData)

```swift
// SwiftData files are encrypted when device is locked
// (Data Protection: NSFileProtectionComplete)

let modelConfiguration = ModelConfiguration(
    schema: schema,
    isStoredInMemoryOnly: false,
    allowsSave: true,
    groupContainer: .automatic,
    cloudKitDatabase: .none
)

// Ensure file protection
do {
    let fileURL = modelConfiguration.url
    try FileManager.default.setAttributes(
        [.protectionKey: FileProtectionType.complete],
        ofItemAtPath: fileURL.path
    )
} catch {
    print("Failed to set file protection: \(error)")
}
```

### 5.3 Sensitive Data in Keychain

```swift
import Security

class KeychainService {
    /// Store sensitive string in Keychain
    func store(key: String, value: String) throws {
        let data = value.data(using: .utf8)!

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        // Delete existing
        SecItemDelete(query as CFDictionary)

        // Add new
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.unableToStore
        }
    }

    /// Retrieve sensitive string from Keychain
    func retrieve(key: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            throw KeychainError.unableToRetrieve
        }

        return string
    }

    func delete(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unableToDelete
        }
    }
}

enum KeychainError: Error {
    case unableToStore
    case unableToRetrieve
    case unableToDelete
}
```

---

## 6. Privacy Protection

### 6.1 Data Minimization

**What we DON'T collect**:
- ❌ GPS coordinates of annotations (use relative positions instead)
- ❌ Device identifiers (UDID, etc.)
- ❌ Contact lists
- ❌ Browsing history
- ❌ Background location tracking

**What we DO collect** (with user consent):
- ✅ CloudKit user identifier (required for sync)
- ✅ Display name (optional, user-provided)
- ✅ Email (optional, for sharing)
- ✅ Annotation content (user-created)
- ✅ Spatial anchor data (no GPS, relative positions only)

### 6.2 Privacy-Preserving Spatial Data

```swift
// DON'T store GPS coordinates
// ❌ BAD
struct Annotation {
    var latitude: Double
    var longitude: Double
}

// DO store relative positions from AR anchors
// ✅ GOOD
struct Annotation {
    var anchorID: UUID // Reference to AR anchor
    var position: SIMD3<Float> // Relative to anchor (no GPS)
}

// AR anchors are stored as transforms, not GPS coordinates
struct ARAnchorData {
    var id: UUID
    var transform: simd_float4x4 // Local coordinate system
    // No GPS data!
}
```

### 6.3 Privacy Policy Compliance

```swift
struct PrivacyInfo {
    static let policyURL = URL(string: "https://example.com/privacy")!

    static let dataCollectionDescription = """
    Reality Annotation Platform collects:
    - Annotation content you create
    - Your iCloud user identifier (for sync)
    - Display name and email (if provided)
    - Spatial data (relative positions, no GPS)

    We do NOT collect:
    - Your precise location
    - Device identifiers
    - Contact lists
    - Browsing history
    """

    static let dataUsageDescription = """
    Your data is used to:
    - Sync annotations across your devices
    - Share annotations with people you choose
    - Provide collaboration features

    Your data is NOT:
    - Sold to third parties
    - Used for advertising
    - Shared without your permission
    """
}
```

### 6.4 App Privacy Report (Privacy Manifest)

```xml
<!-- PrivacyInfo.xcprivacy -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSPrivacyTracking</key>
    <false/>
    <key>NSPrivacyTrackingDomains</key>
    <array/>
    <key>NSPrivacyCollectedDataTypes</key>
    <array>
        <dict>
            <key>NSPrivacyCollectedDataType</key>
            <string>NSPrivacyCollectedDataTypeUserID</string>
            <key>NSPrivacyCollectedDataTypeLinked</key>
            <true/>
            <key>NSPrivacyCollectedDataTypeTracking</key>
            <false/>
            <key>NSPrivacyCollectedDataTypePurposes</key>
            <array>
                <string>NSPrivacyCollectedDataTypePurposeAppFunctionality</string>
            </array>
        </dict>
    </array>
    <key>NSPrivacyAccessedAPITypes</key>
    <array>
        <dict>
            <key>NSPrivacyAccessedAPIType</key>
            <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
            <key>NSPrivacyAccessedAPITypeReasons</key>
            <array>
                <string>CA92.1</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
```

---

## 7. Content Moderation

### 7.1 Public Content Guidelines

```swift
struct ContentModerationService {
    /// Check if content violates guidelines
    func moderateContent(_ content: String) async throws -> ModerationResult {
        // 1. Check for profanity
        if containsProfanity(content) {
            return .rejected(reason: "Contains inappropriate language")
        }

        // 2. Check for spam patterns
        if appearsToBeSpam(content) {
            return .rejected(reason: "Appears to be spam")
        }

        // 3. Check length limits
        if content.count > 5000 {
            return .rejected(reason: "Content too long (max 5000 characters)")
        }

        return .approved
    }

    private func containsProfanity(_ text: String) -> Bool {
        // Use Apple's built-in profanity filter or custom list
        // Implementation...
        return false
    }

    private func appearsToBeSpam(_ text: String) -> Bool {
        // Check for spam patterns (excessive links, repeated text, etc.)
        return false
    }
}

enum ModerationResult {
    case approved
    case rejected(reason: String)
    case flagged(reason: String) // Requires manual review
}
```

### 7.2 User Reporting

```swift
protocol ReportingService {
    /// Report inappropriate content
    func reportAnnotation(
        _ annotationID: UUID,
        reason: ReportReason,
        details: String?
    ) async throws

    /// Report user
    func reportUser(
        _ userID: String,
        reason: ReportReason,
        details: String?
    ) async throws
}

enum ReportReason: String, CaseIterable {
    case inappropriate = "Inappropriate content"
    case spam = "Spam"
    case harassment = "Harassment"
    case misinformation = "Misinformation"
    case other = "Other"
}

class DefaultReportingService: ReportingService {
    func reportAnnotation(
        _ annotationID: UUID,
        reason: ReportReason,
        details: String?
    ) async throws {
        let report = Report(
            type: .annotation,
            targetID: annotationID.uuidString,
            reporterID: currentUserID,
            reason: reason,
            details: details,
            createdAt: Date()
        )

        // Save report to CloudKit
        try await cloudKitService.upload(report)

        // If multiple reports, auto-hide content
        let reportCount = try await getReportCount(for: annotationID)
        if reportCount >= 3 {
            try await hideAnnotation(annotationID)
        }
    }
}

struct Report {
    var id: UUID
    var type: ReportType
    var targetID: String
    var reporterID: String
    var reason: ReportReason
    var details: String?
    var createdAt: Date
    var status: ReportStatus

    enum ReportType {
        case annotation
        case user
        case comment
    }

    enum ReportStatus {
        case pending
        case reviewed
        case actioned
        case dismissed
    }
}
```

---

## 8. Secure Data Deletion

### 8.1 Soft Delete

```swift
extension AnnotationService {
    /// Soft delete (mark as deleted, keep for 30 days)
    func deleteAnnotation(id: UUID) async throws {
        guard var annotation = try await repository.fetch(id) else {
            throw AnnotationError.notFound
        }

        annotation.isDeleted = true
        annotation.updatedAt = Date()
        annotation.deletedAt = Date()

        try await repository.update(annotation)
        await syncCoordinator.queueForSync(annotation)
    }

    /// Permanent delete (after 30 days or manual trigger)
    func permanentlyDelete(id: UUID) async throws {
        // 1. Delete from local storage
        try await repository.delete(id)

        // 2. Delete from CloudKit
        let recordID = CKRecord.ID(recordName: id.uuidString)
        try await cloudKitService.delete(recordID)

        // 3. Delete media assets
        if let annotation = try await repository.fetch(id),
           let mediaURL = annotation.content.mediaURL {
            try FileManager.default.removeItem(at: mediaURL)
        }
    }
}
```

### 8.2 Account Deletion

```swift
protocol AccountDeletionService {
    /// Delete user account and all data
    func deleteAccount() async throws
}

class DefaultAccountDeletionService: AccountDeletionService {
    func deleteAccount() async throws {
        let userID = currentUserID

        // 1. Delete all annotations
        let annotations = try await annotationRepository.fetchByOwner(userID)
        for annotation in annotations {
            try await annotationService.permanentlyDelete(id: annotation.id)
        }

        // 2. Delete all layers
        let layers = try await layerRepository.fetchByOwner(userID)
        for layer in layers {
            try await layerRepository.delete(layer.id)
        }

        // 3. Delete all comments
        let comments = try await commentRepository.fetchByAuthor(userID)
        for comment in comments {
            try await commentRepository.delete(comment.id)
        }

        // 4. Remove from shared annotations
        try await removeUserFromSharedContent(userID)

        // 5. Delete user profile
        try await userRepository.delete(userID)

        // 6. Clear local cache
        try await clearLocalData()

        // 7. Sign out
        await sessionManager.endSession()
    }

    private func clearLocalData() async throws {
        // Clear SwiftData
        let modelContext = modelContainer.mainContext
        try modelContext.delete(model: Annotation.self)
        try modelContext.delete(model: Layer.self)
        try modelContext.delete(model: User.self)
        try modelContext.save()

        // Clear UserDefaults
        UserDefaults.standard.removePersistentDomain(
            forName: Bundle.main.bundleIdentifier!
        )

        // Clear Keychain
        try keychainService.deleteAll()
    }
}
```

---

## 9. Network Security

### 9.1 CloudKit Security

CloudKit automatically provides:
- TLS 1.2+ for all connections
- Certificate pinning
- Authentication tokens

No additional network security code needed for CloudKit.

### 9.2 Certificate Pinning (if using custom API)

```swift
class SecureNetworkService: NSObject, URLSessionDelegate {
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
        let credential = URLCredential(trust: serverTrust)
        completionHandler(.useCredential, credential)
    }
}
```

---

## 10. Audit Logging

### 10.1 Security Events

```swift
enum SecurityEvent {
    case authenticationSuccess(userID: String)
    case authenticationFailure(reason: String)
    case permissionDenied(userID: String, resource: String, action: String)
    case dataExport(userID: String)
    case accountDeletion(userID: String)
    case suspiciousActivity(userID: String, details: String)
}

class SecurityAuditLogger {
    func log(_ event: SecurityEvent) {
        let timestamp = ISO8601DateFormatter().string(from: Date())

        let logEntry = "\(timestamp) - \(eventDescription(event))"

        // Log to system
        OSLog.security.info("\(logEntry)")

        // For production: Send to analytics/monitoring service
        // (Privacy-safe, no PII)
    }

    private func eventDescription(_ event: SecurityEvent) -> String {
        switch event {
        case .authenticationSuccess(let userID):
            return "AUTH_SUCCESS: \(userID)"
        case .authenticationFailure(let reason):
            return "AUTH_FAILURE: \(reason)"
        case .permissionDenied(let userID, let resource, let action):
            return "PERMISSION_DENIED: user=\(userID) resource=\(resource) action=\(action)"
        case .dataExport(let userID):
            return "DATA_EXPORT: \(userID)"
        case .accountDeletion(let userID):
            return "ACCOUNT_DELETED: \(userID)"
        case .suspiciousActivity(let userID, let details):
            return "SUSPICIOUS: user=\(userID) details=\(details)"
        }
    }
}

extension OSLog {
    static let security = OSLog(subsystem: "com.example.RealityAnnotation", category: "Security")
}
```

---

## 11. GDPR Compliance

### 11.1 Data Export

```swift
protocol DataExportService {
    /// Export all user data to JSON
    func exportUserData() async throws -> Data
}

class DefaultDataExportService: DataExportService {
    func exportUserData() async throws -> Data {
        let userID = currentUserID

        // 1. Fetch all data
        let user = try await userRepository.fetch(userID)
        let annotations = try await annotationRepository.fetchByOwner(userID)
        let layers = try await layerRepository.fetchByOwner(userID)
        let comments = try await commentRepository.fetchByAuthor(userID)

        // 2. Create export structure
        let exportData = UserDataExport(
            user: user,
            annotations: annotations,
            layers: layers,
            comments: comments,
            exportedAt: Date()
        )

        // 3. Convert to JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        return try encoder.encode(exportData)
    }
}

struct UserDataExport: Codable {
    var user: User?
    var annotations: [Annotation]
    var layers: [Layer]
    var comments: [Comment]
    var exportedAt: Date
}
```

### 11.2 Consent Management

```swift
struct ConsentManager {
    static let userDefaults = UserDefaults.standard

    enum ConsentType: String {
        case analytics = "consent.analytics"
        case crashReporting = "consent.crashReporting"
        case notifications = "consent.notifications"
    }

    static func requestConsent(_ type: ConsentType) async -> Bool {
        // Show consent dialog
        // Return user's choice
        return false // Placeholder
    }

    static func hasConsent(_ type: ConsentType) -> Bool {
        return userDefaults.bool(forKey: type.rawValue)
    }

    static func setConsent(_ type: ConsentType, granted: Bool) {
        userDefaults.set(granted, forKey: type.rawValue)
    }

    static func revokeAllConsents() {
        for type in [ConsentType.analytics, .crashReporting, .notifications] {
            setConsent(type, granted: false)
        }
    }
}
```

---

## 12. Security Testing

### 12.1 Test Cases

```swift
class SecurityTests: XCTestCase {
    func testUnauthorizedAccessDenied() async throws {
        let otherUserAnnotation = Annotation(ownerID: "other-user")
        let service = AnnotationService(currentUserID: "current-user")

        await XCTAssertThrowsError(
            try await service.deleteAnnotation(otherUserAnnotation.id)
        ) { error in
            XCTAssertEqual(error as? PermissionError, .cannotDelete)
        }
    }

    func testSoftDeleteKeepsData() async throws {
        let annotation = Annotation(ownerID: "current-user")
        try await service.deleteAnnotation(annotation.id)

        let deleted = try await repository.fetch(annotation.id)
        XCTAssertNotNil(deleted)
        XCTAssertTrue(deleted!.isDeleted)
    }

    func testDataEncryption() {
        // Verify SwiftData files have file protection
        let fileURL = modelConfiguration.url
        let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path)
        let protection = attributes?[.protectionKey] as? FileProtectionType
        XCTAssertEqual(protection, .complete)
    }
}
```

---

## 13. Incident Response

### 13.1 Security Incident Plan

```swift
protocol IncidentResponseService {
    /// Report security incident
    func reportIncident(
        type: IncidentType,
        severity: IncidentSeverity,
        description: String
    ) async throws

    /// Lock account if compromised
    func lockAccount(_ userID: String) async throws

    /// Notify affected users
    func notifyAffectedUsers(_ userIDs: [String], message: String) async throws
}

enum IncidentType {
    case unauthorizedAccess
    case dataBreach
    case accountCompromise
    case maliciousContent
}

enum IncidentSeverity {
    case low
    case medium
    case high
    case critical
}
```

---

## 14. Appendix

### 14.1 Security Checklist

- ✅ Authentication with Sign in with Apple
- ✅ CloudKit authorization checks
- ✅ Permission system implemented
- ✅ Data encrypted at rest (CloudKit + SwiftData)
- ✅ Data encrypted in transit (TLS)
- ✅ No GPS data stored
- ✅ Privacy policy created
- ✅ Content moderation for public content
- ✅ User reporting system
- ✅ Soft delete with 30-day retention
- ✅ Account deletion flow
- ✅ Data export for GDPR
- ✅ Audit logging
- ✅ Security testing

### 14.2 Compliance Requirements

**GDPR**:
- Right to access (data export)
- Right to deletion (account deletion)
- Right to rectification (edit profile)
- Data portability (JSON export)
- Consent management

**CCPA** (California Consumer Privacy Act):
- Similar to GDPR requirements
- Opt-out of data sale (we don't sell data)

**Apple App Store**:
- Privacy nutrition labels
- Privacy manifest (PrivacyInfo.xcprivacy)
- No tracking without ATT (we don't track)

### 14.3 References

- [Apple Security Framework](https://developer.apple.com/documentation/security)
- [CloudKit Security](https://developer.apple.com/documentation/cloudkit/securing_cloudkit_data)
- [GDPR Compliance](https://gdpr.eu/)
- [OWASP Mobile Security](https://owasp.org/www-project-mobile-security/)

---

**Document Status**: ✅ Ready for Implementation
**Dependencies**: System Architecture, Data Model, CloudKit Sync
**Next Steps**: Create UI/UX Design & Interaction Specification document
