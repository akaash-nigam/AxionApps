# Security & Privacy Design
## Living Building System

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Draft

---

## 1. Overview

This document outlines the security and privacy architecture for the Living Building System, ensuring user data protection and secure device communication.

## 2. Privacy Principles

1. **On-Device Processing**: All sensitive data processed locally
2. **Data Minimization**: Collect only necessary data
3. **User Control**: Users control all data and permissions
4. **Transparency**: Clear communication about data usage
5. **No Cloud Dependency**: Core features work without cloud
6. **No Third-Party Tracking**: No analytics or tracking SDKs

## 3. Data Storage Security

### 3.1 SwiftData Encryption

```swift
// SwiftData with encryption
let modelConfiguration = ModelConfiguration(
    schema: schema,
    isStoredInMemoryOnly: false,
    allowsSave: true,
    cloudKitDatabase: .automatic,
    groupContainer: .identifier("group.com.lbs.app")
)

// File-level encryption enabled by default on iOS/visionOS
// Data protected by device passcode
```

### 3.2 Keychain for Sensitive Data

```swift
class KeychainHelper {
    enum KeychainError: Error {
        case itemNotFound
        case duplicateItem
        case unexpectedStatus(OSStatus)
    }

    static func save(_ data: String, for key: String) throws {
        guard let data = data.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    static func load(_ key: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            throw KeychainError.itemNotFound
        }

        guard let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            throw KeychainError.unexpectedStatus(status)
        }

        return string
    }

    static func delete(_ key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
}
```

### 3.3 Credential Management

```swift
struct SecureCredentials {
    // Store API keys in Keychain
    static func saveEnergyAPIKey(_ key: String) throws {
        try KeychainHelper.save(key, for: "com.lbs.energy.apikey")
    }

    static func loadEnergyAPIKey() throws -> String {
        try KeychainHelper.load("com.lbs.energy.apikey")
    }

    // Store HomeKit tokens
    static func saveHomeKitToken(_ token: String, for home: UUID) throws {
        try KeychainHelper.save(token, for: "com.lbs.homekit.\(home.uuidString)")
    }

    // Store Face ID templates (encrypted)
    static func saveFaceIDData(_ data: Data, for user: UUID) throws {
        // Face ID data is stored encrypted in Secure Enclave
        let keyQuery: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
            kSecAttrApplicationTag as String: "com.lbs.faceid.\(user.uuidString)",
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: true,
                kSecAttrAccessControl as String: SecAccessControlCreateWithFlags(
                    nil,
                    kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                    .biometryCurrentSet,
                    nil
                )!
            ]
        ]

        // Generate key in Secure Enclave
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(keyQuery as CFDictionary, &error) else {
            throw error!.takeRetainedValue() as Error
        }

        // Encrypt Face ID data with key
        // (Implementation details omitted)
    }
}
```

## 4. Network Security

### 4.1 TLS/HTTPS Only

```swift
class SecureNetworkService {
    private let session: URLSession

    init() {
        let config = URLSessionConfiguration.default
        config.tlsMinimumSupportedProtocolVersion = .TLSv12
        config.httpShouldUsePipelining = false

        self.session = URLSession(configuration: config)
    }

    func request(_ url: URL) async throws -> Data {
        // Ensure HTTPS
        guard url.scheme == "https" else {
            throw NetworkError.insecureConnection
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }

        return data
    }
}
```

### 4.2 Certificate Pinning

```swift
class CertificatePinningDelegate: NSObject, URLSessionDelegate {
    private let pinnedCertificates: [Data]

    init(pinnedCertificates: [Data]) {
        self.pinnedCertificates = pinnedCertificates
    }

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
        if verifyCertificate(serverTrust) {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }

    private func verifyCertificate(_ trust: SecTrust) -> Bool {
        guard let serverCertificate = SecTrustCopyCertificateChain(trust) as? [SecCertificate],
              let cert = serverCertificate.first else {
            return false
        }

        let serverCertData = SecCertificateCopyData(cert) as Data

        return pinnedCertificates.contains(serverCertData)
    }
}
```

## 5. Device Communication Security

### 5.1 HomeKit Security

```swift
// HomeKit uses end-to-end encryption by default
// All communication through encrypted HAP (HomeKit Accessory Protocol)

class SecureHomeKitService: HomeKitServiceProtocol {
    func sendCommand(to accessory: HMAccessory, characteristic: HMCharacteristic, value: Any) async throws {
        // HomeKit framework handles encryption automatically
        // Communication is end-to-end encrypted using Ed25519/ChaCha20-Poly1305

        try await withCheckedThrowingContinuation { continuation in
            characteristic.writeValue(value) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}
```

### 5.2 Local Network Privacy

```swift
// Info.plist entry required:
/*
<key>NSLocalNetworkUsageDescription</key>
<string>This app needs access to your local network to discover and control smart home devices.</string>
<key>NSBonjourServices</key>
<array>
    <string>_hap._tcp</string>
    <string>_matter._tcp</string>
</array>
*/

// Request local network permission
import Network

func requestLocalNetworkPermission() async -> Bool {
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "NetworkMonitor")

    return await withCheckedContinuation { continuation in
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                continuation.resume(returning: true)
            }
        }
        monitor.start(queue: queue)
    }
}
```

## 6. Authentication & Authorization

### 6.1 Face ID Authentication

```swift
import LocalAuthentication

class BiometricAuthManager {
    func authenticate() async throws -> Bool {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            throw AuthError.biometricsNotAvailable
        }

        return try await context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Authenticate to access your home"
        )
    }

    func identifyUser() async throws -> User? {
        guard try await authenticate() else {
            return nil
        }

        // Match Face ID data to registered user
        // (Implementation would use Vision framework for face recognition)
        return nil
    }
}

enum AuthError: Error {
    case biometricsNotAvailable
    case authenticationFailed
}
```

### 6.2 User Permissions

```swift
struct UserPermissions: Codable {
    var canControlDevices: Bool
    var canViewEnergyData: Bool
    var canModifySettings: Bool
    var canManageMaintenance: Bool
    var canAddDevices: Bool

    static func forRole(_ role: UserRole) -> UserPermissions {
        switch role {
        case .owner, .admin:
            return UserPermissions(
                canControlDevices: true,
                canViewEnergyData: true,
                canModifySettings: true,
                canManageMaintenance: true,
                canAddDevices: true
            )
        case .member:
            return UserPermissions(
                canControlDevices: true,
                canViewEnergyData: true,
                canModifySettings: false,
                canManageMaintenance: false,
                canAddDevices: false
            )
        case .guest:
            return UserPermissions(
                canControlDevices: false,
                canViewEnergyData: false,
                canModifySettings: false,
                canManageMaintenance: false,
                canAddDevices: false
            )
        }
    }
}

@MainActor
class PermissionManager {
    func checkPermission(_ permission: UserPermission, for user: User) -> Bool {
        let permissions = UserPermissions.forRole(user.role)

        switch permission {
        case .controlDevices: return permissions.canControlDevices
        case .viewEnergy: return permissions.canViewEnergyData
        case .modifySettings: return permissions.canModifySettings
        case .manageMaintenance: return permissions.canManageMaintenance
        case .addDevices: return permissions.canAddDevices
        }
    }
}

enum UserPermission {
    case controlDevices
    case viewEnergy
    case modifySettings
    case manageMaintenance
    case addDevices
}
```

## 7. Data Privacy

### 7.1 No Cloud Upload

```swift
// Ensure iCloud is opt-in only
let modelConfiguration = ModelConfiguration(
    schema: schema,
    isStoredInMemoryOnly: false,
    allowsSave: true,
    cloudKitDatabase: .none // Default: no cloud sync
)

// User can enable iCloud sync in settings
func enableiCloudSync() {
    let cloudConfig = ModelConfiguration(
        schema: schema,
        cloudKitDatabase: .automatic
    )
    // Recreate container with cloud sync
}
```

### 7.2 Data Export

```swift
class DataExportManager {
    func exportUserData(for user: User) async throws -> Data {
        // Export all user data in JSON format
        let export = UserDataExport(
            user: user,
            preferences: user.preferences,
            maintenanceHistory: [], // Load from database
            energyHistory: []
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try encoder.encode(export)
    }

    func deleteUserData(for user: User) async throws {
        // GDPR/CCPA compliance: complete data deletion
        // Remove from SwiftData
        // Remove from Keychain
        // Remove cached files
    }
}

struct UserDataExport: Codable {
    let user: User
    let preferences: UserPreferences?
    let maintenanceHistory: [TaskHistory]
    let energyHistory: [EnergyReading]
    let exportDate: Date = Date()
}
```

### 7.3 Privacy Manifests

```swift
// PrivacyInfo.xcprivacy
/*
{
  "NSPrivacyAccessedAPITypes": [
    {
      "NSPrivacyAccessedAPIType": "NSPrivacyAccessedAPICategoryUserDefaults",
      "NSPrivacyAccessedAPITypeReasons": ["CA92.1"]
    },
    {
      "NSPrivacyAccessedAPIType": "NSPrivacyAccessedAPICategoryFileTimestamp",
      "NSPrivacyAccessedAPITypeReasons": ["C617.1"]
    }
  ],
  "NSPrivacyCollectedDataTypes": [],
  "NSPrivacyTracking": false,
  "NSPrivacyTrackingDomains": []
}
*/
```

## 8. Audit Logging

### 8.1 Security Events

```swift
struct SecurityAuditLog: Codable {
    let timestamp: Date
    let eventType: SecurityEventType
    let userID: UUID?
    let deviceID: UUID?
    let success: Bool
    let details: String?
}

enum SecurityEventType: String, Codable {
    case login
    case logout
    case deviceControl
    case settingsChange
    case permissionChange
    case dataExport
    case dataDelete
}

class AuditLogger {
    func logEvent(
        _ type: SecurityEventType,
        user: User?,
        device: SmartDevice? = nil,
        success: Bool,
        details: String? = nil
    ) {
        let log = SecurityAuditLog(
            timestamp: Date(),
            eventType: type,
            userID: user?.id,
            deviceID: device?.id,
            success: success,
            details: details
        )

        // Write to secure log file
        writeToLog(log)

        // Keep logs for 90 days
        cleanOldLogs(olderThan: 90)
    }

    private func writeToLog(_ log: SecurityAuditLog) {
        // Append to encrypted log file
    }

    private func cleanOldLogs(olderThan days: Int) {
        // Delete logs older than specified days
    }
}
```

## 9. Secure Coding Practices

### 9.1 Input Validation

```swift
func validateDeviceName(_ name: String) throws {
    // Prevent injection attacks
    guard name.count <= 100 else {
        throw ValidationError.tooLong
    }

    guard !name.isEmpty else {
        throw ValidationError.empty
    }

    // Prevent special characters that could cause issues
    let allowedCharacters = CharacterSet.alphanumerics
        .union(.whitespaces)
        .union(CharacterSet(charactersIn: "-_()"))

    guard name.unicodeScalars.allSatisfy({ allowedCharacters.contains($0) }) else {
        throw ValidationError.invalidCharacters
    }
}

enum ValidationError: Error {
    case empty
    case tooLong
    case invalidCharacters
}
```

### 9.2 SQL Injection Prevention

```swift
// SwiftData uses parameterized queries automatically
// No string concatenation for queries

let predicate = #Predicate<SmartDevice> { device in
    device.name.contains(searchTerm) // Safe: parameterized
}

// Never do this:
// let query = "SELECT * FROM devices WHERE name = '\(searchTerm)'" // Unsafe!
```

## 10. Compliance

### 10.1 Privacy Policy

- Clear explanation of data collection
- Description of data usage
- User rights (access, deletion, export)
- Contact information for privacy concerns

### 10.2 Data Retention

```swift
class DataRetentionPolicy {
    // Energy readings: 2 years
    static let energyRetentionDays = 730

    // Environment readings: 1 year
    static let environmentRetentionDays = 365

    // Audit logs: 90 days
    static let auditLogRetentionDays = 90

    // Maintenance history: Indefinite

    func enforceRetention() async {
        // Delete old energy readings
        await deleteEnergyReadings(olderThan: Self.energyRetentionDays)

        // Delete old environment readings
        await deleteEnvironmentReadings(olderThan: Self.environmentRetentionDays)

        // Delete old audit logs
        await deleteAuditLogs(olderThan: Self.auditLogRetentionDays)
    }
}
```

---

**Document Owner**: Security Team
**Review Cycle**: Quarterly
**Next Review**: 2026-02-24
