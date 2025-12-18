//
//  AddItemManuallyView.swift
//  PhysicalDigitalTwins
//
//  Manual entry form for adding items
//

import SwiftUI

struct AddItemManuallyView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var author = ""
    @State private var isbn = ""
    @State private var purchasePrice = ""
    @State private var purchaseStore = ""
    @State private var location = ""
    @State private var notes = ""

    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Book Information") {
                    TextField("Title", text: $title)
                        .autocorrectionDisabled()

                    TextField("Author", text: $author)
                        .autocorrectionDisabled()

                    TextField("ISBN (optional)", text: $isbn)
                        .keyboardType(.numberPad)
                }

                Section("Purchase Details (Optional)") {
                    TextField("Price", text: $purchasePrice)
                        .keyboardType(.decimalPad)

                    TextField("Store", text: $purchaseStore)
                        .autocorrectionDisabled()
                }

                Section("Organization (Optional)") {
                    TextField("Location", text: $location)
                        .autocorrectionDisabled()

                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Add Item Manually")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveItem()
                    }
                    .disabled(!isFormValid || isLoading)
                }
            }
            .disabled(isLoading)
        }
    }

    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !author.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func saveItem() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                // Create book twin
                var bookTwin = appState.dependencies.twinFactory.createManualTwin(
                    title: title.trimmingCharacters(in: .whitespaces),
                    author: author.trimmingCharacters(in: .whitespaces)
                )

                if !isbn.isEmpty {
                    bookTwin.isbn = isbn
                }

                // If ISBN provided, try to enrich from API
                if !isbn.isEmpty {
                    do {
                        let bookInfo = try await appState.dependencies.apiService.fetchBookInfo(isbn: isbn)
                        bookTwin = appState.dependencies.twinFactory.createBookTwin(from: bookInfo)
                    } catch {
                        // Continue with manual data if API fails
                        print("API enrichment failed: \(error)")
                    }
                }

                // Create inventory item
                var item = InventoryItem(digitalTwin: bookTwin)

                // Add purchase details
                if !purchasePrice.isEmpty, let price = Decimal(string: purchasePrice) {
                    item.purchasePrice = price
                    item.purchaseDate = Date()
                }

                if !purchaseStore.isEmpty {
                    item.purchaseStore = purchaseStore
                }

                if !location.isEmpty {
                    item.locationName = location
                }

                if !notes.isEmpty {
                    item.notes = notes
                }

                // Save to storage
                await appState.addItem(item)

                // Dismiss on success
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to save item: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    AddItemManuallyView()
        .environment(AppState(dependencies: AppDependencies()))
}
