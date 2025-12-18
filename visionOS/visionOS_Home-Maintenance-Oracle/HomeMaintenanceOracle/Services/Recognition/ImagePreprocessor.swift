//
//  ImagePreprocessor.swift
//  HomeMaintenanceOracle
//
//  Created on 2025-11-24.
//  Image preprocessing for ML model input
//

import Foundation
import CoreGraphics
import CoreImage
import Vision

protocol ImagePreprocessorProtocol {
    func preprocess(_ image: CGImage, targetSize: CGSize) -> CGImage?
    func normalize(_ image: CGImage) -> CGImage?
    func enhanceForRecognition(_ image: CGImage) -> CGImage?
}

class ImagePreprocessor: ImagePreprocessorProtocol {

    // MARK: - Properties

    private let context = CIContext()

    // MARK: - Preprocessing

    /// Preprocess image for ML model input
    /// - Parameters:
    ///   - image: Input image
    ///   - targetSize: Target size for ML model (typically 224x224)
    /// - Returns: Preprocessed image
    func preprocess(_ image: CGImage, targetSize: CGSize) -> CGImage? {
        guard let ciImage = CIImage(cgImage: image) else { return nil }

        // 1. Resize to target size
        let resized = resize(ciImage, to: targetSize)

        // 2. Normalize colors
        let normalized = normalizeColors(resized)

        // 3. Convert back to CGImage
        return context.createCGImage(normalized, from: normalized.extent)
    }

    /// Normalize image pixel values (0-255 → 0-1)
    func normalize(_ image: CGImage) -> CGImage? {
        guard let ciImage = CIImage(cgImage: image) else { return nil }

        let normalized = normalizeColors(ciImage)

        return context.createCGImage(normalized, from: normalized.extent)
    }

    /// Enhance image for better recognition (brightness, contrast, sharpness)
    func enhanceForRecognition(_ image: CGImage) -> CGImage? {
        guard var ciImage = CIImage(cgImage: image) else { return nil }

        // Adjust exposure
        if let exposureFilter = CIFilter(name: "CIExposureAdjust") {
            exposureFilter.setValue(ciImage, forKey: kCIInputImageKey)
            exposureFilter.setValue(0.5, forKey: kCIInputEVKey)
            if let output = exposureFilter.outputImage {
                ciImage = output
            }
        }

        // Enhance contrast
        if let contrastFilter = CIFilter(name: "CIColorControls") {
            contrastFilter.setValue(ciImage, forKey: kCIInputImageKey)
            contrastFilter.setValue(1.1, forKey: kCIInputContrastKey)
            if let output = contrastFilter.outputImage {
                ciImage = output
            }
        }

        // Sharpen
        if let sharpenFilter = CIFilter(name: "CISharpenLuminance") {
            sharpenFilter.setValue(ciImage, forKey: kCIInputImageKey)
            sharpenFilter.setValue(0.4, forKey: kCIInputSharpnessKey)
            if let output = sharpenFilter.outputImage {
                ciImage = output
            }
        }

        return context.createCGImage(ciImage, from: ciImage.extent)
    }

    // MARK: - Private Methods

    private func resize(_ image: CIImage, to size: CGSize) -> CIImage {
        let scale = min(
            size.width / image.extent.width,
            size.height / image.extent.height
        )

        let resized = image.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        // Center crop
        let offsetX = (resized.extent.width - size.width) / 2
        let offsetY = (resized.extent.height - size.height) / 2

        return resized.cropped(to: CGRect(
            x: offsetX,
            y: offsetY,
            width: size.width,
            height: size.height
        ))
    }

    private func normalizeColors(_ image: CIImage) -> CIImage {
        // Normalize to 0-1 range (Core ML expects normalized input)
        guard let filter = CIFilter(name: "CIColorControls") else { return image }

        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(1.0, forKey: kCIInputSaturationKey)
        filter.setValue(1.0, forKey: kCIInputBrightnessKey)
        filter.setValue(1.0, forKey: kCIInputContrastKey)

        return filter.outputImage ?? image
    }
}

// MARK: - ML Model Input Conversion

extension ImagePreprocessor {

    /// Convert CGImage to CVPixelBuffer for Core ML input
    /// - Parameters:
    ///   - image: Input image
    ///   - width: Target width
    ///   - height: Target height
    /// - Returns: CVPixelBuffer for ML model
    func createPixelBuffer(from image: CGImage, width: Int, height: Int) -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer?

        let attributes: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]

        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32ARGB,
            attributes as CFDictionary,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }

        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }

        guard let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        ) else {
            return nil
        }

        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))

        return buffer
    }
}

// MARK: - Image Quality Checker

extension ImagePreprocessor {

    /// Check if image is suitable for recognition
    func isImageSuitable(_ image: CGImage) -> (suitable: Bool, reason: String?) {
        // Check resolution
        let minResolution = 224
        if image.width < minResolution || image.height < minResolution {
            return (false, "Image resolution too low (minimum \(minResolution)x\(minResolution))")
        }

        // Check if image is too dark or too bright
        let brightness = calculateBrightness(image)
        if brightness < 0.1 {
            return (false, "Image too dark")
        }
        if brightness > 0.9 {
            return (false, "Image too bright")
        }

        // Check if image is blurry
        let sharpness = calculateSharpness(image)
        if sharpness < 0.3 {
            return (false, "Image too blurry")
        }

        return (true, nil)
    }

    private func calculateBrightness(_ image: CGImage) -> Float {
        guard let ciImage = CIImage(cgImage: image) else { return 0.5 }

        let extent = ciImage.extent
        let inputExtent = CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: ciImage, kCIInputExtentKey: inputExtent]),
              let outputImage = filter.outputImage else {
            return 0.5
        }

        var bitmap = [UInt8](repeating: 0, count: 4)
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        let brightness = (Float(bitmap[0]) + Float(bitmap[1]) + Float(bitmap[2])) / (3.0 * 255.0)

        return brightness
    }

    private func calculateSharpness(_ image: CGImage) -> Float {
        // Simple Laplacian variance method for blur detection
        // Higher values = sharper image
        // This is a simplified implementation

        guard let ciImage = CIImage(cgImage: image) else { return 0.5 }

        // Apply edge detection
        guard let edgesFilter = CIFilter(name: "CIEdges") else { return 0.5 }
        edgesFilter.setValue(ciImage, forKey: kCIInputImageKey)
        edgesFilter.setValue(1.0, forKey: kCIInputIntensityKey)

        guard let edgesImage = edgesFilter.outputImage else { return 0.5 }

        // Calculate mean intensity of edges
        let extent = edgesImage.extent
        let inputExtent = CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)

        guard let avgFilter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: edgesImage, kCIInputExtentKey: inputExtent]),
              let outputImage = avgFilter.outputImage else {
            return 0.5
        }

        var bitmap = [UInt8](repeating: 0, count: 4)
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        let sharpness = Float(bitmap[0]) / 255.0

        return sharpness
    }
}
