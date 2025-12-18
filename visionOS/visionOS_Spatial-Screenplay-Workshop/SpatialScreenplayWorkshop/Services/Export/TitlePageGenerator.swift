//
//  TitlePageGenerator.swift
//  SpatialScreenplayWorkshop
//
//  Created on 2025-11-24
//

import UIKit
import CoreGraphics

/// Generates industry-standard screenplay title page
final class TitlePageGenerator {
    // MARK: - Rendering

    func render(project: Project, in rect: CGRect, context: CGContext) {
        let courierFont = UIFont(name: "Courier", size: 12) ?? UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        let courierBold = UIFont(name: "Courier-Bold", size: 12) ?? UIFont.monospacedSystemFont(ofSize: 12, weight: .bold)

        // Center area for title
        let centerY = rect.height / 2

        // Title (centered, bold, larger)
        renderTitle(project.title, at: CGPoint(x: rect.width / 2, y: centerY - 60), in: context)

        // Subtitle (if project type)
        let subtitle = project.type.rawValue
        renderSubtitle(subtitle, at: CGPoint(x: rect.width / 2, y: centerY - 20), in: context, font: courierFont)

        // "Written by" label
        renderLabel("Written by", at: CGPoint(x: rect.width / 2, y: centerY + 40), in: context, font: courierFont)

        // Author name
        renderAuthor(project.author, at: CGPoint(x: rect.width / 2, y: centerY + 60), in: context, font: courierBold)

        // Bottom left: Contact info (if available)
        if let contact = project.metadata.contact, !contact.isEmpty {
            renderContactInfo(contact, at: CGPoint(x: 72, y: 72), in: context, font: courierFont)
        }

        // Bottom right: Draft info
        let draftInfo = generateDraftInfo(project)
        renderDraftInfo(draftInfo, at: CGPoint(x: rect.width - 72, y: 72), in: context, font: courierFont)
    }

    // MARK: - Title Components

    private func renderTitle(_ title: String, at position: CGPoint, in context: CGContext) {
        let font = UIFont(name: "Courier-Bold", size: 24) ?? UIFont.boldSystemFont(ofSize: 24)

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.black
        ]

        let attributedString = NSAttributedString(string: title.uppercased(), attributes: attributes)
        let size = attributedString.size()

        // Center horizontally
        let x = position.x - (size.width / 2)

        context.saveGState()
        attributedString.draw(at: CGPoint(x: x, y: position.y))
        context.restoreGState()
    }

    private func renderSubtitle(_ text: String, at position: CGPoint, in context: CGContext, font: UIFont) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.black
        ]

        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let size = attributedString.size()

        // Center horizontally
        let x = position.x - (size.width / 2)

        context.saveGState()
        attributedString.draw(at: CGPoint(x: x, y: position.y))
        context.restoreGState()
    }

    private func renderLabel(_ text: String, at position: CGPoint, in context: CGContext, font: UIFont) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.black
        ]

        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let size = attributedString.size()

        // Center horizontally
        let x = position.x - (size.width / 2)

        context.saveGState()
        attributedString.draw(at: CGPoint(x: x, y: position.y))
        context.restoreGState()
    }

    private func renderAuthor(_ name: String, at position: CGPoint, in context: CGContext, font: UIFont) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.black
        ]

        let attributedString = NSAttributedString(string: name, attributes: attributes)
        let size = attributedString.size()

        // Center horizontally
        let x = position.x - (size.width / 2)

        context.saveGState()
        attributedString.draw(at: CGPoint(x: x, y: position.y))
        context.restoreGState()
    }

    // MARK: - Footer Information

    private func renderContactInfo(_ contact: String, at position: CGPoint, in context: CGContext, font: UIFont) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.black
        ]

        let attributedString = NSAttributedString(string: contact, attributes: attributes)

        context.saveGState()
        attributedString.draw(at: position)
        context.restoreGState()
    }

    private func renderDraftInfo(_ info: String, at position: CGPoint, in context: CGContext, font: UIFont) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.black
        ]

        let attributedString = NSAttributedString(string: info, attributes: attributes)
        let size = attributedString.size()

        // Right-align
        let x = position.x - size.width

        context.saveGState()
        attributedString.draw(at: CGPoint(x: x, y: position.y))
        context.restoreGState()
    }

    // MARK: - Helper Methods

    private func generateDraftInfo(_ project: Project) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long

        var info: [String] = []

        // Draft version
        if let version = project.metadata.version, !version.isEmpty {
            info.append(version)
        } else {
            info.append("Draft")
        }

        // Modified date
        if let date = project.modifiedAt {
            info.append(dateFormatter.string(from: date))
        }

        return info.joined(separator: "\n")
    }
}
