import Foundation

/// Parses markdown content into structured briefing data
actor MarkdownParser {
    /// Errors that can occur during parsing
    enum ParsingError: Error, LocalizedError {
        case fileNotFound
        case invalidFormat
        case parsingFailed(String)

        var errorDescription: String? {
            switch self {
            case .fileNotFound:
                return "Markdown file not found"
            case .invalidFormat:
                return "Invalid markdown format"
            case .parsingFailed(let message):
                return "Parsing failed: \(message)"
            }
        }
    }

    /// Parse markdown file into briefing sections
    /// - Parameter filename: Name of markdown file (without extension)
    /// - Returns: Array of briefing sections with content
    func parseBriefing(from filename: String) throws -> [BriefingSectionData] {
        // Load markdown file
        guard let url = Bundle.main.url(forResource: filename, withExtension: "md") else {
            throw ParsingError.fileNotFound
        }

        let content = try String(contentsOf: url, encoding: .utf8)
        return try parseContent(content)
    }

    /// Parse markdown string into briefing sections
    func parseContent(_ markdown: String) throws -> [BriefingSectionData] {
        var sections: [BriefingSectionData] = []
        var currentSection: BriefingSectionData?
        var currentContent: [ContentBlockData] = []
        var order = 0

        let lines = markdown.components(separatedBy: .newlines)

        for line in lines {
            // H1 (# Title) = New section
            if line.hasPrefix("# ") && !line.hasPrefix("## ") {
                // Save previous section if exists
                if var section = currentSection {
                    section.content = currentContent
                    sections.append(section)
                    order += 1
                }

                // Start new section
                let title = line.replacingOccurrences(of: "# ", with: "").trimmingCharacters(in: .whitespaces)
                currentSection = BriefingSectionData(
                    title: title,
                    order: order,
                    icon: iconForSection(title: title),
                    content: [],
                    visualizationType: visualizationTypeForSection(title: title)
                )
                currentContent = []
            }
            // H2 (## Subtitle) = Subheading
            else if line.hasPrefix("## ") {
                let heading = line.replacingOccurrences(of: "## ", with: "").trimmingCharacters(in: .whitespaces)
                currentContent.append(ContentBlockData(
                    type: .subheading,
                    content: heading,
                    order: currentContent.count
                ))
            }
            // H3 (### Subtitle) = Heading within section
            else if line.hasPrefix("### ") {
                let heading = line.replacingOccurrences(of: "### ", with: "").trimmingCharacters(in: .whitespaces)
                currentContent.append(ContentBlockData(
                    type: .heading,
                    content: heading,
                    order: currentContent.count
                ))
            }
            // Bullet list item
            else if line.hasPrefix("- ") || line.hasPrefix("* ") {
                let bulletContent = line.replacingOccurrences(of: "^[\\-\\*] ", with: "", options: .regularExpression)
                currentContent.append(ContentBlockData(
                    type: .bulletList,
                    content: bulletContent.trimmingCharacters(in: .whitespaces),
                    order: currentContent.count
                ))
            }
            // Numbered list
            else if line.range(of: #"^\d+\. "#, options: .regularExpression) != nil {
                let numberedContent = line.replacingOccurrences(of: #"^\d+\. "#, with: "", options: .regularExpression)
                currentContent.append(ContentBlockData(
                    type: .numberedList,
                    content: numberedContent.trimmingCharacters(in: .whitespaces),
                    order: currentContent.count
                ))
            }
            // Regular paragraph (non-empty line)
            else if !line.trimmingCharacters(in: .whitespaces).isEmpty && currentSection != nil {
                // Check if it looks like a metric (contains %, $, or numbers)
                if isMetricLine(line) {
                    currentContent.append(ContentBlockData(
                        type: .metric,
                        content: line.trimmingCharacters(in: .whitespaces),
                        order: currentContent.count
                    ))
                } else {
                    currentContent.append(ContentBlockData(
                        type: .paragraph,
                        content: line.trimmingCharacters(in: .whitespaces),
                        order: currentContent.count
                    ))
                }
            }
        }

        // Save last section
        if var section = currentSection {
            section.content = currentContent
            sections.append(section)
        }

        return sections
    }

    /// Determine if a line contains metric data
    private func isMetricLine(_ line: String) -> Bool {
        // Check for common metric patterns
        let metricPatterns = [
            #"\d+%"#,           // Percentage
            #"\$\d+"#,          // Dollar amount
            #"ROI:"#,           // ROI label
            #"Metrics:"#,       // Metrics label
            #"\d+x"#            // Multiplier
        ]

        return metricPatterns.contains { pattern in
            line.range(of: pattern, options: .regularExpression) != nil
        }
    }

    /// Get appropriate icon for section based on title
    private func iconForSection(title: String) -> String {
        let lowercased = title.lowercased()

        if lowercased.contains("summary") {
            return "doc.text.fill"
        } else if lowercased.contains("use case") {
            return "chart.bar.fill"
        } else if lowercased.contains("decision") {
            return "arrow.triangle.branch"
        } else if lowercased.contains("risk") || lowercased.contains("opportunity") {
            return "exclamationmark.triangle.fill"
        } else if lowercased.contains("investment") || lowercased.contains("priorities") {
            return "dollarsign.circle.fill"
        } else if lowercased.contains("competitive") || lowercased.contains("positioning") {
            return "chart.pie.fill"
        } else if lowercased.contains("action") {
            return "checkmark.circle.fill"
        } else if lowercased.contains("metrics") || lowercased.contains("success") {
            return "chart.line.uptrend.xyaxis"
        } else if lowercased.contains("conclusion") {
            return "flag.checkered"
        } else {
            return "doc.fill"
        }
    }

    /// Get visualization type for section based on title
    private func visualizationTypeForSection(title: String) -> VisualizationType? {
        let lowercased = title.lowercased()

        if lowercased.contains("use case") || lowercased.contains("roi") {
            return .roiComparison
        } else if lowercased.contains("decision") {
            return .decisionMatrix
        } else if lowercased.contains("investment") || lowercased.contains("priorities") {
            return .investmentTimeline
        } else if lowercased.contains("risk") || lowercased.contains("opportunity") {
            return .riskOpportunityMatrix
        } else if lowercased.contains("competitive") {
            return .competitivePositioning
        } else {
            return nil
        }
    }
}

// MARK: - Data Transfer Objects

/// Temporary data structure for briefing section during parsing
struct BriefingSectionData {
    var title: String
    var order: Int
    var icon: String
    var content: [ContentBlockData]
    var visualizationType: VisualizationType?
}

/// Temporary data structure for content block during parsing
struct ContentBlockData {
    var type: ContentType
    var content: String
    var metadata: [String: String]?
    var order: Int

    init(type: ContentType, content: String, metadata: [String: String]? = nil, order: Int) {
        self.type = type
        self.content = content
        self.metadata = metadata
        self.order = order
    }
}
