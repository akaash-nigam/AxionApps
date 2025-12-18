//
//  ScreenplayFormatter.swift
//  SpatialScreenplayWorkshop
//
//  Created on 2025-11-24
//

import UIKit
import CoreGraphics

/// Formats screenplay elements for PDF rendering
final class ScreenplayFormatter {
    // MARK: - Properties

    let configuration: PDFExporter.ExportConfiguration
    let courierFont: UIFont
    let lineHeight: CGFloat = 12  // Courier 12pt line height

    // MARK: - Initialization

    init(configuration: PDFExporter.ExportConfiguration) {
        self.configuration = configuration
        self.courierFont = UIFont(name: configuration.font, size: configuration.fontSize) ?? UIFont.monospacedSystemFont(ofSize: configuration.fontSize, weight: .regular)
    }

    // MARK: - Scene Rendering

    func renderScene(_ scene: Scene, at position: CGPoint, in context: CGContext, pageWidth: CGFloat) -> CGFloat {
        var yOffset: CGFloat = 0

        // Slug line
        let slugLineHeight = renderSlugLine(scene.slugLine, at: CGPoint(x: position.x, y: position.y - yOffset), in: context)
        yOffset += slugLineHeight + lineHeight  // Extra line after slug

        // Scene number (if enabled)
        if configuration.includeSceneNumbers {
            renderSceneNumber(scene.sceneNumber, at: CGPoint(x: position.x + ScriptFormatter.Margins.slugLine - 50, y: position.y - yOffset + slugLineHeight), in: context)
        }

        // Scene content
        for element in scene.content.elements {
            let elementHeight = renderElement(element, at: CGPoint(x: position.x, y: position.y - yOffset), in: context, pageWidth: pageWidth)
            yOffset += elementHeight
        }

        return yOffset
    }

    // MARK: - Element Rendering

    private func renderElement(_ element: ScriptElement, at position: CGPoint, in context: CGContext, pageWidth: CGFloat) -> CGFloat {
        switch element {
        case .action(let action):
            return renderAction(action, at: position, in: context, pageWidth: pageWidth)

        case .dialogue(let dialogue):
            return renderDialogue(dialogue, at: position, in: context, pageWidth: pageWidth)

        case .transition(let transition):
            return renderTransition(transition, at: position, in: context)

        case .shot(let shot):
            return renderShot(shot, at: position, in: context)
        }
    }

    // MARK: - Slug Line

    private func renderSlugLine(_ slugLine: SlugLine, at position: CGPoint, in context: CGContext) -> CGFloat {
        let text = slugLine.formatted.uppercased()
        let attributes: [NSAttributedString.Key: Any] = [
            .font: courierFont,
            .foregroundColor: UIColor.black
        ]

        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let size = attributedString.size()

        context.saveGState()
        context.translateBy(x: ScriptFormatter.Margins.slugLine, y: position.y)
        attributedString.draw(at: .zero)
        context.restoreGState()

        return size.height
    }

    private func renderSceneNumber(_ number: Int, at position: CGPoint, in context: CGContext) {
        let text = "\(number)."
        let attributes: [NSAttributedString.Key: Any] = [
            .font: courierFont,
            .foregroundColor: UIColor.black
        ]

        let attributedString = NSAttributedString(string: text, attributes: attributes)

        context.saveGState()
        context.translateBy(x: position.x, y: position.y)
        attributedString.draw(at: .zero)
        context.restoreGState()
    }

    // MARK: - Action

    private func renderAction(_ action: ActionElement, at position: CGPoint, in context: CGContext, pageWidth: CGFloat) -> CGFloat {
        let maxWidth = ScriptFormatter.Margins.actionRight - ScriptFormatter.Margins.action

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 0
        paragraphStyle.alignment = .left

        let attributes: [NSAttributedString.Key: Any] = [
            .font: courierFont,
            .foregroundColor: UIColor.black,
            .paragraphStyle: paragraphStyle
        ]

        let attributedString = NSAttributedString(string: action.text, attributes: attributes)
        let rect = CGRect(x: ScriptFormatter.Margins.action, y: position.y, width: maxWidth, height: CGFloat.greatestFiniteMagnitude)

        let boundingRect = attributedString.boundingRect(with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin], context: nil)

        context.saveGState()
        attributedString.draw(in: rect)
        context.restoreGState()

        return boundingRect.height + lineHeight  // Extra line after action
    }

    // MARK: - Dialogue

    private func renderDialogue(_ dialogue: DialogueElement, at position: CGPoint, in context: CGContext, pageWidth: CGFloat) -> CGFloat {
        var yOffset: CGFloat = 0

        // Character name
        let characterHeight = renderCharacterName(dialogue.characterName, at: CGPoint(x: position.x, y: position.y - yOffset), in: context)
        yOffset += characterHeight

        // Parenthetical (if present)
        if let parenthetical = dialogue.parenthetical {
            let parentheticalHeight = renderParenthetical(parenthetical, at: CGPoint(x: position.x, y: position.y - yOffset), in: context)
            yOffset += parentheticalHeight
        }

        // Dialogue lines
        let dialogueText = dialogue.lines.joined(separator: " ")
        let dialogueHeight = renderDialogueText(dialogueText, at: CGPoint(x: position.x, y: position.y - yOffset), in: context)
        yOffset += dialogueHeight + lineHeight  // Extra line after dialogue

        return yOffset
    }

    private func renderCharacterName(_ name: String, at position: CGPoint, in context: CGContext) -> CGFloat {
        let text = name.uppercased()
        let attributes: [NSAttributedString.Key: Any] = [
            .font: courierFont,
            .foregroundColor: UIColor.black
        ]

        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let size = attributedString.size()

        context.saveGState()
        context.translateBy(x: ScriptFormatter.Margins.character, y: position.y)
        attributedString.draw(at: .zero)
        context.restoreGState()

        return size.height
    }

    private func renderParenthetical(_ text: String, at position: CGPoint, in context: CGContext) -> CGFloat {
        let formattedText = "(\(text))"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: courierFont,
            .foregroundColor: UIColor.black
        ]

        let attributedString = NSAttributedString(string: formattedText, attributes: attributes)
        let size = attributedString.size()

        context.saveGState()
        context.translateBy(x: ScriptFormatter.Margins.parenthetical, y: position.y)
        attributedString.draw(at: .zero)
        context.restoreGState()

        return size.height
    }

    private func renderDialogueText(_ text: String, at position: CGPoint, in context: CGContext) -> CGFloat {
        let maxWidth = ScriptFormatter.Margins.dialogueRight - ScriptFormatter.Margins.dialogue

        let attributes: [NSAttributedString.Key: Any] = [
            .font: courierFont,
            .foregroundColor: UIColor.black
        ]

        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let rect = CGRect(x: ScriptFormatter.Margins.dialogue, y: position.y, width: maxWidth, height: CGFloat.greatestFiniteMagnitude)

        let boundingRect = attributedString.boundingRect(with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin], context: nil)

        context.saveGState()
        attributedString.draw(in: rect)
        context.restoreGState()

        return boundingRect.height
    }

    // MARK: - Transition

    private func renderTransition(_ transition: TransitionElement, at position: CGPoint, in context: CGContext) -> CGFloat {
        let text = transition.displayText.uppercased()
        let attributes: [NSAttributedString.Key: Any] = [
            .font: courierFont,
            .foregroundColor: UIColor.black
        ]

        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let size = attributedString.size()

        context.saveGState()
        context.translateBy(x: ScriptFormatter.Margins.transition, y: position.y)
        attributedString.draw(at: .zero)
        context.restoreGState()

        return size.height + lineHeight  // Extra line after transition
    }

    // MARK: - Shot

    private func renderShot(_ shot: ShotElement, at position: CGPoint, in context: CGContext) -> CGFloat {
        let text = shot.text.uppercased()
        let attributes: [NSAttributedString.Key: Any] = [
            .font: courierFont,
            .foregroundColor: UIColor.black
        ]

        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let size = attributedString.size()

        context.saveGState()
        context.translateBy(x: ScriptFormatter.Margins.slugLine, y: position.y)
        attributedString.draw(at: .zero)
        context.restoreGState()

        return size.height + lineHeight
    }
}
