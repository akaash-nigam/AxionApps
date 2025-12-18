import Foundation

/// Accessibility identifiers for UI testing and VoiceOver
public enum AccessibilityIdentifiers {

    // MARK: - Control Panel

    public enum ControlPanel {
        public static let window = "control-panel"
        public static let projectList = "project-list"
        public static let newProjectButton = "new-project-button"
        public static let searchField = "project-search-field"
        public static let sortButton = "sort-projects-button"
        public static let refreshButton = "refresh-projects-button"
        public static let projectRow = "project-row"
    }

    // MARK: - Properties Inspector

    public enum PropertiesInspector {
        public static let window = "properties-inspector"
        public static let generalTab = "general-tab"
        public static let geometryTab = "geometry-tab"
        public static let materialTab = "material-tab"
        public static let manufacturingTab = "manufacturing-tab"
        public static let qualityTab = "quality-tab"
        public static let partNameField = "part-name-field"
        public static let descriptionField = "description-field"
        public static let saveButton = "save-properties-button"
        public static let discardButton = "discard-changes-button"
    }

    // MARK: - Part Library

    public enum PartLibrary {
        public static let window = "part-library"
        public static let categoryList = "category-list"
        public static let partGrid = "part-grid"
        public static let searchField = "library-search-field"
        public static let partCard = "part-card"
        public static let insertButton = "insert-part-button"
    }

    // MARK: - Part Viewer

    public enum PartViewer {
        public static let volume = "part-viewer-volume"
        public static let partEntity = "part-entity"
        public static let gridFloor = "grid-floor"
        public static let coordinateAxes = "coordinate-axes"
        public static let shadingModeButton = "shading-mode-button"
        public static let viewPresetButton = "view-preset-button"
        public static let resetCameraButton = "reset-camera-button"
        public static let measurementButton = "measurement-button"
    }

    // MARK: - Assembly Explorer

    public enum AssemblyExplorer {
        public static let volume = "assembly-explorer-volume"
        public static let assemblyTree = "assembly-tree"
        public static let explosionSlider = "explosion-slider"
        public static let highlightModeButton = "highlight-mode-button"
        public static let bomButton = "bom-button"
        public static let validateButton = "validate-assembly-button"
    }

    // MARK: - Design Studio

    public enum DesignStudio {
        public static let space = "design-studio-space"
        public static let toolPalette = "tool-palette"
        public static let selectTool = "select-tool"
        public static let moveTool = "move-tool"
        public static let rotateTool = "rotate-tool"
        public static let scaleTool = "scale-tool"
        public static let sketchTool = "sketch-tool"
        public static let extrudeTool = "extrude-tool"
        public static let revolveTool = "revolve-tool"
        public static let booleanTool = "boolean-tool"
        public static let undoButton = "undo-button"
        public static let redoButton = "redo-button"
        public static let gridToggle = "grid-toggle"
        public static let snapToggle = "snap-toggle"
    }

    // MARK: - Common

    public enum Common {
        public static let closeButton = "close-button"
        public static let cancelButton = "cancel-button"
        public static let saveButton = "save-button"
        public static let deleteButton = "delete-button"
        public static let editButton = "edit-button"
        public static let backButton = "back-button"
        public static let forwardButton = "forward-button"
        public static let moreButton = "more-button"
        public static let settingsButton = "settings-button"
        public static let helpButton = "help-button"
    }

    // MARK: - Alerts and Sheets

    public enum Alerts {
        public static let confirmDeleteAlert = "confirm-delete-alert"
        public static let errorAlert = "error-alert"
        public static let successAlert = "success-alert"
        public static let warningAlert = "warning-alert"
        public static let confirmButton = "confirm-button"
        public static let cancelButton = "alert-cancel-button"
    }

    public enum Sheets {
        public static let newProjectSheet = "new-project-sheet"
        public static let projectNameField = "new-project-name-field"
        public static let projectDescriptionField = "new-project-description-field"
        public static let createButton = "create-project-button"
    }
}
