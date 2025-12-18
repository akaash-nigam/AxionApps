//
//  CodeContentRenderer.swift
//  SpatialCodeReviewer
//
//  Created by Claude on 2025-11-24.
//  Story 0.6: Syntax Highlighting
//

import SwiftUI
import RealityKit

/// Handles rendering of code content with syntax highlighting for 3D display
@MainActor
class CodeContentRenderer {

    // MARK: - Configuration

    struct Configuration {
        var fontSize: CGFloat = 12
        var lineHeight: CGFloat = 18
        var maxVisibleLines: Int = 40
        var showLineNumbers: Bool = true
        var lineNumberWidth: CGFloat = 40
        var padding: CGFloat = 12
        var textureWidth: Int = 1024
        var textureHeight: Int = 1536

        var contentWidth: CGFloat {
            CGFloat(textureWidth) - padding * 2 - (showLineNumbers ? lineNumberWidth : 0)
        }
    }

    private let config: Configuration

    init(config: Configuration = Configuration()) {
        self.config = config
    }

    // MARK: - Rendering

    /// Renders code to a texture resource for 3D display
    func renderCodeToTexture(
        code: String,
        language: String,
        scrollOffset: Int = 0
    ) async -> TextureResource? {
        // Get visible lines
        let lines = code.components(separatedBy: .newlines)
        let startLine = max(0, scrollOffset)
        let endLine = min(lines.count, startLine + config.maxVisibleLines)
        let visibleLines = Array(lines[startLine..<endLine])

        // Create SwiftUI view
        let view = CodeContentView(
            lines: visibleLines,
            language: language,
            config: config,
            startLineNumber: startLine + 1
        )

        // Render to image
        guard let image = renderSwiftUIToImage(view: view) else {
            return nil
        }

        // Convert to texture resource
        do {
            let texture = try await TextureResource.generate(
                from: image,
                options: .init(semantic: .color)
            )
            return texture
        } catch {
            print("❌ Failed to create texture: \(error)")
            return nil
        }
    }

    /// Renders a SwiftUI view to UIImage
    private func renderSwiftUIToImage(view: some View) -> CGImage? {
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2.0 // Retina quality

        // Set size
        renderer.proposedSize = ProposedViewSize(
            width: CGFloat(config.textureWidth),
            height: CGFloat(config.textureHeight)
        )

        return renderer.cgImage
    }

    /// Calculates total number of lines that can be scrolled
    func maxScrollOffset(for code: String) -> Int {
        let lineCount = code.components(separatedBy: .newlines).count
        return max(0, lineCount - config.maxVisibleLines)
    }
}

// MARK: - CodeContentView (SwiftUI for rendering)

struct CodeContentView: View {
    let lines: [String]
    let language: String
    let config: CodeContentRenderer.Configuration
    let startLineNumber: Int

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background
            Rectangle()
                .fill(CodeTheme.current.background)
                .frame(
                    width: CGFloat(config.textureWidth),
                    height: CGFloat(config.textureHeight)
                )

            HStack(alignment: .top, spacing: 0) {
                // Line numbers
                if config.showLineNumbers {
                    lineNumbersColumn
                        .frame(width: config.lineNumberWidth)
                }

                // Code content
                codeColumn
                    .frame(width: config.contentWidth)
            }
            .padding(config.padding)
        }
    }

    private var lineNumbersColumn: some View {
        VStack(alignment: .trailing, spacing: 0) {
            ForEach(Array(lines.enumerated()), id: \.offset) { index, _ in
                Text("\(startLineNumber + index)")
                    .font(.system(size: config.fontSize, design: .monospaced))
                    .foregroundColor(CodeTheme.current.comment.opacity(0.6))
                    .frame(height: config.lineHeight)
            }
        }
    }

    private var codeColumn: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                highlightedLine(line)
                    .frame(height: config.lineHeight, alignment: .leading)
            }
        }
    }

    private func highlightedLine(_ line: String) -> some View {
        let tokens = SyntaxHighlighter.highlight(code: line, language: language)

        return HStack(spacing: 0) {
            ForEach(Array(tokens.enumerated()), id: \.offset) { _, token in
                Text(token.text)
                    .font(.system(size: config.fontSize, design: .monospaced))
                    .foregroundColor(token.color)
            }
        }
    }
}

// MARK: - Enhanced CodeWindowEntity Factory

extension CodeWindowEntityFactory {
    /// Creates a code window with actual rendered code content
    static func createCodeWindowWithContent(
        filePath: String,
        fileName: String,
        content: String,
        language: String,
        position: SIMD3<Float>
    ) async -> Entity {
        let entity = Entity()
        entity.name = "CodeWindow_\(fileName)"
        entity.position = position

        // Add components
        let windowComponent = CodeWindowComponent(
            filePath: filePath,
            fileName: fileName,
            language: language,
            lineCount: content.components(separatedBy: .newlines).count,
            isDirectory: false
        )
        entity.components[CodeWindowComponent.self] = windowComponent

        let spatialComponent = SpatialCodeComponent(targetPosition: position)
        entity.components[SpatialCodeComponent.self] = spatialComponent

        // Create background panel
        let panelSize = SIMD3<Float>(0.6, 0.8, 0.01)
        let panelMesh = MeshResource.generateBox(size: panelSize)
        var panelMaterial = UnlitMaterial()
        panelMaterial.color = .init(tint: UIColor(CodeTheme.current.background))
        let panelModel = ModelComponent(mesh: panelMesh, materials: [panelMaterial])
        entity.components[ModelComponent.self] = panelModel

        // Render code to texture
        let renderer = CodeContentRenderer()
        if let texture = await renderer.renderCodeToTexture(
            code: content,
            language: language,
            scrollOffset: 0
        ) {
            // Create code display plane
            let codePlane = Entity()
            codePlane.name = "CodeContent"

            let codeSize = SIMD3<Float>(0.55, 0.75, 0.001)
            let codeMesh = MeshResource.generatePlane(width: codeSize.x, depth: codeSize.y)

            var codeMaterial = UnlitMaterial()
            codeMaterial.color = .init(texture: .init(texture))
            let codeModel = ModelComponent(mesh: codeMesh, materials: [codeMaterial])

            codePlane.components[ModelComponent.self] = codeModel
            codePlane.position = [0, 0, 0.006] // Slightly in front of background

            entity.addChild(codePlane)
        }

        // Add label at top
        createLabel(for: entity, fileName: fileName, isDirectory: false)

        // Add border
        createBorder(for: entity, isDirectory: false)

        // Add collision for interaction
        let shape = ShapeResource.generateBox(size: panelSize)
        entity.components[CollisionComponent.self] = CollisionComponent(shapes: [shape])
        entity.components[InputTargetComponent.self] = InputTargetComponent()

        return entity
    }

    // Reuse existing helper methods
    private static func createLabel(for entity: Entity, fileName: String, isDirectory: Bool) {
        let labelEntity = Entity()
        labelEntity.name = "Label"

        let labelMesh = MeshResource.generatePlane(width: 0.55, depth: 0.05)
        var labelMaterial = UnlitMaterial()
        labelMaterial.color = .init(tint: UIColor(CodeTheme.current.foreground))

        let labelModel = ModelComponent(mesh: labelMesh, materials: [labelMaterial])
        labelEntity.components[ModelComponent.self] = labelModel

        labelEntity.position = [0, 0.38, 0.011]

        entity.addChild(labelEntity)
    }

    private static func createBorder(for entity: Entity, isDirectory: Bool) {
        let size = SIMD3<Float>(0.605, 0.805, 0.002)
        let borderMesh = MeshResource.generateBox(size: size)

        var borderMaterial = UnlitMaterial()
        borderMaterial.color = .init(tint: UIColor.systemGray.withAlphaComponent(0.3))

        let borderEntity = Entity()
        borderEntity.name = "Border"
        let borderModel = ModelComponent(mesh: borderMesh, materials: [borderMaterial])
        borderEntity.components[ModelComponent.self] = borderModel
        borderEntity.position.z = -0.001

        entity.addChild(borderEntity)
    }
}
