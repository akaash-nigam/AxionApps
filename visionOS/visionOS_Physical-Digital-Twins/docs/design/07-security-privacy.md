# Security & Privacy Implementation Plan

## Overview

Physical-Digital Twins handles sensitive personal inventory data. This document outlines security measures, privacy controls, and compliance strategies.

## Security Principles

1. **Privacy by Design**: User data is private by default
2. **Local-First**: All data accessible offline, cloud sync optional
3. **Encryption**: Data encrypted at rest and in transit
4. **Minimal Collection**: Only collect necessary data
5. **User Control**: Users own and control their data

## Data Classification

### Sensitivity Levels

| Data Type | Sensitivity | Storage | Encryption |
|-----------|-------------|---------|------------|
| Inventory items | High | Core Data + CloudKit | Yes |
| Photos | High | Local files | FileProtection |
| API keys | Critical | Keychain | Hardware-backed |
| User preferences | Low | UserDefaults | No |
| Analytics | Low | Local only | No |
| Recognition logs | Medium | Core Data | Yes |

## Authentication & Authorization

### Sign in with Apple (Optional)

```swift
import AuthenticationServices

class AuthenticationManager {
    func signIn() async throws -> UserCredential {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let result = try await ASAuthorizationController(
            authorizationRequests: [request]
        ).performRequests()

        guard let credential = result.first as? ASAuthorizationAppleIDCredential else {
            throw AuthError.invalidCredential
        }

        return UserCredential(
            userID: credential.user,
            email: credential.email,
            fullName: credential.fullName
        )
    }
}
```

**Privacy Features**:
- Hide my email (random email forwarding)
- No password required
- Two-factor authentication built-in
- No tracking across apps

### Local-Only Mode

```swift
class PrivacyManager {
    @AppStorage("cloudSyncEnabled") private var cloudSyncEnabled = false
    @AppStorage("analyticsEnabled") private var analyticsEnabled = false

    func enableLocalOnlyMode() {
        cloudSyncEnabled = false
        analyticsEnabled = false
        disableCloudKit()
    }
}
```

## Data Encryption

### At Rest

#### 1. Core Data Encryption

```swift
// Persistent store with file protection
let description = NSPersistentStoreDescription()
description.setOption(
    FileProtectionType.complete as NSObject,
    forKey: NSPersistentStoreFileProtectionKey
)
```

**FileProtection Levels**:
- `.complete`: Available only when device unlocked (recommended)
- `.completeUnlessOpen`: Accessible after first unlock
- `.completeUntilFirstUserAuthentication`: Most permissive

#### 2. Keychain Storage (API Keys)

```swift
class SecureStorage {
    func store(key: String, value: String, accessibility: CFString = kSecAttrAccessibleWhenUnlocked) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: value.data(using: .utf8)!,
            kSecAttrAccessible as String: accessibility
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.storeFailed(status)
        }
    }
}
```

#### 3. Image Encryption

```swift
class ImageEncryption {
    func encryptImage(_ image: UIImage) throws -> Data {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw EncryptionError.invalidImage
        }

        // Use CryptoKit for encryption
        let key = SymmetricKey(size: .bits256)
        let sealedBox = try AES.GCM.seal(imageData, using: key)

        // Store key in Keychain
        try SecureStorage().store(key: "image_encryption_key", value: key.rawRepresentation.base64EncodedString())

        return sealedBox.combined!
    }
}
```

### In Transit

#### 1. TLS/HTTPS Only

```swift
// Info.plist configuration
// NSAppTransportSecurity
//   NSAllowsArbitraryLoads: false (enforce HTTPS)
```

#### 2. Certificate Pinning (Optional)

```swift
class NetworkSecurity {
    func validateCertificate(_ challenge: URLAuthenticationChallenge) -> Bool {
        guard let serverTrust = challenge.protectionSpace.serverTrust,
              let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
            return false
        }

        let serverCertificateData = SecCertificateCopyData(certificate) as Data
        let pinnedCertificateData = loadPinnedCertificate()

        return serverCertificateData == pinnedCertificateData
    }
}
```

## CloudKit Privacy

### Private Database Only

```swift
// All user data in CloudKit private database
let container = CKContainer(identifier: "iCloud.com.yourcompany.physicaldigitaltwins")
let privateDB = container.privateCloudDatabase

// Never use shared or public databases for inventory data
```

### Encryption

- CloudKit encrypts data at rest automatically
- End-to-end encryption for sensitive fields (coming in future CloudKit versions)
- User data never accessible by app developers

## Privacy Controls

### User Preferences

```swift
struct PrivacySettings: Codable {
    var cloudSyncEnabled: Bool = false
    var analyticsEnabled: Bool = false
    var cameraPermissionGranted: Bool = false
    var locationSharingEnabled: Bool = false

    // Photo privacy
    var blurFacesInPhotos: Bool = true
    var stripEXIFData: Bool = true

    // Sharing
    var allowSharing: Bool = false
}
```

### Data Export (GDPR Compliance)

```swift
class DataExporter {
    func exportAllUserData() async throws -> URL {
        let exportData = ExportPackage(
            inventory: try await fetchAllInventory(),
            twins: try await fetchAllTwins(),
            photos: try await fetchAllPhotos(),
            settings: fetchUserSettings()
        )

        let jsonData = try JSONEncoder().encode(exportData)
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("export.json")
        try jsonData.write(to: fileURL)

        return fileURL
    }
}
```

### Data Deletion

```swift
class DataDeletionManager {
    func deleteAllUserData() async throws {
        // 1. Delete local data
        try await deleteLocalData()

        // 2. Delete CloudKit data
        try await deleteCloudKitData()

        // 3. Delete cached images
        try deleteCachedImages()

        // 4. Clear Keychain
        try clearKeychain()

        // 5. Reset UserDefaults
        resetUserDefaults()
    }
}
```

## Permissions Management

### Required Permissions

```swift
// Info.plist entries
NSCameraUsageDescription: "Camera access is required to scan and recognize objects"
NSPhotoLibraryAddUsageDescription: "Save photos of your items to Photo Library"
```

### Permission Flow

```swift
class PermissionManager {
    func requestCameraPermission() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        case .denied, .restricted:
            showSettingsPrompt()
            return false
        @unknown default:
            return false
        }
    }
}
```

## API Key Security

### Never Hardcode Keys

```swift
// ❌ BAD
let apiKey = "sk-1234567890abcdef"

// ✅ GOOD: Load from secure backend
class APIKeyManager {
    func fetchAPIKey(for service: String) async throws -> String {
        // Fetch from secure backend service
        let url = URL(string: "https://api.yourapp.com/keys/\(service)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(KeyResponse.self, from: data)

        // Store in Keychain
        try SecureStorage().store(key: service, value: response.key)

        return response.key
    }
}
```

### Key Rotation

```swift
class KeyRotationManager {
    func rotateAPIKeys() async throws {
        let services = ["amazon", "google", "upcdb"]

        for service in services {
            let newKey = try await fetchAPIKey(for: service)
            try SecureStorage().store(key: service, value: newKey)
        }
    }
}
```

## Security Best Practices

### 1. Input Validation

```swift
func sanitizeUserInput(_ input: String) -> String {
    // Remove potentially dangerous characters
    let allowed = CharacterSet.alphanumerics.union(.whitespaces)
    return input.components(separatedBy: allowed.inverted).joined()
}
```

### 2. SQL Injection Prevention

```swift
// Use Core Data (safe by default) or parameterized queries
let fetchRequest = DigitalTwinEntity.fetchRequest()
fetchRequest.predicate = NSPredicate(format: "title == %@", userInput) // Safe
// NOT: format: "title == '\(userInput)'" // Vulnerable!
```

### 3. Secure Random Generation

```swift
func generateSecureToken() -> String {
    var bytes = [UInt8](repeating: 0, count: 32)
    let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
    guard status == errSecSuccess else {
        fatalError("Failed to generate random bytes")
    }
    return Data(bytes).base64EncodedString()
}
```

## Compliance

### GDPR Requirements

- ✅ Right to access (data export)
- ✅ Right to erasure (data deletion)
- ✅ Right to portability (JSON export)
- ✅ Privacy by design (local-first)
- ✅ Consent management (opt-in cloud sync)
- ✅ Data minimization (only essential data)

### CCPA Requirements

- ✅ Notice of data collection
- ✅ Right to know (data export)
- ✅ Right to delete (data deletion)
- ✅ Right to opt-out (disable analytics)

### App Store Privacy Nutrition Label

```
Data Linked to User:
- Purchases (in-app subscriptions)
- User ID (Sign in with Apple)

Data Not Linked to User:
- None (no anonymous tracking)

Data Not Collected:
- Location
- Contacts
- Browsing history
```

## Incident Response

### Security Breach Protocol

1. **Detection**: Monitor for unusual API activity
2. **Containment**: Revoke compromised API keys immediately
3. **Investigation**: Determine scope of breach
4. **Notification**: Inform affected users within 72 hours
5. **Remediation**: Fix vulnerability, rotate all keys
6. **Documentation**: Record incident for compliance

### Monitoring

```swift
class SecurityMonitor {
    func detectAnomalies() {
        // Monitor for:
        // - Unusual API call patterns
        // - Failed authentication attempts
        // - Unexpected data access
        // - Large data exports
    }
}
```

## Testing Security

### Penetration Testing Checklist

- [ ] Test API key exposure in logs
- [ ] Attempt SQL injection via search
- [ ] Test file protection with locked device
- [ ] Verify HTTPS enforcement
- [ ] Test keychain access across app reinstalls
- [ ] Verify CloudKit permissions
- [ ] Test data export completeness
- [ ] Test data deletion thoroughness

## Summary

This security plan provides:
- **Encryption**: Data protected at rest and in transit
- **Privacy**: Local-first with optional cloud sync
- **Compliance**: GDPR and CCPA ready
- **User Control**: Export and delete data anytime
- **Secure APIs**: Keys in Keychain, never hardcoded
- **Incident Response**: Clear breach protocol

Security and privacy are not features, they're requirements. Every component should default to the most secure and private option.
