//
//  RecognitionView.swift
//  CultureArchitectureSystem
//
//  Created on 2025-01-20
//

import SwiftUI

struct RecognitionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppModel.self) private var appModel
    @State private var viewModel = RecognitionViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section("Who would you like to recognize?") {
                    TextField("Search team member...", text: $viewModel.searchText)
                        .textFieldStyle(.roundedBorder)

                    // Team member list (simplified for now)
                    Text("Team member selection coming soon")
                        .foregroundStyle(.secondary)
                }

                Section("Which value did they demonstrate?") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(ValueType.allCases, id: \.self) { valueType in
                                ValueSelectionButton(
                                    valueType: valueType,
                                    isSelected: viewModel.selectedValue == valueType,
                                    action: {
                                        viewModel.selectedValue = valueType
                                    }
                                )
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }

                Section("Share your story (optional)") {
                    TextEditor(text: $viewModel.message)
                        .frame(minHeight: 100)
                }

                Section("Visibility") {
                    Picker("Share with", selection: $viewModel.visibility) {
                        Text("Private").tag(RecognitionVisibility.private_)
                        Text("Team").tag(RecognitionVisibility.team)
                        Text("Organization").tag(RecognitionVisibility.organization)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Give Recognition")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Send") {
                        Task {
                            await viewModel.sendRecognition(service: appModel.recognitionService)
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.canSend)
                }
            }
        }
    }
}

// MARK: - Value Selection Button
struct ValueSelectionButton: View {
    let valueType: ValueType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: valueType.iconName)
                    .font(.system(size: 32))
                    .foregroundStyle(isSelected ? Color(hex: valueType.colorHex) : .secondary)

                Text(valueType.rawValue.capitalized)
                    .font(.caption)
                    .foregroundStyle(isSelected ? .primary : .secondary)
            }
            .frame(width: 80, height: 80)
            .background(isSelected ? Color(hex: valueType.colorHex).opacity(0.2) : Color.clear)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(hex: valueType.colorHex) : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - ValueType Extension
enum ValueType: String, CaseIterable {
    case innovation
    case collaboration
    case trust
    case transparency
    case purpose
    case growth

    var iconName: String {
        switch self {
        case .innovation: "lightbulb.fill"
        case .collaboration: "person.2.fill"
        case .trust: "shield.fill"
        case .transparency: "eye.fill"
        case .purpose: "target"
        case .growth: "chart.line.uptrend.xyaxis"
        }
    }

    var colorHex: String {
        switch self {
        case .innovation: "#8B5CF6"
        case .collaboration: "#3B82F6"
        case .trust: "#F59E0B"
        case .transparency: "#FFFFFF"
        case .purpose: "#FF6B35"
        case .growth: "#10B981"
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0

        if scanner.scanHexInt64(&hexNumber) {
            let r = Double((hexNumber & 0xff0000) >> 16) / 255
            let g = Double((hexNumber & 0x00ff00) >> 8) / 255
            let b = Double(hexNumber & 0x0000ff) / 255

            self.init(red: r, green: g, blue: b)
        } else {
            self.init(red: 0, green: 0, blue: 0)
        }
    }
}

#Preview {
    RecognitionView()
        .environment(AppModel())
}
