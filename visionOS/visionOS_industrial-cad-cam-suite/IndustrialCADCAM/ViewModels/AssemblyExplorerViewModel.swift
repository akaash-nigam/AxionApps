import Foundation
import RealityKit
import SwiftData
import Observation

/// ViewModel for the Assembly Explorer volumetric window
@Observable
@MainActor
public class AssemblyExplorerViewModel {

    // MARK: - Dependencies

    private let modelContext: ModelContext

    // MARK: - State

    /// Currently displayed assembly
    public var assembly: Assembly? {
        didSet {
            if assembly != nil {
                assemblyDidChange()
            }
        }
    }

    /// Selected parts in assembly
    public var selectedParts: Set<UUID> = []

    /// Loading state
    public var isLoading: Bool = false

    /// Error message
    public var errorMessage: String?

    // MARK: - View Settings

    /// Explosion factor (0 = collapsed, 1 = fully exploded)
    public var explosionFactor: Float = 0.0 {
        didSet {
            updateExplosion()
        }
    }

    /// Show assembly tree
    public var showAssemblyTree: Bool = true

    /// Show part labels
    public var showPartLabels: Bool = true

    /// Show assembly constraints
    public var showConstraints: Bool = false

    /// Highlight mode
    public enum HighlightMode: String, CaseIterable {
        case none = "None"
        case byMaterial = "By Material"
        case byStatus = "By Status"
        case byManufacturing = "By Manufacturing Process"

        var displayName: String {
            return rawValue
        }
    }

    public var highlightMode: HighlightMode = .none {
        didSet {
            updateHighlighting()
        }
    }

    // MARK: - Assembly Analysis

    /// Interference check results
    public var hasInterferences: Bool = false

    /// Number of interferences found
    public var interferenceCount: Int = 0

    /// Assembly validation status
    public enum ValidationStatus {
        case valid
        case warnings([String])
        case errors([String])

        var isValid: Bool {
            if case .valid = self {
                return true
            }
            return false
        }
    }

    public var validationStatus: ValidationStatus = .valid

    // MARK: - Part Visibility

    /// Hidden parts
    public var hiddenParts: Set<UUID> = []

    /// Isolated parts (only these shown)
    public var isolatedParts: Set<UUID>?

    // MARK: - Animation

    /// Animation state
    public enum AnimationState {
        case stopped
        case playing
        case paused
    }

    public var animationState: AnimationState = .stopped

    /// Animation timeline position (0-1)
    public var animationPosition: Float = 0

    // MARK: - Initialization

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Assembly Management

    private func assemblyDidChange() {
        // Reset state
        selectedParts = []
        hiddenParts = []
        isolatedParts = nil
        explosionFactor = 0
        interferenceCount = 0
        validationStatus = .valid

        // Perform initial validation
        Task {
            await validateAssembly()
        }
    }

    // MARK: - Part Selection

    /// Select part
    /// - Parameter partID: Part UUID
    public func selectPart(_ partID: UUID) {
        selectedParts.insert(partID)
    }

    /// Deselect part
    /// - Parameter partID: Part UUID
    public func deselectPart(_ partID: UUID) {
        selectedParts.remove(partID)
    }

    /// Toggle part selection
    /// - Parameter partID: Part UUID
    public func togglePartSelection(_ partID: UUID) {
        if selectedParts.contains(partID) {
            selectedParts.remove(partID)
        } else {
            selectedParts.insert(partID)
        }
    }

    /// Clear selection
    public func clearSelection() {
        selectedParts = []
    }

    /// Select all parts
    public func selectAll() {
        guard let assembly = assembly else { return }
        selectedParts = Set(assembly.parts.map { $0.id })
    }

    // MARK: - Visibility Control

    /// Hide selected parts
    public func hideSelectedParts() {
        hiddenParts.formUnion(selectedParts)
    }

    /// Show hidden parts
    public func showHiddenParts() {
        hiddenParts = []
    }

    /// Isolate selected parts
    public func isolateSelectedParts() {
        isolatedParts = selectedParts
    }

    /// Clear isolation
    public func clearIsolation() {
        isolatedParts = nil
    }

    /// Toggle part visibility
    /// - Parameter partID: Part UUID
    public func togglePartVisibility(_ partID: UUID) {
        if hiddenParts.contains(partID) {
            hiddenParts.remove(partID)
        } else {
            hiddenParts.insert(partID)
        }
    }

    // MARK: - Explosion View

    private func updateExplosion() {
        // Update part positions based on explosion factor
        // In real implementation, calculate exploded positions
    }

    /// Animate explosion
    /// - Parameter duration: Animation duration
    public func animateExplosion(to targetFactor: Float, duration: TimeInterval = 1.0) {
        // Animate explosion factor smoothly
        Task {
            let steps = 60
            let increment = (targetFactor - explosionFactor) / Float(steps)

            for _ in 0..<steps {
                explosionFactor += increment
                try? await Task.sleep(for: .milliseconds(Int(duration * 1000 / Double(steps))))
            }

            explosionFactor = targetFactor
        }
    }

    /// Reset explosion
    public func resetExplosion() {
        explosionFactor = 0
    }

    // MARK: - Assembly Validation

    /// Validate assembly for issues
    public func validateAssembly() async {
        guard let assembly = assembly else { return }

        isLoading = true
        var warnings: [String] = []
        var errors: [String] = []

        // Check for interferences
        // In real implementation, use design service to check interferences
        hasInterferences = false
        interferenceCount = 0

        // Check for missing parts
        if assembly.parts.isEmpty {
            errors.append("Assembly contains no parts")
        }

        // Check for duplicate parts
        let partNames = assembly.parts.map { $0.name }
        let duplicates = partNames.filter { name in
            partNames.filter { $0 == name }.count > 1
        }
        if !duplicates.isEmpty {
            warnings.append("Duplicate part names found: \(Set(duplicates).joined(separator: ", "))")
        }

        // Determine validation status
        if !errors.isEmpty {
            validationStatus = .errors(errors)
        } else if !warnings.isEmpty {
            validationStatus = .warnings(warnings)
        } else {
            validationStatus = .valid
        }

        isLoading = false
    }

    // MARK: - Highlighting

    private func updateHighlighting() {
        // Update part materials based on highlight mode
        guard let assembly = assembly else { return }

        switch highlightMode {
        case .none:
            // Reset all materials
            break
        case .byMaterial:
            // Color code by material
            break
        case .byStatus:
            // Color code by status
            break
        case .byManufacturing:
            // Color code by manufacturing process
            break
        }
    }

    // MARK: - Bill of Materials

    /// Generate BOM data
    public func generateBOM() -> [(name: String, quantity: Int, material: String)] {
        guard let assembly = assembly else { return [] }

        var bomDict: [String: (quantity: Int, material: String)] = [:]

        for part in assembly.parts {
            let key = part.name
            if var existing = bomDict[key] {
                existing.quantity += 1
                bomDict[key] = existing
            } else {
                bomDict[key] = (quantity: 1, material: part.materialName)
            }
        }

        return bomDict.map { (name: $0.key, quantity: $0.value.quantity, material: $0.value.material) }
            .sorted { $0.name < $1.name }
    }

    // MARK: - Assembly Metrics

    /// Calculate total mass of assembly
    public var totalMass: Double {
        guard let assembly = assembly else { return 0 }
        return assembly.parts.reduce(0.0) { $0 + $1.calculateMass() }
    }

    /// Get part count
    public var partCount: Int {
        return assembly?.parts.count ?? 0
    }

    /// Get unique part count
    public var uniquePartCount: Int {
        guard let assembly = assembly else { return 0 }
        let uniqueNames = Set(assembly.parts.map { $0.name })
        return uniqueNames.count
    }

    // MARK: - Computed Properties

    public var hasAssembly: Bool {
        return assembly != nil
    }

    public var hasSelection: Bool {
        return !selectedParts.isEmpty
    }

    public var hasHiddenParts: Bool {
        return !hiddenParts.isEmpty
    }

    public var isIsolated: Bool {
        return isolatedParts != nil
    }

    public var isExploded: Bool {
        return explosionFactor > 0
    }

    public var canValidate: Bool {
        return hasAssembly && !isLoading
    }
}
