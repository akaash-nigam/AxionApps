import SwiftUI
import SwiftData
import Charts

/// Progress tracking view for monitoring construction element completion
/// Provides filtering, bulk updates, and visual progress analytics
struct ProgressTrackingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var models: [BIMModel]

    @State private var selectedModel: BIMModel?
    @State private var selectedDiscipline: Discipline?
    @State private var selectedStatus: ElementStatus?
    @State private var searchText = ""
    @State private var showingBulkUpdate = false
    @State private var selectedElements: Set<BIMElement> = []
    @State private var sortOrder: SortOrder = .name

    enum SortOrder: String, CaseIterable {
        case name = "Name"
        case status = "Status"
        case discipline = "Discipline"
        case progress = "Progress"
    }

    var body: some View {
        NavigationSplitView {
            modelList
        } detail: {
            if let model = selectedModel {
                progressDetail(for: model)
            } else {
                emptyState
            }
        }
        .searchable(text: $searchText, prompt: "Search elements...")
        .sheet(isPresented: $showingBulkUpdate) {
            BulkUpdateSheet(elements: Array(selectedElements), modelContext: modelContext)
        }
    }

    // MARK: - Model List

    private var modelList: some View {
        List(models, selection: $selectedModel) { model in
            ModelRow(model: model)
                .tag(model)
        }
        .navigationTitle("Project Models")
    }

    // MARK: - Progress Detail

    @ViewBuilder
    private func progressDetail(for model: BIMModel) -> View {
        ScrollView {
            VStack(spacing: 24) {
                // Overall progress
                overallProgressCard(for: model)

                // Filters
                filtersSection

                // Statistics
                statisticsSection(for: model)

                // Progress chart
                progressChart(for: model)

                // Discipline breakdown
                disciplineBreakdown(for: model)

                // Element list
                elementList(for: model)
            }
            .padding()
        }
        .navigationTitle(model.fileName)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(action: exportProgress) {
                        Label("Export Progress Report", systemImage: "square.and.arrow.up")
                    }

                    Button(action: syncProgress) {
                        Label("Sync with Server", systemImage: "arrow.triangle.2.circlepath")
                    }

                    Divider()

                    if !selectedElements.isEmpty {
                        Button(action: { showingBulkUpdate = true }) {
                            Label("Bulk Update (\(selectedElements.count))", systemImage: "square.and.pencil")
                        }

                        Button(role: .destructive, action: clearSelection) {
                            Label("Clear Selection", systemImage: "xmark")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }

    // MARK: - Overall Progress Card

    private func overallProgressCard(for model: BIMModel) -> some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Overall Progress")
                        .font(.headline)
                    Text("\(model.elements.count) total elements")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(Int(model.completionPercentage * 100))%")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(.blue)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.quaternary)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(.blue)
                        .frame(width: geometry.size.width * model.completionPercentage)
                }
            }
            .frame(height: 16)

            // Quick stats
            HStack(spacing: 20) {
                StatBadge(
                    label: "Completed",
                    value: model.elements.filter { $0.status == .completed }.count,
                    color: .green
                )

                StatBadge(
                    label: "In Progress",
                    value: model.elements.filter { $0.status == .inProgress }.count,
                    color: .orange
                )

                StatBadge(
                    label: "Not Started",
                    value: model.elements.filter { $0.status == .notStarted }.count,
                    color: .gray
                )
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Filters Section

    private var filtersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Filters")
                .font(.headline)

            HStack {
                // Discipline filter
                Menu {
                    Button("All Disciplines") {
                        selectedDiscipline = nil
                    }
                    Divider()
                    ForEach(Discipline.allCases, id: \.self) { discipline in
                        Button(action: { selectedDiscipline = discipline }) {
                            Label(discipline.rawValue.capitalized, systemImage: "circle.fill")
                                .foregroundStyle(discipline.color)
                        }
                    }
                } label: {
                    Label(selectedDiscipline?.rawValue.capitalized ?? "All Disciplines",
                          systemImage: "line.3.horizontal.decrease.circle")
                }
                .buttonStyle(.bordered)

                // Status filter
                Menu {
                    Button("All Statuses") {
                        selectedStatus = nil
                    }
                    Divider()
                    ForEach(ElementStatus.allCases, id: \.self) { status in
                        Button(action: { selectedStatus = status }) {
                            Label(status.rawValue.capitalized, systemImage: "circle.fill")
                                .foregroundStyle(status.color)
                        }
                    }
                } label: {
                    Label(selectedStatus?.rawValue.capitalized ?? "All Statuses",
                          systemImage: "chart.bar.fill")
                }
                .buttonStyle(.bordered)

                Spacer()

                // Sort order
                Menu {
                    ForEach(SortOrder.allCases, id: \.self) { order in
                        Button(action: { sortOrder = order }) {
                            Label(order.rawValue, systemImage: sortOrder == order ? "checkmark" : "")
                        }
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
                .buttonStyle(.bordered)
            }

            if selectedDiscipline != nil || selectedStatus != nil {
                Button(action: clearFilters) {
                    Label("Clear Filters", systemImage: "xmark.circle")
                }
                .buttonStyle(.borderless)
                .font(.caption)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Statistics Section

    private func statisticsSection(for model: BIMModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistics")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(ElementStatus.allCases, id: \.self) { status in
                    let count = model.elements.filter { $0.status == status }.count
                    let percentage = Double(count) / Double(model.elements.count) * 100

                    VStack(spacing: 4) {
                        Text(status.rawValue.capitalized)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("\(count)")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(status.color)

                        Text(String(format: "%.1f%%", percentage))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(status.color.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Progress Chart

    private func progressChart(for model: BIMModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progress Over Time")
                .font(.headline)

            Chart {
                ForEach(model.progressRecords) { record in
                    LineMark(
                        x: .value("Date", record.date),
                        y: .value("Progress", record.percentage * 100)
                    )
                    .foregroundStyle(.blue)
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("Date", record.date),
                        y: .value("Progress", record.percentage * 100)
                    )
                    .foregroundStyle(.blue.opacity(0.1))
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Date", record.date),
                        y: .value("Progress", record.percentage * 100)
                    )
                    .foregroundStyle(.blue)
                }
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        if let progress = value.as(Double.self) {
                            Text("\(Int(progress))%")
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel(format: .dateTime.month().day())
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Discipline Breakdown

    private func disciplineBreakdown(for model: BIMModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progress by Discipline")
                .font(.headline)

            ForEach(Discipline.allCases, id: \.self) { discipline in
                let elements = model.elements.filter { $0.discipline == discipline }
                let completed = elements.filter { $0.status == .completed }.count
                let progress = elements.isEmpty ? 0.0 : Double(completed) / Double(elements.count)

                HStack {
                    Circle()
                        .fill(discipline.color)
                        .frame(width: 12, height: 12)

                    Text(discipline.rawValue.capitalized)
                        .font(.subheadline)

                    Spacer()

                    Text("\(completed)/\(elements.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("\(Int(progress * 100))%")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(width: 50, alignment: .trailing)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.quaternary)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(discipline.color)
                            .frame(width: geometry.size.width * progress)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Element List

    private func elementList(for model: BIMModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Elements")
                    .font(.headline)

                Spacer()

                if !selectedElements.isEmpty {
                    Text("\(selectedElements.count) selected")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            ForEach(filteredAndSortedElements(from: model)) { element in
                ElementRow(
                    element: element,
                    isSelected: selectedElements.contains(element),
                    onTap: { toggleSelection(element) }
                )
            }

            if filteredAndSortedElements(from: model).isEmpty {
                Text("No elements match the current filters")
                    .foregroundStyle(.secondary)
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView(
            "No Model Selected",
            systemImage: "cube.transparent",
            description: Text("Select a BIM model from the list to view progress details")
        )
    }

    // MARK: - Helper Functions

    private func filteredAndSortedElements(from model: BIMModel) -> [BIMElement] {
        var elements = model.elements

        // Apply filters
        if let discipline = selectedDiscipline {
            elements = elements.filter { $0.discipline == discipline }
        }

        if let status = selectedStatus {
            elements = elements.filter { $0.status == status }
        }

        if !searchText.isEmpty {
            elements = elements.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.ifcType.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Apply sorting
        switch sortOrder {
        case .name:
            elements.sort { $0.name < $1.name }
        case .status:
            elements.sort { $0.status < $1.status }
        case .discipline:
            elements.sort { $0.discipline.rawValue < $1.discipline.rawValue }
        case .progress:
            // Status order: completed > inProgress > notStarted > others
            elements.sort { $0.status > $1.status }
        }

        return elements
    }

    private func toggleSelection(_ element: BIMElement) {
        if selectedElements.contains(element) {
            selectedElements.remove(element)
        } else {
            selectedElements.insert(element)
        }
    }

    private func clearSelection() {
        selectedElements.removeAll()
    }

    private func clearFilters() {
        selectedDiscipline = nil
        selectedStatus = nil
    }

    private func exportProgress() {
        // TODO: Generate and export progress report
    }

    private func syncProgress() {
        // TODO: Sync with server
    }
}

// MARK: - Supporting Views

struct ModelRow: View {
    let model: BIMModel

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(model.fileName)
                    .font(.headline)

                Text("\(model.elements.count) elements")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(model.completionPercentage * 100))%")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.blue)

                ProgressView(value: model.completionPercentage)
                    .frame(width: 60)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ElementRow: View {
    @Bindable var element: BIMElement
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? .blue : .secondary)

                // Discipline indicator
                Circle()
                    .fill(element.discipline.color)
                    .frame(width: 8, height: 8)

                // Element info
                VStack(alignment: .leading, spacing: 2) {
                    Text(element.name)
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    Text(element.ifcType)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Status picker
                Picker("Status", selection: $element.status) {
                    ForEach(ElementStatus.allCases, id: \.self) { status in
                        Text(status.rawValue.capitalized).tag(status)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
                .frame(width: 120)
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct StatBadge: View {
    let label: String
    let value: Int
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(color)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct BulkUpdateSheet: View {
    @Environment(\.dismiss) private var dismiss
    let elements: [BIMElement]
    let modelContext: ModelContext

    @State private var newStatus: ElementStatus = .inProgress

    var body: some View {
        NavigationStack {
            Form {
                Section("Update Status") {
                    Picker("New Status", selection: $newStatus) {
                        ForEach(ElementStatus.allCases, id: \.self) { status in
                            Label(status.rawValue.capitalized, systemImage: "circle.fill")
                                .foregroundStyle(status.color)
                                .tag(status)
                        }
                    }
                }

                Section {
                    Text("This will update \(elements.count) element(s)")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Bulk Update")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Update") {
                        performBulkUpdate()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func performBulkUpdate() {
        for element in elements {
            element.status = newStatus
            element.lastUpdated = Date()
        }

        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var container: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: BIMModel.self, BIMElement.self, configurations: config)

        let model = BIMModel(
            name: "Building A.ifc",
            format: .ifc,
            fileURL: "file:///Building_A.ifc",
            sizeInBytes: 15_000_000
        )

    // Add sample elements
    for i in 0..<20 {
        let element = BIMElement(
            ifcGuid: UUID().uuidString,
            ifcType: "IfcBeam",
            name: "Beam-\(String(format: "%03d", i))",
            discipline: Discipline.allCases.randomElement()!
        )
        element.status = ElementStatus.allCases.randomElement()!
        model.elements.append(element)
    }

        container.mainContext.insert(model)
        return container
    }()

    ProgressTrackingView()
        .modelContainer(container)
}
