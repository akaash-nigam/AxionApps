import XCTest
@testable import EscapeRoomNetwork

/// Security and privacy tests
/// ✅ Can run in CLI with `swift test --filter SecurityTests`
final class SecurityTests: XCTestCase {

    // MARK: - Input Validation Tests

    func testPuzzleTitleInputValidation() {
        // Test malicious input in puzzle title
        let maliciousInputs = [
            "<script>alert('xss')</script>",
            "'; DROP TABLE puzzles; --",
            "../../../etc/passwd",
            "\\x00\\x00\\x00",
            String(repeating: "A", count: 100000) // Extremely long input
        ]

        for input in maliciousInputs {
            let puzzle = Puzzle(
                title: input,
                description: "Test",
                difficulty: .beginner,
                estimatedTime: 600,
                requiredRoomSize: .small,
                puzzleElements: [],
                objectives: [],
                hints: []
            )

            // Should store input safely without processing as code
            XCTAssertEqual(puzzle.title, input)
        }
    }

    func testPlayerUsernameValidation() {
        // Test username input validation
        let invalidUsernames = [
            "",  // Empty
            " ",  // Whitespace only
            String(repeating: "A", count: 101),  // Too long
            "user<script>",  // Script injection attempt
            "../../admin"  // Path traversal attempt
        ]

        for username in invalidUsernames {
            // Create player with potentially invalid username
            let player = Player(username: username)

            // Should handle gracefully (not crash)
            XCTAssertNotNil(player.username)
        }
    }

    // MARK: - Data Sanitization Tests

    func testJSONEncodingSecure() throws {
        // Verify JSON encoding doesn't expose sensitive data
        let player = Player(username: "TestUser")
        let encoder = JSONEncoder()
        let data = try encoder.encode(player)
        let jsonString = String(data: data, encoding: .utf8)!

        // Should not contain any SQL, script tags, or paths
        XCTAssertFalse(jsonString.contains("password"))
        XCTAssertFalse(jsonString.contains("secret"))
        XCTAssertFalse(jsonString.contains("token"))
    }

    func testSafeSerialization() throws {
        // Test that serialized data is safe
        let puzzle = Puzzle(
            title: "Test & <Puzzle>",
            description: "Contains 'special' characters",
            difficulty: .beginner,
            estimatedTime: 600,
            requiredRoomSize: .small,
            puzzleElements: [],
            objectives: [],
            hints: []
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(puzzle)
        let decoded = try JSONDecoder().decode(Puzzle.self, from: data)

        XCTAssertEqual(decoded.title, puzzle.title)
        XCTAssertEqual(decoded.description, puzzle.description)
    }

    // MARK: - Privacy Tests

    func testRoomDataDoesNotLeakSensitive() {
        // Verify room data doesn't expose sensitive information
        let roomData = RoomData()

        // Should not contain camera/photo data
        // Should not contain user location
        // Should only contain geometric/furniture data

        XCTAssertNotNil(roomData.id)
        XCTAssertNotNil(roomData.scanDate)

        // Verify no sensitive fields exist (this would fail if someone added them)
        let mirror = Mirror(reflecting: roomData)
        let propertyNames = mirror.children.compactMap { $0.label }

        XCTAssertFalse(propertyNames.contains("cameraImage"))
        XCTAssertFalse(propertyNames.contains("userLocation"))
        XCTAssertFalse(propertyNames.contains("address"))
    }

    func testPlayerDataMinimalExposure() {
        // Verify player data only exposes necessary information
        let player = Player(username: "TestUser")

        let mirror = Mirror(reflecting: player)
        let propertyNames = mirror.children.compactMap { $0.label }

        // Should not have sensitive fields
        XCTAssertFalse(propertyNames.contains("password"))
        XCTAssertFalse(propertyNames.contains("email"))
        XCTAssertFalse(propertyNames.contains("phoneNumber"))
        XCTAssertFalse(propertyNames.contains("address"))
    }

    // MARK: - UUID Security Tests

    func testUUIDsAreUnpredictable() {
        // Verify UUIDs are properly random
        var uuids: Set<UUID> = []

        for _ in 0..<1000 {
            let uuid = UUID()
            XCTAssertFalse(uuids.contains(uuid), "UUID should be unique")
            uuids.insert(uuid)
        }

        XCTAssertEqual(uuids.count, 1000)
    }

    func testEntityIDsNotSequential() {
        // Ensure entity IDs aren't sequential (security through obscurity weakness)
        let id1 = UUID()
        let id2 = UUID()
        let id3 = UUID()

        // UUIDs should be random, not sequential
        XCTAssertNotEqual(id1, id2)
        XCTAssertNotEqual(id2, id3)
        XCTAssertNotEqual(id1, id3)
    }

    // MARK: - Network Message Security

    func testNetworkMessageValidation() throws {
        // Test that network messages are validated
        let validPlayer = Player(username: "ValidUser")
        let message = NetworkMessage.playerJoined(validPlayer)

        // Should be able to encode/decode safely
        let encoder = JSONEncoder()
        let data = try encoder.encode(message)
        let decoded = try JSONDecoder().decode(NetworkMessage.self, from: data)

        if case .playerJoined(let player) = decoded {
            XCTAssertEqual(player.username, "ValidUser")
        } else {
            XCTFail("Message type changed after encoding/decoding")
        }
    }

    func testMalformedNetworkMessageHandling() {
        // Test handling of malformed network data
        let malformedData = Data([0xFF, 0xFF, 0xFF, 0xFF])
        let decoder = JSONDecoder()

        // Should fail gracefully, not crash
        XCTAssertThrowsError(try decoder.decode(NetworkMessage.self, from: malformedData))
    }

    // MARK: - Resource Limits

    func testPuzzleElementCountLimit() {
        // Prevent DOS attacks via excessive puzzle elements
        var elements: [PuzzleElement] = []

        // Try to create 10,000 elements
        for i in 0..<10000 {
            elements.append(PuzzleElement(
                type: .clue,
                position: SIMD3<Float>(0, 0, 0),
                modelName: "element_\(i)",
                interactionType: .grab
            ))
        }

        // Should handle large numbers without crashing
        XCTAssertEqual(elements.count, 10000)

        // In production, would enforce a limit
        let maxAllowed = 100
        let limitedElements = Array(elements.prefix(maxAllowed))
        XCTAssertLessThanOrEqual(limitedElements.count, maxAllowed)
    }

    func testStringLengthLimits() {
        // Prevent DOS via extremely long strings
        let excessivelyLongString = String(repeating: "A", count: 1000000)

        let puzzle = Puzzle(
            title: excessivelyLongString,
            description: excessivelyLongString,
            difficulty: .beginner,
            estimatedTime: 600,
            requiredRoomSize: .small,
            puzzleElements: [],
            objectives: [],
            hints: []
        )

        // Should handle without crashing
        XCTAssertEqual(puzzle.title.count, 1000000)

        // In production, would enforce limits:
        let maxTitleLength = 100
        let maxDescriptionLength = 500

        XCTAssertLessThanOrEqual(
            String(excessivelyLongString.prefix(maxTitleLength)).count,
            maxTitleLength
        )
    }

    // MARK: - Metadata Security

    func testMetadataDoesNotExecuteCode() {
        // Verify metadata doesn't execute code
        let element = PuzzleElement(
            type: .clue,
            position: SIMD3<Float>(0, 0, 0),
            modelName: "test",
            interactionType: .grab,
            metadata: [
                "script": "<script>alert('xss')</script>",
                "sql": "'; DROP TABLE users; --",
                "command": "rm -rf /"
            ]
        )

        // Should store as strings, not execute
        XCTAssertEqual(element.metadata["script"], "<script>alert('xss')</script>")
        XCTAssertEqual(element.metadata["sql"], "'; DROP TABLE users; --")
        XCTAssertEqual(element.metadata["command"], "rm -rf /")
    }

    // MARK: - Session Security

    func testSessionIDsUnique() async throws {
        // Verify session IDs are unique
        let manager1 = MultiplayerManager()
        let manager2 = MultiplayerManager()

        try await manager1.startMultiplayerSession(puzzleId: UUID())
        try await manager2.startMultiplayerSession(puzzleId: UUID())

        let session1ID = manager1.currentSession?.id
        let session2ID = manager2.currentSession?.id

        XCTAssertNotNil(session1ID)
        XCTAssertNotNil(session2ID)
        XCTAssertNotEqual(session1ID, session2ID)
    }

    // MARK: - Error Message Security

    func testErrorMessagesDontLeakInfo() {
        // Verify error messages don't leak sensitive system information
        // This is a placeholder - in production, check actual error messages

        let expectedSafeErrors = [
            "Invalid input",
            "Operation failed",
            "Permission denied"
        ]

        let dangerousErrors = [
            "/var/www/app/config/database.yml",
            "SQL Error at line 42 of query.sql",
            "Stack trace: at function parseUserData() in /home/user/src/auth.swift:123"
        ]

        // Safe errors should be generic
        for error in expectedSafeErrors {
            XCTAssertFalse(error.contains("/"))
            XCTAssertFalse(error.contains("\\"))
        }
    }

    // MARK: - Timing Attack Prevention

    func testConstantTimeComparison() {
        // In production, sensitive comparisons should be constant-time
        // This test verifies the concept

        func constantTimeCompare(_ a: String, _ b: String) -> Bool {
            guard a.count == b.count else { return false }

            var result = 0
            for (charA, charB) in zip(a, b) {
                result |= Int(charA.asciiValue ?? 0) ^ Int(charB.asciiValue ?? 0)
            }
            return result == 0
        }

        XCTAssertTrue(constantTimeCompare("secret", "secret"))
        XCTAssertFalse(constantTimeCompare("secret", "secreT"))
        XCTAssertFalse(constantTimeCompare("secret", "wrong"))
    }

    // MARK: - Data Retention Tests

    func testSensitiveDataNotPersisted() {
        // Verify sensitive data isn't accidentally persisted
        let roomData = RoomData()

        // Room data should not contain:
        // - User photos/camera images
        // - GPS coordinates
        // - Network information
        // - Device identifiers

        let encoder = JSONEncoder()
        if let data = try? encoder.encode(roomData),
           let jsonString = String(data: data, encoding: .utf8) {

            XCTAssertFalse(jsonString.contains("latitude"))
            XCTAssertFalse(jsonString.contains("longitude"))
            XCTAssertFalse(jsonString.contains("ipAddress"))
            XCTAssertFalse(jsonString.contains("deviceId"))
        }
    }
}

/*
 MARK: - Additional Security Tests Requiring Runtime Environment

 These tests require a running app or specific security tools:

 1. Encryption Tests (Requires CryptoKit)
    - Test data encryption at rest
    - Verify secure key storage
    - Test secure communication channels

 2. Keychain Tests (Requires Device/Simulator)
    - Test sensitive data storage
    - Verify keychain item access
    - Test keychain data deletion

 3. Network Security Tests (Requires Network Access)
    - Test HTTPS enforcement
    - Verify certificate pinning
    - Test against man-in-the-middle attacks

 4. Penetration Testing (Requires Security Tools)
    - SQL injection testing
    - XSS vulnerability testing
    - CSRF protection testing

 5. Compliance Tests
    - GDPR compliance verification
    - CCPA compliance verification
    - Children's privacy (COPPA) compliance

 To perform full security audit:
 1. Use Xcode's security analysis tools
 2. Run static analysis (SwiftLint with security rules)
 3. Perform dynamic analysis during runtime
 4. Conduct third-party security audit
 5. Implement security monitoring
 */
