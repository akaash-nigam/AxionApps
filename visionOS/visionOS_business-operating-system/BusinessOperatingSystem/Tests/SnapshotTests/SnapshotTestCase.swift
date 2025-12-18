//
//  SnapshotTestCase.swift
//  BusinessOperatingSystemTests
//
//  Created by BOS Team on 2025-01-20.
//

import XCTest
import SwiftUI
@testable import BusinessOperatingSystem

// MARK: - Snapshot Test Infrastructure

/// Base class for snapshot testing SwiftUI views
/// Provides utilities for capturing and comparing view snapshots
class SnapshotTestCase: XCTestCase {
    // MARK: - Configuration

    /// Directory for storing reference snapshots
    var snapshotDirectory: URL {
        let fileManager = FileManager.default
        let testBundle = Bundle(for: type(of: self))

        // Try to find __Snapshots__ directory next to test file
        if let resourcePath = testBundle.resourcePath {
            let snapshotsPath = URL(fileURLWithPath: resourcePath)
                .appendingPathComponent("__Snapshots__")
            return snapshotsPath
        }

        // Fallback to temp directory
        return fileManager.temporaryDirectory.appendingPathComponent("Snapshots")
    }

    /// Whether to record new snapshots (set to true to update references)
    var recordMode: Bool = false

    /// Tolerance for image comparison (0.0 to 1.0)
    var perceptualPrecision: Float = 0.98

    /// Default viewport sizes for testing
    enum ViewportSize {
        case visionOSWindow      // Standard visionOS window
        case visionOSWide        // Wide window
        case visionOSCompact     // Compact window
        case custom(CGSize)

        var size: CGSize {
            switch self {
            case .visionOSWindow: return CGSize(width: 1280, height: 720)
            case .visionOSWide: return CGSize(width: 1600, height: 900)
            case .visionOSCompact: return CGSize(width: 800, height: 600)
            case .custom(let size): return size
            }
        }
    }

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        createSnapshotDirectoryIfNeeded()
    }

    private func createSnapshotDirectoryIfNeeded() {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: snapshotDirectory.path) {
            try? fileManager.createDirectory(at: snapshotDirectory, withIntermediateDirectories: true)
        }
    }

    // MARK: - Snapshot Testing

    /// Assert that a SwiftUI view matches its reference snapshot
    func assertSnapshot<V: View>(
        matching view: V,
        as name: String? = nil,
        viewport: ViewportSize = .visionOSWindow,
        file: StaticString = #file,
        testName: String = #function,
        line: UInt = #line
    ) {
        let snapshotName = name ?? sanitizeTestName(testName)
        let referenceURL = snapshotDirectory.appendingPathComponent("\(snapshotName).png")

        // Render view to image
        guard let currentImage = renderView(view, size: viewport.size) else {
            XCTFail("Failed to render view to image", file: file, line: line)
            return
        }

        if recordMode {
            // Save new reference snapshot
            saveSnapshot(currentImage, to: referenceURL)
            XCTFail("Recording snapshot: \(snapshotName). Set recordMode = false to run tests.", file: file, line: line)
            return
        }

        // Load reference snapshot
        guard let referenceImage = loadSnapshot(from: referenceURL) else {
            XCTFail("Reference snapshot not found: \(snapshotName). Set recordMode = true to record.", file: file, line: line)
            return
        }

        // Compare images
        let result = compareImages(currentImage, referenceImage)

        if !result.matches {
            // Save diff image for debugging
            let diffURL = snapshotDirectory.appendingPathComponent("\(snapshotName)_diff.png")
            let failedURL = snapshotDirectory.appendingPathComponent("\(snapshotName)_failed.png")

            saveSnapshot(currentImage, to: failedURL)
            if let diffImage = result.diffImage {
                saveSnapshot(diffImage, to: diffURL)
            }

            XCTFail(
                "Snapshot mismatch: \(snapshotName). Difference: \(String(format: "%.2f%%", (1 - result.similarity) * 100))",
                file: file,
                line: line
            )
        }
    }

    /// Assert snapshot with environment and state configuration
    func assertSnapshot<V: View>(
        matching view: V,
        with configuration: SnapshotConfiguration,
        as name: String? = nil,
        file: StaticString = #file,
        testName: String = #function,
        line: UInt = #line
    ) {
        let configuredView = view
            .environment(\.colorScheme, configuration.colorScheme)
            .environment(\.dynamicTypeSize, configuration.dynamicTypeSize)

        let snapshotName = name ?? "\(sanitizeTestName(testName))_\(configuration.suffix)"

        assertSnapshot(
            matching: configuredView,
            as: snapshotName,
            viewport: configuration.viewport,
            file: file,
            testName: testName,
            line: line
        )
    }

    // MARK: - Configuration

    struct SnapshotConfiguration {
        var colorScheme: ColorScheme = .dark
        var dynamicTypeSize: DynamicTypeSize = .medium
        var viewport: ViewportSize = .visionOSWindow

        var suffix: String {
            var parts: [String] = []
            parts.append(colorScheme == .dark ? "dark" : "light")
            if dynamicTypeSize != .medium {
                parts.append("type_\(dynamicTypeSize)")
            }
            return parts.joined(separator: "_")
        }

        static let `default` = SnapshotConfiguration()
        static let light = SnapshotConfiguration(colorScheme: .light)
        static let dark = SnapshotConfiguration(colorScheme: .dark)
        static let largeText = SnapshotConfiguration(dynamicTypeSize: .xxxLarge)
    }

    // MARK: - Rendering

    private func renderView<V: View>(_ view: V, size: CGSize) -> CGImage? {
        let hostingController = NSHostingController(rootView: view.frame(width: size.width, height: size.height))
        hostingController.view.frame = CGRect(origin: .zero, size: size)

        // Force layout
        hostingController.view.layoutSubtreeIfNeeded()

        // Render to bitmap
        guard let bitmapRep = hostingController.view.bitmapImageRepForCachingDisplay(in: hostingController.view.bounds) else {
            return nil
        }

        hostingController.view.cacheDisplay(in: hostingController.view.bounds, to: bitmapRep)
        return bitmapRep.cgImage
    }

    // MARK: - Image I/O

    private func saveSnapshot(_ image: CGImage, to url: URL) {
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, kUTTypePNG, 1, nil) else { return }
        CGImageDestinationAddImage(destination, image, nil)
        CGImageDestinationFinalize(destination)
    }

    private func loadSnapshot(from url: URL) -> CGImage? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        return CGImageSourceCreateImageAtIndex(source, 0, nil)
    }

    // MARK: - Image Comparison

    struct ComparisonResult {
        let matches: Bool
        let similarity: Float
        let diffImage: CGImage?
    }

    private func compareImages(_ image1: CGImage, _ image2: CGImage) -> ComparisonResult {
        // Check dimensions match
        guard image1.width == image2.width && image1.height == image2.height else {
            return ComparisonResult(matches: false, similarity: 0, diffImage: nil)
        }

        let width = image1.width
        let height = image1.height
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel

        // Create pixel buffers
        var pixels1 = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        var pixels2 = [UInt8](repeating: 0, count: width * height * bytesPerPixel)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

        guard let context1 = CGContext(
            data: &pixels1,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return ComparisonResult(matches: false, similarity: 0, diffImage: nil)
        }

        guard let context2 = CGContext(
            data: &pixels2,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return ComparisonResult(matches: false, similarity: 0, diffImage: nil)
        }

        context1.draw(image1, in: CGRect(x: 0, y: 0, width: width, height: height))
        context2.draw(image2, in: CGRect(x: 0, y: 0, width: width, height: height))

        // Compare pixels
        var matchingPixels = 0
        var diffPixels = [UInt8](repeating: 0, count: width * height * bytesPerPixel)

        for i in stride(from: 0, to: pixels1.count, by: bytesPerPixel) {
            let r1 = pixels1[i], g1 = pixels1[i+1], b1 = pixels1[i+2]
            let r2 = pixels2[i], g2 = pixels2[i+1], b2 = pixels2[i+2]

            let diff = abs(Int(r1) - Int(r2)) + abs(Int(g1) - Int(g2)) + abs(Int(b1) - Int(b2))

            if diff < 30 {  // Tolerance threshold
                matchingPixels += 1
                diffPixels[i] = 0
                diffPixels[i+1] = 0
                diffPixels[i+2] = 0
                diffPixels[i+3] = 255
            } else {
                diffPixels[i] = 255      // Red for differences
                diffPixels[i+1] = 0
                diffPixels[i+2] = 0
                diffPixels[i+3] = 255
            }
        }

        let totalPixels = width * height
        let similarity = Float(matchingPixels) / Float(totalPixels)

        // Create diff image
        var diffImageRef: CGImage?
        if let diffContext = CGContext(
            data: &diffPixels,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) {
            diffImageRef = diffContext.makeImage()
        }

        return ComparisonResult(
            matches: similarity >= perceptualPrecision,
            similarity: similarity,
            diffImage: diffImageRef
        )
    }

    // MARK: - Helpers

    private func sanitizeTestName(_ name: String) -> String {
        // Remove test prefix and parentheses
        var sanitized = name
            .replacingOccurrences(of: "test", with: "")
            .replacingOccurrences(of: "()", with: "")
            .trimmingCharacters(in: .whitespaces)

        // Convert camelCase to snake_case
        sanitized = sanitized.unicodeScalars.reduce("") { result, scalar in
            if CharacterSet.uppercaseLetters.contains(scalar) && !result.isEmpty {
                return result + "_" + String(scalar).lowercased()
            }
            return result + String(scalar).lowercased()
        }

        return sanitized
    }
}

// MARK: - Snapshot Test Helpers

extension SnapshotTestCase {
    /// Run snapshot tests for multiple configurations
    func assertSnapshots<V: View>(
        matching view: V,
        configurations: [SnapshotConfiguration] = [.dark, .light],
        as baseName: String? = nil,
        file: StaticString = #file,
        testName: String = #function,
        line: UInt = #line
    ) {
        for config in configurations {
            assertSnapshot(
                matching: view,
                with: config,
                as: baseName,
                file: file,
                testName: testName,
                line: line
            )
        }
    }
}

// MARK: - Import Compatibility

#if canImport(AppKit)
import AppKit
typealias NSHostingController = NSHostingController
#endif
