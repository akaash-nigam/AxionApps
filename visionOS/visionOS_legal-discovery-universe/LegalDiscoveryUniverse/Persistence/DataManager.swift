//
//  DataManager.swift
//  Legal Discovery Universe
//
//  Created by Claude Code
//  Copyright © 2024 Legal Discovery Universe. All rights reserved.
//

import Foundation
import SwiftData

/// Singleton manager for SwiftData persistence
@MainActor
class DataManager {
    static let shared = DataManager()

    let modelContainer: ModelContainer
    let modelContext: ModelContext

    private init() {
        let schema = Schema([
            LegalCase.self,
            Document.self,
            Entity.self,
            EntityConnection.self,
            Timeline.self,
            TimelineEvent.self,
            Tag.self,
            Annotation.self,
            Collaborator.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true,
            cloudKitDatabase: .none // Local only for security
        )

        do {
            self.modelContainer = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
            self.modelContext = ModelContext(modelContainer)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    // MARK: - Save Operations

    func save() throws {
        if modelContext.hasChanges {
            try modelContext.save()
        }
    }

    func saveAsync() async throws {
        try save()
    }

    // MARK: - Sample Data (for development/testing)

    func insertSampleData() throws {
        // Create sample case
        let sampleCase = LegalCase(
            caseNumber: "2024-CV-12345",
            title: "Acme Corp v. TechStart Inc.",
            description: "Contract dispute regarding software licensing agreement",
            status: .active,
            securityLevel: .confidential
        )

        sampleCase.metadata = CaseMetadata(
            client: "Acme Corporation",
            opposingParty: "TechStart Inc.",
            courtName: "Superior Court of California",
            jurisdiction: "California",
            practiceArea: "Commercial Litigation",
            leadAttorney: "Jane Smith"
        )

        modelContext.insert(sampleCase)

        // Create sample documents
        let doc1 = Document(
            fileName: "Contract_2024.pdf",
            fileType: .pdf,
            fileSize: 1024000,
            extractedText: "This Software License Agreement is entered into as of January 1, 2024..."
        )
        doc1.relevanceScore = 0.98
        doc1.isRelevant = true
        doc1.isKeyEvidence = true
        doc1.documentDate = Date()

        let doc2 = Document(
            fileName: "Email_Thread_March.msg",
            fileType: .email,
            fileSize: 25600,
            extractedText: "From: John Doe\nTo: Jane Smith\nSubject: Concerns about contract terms..."
        )
        doc2.metadata = DocumentMetadata(
            from: "john.doe@techstart.com",
            recipient: ["jane.smith@acmecorp.com"],
            subject: "Concerns about contract terms"
        )
        doc2.relevanceScore = 0.87
        doc2.isRelevant = true

        let doc3 = Document(
            fileName: "Attorney_Notes.docx",
            fileType: .word,
            fileSize: 102400,
            extractedText: "Confidential attorney work product regarding litigation strategy..."
        )
        doc3.privilegeStatus = .workProduct
        doc3.isPrivileged = true
        doc3.relevanceScore = 0.95

        sampleCase.documents = [doc1, doc2, doc3]
        sampleCase.documentCount = 3
        sampleCase.relevantDocumentCount = 2
        sampleCase.privilegedDocumentCount = 1

        // Create sample entities
        let person1 = Entity(name: "John Doe", type: .person)
        person1.email = "john.doe@techstart.com"
        person1.organization = "TechStart Inc."
        person1.title = "CEO"

        let person2 = Entity(name: "Jane Smith", type: .person)
        person2.email = "jane.smith@acmecorp.com"
        person2.organization = "Acme Corporation"
        person2.title = "General Counsel"

        let org1 = Entity(name: "TechStart Inc.", type: .organization)
        let org2 = Entity(name: "Acme Corporation", type: .organization)

        sampleCase.entities = [person1, person2, org1, org2]

        // Create sample tags
        let relevantTag = Tag(name: "Highly Relevant", color: "#FFD700", category: .priority)
        let contractTag = Tag(name: "Contract", color: "#2196F3", category: .topic)
        let privilegeTag = Tag(name: "Privileged", color: "#F44336", category: .status)

        sampleCase.tags = [relevantTag, contractTag, privilegeTag]

        // Create sample timeline
        let timeline = Timeline(name: "Contract Dispute Timeline")
        let event1 = TimelineEvent(
            title: "Contract Signed",
            description: "Software license agreement executed",
            eventDate: Calendar.current.date(byAdding: .month, value: -12, to: Date())!,
            importance: .critical
        )
        let event2 = TimelineEvent(
            title: "First Complaint",
            description: "TechStart raised concerns about terms",
            eventDate: Calendar.current.date(byAdding: .month, value: -6, to: Date())!,
            importance: .high
        )
        let event3 = TimelineEvent(
            title: "Lawsuit Filed",
            description: "Complaint filed in Superior Court",
            eventDate: Calendar.current.date(byAdding: .month, value: -1, to: Date())!,
            importance: .critical
        )

        timeline.events = [event1, event2, event3]
        sampleCase.timelines = [timeline]

        // Save all
        try save()
    }
}
