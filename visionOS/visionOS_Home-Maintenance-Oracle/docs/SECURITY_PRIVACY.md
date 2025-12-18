# Security & Privacy Design
## Home Maintenance Oracle

**Version**: 1.0
**Last Updated**: 2025-11-24
**Status**: Draft

---

## Table of Contents

1. [Privacy Philosophy](#privacy-philosophy)
2. [Data Classification](#data-classification)
3. [Data Collection & Usage](#data-collection--usage)
4. [Storage Security](#storage-security)
5. [Network Security](#network-security)
6. [Authentication & Authorization](#authentication--authorization)
7. [Privacy Policy](#privacy-policy)
8. [Compliance](#compliance)
9. [User Controls](#user-controls)
10. [Incident Response](#incident-response)

---

## Privacy Philosophy

### Core Principles

1. **Data Minimization**: Collect only what's necessary
2. **User Control**: Users own their data
3. **Transparency**: Clear about what we collect and why
4. **On-Device First**: Process locally when possible
5. **No Selling**: Never sell user data to third parties

### Privacy by Design

- Default to most private settings
- Require explicit consent for sensitive data
- Provide easy opt-out mechanisms
- Regular privacy audits

---

## Data Classification

### Sensitivity Levels

| Level | Data Type | Examples | Storage | Encryption |
|-------|-----------|----------|---------|------------|
| Public | App content | Manuals, tutorials | CDN | None |
| Internal | Analytics | Feature usage | Secure DB | At rest |
| Confidential | Home inventory | Appliances, locations | Core Data + CloudKit | At rest & transit |
| Secret | Credentials | API keys, tokens | Keychain | Always |
| Sensitive | Photos | Service photos, home images | Encrypted storage | Always |

### Personal Identifiable Information (PII)

**PII We Collect**:
- Home address (optional, user-entered)
- Purchase dates and prices (optional)
- Photos of appliances and home

**PII We Do NOT Collect**:
- Name (uses iCloud identity)
- Email (uses iCloud)
- Payment information (handled by merchants)
- Social security numbers
- Financial data

---

## Data Collection & Usage

### What We Collect

#### Required for Core Functionality

```swift
struct CoreData {
    // Appliance inventory
    let appliances: [Appliance]  // Brand, model, serial (optional)

    // Maintenance records
    let maintenanceTasks: [MaintenanceTask]
    let serviceHistory: [ServiceHistory]

    // App usage
    let recognitionResults: [RecognitionResult]  // For model improvement
}
```

#### Optional (User Consent Required)

```swift
struct OptionalData {
    // Enhanced features
    let homeAddress: String?  // For local contractor recommendations
    let photos: [UIImage]?    // Service documentation

    // Analytics
    let featureUsage: AnalyticsData?  // Which features used, how often
    let crashReports: CrashData?      // For debugging
}
```

#### Never Collected

- Microphone data (except voice commands, processed on-device)
- Continuous camera feed (only snapshots for recognition)
- Location tracking (no background location)
- Contacts, messages, or other app data
- Biometric data

### Data Usage

| Data | Purpose | Sharing |
|------|---------|---------|
| Appliance inventory | Show manuals, maintenance | CloudKit sync only |
| Recognition results | Improve ML models | Anonymized aggregates |
| Feature usage | Product improvements | Anonymized analytics |
| Crash reports | Bug fixes | Developer only |
| Photos | Service documentation | Never shared |

### User Consent Flow

```swift
class ConsentManager {
    enum ConsentType {
        case analytics
        case crashReporting
        case photoStorage
        case locationAccess  // Future: for local contractors
    }

    func requestConsent(_ type: ConsentType) async -> Bool {
        // Show explanation dialog
        let explanation = getExplanation(for: type)

        let result = await showConsentDialog(
            title: type.title,
            message: explanation,
            options: ["Allow", "Don't Allow"]
        )

        // Store preference
        UserDefaults.standard.set(result, forKey: type.key)

        return result
    }

    func getExplanation(for type: ConsentType) -> String {
        switch type {
        case .analytics:
            return "Help us improve by sharing how you use features. No personal information is collected."
        case .crashReporting:
            return "Send crash reports to help us fix bugs. Reports are anonymous and only contain technical data."
        case .photoStorage:
            return "Photos are stored securely on your device and in your private iCloud. Never shared."
        case .locationAccess:
            return "Used only to find local contractors. Location is never tracked or stored."
        }
    }
}
```

---

## Storage Security

### Keychain for Secrets

```swift
class SecureStorage {
    func saveAPIKey(_ key: String, for service: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecValueData as String: key.data(using: .utf8)!,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    func getAPIKey(for service: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let key = String(data: data, encoding: .utf8) else {
            return nil
        }

        return key
    }
}
```

### Core Data Encryption

```swift
let description = NSPersistentStoreDescription()
description.setOption(
    FileProtectionType.completeUnlessOpen as NSObject,
    forKey: NSPersistentStoreFileProtectionKey
)

// Enables encryption at rest
container.persistentStoreDescriptions = [description]
```

### Photo Encryption

```swift
class EncryptedPhotoStorage {
    private let encryptionKey: SymmetricKey

    init() {
        // Generate or retrieve encryption key from Keychain
        if let keyData = SecureStorage().getEncryptionKey() {
            self.encryptionKey = SymmetricKey(data: keyData)
        } else {
            self.encryptionKey = SymmetricKey(size: .bits256)
            SecureStorage().saveEncryptionKey(encryptionKey.dataRepresentation)
        }
    }

    func savePhoto(_ image: UIImage, id: UUID) throws -> URL {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw StorageError.invalidImage
        }

        // Encrypt
        let sealedBox = try AES.GCM.seal(imageData, using: encryptionKey)
        let encryptedData = sealedBox.combined!

        // Save to file system
        let fileURL = photoDirectory.appendingPathComponent("\(id.uuidString).encrypted")
        try encryptedData.write(to: fileURL, options: .completeFileProtection)

        return fileURL
    }

    func loadPhoto(from url: URL) throws -> UIImage {
        let encryptedData = try Data(contentsOf: url)
        let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
        let decryptedData = try AES.GCM.open(sealedBox, using: encryptionKey)

        guard let image = UIImage(data: decryptedData) else {
            throw StorageError.corruptedImage
        }

        return image
    }
}
```

---

## Network Security

### TLS/SSL

**Requirements**:
- TLS 1.3 minimum
- Certificate pinning for critical APIs
- No cleartext HTTP

```swift
class SecureAPIClient {
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.tlsMinimumSupportedProtocolVersion = .TLSv13
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
}

extension SecureAPIClient: URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        // Certificate pinning
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        let policy = SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString)
        SecTrustSetPolicies(serverTrust, policy)

        // Verify against pinned certificate
        if isPinnedCertificateValid(serverTrust) {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }

    private func isPinnedCertificateValid(_ trust: SecTrust) -> Bool {
        guard let certificate = SecTrustGetCertificateAtIndex(trust, 0),
              let pinnedCert = loadPinnedCertificate() else {
            return false
        }

        let serverCertData = SecCertificateCopyData(certificate) as Data
        let pinnedCertData = SecCertificateCopyData(pinnedCert) as Data

        return serverCertData == pinnedCertData
    }
}
```

### Request Signing

```swift
struct SignedRequest {
    let timestamp: Date
    let nonce: String
    let signature: String

    static func sign(_ request: URLRequest, with secret: String) -> SignedRequest {
        let timestamp = Date()
        let nonce = UUID().uuidString

        // Create signature: HMAC-SHA256(timestamp + nonce + body)
        let message = "\(timestamp.timeIntervalSince1970)\(nonce)\(request.httpBody?.base64EncodedString() ?? "")"
        let signature = HMAC<SHA256>.authenticationCode(
            for: message.data(using: .utf8)!,
            using: SymmetricKey(data: secret.data(using: .utf8)!)
        )

        return SignedRequest(
            timestamp: timestamp,
            nonce: nonce,
            signature: signature.hexString
        )
    }
}
```

---

## Authentication & Authorization

### iCloud Authentication

```swift
class AuthenticationManager {
    func checkiCloudStatus() async -> Bool {
        let container = CKContainer.default()
        do {
            let status = try await container.accountStatus()
            return status == .available
        } catch {
            return false
        }
    }

    func getUserIdentifier() async -> String? {
        let container = CKContainer.default()
        do {
            let recordID = try await container.userRecordID()
            return recordID.recordName
        } catch {
            return nil
        }
    }
}
```

### API Token Management

```swift
class APITokenManager {
    private var tokens: [String: APIToken] = [:]

    struct APIToken {
        let value: String
        let expiresAt: Date
        let refreshToken: String?
    }

    func getValidToken(for api: String) async throws -> String {
        if let token = tokens[api], token.expiresAt > Date() {
            return token.value
        }

        // Token expired, refresh
        if let refreshToken = tokens[api]?.refreshToken {
            let newToken = try await refreshToken(api, using: refreshToken)
            tokens[api] = newToken
            return newToken.value
        }

        // No valid token, re-authenticate
        let newToken = try await authenticate(api)
        tokens[api] = newToken
        return newToken.value
    }
}
```

---

## Privacy Policy

### Key Points

**Data We Collect**:
- Appliance information (brand, model, serial number)
- Maintenance schedules and history
- Optional photos for service records
- Anonymous usage analytics (with consent)

**How We Use Data**:
- Provide app functionality
- Improve recognition accuracy
- Fix bugs and crashes
- Develop new features

**Data Sharing**:
- iCloud sync (your private iCloud only)
- Never sold to third parties
- Anonymized analytics to Apple (standard App Analytics)

**Your Rights**:
- Access your data anytime
- Export all data
- Delete account and all data
- Opt out of analytics

**Data Retention**:
- Active users: Retained indefinitely in iCloud
- Deleted data: Purged within 30 days
- Inactive accounts: No server-side storage

### In-App Privacy Notice

```swift
struct PrivacyNoticeView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Your Privacy Matters")
                    .font(.largeTitle)

                PrivacySection(
                    icon: "lock.shield",
                    title: "Secure Storage",
                    description: "All data encrypted and stored in your private iCloud"
                )

                PrivacySection(
                    icon: "eye.slash",
                    title: "No Tracking",
                    description: "We don't track your location or sell your data"
                )

                PrivacySection(
                    icon: "hand.raised",
                    title: "You're in Control",
                    description: "Delete your data anytime from Settings"
                )

                Link("Read Full Privacy Policy", destination: URL(string: "https://hmo.com/privacy")!)
            }
            .padding()
        }
    }
}
```

---

## Compliance

### Regulations

#### GDPR (Europe)

**Requirements**:
- ✅ Right to access
- ✅ Right to deletion
- ✅ Right to data portability
- ✅ Consent for processing
- ✅ Data breach notification (72 hours)

**Implementation**:
```swift
class GDPRCompliance {
    func exportUserData(userId: String) async throws -> URL {
        // Export all user data to JSON
        let userData = try await fetchAllUserData(userId)
        let jsonData = try JSONEncoder().encode(userData)

        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("my_data.json")
        try jsonData.write(to: fileURL)

        return fileURL
    }

    func deleteAllUserData(userId: String) async throws {
        // Delete from Core Data
        try await coreDataManager.deleteAllData(userId)

        // Delete from CloudKit
        try await cloudKitManager.deleteAllRecords(userId)

        // Delete photos
        try photoManager.deleteAllPhotos(userId)

        // Log deletion for compliance
        try await logDataDeletion(userId, timestamp: Date())
    }
}
```

#### CCPA (California)

**Requirements**:
- ✅ Disclose data collection
- ✅ Right to opt-out of sale (N/A - we don't sell)
- ✅ Right to deletion
- ✅ Non-discrimination

#### COPPA (Children's Privacy)

**Restriction**: App is 13+ only (no children's data collected)

```swift
// App Store age rating: 4+ (general audience)
// But no special features for children
```

---

## User Controls

### Privacy Settings

```swift
struct PrivacySettingsView: View {
    @AppStorage("analytics_enabled") var analyticsEnabled = false
    @AppStorage("crash_reporting_enabled") var crashReportingEnabled = true
    @AppStorage("photo_backup_enabled") var photoBackupEnabled = true

    var body: some View {
        Form {
            Section("Data Collection") {
                Toggle("Usage Analytics", isOn: $analyticsEnabled)
                Toggle("Crash Reports", isOn: $crashReportingEnabled)
            }

            Section("Data Storage") {
                Toggle("Backup Photos to iCloud", isOn: $photoBackupEnabled)

                Button("Export All My Data") {
                    exportData()
                }

                Button("Delete All My Data", role: .destructive) {
                    showDeleteConfirmation = true
                }
            }

            Section("Information") {
                Link("Privacy Policy", destination: URL(string: "https://hmo.com/privacy")!)
                Link("Terms of Service", destination: URL(string: "https://hmo.com/terms")!)
            }
        }
    }
}
```

### Data Export

```swift
func exportData() async {
    let userData = UserDataExport(
        appliances: fetchAppliances(),
        maintenanceTasks: fetchMaintenanceTasks(),
        serviceHistory: fetchServiceHistory(),
        exportDate: Date()
    )

    let jsonData = try! JSONEncoder().encode(userData)
    let fileURL = FileManager.default.temporaryDirectory
        .appendingPathComponent("HomeMaintenanceOracle_Data.json")
    try! jsonData.write(to: fileURL)

    // Share sheet
    let activityVC = UIActivityViewController(
        activityItems: [fileURL],
        applicationActivities: nil
    )
    present(activityVC)
}
```

---

## Incident Response

### Data Breach Protocol

**Detection**:
- Automated monitoring for unauthorized access
- Regular security audits
- User reports

**Response Plan** (within 72 hours):
1. **Assess**: Determine scope and impact
2. **Contain**: Stop the breach
3. **Notify**: Inform affected users
4. **Report**: Notify authorities (if GDPR applies)
5. **Remediate**: Fix vulnerability
6. **Review**: Post-mortem and improvements

**User Notification Template**:
```
Subject: Important Security Notice

We detected unauthorized access to our systems on [DATE].

What happened: [Brief description]
What data was affected: [Specific data types]
What we're doing: [Actions taken]
What you should do: [User actions, if any]

We take security seriously and apologize for this incident.

[Contact information]
```

### Security Contact

```
Security issues: security@hmo.com
Response time: 24 hours
PGP key: [public key]
```

---

**Document Status**: Ready for Legal Review
**Next Steps**: Legal review, privacy audit, penetration testing
