//
//  CustomerDetailView.swift
//  SpatialCRM
//
//  Customer detail view
//

import SwiftUI
import SwiftData

struct CustomerDetailView: View {
    let customerId: UUID
    @Environment(\.modelContext) private var modelContext
    @State private var account: Account?

    var body: some View {
        if let account = account {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    HStack {
                        Circle()
                            .fill(.blue.gradient)
                            .frame(width: 80, height: 80)
                            .overlay {
                                Text(account.name.prefix(1))
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                            }

                        VStack(alignment: .leading) {
                            Text(account.name)
                                .font(.title)
                                .fontWeight(.bold)

                            Text(account.industry)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            HStack {
                                Label(account.revenue.formatted(.currency(code: "USD")), systemImage: "dollarsign.circle")
                                Label("\(account.employeeCount) employees", systemImage: "person.2")
                            }
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                        }

                        Spacer()

                        HealthScoreIndicator(score: account.healthScore)
                            .frame(width: 60, height: 60)
                    }

                    Divider()

                    // Contacts
                    VStack(alignment: .leading) {
                        Text("Contacts (\(account.contacts.count))")
                            .font(.headline)

                        ForEach(account.contacts) { contact in
                            ContactRowView(contact: contact)
                        }
                    }

                    Divider()

                    // Opportunities
                    VStack(alignment: .leading) {
                        Text("Opportunities (\(account.opportunities.count))")
                            .font(.headline)

                        ForEach(account.opportunities) { opp in
                            OpportunityRow(opportunity: opp)
                        }
                    }

                    Divider()

                    // Actions
                    HStack(spacing: 12) {
                        Button("Schedule Meeting") { }
                            .buttonStyle(.borderedProminent)

                        Button("Create Opportunity") { }
                            .buttonStyle(.bordered)

                        Button("View in 3D") { }
                            .buttonStyle(.bordered)
                    }
                }
                .padding()
            }
        } else {
            ProgressView("Loading...")
                .onAppear {
                    loadAccount()
                }
        }
    }

    private func loadAccount() {
        let descriptor = FetchDescriptor<Account>(
            predicate: #Predicate { $0.id == customerId }
        )
        account = try? modelContext.fetch(descriptor).first
    }
}

struct ContactRowView: View {
    let contact: Contact

    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .font(.title2)
                .foregroundStyle(.blue)

            VStack(alignment: .leading) {
                Text(contact.fullName)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(contact.title)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(contact.email)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            if contact.isDecisionMaker {
                Image(systemName: "crown.fill")
                    .foregroundStyle(.yellow)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    CustomerDetailView(customerId: UUID())
}
