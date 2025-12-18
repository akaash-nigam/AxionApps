//
//  ARSessionManagerTests.swift
//  Reality Annotation Platform Tests
//
//  Unit tests for ARSessionManager
//

import XCTest
@testable import RealityAnnotation

@MainActor
final class ARSessionManagerTests: XCTestCase {
    var sut: ARSessionManager!

    override func setUp() {
        super.setUp()
        sut = ARSessionManager()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialization_DefaultState() {
        // Then
        XCTAssertEqual(sut.state, .stopped)
        XCTAssertEqual(sut.trackingQuality, .unknown)
        XCTAssertFalse(sut.isSessionRunning)
        XCTAssertNil(sut.errorMessage)
    }

    // MARK: - Session Lifecycle Tests

    func testStartSession_UpdatesState() async {
        // When
        await sut.startSession()

        // Then
        XCTAssertEqual(sut.state, .running)
        XCTAssertTrue(sut.isSessionRunning)
    }

    func testStopSession_UpdatesState() async {
        // Given
        await sut.startSession()
        XCTAssertTrue(sut.isSessionRunning)

        // When
        sut.stopSession()

        // Then
        XCTAssertEqual(sut.state, .stopped)
        XCTAssertFalse(sut.isSessionRunning)
    }

    func testPauseSession_UpdatesState() async {
        // Given
        await sut.startSession()

        // When
        sut.pauseSession()

        // Then
        XCTAssertEqual(sut.state, .paused)
        XCTAssertTrue(sut.isSessionRunning) // Still running, just paused
    }

    func testResumeSession_UpdatesState() async {
        // Given
        await sut.startSession()
        sut.pauseSession()
        XCTAssertEqual(sut.state, .paused)

        // When
        await sut.resumeSession()

        // Then
        XCTAssertEqual(sut.state, .running)
        XCTAssertTrue(sut.isSessionRunning)
    }

    // MARK: - Error Handling Tests

    func testHandleSessionError_UpdatesErrorState() async {
        // Given
        await sut.startSession()

        // When
        await sut.handleSessionError("Test error")

        // Then
        XCTAssertEqual(sut.state, .error)
        XCTAssertEqual(sut.errorMessage, "Test error")
    }

    func testHandleSessionError_ClearsOnStart() async {
        // Given
        await sut.startSession()
        await sut.handleSessionError("Test error")
        XCTAssertEqual(sut.state, .error)

        // When
        await sut.startSession()

        // Then
        XCTAssertEqual(sut.state, .running)
        XCTAssertNil(sut.errorMessage)
    }

    // MARK: - Tracking Quality Tests

    func testUpdateTrackingQuality_Normal() {
        // When
        sut.updateTrackingQuality(.normal)

        // Then
        XCTAssertEqual(sut.trackingQuality, .normal)
    }

    func testUpdateTrackingQuality_AllStates() {
        let qualities: [TrackingQuality] = [.unknown, .notAvailable, .limited, .normal]

        for quality in qualities {
            // When
            sut.updateTrackingQuality(quality)

            // Then
            XCTAssertEqual(sut.trackingQuality, quality)
        }
    }

    // MARK: - State Transitions Tests

    func testStateTransition_CannotStopBeforeStart() {
        // Given
        XCTAssertEqual(sut.state, .stopped)

        // When
        sut.stopSession()

        // Then
        XCTAssertEqual(sut.state, .stopped)
    }

    func testStateTransition_CannotPauseBeforeStart() {
        // Given
        XCTAssertEqual(sut.state, .stopped)

        // When
        sut.pauseSession()

        // Then
        XCTAssertEqual(sut.state, .stopped)
    }

    // MARK: - Status Info Tests

    func testPrintStatus_DoesNotCrash() async {
        // When starting
        await sut.startSession()
        sut.printStatus()

        // When paused
        sut.pauseSession()
        sut.printStatus()

        // When stopped
        sut.stopSession()
        sut.printStatus()

        // Then - no crash
        XCTAssertTrue(true)
    }
}
