import Foundation
import SwiftData
import Observation

/// ViewModel for the Properties Inspector window
@Observable
@MainActor
public class PropertiesInspectorViewModel {

    // MARK: - Dependencies

    private let modelContext: ModelContext

    // MARK: - State

    /// Currently selected part
    public var selectedPart: Part? {
        didSet {
            if selectedPart != nil {
                loadPartDetails()
            }
        }
    }

    /// Part name (editable)
    public var partName: String = "" {
        didSet {
            hasUnsavedChanges = true
        }
    }

    /// Part description (editable)
    public var partDescription: String = "" {
        didSet {
            hasUnsavedChanges = true
        }
    }

    /// Material name (editable)
    public var materialName: String = "" {
        didSet {
            hasUnsavedChanges = true
        }
    }

    /// Material color (editable)
    public var materialColor: String = "" {
        didSet {
            hasUnsavedChanges = true
        }
    }

    /// Density (editable)
    public var density: String = "" {
        didSet {
            hasUnsavedChanges = true
        }
    }

    /// Manufacturing notes (editable)
    public var manufacturingNotes: String = "" {
        didSet {
            hasUnsavedChanges = true
        }
    }

    /// Has unsaved changes
    public var hasUnsavedChanges: Bool = false

    /// Loading state
    public var isLoading: Bool = false

    /// Error message
    public var errorMessage: String?

    /// Success message
    public var successMessage: String?

    // MARK: - Active Tab

    public enum InspectorTab: String, CaseIterable {
        case general = "General"
        case geometry = "Geometry"
        case material = "Material"
        case manufacturing = "Manufacturing"
        case quality = "Quality"

        var displayName: String {
            return rawValue
        }
    }

    public var activeTab: InspectorTab = .general

    // MARK: - Read-only Properties

    public var partID: String {
        return selectedPart?.id.shortID ?? "N/A"
    }

    public var createdDate: String {
        return selectedPart?.createdDate.mediumDateString ?? "N/A"
    }

    public var modifiedDate: String {
        return selectedPart?.modifiedDate.mediumDateString ?? "N/A"
    }

    public var volume: String {
        guard let part = selectedPart else { return "N/A" }
        return part.volume.formatted(withUnit: "mm³", decimalPlaces: 2)
    }

    public var surfaceArea: String {
        guard let part = selectedPart else { return "N/A" }
        return part.surfaceArea.formatted(withUnit: "mm²", decimalPlaces: 2)
    }

    public var mass: String {
        guard let part = selectedPart else { return "N/A" }
        let massValue = part.calculateMass()
        return massValue.formatted(withUnit: "g", decimalPlaces: 2)
    }

    public var boundingBox: String {
        guard let part = selectedPart else { return "N/A" }
        return "\(part.boundingBoxWidth.formatted(decimalPlaces: 1)) × \(part.boundingBoxHeight.formatted(decimalPlaces: 1)) × \(part.boundingBoxDepth.formatted(decimalPlaces: 1)) mm"
    }

    // MARK: - Initialization

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Loading

    private func loadPartDetails() {
        guard let part = selectedPart else { return }

        partName = part.name
        partDescription = part.partDescription
        materialName = part.materialName
        materialColor = part.materialColor
        density = String(part.density)
        manufacturingNotes = part.manufacturingNotes

        hasUnsavedChanges = false
        errorMessage = nil
        successMessage = nil
    }

    // MARK: - Saving

    /// Save changes to part
    public func saveChanges() async {
        guard let part = selectedPart else { return }
        guard hasUnsavedChanges else { return }

        isLoading = true
        errorMessage = nil
        successMessage = nil

        do {
            // Update part properties
            part.name = partName
            part.partDescription = partDescription
            part.materialName = materialName
            part.materialColor = materialColor

            if let densityValue = Double(density) {
                part.density = densityValue
            }

            part.manufacturingNotes = manufacturingNotes
            part.touch()

            // Save to database
            try modelContext.save()

            hasUnsavedChanges = false
            successMessage = "Changes saved successfully"

            // Clear success message after delay
            Task {
                try? await Task.sleep(for: .seconds(2))
                successMessage = nil
            }
        } catch {
            errorMessage = "Failed to save changes: \(error.localizedDescription)"
        }

        isLoading = false
    }

    /// Discard changes
    public func discardChanges() {
        loadPartDetails()
    }

    // MARK: - Validation

    /// Validate current inputs
    public func validate() -> Bool {
        // Clear previous errors
        errorMessage = nil

        // Validate part name
        let nameValidation = ValidationUtilities.validatePartName(partName)
        if !nameValidation.isValid {
            errorMessage = nameValidation.message
            return false
        }

        // Validate material name
        if !materialName.isEmpty {
            let materialValidation = ValidationUtilities.validateMaterialName(materialName)
            if !materialValidation.isValid {
                errorMessage = materialValidation.message
                return false
            }
        }

        // Validate density
        if let densityValue = Double(density) {
            let densityValidation = ValidationUtilities.validateDensity(densityValue)
            if !densityValidation.isValid {
                errorMessage = densityValidation.message
                return false
            }
        } else if !density.isEmpty {
            errorMessage = "Density must be a valid number"
            return false
        }

        return true
    }

    // MARK: - Computed Properties

    public var hasPart: Bool {
        return selectedPart != nil
    }

    public var canSave: Bool {
        return hasPart && hasUnsavedChanges && errorMessage == nil
    }

    public var geometryInfo: [String: String] {
        guard let part = selectedPart else { return [:] }

        return [
            "Volume": volume,
            "Surface Area": surfaceArea,
            "Mass": mass,
            "Bounding Box": boundingBox,
            "Centroid X": part.centroidX.formatted(decimalPlaces: 2),
            "Centroid Y": part.centroidY.formatted(decimalPlaces: 2),
            "Centroid Z": part.centroidZ.formatted(decimalPlaces: 2)
        ]
    }

    public var materialInfo: [String: String] {
        guard let part = selectedPart else { return [:] }

        return [
            "Material": materialName.isEmpty ? "Not specified" : materialName,
            "Color": materialColor.isEmpty ? "Default" : materialColor,
            "Density": "\(part.density.formatted(decimalPlaces: 2)) g/cm³",
            "Finish": part.finish.isEmpty ? "Not specified" : part.finish
        ]
    }

    public var manufacturingInfo: [String: String] {
        guard let part = selectedPart else { return [:] }

        return [
            "Process Type": part.manufacturingProcess.isEmpty ? "Not specified" : part.manufacturingProcess,
            "Notes": manufacturingNotes.isEmpty ? "None" : manufacturingNotes,
            "Status": part.status
        ]
    }

    public var qualityInfo: [String: String] {
        guard let part = selectedPart else { return [:] }

        var info: [String: String] = [:]

        if !part.tolerances.isEmpty {
            info["Tolerances"] = part.tolerances
        }

        if part.qualityScore > 0 {
            info["Quality Score"] = "\(Int(part.qualityScore))%"
        }

        return info.isEmpty ? ["Status": "No quality data"] : info
    }
}
