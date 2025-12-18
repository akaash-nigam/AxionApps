import Foundation

/// Constants for design operations
public enum DesignConstants {

    // MARK: - Default Values

    public static let defaultUnits = "metric"
    public static let defaultDensity = 7.85 // Steel in g/cm³
    public static let defaultMaterial = "Steel"
    public static let defaultColor = "#808080" // Gray

    // MARK: - Dimension Limits

    public static let minDimension = 0.001 // 0.001 mm
    public static let maxDimension = 100_000.0 // 100 meters in mm
    public static let defaultDimension = 100.0 // mm

    // MARK: - Tolerance

    public static let defaultTolerance = 0.1 // mm
    public static let minTolerance = 0.001 // mm
    public static let maxTolerance = 10.0 // mm

    // MARK: - Material Density Ranges (g/cm³)

    public static let minDensity = 0.1 // Foam
    public static let maxDensity = 25.0 // Tungsten

    public struct MaterialDensities {
        public static let aluminum = 2.70
        public static let steel = 7.85
        public static let stainlessSteel = 8.00
        public static let titanium = 4.51
        public static let brass = 8.40
        public static let copper = 8.96
        public static let plastic = 1.20
        public static let wood = 0.60
    }

    // MARK: - Geometric Limits

    public static let minVolume = 0.001 // mm³
    public static let maxVolume = 1_000_000_000_000.0 // mm³ (1 m³)

    public static let minSurfaceArea = 0.01 // mm²
    public static let maxSurfaceArea = 100_000_000.0 // mm² (100 m²)

    // MARK: - Primitive Defaults

    public struct PrimitiveDefaults {
        public static let cubeSize = 100.0 // mm
        public static let sphereDiameter = 100.0 // mm
        public static let cylinderDiameter = 100.0 // mm
        public static let cylinderHeight = 100.0 // mm
        public static let coneBaseDiameter = 100.0 // mm
        public static let coneHeight = 100.0 // mm
    }

    // MARK: - Sketch Constants

    public static let minSketchPoints = 3
    public static let maxSketchPoints = 1000
    public static let snapDistance = 0.1 // mm
    public static let gridSpacing = 10.0 // mm

    // MARK: - Extrusion/Revolve

    public static let minExtrusionHeight = 0.1 // mm
    public static let maxExtrusionHeight = 10_000.0 // mm
    public static let defaultExtrusionHeight = 10.0 // mm

    public static let minRevolutionAngle = 1.0 // degrees
    public static let maxRevolutionAngle = 360.0 // degrees
    public static let defaultRevolutionAngle = 360.0 // degrees

    // MARK: - Assembly

    public static let maxAssemblyDepth = 10 // Nesting levels
    public static let interferenceCheckTolerance = 0.01 // mm

    // MARK: - Quality

    public static let minQualityScore = 0.0
    public static let maxQualityScore = 100.0
    public static let targetQualityScore = 90.0

    // MARK: - File Export

    public struct ExportSettings {
        public static let defaultStepVersion = "AP214"
        public static let defaultIgesVersion = "5.3"
        public static let defaultSTLUnits = "mm"
        public static let defaultSTLBinary = true
    }

    // MARK: - Visualization

    public static let defaultLineWidth: Float = 1.0
    public static let highlightLineWidth: Float = 2.0
    public static let selectionLineWidth: Float = 3.0

    public static let defaultPointSize: Float = 3.0
    public static let highlightPointSize: Float = 5.0

    // MARK: - LOD (Level of Detail)

    public struct LODSettings {
        public static let nearDistance: Float = 0.5 // meters
        public static let mediumDistance: Float = 2.0 // meters
        public static let farDistance: Float = 10.0 // meters

        public static let highPolyCount = 100_000
        public static let mediumPolyCount = 10_000
        public static let lowPolyCount = 1_000
    }
}
