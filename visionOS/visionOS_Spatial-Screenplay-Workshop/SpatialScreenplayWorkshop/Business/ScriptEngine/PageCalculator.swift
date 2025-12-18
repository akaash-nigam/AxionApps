//
//  PageCalculator.swift
//  SpatialScreenplayWorkshop
//
//  Created on 2025-11-24
//

import Foundation

/// Calculates page count for screenplay
struct PageCalculator {

    // MARK: - Constants

    /// Lines per page (standard screenplay format)
    private static let linesPerPage: Double = 55

    /// Character width for Courier 12pt
    private static let courierCharWidth: CGFloat = 7.2  // Approximation

    // MARK: - Page Calculation

    /// Calculate page count from script text
    static func calculatePageCount(from text: String) -> Double {
        let elements = ScriptFormatter.analyzeScript(text)
        var totalLines: Double = 0

        for element in elements {
            totalLines += countLines(for: element)
        }

        // Add spacing between elements
        let elementCount = Double(elements.count)
        totalLines += elementCount * 0.5  // Half line between elements

        return max(totalLines / linesPerPage, 1.0 / 8.0)  // Minimum 1/8 page
    }

    /// Calculate page count for a scene
    static func calculatePageCount(for scene: Scene) -> Double {
        var totalLines: Double = 0

        // Slug line (1 line + spacing)
        totalLines += 2

        // Count script elements
        for element in scene.content.elements {
            totalLines += countLines(for: element)
        }

        return max(totalLines / linesPerPage, 1.0 / 8.0)
    }

    // MARK: - Line Counting

    /// Count lines for a formatted element
    private static func countLines(for element: FormattedElement) -> Double {
        switch element {
        case .slugLine:
            return 2.0  // Slug line + spacing after
        case .action(let text):
            return countLinesForText(text, width: ScriptFormatter.Margins.actionRight - ScriptFormatter.Margins.action)
        case .dialogue(let block):
            return countLinesForDialogue(block)
        case .transition:
            return 1.5  // Transition + spacing
        case .empty:
            return 1.0
        }
    }

    /// Count lines for script element
    private static func countLines(for element: ScriptElement) -> Double {
        switch element {
        case .action(let action):
            return countLinesForText(action.text, width: ScriptFormatter.Margins.actionRight - ScriptFormatter.Margins.action)

        case .dialogue(let dialogue):
            var lines: Double = 1.0  // Character name

            if dialogue.parenthetical != nil {
                lines += 1.0  // Parenthetical
            }

            let dialogueText = dialogue.lines.joined(separator: " ")
            lines += countLinesForText(dialogueText, width: ScriptFormatter.Margins.dialogueRight - ScriptFormatter.Margins.dialogue)

            lines += 0.5  // Spacing after dialogue

            return lines

        case .transition:
            return 1.5  // Transition + spacing

        case .shot(let shot):
            return 1.0
        }
    }

    /// Count lines for dialogue block
    private static func countLinesForDialogue(_ block: DialogueBlock) -> Double {
        var lines: Double = 1.0  // Character name

        if block.parenthetical != nil {
            lines += 1.0  // Parenthetical
        }

        let dialogueText = block.lines.joined(separator: " ")
        lines += countLinesForText(dialogueText, width: ScriptFormatter.Margins.dialogueRight - ScriptFormatter.Margins.dialogue)

        lines += 0.5  // Spacing after dialogue

        return lines
    }

    /// Count lines for text with given width
    private static func countLinesForText(_ text: String, width: CGFloat) -> Double {
        guard !text.isEmpty else { return 0 }

        // Estimate characters per line
        let charsPerLine = Int(width / courierCharWidth)
        guard charsPerLine > 0 else { return 1 }

        // Word wrapping calculation
        let words = text.components(separatedBy: .whitespaces)
        var currentLineLength = 0
        var lineCount: Double = 1

        for word in words {
            let wordLength = word.count + 1  // +1 for space

            if currentLineLength + wordLength > charsPerLine {
                // Word doesn't fit, start new line
                lineCount += 1
                currentLineLength = wordLength
            } else {
                currentLineLength += wordLength
            }
        }

        return lineCount
    }

    // MARK: - Statistics

    /// Calculate detailed statistics for a scene
    static func calculateStatistics(for scene: Scene) -> SceneStatistics {
        let pageCount = calculatePageCount(for: scene)

        var wordCount = 0
        var lineCount = 0
        var actionCount = 0
        var dialogueCount = 0

        for element in scene.content.elements {
            switch element {
            case .action(let action):
                actionCount += 1
                wordCount += action.text.components(separatedBy: .whitespaces).count
            case .dialogue(let dialogue):
                dialogueCount += 1
                lineCount += dialogue.lines.count
                wordCount += dialogue.fullText.components(separatedBy: .whitespaces).count
            case .transition, .shot:
                break
            }
        }

        return SceneStatistics(
            pageCount: pageCount,
            wordCount: wordCount,
            lineCount: lineCount,
            actionCount: actionCount,
            dialogueCount: dialogueCount,
            estimatedDuration: pageCount * 60  // 1 page ≈ 1 minute
        )
    }

    /// Calculate statistics for entire project
    static func calculateStatistics(for project: Project) -> ProjectStatistics {
        guard let scenes = project.scenes else {
            return ProjectStatistics(
                totalPages: 0,
                totalWords: 0,
                totalScenes: 0,
                scenesByAct: [:],
                estimatedRuntime: 0
            )
        }

        var totalPages: Double = 0
        var totalWords = 0
        var scenesByAct: [Int: Int] = [:]

        for scene in scenes {
            let stats = calculateStatistics(for: scene)
            totalPages += stats.pageCount
            totalWords += stats.wordCount

            scenesByAct[scene.position.act, default: 0] += 1
        }

        return ProjectStatistics(
            totalPages: totalPages,
            totalWords: totalWords,
            totalScenes: scenes.count,
            scenesByAct: scenesByAct,
            estimatedRuntime: totalPages * 60  // 1 page ≈ 1 minute
        )
    }
}

// MARK: - Statistics Models

struct SceneStatistics {
    let pageCount: Double
    let wordCount: Int
    let lineCount: Int
    let actionCount: Int
    let dialogueCount: Int
    let estimatedDuration: TimeInterval

    var formattedPageCount: String {
        String(format: "%.2f", pageCount)
    }

    var formattedDuration: String {
        let minutes = Int(estimatedDuration / 60)
        let seconds = Int(estimatedDuration.truncatingRemainder(dividingBy: 60))
        return "\(minutes):\(String(format: "%02d", seconds))"
    }
}

struct ProjectStatistics {
    let totalPages: Double
    let totalWords: Int
    let totalScenes: Int
    let scenesByAct: [Int: Int]
    let estimatedRuntime: TimeInterval

    var formattedPages: String {
        String(format: "%.1f", totalPages)
    }

    var formattedRuntime: String {
        let minutes = Int(estimatedRuntime / 60)
        return "\(minutes) min"
    }

    var completionPercentage: Double {
        // Assuming 110 pages for feature film
        let target: Double = 110
        return min(totalPages / target * 100, 100)
    }
}
