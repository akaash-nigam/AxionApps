import SwiftUI

/// Sidebar navigation view
struct SidebarView: View {
    let sections: [BriefingSection]
    @Binding var selectedSection: BriefingSection?

    var body: some View {
        List(sections, selection: $selectedSection) { section in
            NavigationLink(value: section) {
                HStack(spacing: 16) {
                    Image(systemName: section.icon)
                        .font(.title2)
                        .foregroundStyle(.accent)
                        .frame(width: 32)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(section.title)
                            .font(.headline)

                        if section.content.count > 0 {
                            Text("\(section.content.count) items")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    if section.visualizationType != nil {
                        Image(systemName: "cube.fill")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Contents")
    }
}

#Preview {
    @Previewable @State var selectedSection: BriefingSection?

    SidebarView(
        sections: [
            BriefingSection(title: "Executive Summary", order: 0, icon: "doc.text.fill"),
            BriefingSection(title: "Use Cases", order: 1, icon: "chart.bar.fill", visualizationType: .roiComparison)
        ],
        selectedSection: $selectedSection
    )
}
