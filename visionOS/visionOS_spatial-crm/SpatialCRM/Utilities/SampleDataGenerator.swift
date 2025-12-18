//
//  SampleDataGenerator.swift
//  SpatialCRM
//
//  Generate sample data for development and testing
//

import Foundation
import SwiftData

@MainActor
class SampleDataGenerator {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Generate a complete sample dataset for development
    func generateCompleteDataset() {
        print("🎬 Generating sample CRM data...")

        // Create sales reps
        let salesReps = createSalesReps()
        print("✅ Created \(salesReps.count) sales reps")

        // Create territories
        let territories = createTerritories(reps: salesReps)
        print("✅ Created \(territories.count) territories")

        // Create accounts
        let accounts = createAccounts(territories: territories, reps: salesReps)
        print("✅ Created \(accounts.count) accounts")

        // Create contacts for accounts
        let contacts = createContacts(for: accounts)
        print("✅ Created \(contacts.count) contacts")

        // Create opportunities
        let opportunities = createOpportunities(for: accounts, contacts: contacts, reps: salesReps)
        print("✅ Created \(opportunities.count) opportunities")

        // Create activities
        let activities = createActivities(for: accounts, contacts: contacts, opportunities: opportunities, reps: salesReps)
        print("✅ Created \(activities.count) activities")

        // Save context
        do {
            try modelContext.save()
            print("💾 Sample data saved successfully!")
        } catch {
            print("❌ Error saving sample data: \(error)")
        }
    }

    // MARK: - Sales Reps

    private func createSalesReps() -> [SalesRep] {
        let names = [
            ("John", "Sales", "representative", 2_500_000),
            ("Mary", "Account", "accountExecutive", 3_000_000),
            ("David", "Manager", "manager", 10_000_000),
            ("Lisa", "Director", "director", 25_000_000),
            ("Mike", "Chen", "representative", 2_000_000),
            ("Sarah", "Williams", "accountExecutive", 2_800_000)
        ]

        return names.map { firstName, lastName, roleStr, quota in
            let role = SalesRole(rawValue: roleStr) ?? .representative
            let rep = SalesRep(
                firstName: firstName,
                lastName: lastName,
                email: "\(firstName.lowercased())@company.com",
                role: role,
                quota: Decimal(quota)
            )

            // Set realistic achievement
            rep.achievedRevenue = Decimal(quota) * Decimal.random(in: 0.6...1.2)
            rep.winRate = Double.random(in: 0.5...0.8)
            rep.averageDealSize = Decimal.random(in: 50_000...300_000)
            rep.activitiesPerWeek = Int.random(in: 15...35)

            modelContext.insert(rep)
            return rep
        }
    }

    // MARK: - Territories

    private func createTerritories(reps: [SalesRep]) -> [Territory] {
        let territoryData = [
            ("West Coast", "North America", 5_000_000),
            ("East Coast", "North America", 4_500_000),
            ("Europe", "EMEA", 6_000_000),
            ("Asia Pacific", "APAC", 3_000_000),
            ("Latin America", "LATAM", 2_500_000)
        ]

        return territoryData.enumerated().map { index, data in
            let (name, region, quota) = data
            let territory = Territory(
                name: name,
                region: region,
                quota: Decimal(quota),
                actualRevenue: Decimal(quota) * Decimal.random(in: 0.7...1.1)
            )

            // Assign reps to territories
            if index < reps.count {
                territory.reps.append(reps[index])
            }

            modelContext.insert(territory)
            return territory
        }
    }

    // MARK: - Accounts

    private func createAccounts(territories: [Territory], reps: [SalesRep]) -> [Account] {
        let accountData = [
            ("Acme Corporation", "Enterprise Software", 2_500_000, 500, 92.0, RiskLevel.low),
            ("TechCo Industries", "Technology", 1_200_000, 250, 78.0, .medium),
            ("Global Enterprises", "Manufacturing", 5_000_000, 1000, 85.0, .low),
            ("StartupX", "SaaS", 500_000, 50, 65.0, .medium),
            ("MegaCorp", "Retail", 10_000_000, 5000, 45.0, .high),
            ("InnovateLabs", "Biotechnology", 3_000_000, 300, 88.0, .low),
            ("CloudSystems", "Cloud Services", 4_500_000, 750, 72.0, .medium),
            ("DataDynamics", "Analytics", 1_800_000, 200, 80.0, .low),
            ("FinTech Pro", "Financial Services", 6_000_000, 1200, 55.0, .high),
            ("HealthCare Plus", "Healthcare", 3_500_000, 600, 90.0, .low)
        ]

        return accountData.enumerated().map { index, data in
            let (name, industry, revenue, employees, health, risk) = data
            let account = Account(
                name: name,
                industry: industry,
                revenue: Decimal(revenue),
                employeeCount: employees,
                healthScore: health,
                riskLevel: risk
            )

            account.website = "https://\(name.lowercased().replacingOccurrences(of: " ", with: "")).example.com"
            account.phone = "+1-555-\(String(format: "%04d", index * 100))"

            // Assign to territory and rep
            if !territories.isEmpty {
                let territory = territories[index % territories.count]
                account.territories.append(territory)
            }

            // Set spatial position (galaxy layout)
            let tier = revenue > 5_000_000 ? 1 : (revenue > 1_000_000 ? 2 : 3)
            let radius = Float(tier) * 2.0
            let angle = Float(index) * (2 * .pi / Float(accountData.count))
            account.positionX = radius * cos(angle)
            account.positionY = Float.random(in: -0.5...0.5)
            account.positionZ = radius * sin(angle)
            account.visualSize = Float(revenue) / 1_000_000 * 0.1 + 0.1

            modelContext.insert(account)
            return account
        }
    }

    // MARK: - Contacts

    private func createContacts(for accounts: [Account]) -> [Contact] {
        var allContacts: [Contact] = []

        let roles: [(String, String, ContactRole, Double, Bool)] = [
            ("CEO", "Chief Executive Officer", .champion, 95.0, true),
            ("CTO", "Chief Technology Officer", .influencer, 85.0, true),
            ("VP Sales", "Vice President of Sales", .influencer, 80.0, true),
            ("Product Manager", "Product Manager", .user, 60.0, false),
            ("Engineer", "Software Engineer", .user, 40.0, false)
        ]

        for account in accounts {
            let contactCount = Int.random(in: 3...6)

            for i in 0..<contactCount {
                let roleData = roles[min(i, roles.count - 1)]
                let firstName = ["John", "Jane", "Mike", "Sarah", "David", "Emily"][i % 6]
                let lastName = ["Smith", "Johnson", "Williams", "Brown", "Jones", "Davis"][i % 6]

                let contact = Contact(
                    firstName: firstName,
                    lastName: lastName,
                    email: "\(firstName.lowercased()).\(lastName.lowercased())@\(account.name.lowercased().replacingOccurrences(of: " ", with: "")).com",
                    phone: "+1-555-\(String(format: "%04d", Int.random(in: 1000...9999)))",
                    title: roleData.1,
                    role: roleData.2,
                    influenceScore: roleData.3,
                    isDecisionMaker: roleData.4,
                    isPrimaryContact: i == 0
                )

                contact.account = account
                contact.lastContactedAt = Date().addingTimeInterval(-Double.random(in: 0...30) * 24 * 60 * 60)

                modelContext.insert(contact)
                allContacts.append(contact)
            }
        }

        return allContacts
    }

    // MARK: - Opportunities

    private func createOpportunities(for accounts: [Account], contacts: [Contact], reps: [SalesRep]) -> [Opportunity] {
        var allOpportunities: [Opportunity] = []

        for account in accounts {
            let oppCount = Int.random(in: 1...4)

            for i in 0..<oppCount {
                let amount = Decimal(Int.random(in: 50_000...1_000_000))
                let stage = DealStage.allCases.filter { $0 != .closedLost }[Int.random(in: 0...5)]
                let closeDate = Date().addingTimeInterval(Double.random(in: 7...90) * 24 * 60 * 60)

                let opp = Opportunity(
                    name: "\(account.name) - \(["Enterprise License", "Annual Subscription", "Professional Services", "Expansion"][i % 4])",
                    amount: amount,
                    stage: stage,
                    probability: stage.typicalProbability,
                    expectedCloseDate: closeDate,
                    status: stage == .closedWon ? .won : .active,
                    type: [.newBusiness, .upsell, .renewal][Int.random(in: 0...2)]
                )

                opp.description = "Strategic opportunity for \(account.name)"
                opp.account = account
                opp.owner = reps.randomElement()

                // AI fields
                opp.aiScore = Double.random(in: 40...95)
                opp.riskFactors = ["Budget approval pending", "Competition from rival"].filter { _ in Bool.random() }
                opp.suggestedActions = ["Schedule executive meeting", "Send proposal"].filter { _ in Bool.random() }
                opp.velocity = Double.random(in: 5...30)

                // Add contacts
                let accountContacts = contacts.filter { $0.account?.id == account.id }
                if !accountContacts.isEmpty {
                    opp.contacts.append(contentsOf: accountContacts.prefix(2))
                }

                modelContext.insert(opp)
                allOpportunities.append(opp)
            }
        }

        return allOpportunities
    }

    // MARK: - Activities

    private func createActivities(for accounts: [Account], contacts: [Contact], opportunities: [Opportunity], reps: [SalesRep]) -> [Activity] {
        var allActivities: [Activity] = []

        let activityTypes: [ActivityType] = [.call, .meeting, .email, .demo, .task]
        let subjects = [
            "Initial discovery call",
            "Product demonstration",
            "Contract negotiation",
            "Follow-up meeting",
            "Proposal presentation",
            "Technical deep dive",
            "Executive briefing",
            "Quarterly business review"
        ]

        // Create activities for opportunities
        for opportunity in opportunities {
            let activityCount = Int.random(in: 3...8)

            for _ in 0..<activityCount {
                let type = activityTypes.randomElement()!
                let scheduledDate = Date().addingTimeInterval(-Double.random(in: 0...30) * 24 * 60 * 60)
                let isCompleted = Bool.random()

                let activity = Activity(
                    type: type,
                    subject: subjects.randomElement()!,
                    description: "Activity related to \(opportunity.name)",
                    scheduledAt: scheduledDate
                )

                activity.opportunity = opportunity
                activity.account = opportunity.account
                activity.owner = opportunity.owner

                if isCompleted {
                    activity.complete(outcome: [.successful, .unsuccessful, .rescheduled].randomElement()!)
                    activity.sentiment = [.positive, .neutral, .negative].randomElement()
                    activity.keyTopics = ["Pricing", "Timeline", "Features"].shuffled().prefix(2).map { $0 }
                }

                if !opportunity.contacts.isEmpty {
                    activity.contact = opportunity.contacts.randomElement()
                }

                modelContext.insert(activity)
                allActivities.append(activity)
            }
        }

        return allActivities
    }

    // MARK: - Cleanup

    func clearAllData() {
        print("🗑️ Clearing all CRM data...")

        do {
            // Delete all entities
            try modelContext.delete(model: Account.self)
            try modelContext.delete(model: Contact.self)
            try modelContext.delete(model: Opportunity.self)
            try modelContext.delete(model: Activity.self)
            try modelContext.delete(model: Territory.self)
            try modelContext.delete(model: SalesRep.self)

            try modelContext.save()
            print("✅ All data cleared successfully")
        } catch {
            print("❌ Error clearing data: \(error)")
        }
    }
}
