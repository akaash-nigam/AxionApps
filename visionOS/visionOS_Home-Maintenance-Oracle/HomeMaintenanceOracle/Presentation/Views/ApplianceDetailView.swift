//
//  ApplianceDetailView.swift
//  HomeMaintenanceOracle
//
//  Created on 2025-11-24.
//  Detailed view for appliance information
//

import SwiftUI

struct ApplianceDetailView: View {

    // MARK: - Properties

    let appliance: Appliance
    @StateObject private var viewModel: ApplianceDetailViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - Initialization

    init(appliance: Appliance) {
        self.appliance = appliance
        _viewModel = StateObject(wrappedValue: ApplianceDetailViewModel(appliance: appliance))
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Card
                headerCard

                // Information Sections
                basicInfoSection
                installationInfoSection
                maintenanceSection
                serviceHistorySection

                // Actions Section
                actionsSection

                Spacer(minLength: 40)
            }
            .padding()
        }
        .navigationTitle(appliance.brand)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        viewModel.showEditSheet = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        viewModel.showDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $viewModel.showEditSheet) {
            EditApplianceView(appliance: appliance)
        }
        .alert("Delete Appliance?", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deleteAppliance()
                    dismiss()
                }
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }

    // MARK: - View Components

    private var headerCard: some View {
        VStack(spacing: 16) {
            // Icon
            Image(systemName: appliance.categoryIcon)
                .font(.system(size: 60))
                .foregroundStyle(.blue)
                .frame(width: 100, height: 100)
                .background(.blue.opacity(0.1), in: Circle())

            // Title
            VStack(spacing: 4) {
                Text(appliance.brand)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(appliance.model)
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text(appliance.category.displayName)
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(.blue.opacity(0.1), in: Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Basic Information", icon: "info.circle.fill")

            VStack(spacing: 8) {
                if let serialNumber = appliance.serialNumber {
                    InfoRow(label: "Serial Number", value: serialNumber)
                }

                if let location = appliance.roomLocation {
                    InfoRow(label: "Location", value: location)
                }

                InfoRow(label: "Added", value: appliance.createdAt.formatted(date: .long, time: .omitted))

                if let purchaseDate = appliance.purchaseDate {
                    InfoRow(label: "Purchase Date", value: purchaseDate.formatted(date: .long, time: .omitted))
                }

                if let purchasePrice = appliance.purchasePrice {
                    InfoRow(label: "Purchase Price", value: "$\(String(format: "%.2f", purchasePrice))")
                }

                if let warrantyExpiry = appliance.warrantyExpiry {
                    let isExpired = warrantyExpiry < Date()
                    InfoRow(
                        label: "Warranty",
                        value: warrantyExpiry.formatted(date: .long, time: .omitted),
                        valueColor: isExpired ? .red : .primary
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var installationInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Installation", icon: "wrench.and.screwdriver.fill")

            VStack(spacing: 8) {
                if let installDate = appliance.installDate {
                    let age = Calendar.current.dateComponents([.year, .month], from: installDate, to: Date())
                    let ageString = formatAge(years: age.year ?? 0, months: age.month ?? 0)
                    InfoRow(label: "Installed", value: installDate.formatted(date: .long, time: .omitted))
                    InfoRow(label: "Age", value: ageString)
                }

                if let notes = appliance.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notes")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(notes)
                            .font(.body)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var maintenanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Maintenance", icon: "calendar.badge.checkmark")

            // TODO: Fetch actual maintenance tasks from database
            Text("No upcoming maintenance tasks")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()

            Button {
                viewModel.showAddMaintenanceTask = true
            } label: {
                Label("Schedule Maintenance", systemImage: "plus.circle")
            }
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var serviceHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Service History", icon: "clock.fill")

            // TODO: Fetch actual service history from database
            Text("No service history")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()

            Button {
                viewModel.showAddServiceRecord = true
            } label: {
                Label("Add Service Record", systemImage: "plus.circle")
            }
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button {
                viewModel.showManual = true
            } label: {
                Label("View Manual", systemImage: "book.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            HStack(spacing: 12) {
                Button {
                    viewModel.showPartsLookup = true
                } label: {
                    Label("Find Parts", systemImage: "magnifyingglass")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                ShareLink(
                    item: applianceShareText,
                    subject: Text("Appliance: \(appliance.brand) \(appliance.model)")
                ) {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }

    // MARK: - Computed Properties

    private var applianceShareText: String {
        var text = "\(appliance.brand) \(appliance.model)\n"
        text += "Category: \(appliance.category.displayName)\n"
        if let serial = appliance.serialNumber {
            text += "Serial: \(serial)\n"
        }
        if let location = appliance.roomLocation {
            text += "Location: \(location)\n"
        }
        return text
    }

    // MARK: - Helper Methods

    private func formatAge(years: Int, months: Int) -> String {
        if years == 0 {
            return "\(months) month\(months == 1 ? "" : "s")"
        } else if months == 0 {
            return "\(years) year\(years == 1 ? "" : "s")"
        } else {
            return "\(years)y \(months)m"
        }
    }
}

// MARK: - Supporting Views

struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
            Text(title)
                .font(.headline)
            Spacer()
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    var valueColor: Color = .primary

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundStyle(valueColor)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ApplianceDetailView(
            appliance: Appliance(
                brand: "Samsung",
                model: "RF28R7351SR",
                serialNumber: "12345ABC",
                category: .refrigerator,
                installDate: Date().addingTimeInterval(-31536000), // 1 year ago
                purchasePrice: 2499.99,
                notes: "High-efficiency model with smart features",
                roomLocation: "Kitchen"
            )
        )
    }
}
