//
//  PDFExporter.swift
//  SpatialScreenplayWorkshop
//
//  Created on 2025-11-24
//

import Foundation
import PDFKit
import UIKit

/// Exports screenplay projects to industry-standard PDF format
@MainActor
final class PDFExporter {
    // MARK: - Export Configuration

    struct ExportConfiguration {
        var includeTitlePage: Bool = true
        var includeSceneNumbers: Bool = true
        var includePageNumbers: Bool = true
        var pageNumberStart: Int = 1
        var font: String = "Courier"
        var fontSize: CGFloat = 12.0

        static var standard: ExportConfiguration {
            ExportConfiguration()
        }
    }

    // MARK: - Export

    func export(project: Project, configuration: ExportConfiguration = .standard) async throws -> URL {
        // Create PDF data
        let pdfData = try await generatePDF(project: project, configuration: configuration)

        // Save to temporary file
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(project.title).pdf")

        try pdfData.write(to: tempURL)

        return tempURL
    }

    // MARK: - PDF Generation

    private func generatePDF(project: Project, configuration: ExportConfiguration) async throws -> Data {
        let pdfMetadata = createPDFMetadata(project: project)
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetadata

        // Page size: 8.5 x 11 inches (US Letter)
        let pageWidth: CGFloat = 612  // 8.5 * 72
        let pageHeight: CGFloat = 792  // 11 * 72
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { context in
            var currentPageNumber = configuration.pageNumberStart

            // Title page
            if configuration.includeTitlePage {
                context.beginPage()
                renderTitlePage(project: project, in: pageRect, context: context.cgContext)
                currentPageNumber += 1
            }

            // Screenplay pages
            guard let scenes = project.scenes else { return }

            let formatter = ScreenplayFormatter(configuration: configuration)
            var currentY: CGFloat = ScriptFormatter.Margins.pageHeight - 72  // 1 inch from top

            for scene in scenes {
                // Check if we need a new page
                if currentY < 100 {  // Less than 100pt remaining
                    context.beginPage()
                    currentY = ScriptFormatter.Margins.pageHeight - 72

                    // Page number
                    if configuration.includePageNumbers {
                        renderPageNumber(currentPageNumber, in: pageRect, context: context.cgContext)
                    }
                    currentPageNumber += 1
                }

                // Render scene
                let sceneHeight = formatter.renderScene(
                    scene,
                    at: CGPoint(x: 0, y: currentY),
                    in: context.cgContext,
                    pageWidth: pageWidth
                )

                currentY -= sceneHeight

                // If scene spans multiple pages, handle pagination
                if currentY < 0 {
                    // Scene continued on next page
                    context.beginPage()
                    currentY = ScriptFormatter.Margins.pageHeight - 72

                    if configuration.includePageNumbers {
                        renderPageNumber(currentPageNumber, in: pageRect, context: context.cgContext)
                    }
                    currentPageNumber += 1
                }
            }
        }

        return data
    }

    // MARK: - Title Page

    private func renderTitlePage(project: Project, in rect: CGRect, context: CGContext) {
        let titlePageGenerator = TitlePageGenerator()
        titlePageGenerator.render(project: project, in: rect, context: context)
    }

    // MARK: - Page Number

    private func renderPageNumber(_ number: Int, in rect: CGRect, context: CGContext) {
        let numberString = "\(number)."
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Courier", size: 12) ?? UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.black
        ]

        let attributedString = NSAttributedString(string: numberString, attributes: attributes)
        let size = attributedString.size()

        // Position: top right, 0.5" from edge
        let x = rect.width - 36 - size.width  // 0.5" from right
        let y = rect.height - 36 - size.height  // 0.5" from top

        attributedString.draw(at: CGPoint(x: x, y: y))
    }

    // MARK: - PDF Metadata

    private func createPDFMetadata(project: Project) -> [String: Any] {
        var metadata: [String: Any] = [:]

        metadata[kCGPDFContextTitle as String] = project.title
        metadata[kCGPDFContextAuthor as String] = project.author
        metadata[kCGPDFContextCreator as String] = "Spatial Screenplay Workshop"
        metadata[kCGPDFContextCreationDate as String] = Date()

        if let modifiedDate = project.modifiedAt {
            metadata[kCGPDFContextModificationDate as String] = modifiedDate
        }

        return metadata
    }
}
