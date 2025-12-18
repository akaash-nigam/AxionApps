//
//  PropertyCard.swift
//  RealEstateSpatial
//
//  Property card component for list/grid display
//

import SwiftUI

struct PropertyCard: View {
    let property: Property
    var isFavorite: Bool = false
    var onTap: (() -> Void)?
    var onFavorite: (() -> Void)?
    var onTour: (() -> Void)?

    @State private var isHovered: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Property Image
            propertyImage

            // Property Information
            VStack(alignment: .leading, spacing: 8) {
                // Address
                Text(property.address.street)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                // Specifications
                HStack(spacing: 12) {
                    Label("\(property.specifications.bedrooms)", systemImage: "bed.double.fill")
                    Label("\(Int(property.specifications.bathrooms))", systemImage: "shower.fill")
                    Label("\(property.specifications.squareFeet)", systemImage: "square.fill")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                // Price
                Text(property.pricing.listPrice, format: .currency(code: "USD"))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)

                // Location
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(.blue)
                    Text("\(property.address.city), \(property.address.state)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Action Buttons
                HStack(spacing: 12) {
                    // Favorite Button
                    Button(action: { onFavorite?() }) {
                        Label(isFavorite ? "Saved" : "Save", systemImage: isFavorite ? "heart.fill" : "heart")
                            .font(.caption)
                            .foregroundStyle(isFavorite ? .red : .primary)
                    }
                    .buttonStyle(.bordered)

                    Spacer()

                    // Tour Button
                    Button(action: { onTour?() }) {
                        Label("Tour", systemImage: "eye.fill")
                            .font(.caption)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.top, 4)
            }
            .padding(12)
        }
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(isHovered ? 0.2 : 0.1), radius: isHovered ? 12 : 6)
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
        .onTapGesture {
            onTap?()
        }
        .hoverEffect()
        .onContinuousHover { phase in
            switch phase {
            case .active:
                isHovered = true
            case .ended:
                isHovered = false
            }
        }
    }

    private var propertyImage: some View {
        Group {
            if let firstPhoto = property.media.photos.first {
                AsyncImage(url: firstPhoto.url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(height: 200)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(16/9, contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                    case .failure:
                        placeholderImage
                    @unknown default:
                        placeholderImage
                    }
                }
            } else {
                placeholderImage
            }
        }
        .overlay(alignment: .topTrailing) {
            // Status Badge
            if property.metadata.status != .active {
                Text(property.metadata.status.rawValue)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(8)
            }
        }
    }

    private var placeholderImage: some View {
        ZStack {
            Rectangle()
                .fill(.gray.opacity(0.2))
                .frame(height: 200)

            Image(systemName: "house.fill")
                .font(.system(size: 48))
                .foregroundStyle(.gray.opacity(0.5))
        }
    }
}

// MARK: - Preview

#Preview("Property Card") {
    PropertyCard(property: .preview) {
        print("Card tapped")
    } onFavorite: {
        print("Favorite tapped")
    } onTour: {
        print("Tour tapped")
    }
    .frame(width: 300)
    .padding()
}

#Preview("Property Card - Favorite") {
    PropertyCard(property: .preview, isFavorite: true)
        .frame(width: 300)
        .padding()
}
