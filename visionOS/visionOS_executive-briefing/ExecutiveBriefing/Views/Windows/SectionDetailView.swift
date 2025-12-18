import SwiftUI

/// Detail view for a briefing section
struct SectionDetailView: View {
    let section: BriefingSection

    @Environment(\.openWindow) private var openWindow

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack {
                    Image(systemName: section.icon)
                        .font(.system(size: 48))
                        .foregroundStyle(.accent)

                    Text(section.title)
                        .font(.system(size: 48, weight: .bold))

                    Spacer()

                    // 3D visualization button if available
                    if let vizType = section.visualizationType {
                        Button {
                            openVisualization(vizType)
                        } label: {
                            Label("View in 3D", systemImage: "cube.fill")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(.bottom, 8)

                Divider()

                // Content blocks
                ForEach(section.content.sorted(by: { $0.order < $1.order })) { block in
                    ContentBlockView(block: block)
                }
            }
            .padding(40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func openVisualization(_ type: VisualizationType) {
        openWindow(id: "roi-visualization", value: type)
    }
}

/// View for rendering individual content blocks
struct ContentBlockView: View {
    let block: ContentBlock

    var body: some View {
        switch block.type {
        case .heading:
            Text(block.content)
                .font(.system(size: 32, weight: .semibold))
                .padding(.top, 16)

        case .subheading:
            Text(block.content)
                .font(.system(size: 24, weight: .semibold))
                .padding(.top, 12)

        case .paragraph:
            Text(block.content)
                .font(.system(size: 20))
                .lineSpacing(8)
                .foregroundStyle(.primary)

        case .bulletList:
            HStack(alignment: .top, spacing: 12) {
                Text("•")
                    .font(.title3)
                Text(block.content)
                    .font(.system(size: 18))
            }
            .padding(.leading, 20)

        case .numberedList:
            Text(block.content)
                .font(.system(size: 18))
                .padding(.leading, 20)

        case .metric:
            MetricBlockView(content: block.content)

        case .callout:
            CalloutView(content: block.content)

        case .quote:
            QuoteView(content: block.content)

        case .codeBlock:
            CodeBlockView(content: block.content)

        case .table:
            Text(block.content)
                .font(.system(size: 16, design: .monospaced))
        }
    }
}

/// Special view for metrics
struct MetricBlockView: View {
    let content: String

    var body: some View {
        HStack {
            Text(content)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.accent)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.vertical, 8)
    }
}

/// Callout view
struct CalloutView: View {
    let content: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(.blue)
            Text(content)
                .font(.system(size: 18))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.blue.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

/// Quote view
struct QuoteView: View {
    let content: String

    var body: some View {
        Text(content)
            .font(.system(size: 20, weight: .medium, design: .serif))
            .italic()
            .padding(.leading, 20)
            .overlay(alignment: .leading) {
                Rectangle()
                    .fill(.accent)
                    .frame(width: 4)
            }
    }
}

/// Code block view
struct CodeBlockView: View {
    let content: String

    var body: some View {
        Text(content)
            .font(.system(size: 16, design: .monospaced))
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.black.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    SectionDetailView(
        section: BriefingSection(
            title: "Executive Summary",
            order: 0,
            icon: "doc.text.fill",
            content: [
                ContentBlock(type: .paragraph, content: "This is a test paragraph.", order: 0),
                ContentBlock(type: .heading, content: "Key Points", order: 1),
                ContentBlock(type: .bulletList, content: "Point 1", order: 2),
                ContentBlock(type: .metric, content: "ROI: 400%", order: 3)
            ]
        )
    )
}
