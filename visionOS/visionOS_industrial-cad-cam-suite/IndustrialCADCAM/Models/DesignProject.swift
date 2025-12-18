import Foundation
import SwiftData

@Model
final class DesignProject {
    @Attribute(.unique) var id: UUID
    var name: String
    var projectDescription: String
    var createdDate: Date
    var modifiedDate: Date
    var version: String
    var units: String // "metric" or "imperial"

    @Relationship(deleteRule: .cascade)
    var parts: [Part]

    @Relationship(deleteRule: .cascade)
    var assemblies: [Assembly]

    @Relationship
    var collaborators: [User]

    // Large binary data stored externally
    @Attribute(.externalStorage)
    var thumbnailData: Data?

    // Project metadata
    var tags: [String]
    var status: String // "draft", "in_progress", "review", "approved"

    init(
        name: String,
        description: String = "",
        units: String = "metric"
    ) {
        self.id = UUID()
        self.name = name
        self.projectDescription = description
        self.createdDate = Date()
        self.modifiedDate = Date()
        self.version = "1.0.0"
        self.units = units
        self.parts = []
        self.assemblies = []
        self.collaborators = []
        self.tags = []
        self.status = "draft"
    }

    // MARK: - Computed Properties
    var partCount: Int {
        parts.count
    }

    var assemblyCount: Int {
        assemblies.count
    }

    // MARK: - Methods
    func addPart(_ part: Part) {
        parts.append(part)
        touch()
    }

    func removePart(_ part: Part) {
        if let index = parts.firstIndex(where: { $0.id == part.id }) {
            parts.remove(at: index)
            touch()
        }
    }

    func addAssembly(_ assembly: Assembly) {
        assemblies.append(assembly)
        touch()
    }

    func touch() {
        modifiedDate = Date()
    }
}
