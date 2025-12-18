//
//  PropertyBrowserView.swift
//  RealEstateSpatial
//
//  Main property browsing interface
//

import SwiftUI
import SwiftData

struct PropertyBrowserView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow

    @Query(sort: \Property.metadata.listedDate, order: .reverse)
    private var properties: [Property]

    @State private var searchText: String = ""
    @State private var showFilters: Bool = true
    @State private var selectedPropertyType: PropertyType?
    @State private var priceRange: ClosedRange<Double> = 0...5_000_000
    @State private var bedroomCount: Int = 0

    private let gridColumns = [
        GridItem(.adaptive(minimum: 280, maximum: 320), spacing: 20)
    ]

    var body: some View {
        NavigationStack {
            HStack(spacing: 0) {
                // Filter Sidebar
                if showFilters {
                    filterSidebar
                        .frame(width: 240)
                        .background(.ultraThinMaterial)
                }

                // Main Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Header
                        headerView

                        // Property Grid
                        LazyVGrid(columns: gridColumns, spacing: 20) {
                            ForEach(filteredProperties) { property in
                                PropertyCard(
                                    property: property,
                                    isFavorite: false,
                                    onTap: {
                                        openPropertyDetail(property)
                                    },
                                    onFavorite: {
                                        toggleFavorite(property)
                                    },
                                    onTour: {
                                        startTour(property)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Properties")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showFilters.toggle() }) {
                        Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button(action: loadSampleData) {
                        Label("Load Samples", systemImage: "arrow.clockwise")
                    }
                }
            }
        }
    }

    // MARK: - Views

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(filteredProperties.count) Properties")
                .font(.title2)
                .fontWeight(.bold)

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("Search by address, city, or ZIP", text: $searchText)
                    .textFieldStyle(.roundedBorder)

                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }

    private var filterSidebar: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Filters")
                    .font(.title3)
                    .fontWeight(.bold)

                Divider()

                // Property Type Filter
                VStack(alignment: .leading, spacing: 8) {
                    Text("Property Type")
                        .font(.headline)

                    ForEach(PropertyType.allCases, id: \.self) { type in
                        Button(action: {
                            selectedPropertyType = selectedPropertyType == type ? nil : type
                        }) {
                            HStack {
                                Image(systemName: selectedPropertyType == type ? "checkmark.circle.fill" : "circle")
                                Text(type.rawValue)
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(selectedPropertyType == type ? .blue : .primary)
                    }
                }

                Divider()

                // Price Range
                VStack(alignment: .leading, spacing: 8) {
                    Text("Price Range")
                        .font(.headline)

                    VStack(alignment: .leading) {
                        Text("\(Int(priceRange.lowerBound), format: .currency(code: "USD")) - \(Int(priceRange.upperBound), format: .currency(code: "USD"))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        // Price sliders would go here in real implementation
                        // For now, showing static range
                    }
                }

                Divider()

                // Bedrooms
                VStack(alignment: .leading, spacing: 8) {
                    Text("Bedrooms")
                        .font(.headline)

                    HStack {
                        ForEach(0..<6) { count in
                            Button(action: {
                                bedroomCount = bedroomCount == count ? 0 : count
                            }) {
                                Text(count == 0 ? "Any" : "\(count)+")
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(bedroomCount == count ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundStyle(bedroomCount == count ? .white : .primary)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Divider()

                // Clear Filters
                Button(action: clearFilters) {
                    Text("Clear All Filters")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
    }

    // MARK: - Computed Properties

    private var filteredProperties: [Property] {
        properties.filter { property in
            var matches = true

            // Search text
            if !searchText.isEmpty {
                let searchLower = searchText.lowercased()
                matches = matches && (
                    property.address.street.lowercased().contains(searchLower) ||
                    property.address.city.lowercased().contains(searchLower) ||
                    property.address.zipCode.contains(searchText)
                )
            }

            // Property type
            if let selectedType = selectedPropertyType {
                matches = matches && property.specifications.propertyType == selectedType
            }

            // Bedrooms
            if bedroomCount > 0 {
                matches = matches && property.specifications.bedrooms >= bedroomCount
            }

            return matches
        }
    }

    // MARK: - Actions

    private func openPropertyDetail(_ property: Property) {
        appModel.selectedProperty = property
        openWindow(id: "property-detail", value: property.id)
    }

    private func toggleFavorite(_ property: Property) {
        // Toggle favorite logic
        print("Toggle favorite for property: \(property.id)")
    }

    private func startTour(_ property: Property) {
        // Start immersive tour
        appModel.selectedProperty = property
        openWindow(id: "property-tour", value: property.id)
    }

    private func clearFilters() {
        selectedPropertyType = nil
        bedroomCount = 0
        searchText = ""
    }

    private func loadSampleData() {
        Task {
            await generateSampleProperties()
        }
    }

    private func generateSampleProperties() async {
        let sampleProperties = [
            Property(
                mlsNumber: "MLS001",
                address: PropertyAddress(
                    street: "123 Market Street",
                    city: "San Francisco",
                    state: "CA",
                    zipCode: "94102",
                    coordinates: GeographicCoordinate(latitude: 37.7749, longitude: -122.4194)
                ),
                pricing: PricingInfo(
                    listPrice: 1_200_000,
                    pricePerSqFt: 500
                ),
                specifications: PropertySpecs(
                    bedrooms: 3,
                    bathrooms: 2.5,
                    squareFeet: 2400,
                    yearBuilt: 2020,
                    propertyType: .singleFamily,
                    features: ["Hardwood floors", "Granite counters", "Central AC"]
                )
            ),
            Property(
                mlsNumber: "MLS002",
                address: PropertyAddress(
                    street: "456 Oak Avenue",
                    city: "Oakland",
                    state: "CA",
                    zipCode: "94607",
                    coordinates: GeographicCoordinate(latitude: 37.8044, longitude: -122.2712)
                ),
                pricing: PricingInfo(
                    listPrice: 850_000,
                    pricePerSqFt: 425
                ),
                specifications: PropertySpecs(
                    bedrooms: 2,
                    bathrooms: 2.0,
                    squareFeet: 2000,
                    yearBuilt: 2018,
                    propertyType: .condo,
                    features: ["Bay views", "Modern kitchen", "Parking included"]
                )
            ),
            Property(
                mlsNumber: "MLS003",
                address: PropertyAddress(
                    street: "789 Pine Street",
                    city: "San Francisco",
                    state: "CA",
                    zipCode: "94109",
                    coordinates: GeographicCoordinate(latitude: 37.7899, longitude: -122.4142)
                ),
                pricing: PricingInfo(
                    listPrice: 2_500_000,
                    pricePerSqFt: 625
                ),
                specifications: PropertySpecs(
                    bedrooms: 4,
                    bathrooms: 3.5,
                    squareFeet: 4000,
                    yearBuilt: 2022,
                    propertyType: .singleFamily,
                    features: ["Gourmet kitchen", "Spa bathroom", "Smart home", "Roof deck"]
                )
            )
        ]

        for property in sampleProperties {
            modelContext.insert(property)
        }

        try? modelContext.save()
    }
}

// MARK: - Preview

#Preview {
    PropertyBrowserView()
        .environment(AppModel())
        .modelContainer(for: [Property.self, Room.self, User.self])
        .frame(width: 1200, height: 800)
}
