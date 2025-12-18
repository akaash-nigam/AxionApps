import Foundation

/// Constants for manufacturing operations
public enum ManufacturingConstants {

    // MARK: - CNC Parameters

    public struct CNCDefaults {
        public static let feedRate = 1000.0 // mm/min
        public static let spindleSpeed = 3000.0 // RPM
        public static let depthOfCut = 2.0 // mm
        public static let stepover = 0.5 // Tool diameter ratio
    }

    public struct CNCLimits {
        public static let minFeedRate = 1.0 // mm/min
        public static let maxFeedRate = 10_000.0 // mm/min

        public static let minSpindleSpeed = 100.0 // RPM
        public static let maxSpindleSpeed = 30_000.0 // RPM

        public static let minDepthOfCut = 0.1 // mm
        public static let maxDepthOfCut = 20.0 // mm

        public static let minStepover = 0.1
        public static let maxStepover = 1.0
    }

    // MARK: - Tool Parameters

    public struct ToolDefaults {
        public static let diameter = 10.0 // mm
        public static let length = 50.0 // mm
        public static let fluteCount = 4
        public static let material = "Carbide"
    }

    public struct ToolLimits {
        public static let minDiameter = 0.1 // mm
        public static let maxDiameter = 100.0 // mm

        public static let minLength = 1.0 // mm
        public static let maxLength = 500.0 // mm

        public static let minFluteCount = 1
        public static let maxFluteCount = 12
    }

    // MARK: - Machining Processes

    public struct ProcessTypes {
        public static let milling = "CNC_Milling"
        public static let turning = "CNC_Turning"
        public static let drilling = "Drilling"
        public static let tapping = "Tapping"
        public static let boring = "Boring"
        public static let grinding = "Grinding"
    }

    // MARK: - Material Removal Rates

    public struct MRRLimits {
        public static let maxMaterialRemovalPercentage = 90.0
        public static let warningMaterialRemovalPercentage = 75.0
    }

    // MARK: - Simulation

    public struct SimulationSettings {
        public static let defaultStepSize = 0.1 // mm
        public static let maxSimulationSteps = 100_000
        public static let collisionCheckInterval = 10 // steps
    }

    // MARK: - Cost Estimation

    public struct CostFactors {
        public static let machineCostPerHour = 50.0 // USD
        public static let laborCostPerHour = 75.0 // USD
        public static let setupCost = 100.0 // USD
        public static let toolCostPerChange = 10.0 // USD
        public static let materialMarkup = 1.25 // 25% markup
    }

    // MARK: - Quality Control

    public struct QualityStandards {
        public static let standardTolerance = 0.1 // mm
        public static let precisionTolerance = 0.01 // mm
        public static let roughTolerance = 0.5 // mm

        public static let standardSurfaceFinish = 3.2 // Ra µm
        public static let finishSurfaceFinish = 0.8 // Ra µm
        public static let roughSurfaceFinish = 12.5 // Ra µm
    }

    // MARK: - G-Code

    public struct GCodeSettings {
        public static let coordinateSystem = "G54"
        public static let unitSystem = "G21" // Metric
        public static let absolutePositioning = "G90"
        public static let feedRateMode = "G94" // Units per minute
    }

    // MARK: - Safety Margins

    public struct SafetyMargins {
        public static let rapidHeight = 10.0 // mm
        public static let safetyDistance = 5.0 // mm
        public static let retractDistance = 2.0 // mm
    }

    // MARK: - Coolant

    public struct CoolantSettings {
        public static let floodCoolantCode = "M8"
        public static let mistCoolantCode = "M7"
        public static let coolantOffCode = "M9"
    }

    // MARK: - Chip Load

    public struct ChipLoadRanges {
        // Chip load in mm/tooth for different materials
        public static let aluminumMin = 0.05
        public static let aluminumMax = 0.15

        public static let steelMin = 0.03
        public static let steelMax = 0.10

        public static let stainlessMin = 0.02
        public static let stainlessMax = 0.08

        public static let titaniumMin = 0.01
        public static let titaniumMax = 0.05
    }
}
