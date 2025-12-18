//
//  AccountTests.swift
//  SpatialCRMTests
//
//  Unit tests for Account model
//

import Testing
import Foundation
@testable import SpatialCRM

@Suite("Account Model Tests")
struct AccountTests {

    @Test("Account initialization with valid data")
    func testAccountInitialization() {
        let account = Account(
            name: "Test Corp",
            industry: "Technology",
            revenue: 1_000_000,
            employeeCount: 100,
            healthScore: 85.0,
            riskLevel: .low
        )

        #expect(account.name == "Test Corp")
        #expect(account.industry == "Technology")
        #expect(account.revenue == 1_000_000)
        #expect(account.employeeCount == 100)
        #expect(account.healthScore == 85.0)
        #expect(account.riskLevel == .low)
    }

    @Test("Account position property computed correctly")
    func testAccountPosition() {
        let account = Account(name: "Test Corp")
        account.positionX = 1.0
        account.positionY = 2.0
        account.positionZ = 3.0

        let position = account.position
        #expect(position.x == 1.0)
        #expect(position.y == 2.0)
        #expect(position.z == 3.0)
    }

    @Test("Account total opportunity value calculated correctly")
    func testTotalOpportunityValue() {
        let account = Account(name: "Test Corp")

        let opp1 = Opportunity(name: "Deal 1", amount: 100_000, status: .active)
        let opp2 = Opportunity(name: "Deal 2", amount: 200_000, status: .active)
        let opp3 = Opportunity(name: "Deal 3", amount: 50_000, status: .won)

        account.opportunities = [opp1, opp2, opp3]

        // Should only count active opportunities
        let total = account.totalOpportunityValue
        #expect(total == 300_000)
    }

    @Test("Account primary contact identified correctly")
    func testPrimaryContact() {
        let account = Account(name: "Test Corp")

        let contact1 = Contact(
            firstName: "John",
            lastName: "Doe",
            email: "john@test.com",
            title: "CEO",
            isPrimaryContact: false
        )

        let contact2 = Contact(
            firstName: "Jane",
            lastName: "Smith",
            email: "jane@test.com",
            title: "CTO",
            isPrimaryContact: true
        )

        account.contacts = [contact1, contact2]

        #expect(account.primaryContact?.firstName == "Jane")
        #expect(account.primaryContact?.isPrimaryContact == true)
    }

    @Test("Account sample data is valid")
    func testSampleData() {
        let sample = Account.sample

        #expect(sample.name == "Acme Corporation")
        #expect(sample.revenue > 0)
        #expect(sample.healthScore >= 0 && sample.healthScore <= 100)
    }

    @Test("Risk level enumeration")
    func testRiskLevels() {
        #expect(RiskLevel.low.rawValue == "low")
        #expect(RiskLevel.medium.rawValue == "medium")
        #expect(RiskLevel.high.rawValue == "high")
        #expect(RiskLevel.critical.rawValue == "critical")
    }
}
