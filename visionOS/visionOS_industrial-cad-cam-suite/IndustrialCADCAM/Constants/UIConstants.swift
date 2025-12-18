import Foundation

/// Constants for UI and spatial design
public enum UIConstants {

    // MARK: - Spacing

    public struct Spacing {
        public static let xxsmall: CGFloat = 4
        public static let xsmall: CGFloat = 8
        public static let small: CGFloat = 12
        public static let medium: CGFloat = 16
        public static let large: CGFloat = 24
        public static let xlarge: CGFloat = 32
        public static let xxlarge: CGFloat = 48
    }

    // MARK: - Corner Radius

    public struct CornerRadius {
        public static let small: CGFloat = 4
        public static let medium: CGFloat = 8
        public static let large: CGFloat = 12
        public static let xlarge: CGFloat = 16
    }

    // MARK: - Window Sizes

    public struct WindowSize {
        public static let controlPanelWidth: CGFloat = 400
        public static let controlPanelHeight: CGFloat = 600

        public static let inspectorWidth: CGFloat = 350
        public static let inspectorHeight: CGFloat = 500

        public static let libraryWidth: CGFloat = 450
        public static let libraryHeight: CGFloat = 550

        public static let minWidth: CGFloat = 300
        public static let minHeight: CGFloat = 400
    }

    // MARK: - Volumetric Sizes (meters in RealityKit)

    public struct VolumetricSize {
        public static let partViewerWidth: Float = 0.8
        public static let partViewerHeight: Float = 0.8
        public static let partViewerDepth: Float = 0.8

        public static let assemblyExplorerWidth: Float = 1.2
        public static let assemblyExplorerHeight: Float = 1.2
        public static let assemblyExplorerDepth: Float = 1.2

        public static let simulationWidth: Float = 1.0
        public static let simulationHeight: Float = 1.0
        public static let simulationDepth: Float = 1.0
    }

    // MARK: - Spatial Zones (meters)

    public struct SpatialZones {
        // Near zone: 0.3-0.6m
        public static let nearMin: Float = 0.3
        public static let nearMax: Float = 0.6

        // Primary zone: 0.6-1.5m
        public static let primaryMin: Float = 0.6
        public static let primaryMax: Float = 1.5

        // Extended zone: 1.5-3.0m
        public static let extendedMin: Float = 1.5
        public static let extendedMax: Float = 3.0

        // Far zone: 3.0-5.0m
        public static let farMin: Float = 3.0
        public static let farMax: Float = 5.0
    }

    // MARK: - Animation Durations

    public struct AnimationDuration {
        public static let fast: TimeInterval = 0.2
        public static let normal: TimeInterval = 0.3
        public static let slow: TimeInterval = 0.5
        public static let verySlow: TimeInterval = 1.0
    }

    // MARK: - Font Sizes

    public struct FontSize {
        public static let caption: CGFloat = 12
        public static let body: CGFloat = 14
        public static let title: CGFloat = 18
        public static let heading: CGFloat = 24
        public static let largeTitle: CGFloat = 32
    }

    // MARK: - Icon Sizes

    public struct IconSize {
        public static let small: CGFloat = 16
        public static let medium: CGFloat = 24
        public static let large: CGFloat = 32
        public static let xlarge: CGFloat = 48
    }

    // MARK: - Opacity

    public struct Opacity {
        public static let disabled: Double = 0.5
        public static let placeholder: Double = 0.6
        public static let secondary: Double = 0.7
        public static let hover: Double = 0.9
        public static let full: Double = 1.0
    }

    // MARK: - Grid

    public struct Grid {
        public static let columns = 12
        public static let gutter: CGFloat = 16
        public static let margin: CGFloat = 24
    }

    // MARK: - List

    public struct List {
        public static let rowHeight: CGFloat = 44
        public static let sectionHeaderHeight: CGFloat = 32
        public static let thumbnailSize: CGFloat = 40
    }

    // MARK: - Button

    public struct Button {
        public static let minWidth: CGFloat = 80
        public static let minHeight: CGFloat = 36
        public static let padding: CGFloat = 12
    }

    // MARK: - Text Field

    public struct TextField {
        public static let height: CGFloat = 40
        public static let padding: CGFloat = 12
        public static let borderWidth: CGFloat = 1
    }

    // MARK: - Accessibility

    public struct Accessibility {
        public static let minTouchTarget: CGFloat = 44
        public static let minContrastRatio: Double = 4.5 // WCAG AA
        public static let largeTextContrastRatio: Double = 3.0 // WCAG AA for large text
    }

    // MARK: - 3D View

    public struct ThreeDView {
        public static let nearClipPlane: Float = 0.01
        public static let farClipPlane: Float = 100.0
        public static let fieldOfView: Float = 60.0 // degrees

        public static let cameraMinDistance: Float = 0.5
        public static let cameraMaxDistance: Float = 10.0
        public static let cameraDefaultDistance: Float = 2.0

        public static let rotationSensitivity: Float = 1.0
        public static let zoomSensitivity: Float = 0.1
        public static let panSensitivity: Float = 0.5
    }

    // MARK: - Color Palette

    public struct Colors {
        // Primary colors (hex strings)
        public static let primary = "#007AFF"
        public static let secondary = "#5856D6"
        public static let accent = "#FF9500"

        // Semantic colors
        public static let success = "#34C759"
        public static let warning = "#FF9500"
        public static let error = "#FF3B30"
        public static let info = "#007AFF"

        // Neutral colors
        public static let text = "#000000"
        public static let textSecondary = "#666666"
        public static let background = "#FFFFFF"
        public static let backgroundSecondary = "#F5F5F5"
        public static let border = "#DDDDDD"

        // Material colors for 3D
        public static let defaultMaterial = "#808080"
        public static let selectedMaterial = "#007AFF"
        public static let highlightMaterial = "#FF9500"
        public static let errorMaterial = "#FF3B30"
    }

    // MARK: - Measurements Display

    public struct MeasurementDisplay {
        public static let defaultPrecision = 2
        public static let highPrecision = 3
        public static let lowPrecision = 1

        public static let anglePrecision = 1
        public static let percentagePrecision = 1
    }
}
