//
//  HomeView.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var appCoordinator: AppCoordinator

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    // Welcome Header
                    welcomeHeader

                    // Wardrobe Stats
                    if let stats = viewModel.wardrobeStats {
                        statsSection(stats: stats)
                    }

                    // Outfit Suggestions
                    if !viewModel.suggestedOutfits.isEmpty {
                        outfitSuggestionsSection
                    }

                    // Recent Items
                    if !viewModel.recentItems.isEmpty {
                        recentItemsSection
                    }

                    // Favorite Items
                    if !viewModel.favoriteItems.isEmpty {
                        favoriteItemsSection
                    }
                }
                .padding()
            }
            .navigationTitle("Wardrobe Consultant")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    refreshButton
                }
            }
            .overlay {
                if viewModel.isLoading {
                    loadingOverlay
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .task {
                await viewModel.loadDashboardData()
            }
        }
    }

    // MARK: - Welcome Header
    private var welcomeHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome Back")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Your personalized style assistant")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Stats Section
    private func statsSection(stats: WardrobeStats) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Wardrobe")
                .font(.title2)
                .fontWeight(.semibold)

            HStack(spacing: 20) {
                StatCard(
                    title: "Items",
                    value: "\(stats.totalItems)",
                    icon: "tshirt.fill"
                )

                StatCard(
                    title: "Outfits",
                    value: "\(stats.totalOutfits)",
                    icon: "sparkles"
                )

                if let mostWorn = stats.mostWornItem {
                    StatCard(
                        title: "Most Worn",
                        value: "\(mostWorn.timesWorn)x",
                        icon: "star.fill"
                    )
                }
            }
        }
    }

    // MARK: - Outfit Suggestions Section
    private var outfitSuggestionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Outfit Suggestions")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                NavigationLink {
                    OutfitListView()
                } label: {
                    Text("See All")
                        .font(.subheadline)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.suggestedOutfits) { outfit in
                        NavigationLink {
                            OutfitDetailView(outfit: outfit)
                        } label: {
                            OutfitCard(outfit: outfit)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Recent Items Section
    private var recentItemsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recently Added")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                NavigationLink {
                    WardrobeView()
                } label: {
                    Text("See All")
                        .font(.subheadline)
                }
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(viewModel.recentItems) { item in
                    NavigationLink {
                        ItemDetailView(item: item)
                    } label: {
                        WardrobeItemCard(item: item)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Favorite Items Section
    private var favoriteItemsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Favorites")
                .font(.title2)
                .fontWeight(.semibold)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.favoriteItems.prefix(6)) { item in
                        NavigationLink {
                            ItemDetailView(item: item)
                        } label: {
                            WardrobeItemCard(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Refresh Button
    private var refreshButton: some View {
        Button {
            Task {
                await viewModel.refresh()
            }
        } label: {
            Image(systemName: "arrow.clockwise")
        }
        .disabled(viewModel.isLoading)
    }

    // MARK: - Loading Overlay
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)

            Text(value)
                .font(.title)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Outfit Card
struct OutfitCard: View {
    let outfit: Outfit

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(.blue.gradient)
                .frame(width: 200, height: 150)
                .overlay {
                    Image(systemName: "sparkles")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(outfit.name ?? "Untitled Outfit")
                    .font(.headline)
                    .lineLimit(1)

                HStack {
                    Image(systemName: occasionIcon(for: outfit.occasionType))
                        .font(.caption)

                    Text(outfit.occasionType.rawValue.capitalized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(width: 200)
    }

    private func occasionIcon(for occasion: OccasionType) -> String {
        switch occasion {
        case .casual: return "figure.walk"
        case .work: return "briefcase.fill"
        case .formal: return "suit.fill"
        case .party: return "party.popper.fill"
        case .workout: return "figure.run"
        case .dateNight: return "heart.fill"
        case .travel: return "airplane"
        case .outdoor: return "tree.fill"
        }
    }
}

// MARK: - Wardrobe Item Card
struct WardrobeItemCard: View {
    let item: WardrobeItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Item Photo Placeholder
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: item.primaryColor) ?? .blue)
                .aspectRatio(3/4, contentMode: .fit)
                .overlay {
                    if item.isFavorite {
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "heart.fill")
                                    .foregroundStyle(.red)
                                    .padding(8)
                            }
                            Spacer()
                        }
                    }
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.category.rawValue.capitalized)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let brand = item.brand {
                    Text(brand)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                }
            }
        }
    }
}

// MARK: - Color Extension
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview
#Preview {
    HomeView()
        .environmentObject(AppCoordinator())
}
