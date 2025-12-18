//
//  ProcedureServiceTests.swift
//  Surgical Training Universe Tests
//
//  Unit tests for ProcedureService
//

import XCTest
import SwiftData
@testable import SurgicalTrainingUniverse

final class ProcedureServiceTests: XCTestCase {

    var modelContext: ModelContext!
    var procedureService: ProcedureService!
    var testSurgeon: SurgeonProfile!
    var analyticsService: AnalyticsService!
    var aiCoach: SurgicalCoachAI!

    override func setUpWithError() throws {
        // Create in-memory model container
        let schema = Schema([
            SurgeonProfile.self,
            ProcedureSession.self,
            SurgicalMovement.self,
            AIInsight.self,
            Complication.self
        ])

        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        modelContext = ModelContext(container)

        // Create test surgeon
        testSurgeon = SurgeonProfile(
            name: "Dr. Test",
            email: "test@example.com",
            specialization: .generalSurgery,
            level: .resident2
        )
        modelContext.insert(testSurgeon)

        // Initialize services
        analyticsService = AnalyticsService()
        aiCoach = SurgicalCoachAI()
        procedureService = ProcedureService(
            modelContext: modelContext,
            analyticsService: analyticsService,
            aiCoach: aiCoach
        )
    }

    override func tearDownWithError() throws {
        procedureService = nil
        testSurgeon = nil
        modelContext = nil
    }

    // MARK: - Session Management Tests

    func testStartProcedure() async throws {
        let session = try await procedureService.startProcedure(
            type: .appendectomy,
            surgeon: testSurgeon
        )

        XCTAssertNotNil(session)
        XCTAssertEqual(session.procedureType, .appendectomy)
        XCTAssertEqual(session.surgeon.id, testSurgeon.id)
        XCTAssertEqual(session.status, .inProgress)
        XCTAssertEqual(procedureService.currentSession?.id, session.id)
    }

    func testCompleteProcedure() async throws {
        // Start procedure
        let session = try await procedureService.startProcedure(
            type: .appendectomy,
            surgeon: testSurgeon
        )

        // Add some movements
        let movement = SurgicalMovement(
            movementType: .incision,
            instrumentType: .scalpel,
            startPosition: .zero,
            endPosition: Position3D(x: 0.1, y: 0, z: 0),
            forceApplied: 0.5,
            affectedRegion: .abdomen
        )
        session.addMovement(movement)

        // Complete procedure
        let report = try await procedureService.completeProcedure(session)

        XCTAssertEqual(session.status, .completed)
        XCTAssertNotNil(session.endTime)
        XCTAssertGreaterThan(session.duration, 0)
        XCTAssertNil(procedureService.currentSession)
        XCTAssertNotNil(report)
    }

    func testAbortProcedure() async throws {
        let session = try await procedureService.startProcedure(
            type: .appendectomy,
            surgeon: testSurgeon
        )

        try await procedureService.abortProcedure(session, reason: "Test abortion")

        XCTAssertEqual(session.status, .aborted)
        XCTAssertNil(procedureService.currentSession)
    }

    func testPauseProcedure() async throws {
        let session = try await procedureService.startProcedure(
            type: .appendectomy,
            surgeon: testSurgeon
        )

        try await procedureService.pauseProcedure(session)

        XCTAssertEqual(session.status, .paused)
    }

    func testResumeProcedure() async throws {
        let session = try await procedureService.startProcedure(
            type: .appendectomy,
            surgeon: testSurgeon
        )

        try await procedureService.pauseProcedure(session)
        try await procedureService.resumeProcedure(session)

        XCTAssertEqual(session.status, .inProgress)
    }

    // MARK: - Movement Recording Tests

    func testRecordMovement() async throws {
        let session = try await procedureService.startProcedure(
            type: .appendectomy,
            surgeon: testSurgeon
        )

        await procedureService.recordMovement(
            type: .incision,
            instrumentType: .scalpel,
            startPosition: .zero,
            endPosition: Position3D(x: 0.1, y: 0, z: 0),
            forceApplied: 0.5,
            affectedRegion: .abdomen
        )

        XCTAssertEqual(session.movements.count, 1)
        XCTAssertEqual(session.movements.first?.movementType, .incision)
    }

    func testRecordComplication() throws {
        let session = ProcedureSession(procedureType: .appendectomy, surgeon: testSurgeon)
        procedureService.currentSession = session

        procedureService.recordComplication(
            type: .bleeding,
            severity: .medium,
            description: "Minor bleeding detected"
        )

        XCTAssertEqual(session.complications.count, 1)
        XCTAssertEqual(session.complications.first?.type, .bleeding)
        XCTAssertGreaterThan(session.insights.count, 0)
    }

    // MARK: - Query Tests

    func testGetSessionsForSurgeon() throws {
        // Create multiple sessions
        let session1 = ProcedureSession(procedureType: .appendectomy, surgeon: testSurgeon)
        let session2 = ProcedureSession(procedureType: .cholecystectomy, surgeon: testSurgeon)
        modelContext.insert(session1)
        modelContext.insert(session2)
        testSurgeon.sessions.append(contentsOf: [session1, session2])

        let sessions = procedureService.getSessions(for: testSurgeon)

        XCTAssertEqual(sessions.count, 2)
    }

    func testGetSessionsByType() throws {
        let session1 = ProcedureSession(procedureType: .appendectomy, surgeon: testSurgeon)
        let session2 = ProcedureSession(procedureType: .appendectomy, surgeon: testSurgeon)
        let session3 = ProcedureSession(procedureType: .cholecystectomy, surgeon: testSurgeon)
        modelContext.insert(session1)
        modelContext.insert(session2)
        modelContext.insert(session3)
        testSurgeon.sessions.append(contentsOf: [session1, session2, session3])

        let appendectomySessions = procedureService.getSessions(
            ofType: .appendectomy,
            for: testSurgeon
        )

        XCTAssertEqual(appendectomySessions.count, 2)
        XCTAssertTrue(appendectomySessions.allSatisfy { $0.procedureType == .appendectomy })
    }

    func testGetRecentSessions() throws {
        // Create 15 sessions
        for i in 0..<15 {
            let session = ProcedureSession(procedureType: .appendectomy, surgeon: testSurgeon)
            modelContext.insert(session)
            testSurgeon.sessions.append(session)
        }

        let recentSessions = procedureService.getRecentSessions(for: testSurgeon, limit: 10)

        XCTAssertEqual(recentSessions.count, 10)
    }

    // MARK: - Multiple Session Tests

    func testStartNewSessionEndsExisting() async throws {
        // Start first session
        let session1 = try await procedureService.startProcedure(
            type: .appendectomy,
            surgeon: testSurgeon
        )

        // Start second session (should abort first)
        let session2 = try await procedureService.startProcedure(
            type: .cholecystectomy,
            surgeon: testSurgeon
        )

        XCTAssertEqual(session1.status, .aborted)
        XCTAssertEqual(procedureService.currentSession?.id, session2.id)
    }

    // MARK: - Performance Tests

    func testRecordMovementPerformance() async throws {
        let session = try await procedureService.startProcedure(
            type: .appendectomy,
            surgeon: testSurgeon
        )

        measure {
            Task {
                await procedureService.recordMovement(
                    type: .incision,
                    instrumentType: .scalpel,
                    startPosition: .zero,
                    endPosition: Position3D(x: 0.1, y: 0, z: 0),
                    forceApplied: 0.5,
                    affectedRegion: .abdomen
                )
            }
        }
    }
}
