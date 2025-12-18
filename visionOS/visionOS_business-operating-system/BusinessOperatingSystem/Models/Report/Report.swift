//
//  Report.swift
//  BusinessOperatingSystem
//
//  Created by BOS Team on 2025-01-20.
//

import Foundation

// MARK: - Report

/// Represents a business report with sections and visualizations
public struct Report: Identifiable, Codable, Sendable {
    public let id: UUID
    var title: String
    var description: String
    var type: ReportType
    var createdAt: Date
    var updatedAt: Date
    var createdBy: User.ID
    var content: ReportContent

    public enum ReportType: String, Codable, Sendable {
        case financial
        case operational
        case executive
        case custom

        var displayName: String {
            switch self {
            case .financial: return "Financial Report"
            case .operational: return "Operational Report"
            case .executive: return "Executive Summary"
            case .custom: return "Custom Report"
            }
        }

        var iconName: String {
            switch self {
            case .financial: return "chart.bar.doc.horizontal"
            case .operational: return "gear.badge.checkmark"
            case .executive: return "doc.text.magnifyingglass"
            case .custom: return "doc.badge.plus"
            }
        }
    }
}

// MARK: - Report Content

public struct ReportContent: Codable, Sendable {
    var sections: [ReportSection]
    private var _jsonData: Data

    /// Initialize with sections and optional data dictionary
    init(sections: [ReportSection], data: [String: Any] = [:]) {
        self.sections = sections
        self._jsonData = (try? JSONSerialization.data(withJSONObject: data)) ?? Data()
    }

    /// Access the report data as a dictionary
    var data: [String: Any] {
        get {
            (try? JSONSerialization.jsonObject(with: _jsonData) as? [String: Any]) ?? [:]
        }
    }

    /// Update the report data
    mutating func setData(_ newData: [String: Any]) throws {
        guard JSONSerialization.isValidJSONObject(newData) else {
            throw BOSError.encodingFailed(NSError(domain: "ReportContent", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Invalid JSON object for report data"
            ]))
        }
        _jsonData = try JSONSerialization.data(withJSONObject: newData)
    }

    /// Get the raw JSON data
    var jsonData: Data {
        _jsonData
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case sections
        case _jsonData = "jsonData"
    }
}

// MARK: - Report Section

public struct ReportSection: Codable, Hashable, Sendable {
    var title: String
    var content: String
    var visualizations: [Visualization.ID]

    init(title: String, content: String, visualizations: [Visualization.ID] = []) {
        self.title = title
        self.content = content
        self.visualizations = visualizations
    }
}

// MARK: - Mock Extension

extension Report {
    static func mock(
        title: String = "Q4 Financial Summary",
        type: ReportType = .financial
    ) -> Report {
        Report(
            id: UUID(),
            title: title,
            description: "Quarterly financial performance overview",
            type: type,
            createdAt: Date(),
            updatedAt: Date(),
            createdBy: UUID(),
            content: ReportContent(
                sections: [
                    ReportSection(
                        title: "Executive Summary",
                        content: "Overall performance exceeded expectations with a 15% increase in revenue."
                    ),
                    ReportSection(
                        title: "Key Metrics",
                        content: "Revenue: $125M, Expenses: $95M, Net Profit: $30M"
                    )
                ],
                data: ["revenue": 125_000_000, "expenses": 95_000_000]
            )
        )
    }
}
