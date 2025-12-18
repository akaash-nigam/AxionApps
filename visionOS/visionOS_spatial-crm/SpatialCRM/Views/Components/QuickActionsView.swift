//
//  QuickActionsView.swift
//  SpatialCRM
//
//  Quick actions panel
//

import SwiftUI

struct QuickActionsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Create") {
                    QuickActionItem(
                        icon: "plus.circle.fill",
                        title: "New Opportunity",
                        subtitle: "Create a new deal",
                        color: .blue
                    ) {
                        // Create opportunity
                    }

                    QuickActionItem(
                        icon: "building.2.fill",
                        title: "New Account",
                        subtitle: "Add a new customer",
                        color: .green
                    ) {
                        // Create account
                    }

                    QuickActionItem(
                        icon: "person.fill.badge.plus",
                        title: "New Contact",
                        subtitle: "Add a contact",
                        color: .orange
                    ) {
                        // Create contact
                    }
                }

                Section("Log Activity") {
                    QuickActionItem(
                        icon: "phone.fill",
                        title: "Log Call",
                        subtitle: "Record a phone call",
                        color: .cyan
                    ) {
                        // Log call
                    }

                    QuickActionItem(
                        icon: "envelope.fill",
                        title: "Send Email",
                        subtitle: "Compose an email",
                        color: .purple
                    ) {
                        // Send email
                    }

                    QuickActionItem(
                        icon: "calendar",
                        title: "Schedule Meeting",
                        subtitle: "Book a meeting",
                        color: .red
                    ) {
                        // Schedule meeting
                    }
                }

                Section("AI Powered") {
                    QuickActionItem(
                        icon: "sparkles",
                        title: "AI Insights",
                        subtitle: "View AI recommendations",
                        color: .pink
                    ) {
                        // Show AI insights
                    }

                    QuickActionItem(
                        icon: "wand.and.stars",
                        title: "Smart Suggestions",
                        subtitle: "Get next best actions",
                        color: .indigo
                    ) {
                        // Show suggestions
                    }
                }

                Section("3D Views") {
                    QuickActionItem(
                        icon: "globe",
                        title: "Customer Galaxy",
                        subtitle: "Immersive customer view",
                        color: .blue
                    ) {
                        // Open galaxy
                    }

                    QuickActionItem(
                        icon: "water.waves",
                        title: "Pipeline River",
                        subtitle: "3D pipeline visualization",
                        color: .cyan
                    ) {
                        // Open pipeline
                    }
                }
            }
            .navigationTitle("Quick Actions")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct QuickActionItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                    .frame(width: 44)

                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    QuickActionsView()
}
