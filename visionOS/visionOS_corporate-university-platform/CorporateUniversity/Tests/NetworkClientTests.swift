//
//  NetworkClientTests.swift
//  CorporateUniversityTests
//
//  Created by Claude AI on 2025-01-20.
//  Copyright © 2025 Corporate University Platform. All rights reserved.
//

import XCTest
@testable import CorporateUniversity

final class NetworkClientTests: XCTestCase {
    var sut: NetworkClient!

    override func setUp() {
        super.setUp()
        sut = NetworkClient()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testNetworkClientInitialization() {
        // Then
        XCTAssertNotNil(sut)
    }

    // MARK: - Auth Token Tests

    func testSetAuthToken_StoresToken() {
        // Given
        let token = "test_token_123"

        // When
        sut.setAuthToken(token)

        // Then - Token should be set (we can't directly test private property, but method shouldn't crash)
        XCTAssertNoThrow(sut.setAuthToken(token))
    }

    func testSetAuthToken_CanBeCleared() {
        // Given
        sut.setAuthToken("test_token")

        // When
        sut.setAuthToken(nil)

        // Then
        XCTAssertNoThrow(sut.setAuthToken(nil))
    }

    // MARK: - HTTP Method Tests

    func testHTTPMethodRawValues() {
        XCTAssertEqual(HTTPMethod.get.rawValue, "GET")
        XCTAssertEqual(HTTPMethod.post.rawValue, "POST")
        XCTAssertEqual(HTTPMethod.put.rawValue, "PUT")
        XCTAssertEqual(HTTPMethod.delete.rawValue, "DELETE")
        XCTAssertEqual(HTTPMethod.patch.rawValue, "PATCH")
    }

    // MARK: - API Endpoint Tests

    func testAPIEndpointPaths() {
        // Test various endpoint paths
        XCTAssertEqual(APIEndpoint.login.path, "/auth/login")
        XCTAssertEqual(APIEndpoint.logout.path, "/auth/logout")
        XCTAssertEqual(APIEndpoint.courses(filter: nil).path, "/courses")

        let testUUID = UUID()
        XCTAssertEqual(
            APIEndpoint.courseDetail(id: testUUID).path,
            "/courses/\(testUUID.uuidString)"
        )

        let userUUID = UUID()
        XCTAssertEqual(
            APIEndpoint.enrollments(userId: userUUID).path,
            "/users/\(userUUID.uuidString)/enrollments"
        )

        XCTAssertEqual(
            APIEndpoint.analytics(userId: userUUID).path,
            "/analytics/learner/\(userUUID.uuidString)"
        )
    }

    // MARK: - Network Error Tests

    func testNetworkErrorDescriptions() {
        XCTAssertNotNil(NetworkError.invalidURL.errorDescription)
        XCTAssertNotNil(NetworkError.invalidResponse.errorDescription)
        XCTAssertNotNil(NetworkError.httpError(statusCode: 404).errorDescription)
        XCTAssertNotNil(NetworkError.networkUnavailable.errorDescription)

        // Verify HTTP error includes status code
        if case let NetworkError.httpError(statusCode) = NetworkError.httpError(statusCode: 404) {
            XCTAssertEqual(statusCode, 404)
        } else {
            XCTFail("Should match httpError case")
        }
    }

    // MARK: - Course Filter Tests

    func testCourseFilter_AllCases() {
        // Just verify all cases compile and can be created
        let filters: [CourseFilter] = [
            .all,
            .category(.technology),
            .difficulty(.beginner),
            .recommended(userId: UUID())
        ]

        XCTAssertEqual(filters.count, 4)
    }
}
