//
//  CRMServiceTests.swift
//  Spatial CRM Tests
//
//  Tests for CRMService CRUD operations and business logic
//

import Testing
import SwiftData
@testable import SpatialCRM

@Suite("CRMService Tests")
struct CRMServiceTests {
    
    var service: CRMService
    var modelContext: ModelContext
    
    init() throws {
        // Create in-memory model container for testing
        let schema = Schema([
            Account.self,
            Contact.self,
            Opportunity.self,
            Activity.self,
            Territory.self
        ])
        
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: configuration)
        self.modelContext = ModelContext(container)
        self.service = CRMService()
    }
    
    // MARK: - Account Tests
    
    @Test("Create and fetch account")
    func testCreateAndFetchAccount() async throws {
        // Given
        let account = Account(
            name: "Test Corp",
            industry: "Technology",
            revenue: 1_000_000,
            employeeCount: 100
        )
        
        // When
        try await service.createAccount(account)
        let fetchedAccounts = try await service.fetchAccounts()
        
        // Then
        #expect(fetchedAccounts.count == 1)
        #expect(fetchedAccounts.first?.name == "Test Corp")
        #expect(fetchedAccounts.first?.industry == "Technology")
    }
    
    @Test("Update account information")
    func testUpdateAccount() async throws {
        // Given
        let account = Account(name: "Original Name", revenue: 500_000)
        try await service.createAccount(account)
        
        // When
        account.name = "Updated Name"
        account.revenue = 750_000
        try await service.updateAccount(account)
        
        let updated = try await service.fetchAccounts()
        
        // Then
        #expect(updated.first?.name == "Updated Name")
        #expect(updated.first?.revenue == 750_000)
    }
    
    @Test("Delete account")
    func testDeleteAccount() async throws {
        // Given
        let account = Account(name: "To Delete")
        try await service.createAccount(account)
        #expect(try await service.fetchAccounts().count == 1)
        
        // When
        try await service.deleteAccount(account)
        
        // Then
        #expect(try await service.fetchAccounts().count == 0)
    }
    
    @Test("Search accounts by name")
    func testSearchAccounts() async throws {
        // Given
        try await service.createAccount(Account(name: "Acme Corp"))
        try await service.createAccount(Account(name: "Beta Industries"))
        try await service.createAccount(Account(name: "Acme Solutions"))
        
        // When
        let results = service.searchAccounts(query: "Acme")
        
        // Then
        #expect(results.count == 2)
        #expect(results.allSatisfy { $0.name.contains("Acme") })
    }
    
    // MARK: - Contact Tests
    
    @Test("Create and fetch contacts")
    func testCreateAndFetchContacts() async throws {
        // Given
        let account = Account(name: "Test Corp")
        try await service.createAccount(account)
        
        let contact = Contact(
            firstName: "John",
            lastName: "Doe",
            email: "john@test.com"
        )
        contact.account = account
        
        // When
        try await service.createContact(contact)
        let fetched = try await service.fetchContacts()
        
        // Then
        #expect(fetched.count == 1)
        #expect(fetched.first?.firstName == "John")
        #expect(fetched.first?.lastName == "Doe")
        #expect(fetched.first?.email == "john@test.com")
    }
    
    @Test("Fetch contacts for specific account")
    func testFetchContactsForAccount() async throws {
        // Given
        let account1 = Account(name: "Account 1")
        let account2 = Account(name: "Account 2")
        try await service.createAccount(account1)
        try await service.createAccount(account2)
        
        let contact1 = Contact(firstName: "John", lastName: "Doe", email: "john@test.com")
        let contact2 = Contact(firstName: "Jane", lastName: "Smith", email: "jane@test.com")
        contact1.account = account1
        contact2.account = account2
        
        try await service.createContact(contact1)
        try await service.createContact(contact2)
        
        // When
        let account1Contacts = try await service.fetchContacts(for: account1)
        
        // Then
        #expect(account1Contacts.count == 1)
        #expect(account1Contacts.first?.firstName == "John")
    }
    
    @Test("Update contact information")
    func testUpdateContact() async throws {
        // Given
        let contact = Contact(firstName: "John", lastName: "Doe", email: "john@old.com")
        try await service.createContact(contact)
        
        // When
        contact.email = "john@new.com"
        contact.title = "VP Sales"
        try await service.updateContact(contact)
        
        let updated = try await service.fetchContacts()
        
        // Then
        #expect(updated.first?.email == "john@new.com")
        #expect(updated.first?.title == "VP Sales")
    }
    
    // MARK: - Opportunity Tests
    
    @Test("Create and fetch opportunities")
    func testCreateAndFetchOpportunities() async throws {
        // Given
        let opportunity = Opportunity(
            name: "Enterprise Deal",
            amount: 500_000,
            stage: .qualification,
            expectedCloseDate: Date().addingTimeInterval(30 * 86400)
        )
        
        // When
        try await service.createOpportunity(opportunity)
        let fetched = try await service.fetchOpportunities()
        
        // Then
        #expect(fetched.count == 1)
        #expect(fetched.first?.name == "Enterprise Deal")
        #expect(fetched.first?.amount == 500_000)
        #expect(fetched.first?.stage == .qualification)
    }
    
    @Test("Fetch opportunities by stage")
    func testFetchOpportunitiesByStage() async throws {
        // Given
        try await service.createOpportunity(Opportunity(
            name: "Deal 1",
            amount: 100_000,
            stage: .qualification,
            expectedCloseDate: Date()
        ))
        try await service.createOpportunity(Opportunity(
            name: "Deal 2",
            amount: 200_000,
            stage: .negotiation,
            expectedCloseDate: Date()
        ))
        try await service.createOpportunity(Opportunity(
            name: "Deal 3",
            amount: 300_000,
            stage: .qualification,
            expectedCloseDate: Date()
        ))
        
        // When
        let qualificationDeals = try await service.fetchOpportunities(stage: .qualification)
        
        // Then
        #expect(qualificationDeals.count == 2)
        #expect(qualificationDeals.allSatisfy { $0.stage == .qualification })
    }
    
    @Test("Fetch open opportunities")
    func testFetchOpenOpportunities() async throws {
        // Given
        let openDeal = Opportunity(name: "Open", amount: 100_000, stage: .negotiation, expectedCloseDate: Date())
        let wonDeal = Opportunity(name: "Won", amount: 200_000, stage: .closedWon, expectedCloseDate: Date())
        let lostDeal = Opportunity(name: "Lost", amount: 300_000, stage: .closedLost, expectedCloseDate: Date())
        
        wonDeal.status = .won
        lostDeal.status = .lost
        
        try await service.createOpportunity(openDeal)
        try await service.createOpportunity(wonDeal)
        try await service.createOpportunity(lostDeal)
        
        // When
        let openOpportunities = try await service.fetchOpenOpportunities()
        
        // Then
        #expect(openOpportunities.count == 1)
        #expect(openOpportunities.first?.name == "Open")
        #expect(openOpportunities.first?.status == .open)
    }
    
    @Test("Update opportunity stage")
    func testUpdateOpportunityStage() async throws {
        // Given
        let opportunity = Opportunity(
            name: "Test Deal",
            amount: 100_000,
            stage: .qualification,
            expectedCloseDate: Date()
        )
        try await service.createOpportunity(opportunity)
        
        // When
        opportunity.progress(to: .negotiation)
        try await service.updateOpportunity(opportunity)
        
        let updated = try await service.fetchOpportunities()
        
        // Then
        #expect(updated.first?.stage == .negotiation)
        #expect(updated.first?.probability == DealStage.negotiation.typicalProbability)
    }
    
    // MARK: - Activity Tests
    
    @Test("Create and fetch activities")
    func testCreateAndFetchActivities() async throws {
        // Given
        let activity = Activity(
            type: .call,
            subject: "Discovery Call",
            description: "Initial needs assessment",
            status: .planned,
            priority: .high
        )
        
        // When
        try await service.createActivity(activity)
        let fetched = try await service.fetchActivities()
        
        // Then
        #expect(fetched.count == 1)
        #expect(fetched.first?.type == .call)
        #expect(fetched.first?.subject == "Discovery Call")
        #expect(fetched.first?.priority == .high)
    }
    
    @Test("Fetch activities for account")
    func testFetchActivitiesForAccount() async throws {
        // Given
        let account1 = Account(name: "Account 1")
        let account2 = Account(name: "Account 2")
        try await service.createAccount(account1)
        try await service.createAccount(account2)
        
        let activity1 = Activity(type: .call, subject: "Call 1")
        let activity2 = Activity(type: .email, subject: "Email 1")
        activity1.account = account1
        activity2.account = account2
        
        try await service.createActivity(activity1)
        try await service.createActivity(activity2)
        
        // When
        let account1Activities = try await service.fetchActivities(for: account1)
        
        // Then
        #expect(account1Activities.count == 1)
        #expect(account1Activities.first?.subject == "Call 1")
    }
    
    @Test("Fetch overdue activities")
    func testFetchOverdueActivities() async throws {
        // Given
        let overdueActivity = Activity(
            type: .task,
            subject: "Overdue Task",
            dueDate: Date().addingTimeInterval(-86400) // Yesterday
        )
        overdueActivity.status = .planned
        
        let futureActivity = Activity(
            type: .task,
            subject: "Future Task",
            dueDate: Date().addingTimeInterval(86400) // Tomorrow
        )
        
        try await service.createActivity(overdueActivity)
        try await service.createActivity(futureActivity)
        
        // When
        let overdue = try await service.fetchOverdueActivities()
        
        // Then
        #expect(overdue.count == 1)
        #expect(overdue.first?.subject == "Overdue Task")
        #expect(overdue.first?.isOverdue == true)
    }
    
    @Test("Complete activity")
    func testCompleteActivity() async throws {
        // Given
        let activity = Activity(
            type: .call,
            subject: "Follow-up Call",
            status: .planned
        )
        try await service.createActivity(activity)
        
        // When
        activity.complete(outcome: "Positive discussion, next steps agreed")
        try await service.updateActivity(activity)
        
        let updated = try await service.fetchActivities()
        
        // Then
        #expect(updated.first?.status == .completed)
        #expect(updated.first?.isCompleted == true)
        #expect(updated.first?.outcome == "Positive discussion, next steps agreed")
        #expect(updated.first?.completedDate != nil)
    }
    
    // MARK: - Data Validation Tests
    
    @Test("Account health score is within valid range")
    func testAccountHealthScoreRange() async throws {
        // Given
        let account = Account(name: "Test", healthScore: 150)
        
        // Then - health score should be clamped or validated
        #expect(account.healthScore >= 0)
        #expect(account.healthScore <= 100)
    }
    
    @Test("Opportunity probability updates with stage")
    func testOpportunityProbabilityUpdate() async throws {
        // Given
        let opportunity = Opportunity(
            name: "Test Deal",
            amount: 100_000,
            stage: .prospecting,
            expectedCloseDate: Date()
        )
        
        // When
        opportunity.progress(to: .negotiation)
        
        // Then
        #expect(opportunity.probability == 70) // Negotiation stage probability
    }
    
    @Test("Contact email validation")
    func testContactEmailValidation() {
        // Given
        let validContact = Contact(firstName: "John", lastName: "Doe", email: "john@example.com")
        let invalidContact = Contact(firstName: "Jane", lastName: "Smith", email: "not-an-email")
        
        // Then
        #expect(validContact.isValidEmail() == true)
        #expect(invalidContact.isValidEmail() == false)
    }
}
