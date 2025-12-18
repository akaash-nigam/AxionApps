//
//  DocumentTests.swift
//  Legal Discovery Universe Tests
//
//  Created by Claude Code
//  Copyright © 2024 Legal Discovery Universe. All rights reserved.
//

import Testing
import Foundation
@testable import LegalDiscoveryUniverse

@Suite("Document Model Tests")
struct DocumentTests {

    @Test("Document creation with basic properties")
    func testDocumentCreation() {
        let document = Document(
            fileName: "test.pdf",
            fileType: .pdf,
            fileSize: 1024,
            extractedText: "Test content"
        )

        #expect(document.fileName == "test.pdf")
        #expect(document.fileType == .pdf)
        #expect(document.fileSize == 1024)
        #expect(document.extractedText == "Test content")
        #expect(document.relevanceScore == 0.0)
        #expect(document.privilegeStatus == .notPrivileged)
        #expect(document.isReviewed == false)
    }

    @Test("Document relevance scoring")
    func testRelevanceScoring() {
        let document = Document(
            fileName: "relevant.pdf",
            fileType: .pdf
        )

        document.relevanceScore = 0.95
        document.isRelevant = true

        #expect(document.relevanceScore == 0.95)
        #expect(document.isRelevant == true)
    }

    @Test("Document privilege status")
    func testPrivilegeStatus() {
        let document = Document(
            fileName: "privileged.pdf",
            fileType: .pdf
        )

        document.privilegeStatus = .attorneyClient
        document.isPrivileged = true

        #expect(document.privilegeStatus == .attorneyClient)
        #expect(document.isPrivileged == true)
    }

    @Test("Document with metadata")
    func testDocumentMetadata() {
        let document = Document(
            fileName: "email.msg",
            fileType: .email
        )

        var metadata = DocumentMetadata()
        metadata.from = "john@example.com"
        metadata.recipient = ["jane@example.com"]
        metadata.subject = "Test Email"

        document.metadata = metadata

        #expect(document.metadata?.from == "john@example.com")
        #expect(document.metadata?.recipient.first == "jane@example.com")
        #expect(document.metadata?.subject == "Test Email")
    }

    @Test("Document AI analysis")
    func testAIAnalysis() {
        let document = Document(
            fileName: "analyzed.pdf",
            fileType: .pdf,
            extractedText: "Legal document with contract terms"
        )

        var analysis = AIAnalysis()
        analysis.relevanceScore = 0.85
        analysis.keyPhrases = ["contract", "terms", "agreement"]
        analysis.sentiment = 0.2

        document.aiAnalysis = analysis

        #expect(document.aiAnalysis?.relevanceScore == 0.85)
        #expect(document.aiAnalysis?.keyPhrases.count == 3)
        #expect(document.aiAnalysis?.sentiment == 0.2)
    }

    @Test("Document status color mapping")
    func testStatusColor() {
        let keyEvidence = Document(fileName: "key.pdf", fileType: .pdf)
        keyEvidence.isKeyEvidence = true
        // Would test color in actual UI test

        let privileged = Document(fileName: "priv.pdf", fileType: .pdf)
        privileged.isPrivileged = true

        let relevant = Document(fileName: "rel.pdf", fileType: .pdf)
        relevant.isRelevant = true

        #expect(keyEvidence.isKeyEvidence == true)
        #expect(privileged.isPrivileged == true)
        #expect(relevant.isRelevant == true)
    }
}

@Suite("Entity Model Tests")
struct EntityTests {

    @Test("Entity creation")
    func testEntityCreation() {
        let person = Entity(name: "John Doe", type: .person)

        #expect(person.name == "John Doe")
        #expect(person.type == .person)
        #expect(person.importance == 0.5) // Default
        #expect(person.sentiment == 0.0)
    }

    @Test("Entity with details")
    func testEntityDetails() {
        let person = Entity(name: "Jane Smith", type: .person)
        person.email = "jane@lawfirm.com"
        person.organization = "Smith & Associates"
        person.title = "Attorney"

        #expect(person.email == "jane@lawfirm.com")
        #expect(person.organization == "Smith & Associates")
        #expect(person.title == "Attorney")
    }

    @Test("Entity connection")
    func testEntityConnection() {
        let person1Id = UUID()
        let person2Id = UUID()

        let connection = EntityConnection(
            sourceEntityId: person1Id,
            targetEntityId: person2Id,
            connectionType: .email,
            strength: 0.8
        )

        #expect(connection.sourceEntityId == person1Id)
        #expect(connection.targetEntityId == person2Id)
        #expect(connection.connectionType == .email)
        #expect(connection.strength == 0.8)
    }
}

@Suite("LegalCase Model Tests")
struct LegalCaseTests {

    @Test("Legal case creation")
    func testCaseCreation() {
        let legalCase = LegalCase(
            caseNumber: "2024-CV-12345",
            title: "Test v. Example",
            description: "Test case description",
            status: .active,
            securityLevel: .confidential
        )

        #expect(legalCase.caseNumber == "2024-CV-12345")
        #expect(legalCase.title == "Test v. Example")
        #expect(legalCase.status == .active)
        #expect(legalCase.securityLevel == .confidential)
        #expect(legalCase.documentCount == 0)
    }

    @Test("Case with metadata")
    func testCaseMetadata() {
        let legalCase = LegalCase(
            caseNumber: "2024-CV-12345",
            title: "Test Case",
            description: "Description"
        )

        var metadata = CaseMetadata()
        metadata.client = "Acme Corp"
        metadata.opposingParty = "TechStart Inc"
        metadata.courtName = "Superior Court"
        metadata.practiceArea = "Commercial Litigation"

        legalCase.metadata = metadata

        #expect(legalCase.metadata?.client == "Acme Corp")
        #expect(legalCase.metadata?.opposingParty == "TechStart Inc")
        #expect(legalCase.metadata?.practiceArea == "Commercial Litigation")
    }

    @Test("Case statistics update")
    func testCaseStatistics() {
        let legalCase = LegalCase(
            caseNumber: "2024-CV-12345",
            title: "Test Case",
            description: "Description"
        )

        legalCase.documentCount = 100
        legalCase.relevantDocumentCount = 45
        legalCase.privilegedDocumentCount = 5
        legalCase.reviewProgress = 0.75

        #expect(legalCase.documentCount == 100)
        #expect(legalCase.relevantDocumentCount == 45)
        #expect(legalCase.privilegedDocumentCount == 5)
        #expect(legalCase.reviewProgress == 0.75)
    }
}
