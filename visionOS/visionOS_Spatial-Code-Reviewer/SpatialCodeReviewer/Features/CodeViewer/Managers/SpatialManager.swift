//
//  SpatialManager.swift
//  SpatialCodeReviewer
//
//  Created by Claude on 2025-11-24.
//  Story 0.5: Basic 3D Code Window
//

import RealityKit
import SwiftUI

/// Manages all 3D spatial entities and their layout in the immersive space
@MainActor
class SpatialManager: ObservableObject {
    // MARK: - Published Properties

    @Published var isLoading = false
    @Published var loadingProgress: Double = 0.0
    @Published var error: Error?
    @Published var selectedEntity: Entity?
    @Published var currentLayout: LayoutType = .hemisphere

    // MARK: - Private Properties

    private var codeWindowEntities: [Entity] = []
    private var rootEntity: Entity?
    private let localRepositoryManager = LocalRepositoryManager.shared
    private let navigationManager = FileNavigationManager()

    private var hemisphereLayout = HemisphereLayout()
    private var focusLayout = FocusLayout()
    private var gridLayout = GridLayout(columns: 3)
    private var nestedLayout = NestedLayout()

    // MARK: - Enums

    enum LayoutType {
        case hemisphere
        case focus
        case grid
        case comparison
        case nested  // Story 0.8: Hierarchical file tree
    }

    enum SpatialError: LocalizedError {
        case repositoryNotDownloaded
        case fileTreeGenerationFailed
        case noFilesToDisplay

        var errorDescription: String? {
            switch self {
            case .repositoryNotDownloaded:
                return "Repository has not been downloaded yet"
            case .fileTreeGenerationFailed:
                return "Failed to generate file tree"
            case .noFilesToDisplay:
                return "No files found to display"
            }
        }
    }

    // MARK: - Initialization

    init() {}

    // MARK: - Public Methods

    /// Loads and displays a repository in 3D space
    func loadRepository(owner: String, name: String) async throws {
        isLoading = true
        loadingProgress = 0.0
        defer { isLoading = false }

        // Check if repository is downloaded
        guard localRepositoryManager.isRepositoryDownloaded(owner: owner, name: name) else {
            throw SpatialError.repositoryNotDownloaded
        }

        // Build file tree
        loadingProgress = 0.2
        let fileTree: FileNode
        do {
            fileTree = try localRepositoryManager.buildFileTree(owner: owner, name: name)
        } catch {
            throw SpatialError.fileTreeGenerationFailed
        }

        // Flatten file tree for visualization (limit to top-level for MVP)
        loadingProgress = 0.4
        let topLevelNodes = extractTopLevelNodes(from: fileTree)

        guard !topLevelNodes.isEmpty else {
            throw SpatialError.noFilesToDisplay
        }

        // Clear existing entities
        clearAllEntities()

        // Create code window entities
        loadingProgress = 0.6
        await createCodeWindowEntities(for: topLevelNodes, owner: owner, name: name)

        // Apply layout
        loadingProgress = 0.8
        applyLayout(currentLayout)

        loadingProgress = 1.0
        print("✅ Successfully loaded \(topLevelNodes.count) files in 3D space")
    }

    /// Switches to a different spatial layout
    func switchLayout(to layout: LayoutType) {
        currentLayout = layout
        applyLayout(layout)
    }

    /// Focuses on a specific entity
    func focusOnEntity(_ entity: Entity) {
        // Unfocus previous selection
        if let previousEntity = selectedEntity {
            CodeWindowEntityFactory.setFocus(previousEntity, focused: false)
        }

        // Focus new selection
        selectedEntity = entity
        CodeWindowEntityFactory.setFocus(entity, focused: true)

        print("Focused on: \(entity.name)")
    }

    /// Clears all code window entities from the scene
    func clearAllEntities() {
        for entity in codeWindowEntities {
            entity.removeFromParent()
        }
        codeWindowEntities.removeAll()
        selectedEntity = nil
    }

    /// Returns all code window entities for adding to RealityView
    func getEntities() -> [Entity] {
        return codeWindowEntities
    }

    // MARK: - Private Methods

    /// Extracts top-level nodes from file tree
    private func extractTopLevelNodes(from root: FileNode) -> [FileNode] {
        guard let children = root.children else {
            return []
        }

        // For MVP, only show top-level files and directories
        // Filter out hidden files and common build artifacts
        return children.filter { node in
            !node.name.hasPrefix(".") &&
            node.name != "node_modules" &&
            node.name != ".git" &&
            node.name != "build" &&
            node.name != "dist"
        }.sorted { $0.name < $1.name }
    }

    /// Creates 3D entities for each file/directory node
    private func createCodeWindowEntities(for nodes: [FileNode], owner: String, name: String) async {
        let total = nodes.count
        let repoPath = localRepositoryManager.repositoryPath(owner: owner, name: name)

        for (index, node) in nodes.enumerated() {
            let entity: Entity

            if node.isDirectory {
                // Directories: simple placeholder (no content)
                entity = CodeWindowEntityFactory.createCodeWindow(
                    filePath: node.path,
                    fileName: node.name,
                    isDirectory: true,
                    position: [0, 0, 0],
                    content: nil
                )

                // Add file icon
                CodeWindowEntityFactory.addFileIcon(entity, fileType: "directory")
            } else {
                // Files: load content and render with syntax highlighting
                let filePath = repoPath.appendingPathComponent(node.path).path
                let content = try? localRepositoryManager.readFileContent(at: filePath)
                let language = CodeWindowEntityFactory.detectLanguage(from: node.name)

                if let content = content, content.count < 50000 { // Limit size for performance
                    // Create entity with rendered code content
                    entity = await CodeWindowEntityFactory.createCodeWindowWithContent(
                        filePath: node.path,
                        fileName: node.name,
                        content: content,
                        language: language,
                        position: [0, 0, 0]
                    )
                } else {
                    // Fallback to simple entity for large files or load errors
                    entity = CodeWindowEntityFactory.createCodeWindow(
                        filePath: node.path,
                        fileName: node.name,
                        isDirectory: false,
                        position: [0, 0, 0],
                        content: content
                    )
                    CodeWindowEntityFactory.addFileIcon(entity, fileType: language)
                }
            }

            codeWindowEntities.append(entity)

            // Update progress
            loadingProgress = 0.6 + (Double(index + 1) / Double(total)) * 0.2
        }
    }

    /// Applies a spatial layout to all code window entities
    private func applyLayout(_ layout: LayoutType) {
        guard !codeWindowEntities.isEmpty else { return }

        switch layout {
        case .hemisphere:
            applyHemisphereLayout()
        case .focus:
            applyFocusLayout()
        case .grid:
            applyGridLayout()
        case .comparison:
            applyComparisonLayout()
        }
    }

    private func applyHemisphereLayout() {
        let transforms = hemisphereLayout.calculatePositions(for: codeWindowEntities.count)

        for (entity, transform) in zip(codeWindowEntities, transforms) {
            animateToTransform(entity: entity, transform: transform)
        }

        print("Applied hemisphere layout to \(codeWindowEntities.count) entities")
    }

    private func applyFocusLayout() {
        guard !codeWindowEntities.isEmpty else { return }

        // Focus on first entity by default
        let focusedIndex = 0

        if let selectedEntity = selectedEntity,
           let index = codeWindowEntities.firstIndex(of: selectedEntity) {
            // Use selected entity if available
            applyFocusLayout(focusedIndex: index)
        } else {
            applyFocusLayout(focusedIndex: focusedIndex)
        }
    }

    private func applyFocusLayout(focusedIndex: Int) {
        for (index, entity) in codeWindowEntities.enumerated() {
            if index == focusedIndex {
                // Main focused window
                let transform = Transform(
                    scale: focusLayout.focusScale,
                    translation: focusLayout.focusPosition
                )
                animateToTransform(entity: entity, transform: transform)
            } else {
                // Context windows
                let contextIndex = index < focusedIndex ? index : index - 1
                let angle = Float(contextIndex) * 0.3 - Float(codeWindowEntities.count - 1) * 0.15

                let x = focusLayout.contextRadius * sin(angle)
                let y: Float = 0.8
                let z = -1.8 - focusLayout.contextRadius * cos(angle)

                let transform = Transform(
                    scale: focusLayout.contextScale,
                    translation: SIMD3<Float>(x, y, z)
                )
                animateToTransform(entity: entity, transform: transform)
            }
        }

        print("Applied focus layout (focused on index \(focusedIndex))")
    }

    private func applyGridLayout() {
        let transforms = gridLayout.calculatePositions(for: codeWindowEntities.count)

        for (entity, transform) in zip(codeWindowEntities, transforms) {
            animateToTransform(entity: entity, transform: transform)
        }

        print("Applied grid layout to \(codeWindowEntities.count) entities")
    }

    private func applyComparisonLayout() {
        guard codeWindowEntities.count >= 2 else {
            // Fall back to hemisphere if less than 2 entities
            applyHemisphereLayout()
            return
        }

        // Only show first two entities
        let separation: Float = 0.8
        let position = SIMD3<Float>(0, 1.5, -1.5)
        let scale = SIMD3<Float>(0.9, 1.0, 1.0)

        let leftPosition = position + SIMD3<Float>(-separation / 2, 0, 0)
        let rightPosition = position + SIMD3<Float>(separation / 2, 0, 0)

        // Position first two entities
        animateToTransform(entity: codeWindowEntities[0], transform: Transform(scale: scale, translation: leftPosition))
        animateToTransform(entity: codeWindowEntities[1], transform: Transform(scale: scale, translation: rightPosition))

        // Hide remaining entities
        for i in 2..<codeWindowEntities.count {
            codeWindowEntities[i].isEnabled = false
        }

        print("Applied comparison layout (showing 2 entities)")
    }

    /// Animates an entity to a target transform
    private func animateToTransform(entity: Entity, transform: Transform, duration: TimeInterval = 0.5) {
        let animation = FromToByAnimation(
            from: entity.transform,
            to: transform,
            duration: duration,
            timing: .easeInOut,
            bindTarget: .transform
        )

        entity.playAnimation(animation.repeat())
    }
}

// MARK: - Extension for Language Detection

extension CodeWindowEntityFactory {
    /// Exposes language detection for use in SpatialManager
    static func detectLanguage(from fileName: String) -> String {
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
}
