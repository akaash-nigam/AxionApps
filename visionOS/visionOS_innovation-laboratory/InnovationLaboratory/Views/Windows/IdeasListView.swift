import SwiftUI
import SwiftData

struct IdeasListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \\InnovationIdea.createdDate, order: .reverse)
    private var allIdeas: [InnovationIdea]

    @State private var searchText = ""
    @State private var filterCategory: IdeaCategory?
    @State private var filterStatus: IdeaStatus?

    var body: some View {
        List {
            ForEach(filteredIdeas) { idea in
                NavigationLink(destination: IdeaDetailView(idea: idea)) {
                    IdeaRow(idea: idea)
                }
            }
            .onDelete(perform: deleteIdeas)
        }
        .searchable(text: $searchText, prompt: "Search ideas")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                filterMenu
            }
        }
        .navigationTitle("All Ideas")
    }

    private var filterMenu: some View {
        Menu {
            Section("Category") {
                Button("All Categories") {
                    filterCategory = nil
                }
                ForEach(IdeaCategory.allCases, id: \\.self) { category in
                    Button {
                        filterCategory = category
                    } label: {
                        Label(category.rawValue, systemImage: category.icon)
                    }
                }
            }

            Section("Status") {
                Button("All Statuses") {
                    filterStatus = nil
                }
                ForEach(IdeaStatus.allCases, id: \\.self) { status in
                    Button {
                        filterStatus = status
                    } label: {
                        Label(status.rawValue, systemImage: status.icon)
                    }
                }
            }
        } label: {
            Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
        }
    }

    private var filteredIdeas: [InnovationIdea] {
        allIdeas.filter { idea in
            let matchesSearch = searchText.isEmpty ||
                idea.title.localizedStandardContains(searchText) ||
                idea.ideaDescription.localizedStandardContains(searchText)

            let matchesCategory = filterCategory == nil || idea.category == filterCategory
            let matchesStatus = filterStatus == nil || idea.status == filterStatus

            return matchesSearch && matchesCategory && matchesStatus
        }
    }

    private func deleteIdeas(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(allIdeas[index])
        }
    }
}

struct IdeaRow: View {
    let idea: InnovationIdea

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: idea.category.icon)
                .font(.title2)
                .foregroundStyle(categoryColor)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(idea.title)
                    .font(.headline)

                Text(idea.ideaDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                HStack(spacing: 12) {
                    Label("\\(idea.priority)", systemImage: "star.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow)

                    Label(idea.status.rawValue, systemImage: idea.status.icon)
                        .font(.caption)
                        .foregroundStyle(statusColor)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
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
}

struct IdeaDetailView: View {
    let idea: InnovationIdea

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(idea.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(idea.ideaDescription)
                    .font(.body)

                // Prototypes section would go here
            }
            .padding()
        }
        .navigationTitle("Idea Details")
    }
}

#Preview {
    NavigationStack {
        IdeasListView()
    }
}
