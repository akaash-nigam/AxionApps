//
//  UserProfileView.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import SwiftUI

struct UserProfileView: View {
    @StateObject private var viewModel = UserProfileViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                // Size Preferences
                Section("Size Preferences") {
                    TextField("Top Size", text: $viewModel.topSize)
                    TextField("Bottom Size", text: $viewModel.bottomSize)
                    TextField("Dress Size", text: $viewModel.dressSize)
                    TextField("Shoe Size", text: $viewModel.shoeSize)

                    Picker("Fit Preference", selection: $viewModel.fitPreference) {
                        ForEach(FitPreference.allCases, id: \.self) { fit in
                            Text(fit.rawValue.capitalized).tag(fit)
                        }
                    }
                }

                // Style Profile
                Section("Style Profile") {
                    Picker("Primary Style", selection: $viewModel.primaryStyle) {
                        ForEach(StyleProfile.allCases, id: \.self) { style in
                            Text(style.rawValue.capitalized).tag(style)
                        }
                    }

                    Picker("Secondary Style", selection: $viewModel.secondaryStyle) {
                        Text("None").tag(nil as StyleProfile?)
                        ForEach(StyleProfile.allCases, id: \.self) { style in
                            Text(style.rawValue.capitalized).tag(style as StyleProfile?)
                        }
                    }
                }

                // Colors
                Section("Color Preferences") {
                    NavigationLink {
                        ColorPreferencesView(
                            favoriteColors: $viewModel.favoriteColors,
                            avoidColors: $viewModel.avoidColors
                        )
                    } label: {
                        HStack {
                            Text("Favorite Colors")
                            Spacer()
                            Text("\(viewModel.favoriteColors.count)")
                                .foregroundStyle(.secondary)
                        }
                    }

                    NavigationLink {
                        ColorPreferencesView(
                            favoriteColors: Binding.constant([]),
                            avoidColors: $viewModel.avoidColors,
                            isAvoidMode: true
                        )
                    } label: {
                        HStack {
                            Text("Colors to Avoid")
                            Spacer()
                            Text("\(viewModel.avoidColors.count)")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // Preferences
                Section("Preferences") {
                    Picker("Comfort Level", selection: $viewModel.comfortLevel) {
                        ForEach(ComfortLevel.allCases, id: \.self) { level in
                            Text(level.rawValue.capitalized).tag(level)
                        }
                    }

                    Picker("Budget Range", selection: $viewModel.budgetRange) {
                        ForEach(BudgetRange.allCases, id: \.self) { range in
                            Text(range.rawValue.capitalized).tag(range)
                        }
                    }

                    Toggle("Sustainability Preference", isOn: $viewModel.sustainabilityPreference)
                }

                // Body Measurements
                Section("Body Measurements") {
                    NavigationLink {
                        BodyMeasurementsView()
                    } label: {
                        HStack {
                            Label("Manage Measurements", systemImage: "ruler.fill")
                            Spacer()
                            if viewModel.hasMeasurements {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                }
            }
            .navigationTitle("User Profile")
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
                            if await viewModel.saveProfile() {
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.isSaving)
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
                await viewModel.loadProfile()
            }
        }
    }
}

// MARK: - User Profile ViewModel
@MainActor
class UserProfileViewModel: ObservableObject {
    @Published var topSize = ""
    @Published var bottomSize = ""
    @Published var dressSize = ""
    @Published var shoeSize = ""
    @Published var fitPreference: FitPreference = .regular
    @Published var primaryStyle: StyleProfile = .casual
    @Published var secondaryStyle: StyleProfile? = nil
    @Published var favoriteColors: [String] = []
    @Published var avoidColors: [String] = []
    @Published var comfortLevel: ComfortLevel = .moderate
    @Published var budgetRange: BudgetRange = .medium
    @Published var sustainabilityPreference = false
    @Published var hasMeasurements = false
    @Published var isSaving = false
    @Published var errorMessage: String?

    private let repository: UserProfileRepository

    init(repository: UserProfileRepository = CoreDataUserProfileRepository.shared) {
        self.repository = repository
    }

    func loadProfile() async {
        do {
            let profile = try await repository.fetch()

            topSize = profile.topSize ?? ""
            bottomSize = profile.bottomSize ?? ""
            dressSize = profile.dressSize ?? ""
            shoeSize = profile.shoeSize ?? ""
            fitPreference = profile.fitPreference ?? .regular
            primaryStyle = profile.primaryStyle
            secondaryStyle = profile.secondaryStyle
            favoriteColors = profile.favoriteColors
            avoidColors = profile.avoidColors
            comfortLevel = profile.comfortLevel ?? .moderate
            budgetRange = profile.budgetRange ?? .medium
            sustainabilityPreference = profile.sustainabilityPreference

            let measurements = try await repository.getBodyMeasurements()
            hasMeasurements = measurements != nil
        } catch {
            errorMessage = "Failed to load profile: \(error.localizedDescription)"
        }
    }

    func saveProfile() async -> Bool {
        isSaving = true
        errorMessage = nil

        do {
            var profile = try await repository.fetch()

            profile.topSize = topSize.isEmpty ? nil : topSize
            profile.bottomSize = bottomSize.isEmpty ? nil : bottomSize
            profile.dressSize = dressSize.isEmpty ? nil : dressSize
            profile.shoeSize = shoeSize.isEmpty ? nil : shoeSize
            profile.fitPreference = fitPreference
            profile.primaryStyle = primaryStyle
            profile.secondaryStyle = secondaryStyle
            profile.favoriteColors = favoriteColors
            profile.avoidColors = avoidColors
            profile.comfortLevel = comfortLevel
            profile.budgetRange = budgetRange
            profile.sustainabilityPreference = sustainabilityPreference

            try await repository.update(profile)
            isSaving = false
            return true
        } catch {
            errorMessage = "Failed to save profile: \(error.localizedDescription)"
            isSaving = false
            return false
        }
    }
}

// MARK: - Color Preferences View
struct ColorPreferencesView: View {
    @Binding var favoriteColors: [String]
    @Binding var avoidColors: [String]
    var isAvoidMode: Bool = false

    @State private var selectedColor: Color = .blue

    private let title: String

    init(favoriteColors: Binding<[String]>, avoidColors: Binding<[String]>, isAvoidMode: Bool = false) {
        self._favoriteColors = favoriteColors
        self._avoidColors = avoidColors
        self.isAvoidMode = isAvoidMode
        self.title = isAvoidMode ? "Colors to Avoid" : "Favorite Colors"
    }

    private var colors: Binding<[String]> {
        isAvoidMode ? $avoidColors : $favoriteColors
    }

    var body: some View {
        Form {
            Section("Add Color") {
                ColorPicker("Select Color", selection: $selectedColor)

                Button("Add Color") {
                    let hexColor = selectedColor.toHex()
                    if !colors.wrappedValue.contains(hexColor) {
                        colors.wrappedValue.append(hexColor)
                    }
                }
            }

            Section("\(title) (\(colors.wrappedValue.count))") {
                ForEach(colors.wrappedValue, id: \.self) { hexColor in
                    HStack {
                        Circle()
                            .fill(Color(hex: hexColor) ?? .gray)
                            .frame(width: 30, height: 30)

                        Text(hexColor)
                            .font(.system(.body, design: .monospaced))

                        Spacer()

                        Button(role: .destructive) {
                            colors.wrappedValue.removeAll { $0 == hexColor }
                        } label: {
                            Image(systemName: "trash")
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Body Measurements View
struct BodyMeasurementsView: View {
    @StateObject private var viewModel = BodyMeasurementsViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("Unit System") {
                Picker("Units", selection: $viewModel.unitSystem) {
                    Text("Metric (cm, kg)").tag(UnitSystem.metric)
                    Text("Imperial (in, lbs)").tag(UnitSystem.imperial)
                }
            }

            Section("Measurements") {
                TextField("Height", text: $viewModel.height)
                    .keyboardType(.decimalPad)

                TextField("Weight", text: $viewModel.weight)
                    .keyboardType(.decimalPad)

                TextField("Chest", text: $viewModel.chest)
                    .keyboardType(.decimalPad)

                TextField("Waist", text: $viewModel.waist)
                    .keyboardType(.decimalPad)

                TextField("Hips", text: $viewModel.hips)
                    .keyboardType(.decimalPad)

                TextField("Inseam", text: $viewModel.inseam)
                    .keyboardType(.decimalPad)
            }

            Section {
                Text("These measurements are encrypted and stored securely in your device's Keychain.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Body Measurements")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task {
                        if await viewModel.saveMeasurements() {
                            dismiss()
                        }
                    }
                }
                .disabled(viewModel.isSaving)
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
            await viewModel.loadMeasurements()
        }
    }
}

// MARK: - Body Measurements ViewModel
@MainActor
class BodyMeasurementsViewModel: ObservableObject {
    @Published var unitSystem: UnitSystem = .metric
    @Published var height = ""
    @Published var weight = ""
    @Published var chest = ""
    @Published var waist = ""
    @Published var hips = ""
    @Published var inseam = ""
    @Published var isSaving = false
    @Published var errorMessage: String?

    private let repository: UserProfileRepository

    init(repository: UserProfileRepository = CoreDataUserProfileRepository.shared) {
        self.repository = repository
    }

    func loadMeasurements() async {
        do {
            if let measurements = try await repository.getBodyMeasurements() {
                unitSystem = measurements.unitSystem
                height = String(describing: measurements.height)
                weight = measurements.weight.map { String(describing: $0) } ?? ""
                chest = measurements.chest.map { String(describing: $0) } ?? ""
                waist = measurements.waist.map { String(describing: $0) } ?? ""
                hips = measurements.hips.map { String(describing: $0) } ?? ""
                inseam = measurements.inseam.map { String(describing: $0) } ?? ""
            }
        } catch {
            errorMessage = "Failed to load measurements: \(error.localizedDescription)"
        }
    }

    func saveMeasurements() async -> Bool {
        guard let heightValue = Decimal(string: height) else {
            errorMessage = "Please enter a valid height"
            return false
        }

        isSaving = true

        do {
            let measurements = BodyMeasurements(
                height: heightValue,
                weight: Decimal(string: weight),
                chest: Decimal(string: chest),
                waist: Decimal(string: waist),
                hips: Decimal(string: hips),
                inseam: Decimal(string: inseam),
                shoulder: nil,
                neck: nil,
                sleeveLength: nil,
                unitSystem: unitSystem
            )

            try await repository.saveBodyMeasurements(measurements)
            isSaving = false
            return true
        } catch {
            errorMessage = "Failed to save measurements: \(error.localizedDescription)"
            isSaving = false
            return false
        }
    }
}

// MARK: - Preview
#Preview {
    UserProfileView()
}
