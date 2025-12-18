//
//  RecommendationsView.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import SwiftUI

struct RecommendationsView: View {
    @StateObject private var viewModel = RecommendationsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    headerSection

                    // Quick Generate
                    quickGenerateSection

                    // Generated Outfits
                    if !viewModel.generatedOutfits.isEmpty {
                        generatedOutfitsSection
                    }

                    // Style Insights
                    styleInsightsSection
                }
                .padding()
            }
            .navigationTitle("AI Recommendations")
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
                await viewModel.loadData()
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("AI-Powered Suggestions")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Let AI help you create perfect outfit combinations")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Quick Generate Section
    private var quickGenerateSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Generate")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(OccasionType.allCases.prefix(6), id: \.self) { occasion in
                    Button {
                        Task {
                            await viewModel.generateOutfits(for: occasion)
                        }
                    } label: {
                        OccasionButton(occasion: occasion)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Generated Outfits Section
    private var generatedOutfitsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Generated Outfits")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Text("\(viewModel.generatedOutfits.count) suggestions")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ForEach(Array(viewModel.generatedOutfits.enumerated()), id: \.element.0.id) { index, generated in
                GeneratedOutfitCard(
                    outfit: generated,
                    rank: index + 1,
                    onSave: {
                        Task {
                            await viewModel.saveOutfit(generated)
                        }
                    }
                )
            }
        }
    }

    // MARK: - Style Insights Section
    private var styleInsightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Style Insights")
                .font(.headline)

            if let insights = viewModel.styleInsights {
                VStack(spacing: 12) {
                    InsightCard(
                        icon: "paintpalette.fill",
                        title: "Most Worn Colors",
                        value: insights.topColors.joined(separator: ", ")
                    )

                    InsightCard(
                        icon: "star.fill",
                        title: "Style Profile",
                        value: insights.primaryStyle
                    )

                    InsightCard(
                        icon: "chart.bar.fill",
                        title: "Wardrobe Balance",
                        value: "\(insights.topsCount) tops, \(insights.bottomsCount) bottoms"
                    )
                }
            }
        }
    }

    // MARK: - Loading Overlay
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)

                Text("Generating outfits...")
                    .foregroundStyle(.white)
                    .font(.headline)
            }
        }
    }
}

// MARK: - Occasion Button
struct OccasionButton: View {
    let occasion: OccasionType

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: iconFor(occasion))
                .font(.largeTitle)
                .foregroundStyle(.blue)

            Text(occasion.displayName)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func iconFor(_ occasion: OccasionType) -> String {
        switch occasion {
        case .work, .workPresentation, .workCasual: return "briefcase.fill"
        case .casual: return "figure.walk"
        case .dateNight: return "heart.fill"
        case .party, .wedding, .formalEvent: return "party.popper.fill"
        case .athletic, .gym: return "figure.run"
        case .outdoor: return "tree.fill"
        case .travel: return "airplane"
        case .brunch: return "cup.and.saucer.fill"
        default: return "sparkles"
        }
    }
}

// MARK: - Generated Outfit Card
struct GeneratedOutfitCard: View {
    let outfit: (generated: GeneratedOutfit, saved: Bool)
    let rank: Int
    let onSave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Rank badge
                ZStack {
                    Circle()
                        .fill(.blue.gradient)
                        .frame(width: 32, height: 32)

                    Text("#\(rank)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("AI Generated Outfit")
                        .font(.headline)

                    HStack(spacing: 4) {
                        ForEach(0..<5) { index in
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundStyle(index < Int(outfit.generated.confidenceScore * 5) ? .yellow : .gray.opacity(0.3))
                        }

                        Text(String(format: "%.0f%% match", outfit.generated.confidenceScore * 100))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                if !outfit.saved {
                    Button {
                        onSave()
                    } label: {
                        Label("Save", systemImage: "heart")
                            .font(.subheadline)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }

            // Items preview
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(outfit.generated.items) { item in
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: item.primaryColor) ?? .blue)
                                .frame(width: 80, height: 100)

                            Text(item.category.displayName)
                                .font(.caption2)
                                .lineLimit(1)
                        }
                    }
                }
            }

            // Reasoning
            Text(outfit.generated.reasoning)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Insight Card
struct InsightCard: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
            }

            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Recommendations ViewModel
@MainActor
class RecommendationsViewModel: ObservableObject {
    @Published var generatedOutfits: [(generated: GeneratedOutfit, saved: Bool)] = []
    @Published var styleInsights: StyleInsights?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let outfitGenerator = OutfitGenerationService.shared
    private let styleMatching = StyleMatchingService.shared
    private let wardrobeRepository: WardrobeRepository
    private let outfitRepository: OutfitRepository
    private let profileRepository: UserProfileRepository

    init(
        wardrobeRepository: WardrobeRepository = CoreDataWardrobeRepository.shared,
        outfitRepository: OutfitRepository = CoreDataOutfitRepository.shared,
        profileRepository: UserProfileRepository = CoreDataUserProfileRepository.shared
    ) {
        self.wardrobeRepository = wardrobeRepository
        self.outfitRepository = outfitRepository
        self.profileRepository = profileRepository
    }

    func loadData() async {
        await loadStyleInsights()
    }

    func generateOutfits(for occasion: OccasionType) async {
        isLoading = true
        errorMessage = nil

        do {
            let outfits = try await outfitGenerator.generateOutfits(for: occasion, limit: 5)
            generatedOutfits = outfits.map { ($0, false) }
            isLoading = false
        } catch {
            errorMessage = "Failed to generate outfits: \(error.localizedDescription)"
            isLoading = false
        }
    }

    func saveOutfit(_ generated: GeneratedOutfit) async {
        do {
            let outfit = generated.toOutfit()
            _ = try await outfitRepository.create(outfit)

            // Mark as saved
            if let index = generatedOutfits.firstIndex(where: { $0.generated.items == generated.items }) {
                generatedOutfits[index].saved = true
            }
        } catch {
            errorMessage = "Failed to save outfit: \(error.localizedDescription)"
        }
    }

    private func loadStyleInsights() async {
        do {
            let items = try await wardrobeRepository.fetchAll()
            let profile = try await profileRepository.fetch()

            // Analyze wardrobe
            let colorCounts = Dictionary(grouping: items, by: { $0.primaryColor })
                .mapValues { $0.count }
                .sorted { $0.value > $1.value }

            let topColors = colorCounts.prefix(3).map { $0.key }

            let topsCount = items.filter { $0.category.isTop }.count
            let bottomsCount = items.filter { $0.category.isBottom }.count

            styleInsights = StyleInsights(
                topColors: topColors,
                primaryStyle: profile.primaryStyle.rawValue.capitalized,
                topsCount: topsCount,
                bottomsCount: bottomsCount
            )
        } catch {
            errorMessage = "Failed to load insights: \(error.localizedDescription)"
        }
    }
}

// MARK: - Supporting Types
struct StyleInsights {
    let topColors: [String]
    let primaryStyle: String
    let topsCount: Int
    let bottomsCount: Int
}

// MARK: - Preview
#Preview {
    RecommendationsView()
}
