import Foundation

/// Accessibility labels for VoiceOver and assistive technologies
public enum AccessibilityLabels {

    // MARK: - Control Panel

    public enum ControlPanel {
        public static func projectRow(name: String, partCount: Int) -> String {
            return "Project \(name), \(partCount) parts"
        }

        public static let newProject = "Create new project"
        public static let searchProjects = "Search projects"
        public static let sortProjects = "Sort projects"
        public static let refreshProjects = "Refresh project list"
    }

    // MARK: - Properties Inspector

    public enum PropertiesInspector {
        public static let partName = "Part name"
        public static let description = "Part description"
        public static let material = "Material name"
        public static let density = "Material density in grams per cubic centimeter"
        public static let volume = "Part volume in cubic millimeters"
        public static let mass = "Part mass in grams"
        public static let save = "Save changes to part properties"
        public static let discard = "Discard changes"
    }

    // MARK: - Part Library

    public enum PartLibrary {
        public static func partCard(name: String, category: String) -> String {
            return "\(name), \(category)"
        }

        public static let search = "Search part library"
        public static let insert = "Insert selected part into project"

        public static func category(_ name: String, count: Int) -> String {
            return "\(name) category, \(count) parts"
        }
    }

    // MARK: - 3D Views

    public enum ThreeDView {
        public static let partEntity = "Three dimensional part view"
        public static let assembly = "Three dimensional assembly view"
        public static let gridFloor = "Reference grid"
        public static let coordinateAxes = "Coordinate axes, X Y Z"

        public static func rotation(degrees: Double) -> String {
            return "Rotated \(Int(degrees)) degrees"
        }

        public static func zoom(distance: Float) -> String {
            return "Zoomed to \(distance.formatted(decimalPlaces: 1)) meters"
        }
    }

    // MARK: - Tools

    public enum Tools {
        public static let select = "Select tool, tap to select parts"
        public static let move = "Move tool, drag to move parts"
        public static let rotate = "Rotate tool, drag to rotate parts"
        public static let scale = "Scale tool, pinch to scale parts"
        public static let sketch = "Sketch tool, create two dimensional profiles"
        public static let extrude = "Extrude tool, create three dimensional shapes from profiles"
        public static let revolve = "Revolve tool, create shapes by rotating profiles"
        public static let boolean = "Boolean tool, combine or subtract parts"
        public static let measure = "Measure tool, measure distances and angles"

        public static func toolActive(_ name: String) -> String {
            return "\(name) tool active"
        }
    }

    // MARK: - Measurements

    public enum Measurements {
        public static func distance(_ value: Double, unit: String) -> String {
            return "Distance: \(value.formatted(decimalPlaces: 2)) \(unit)"
        }

        public static func angle(_ degrees: Double) -> String {
            return "Angle: \(degrees.formatted(decimalPlaces: 1)) degrees"
        }

        public static func area(_ value: Double, unit: String) -> String {
            return "Area: \(value.formatted(decimalPlaces: 2)) square \(unit)"
        }
    }

    // MARK: - Assembly

    public enum Assembly {
        public static func partCount(_ count: Int) -> String {
            return "\(count) \(count == 1 ? "part" : "parts") in assembly"
        }

        public static func explosion(_ factor: Float) -> String {
            let percentage = Int(factor * 100)
            return "Assembly exploded \(percentage) percent"
        }

        public static func interference(_ count: Int) -> String {
            if count == 0 {
                return "No interferences detected"
            } else {
                return "\(count) \(count == 1 ? "interference" : "interferences") detected"
            }
        }
    }

    // MARK: - Status

    public enum Status {
        public static let loading = "Loading..."
        public static let saving = "Saving..."
        public static let processing = "Processing..."
        public static let complete = "Complete"
        public static let failed = "Failed"

        public static func progress(_ percentage: Int) -> String {
            return "\(percentage) percent complete"
        }
    }

    // MARK: - Buttons

    public enum Buttons {
        public static let close = "Close"
        public static let cancel = "Cancel"
        public static let save = "Save"
        public static let delete = "Delete"
        public static let edit = "Edit"
        public static let done = "Done"
        public static let back = "Go back"
        public static let forward = "Go forward"
        public static let more = "More options"
        public static let settings = "Settings"
        public static let help = "Help"
    }

    // MARK: - Alerts

    public enum Alerts {
        public static func confirmDelete(itemName: String) -> String {
            return "Are you sure you want to delete \(itemName)? This action cannot be undone."
        }

        public static func error(_ message: String) -> String {
            return "Error: \(message)"
        }

        public static func success(_ message: String) -> String {
            return "Success: \(message)"
        }

        public static func warning(_ message: String) -> String {
            return "Warning: \(message)"
        }
    }

    // MARK: - Manufacturing

    public enum Manufacturing {
        public static func process(_ type: String) -> String {
            return "Manufacturing process: \(type)"
        }

        public static func feedRate(_ value: Double) -> String {
            return "Feed rate: \(value.formatted(decimalPlaces: 0)) millimeters per minute"
        }

        public static func spindleSpeed(_ rpm: Double) -> String {
            return "Spindle speed: \(rpm.formatted(decimalPlaces: 0)) revolutions per minute"
        }

        public static func estimatedCost(_ cost: Double) -> String {
            return "Estimated cost: \(cost.formatted(decimalPlaces: 2)) dollars"
        }

        public static func estimatedTime(_ hours: Double) -> String {
            let mins = Int(hours * 60)
            return "Estimated time: \(mins) minutes"
        }
    }
}
