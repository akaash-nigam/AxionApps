import SwiftUI
import SwiftData
import RealityKit
import Observation

/// ViewModel for BIM model management and visualization
/// Handles model loading, element filtering, and progress tracking
@Observable
final class BIMViewModel {
    // MARK: - Properties

    private(set) var models: [BIMModel] = []
    private(set) var filteredElements: [BIMElement] = []
    private(set) var isLoading = false
    private(set) var loadingProgress: Double = 0.0
    private(set) var errorMessage: String?

    var selectedModel: BIMModel?
    var selectedDiscipline: Discipline?
    var selectedStatus: ElementStatus?
    var searchText = ""
    var showOnlyIssues = false

    // MARK: - Dependencies

    private let modelContext: ModelContext

    // MARK: - Initialization

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Public Methods

    /// Load all BIM models from database
    func loadModels() {
        isLoading = true
        errorMessage = nil

        do {
            let descriptor = FetchDescriptor<BIMModel>(
                sortBy: [SortDescriptor(\.createdDate, order: .reverse)]
            )
            models = try modelContext.fetch(descriptor)
            isLoading = false
        } catch {
            errorMessage = "Failed to load BIM models: \(error.localizedDescription)"
            isLoading = false
        }
    }

    /// Import a BIM model from file
    func importModel(from url: URL, project: Project) async throws {
        isLoading = true
        loadingProgress = 0.0
        errorMessage = nil

        defer { isLoading = false }

        // Validate file format
        let formatString = url.pathExtension.uppercased()
        guard let format = BIMFormat(rawValue: formatString) else {
            throw BIMError.unsupportedFormat
        }

        // Create model record
        let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
        let fileSize = attributes[.size] as? Int64 ?? 0

        let model = BIMModel(
            name: url.deletingPathExtension().lastPathComponent,
            format: format,
            fileURL: url.path,
            sizeInBytes: fileSize
        )

        loadingProgress = 0.1

        // Parse file based on format
        switch format {
        case .ifc:
            try await parseIFCFile(url, into: model)
        case .rvt:
            try await parseRevitFile(url, into: model)
        default:
            throw BIMError.parsingFailed
        }

        loadingProgress = 0.9

        // Save to database
        model.project = project
        project.bimModels.append(model)
        modelContext.insert(model)
        try modelContext.save()

        loadingProgress = 1.0
        models.append(model)
    }

    /// Update element status
    func updateElementStatus(_ element: BIMElement, status: ElementStatus) throws {
        element.status = status
        element.lastUpdated = Date()

        // Create progress record for the element
        let record = ElementProgressRecord(
            status: status,
            percentComplete: element.percentComplete,
            timestamp: Date(),
            updatedBy: "Current User", // TODO: Get from auth service
            notes: "Status updated to \(status.rawValue)"
        )
        element.progressRecords.append(record)

        try modelContext.save()
    }

    /// Bulk update element statuses
    func bulkUpdateStatus(_ elements: [BIMElement], status: ElementStatus) throws {
        for element in elements {
            element.status = status
            element.lastUpdated = Date()
        }

        try modelContext.save()
    }

    /// Filter elements based on current criteria
    func filterElements(from model: BIMModel) {
        var elements = model.elements

        // Apply discipline filter
        if let discipline = selectedDiscipline {
            elements = elements.filter { $0.discipline == discipline }
        }

        // Apply status filter
        if let status = selectedStatus {
            elements = elements.filter { $0.status == status }
        }

        // Apply search filter
        if !searchText.isEmpty {
            elements = elements.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.ifcType.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Apply issues filter - Note: Issue relationship to elements not yet implemented
        // if showOnlyIssues {
        //     elements = elements.filter { !$0.issues.isEmpty }
        // }

        filteredElements = elements
    }

    /// Get progress statistics for a model
    func getProgressStatistics(for model: BIMModel) -> ProgressStatistics {
        let total = model.elements.count
        let byStatus = Dictionary(grouping: model.elements) { $0.status }

        return ProgressStatistics(
            total: total,
            notStarted: byStatus[.notStarted]?.count ?? 0,
            inProgress: byStatus[.inProgress]?.count ?? 0,
            completed: byStatus[.completed]?.count ?? 0,
            approved: byStatus[.approved]?.count ?? 0,
            rejected: byStatus[.rejected]?.count ?? 0,
            onHold: byStatus[.onHold]?.count ?? 0
        )
    }

    /// Get progress by discipline
    func getProgressByDiscipline(for model: BIMModel) -> [Discipline: Double] {
        var progressByDiscipline: [Discipline: Double] = [:]

        for discipline in Discipline.allCases {
            let elements = model.elements.filter { $0.discipline == discipline }
            guard !elements.isEmpty else { continue }

            let completed = elements.filter { $0.status == .completed || $0.status == .approved }.count
            let progress = Double(completed) / Double(elements.count)
            progressByDiscipline[discipline] = progress
        }

        return progressByDiscipline
    }

    /// Generate RealityKit entities for visualization
    @MainActor
    func generateEntities(for model: BIMModel) async throws -> [Entity] {
        var entities: [Entity] = []

        for element in model.elements {
            let entity = try await createEntity(for: element)
            entities.append(entity)
        }

        return entities
    }

    /// Create spatial anchor for element
    func createAnchor(for element: BIMElement, at worldPosition: SIMD3<Float>) throws {
        // TODO: Create ARKit anchor for element placement
    }

    /// Export model data
    func exportProgress(for model: BIMModel) -> Data? {
        // TODO: Generate progress report (PDF, CSV, etc.)
        return nil
    }

    /// Search elements across all models
    func searchAllModels(_ query: String) -> [BIMElement] {
        models.flatMap { $0.elements }.filter {
            $0.name.localizedCaseInsensitiveContains(query) ||
            $0.ifcType.localizedCaseInsensitiveContains(query)
        }
    }

    // MARK: - Private Methods

    private func parseIFCFile(_ url: URL, into model: BIMModel) async throws {
        // TODO: Implement IFC parser
        // This would use an IFC parsing library to extract:
        // - Building elements (IfcBeam, IfcColumn, IfcWall, etc.)
        // - Properties (dimensions, materials, etc.)
        // - Spatial hierarchy
        // - Geometric representations

        // For now, create sample elements
        let sampleElements = [
            BIMElement(
                ifcGuid: UUID().uuidString,
                ifcType: "IfcBeam",
                name: "Sample Beam",
                discipline: .structural
            ),
            BIMElement(
                ifcGuid: UUID().uuidString,
                ifcType: "IfcColumn",
                name: "Sample Column",
                discipline: .structural
            )
        ]

        for element in sampleElements {
            model.elements.append(element)
        }

        loadingProgress = 0.7
    }

    private func parseRevitFile(_ url: URL, into model: BIMModel) async throws {
        // TODO: Implement Revit file parser
        // Would extract similar data as IFC parser
        throw BIMError.parsingFailed
    }

    @MainActor
    private func createEntity(for element: BIMElement) async throws -> Entity {
        let entity = ModelEntity()
        entity.name = element.name

        // Apply transform
        let transform = element.transform.toMatrix()
        entity.transform.matrix = transform

        // Apply material based on status
        let material = SimpleMaterial(color: element.status.color.uiColor, isMetallic: false)
        entity.model?.materials = [material]

        return entity
    }
}

// MARK: - Supporting Types

struct ProgressStatistics {
    let total: Int
    let notStarted: Int
    let inProgress: Int
    let completed: Int
    let approved: Int
    let rejected: Int
    let onHold: Int

    var completionPercentage: Double {
        guard total > 0 else { return 0.0 }
        return Double(completed + approved) / Double(total)
    }
}

enum BIMError: LocalizedError {
    case unsupportedFormat
    case parsingFailed
    case invalidData

    var errorDescription: String? {
        switch self {
        case .unsupportedFormat:
            return "Unsupported file format"
        case .parsingFailed:
            return "Failed to parse BIM file"
        case .invalidData:
            return "Invalid BIM data"
        }
    }
}

// MARK: - Extensions

extension Color {
    var uiColor: UIColor {
        UIColor(self)
    }
}
