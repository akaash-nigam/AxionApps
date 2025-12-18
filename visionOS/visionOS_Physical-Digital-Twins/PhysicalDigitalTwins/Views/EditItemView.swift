//
//  EditItemView.swift
//  PhysicalDigitalTwins
//
//  Edit existing inventory items
//

import SwiftUI

struct EditItemView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    let item: InventoryItem

    // Editable fields
    @State private var title: String
    @State private var author: String
    @State private var isbn: String
    @State private var purchasePrice: String
    @State private var purchaseStore: String
    @State private var location: String
    @State private var specificLocation: String
    @State private var notes: String
    @State private var condition: ItemCondition
    @State private var readingStatus: ReadingStatus

    @State private var isLoading = false
    @State private var errorMessage: String?

    init(item: InventoryItem) {
        self.item = item

        // Initialize state from item
        if let bookTwin = item.digitalTwin.asTwin() as BookTwin? {
            _title = State(initialValue: bookTwin.title)
            _author = State(initialValue: bookTwin.author)
            _isbn = State(initialValue: bookTwin.isbn ?? "")
            _readingStatus = State(initialValue: bookTwin.readingStatus)
        } else {
            _title = State(initialValue: item.digitalTwin.displayName)
            _author = State(initialValue: "")
            _isbn = State(initialValue: "")
            _readingStatus = State(initialValue: .unread)
        }

        _purchasePrice = State(initialValue: item.purchasePrice?.description ?? "")
        _purchaseStore = State(initialValue: item.purchaseStore ?? "")
        _location = State(initialValue: item.locationName ?? "")
        _specificLocation = State(initialValue: item.specificLocation ?? "")
        _notes = State(initialValue: item.notes ?? "")
        _condition = State(initialValue: item.condition)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Book Information") {
                    TextField("Title", text: $title)
                        .autocorrectionDisabled()

                    TextField("Author", text: $author)
                        .autocorrectionDisabled()

                    TextField("ISBN", text: $isbn)
                        .keyboardType(.numberPad)
                }

                Section("Reading Status") {
                    Picker("Status", selection: $readingStatus) {
                        ForEach([ReadingStatus.unread, .reading, .finished, .dnf], id: \.self) { status in
                            Text(status.displayName).tag(status)
                        }
                    }
                }

                Section("Purchase Details") {
                    TextField("Price", text: $purchasePrice)
                        .keyboardType(.decimalPad)

                    TextField("Store", text: $purchaseStore)
                        .autocorrectionDisabled()
                }

                Section("Condition") {
                    Picker("Condition", selection: $condition) {
                        ForEach([ItemCondition.new, .excellent, .good, .fair, .poor, .broken], id: \.self) { cond in
                            Text(cond.displayName).tag(cond)
                        }
                    }
                }

                Section("Location") {
                    TextField("Room/Area", text: $location)
                        .autocorrectionDisabled()

                    TextField("Specific Location", text: $specificLocation)
                        .autocorrectionDisabled()
                }

                Section("Notes") {
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
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
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

    private func saveChanges() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                // Create updated twin
                var updatedTwin = item.digitalTwin

                if var bookTwin = updatedTwin.asTwin() as BookTwin? {
                    bookTwin.title = title.trimmingCharacters(in: .whitespaces)
                    bookTwin.author = author.trimmingCharacters(in: .whitespaces)
                    bookTwin.isbn = isbn.isEmpty ? nil : isbn
                    bookTwin.readingStatus = readingStatus
                    bookTwin.updatedAt = Date()

                    updatedTwin = AnyDigitalTwin(bookTwin)
                }

                // Create updated inventory item
                var updatedItem = item
                updatedItem.digitalTwin = updatedTwin
                updatedItem.updatedAt = Date()

                // Update purchase details
                if !purchasePrice.isEmpty, let price = Decimal(string: purchasePrice) {
                    updatedItem.purchasePrice = price
                } else {
                    updatedItem.purchasePrice = nil
                }

                updatedItem.purchaseStore = purchaseStore.isEmpty ? nil : purchaseStore

                // Update location
                updatedItem.locationName = location.isEmpty ? nil : location
                updatedItem.specificLocation = specificLocation.isEmpty ? nil : specificLocation

                // Update notes and condition
                updatedItem.notes = notes.isEmpty ? nil : notes
                updatedItem.condition = condition

                // Save to storage
                await appState.updateItem(updatedItem)

                // Dismiss on success
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to save changes: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    let sampleBook = BookTwin(
        title: "Atomic Habits",
        author: "James Clear",
        isbn: "9780735211292",
        recognitionMethod: .barcode
    )

    var sampleItem = InventoryItem(digitalTwin: sampleBook)
    sampleItem.purchasePrice = 19.99
    sampleItem.locationName = "Bedroom"

    return EditItemView(item: sampleItem)
        .environment(AppState(dependencies: AppDependencies()))
}
