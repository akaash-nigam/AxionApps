//
//  ColorHarmonyService.swift
//  WardrobeConsultant
//
//  Created by Claude Code
//  Copyright © 2025 Wardrobe Consultant. All rights reserved.
//

import Foundation
import SwiftUI

/// Service for calculating color harmony and compatibility
class ColorHarmonyService {
    static let shared = ColorHarmonyService()

    private init() {}

    // MARK: - Color Harmony Types
    enum HarmonyType {
        case complementary
        case analogous
        case triadic
        case splitComplementary
        case tetradic
        case monochromatic
    }

    // MARK: - Color Compatibility
    /// Calculate compatibility score between two colors (0.0 to 1.0)
    func compatibilityScore(color1: String, color2: String) -> Float {
        guard let hsl1 = hexToHSL(color1),
              let hsl2 = hexToHSL(color2) else {
            return 0.5 // Neutral score for invalid colors
        }

        // Calculate hue difference
        let hueDiff = abs(hsl1.hue - hsl2.hue)
        let normalizedHueDiff = min(hueDiff, 360 - hueDiff)

        // Calculate saturation difference
        let satDiff = abs(hsl1.saturation - hsl2.saturation)

        // Calculate lightness difference
        let lightDiff = abs(hsl1.lightness - hsl2.lightness)

        // Complementary colors (opposite on color wheel)
        if normalizedHueDiff > 150 && normalizedHueDiff < 210 {
            return 0.95
        }

        // Analogous colors (close on color wheel)
        if normalizedHueDiff < 30 {
            return 0.85
        }

        // Triadic relationship
        if (normalizedHueDiff > 110 && normalizedHueDiff < 130) {
            return 0.80
        }

        // Monochromatic (same hue, different sat/light)
        if normalizedHueDiff < 10 && (satDiff > 0.2 || lightDiff > 0.2) {
            return 0.75
        }

        // Neutral colors work well together
        if hsl1.saturation < 0.1 && hsl2.saturation < 0.1 {
            return 0.85
        }

        // Default score based on harmony
        let harmonyScore = 1.0 - (normalizedHueDiff / 180.0)
        let contrastScore = min(lightDiff * 2, 1.0)

        return Float((harmonyScore + contrastScore) / 2)
    }

    // MARK: - Find Matching Colors
    /// Find colors from a list that match well with the target color
    func findMatchingColors(_ colors: [String], for targetColor: String, limit: Int = 5) -> [(color: String, score: Float)] {
        var scores: [(color: String, score: Float)] = []

        for color in colors where color != targetColor {
            let score = compatibilityScore(color1: targetColor, color2: color)
            scores.append((color: color, score: score))
        }

        return scores.sorted { $0.score > $1.score }.prefix(limit).map { $0 }
    }

    // MARK: - Color Palette Generation
    /// Generate a harmonious color palette based on a base color
    func generateHarmoniousPalette(baseColor: String, type: HarmonyType) -> [String] {
        guard let hsl = hexToHSL(baseColor) else {
            return [baseColor]
        }

        var palette: [String] = [baseColor]

        switch type {
        case .complementary:
            let complement = HSL(
                hue: (hsl.hue + 180).truncatingRemainder(dividingBy: 360),
                saturation: hsl.saturation,
                lightness: hsl.lightness
            )
            palette.append(hslToHex(complement))

        case .analogous:
            let analog1 = HSL(
                hue: (hsl.hue + 30).truncatingRemainder(dividingBy: 360),
                saturation: hsl.saturation,
                lightness: hsl.lightness
            )
            let analog2 = HSL(
                hue: (hsl.hue - 30 + 360).truncatingRemainder(dividingBy: 360),
                saturation: hsl.saturation,
                lightness: hsl.lightness
            )
            palette.append(contentsOf: [hslToHex(analog1), hslToHex(analog2)])

        case .triadic:
            let triadic1 = HSL(
                hue: (hsl.hue + 120).truncatingRemainder(dividingBy: 360),
                saturation: hsl.saturation,
                lightness: hsl.lightness
            )
            let triadic2 = HSL(
                hue: (hsl.hue + 240).truncatingRemainder(dividingBy: 360),
                saturation: hsl.saturation,
                lightness: hsl.lightness
            )
            palette.append(contentsOf: [hslToHex(triadic1), hslToHex(triadic2)])

        case .splitComplementary:
            let split1 = HSL(
                hue: (hsl.hue + 150).truncatingRemainder(dividingBy: 360),
                saturation: hsl.saturation,
                lightness: hsl.lightness
            )
            let split2 = HSL(
                hue: (hsl.hue + 210).truncatingRemainder(dividingBy: 360),
                saturation: hsl.saturation,
                lightness: hsl.lightness
            )
            palette.append(contentsOf: [hslToHex(split1), hslToHex(split2)])

        case .tetradic:
            let tet1 = HSL(hue: (hsl.hue + 90).truncatingRemainder(dividingBy: 360), saturation: hsl.saturation, lightness: hsl.lightness)
            let tet2 = HSL(hue: (hsl.hue + 180).truncatingRemainder(dividingBy: 360), saturation: hsl.saturation, lightness: hsl.lightness)
            let tet3 = HSL(hue: (hsl.hue + 270).truncatingRemainder(dividingBy: 360), saturation: hsl.saturation, lightness: hsl.lightness)
            palette.append(contentsOf: [hslToHex(tet1), hslToHex(tet2), hslToHex(tet3)])

        case .monochromatic:
            let lighter = HSL(hue: hsl.hue, saturation: hsl.saturation, lightness: min(hsl.lightness + 0.2, 1.0))
            let darker = HSL(hue: hsl.hue, saturation: hsl.saturation, lightness: max(hsl.lightness - 0.2, 0.0))
            let muted = HSL(hue: hsl.hue, saturation: max(hsl.saturation - 0.3, 0.0), lightness: hsl.lightness)
            palette.append(contentsOf: [hslToHex(lighter), hslToHex(darker), hslToHex(muted)])
        }

        return palette
    }

    // MARK: - Neutrals Detection
    /// Check if a color is considered neutral
    func isNeutralColor(_ hexColor: String) -> Bool {
        guard let hsl = hexToHSL(hexColor) else { return false }
        return hsl.saturation < 0.15
    }

    // MARK: - Color Contrast
    /// Calculate contrast ratio between two colors (for readability)
    func contrastRatio(color1: String, color2: String) -> Float {
        guard let rgb1 = hexToRGB(color1),
              let rgb2 = hexToRGB(color2) else {
            return 1.0
        }

        let l1 = relativeLuminance(rgb1)
        let l2 = relativeLuminance(rgb2)

        let lighter = max(l1, l2)
        let darker = min(l1, l2)

        return Float((lighter + 0.05) / (darker + 0.05))
    }

    private func relativeLuminance(_ rgb: RGB) -> Double {
        let r = rgb.red <= 0.03928 ? rgb.red / 12.92 : pow((rgb.red + 0.055) / 1.055, 2.4)
        let g = rgb.green <= 0.03928 ? rgb.green / 12.92 : pow((rgb.green + 0.055) / 1.055, 2.4)
        let b = rgb.blue <= 0.03928 ? rgb.blue / 12.92 : pow((rgb.blue + 0.055) / 1.055, 2.4)

        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }

    // MARK: - Color Space Conversions
    private func hexToRGB(_ hex: String) -> RGB? {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b: Double
        switch hex.count {
        case 6: // RGB
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF) / 255.0
            b = Double(int & 0xFF) / 255.0
        default:
            return nil
        }

        return RGB(red: r, green: g, blue: b)
    }

    private func hexToHSL(_ hex: String) -> HSL? {
        guard let rgb = hexToRGB(hex) else { return nil }

        let max = Swift.max(rgb.red, rgb.green, rgb.blue)
        let min = Swift.min(rgb.red, rgb.green, rgb.blue)
        let delta = max - min

        var hue: Double = 0
        let lightness = (max + min) / 2
        let saturation = delta == 0 ? 0 : delta / (1 - abs(2 * lightness - 1))

        if delta != 0 {
            if max == rgb.red {
                hue = 60 * ((rgb.green - rgb.blue) / delta).truncatingRemainder(dividingBy: 6)
            } else if max == rgb.green {
                hue = 60 * ((rgb.blue - rgb.red) / delta + 2)
            } else {
                hue = 60 * ((rgb.red - rgb.green) / delta + 4)
            }
        }

        if hue < 0 {
            hue += 360
        }

        return HSL(hue: hue, saturation: saturation, lightness: lightness)
    }

    private func hslToHex(_ hsl: HSL) -> String {
        let c = (1 - abs(2 * hsl.lightness - 1)) * hsl.saturation
        let x = c * (1 - abs(((hsl.hue / 60).truncatingRemainder(dividingBy: 2)) - 1))
        let m = hsl.lightness - c / 2

        var r: Double = 0, g: Double = 0, b: Double = 0

        switch hsl.hue {
        case 0..<60:
            (r, g, b) = (c, x, 0)
        case 60..<120:
            (r, g, b) = (x, c, 0)
        case 120..<180:
            (r, g, b) = (0, c, x)
        case 180..<240:
            (r, g, b) = (0, x, c)
        case 240..<300:
            (r, g, b) = (x, 0, c)
        default:
            (r, g, b) = (c, 0, x)
        }

        let red = Int((r + m) * 255)
        let green = Int((g + m) * 255)
        let blue = Int((b + m) * 255)

        return String(format: "#%02X%02X%02X", red, green, blue)
    }
}

// MARK: - Supporting Types
struct RGB {
    let red: Double
    let green: Double
    let blue: Double
}

struct HSL {
    let hue: Double        // 0-360
    let saturation: Double // 0-1
    let lightness: Double  // 0-1
}
