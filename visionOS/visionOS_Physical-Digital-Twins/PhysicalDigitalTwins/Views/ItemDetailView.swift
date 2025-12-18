//
//  ItemDetailView.swift
//  PhysicalDigitalTwins
//
//  Detailed view of an inventory item
//

import SwiftUI

struct ItemDetailView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    let item: InventoryItem

    @State private var showingDeleteAlert = false
    @State private var showingEditSheet = false
    @State private var showingPhotoGallery = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                ItemHeader(item: item)

                // Photos
                PhotoSection(
                    item: item,
                    onViewGallery: { showingPhotoGallery = true }
                )

                // Details based on type
                if let bookTwin = item.digitalTwin.asTwin() as BookTwin? {
                    BookDetails(book: bookTwin)
                }

                // Purchase Info
                if item.purchaseDate != nil || item.purchasePrice != nil {
                    PurchaseInfoSection(item: item)
                }

                // Location
                if let location = item.locationName {
                    LocationSection(location: location, specificLocation: item.specificLocation)
                }

                // Notes
                if let notes = item.notes {
                    NotesSection(notes: notes)
                }

                // Actions
                ActionsSection(
                    onEdit: { showingEditSheet = true },
                    onDelete: { showingDeleteAlert = true }
                )
            }
            .padding()
        }
        .navigationTitle(item.digitalTwin.displayName)
        .navigationBarTitleDisplayMode(.large)
        .alert("Delete Item?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    await appState.deleteItem(item)
                    dismiss()
                }
            }
        } message: {
            Text("This action cannot be undone.")
        }
        .sheet(isPresented: $showingEditSheet) {
            EditItemView(item: item)
        }
        .sheet(isPresented: $showingPhotoGallery) {
            PhotoGalleryView(item: item)
        }
    }
}

// MARK: - Item Header

struct ItemHeader: View {
    let item: InventoryItem

    var body: some View {
        HStack(spacing: 16) {
            // Category icon
            Image(systemName: item.digitalTwin.objectType.iconName)
                .font(.system(size: 60))
                .foregroundStyle(categoryColor)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.digitalTwin.displayName)
                    .font(.title)
                    .fontWeight(.bold)

                Text(item.digitalTwin.objectType.displayName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("Added \(item.createdAt, style: .date)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    private var categoryColor: Color {
        switch item.digitalTwin.objectType {
        case .book: return .blue
        case .food: return .green
        case .furniture: return .brown
        case .electronics: return .purple
        case .clothing: return .pink
        case .games: return .red
        case .tools: return .orange
        case .plants: return .mint
        case .unknown: return .gray
        }
    }
}

// MARK: - Book Details

struct BookDetails: View {
    let book: BookTwin

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Book Details")
                .font(.headline)

            DetailRow(label: "Author", value: book.author)

            if let publisher = book.publisher {
                DetailRow(label: "Publisher", value: publisher)
            }

            if let publishDate = book.publishDate {
                DetailRow(label: "Published", value: publishDate)
            }

            if let pageCount = book.pageCount {
                DetailRow(label: "Pages", value: "\(pageCount)")
            }

            if let isbn = book.isbn {
                DetailRow(label: "ISBN", value: isbn)
            }

            if let rating = book.averageRating, let count = book.ratingsCount {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text(String(format: "%.1f", rating))
                    Text("(\(count) ratings)")
                        .foregroundStyle(.secondary)
                }
            }

            Text("Reading Status: \(book.readingStatus.displayName)")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

// MARK: - Purchase Info

struct PurchaseInfoSection: View {
    let item: InventoryItem

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Purchase Information")
                .font(.headline)

            if let date = item.purchaseDate {
                DetailRow(label: "Purchase Date", value: date.formatted(date: .long, time: .omitted))
            }

            if let price = item.purchasePrice {
                DetailRow(label: "Purchase Price", value: formatCurrency(price))
            }

            if let store = item.purchaseStore {
                DetailRow(label: "Store", value: store)
            }

            DetailRow(label: "Condition", value: item.condition.displayName)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }

    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: value as NSDecimalNumber) ?? "$0"
    }
}

// MARK: - Location Section

struct LocationSection: View {
    let location: String
    let specificLocation: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Location")
                .font(.headline)

            DetailRow(label: "Room/Area", value: location)

            if let specific = specificLocation {
                DetailRow(label: "Specific Location", value: specific)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

// MARK: - Notes Section

struct NotesSection: View {
    let notes: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes")
                .font(.headline)

            Text(notes)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

// MARK: - Actions Section

struct ActionsSection: View {
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Button(action: onEdit) {
                Label("Edit Item", systemImage: "pencil")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Button(role: .destructive, action: onDelete) {
                Label("Delete Item", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }
}

// MARK: - Photo Section

struct PhotoSection: View {
    let item: InventoryItem
    let onViewGallery: () -> Void
    @Environment(AppState.self) private var appState

    @State private var previewImages: [UIImage] = []
    @State private var isLoading = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Photos")
                    .font(.headline)

                Spacer()

                if let count = item.photosPaths?.count, count > 0 {
                    Text("\(count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                }
            }

            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else if previewImages.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)

                    Text("No photos yet")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(previewImages.prefix(5).enumerated()), id: \.offset) { _, image in
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }

                        if let count = item.photosPaths?.count, count > 5 {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 100, height: 100)

                                Text("+\(count - 5)")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
            }

            Button(action: onViewGallery) {
                Label(
                    previewImages.isEmpty ? "Add Photos" : "View Gallery",
                    systemImage: previewImages.isEmpty ? "plus.circle" : "photo.stack"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .task {
            await loadPreviewImages()
        }
    }

    private func loadPreviewImages() async {
        guard let photoPaths = item.photosPaths, !photoPaths.isEmpty else {
            return
        }

        isLoading = true
        defer { isLoading = false }

        var images: [UIImage] = []

        // Load up to 5 preview images
        for path in photoPaths.prefix(5) {
            if let image = try? await appState.dependencies.photoService.loadPhoto(path: path) {
                images.append(image)
            }
        }

        previewImages = images
    }
}

// MARK: - Detail Row

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
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

    let sampleItem = InventoryItem(
        digitalTwin: sampleBook
    )

    return NavigationStack {
        ItemDetailView(item: sampleItem)
            .environment(AppState(dependencies: AppDependencies()))
    }
}
