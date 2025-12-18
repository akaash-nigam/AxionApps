import Foundation

/// Errors related to manufacturing operations
public enum ManufacturingError: LocalizedError {

    // MARK: - Process Errors

    case processNotFound(id: UUID)
    case processCreationFailed(reason: String)
    case invalidProcessType(type: String)
    case unsupportedProcessForMaterial(process: String, material: String)
    case processParametersInvalid(reason: String)

    // MARK: - Toolpath Errors

    case toolpathGenerationFailed(reason: String)
    case toolpathInvalid(reason: String)
    case toolpathCollision(at: String)
    case toolpathOutOfBounds

    // MARK: - Tool Errors

    case toolNotFound(id: String)
    case invalidToolDiameter(value: Double)
    case invalidToolLength(value: Double)
    case toolWearExceedsLimit(wear: Double, limit: Double)
    case incompatibleTool(tool: String, material: String)

    // MARK: - Feed and Speed Errors

    case invalidFeedRate(value: Double)
    case feedRateTooHigh(value: Double, maximum: Double)
    case feedRateTooLow(value: Double, minimum: Double)
    case invalidSpindleSpeed(value: Double)
    case spindleSpeedOutOfRange(value: Double, min: Double, max: Double)

    // MARK: - Depth of Cut Errors

    case invalidDepthOfCut(value: Double)
    case depthOfCutTooLarge(value: Double, maximum: Double)
    case stepoverTooLarge(value: Double, maximum: Double)

    // MARK: - Simulation Errors

    case simulationFailed(reason: String)
    case simulationTimeout
    case simulationDataCorrupted
    case invalidSimulationParameters(reason: String)

    // MARK: - Cost Estimation Errors

    case costEstimationFailed(reason: String)
    case missingCostData(component: String)
    case invalidCostParameters(reason: String)

    // MARK: - Material Removal Errors

    case excessiveMaterialRemoval(percentage: Double)
    case insufficientStock
    case invalidStockDimensions

    // MARK: - NC Code Errors

    case ncCodeGenerationFailed(reason: String)
    case invalidNCCode(line: Int, reason: String)
    case unsupportedGCode(code: String)

    // MARK: - LocalizedError Implementation

    public var errorDescription: String? {
        switch self {
        case .processNotFound(let id):
            return "Manufacturing process with ID \(id.shortID) not found"
        case .processCreationFailed(let reason):
            return "Failed to create manufacturing process: \(reason)"
        case .invalidProcessType(let type):
            return "Invalid process type: '\(type)'"
        case .unsupportedProcessForMaterial(let process, let material):
            return "Process '\(process)' is not supported for material '\(material)'"
        case .processParametersInvalid(let reason):
            return "Invalid process parameters: \(reason)"

        case .toolpathGenerationFailed(let reason):
            return "Toolpath generation failed: \(reason)"
        case .toolpathInvalid(let reason):
            return "Invalid toolpath: \(reason)"
        case .toolpathCollision(let location):
            return "Toolpath collision detected at: \(location)"
        case .toolpathOutOfBounds:
            return "Toolpath exceeds machine bounds"

        case .toolNotFound(let id):
            return "Tool '\(id)' not found in tool library"
        case .invalidToolDiameter(let value):
            return "Invalid tool diameter: \(value) mm"
        case .invalidToolLength(let value):
            return "Invalid tool length: \(value) mm"
        case .toolWearExceedsLimit(let wear, let limit):
            return "Tool wear \(wear) mm exceeds limit of \(limit) mm"
        case .incompatibleTool(let tool, let material):
            return "Tool '\(tool)' is incompatible with material '\(material)'"

        case .invalidFeedRate(let value):
            return "Invalid feed rate: \(value) mm/min"
        case .feedRateTooHigh(let value, let maximum):
            return "Feed rate \(value) mm/min exceeds maximum of \(maximum) mm/min"
        case .feedRateTooLow(let value, let minimum):
            return "Feed rate \(value) mm/min is below minimum of \(minimum) mm/min"
        case .invalidSpindleSpeed(let value):
            return "Invalid spindle speed: \(value) RPM"
        case .spindleSpeedOutOfRange(let value, let min, let max):
            return "Spindle speed \(value) RPM is out of range (\(min) - \(max) RPM)"

        case .invalidDepthOfCut(let value):
            return "Invalid depth of cut: \(value) mm"
        case .depthOfCutTooLarge(let value, let maximum):
            return "Depth of cut \(value) mm exceeds maximum of \(maximum) mm"
        case .stepoverTooLarge(let value, let maximum):
            return "Stepover \(value) mm exceeds maximum of \(maximum) mm"

        case .simulationFailed(let reason):
            return "Machining simulation failed: \(reason)"
        case .simulationTimeout:
            return "Machining simulation timed out"
        case .simulationDataCorrupted:
            return "Simulation data is corrupted"
        case .invalidSimulationParameters(let reason):
            return "Invalid simulation parameters: \(reason)"

        case .costEstimationFailed(let reason):
            return "Cost estimation failed: \(reason)"
        case .missingCostData(let component):
            return "Missing cost data for: \(component)"
        case .invalidCostParameters(let reason):
            return "Invalid cost parameters: \(reason)"

        case .excessiveMaterialRemoval(let percentage):
            return "Excessive material removal: \(percentage.formatted(decimalPlaces: 1))%"
        case .insufficientStock:
            return "Insufficient stock material"
        case .invalidStockDimensions:
            return "Invalid stock dimensions"

        case .ncCodeGenerationFailed(let reason):
            return "NC code generation failed: \(reason)"
        case .invalidNCCode(let line, let reason):
            return "Invalid NC code at line \(line): \(reason)"
        case .unsupportedGCode(let code):
            return "Unsupported G-code: \(code)"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .feedRateTooHigh:
            return "Reduce the feed rate to within machine limits"
        case .feedRateTooLow:
            return "Increase the feed rate to improve efficiency"
        case .depthOfCutTooLarge:
            return "Reduce the depth of cut or use multiple passes"
        case .toolWearExceedsLimit:
            return "Replace the tool before continuing"
        case .toolpathCollision:
            return "Adjust tool approach angle or workpiece orientation"
        case .excessiveMaterialRemoval:
            return "Use roughing operations before finishing"
        case .insufficientStock:
            return "Increase stock dimensions or reduce part size"
        default:
            return nil
        }
    }
}
