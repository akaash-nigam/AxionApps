//
//  EnhancedDocumentService.swift
//  Legal Discovery Universe
//
//  Created by Claude Code
//  Copyright © 2024 Legal Discovery Universe. All rights reserved.
//

import Foundation
import PDFKit
import UniformTypeIdentifiers

/// Enhanced document service with actual file parsing capabilities
class EnhancedDocumentService: DocumentService {
    private let repository: DocumentRepository
    private let aiService: AIService

    init(repository: DocumentRepository, aiService: AIService) {
        self.repository = repository
        self.aiService = aiService
    }

    // MARK: - Import Documents

    func importDocuments(from urls: [URL]) async throws -> [Document] {
        var documents: [Document] = []

        for url in urls {
            do {
                let document = try await importSingleDocument(from: url)
                documents.append(document)
            } catch {
                print("Failed to import \(url.lastPathComponent): \(error)")
                // Continue with other documents
            }
        }

        // Save all imported documents
        if !documents.isEmpty {
            try await MainActor.run {
                try repository.insertBatch(documents)
            }
        }

        return documents
    }

    private func importSingleDocument(from url: URL) async throws -> Document {
        // Check file exists
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw DocumentError.fileNotFound
        }

        // Get file attributes
        let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
        let fileSize = attributes[.size] as? Int64 ?? 0

        // Check size limit
        guard fileSize <= AppConstants.maxDocumentSize else {
            throw DocumentError.fileTooLarge
        }

        // Determine file type
        let fileType = determineFileType(from: url)

        // Extract text content
        let extractedText = try await extractText(from: url, fileType: fileType)

        // Extract metadata
        let metadata = try extractMetadata(from: url, fileType: fileType)

        // Calculate content hash
        let data = try Data(contentsOf: url)
        let hash = data.sha256Hash()

        // Create document
        let document = Document(
            fileName: url.lastPathComponent,
            fileType: fileType,
            fileSize: fileSize,
            contentHash: hash,
            extractedText: extractedText
        )
        document.metadata = metadata

        // Run AI analysis
        let analysis = try await aiService.analyzeDocument(document)
        document.aiAnalysis = analysis
        document.relevanceScore = analysis.relevanceScore

        // Detect privilege
        let privilegeStatus = try await aiService.detectPrivilege(document)
        document.privilegeStatus = privilegeStatus
        document.isPrivileged = privilegeStatus != .notPrivileged

        return document
    }

    // MARK: - Text Extraction

    private func extractText(from url: URL, fileType: FileType) async throws -> String {
        switch fileType {
        case .pdf:
            return try extractTextFromPDF(url)
        case .word:
            return try extractTextFromWord(url)
        case .email:
            return try extractTextFromEmail(url)
        case .other, .excel, .image, .video, .audio:
            // For other types, try basic text extraction
            return try extractPlainText(url)
        }
    }

    private func extractTextFromPDF(_ url: URL) throws -> String {
        guard let pdfDocument = PDFDocument(url: url) else {
            throw DocumentError.parsingFailed
        }

        var fullText = ""
        for pageIndex in 0..<pdfDocument.pageCount {
            guard let page = pdfDocument.page(at: pageIndex) else { continue }
            if let pageText = page.string {
                fullText += pageText + "\n"
            }
        }

        return fullText.normalizedWhitespace
    }

    private func extractTextFromWord(_ url: URL) throws -> String {
        // For Word documents, we'd need to use a more specialized library
        // For now, try to read as plain text if possible
        return try extractPlainText(url)
    }

    private func extractTextFromEmail(_ url: URL) throws -> String {
        // Read email file content
        let emailData = try String(contentsOf: url, encoding: .utf8)

        // Parse email headers and body (simplified)
        var extractedText = ""

        // Extract common email fields
        let lines = emailData.components(separatedBy: .newlines)
        for line in lines {
            if line.hasPrefix("From:") || line.hasPrefix("To:") ||
               line.hasPrefix("Subject:") || line.hasPrefix("Date:") {
                extractedText += line + "\n"
            }
        }

        // Add full content
        extractedText += "\n" + emailData

        return extractedText.normalizedWhitespace
    }

    private func extractPlainText(_ url: URL) throws -> String {
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            // Try other encodings
            if let content = try? String(contentsOf: url, encoding: .ascii) {
                return content
            }
            throw DocumentError.parsingFailed
        }
    }

    // MARK: - Metadata Extraction

    private func extractMetadata(from url: URL, fileType: FileType) throws -> DocumentMetadata {
        var metadata = DocumentMetadata()

        // File-level metadata
        let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
        metadata.dateCreated = attributes[.creationDate] as? Date
        metadata.dateModified = attributes[.modificationDate] as? Date
        metadata.path = url.path

        // File type specific metadata
        switch fileType {
        case .pdf:
            metadata = try extractPDFMetadata(url, metadata: metadata)
        case .email:
            metadata = try extractEmailMetadata(url, metadata: metadata)
        default:
            break
        }

        return metadata
    }

    private func extractPDFMetadata(_ url: URL, metadata: DocumentMetadata) throws -> DocumentMetadata {
        guard let pdfDocument = PDFDocument(url: url) else {
            return metadata
        }

        var updatedMetadata = metadata

        if let attributes = pdfDocument.documentAttributes {
            updatedMetadata.author = attributes[PDFDocumentAttribute.authorAttribute] as? String
            updatedMetadata.subject = attributes[PDFDocumentAttribute.subjectAttribute] as? String

            if let creationDate = attributes[PDFDocumentAttribute.creationDateAttribute] as? Date {
                updatedMetadata.dateCreated = creationDate
            }
        }

        return updatedMetadata
    }

    private func extractEmailMetadata(_ url: URL, metadata: DocumentMetadata) throws -> DocumentMetadata {
        let emailContent = try String(contentsOf: url, encoding: .utf8)
        var updatedMetadata = metadata

        // Parse email headers (simplified)
        let lines = emailContent.components(separatedBy: .newlines)
        for line in lines {
            if line.hasPrefix("From:") {
                updatedMetadata.from = line.replacingOccurrences(of: "From:", with: "").trimmingCharacters(in: .whitespaces)
            } else if line.hasPrefix("To:") {
                let recipients = line.replacingOccurrences(of: "To:", with: "").trimmingCharacters(in: .whitespaces)
                updatedMetadata.recipient = recipients.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            } else if line.hasPrefix("Cc:") {
                let cc = line.replacingOccurrences(of: "Cc:", with: "").trimmingCharacters(in: .whitespaces)
                updatedMetadata.cc = cc.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            } else if line.hasPrefix("Subject:") {
                updatedMetadata.subject = line.replacingOccurrences(of: "Subject:", with: "").trimmingCharacters(in: .whitespaces)
            } else if line.hasPrefix("Date:") {
                // Parse date (would need proper date parsing)
                let dateString = line.replacingOccurrences(of: "Date:", with: "").trimmingCharacters(in: .whitespaces)
                // Could use DateFormatter here to parse
            }
        }

        return updatedMetadata
    }

    // MARK: - Search Documents

    func searchDocuments(query: SearchQuery) async throws -> [Document] {
        return try await MainActor.run {
            try repository.search(query: query.text)
        }
    }

    // MARK: - Analyze Document

    func analyzeDocument(_ document: Document) async throws -> AIAnalysis {
        return try await aiService.analyzeDocument(document)
    }

    // MARK: - Export Documents

    func exportDocuments(_ documents: [Document], format: ExportFormat) async throws -> URL {
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("export_\(UUID().uuidString)")
            .appendingPathExtension(format.fileExtension)

        switch format {
        case .pdf:
            try await exportToPDF(documents, to: tempURL)
        case .csv:
            try await exportToCSV(documents, to: tempURL)
        case .json:
            try await exportToJSON(documents, to: tempURL)
        case .zip:
            try await exportToZip(documents, to: tempURL)
        }

        return tempURL
    }

    private func exportToPDF(_ documents: [Document], to url: URL) async throws {
        // Create PDF with document list
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))

        let pdfData = pdfRenderer.pdfData { context in
            for document in documents {
                context.beginPage()

                // Draw document information
                let title = document.fileName
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 18, weight: .bold)
                ]

                title.draw(at: CGPoint(x: 50, y: 50), withAttributes: attributes)

                // Draw metadata
                let metadata = """
                File Type: \(document.fileType.rawValue)
                Size: \(ByteCountFormatter.string(fromByteCount: document.fileSize, countStyle: .file))
                Relevance: \(Int(document.relevanceScore * 100))%
                Privilege: \(document.privilegeStatus.rawValue)
                """

                let bodyAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12)
                ]

                metadata.draw(at: CGPoint(x: 50, y: 80), withAttributes: bodyAttributes)
            }
        }

        try pdfData.write(to: url)
    }

    private func exportToCSV(_ documents: [Document], to url: URL) async throws {
        var csvString = "File Name,File Type,Size,Relevance,Privilege,Date\n"

        for document in documents {
            let row = [
                document.fileName,
                document.fileType.rawValue,
                String(document.fileSize),
                String(format: "%.2f", document.relevanceScore),
                document.privilegeStatus.rawValue,
                document.documentDate?.iso8601String ?? ""
            ].joined(separator: ",")

            csvString += row + "\n"
        }

        try csvString.write(to: url, atomically: true, encoding: .utf8)
    }

    private func exportToJSON(_ documents: [Document], to url: URL) async throws {
        let exportData = documents.map { document in
            [
                "id": document.id.uuidString,
                "fileName": document.fileName,
                "fileType": document.fileType.rawValue,
                "fileSize": document.fileSize,
                "relevanceScore": document.relevanceScore,
                "privilegeStatus": document.privilegeStatus.rawValue,
                "extractedText": document.extractedText
            ] as [String : Any]
        }

        let jsonData = try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
        try jsonData.write(to: url)
    }

    private func exportToZip(_ documents: [Document], to url: URL) async throws {
        // Would need to create a zip archive of the original files
        // For now, export as JSON
        try await exportToJSON(documents, to: url)
    }

    // MARK: - Helper Methods

    private func determineFileType(from url: URL) -> FileType {
        let pathExtension = url.pathExtension.lowercased()

        if AppConstants.documentFileTypes.contains(pathExtension) {
            if pathExtension == "pdf" { return .pdf }
            if pathExtension == "doc" || pathExtension == "docx" { return .word }
        }

        if AppConstants.emailFileTypes.contains(pathExtension) {
            return .email
        }

        if AppConstants.imageFileTypes.contains(pathExtension) {
            return .image
        }

        if pathExtension == "xls" || pathExtension == "xlsx" {
            return .excel
        }

        if AppConstants.videoFileTypes.contains(pathExtension) {
            return .video
        }

        if AppConstants.audioFileTypes.contains(pathExtension) {
            return .audio
        }

        return .other
    }
}

// MARK: - Document Errors

enum DocumentError: Error, LocalizedError {
    case fileNotFound
    case fileTooLarge
    case parsingFailed
    case unsupportedFileType
    case corruptedFile

    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "The specified file could not be found."
        case .fileTooLarge:
            return "The file exceeds the maximum allowed size of \(ByteCountFormatter.string(fromByteCount: AppConstants.maxDocumentSize, countStyle: .file))."
        case .parsingFailed:
            return "Failed to parse the document content."
        case .unsupportedFileType:
            return "This file type is not supported."
        case .corruptedFile:
            return "The file appears to be corrupted."
        }
    }
}
