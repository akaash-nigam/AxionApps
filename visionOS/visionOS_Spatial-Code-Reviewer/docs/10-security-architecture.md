# Security Architecture Document

## Document Information
- **Version**: 1.0
- **Last Updated**: 2025-11-24
- **Status**: Draft
- **Owner**: Engineering Team

## 1. Overview

This document defines the security architecture, threat model, authentication mechanisms, data protection strategies, and compliance requirements for Spatial Code Reviewer.

## 2. Security Principles

### 2.1 Core Principles

1. **Defense in Depth**: Multiple layers of security controls
2. **Least Privilege**: Minimal permissions required for operations
3. **Zero Trust**: Verify every access request
4. **Privacy by Design**: User privacy built into architecture
5. **Security by Default**: Secure configurations out of the box

### 2.2 Compliance Requirements

| Standard | Applicable | Status |
|----------|-----------|--------|
| GDPR | Yes (EU users) | Required |
| CCPA | Yes (CA users) | Required |
| SOC 2 Type II | Yes (Enterprise) | Target |
| ISO 27001 | Optional (Enterprise) | Future |
| HIPAA | No | N/A |

## 3. Threat Model

### 3.1 Assets

| Asset | Classification | Protection Level |
|-------|---------------|------------------|
| OAuth Tokens | Secret | Critical |
| Repository Code | Confidential | High |
| User Data (emails, names) | PII | High |
| Session Data | Private | Medium |
| Usage Telemetry | Anonymous | Low |

### 3.2 Threat Actors

1. **External Attackers**: Unauthorized access to repositories
2. **Malicious Insiders**: Abuse of legitimate access
3. **Compromised Dependencies**: Supply chain attacks
4. **Social Engineering**: Phishing for credentials

### 3.3 Attack Vectors

| Vector | Likelihood | Impact | Mitigation |
|--------|-----------|--------|------------|
| Stolen OAuth tokens | Medium | High | Keychain storage, token rotation |
| Man-in-the-middle | Low | High | TLS 1.3, certificate pinning |
| Code injection | Low | Critical | Input validation, sandboxing |
| Memory disclosure | Low | Medium | Memory encryption, secure coding |
| Dependency compromise | Medium | High | Dependency scanning, SBOMs |
| Social engineering | Medium | High | User education, MFA support |

## 4. Authentication & Authorization

### 4.1 OAuth 2.0 Implementation

```swift
class SecureAuthService {
    private let keychain: KeychainService
    private let encryption: EncryptionService

    // PKCE for OAuth
    func generatePKCEChallenge() -> (verifier: String, challenge: String) {
        // Generate cryptographically secure random verifier
        var buffer = [UInt8](repeating: 0, count: 32)
        let result = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)

        guard result == errSecSuccess else {
            fatalError("Failed to generate random bytes")
        }

        let verifier = Data(buffer)
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")

        // SHA256 hash for challenge
        let challenge = SHA256.hash(data: Data(verifier.utf8))
            .compactMap { String(format: "%02x", $0) }
            .joined()

        return (verifier, challenge)
    }

    // Secure token storage
    func storeToken(_ token: Token, for service: String) throws {
        // Encrypt token before storing
        let encrypted = try encryption.encrypt(token)

        // Store in Keychain with strong access control
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "oauth_token",
            kSecValueData as String: encrypted,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            kSecAttrSynchronizable as String: false // Don't sync to iCloud
        ]

        // Delete existing first
        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.storeFailed(status)
        }
    }

    // Token retrieval with decryption
    func retrieveToken(for service: String) throws -> Token {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "oauth_token",
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data else {
            throw KeychainError.retrieveFailed(status)
        }

        // Decrypt token
        return try encryption.decrypt(data)
    }

    // Secure token deletion
    func deleteToken(for service: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "oauth_token"
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }
}

enum KeychainError: Error {
    case storeFailed(OSStatus)
    case retrieveFailed(OSStatus)
    case deleteFailed(OSStatus)
}
```

### 4.2 Token Rotation

```swift
class TokenRotationService {
    private let authService: SecureAuthService
    private let refreshInterval: TimeInterval = 3600 // 1 hour

    func startAutomaticRotation() {
        Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { [weak self] _ in
            Task {
                await self?.rotateTokensIfNeeded()
            }
        }
    }

    private func rotateTokensIfNeeded() async {
        for provider in AuthProvider.allCases {
            do {
                let token = try authService.retrieveToken(for: provider.rawValue)

                // Check if token expires soon (within 5 minutes)
                if token.expiresAt.timeIntervalSinceNow < 300 {
                    let newToken = try await refreshToken(for: provider)
                    try authService.storeToken(newToken, for: provider.rawValue)

                    print("✓ Rotated token for \(provider.rawValue)")
                }
            } catch {
                print("Failed to rotate token for \(provider.rawValue): \(error)")
            }
        }
    }

    private func refreshToken(for provider: AuthProvider) async throws -> Token {
        // Implementation from OAuthManager
        return Token(
            accessToken: "",
            refreshToken: nil,
            expiresAt: Date(),
            tokenType: "Bearer",
            scope: nil
        )
    }
}
```

## 5. Data Protection

### 5.1 Encryption at Rest

```swift
class EncryptionService {
    private let key: SymmetricKey

    init() {
        // Generate or retrieve encryption key from Secure Enclave
        self.key = try! retrieveOrGenerateKey()
    }

    func encrypt<T: Codable>(_ value: T) throws -> Data {
        let data = try JSONEncoder().encode(value)

        let sealedBox = try AES.GCM.seal(
            data,
            using: key,
            authenticating: Data()
        )

        return sealedBox.combined!
    }

    func decrypt<T: Codable>(_ data: Data) throws -> T {
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        let decrypted = try AES.GCM.open(sealedBox, using: key)

        return try JSONDecoder().decode(T.self, from: decrypted)
    }

    private func retrieveOrGenerateKey() throws -> SymmetricKey {
        // Try to retrieve from Keychain
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.spatialcodereviewer.encryption",
            kSecAttrAccount as String: "master_key",
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess, let data = result as? Data {
            return SymmetricKey(data: data)
        }

        // Generate new key
        let key = SymmetricKey(size: .bits256)
        let keyData = key.withUnsafeBytes { Data($0) }

        // Store in Keychain
        let storeQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.spatialcodereviewer.encryption",
            kSecAttrAccount as String: "master_key",
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        SecItemAdd(storeQuery as CFDictionary, nil)

        return key
    }
}
```

### 5.2 Encryption in Transit

```swift
class SecureNetworkService {
    private let session: URLSession

    init() {
        let configuration = URLSessionConfiguration.default

        // TLS 1.3 only
        configuration.tlsMinimumSupportedProtocolVersion = .TLSv13

        // Certificate pinning
        let delegate = CertificatePinningDelegate()
        self.session = URLSession(
            configuration: configuration,
            delegate: delegate,
            delegateQueue: nil
        )
    }

    func makeRequest(url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(httpResponse.statusCode)
        }

        return data
    }
}

class CertificatePinningDelegate: NSObject, URLSessionDelegate {
    private let pinnedCertificates: Set<Data>

    override init() {
        // Load pinned certificates from bundle
        var certs: Set<Data> = []

        if let githubCert = Bundle.main.url(forResource: "github", withExtension: "cer") {
            certs.insert(try! Data(contentsOf: githubCert))
        }

        self.pinnedCertificates = certs

        super.init()
    }

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Validate certificate
        let policies = [SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString)]
        SecTrustSetPolicies(serverTrust, policies as CFArray)

        var result: SecTrustResultType = .invalid
        SecTrustEvaluate(serverTrust, &result)

        let isValid = result == .unspecified || result == .proceed

        if isValid {
            // Check certificate pinning
            if isPinned(serverTrust: serverTrust) {
                let credential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
            } else {
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }

    private func isPinned(serverTrust: SecTrust) -> Bool {
        let certificateCount = SecTrustGetCertificateCount(serverTrust)

        for i in 0..<certificateCount {
            guard let certificate = SecTrustGetCertificateAtIndex(serverTrust, i) else {
                continue
            }

            let data = SecCertificateCopyData(certificate) as Data

            if pinnedCertificates.contains(data) {
                return true
            }
        }

        return false
    }
}
```

## 6. Secure Coding Practices

### 6.1 Input Validation

```swift
class InputValidator {
    static func validateRepositoryURL(_ urlString: String) throws -> URL {
        // Remove dangerous characters
        let sanitized = urlString.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let url = URL(string: sanitized) else {
            throw ValidationError.invalidURL
        }

        // Only allow HTTPS (or HTTP for localhost development)
        guard url.scheme == "https" || (url.scheme == "http" && url.host == "localhost") else {
            throw ValidationError.insecureScheme
        }

        // Validate domain whitelist for production
        let allowedDomains = [
            "github.com",
            "gitlab.com",
            "bitbucket.org",
            "dev.azure.com"
        ]

        if let host = url.host, !allowedDomains.contains(where: { host.hasSuffix($0) }) {
            throw ValidationError.untrustedDomain
        }

        return url
    }

    static func sanitizeFilePath(_ path: String) throws -> String {
        // Prevent directory traversal
        let normalized = (path as NSString).standardizingPath

        // Check for directory traversal patterns
        if normalized.contains("..") || normalized.hasPrefix("/") {
            throw ValidationError.pathTraversal
        }

        // Check for null bytes
        if normalized.contains("\0") {
            throw ValidationError.nullByteInjection
        }

        return normalized
    }

    static func sanitizeUserInput(_ input: String) -> String {
        // Remove control characters
        let sanitized = input.unicodeScalars.filter { scalar in
            !CharacterSet.controlCharacters.contains(scalar)
        }

        return String(String.UnicodeScalarView(sanitized))
    }
}

enum ValidationError: LocalizedError {
    case invalidURL
    case insecureScheme
    case untrustedDomain
    case pathTraversal
    case nullByteInjection

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The provided URL is invalid"
        case .insecureScheme:
            return "Only HTTPS URLs are allowed"
        case .untrustedDomain:
            return "The domain is not in the trusted list"
        case .pathTraversal:
            return "Path traversal detected"
        case .nullByteInjection:
            return "Null byte injection detected"
        }
    }
}
```

### 6.2 SQL Injection Prevention

```swift
class SecureDatabaseService {
    private let db: OpaquePointer?

    func executeQuery(_ query: String, parameters: [Any]) throws -> [[String: Any]] {
        var statement: OpaquePointer?

        // Always use prepared statements
        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
            throw DatabaseError.prepareFailed
        }

        defer {
            sqlite3_finalize(statement)
        }

        // Bind parameters
        for (index, parameter) in parameters.enumerated() {
            let bindIndex = Int32(index + 1)

            switch parameter {
            case let value as String:
                sqlite3_bind_text(statement, bindIndex, value, -1, SQLITE_TRANSIENT)
            case let value as Int:
                sqlite3_bind_int(statement, bindIndex, Int32(value))
            case let value as Double:
                sqlite3_bind_double(statement, bindIndex, value)
            case is NSNull:
                sqlite3_bind_null(statement, bindIndex)
            default:
                throw DatabaseError.unsupportedType
            }
        }

        // Execute and fetch results
        var results: [[String: Any]] = []

        while sqlite3_step(statement) == SQLITE_ROW {
            var row: [String: Any] = [:]

            let columnCount = sqlite3_column_count(statement)

            for i in 0..<columnCount {
                let columnName = String(cString: sqlite3_column_name(statement, i))

                switch sqlite3_column_type(statement, i) {
                case SQLITE_INTEGER:
                    row[columnName] = Int(sqlite3_column_int(statement, i))
                case SQLITE_FLOAT:
                    row[columnName] = sqlite3_column_double(statement, i)
                case SQLITE_TEXT:
                    row[columnName] = String(cString: sqlite3_column_text(statement, i))
                case SQLITE_NULL:
                    row[columnName] = NSNull()
                default:
                    break
                }
            }

            results.append(row)
        }

        return results
    }
}
```

## 7. Audit Logging

### 7.1 Security Event Logging

```swift
class SecurityAuditLogger {
    enum SecurityEvent {
        case authenticationAttempt(provider: String, success: Bool)
        case authenticationFailed(provider: String, reason: String)
        case tokenRefresh(provider: String)
        case unauthorizedAccess(resource: String)
        case dataAccess(resource: String, user: String)
        case dataModification(resource: String, user: String)
        case securityViolation(type: String, details: String)
    }

    func log(_ event: SecurityEvent) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let logEntry = formatLogEntry(event, timestamp: timestamp)

        // Write to secure log file
        writeToSecureLog(logEntry)

        // Send to SIEM if enterprise
        if isEnterpriseMode {
            sendToSIEM(logEntry)
        }

        // Alert on critical events
        if isCritical(event) {
            alertSecurityTeam(event)
        }
    }

    private func formatLogEntry(_ event: SecurityEvent, timestamp: String) -> String {
        switch event {
        case .authenticationAttempt(let provider, let success):
            return "[\(timestamp)] AUTH_ATTEMPT provider=\(provider) success=\(success)"

        case .authenticationFailed(let provider, let reason):
            return "[\(timestamp)] AUTH_FAILED provider=\(provider) reason=\(reason)"

        case .tokenRefresh(let provider):
            return "[\(timestamp)] TOKEN_REFRESH provider=\(provider)"

        case .unauthorizedAccess(let resource):
            return "[\(timestamp)] UNAUTHORIZED_ACCESS resource=\(resource)"

        case .dataAccess(let resource, let user):
            return "[\(timestamp)] DATA_ACCESS resource=\(resource) user=\(user)"

        case .dataModification(let resource, let user):
            return "[\(timestamp)] DATA_MODIFICATION resource=\(resource) user=\(user)"

        case .securityViolation(let type, let details):
            return "[\(timestamp)] SECURITY_VIOLATION type=\(type) details=\(details)"
        }
    }

    private func writeToSecureLog(_ entry: String) {
        // Write to encrypted log file
    }

    private func sendToSIEM(_ entry: String) {
        // Send to Security Information and Event Management system
    }

    private func isCritical(_ event: SecurityEvent) -> Bool {
        switch event {
        case .authenticationFailed, .unauthorizedAccess, .securityViolation:
            return true
        default:
            return false
        }
    }

    private func alertSecurityTeam(_ event: SecurityEvent) {
        // Send alert via webhook, email, etc.
    }
}
```

## 8. Privacy Protection

### 8.1 Data Minimization

```swift
class PrivacyManager {
    func collectMinimalData(from user: User) -> MinimalUserData {
        // Only collect what's necessary
        return MinimalUserData(
            id: user.id,
            // Don't store email, name, etc. unless required
        )
    }

    func anonymizeTelemetry(_ event: TelemetryEvent) -> AnonymousTelemetry {
        return AnonymousTelemetry(
            eventType: event.type,
            timestamp: event.timestamp,
            // Remove all PII
            metadata: event.metadata.filter { key, _ in
                !["email", "name", "ip_address"].contains(key)
            }
        )
    }
}
```

### 8.2 Data Retention

```swift
class DataRetentionPolicy {
    func enforceRetention() async {
        // Delete old session data (90 days)
        try? await deleteOldSessions(olderThan: 90)

        // Delete old logs (30 days)
        try? await deleteOldLogs(olderThan: 30)

        // Clear cache data (7 days)
        try? await clearOldCache(olderThan: 7)
    }

    private func deleteOldSessions(olderThan days: Int) async throws {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())!

        // Delete from Core Data
        let request = Session.fetchRequest()
        request.predicate = NSPredicate(format: "endedAt < %@", cutoffDate as NSDate)

        let context = PersistenceController.shared.container.viewContext
        let sessions = try context.fetch(request)

        for session in sessions {
            context.delete(session)
        }

        try context.save()
    }
}
```

## 9. Vulnerability Management

### 9.1 Dependency Scanning

```swift
// Use Swift Package Manager's vulnerability scanning
// In Package.swift:
/*
dependencies: [
    .package(url: "https://github.com/example/package.git", from: "1.0.0")
],
plugins: [
    .plugin(name: "DependencyCheck")
]
*/
```

### 9.2 Security Updates

```swift
class SecurityUpdateChecker {
    func checkForSecurityUpdates() async throws -> [SecurityUpdate] {
        // Check for security updates from update server
        let url = URL(string: "https://updates.spatialcodereviewer.com/security")!
        let (data, _) = try await URLSession.shared.data(from: url)

        let updates = try JSONDecoder().decode([SecurityUpdate].self, from: data)

        return updates.filter { $0.severity == .critical || $0.severity == .high }
    }

    func applySecurityUpdate(_ update: SecurityUpdate) async throws {
        // Download and apply security patch
    }
}

struct SecurityUpdate: Codable {
    let version: String
    let severity: Severity
    let description: String
    let cveID: String?

    enum Severity: String, Codable {
        case critical
        case high
        case medium
        case low
    }
}
```

## 10. Security Checklist

### 10.1 Pre-Release Security Review
- [ ] All OAuth flows tested and secured
- [ ] Certificate pinning implemented
- [ ] Input validation on all user inputs
- [ ] SQL injection prevention verified
- [ ] XSS protection implemented
- [ ] CSRF tokens used where applicable
- [ ] Rate limiting on API calls
- [ ] Audit logging functional
- [ ] Encryption at rest verified
- [ ] Encryption in transit verified
- [ ] Dependency vulnerabilities checked
- [ ] Security test suite passes
- [ ] Penetration testing completed
- [ ] Code review for security issues
- [ ] Privacy policy updated

## 11. Incident Response

### 11.1 Security Incident Plan

1. **Detection**: Automated monitoring alerts
2. **Containment**: Isolate affected systems
3. **Investigation**: Analyze logs, determine scope
4. **Eradication**: Remove threat, patch vulnerability
5. **Recovery**: Restore systems, verify security
6. **Post-Incident**: Document, improve defenses

## 12. References

- [System Architecture Document](./01-system-architecture.md)
- [API Integration Specifications](./07-api-integrations.md)
- OWASP Mobile Security Testing Guide
- Apple Security Framework Documentation

## 13. Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-11-24 | Engineering Team | Initial draft |
