//
//  SurgeonProfileTests.swift
//  Surgical Training Universe Tests
//
//  Unit tests for SurgeonProfile model
//

import XCTest
import SwiftData
@testable import SurgicalTrainingUniverse

final class SurgeonProfileTests: XCTestCase {

    var modelContext: ModelContext!
    var testProfile: SurgeonProfile!

    override func setUpWithError() throws {
        // Create in-memory model container for testing
        let schema = Schema([
            SurgeonProfile.self,
            ProcedureSession.self,
            Certification.self,
            Achievement.self
        ])

        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        modelContext = ModelContext(container)

        // Create test profile
        testProfile = SurgeonProfile(
            name: "Dr. Test Surgeon",
            email: "test@example.com",
            specialization: .generalSurgery,
            level: .resident2,
            institution: "Test Medical Center"
        )
        modelContext.insert(testProfile)
    }

    override func tearDownWithError() throws {
        testProfile = nil
        modelContext = nil
    }

    // MARK: - Initialization Tests

    func testSurgeonProfileInitialization() throws {
        XCTAssertNotNil(testProfile.id)
        XCTAssertEqual(testProfile.name, "Dr. Test Surgeon")
        XCTAssertEqual(testProfile.email, "test@example.com")
        XCTAssertEqual(testProfile.specialization, .generalSurgery)
        XCTAssertEqual(testProfile.level, .resident2)
        XCTAssertEqual(testProfile.institution, "Test Medical Center")
        XCTAssertEqual(testProfile.totalProcedures, 0)
        XCTAssertEqual(testProfile.averageAccuracy, 0.0)
        XCTAssertEqual(testProfile.averageEfficiency, 0.0)
        XCTAssertEqual(testProfile.averageSafety, 0.0)
    }

    func testSurgeonProfileDefaultValues() throws {
        let defaultProfile = SurgeonProfile(name: "Test", email: "test@test.com")

        XCTAssertEqual(defaultProfile.specialization, .generalSurgery)
        XCTAssertEqual(defaultProfile.level, .resident1)
        XCTAssertEqual(defaultProfile.institution, "")
        XCTAssertTrue(defaultProfile.sessions.isEmpty)
        XCTAssertTrue(defaultProfile.certifications.isEmpty)
        XCTAssertTrue(defaultProfile.achievements.isEmpty)
    }

    // MARK: - Statistics Update Tests

    func testUpdateStatisticsFromSession() throws {
        // Create a mock session with known scores
        let session = ProcedureSession(
            procedureType: .appendectomy,
            surgeon: testProfile
        )
        session.accuracyScore = 90.0
        session.efficiencyScore = 85.0
        session.safetyScore = 95.0

        // Update statistics
        testProfile.updateStatistics(from: session)

        // Verify statistics were updated
        XCTAssertEqual(testProfile.totalProcedures, 1)
        XCTAssertEqual(testProfile.averageAccuracy, 90.0, accuracy: 0.01)
        XCTAssertEqual(testProfile.averageEfficiency, 85.0, accuracy: 0.01)
        XCTAssertEqual(testProfile.averageSafety, 95.0, accuracy: 0.01)
    }

    func testUpdateStatisticsMultipleSessions() throws {
        // First session
        let session1 = ProcedureSession(procedureType: .appendectomy, surgeon: testProfile)
        session1.accuracyScore = 80.0
        session1.efficiencyScore = 75.0
        session1.safetyScore = 85.0
        testProfile.updateStatistics(from: session1)

        // Second session
        let session2 = ProcedureSession(procedureType: .cholecystectomy, surgeon: testProfile)
        session2.accuracyScore = 90.0
        session2.efficiencyScore = 85.0
        session2.safetyScore = 95.0
        testProfile.updateStatistics(from: session2)

        // Verify rolling average
        XCTAssertEqual(testProfile.totalProcedures, 2)
        XCTAssertGreaterThan(testProfile.averageAccuracy, 80.0)
        XCTAssertLessThan(testProfile.averageAccuracy, 90.0)
    }

    func testOverallScoreCalculation() throws {
        testProfile.averageAccuracy = 90.0
        testProfile.averageEfficiency = 85.0
        testProfile.averageSafety = 95.0

        let expectedOverall = (90.0 + 85.0 + 95.0) / 3.0
        XCTAssertEqual(testProfile.overallScore, expectedOverall, accuracy: 0.01)
    }

    // MARK: - Relationship Tests

    func testSessionRelationship() throws {
        let session = ProcedureSession(procedureType: .appendectomy, surgeon: testProfile)
        modelContext.insert(session)

        XCTAssertTrue(testProfile.sessions.contains(where: { $0.id == session.id }))
    }

    func testCertificationRelationship() throws {
        let cert = Certification(
            name: "Basic Surgical Skills",
            procedureType: .appendectomy,
            score: 95.0
        )
        cert.surgeon = testProfile
        modelContext.insert(cert)
        testProfile.certifications.append(cert)

        XCTAssertEqual(testProfile.certifications.count, 1)
        XCTAssertEqual(testProfile.certifications.first?.name, "Basic Surgical Skills")
    }

    // MARK: - Validation Tests

    func testEmailValidation() throws {
        // Note: Add email validation to the model if needed
        XCTAssertTrue(testProfile.email.contains("@"))
    }

    func testNameNotEmpty() throws {
        XCTAssertFalse(testProfile.name.isEmpty)
    }

    // MARK: - Performance Tests

    func testStatisticsUpdatePerformance() throws {
        measure {
            let session = ProcedureSession(procedureType: .appendectomy, surgeon: testProfile)
            session.accuracyScore = 90.0
            session.efficiencyScore = 85.0
            session.safetyScore = 95.0

            for _ in 0..<100 {
                testProfile.updateStatistics(from: session)
            }
        }
    }
}

// MARK: - Training Level Tests

extension SurgeonProfileTests {

    func testTrainingLevelExperience() throws {
        XCTAssertEqual(TrainingLevel.medicalStudent.experienceLevel, 0)
        XCTAssertEqual(TrainingLevel.resident1.experienceLevel, 1)
        XCTAssertEqual(TrainingLevel.resident2.experienceLevel, 2)
        XCTAssertEqual(TrainingLevel.resident3.experienceLevel, 3)
        XCTAssertEqual(TrainingLevel.chiefResident.experienceLevel, 4)
        XCTAssertEqual(TrainingLevel.fellow.experienceLevel, 5)
        XCTAssertEqual(TrainingLevel.attending.experienceLevel, 6)
    }

    func testTrainingLevelProgression() throws {
        let levels = TrainingLevel.allCases

        for i in 0..<levels.count - 1 {
            XCTAssertLessThan(
                levels[i].experienceLevel,
                levels[i + 1].experienceLevel,
                "Training levels should progress in order"
            )
        }
    }
}

// MARK: - Surgical Specialty Tests

extension SurgeonProfileTests {

    func testSurgicalSpecialtyRawValues() throws {
        XCTAssertEqual(SurgicalSpecialty.generalSurgery.rawValue, "General Surgery")
        XCTAssertEqual(SurgicalSpecialty.cardiacSurgery.rawValue, "Cardiac Surgery")
        XCTAssertEqual(SurgicalSpecialty.neurosurgery.rawValue, "Neurosurgery")
    }

    func testSurgicalSpecialtyCoding() throws {
        let specialty = SurgicalSpecialty.cardiacSurgery

        let encoder = JSONEncoder()
        let data = try encoder.encode(specialty)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(SurgicalSpecialty.self, from: data)

        XCTAssertEqual(specialty, decoded)
    }
}
