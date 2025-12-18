# Security & Privacy Design

## Data Privacy

### User Data Collection
- **Speech recordings**: Processed for pronunciation, deleted after session
- **Conversation history**: Stored locally, optionally synced to iCloud
- **Learning progress**: Synced via CloudKit (encrypted)
- **Analytics**: Aggregated, anonymized (opt-in only)

### Privacy-First Principles
1. **On-device processing** where possible (speech recognition, object detection)
2. **Minimal data transmission** to cloud services
3. **User control** over data collection and storage
4. **Transparent privacy policy**
5. **GDPR/CCPA compliance**

## Data Security

### API Keys Storage

```swift
import Security

class SecureStorage {
    func store(apiKey: String, for service: String) throws {
        let data = apiKey.data(using: .utf8)!

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "api_key",
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]

        // Delete existing
        SecItemDelete(query as CFDictionary)

        // Add new
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unableToStore
        }
    }

    func retrieve(for service: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "api_key",
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let apiKey = String(data: data, encoding: .utf8) else {
            throw KeychainError.notFound
        }

        return apiKey
    }
}

enum KeychainError: Error {
    case unableToStore
    case notFound
    case unexpectedData
}
```

### User Data Encryption

```swift
import CryptoKit

class DataEncryption {
    private let key: SymmetricKey

    init() {
        // Generate or retrieve encryption key
        if let keyData = try? SecureStorage().retrieve(for: "encryption_key"),
           let data = Data(base64Encoded: keyData) {
            self.key = SymmetricKey(data: data)
        } else {
            self.key = SymmetricKey(size: .bits256)
            // Store key securely
            let keyString = key.withUnsafeBytes { Data($0).base64EncodedString() }
            try? SecureStorage().store(apiKey: keyString, for: "encryption_key")
        }
    }

    func encrypt(_ data: Data) throws -> Data {
        let sealedBox = try AES.GCM.seal(data, using: key)
        return sealedBox.combined!
    }

    func decrypt(_ data: Data) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(sealedBox, using: key)
    }
}
```

### Secure Network Communication

```swift
class SecureAPIClient {
    private let session: URLSession

    init() {
        let config = URLSessionConfiguration.default
        config.tlsMinimumSupportedProtocolVersion = .TLSv13
        config.httpShouldSetCookies = false

        self.session = URLSession(configuration: config)
    }

    func request<T: Decodable>(
        _ endpoint: URL,
        method: String = "GET",
        body: Data? = nil
    ) async throws -> T {
        var request = URLRequest(url: endpoint)
        request.httpMethod = method
        request.httpBody = body

        // Add security headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")

        // Add API key from Keychain
        let apiKey = try SecureStorage().retrieve(for: "OpenAI")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)

        // Validate response
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}
```

## Authentication & Authorization

### User Authentication

```swift
import AuthenticationServices

class AuthManager {
    func signInWithApple() async throws -> UserProfile {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.email, .fullName]

        // Perform authorization
        let controller = ASAuthorizationController(authorizationRequests: [request])
        // Handle result...

        return UserProfile(id: UUID(), username: "", email: "")
    }

    func validateSession() async -> Bool {
        // Check if user is authenticated
        guard let userID = UserDefaults.standard.string(forKey: "userID") else {
            return false
        }

        // Verify with backend
        let isValid = await verifySessionToken()
        return isValid
    }

    private func verifySessionToken() async -> Bool {
        // Verify JWT or session token
        return true
    }
}
```

### Parental Controls

```swift
class ParentalControls {
    func isContentAllowed(for age: Int, content: Content) -> Bool {
        switch content.rating {
        case .everyone:
            return true
        case .teen:
            return age >= 13
        case .mature:
            return age >= 18
        }
    }

    func enableRestrictions() {
        UserDefaults.standard.set(true, forKey: "parental_controls_enabled")
        // Disable certain features
        // Require password for settings changes
    }
}
```

## Privacy Compliance

### GDPR Compliance

```swift
class GDPRCompliance {
    // Right to Access
    func exportUserData() async throws -> Data {
        let userData = UserDataExport(
            profile: getUserProfile(),
            progress: getLearningProgress(),
            conversations: getConversations(),
            settings: getUserSettings()
        )

        return try JSONEncoder().encode(userData)
    }

    // Right to Erasure
    func deleteAllUserData() async throws {
        // Delete from local storage
        try PersistenceController.shared.deleteAllUserData()

        // Delete from CloudKit
        try await CloudSyncManager().deleteAllRecords()

        // Request deletion from third-party services
        try await requestAPIDataDeletion()

        // Clear caches
        StorageManager().clearCache()

        // Reset app state
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }

    // Right to Data Portability
    func generateDataPackage() async throws -> URL {
        let data = try await exportUserData()
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("user_data.json")
        try data.write(to: fileURL)
        return fileURL
    }

    private func requestAPIDataDeletion() async throws {
        // Notify external services to delete user data
        // OpenAI: Request user data deletion
        // ElevenLabs: Request voice data deletion
    }
}

struct UserDataExport: Codable {
    let profile: UserProfile
    let progress: [LanguageProgress]
    let conversations: [Conversation]
    let settings: UserPreferences
}
```

### CCPA Compliance

```swift
class CCPACompliance {
    func handleDataSaleOptOut() {
        UserDefaults.standard.set(true, forKey: "ccpa_opt_out")
        // Stop sharing data with third parties
        AnalyticsManager.shared.disable()
    }

    func disclosureOfDataSales() -> String {
        return """
        We do not sell your personal information. However, we share anonymized analytics
        with third-party services for app improvement purposes. You can opt out in Settings.
        """
    }
}
```

## Audio Recording Privacy

### Microphone Permission

```swift
import AVFoundation

class MicrophonePermissionManager {
    func requestPermission() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)

        switch status {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .audio)
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }

    func showPermissionDeniedAlert() {
        // Show alert directing user to Settings
    }
}
```

### Recording Indicator

```swift
class RecordingIndicator: ObservableObject {
    @Published var isRecording: Bool = false

    func startRecording() {
        isRecording = true
        // Show prominent visual indicator
    }

    func stopRecording() {
        isRecording = false
    }
}
```

## Secure Analytics

### Privacy-Preserving Analytics

```swift
class PrivateAnalytics {
    func trackEvent(_ event: String, properties: [String: Any] = [:]) {
        guard UserDefaults.standard.bool(forKey: "analytics_enabled") else {
            return // User opted out
        }

        // Anonymize user ID
        let anonymousID = hashUserID()

        // Remove PII from properties
        let sanitizedProperties = sanitize(properties)

        // Send to analytics service
        send(event: event, id: anonymousID, properties: sanitizedProperties)
    }

    private func hashUserID() -> String {
        guard let userID = UserDefaults.standard.string(forKey: "userID") else {
            return UUID().uuidString
        }

        // One-way hash
        return SHA256.hash(data: userID.data(using: .utf8)!)
            .compactMap { String(format: "%02x", $0) }
            .joined()
    }

    private func sanitize(_ properties: [String: Any]) -> [String: Any] {
        // Remove email, names, etc.
        var sanitized = properties
        let piiKeys = ["email", "name", "phone", "address"]

        for key in piiKeys {
            sanitized.removeValue(forKey: key)
        }

        return sanitized
    }
}
```

## Security Best Practices

### Input Validation

```swift
class InputValidator {
    func validateUserInput(_ text: String) -> Bool {
        // Prevent injection attacks
        let allowedCharacters = CharacterSet.alphanumerics
            .union(.whitespaces)
            .union(.punctuationCharacters)

        return text.unicodeScalars.allSatisfy { allowedCharacters.contains($0) }
    }

    func sanitizeForDatabase(_ text: String) -> String {
        // Escape special characters
        return text
            .replacingOccurrences(of: "'", with: "''")
            .replacingOccurrences(of: "\\", with: "\\\\")
    }
}
```

### Secure Logging

```swift
class SecureLogger {
    func log(_ message: String, level: LogLevel = .info) {
        // Remove sensitive data before logging
        let sanitized = redactSensitiveInfo(message)

        print("[\(level)] \(sanitized)")
    }

    private func redactSensitiveInfo(_ message: String) -> String {
        var redacted = message

        // Redact API keys
        let apiKeyPattern = #"[A-Za-z0-9]{32,}"#
        redacted = redacted.replacingOccurrences(of: apiKeyPattern, with: "[REDACTED]", options: .regularExpression)

        // Redact email addresses
        let emailPattern = #"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}"#
        redacted = redacted.replacingOccurrences(of: emailPattern, with: "[EMAIL]", options: .regularExpression)

        return redacted
    }
}

enum LogLevel: String {
    case debug, info, warning, error
}
```

## Privacy Policy Summary

**What we collect:**
- Learning progress and statistics
- Conversation transcripts (optional, for improvement)
- App usage analytics (anonymized, opt-in)

**What we don't collect:**
- Biometric data
- Location data
- Contact lists
- Photos or media

**How we protect your data:**
- End-to-end encryption for synced data
- On-device processing for sensitive operations
- Secure API communication (TLS 1.3)
- No data selling or third-party sharing

**Your rights:**
- Access your data
- Export your data
- Delete your data
- Opt out of analytics
