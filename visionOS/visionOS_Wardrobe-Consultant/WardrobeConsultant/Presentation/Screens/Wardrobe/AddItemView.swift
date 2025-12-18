//
//  AddItemView.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import SwiftUI
import PhotosUI

struct AddItemView: View {
    @StateObject private var viewModel = AddItemViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            Form {
                // Photo Section
                photoSection

                // Basic Info
                Section("Basic Information") {
                    Picker("Category", selection: $viewModel.category) {
                        ForEach(ClothingCategory.allCases, id: \.self) { category in
                            Text(category.rawValue.capitalized).tag(category)
                        }
                    }

                    TextField("Brand", text: $viewModel.brand)

                    TextField("Size", text: $viewModel.size)
                }

                // Colors
                Section("Colors") {
                    ColorPicker("Primary Color", selection: $viewModel.primaryColor)

                    Toggle("Add Secondary Color", isOn: $viewModel.useSecondaryColor)

                    if viewModel.useSecondaryColor {
                        ColorPicker("Secondary Color", selection: Binding(
                            get: { viewModel.secondaryColor ?? .gray },
                            set: { viewModel.secondaryColor = $0 }
                        ))
                    }
                }

                // Material & Pattern
                Section("Material & Pattern") {
                    Picker("Fabric Type", selection: $viewModel.fabricType) {
                        ForEach(FabricType.allCases, id: \.self) { fabric in
                            Text(fabric.rawValue.capitalized).tag(fabric)
                        }
                    }

                    Picker("Pattern", selection: $viewModel.pattern) {
                        ForEach(ClothingPattern.allCases, id: \.self) { pattern in
                            Text(pattern.rawValue.capitalized).tag(pattern)
                        }
                    }
                }

                // Seasons
                Section("Suitable Seasons") {
                    ForEach(Season.allCases, id: \.self) { season in
                        Toggle(season.rawValue.capitalized, isOn: Binding(
                            get: { viewModel.selectedSeasons.contains(season) },
                            set: { isSelected in
                                if isSelected {
                                    viewModel.selectedSeasons.insert(season)
                                } else {
                                    viewModel.selectedSeasons.remove(season)
                                }
                            }
                        ))
                    }
                }

                // Occasions
                Section("Suitable Occasions") {
                    ForEach(OccasionType.allCases, id: \.self) { occasion in
                        Toggle(occasion.rawValue.capitalized, isOn: Binding(
                            get: { viewModel.selectedOccasions.contains(occasion) },
                            set: { isSelected in
                                if isSelected {
                                    viewModel.selectedOccasions.insert(occasion)
                                } else {
                                    viewModel.selectedOccasions.remove(occasion)
                                }
                            }
                        ))
                    }
                }

                // Purchase Info
                Section("Purchase Information") {
                    DatePicker("Purchase Date", selection: $viewModel.purchaseDate, displayedComponents: .date)

                    TextField("Purchase Price", text: $viewModel.purchasePrice)
                        .keyboardType(.decimalPad)

                    TextField("Retailer", text: $viewModel.retailer)

                    Picker("Condition", selection: $viewModel.condition) {
                        ForEach(ItemCondition.allCases, id: \.self) { condition in
                            Text(condition.rawValue.capitalized).tag(condition)
                        }
                    }
                }

                // Additional Info
                Section("Additional Information") {
                    TextField("Care Instructions", text: $viewModel.careInstructions, axis: .vertical)
                        .lineLimit(3...6)

                    TextField("Notes", text: $viewModel.notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            if await viewModel.saveItem() {
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.isLoading)
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
            .overlay {
                if viewModel.isLoading {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()

                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                    }
                }
            }
        }
    }

    // MARK: - Photo Section
    private var photoSection: some View {
        Section("Photo") {
            if let image = viewModel.capturedImage {
                VStack(spacing: 12) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    Button(role: .destructive) {
                        viewModel.clearPhoto()
                    } label: {
                        Label("Remove Photo", systemImage: "trash")
                    }
                }
            } else {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Label("Add Photo", systemImage: "camera")
                        .frame(maxWidth: .infinity)
                }
                .onChange(of: selectedPhotoItem) { _, newValue in
                    Task {
                        if let data = try? await newValue?.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            viewModel.capturedImage = image
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    AddItemView()
}
