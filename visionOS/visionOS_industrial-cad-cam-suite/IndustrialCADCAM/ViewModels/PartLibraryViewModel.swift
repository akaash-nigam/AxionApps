import Foundation
import SwiftData
import Observation

/// ViewModel for the Part Library window
@Observable
@MainActor
public class PartLibraryViewModel {

    // MARK: - Dependencies

    private let modelContext: ModelContext
    private let designService: DesignService

    // MARK: - State

    /// All standard parts in library
    public var standardParts: [StandardPart] = []

    /// Filtered parts based on search and category
    public var filteredParts: [StandardPart] = []

    /// Search query
    public var searchQuery: String = "" {
        didSet {
            filterParts()
        }
    }

    /// Selected category
    public var selectedCategory: PartCategory = .all {
        didSet {
            filterParts()
        }
    }

    /// Selected part
    public var selectedPart: StandardPart?

    /// Loading state
    public var isLoading: Bool = false

    /// Error message
    public var errorMessage: String?

    // MARK: - Categories

    public enum PartCategory: String, CaseIterable {
        case all = "All"
        case fasteners = "Fasteners"
        case bearings = "Bearings"
        case gears = "Gears"
        case structural = "Structural"
        case electrical = "Electrical"
        case pneumatic = "Pneumatic"
        case hydraulic = "Hydraulic"

        var displayName: String {
            return rawValue
        }

        var iconName: String {
            switch self {
            case .all: return "square.grid.2x2"
            case .fasteners: return "bolt.fill"
            case .bearings: return "circle.fill"
            case .gears: return "gearshape.fill"
            case .structural: return "building.columns.fill"
            case .electrical: return "bolt.fill"
            case .pneumatic: return "wind"
            case .hydraulic: return "drop.fill"
            }
        }
    }

    // MARK: - Standard Part Model

    public struct StandardPart: Identifiable {
        public let id: UUID
        public let name: String
        public let category: PartCategory
        public let description: String
        public let specifications: [String: String]
        public let thumbnailName: String
        public let modelFileName: String

        public init(
            id: UUID = UUID(),
            name: String,
            category: PartCategory,
            description: String,
            specifications: [String: String],
            thumbnailName: String,
            modelFileName: String
        ) {
            self.id = id
            self.name = name
            self.category = category
            self.description = description
            self.specifications = specifications
            self.thumbnailName = thumbnailName
            self.modelFileName = modelFileName
        }
    }

    // MARK: - Initialization

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.designService = DesignService(modelContext: modelContext)
        loadStandardParts()
    }

    // MARK: - Loading

    private func loadStandardParts() {
        // In a real implementation, this would load from a catalog file or database
        // For now, we'll create sample standard parts

        standardParts = [
            // Fasteners
            StandardPart(
                name: "M6 Hex Bolt",
                category: .fasteners,
                description: "Standard metric hex head bolt",
                specifications: [
                    "Thread": "M6",
                    "Length": "25mm",
                    "Material": "Steel",
                    "Grade": "8.8"
                ],
                thumbnailName: "m6_bolt_thumb",
                modelFileName: "m6_bolt.step"
            ),
            StandardPart(
                name: "M8 Hex Nut",
                category: .fasteners,
                description: "Standard metric hex nut",
                specifications: [
                    "Thread": "M8",
                    "Width": "13mm",
                    "Material": "Steel",
                    "Grade": "8"
                ],
                thumbnailName: "m8_nut_thumb",
                modelFileName: "m8_nut.step"
            ),

            // Bearings
            StandardPart(
                name: "6205 Ball Bearing",
                category: .bearings,
                description: "Deep groove ball bearing",
                specifications: [
                    "ID": "25mm",
                    "OD": "52mm",
                    "Width": "15mm",
                    "Load Rating": "11.3kN"
                ],
                thumbnailName: "6205_bearing_thumb",
                modelFileName: "6205_bearing.step"
            ),

            // Gears
            StandardPart(
                name: "Spur Gear 20T",
                category: .gears,
                description: "20 tooth spur gear, module 2",
                specifications: [
                    "Teeth": "20",
                    "Module": "2",
                    "PD": "40mm",
                    "Face Width": "20mm"
                ],
                thumbnailName: "spur_gear_20t_thumb",
                modelFileName: "spur_gear_20t.step"
            ),

            // Structural
            StandardPart(
                name: "80/20 T-Slot Extrusion",
                category: .structural,
                description: "40mm x 40mm aluminum extrusion",
                specifications: [
                    "Size": "40x40mm",
                    "Length": "1000mm",
                    "Material": "6105-T5 Aluminum",
                    "Slot": "10mm"
                ],
                thumbnailName: "t_slot_40x40_thumb",
                modelFileName: "t_slot_40x40.step"
            ),

            // Electrical
            StandardPart(
                name: "Terminal Block 2-Position",
                category: .electrical,
                description: "Screw terminal block",
                specifications: [
                    "Positions": "2",
                    "Pitch": "5.08mm",
                    "Current": "15A",
                    "Voltage": "300V"
                ],
                thumbnailName: "terminal_block_2p_thumb",
                modelFileName: "terminal_block_2p.step"
            )
        ]

        filterParts()
    }

    // MARK: - Filtering

    private func filterParts() {
        var parts = standardParts

        // Filter by category
        if selectedCategory != .all {
            parts = parts.filter { $0.category == selectedCategory }
        }

        // Filter by search query
        if !searchQuery.isEmpty {
            parts = parts.filter { part in
                part.name.localizedCaseInsensitiveContains(searchQuery) ||
                part.description.localizedCaseInsensitiveContains(searchQuery)
            }
        }

        filteredParts = parts
    }

    // MARK: - Part Selection

    /// Select a part from the library
    /// - Parameter part: Standard part to select
    public func selectPart(_ part: StandardPart) {
        selectedPart = part
    }

    /// Clear selection
    public func clearSelection() {
        selectedPart = nil
    }

    // MARK: - Part Insertion

    /// Insert selected part into current project
    /// - Parameter project: Target project
    public func insertPartIntoProject(_ project: DesignProject) async {
        guard let standardPart = selectedPart else { return }

        isLoading = true
        errorMessage = nil

        do {
            // Create new part from standard part
            let part = try await designService.createPart(
                name: standardPart.name,
                in: project
            )

            // Copy specifications
            part.partDescription = standardPart.description
            part.manufacturingNotes = "Standard part: \(standardPart.category.displayName)"

            // Save
            try modelContext.save()

        } catch {
            errorMessage = "Failed to insert part: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Computed Properties

    public var hasResults: Bool {
        return !filteredParts.isEmpty
    }

    public var resultCount: Int {
        return filteredParts.count
    }

    public var isSearching: Bool {
        return !searchQuery.isEmpty
    }

    public var hasSelection: Bool {
        return selectedPart != nil
    }

    /// Get parts count by category
    public func partCount(for category: PartCategory) -> Int {
        if category == .all {
            return standardParts.count
        } else {
            return standardParts.filter { $0.category == category }.count
        }
    }

    /// Get category distribution
    public var categoryDistribution: [PartCategory: Int] {
        var distribution: [PartCategory: Int] = [:]

        for category in PartCategory.allCases where category != .all {
            distribution[category] = partCount(for: category)
        }

        return distribution
    }
}
