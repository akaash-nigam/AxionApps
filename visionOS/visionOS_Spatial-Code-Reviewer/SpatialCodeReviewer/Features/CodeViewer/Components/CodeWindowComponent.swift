//
//  CodeWindowComponent.swift
//  SpatialCodeReviewer
//
//  Created by Claude on 2025-11-24.
//  Story 0.5: Basic 3D Code Window
//

import RealityKit
import SwiftUI

/// Component that represents a code window in 3D space
struct CodeWindowComponent: Component {
    var filePath: String
    var fileName: String
    var language: String
    var lineCount: Int
    var isDirectory: Bool
    var scrollOffset: Float
    var opacity: Float
    var isFocused: Bool

    init(
        filePath: String,
        fileName: String,
        language: String = "text",
        lineCount: Int = 0,
        isDirectory: Bool = false,
        scrollOffset: Float = 0,
        opacity: Float = 0.95,
        isFocused: Bool = false
    ) {
        self.filePath = filePath
        self.fileName = fileName
        self.language = language
        self.lineCount = lineCount
        self.isDirectory = isDirectory
        self.scrollOffset = scrollOffset
        self.opacity = opacity
        self.isFocused = isFocused
    }
}

/// Component for spatial positioning and animation
struct SpatialCodeComponent: Component {
    var targetPosition: SIMD3<Float>
    var targetScale: SIMD3<Float>
    var animationDuration: TimeInterval
    var isInteractive: Bool

    init(
        targetPosition: SIMD3<Float>,
        targetScale: SIMD3<Float> = [1, 1, 1],
        animationDuration: TimeInterval = 0.3,
        isInteractive: Bool = true
    ) {
        self.targetPosition = targetPosition
        self.targetScale = targetScale
        self.animationDuration = animationDuration
        self.isInteractive = isInteractive
    }
}

/// Helper to create CodeWindowEntity
@MainActor
class CodeWindowEntityFactory {
    /// Creates a 3D entity representing a code file
    static func createCodeWindow(
        filePath: String,
        fileName: String,
        isDirectory: Bool,
        position: SIMD3<Float>,
        content: String? = nil
    ) -> Entity {
        let entity = Entity()
        entity.name = "CodeWindow_\(fileName)"
        entity.position = position

        // Add code window component
        let windowComponent = CodeWindowComponent(
            filePath: filePath,
            fileName: fileName,
            language: detectLanguage(from: fileName),
            lineCount: content?.components(separatedBy: "\n").count ?? 0,
            isDirectory: isDirectory
        )
        entity.components[CodeWindowComponent.self] = windowComponent

        // Add spatial component
        let spatialComponent = SpatialCodeComponent(
            targetPosition: position
        )
        entity.components[SpatialCodeComponent.self] = spatialComponent

        // Create visual components
        createBackground(for: entity, isDirectory: isDirectory)
        createLabel(for: entity, fileName: fileName, isDirectory: isDirectory)
        createBorder(for: entity, isDirectory: isDirectory)

        // Add collision for interaction
        let shape = ShapeResource.generateBox(size: isDirectory ? [0.4, 0.4, 0.02] : [0.6, 0.8, 0.02])
        entity.components[CollisionComponent.self] = CollisionComponent(shapes: [shape])
        entity.components[InputTargetComponent.self] = InputTargetComponent()

        return entity
    }

    // MARK: - Visual Components

    private static func createBackground(for entity: Entity, isDirectory: Bool) {
        let size: SIMD3<Float> = isDirectory ? [0.4, 0.4, 0.01] : [0.6, 0.8, 0.01]
        let mesh = MeshResource.generateBox(size: size)

        var material = UnlitMaterial()

        if isDirectory {
            // Directories are semi-transparent blue
            material.color = .init(tint: UIColor.systemBlue.withAlphaComponent(0.3))
        } else {
            // Files are dark panels
            material.color = .init(tint: UIColor(white: 0.1, alpha: 0.95))
        }

        material.blending = .transparent(opacity: .init(floatLiteral: 0.95))

        let background = ModelComponent(mesh: mesh, materials: [material])
        entity.components[ModelComponent.self] = background
    }

    private static func createLabel(for entity: Entity, fileName: String, isDirectory: Bool) {
        // Create a child entity for the text label
        let labelEntity = Entity()
        labelEntity.name = "Label"

        // Create text mesh using MeshResource
        // Note: In a real implementation, we'd use TextKit or a text rendering library
        // For now, we'll create a simple plane as a placeholder

        let labelMesh = MeshResource.generatePlane(width: isDirectory ? 0.35 : 0.55, depth: 0.05)
        var labelMaterial = UnlitMaterial()
        labelMaterial.color = .init(tint: .white)

        let labelModel = ModelComponent(mesh: labelMesh, materials: [labelMaterial])
        labelEntity.components[ModelComponent.self] = labelModel

        // Position label at top of window
        let yOffset: Float = isDirectory ? 0.18 : 0.38
        labelEntity.position = [0, yOffset, 0.011]

        entity.addChild(labelEntity)

        // Store the file name in the entity's name for debugging
        labelEntity.name = "Label_\(fileName)"
    }

    private static func createBorder(for entity: Entity, isDirectory: Bool) {
        let size: SIMD3<Float> = isDirectory ? [0.405, 0.405, 0.002] : [0.605, 0.805, 0.002]
        let borderMesh = MeshResource.generateBox(size: size)

        var borderMaterial = UnlitMaterial()
        let borderColor = isDirectory ? UIColor.systemBlue : UIColor.systemGray
        borderMaterial.color = .init(tint: borderColor.withAlphaComponent(0.3))

        let borderEntity = Entity()
        borderEntity.name = "Border"
        let borderModel = ModelComponent(mesh: borderMesh, materials: [borderMaterial])
        borderEntity.components[ModelComponent.self] = borderModel
        borderEntity.position.z = -0.001

        entity.addChild(borderEntity)
    }

    /// Detects programming language from file extension
    private static func detectLanguage(from fileName: String) -> String {
        let ext = (fileName as NSString).pathExtension.lowercased()

        switch ext {
        case "swift": return "swift"
        case "js", "jsx": return "javascript"
        case "ts", "tsx": return "typescript"
        case "py": return "python"
        case "java": return "java"
        case "cpp", "cc", "cxx", "c": return "cpp"
        case "h", "hpp": return "cpp"
        case "rs": return "rust"
        case "go": return "go"
        case "rb": return "ruby"
        case "php": return "php"
        case "html", "htm": return "html"
        case "css", "scss", "sass": return "css"
        case "json": return "json"
        case "xml": return "xml"
        case "yaml", "yml": return "yaml"
        case "md", "markdown": return "markdown"
        case "sh", "bash": return "shell"
        default: return "text"
        }
    }

    /// Updates the focus state of a code window
    static func setFocus(_ entity: Entity, focused: Bool) {
        guard var component = entity.components[CodeWindowComponent.self] else { return }
        component.isFocused = focused
        entity.components[CodeWindowComponent.self] = component

        // Update border color
        if let border = entity.children.first(where: { $0.name == "Border" }),
           var model = border.components[ModelComponent.self] {

            var material = model.materials.first as? UnlitMaterial ?? UnlitMaterial()
            let color = focused ? UIColor.systemBlue : UIColor.systemGray
            material.color = .init(tint: color.withAlphaComponent(focused ? 0.8 : 0.3))

            model.materials = [material]
            border.components[ModelComponent.self] = model
        }
    }

    /// Adds a file type icon to the window
    static func addFileIcon(_ entity: Entity, fileType: String) {
        let iconEntity = Entity()
        iconEntity.name = "Icon"

        // Create small sphere or cube as icon placeholder
        let iconMesh = MeshResource.generateSphere(radius: 0.03)
        var iconMaterial = UnlitMaterial()
        iconMaterial.color = .init(tint: colorForFileType(fileType))

        let iconModel = ModelComponent(mesh: iconMesh, materials: [iconMaterial])
        iconEntity.components[ModelComponent.self] = iconModel

        // Position icon at top-left corner
        iconEntity.position = [-0.25, 0.35, 0.012]

        entity.addChild(iconEntity)
    }

    private static func colorForFileType(_ fileType: String) -> UIColor {
        switch fileType {
        case "swift": return .systemOrange
        case "javascript", "typescript": return .systemYellow
        case "python": return .systemBlue
        case "java": return .systemRed
        case "cpp": return .systemPurple
        case "rust": return .systemOrange
        case "go": return .systemCyan
        case "html": return .systemRed
        case "css": return .systemBlue
        case "json", "yaml": return .systemGreen
        default: return .systemGray
        }
    }
}
