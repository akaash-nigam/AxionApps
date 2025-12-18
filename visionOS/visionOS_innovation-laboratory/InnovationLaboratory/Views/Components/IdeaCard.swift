import SwiftUI

struct IdeaCard: View {
    let idea: InnovationIdea

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: idea.category.icon)
                    .font(.title2)
                    .foregroundStyle(categoryColor)

                Spacer()

                Image(systemName: idea.status.icon)
                    .font(.caption)
                    .foregroundStyle(statusColor)
            }

            // Title
            Text(idea.title)
                .font(.headline)
                .lineLimit(2)

            // Description
            Text(idea.ideaDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(3)

            // Tags
            if !idea.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(idea.tags.prefix(3), id: \\.self) { tag in
                            Text("#\\(tag)")
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(categoryColor.opacity(0.2))
                                .foregroundStyle(categoryColor)
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            Divider()

            // Metrics
            HStack {
                MetricView(
                    icon: "star.fill",
                    value: "\\(idea.priority)",
                    label: "Priority"
                )

                Spacer()

                MetricView(
                    icon: "cube.fill",
                    value: "\\(idea.prototypes.count)",
                    label: "Prototypes"
                )

                Spacer()

                MetricView(
                    icon: "clock.fill",
                    value: timeAgo,
                    label: ""
                )
            }
            .font(.caption2)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
    }

    private var categoryColor: Color {
        switch idea.category {
        case .product: return .blue
        case .service: return .purple
        case .process: return .green
        case .technology: return .orange
        case .businessModel: return .pink
        }
    }

    private var statusColor: Color {
        switch idea.status {
        case .concept: return .yellow
        case .prototyping: return .purple
        case .testing: return .orange
        case .validated: return .green
        case .inDevelopment: return .blue
        case .launched: return .pink
        case .archived: return .gray
        }
    }

    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: idea.createdDate, relativeTo: Date())
    }
}

struct MetricView: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
            Text(value)
                .fontWeight(.semibold)
            if !label.isEmpty {
                Text(label)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    IdeaCard(idea: InnovationIdea(
        title: "Smart Packaging Solution",
        description: "Biodegradable packaging with built-in freshness sensors",
        category: .product,
        priority: 4
    ))
    .frame(width: 300)
}
