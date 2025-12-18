import SwiftUI
import SwiftData

struct IdeaCaptureView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var description: String = ""
    @State private var selectedCategory: IdeaCategory = .product
    @State private var priority: Int = 3
    @State private var tags: [String] = []
    @State private var newTag: String = ""
    @State private var isSubmitting = false
    @State private var showSuccessMessage = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Information") {
                    TextField("Idea Title", text: $title, prompt: Text("Enter a compelling title"))
                        .textFieldStyle(.roundedBorder)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)

                        TextEditor(text: $description)
                            .frame(minHeight: 120)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                            )
                    }
                }

                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(IdeaCategory.allCases, id: \\.self) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Priority") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Priority Level")
                            Spacer()
                            Text("\\(priority)/5")
                                .font(.headline)
                        }

                        HStack(spacing: 8) {
                            ForEach(1...5, id: \\.self) { level in
                                Image(systemName: level <= priority ? "star.fill" : "star")
                                    .foregroundStyle(level <= priority ? .yellow : .gray)
                                    .font(.title2)
                                    .onTapGesture {
                                        priority = level
                                    }
                            }
                        }
                    }
                }

                Section("Tags") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            TextField("Add tag", text: $newTag)
                                .textFieldStyle(.roundedBorder)
                                .onSubmit {
                                    addTag()
                                }

                            Button("Add", action: addTag)
                                .buttonStyle(.bordered)
                                .disabled(newTag.isEmpty)
                        }

                        if !tags.isEmpty {
                            FlowLayout(spacing: 8) {
                                ForEach(tags, id: \\.self) { tag in
                                    TagChip(tag: tag) {
                                        removeTag(tag)
                                    }
                                }
                            }
                        }
                    }
                }

                Section("AI Assistance") {
                    Button {
                        enhanceWithAI()
                    } label: {
                        Label("Enhance with AI", systemImage: "sparkles")
                    }
                    .disabled(description.isEmpty)
                }
            }
            .navigationTitle("Capture Your Idea")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        submitIdea()
                    }
                    .disabled(!isFormValid)
                }
            }
            .overlay {
                if showSuccessMessage {
                    successOverlay
                }
            }
        }
    }

    // MARK: - Success Overlay
    private var successOverlay: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)

            Text("Idea Created Successfully!")
                .font(.title2)
                .fontWeight(.bold)

            Text("Your innovation journey begins now")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(40)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 20)
    }

    // MARK: - Helper Methods
    private var isFormValid: Bool {
        !title.isEmpty && !description.isEmpty
    }

    private func addTag() {
        let trimmed = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !tags.contains(trimmed) else { return }

        tags.append(trimmed)
        newTag = ""
    }

    private func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }

    private func enhanceWithAI() {
        // AI enhancement simulation
        Task {
            // In production, call AI service
            try? await Task.sleep(for: .seconds(1))

            // Add AI-generated tags
            let suggestedTags = ["innovative", "sustainable", "scalable"]
            for tag in suggestedTags where !tags.contains(tag) {
                tags.append(tag)
            }
        }
    }

    private func submitIdea() {
        guard isFormValid else { return }

        isSubmitting = true

        let idea = InnovationIdea(
            title: title,
            description: description,
            category: selectedCategory,
            priority: priority,
            estimatedImpact: Double(priority) / 5.0,
            feasibilityScore: 0.5
        )

        idea.tags = tags

        // Save to database
        modelContext.insert(idea)

        do {
            try modelContext.save()

            // Show success message
            withAnimation {
                showSuccessMessage = true
            }

            // Dismiss after delay
            Task {
                try? await Task.sleep(for: .seconds(2))
                dismiss()
            }
        } catch {
            print("Failed to save idea: \\(error)")
        }
    }
}

// MARK: - Tag Chip
struct TagChip: View {
    let tag: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text("#\\(tag)")
                .font(.caption)

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.blue.opacity(0.2))
        .foregroundStyle(.blue)
        .clipShape(Capsule())
    }
}

// MARK: - Flow Layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize
        var frames: [CGRect]

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var frames: [CGRect] = []
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                frames.append(CGRect(origin: CGPoint(x: currentX, y: currentY), size: size))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }

            self.frames = frames
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

#Preview {
    IdeaCaptureView()
}
