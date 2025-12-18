//
//  CRMService.swift
//  SpatialCRM
//
//  Core CRM service for data management
//

import Foundation
import SwiftData

@Observable
final class CRMService {
    // MARK: - Properties

    private let modelContext: ModelContext
    var isLoading: Bool = false
    var error: Error?

    // MARK: - Initialization

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Account Methods

    func fetchAccounts(filter: AccountFilter? = nil) async throws -> [Account] {
        isLoading = true
        defer { isLoading = false }

        var descriptor = FetchDescriptor<Account>(
            sortBy: [SortDescriptor(\.name)]
        )

        if let filter = filter {
            descriptor.predicate = filter.predicate
        }

        do {
            let accounts = try modelContext.fetch(descriptor)
            return accounts
        } catch {
            self.error = error
            throw error
        }
    }

    func fetchAccount(id: UUID) async throws -> Account? {
        let descriptor = FetchDescriptor<Account>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }

    func createAccount(_ account: Account) async throws -> Account {
        modelContext.insert(account)
        try modelContext.save()
        return account
    }

    func updateAccount(_ account: Account) async throws {
        account.updatedAt = Date()
        try modelContext.save()
    }

    func deleteAccount(_ id: UUID) async throws {
        guard let account = try await fetchAccount(id: id) else {
            throw CRMError.accountNotFound
        }
        modelContext.delete(account)
        try modelContext.save()
    }

    // MARK: - Opportunity Methods

    func fetchOpportunities(filter: OpportunityFilter? = nil) async throws -> [Opportunity] {
        isLoading = true
        defer { isLoading = false }

        var descriptor = FetchDescriptor<Opportunity>(
            sortBy: [SortDescriptor(\.amount, order: .reverse)]
        )

        if let filter = filter {
            descriptor.predicate = filter.predicate
        }

        return try modelContext.fetch(descriptor)
    }

    func fetchOpportunity(id: UUID) async throws -> Opportunity? {
        let descriptor = FetchDescriptor<Opportunity>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }

    func createOpportunity(_ opportunity: Opportunity) async throws -> Opportunity {
        modelContext.insert(opportunity)
        try modelContext.save()
        return opportunity
    }

    func updateOpportunity(_ opportunity: Opportunity) async throws {
        opportunity.updatedAt = Date()
        try modelContext.save()
    }

    func deleteOpportunity(_ id: UUID) async throws {
        guard let opportunity = try await fetchOpportunity(id: id) else {
            throw CRMError.opportunityNotFound
        }
        modelContext.delete(opportunity)
        try modelContext.save()
    }

    // MARK: - Contact Methods

    func fetchContacts(accountId: UUID? = nil) async throws -> [Contact] {
        var descriptor = FetchDescriptor<Contact>(
            sortBy: [SortDescriptor(\.lastName)]
        )

        if let accountId = accountId {
            descriptor.predicate = #Predicate { contact in
                contact.account?.id == accountId
            }
        }

        return try modelContext.fetch(descriptor)
    }

    func createContact(_ contact: Contact) async throws -> Contact {
        modelContext.insert(contact)
        try modelContext.save()
        return contact
    }

    func updateContact(_ contact: Contact) async throws {
        contact.updatedAt = Date()
        try modelContext.save()
    }

    // MARK: - Activity Methods

    func fetchActivities(filter: ActivityFilter? = nil) async throws -> [Activity] {
        var descriptor = FetchDescriptor<Activity>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        if let filter = filter {
            descriptor.predicate = filter.predicate
        }

        return try modelContext.fetch(descriptor)
    }

    func createActivity(_ activity: Activity) async throws -> Activity {
        modelContext.insert(activity)
        try modelContext.save()
        return activity
    }

    func completeActivity(_ activity: Activity, outcome: ActivityOutcome) async throws {
        activity.complete(outcome: outcome)
        try modelContext.save()
    }

    // MARK: - Search

    func searchCustomers(query: String) async throws -> [SearchResult] {
        var results: [SearchResult] = []

        // Search accounts
        let accountDescriptor = FetchDescriptor<Account>(
            predicate: #Predicate { account in
                account.name.localizedStandardContains(query)
            }
        )
        let accounts = try modelContext.fetch(accountDescriptor)
        results.append(contentsOf: accounts.map { SearchResult.account($0) })

        // Search contacts
        let contactDescriptor = FetchDescriptor<Contact>(
            predicate: #Predicate { contact in
                contact.firstName.localizedStandardContains(query) ||
                contact.lastName.localizedStandardContains(query) ||
                contact.email.localizedStandardContains(query)
            }
        )
        let contacts = try modelContext.fetch(contactDescriptor)
        results.append(contentsOf: contacts.map { SearchResult.contact($0) })

        // Search opportunities
        let oppDescriptor = FetchDescriptor<Opportunity>(
            predicate: #Predicate { opp in
                opp.name.localizedStandardContains(query)
            }
        )
        let opportunities = try modelContext.fetch(oppDescriptor)
        results.append(contentsOf: opportunities.map { SearchResult.opportunity($0) })

        return results
    }

    // MARK: - Analytics

    func getPipelineMetrics() async throws -> PipelineMetrics {
        let opportunities = try await fetchOpportunities(
            filter: .active
        )

        let totalValue = opportunities.reduce(Decimal(0)) { $0 + $1.amount }
        let weightedValue = opportunities.reduce(Decimal(0)) { total, opp in
            total + (opp.amount * Decimal(opp.probability / 100))
        }

        let stageBreakdown = Dictionary(grouping: opportunities) { $0.stage }
            .mapValues { $0.count }

        return PipelineMetrics(
            totalValue: totalValue,
            weightedValue: weightedValue,
            opportunityCount: opportunities.count,
            stageBreakdown: stageBreakdown,
            averageDealSize: opportunities.isEmpty ? 0 : totalValue / Decimal(opportunities.count)
        )
    }

    func calculateHealthScore(for account: Account) async -> Double {
        // Simple health score calculation
        var score: Double = 50.0

        // Factor 1: Recent activity (0-25 points)
        let recentActivityCount = account.activities.filter {
            guard let completed = $0.completedAt else { return false }
            return completed > Date().addingTimeInterval(-30 * 24 * 60 * 60) // Last 30 days
        }.count
        score += min(Double(recentActivityCount) * 2.5, 25)

        // Factor 2: Open opportunities (0-25 points)
        let activeOpps = account.opportunities.filter { $0.status == .active }
        score += min(Double(activeOpps.count) * 5, 25)

        // Factor 3: Revenue (0-25 points)
        if account.revenue > 1_000_000 {
            score += 25
        } else if account.revenue > 500_000 {
            score += 15
        } else if account.revenue > 100_000 {
            score += 5
        }

        // Factor 4: Positive sentiment (0-25 points)
        let positiveSentimentCount = account.activities.filter {
            $0.sentiment == .positive || $0.sentiment == .veryPositive
        }.count
        score += min(Double(positiveSentimentCount) * 2, 25)

        return min(max(score, 0), 100)
    }
}

// MARK: - Supporting Types

enum CRMError: LocalizedError {
    case accountNotFound
    case opportunityNotFound
    case contactNotFound
    case invalidData

    var errorDescription: String? {
        switch self {
        case .accountNotFound: return "Account not found"
        case .opportunityNotFound: return "Opportunity not found"
        case .contactNotFound: return "Contact not found"
        case .invalidData: return "Invalid data provided"
        }
    }
}

enum AccountFilter {
    case all
    case highValue(Decimal)
    case lowHealth(Double)
    case territory(UUID)

    var predicate: Predicate<Account> {
        switch self {
        case .all:
            return #Predicate { _ in true }
        case .highValue(let minRevenue):
            return #Predicate { $0.revenue >= minRevenue }
        case .lowHealth(let maxHealth):
            return #Predicate { $0.healthScore <= maxHealth }
        case .territory(let territoryId):
            return #Predicate { account in
                account.territories.contains { $0.id == territoryId }
            }
        }
    }
}

enum OpportunityFilter {
    case all
    case active
    case stage(DealStage)
    case closingThisMonth
    case overdue

    var predicate: Predicate<Opportunity> {
        switch self {
        case .all:
            return #Predicate { _ in true }
        case .active:
            return #Predicate { $0.status == .active }
        case .stage(let stage):
            return #Predicate { $0.stage == stage }
        case .closingThisMonth:
            let now = Date()
            let calendar = Calendar.current
            let endOfMonth = calendar.date(byAdding: .month, value: 1, to: now) ?? now
            return #Predicate { opp in
                opp.expectedCloseDate >= now && opp.expectedCloseDate <= endOfMonth
            }
        case .overdue:
            let now = Date()
            return #Predicate { opp in
                opp.status == .active && opp.expectedCloseDate < now
            }
        }
    }
}

enum ActivityFilter {
    case all
    case pending
    case completed
    case overdue
    case today

    var predicate: Predicate<Activity> {
        switch self {
        case .all:
            return #Predicate { _ in true }
        case .pending:
            return #Predicate { $0.completedAt == nil }
        case .completed:
            return #Predicate { $0.completedAt != nil }
        case .overdue:
            let now = Date()
            return #Predicate { activity in
                activity.completedAt == nil &&
                activity.scheduledAt ?? now < now
            }
        case .today:
            let start = Calendar.current.startOfDay(for: Date())
            let end = Calendar.current.date(byAdding: .day, value: 1, to: start) ?? Date()
            return #Predicate { activity in
                if let scheduled = activity.scheduledAt {
                    return scheduled >= start && scheduled < end
                }
                return false
            }
        }
    }
}

enum SearchResult {
    case account(Account)
    case contact(Contact)
    case opportunity(Opportunity)

    var id: UUID {
        switch self {
        case .account(let a): return a.id
        case .contact(let c): return c.id
        case .opportunity(let o): return o.id
        }
    }

    var title: String {
        switch self {
        case .account(let a): return a.name
        case .contact(let c): return c.fullName
        case .opportunity(let o): return o.name
        }
    }

    var subtitle: String {
        switch self {
        case .account(let a): return a.industry
        case .contact(let c): return c.title
        case .opportunity(let o): return "\(o.amount.formatted(.currency(code: "USD"))) • \(o.stage.displayName)"
        }
    }
}

struct PipelineMetrics {
    let totalValue: Decimal
    let weightedValue: Decimal
    let opportunityCount: Int
    let stageBreakdown: [DealStage: Int]
    let averageDealSize: Decimal
}
