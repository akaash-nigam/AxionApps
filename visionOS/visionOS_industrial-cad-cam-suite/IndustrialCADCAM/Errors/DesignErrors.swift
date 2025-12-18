import Foundation

/// Errors related to design operations
public enum DesignError: LocalizedError {

    // MARK: - Project Errors

    case projectNotFound(id: UUID)
    case projectNameTooLong(maxLength: Int)
    case projectNameInvalid(name: String)
    case projectAlreadyExists(name: String)
    case projectCreationFailed(reason: String)
    case projectDeletionFailed(reason: String)
    case projectSaveFailed(reason: String)

    // MARK: - Part Errors

    case partNotFound(id: UUID)
    case partNameTooLong(maxLength: Int)
    case partNameInvalid(name: String)
    case partCreationFailed(reason: String)
    case partDeletionFailed(reason: String)
    case partUpdateFailed(reason: String)
    case invalidGeometry(reason: String)
    case geometryDataCorrupted

    // MARK: - Assembly Errors

    case assemblyNotFound(id: UUID)
    case assemblyCreationFailed(reason: String)
    case assemblyTooLarge(partCount: Int, maxParts: Int)
    case interferenceDetected(count: Int)
    case missingConstraints
    case invalidAssemblyStructure(reason: String)

    // MARK: - Dimension Errors

    case dimensionOutOfRange(value: Double, min: Double, max: Double)
    case negativeDimension(value: Double)
    case zeroDimension
    case invalidBoundingBox

    // MARK: - Material Errors

    case invalidMaterial(name: String)
    case materialNotFound(name: String)
    case invalidDensity(value: Double)
    case materialPropertyMissing(property: String)

    // MARK: - Operation Errors

    case operationFailed(operation: String, reason: String)
    case unsupportedOperation(operation: String)
    case operationCancelled(operation: String)
    case operationTimeout(operation: String)
    case invalidOperationParameters(operation: String, reason: String)

    // MARK: - Boolean Operation Errors

    case booleanOperationFailed(type: String, reason: String)
    case insufficientPartsForBoolean(required: Int, provided: Int)
    case incompatibleGeometry(reason: String)

    // MARK: - Sketch Errors

    case sketchNotClosed
    case sketchTooFewPoints(minimum: Int)
    case sketchSelfIntersecting
    case sketchInvalid(reason: String)

    // MARK: - Transform Errors

    case invalidTransform(reason: String)
    case transformOutOfBounds
    case invalidRotationAxis

    // MARK: - Validation Errors

    case validationFailed(errors: [String])
    case geometryValidationFailed(reason: String)
    case topologyInvalid(reason: String)

    // MARK: - LocalizedError Implementation

    public var errorDescription: String? {
        switch self {
        // Project Errors
        case .projectNotFound(let id):
            return "Project with ID \(id.shortID) not found"
        case .projectNameTooLong(let maxLength):
            return "Project name exceeds maximum length of \(maxLength) characters"
        case .projectNameInvalid(let name):
            return "Invalid project name: '\(name)'"
        case .projectAlreadyExists(let name):
            return "A project named '\(name)' already exists"
        case .projectCreationFailed(let reason):
            return "Failed to create project: \(reason)"
        case .projectDeletionFailed(let reason):
            return "Failed to delete project: \(reason)"
        case .projectSaveFailed(let reason):
            return "Failed to save project: \(reason)"

        // Part Errors
        case .partNotFound(let id):
            return "Part with ID \(id.shortID) not found"
        case .partNameTooLong(let maxLength):
            return "Part name exceeds maximum length of \(maxLength) characters"
        case .partNameInvalid(let name):
            return "Invalid part name: '\(name)'"
        case .partCreationFailed(let reason):
            return "Failed to create part: \(reason)"
        case .partDeletionFailed(let reason):
            return "Failed to delete part: \(reason)"
        case .partUpdateFailed(let reason):
            return "Failed to update part: \(reason)"
        case .invalidGeometry(let reason):
            return "Invalid geometry: \(reason)"
        case .geometryDataCorrupted:
            return "Geometry data is corrupted"

        // Assembly Errors
        case .assemblyNotFound(let id):
            return "Assembly with ID \(id.shortID) not found"
        case .assemblyCreationFailed(let reason):
            return "Failed to create assembly: \(reason)"
        case .assemblyTooLarge(let partCount, let maxParts):
            return "Assembly has \(partCount) parts, exceeds maximum of \(maxParts)"
        case .interferenceDetected(let count):
            return "Detected \(count) interference(s) in assembly"
        case .missingConstraints:
            return "Assembly is missing required constraints"
        case .invalidAssemblyStructure(let reason):
            return "Invalid assembly structure: \(reason)"

        // Dimension Errors
        case .dimensionOutOfRange(let value, let min, let max):
            return "Dimension \(value) is out of range (\(min) - \(max))"
        case .negativeDimension(let value):
            return "Dimension cannot be negative: \(value)"
        case .zeroDimension:
            return "Dimension cannot be zero"
        case .invalidBoundingBox:
            return "Invalid bounding box"

        // Material Errors
        case .invalidMaterial(let name):
            return "Invalid material: '\(name)'"
        case .materialNotFound(let name):
            return "Material '\(name)' not found"
        case .invalidDensity(let value):
            return "Invalid density: \(value) g/cm³"
        case .materialPropertyMissing(let property):
            return "Material property '\(property)' is missing"

        // Operation Errors
        case .operationFailed(let operation, let reason):
            return "\(operation) failed: \(reason)"
        case .unsupportedOperation(let operation):
            return "Operation '\(operation)' is not supported"
        case .operationCancelled(let operation):
            return "Operation '\(operation)' was cancelled"
        case .operationTimeout(let operation):
            return "Operation '\(operation)' timed out"
        case .invalidOperationParameters(let operation, let reason):
            return "Invalid parameters for '\(operation)': \(reason)"

        // Boolean Operation Errors
        case .booleanOperationFailed(let type, let reason):
            return "Boolean \(type) operation failed: \(reason)"
        case .insufficientPartsForBoolean(let required, let provided):
            return "Boolean operation requires \(required) parts, only \(provided) provided"
        case .incompatibleGeometry(let reason):
            return "Incompatible geometry: \(reason)"

        // Sketch Errors
        case .sketchNotClosed:
            return "Sketch must be closed"
        case .sketchTooFewPoints(let minimum):
            return "Sketch requires at least \(minimum) points"
        case .sketchSelfIntersecting:
            return "Sketch cannot self-intersect"
        case .sketchInvalid(let reason):
            return "Invalid sketch: \(reason)"

        // Transform Errors
        case .invalidTransform(let reason):
            return "Invalid transform: \(reason)"
        case .transformOutOfBounds:
            return "Transform result is out of bounds"
        case .invalidRotationAxis:
            return "Invalid rotation axis"

        // Validation Errors
        case .validationFailed(let errors):
            return "Validation failed: \(errors.joined(separator: ", "))"
        case .geometryValidationFailed(let reason):
            return "Geometry validation failed: \(reason)"
        case .topologyInvalid(let reason):
            return "Invalid topology: \(reason)"
        }
    }

    public var failureReason: String? {
        return errorDescription
    }

    public var recoverySuggestion: String? {
        switch self {
        case .projectNameTooLong:
            return "Choose a shorter project name"
        case .projectNameInvalid:
            return "Use only letters, numbers, and basic punctuation"
        case .projectAlreadyExists:
            return "Choose a different name or delete the existing project"
        case .negativeDimension, .zeroDimension:
            return "Provide a positive dimension value"
        case .dimensionOutOfRange:
            return "Adjust the dimension to be within the valid range"
        case .sketchNotClosed:
            return "Connect the last point to the first point"
        case .sketchTooFewPoints:
            return "Add more points to the sketch"
        case .interferenceDetected:
            return "Adjust part positions to eliminate interferences"
        default:
            return nil
        }
    }
}
