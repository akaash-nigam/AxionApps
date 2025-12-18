//
//  AccountsView.swift
//  SpatialCRM
//
//  Accounts/Customers view
//

import SwiftUI
import SwiftData

struct AccountsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @State private var accounts: [Account] = []
    @State private var searchText = ""

    var body: some View {
        VStack {
            List {
                ForEach(filteredAccounts) { account in
                    AccountRow(account: account)
                        .onTapGesture {
                            openWindow(id: "customer-detail", value: account.id)
                        }
                }
            }
            .searchable(text: $searchText, prompt: "Search accounts")

            // Spatial view button
            Button("View in Customer Galaxy (Immersive)") {
                Task {
                    await openImmersiveSpace(id: "customer-galaxy")
                }
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .navigationTitle("Accounts")
        .onAppear {
            loadAccounts()
        }
    }

    private var filteredAccounts: [Account] {
        if searchText.isEmpty {
            return accounts
        }
        return accounts.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private func loadAccounts() {
        let descriptor = FetchDescriptor<Account>(
            sortBy: [SortDescriptor(\.name)]
        )
        accounts = (try? modelContext.fetch(descriptor)) ?? []
    }
}

struct AccountRow: View {
    let account: Account

    var body: some View {
        HStack {
            // Company logo placeholder
            Circle()
                .fill(.blue.gradient)
                .frame(width: 50, height: 50)
                .overlay {
                    Text(account.name.prefix(1))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(account.name)
                    .font(.headline)

                Text(account.industry)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack {
                    Label("\(account.revenue.formatted(.currency(code: "USD")))", systemImage: "dollarsign.circle")
                    Label("Health: \(Int(account.healthScore))", systemImage: "heart.fill")
                }
                .font(.caption)
                .foregroundStyle(.tertiary)
            }

            Spacer()

            HealthScoreIndicator(score: account.healthScore)
        }
        .padding(.vertical, 4)
    }
}

struct HealthScoreIndicator: View {
    let score: Double

    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(.tertiary, lineWidth: 4)
                Circle()
                    .trim(from: 0, to: score / 100)
                    .stroke(color, lineWidth: 4)
                    .rotationEffect(.degrees(-90))

                Text("\(Int(score))")
                    .font(.caption2)
                    .fontWeight(.bold)
            }
            .frame(width: 40, height: 40)
        }
    }

    private var color: Color {
        if score > 75 {
            return .green
        } else if score > 50 {
            return .orange
        } else {
            return .red
        }
    }
}

#Preview {
    AccountsView()
}
