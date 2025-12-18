//
//  ContactTests.swift
//  SpatialCRMTests
//
//  Unit tests for Contact model
//

import Testing
import Foundation
@testable import SpatialCRM

@Suite("Contact Model Tests")
struct ContactTests {

    @Test("Contact initialization")
    func testContactInitialization() {
        let contact = Contact(
            firstName: "John",
            lastName: "Smith",
            email: "john@example.com",
            phone: "+1-555-0100",
            title: "CEO",
            role: .champion,
            influenceScore: 95.0,
            isDecisionMaker: true,
            isPrimaryContact: true
        )

        #expect(contact.firstName == "John")
        #expect(contact.lastName == "Smith")
        #expect(contact.email == "john@example.com")
        #expect(contact.phone == "+1-555-0100")
        #expect(contact.title == "CEO")
        #expect(contact.role == .champion)
        #expect(contact.influenceScore == 95.0)
        #expect(contact.isDecisionMaker == true)
        #expect(contact.isPrimaryContact == true)
    }

    @Test("Full name computed property")
    func testFullName() {
        let contact = Contact(
            firstName: "Jane",
            lastName: "Doe",
            email: "jane@example.com",
            title: "CTO"
        )

        #expect(contact.fullName == "Jane Doe")
    }

    @Test("Initials computed property")
    func testInitials() {
        let contact = Contact(
            firstName: "Alice",
            lastName: "Johnson",
            email: "alice@example.com",
            title: "VP Sales"
        )

        #expect(contact.initials == "AJ")
    }

    @Test("Contact role enumeration")
    func testContactRoles() {
        #expect(ContactRole.champion.rawValue == "champion")
        #expect(ContactRole.influencer.rawValue == "influencer")
        #expect(ContactRole.decisionMaker.rawValue == "decisionMaker")
        #expect(ContactRole.user.rawValue == "user")
        #expect(ContactRole.blocker.rawValue == "blocker")
        #expect(ContactRole.unknown.rawValue == "unknown")
    }

    @Test("Orbital properties are randomized")
    func testOrbitalProperties() {
        let contact = Contact(
            firstName: "Test",
            lastName: "User",
            email: "test@example.com",
            title: "Manager"
        )

        // Check that orbital properties are set
        #expect(contact.orbitRadius > 0)
        #expect(contact.orbitSpeed > 0)
        #expect(contact.orbitAngle >= 0)
    }

    @Test("Contact sample data")
    func testSampleData() {
        let sample = Contact.sample

        #expect(sample.firstName == "John")
        #expect(sample.lastName == "Smith")
        #expect(sample.isDecisionMaker == true)
        #expect(sample.isPrimaryContact == true)
        #expect(sample.role == .champion)
    }

    @Test("Multiple sample contacts")
    func testSamplesData() {
        let samples = Contact.samples

        #expect(samples.count == 4)
        #expect(samples[0].role == .champion)
        #expect(samples[1].role == .influencer)
    }
}
