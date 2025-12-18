//
//  ApplianceClassifierWrapper.swift
//  HomeMaintenanceOracle
//
//  Created on 2025-11-24.
//  Core ML model wrapper for appliance classification
//

import Foundation
import CoreML
import Vision
import CoreGraphics

/// Wrapper for the ApplianceClassifier Core ML model
class ApplianceClassifierWrapper {

    // MARK: - Properties

    private var model: VNCoreMLModel?
    private let modelName = "ApplianceClassifier"

    // MARK: - Model Configuration

    /// Model input size (typically 224x224 for image classification)
    let inputSize = CGSize(width: 224, height: 224)

    /// Confidence threshold for valid predictions
    let confidenceThreshold: Float = 0.6

    // MARK: - Initialization

    init() {
        loadModel()
    }

    // MARK: - Model Loading

    private func loadModel() {
        // TODO: Replace with actual Core ML model when available
        // For now, this is a placeholder that will be replaced in Sprint 2

        /*
        do {
            // Load the compiled Core ML model
            let configuration = MLModelConfiguration()
            configuration.computeUnits = .all // Use Neural Engine when available

            let mlModel = try ApplianceClassifier(configuration: configuration).model
            model = try VNCoreMLModel(for: mlModel)

            print("✅ ApplianceClassifier model loaded successfully")
        } catch {
            print("❌ Failed to load ApplianceClassifier model: \(error)")
        }
        */
    }

    // MARK: - Classification

    /// Classify an appliance from an image
    /// - Parameter image: Preprocessed CGImage
    /// - Returns: Classification results with confidence scores
    func classify(_ image: CGImage) async throws -> ClassificationResult {
        // TODO: Replace with real Core ML inference
        // Placeholder implementation for Sprint 2 development

        #if DEBUG
        // Mock results for development
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5s delay

        return ClassificationResult(
            primaryCategory: "refrigerator",
            confidence: 0.85,
            alternatives: [
                CategoryPrediction(category: "refrigerator", confidence: 0.85),
                CategoryPrediction(category: "freezer", confidence: 0.10),
                CategoryPrediction(category: "other", confidence: 0.05)
            ]
        )
        #else
        guard let model = model else {
            throw ClassificationError.modelNotLoaded
        }

        return try await performClassification(on: image, using: model)
        #endif
    }

    /// Perform actual classification using Vision framework
    private func performClassification(on image: CGImage, using model: VNCoreMLModel) async throws -> ClassificationResult {
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNCoreMLRequest(model: model) { request, error in
                if let error = error {
                    continuation.resume(throwing: ClassificationError.inferenceFailed(error))
                    return
                }

                guard let results = request.results as? [VNClassificationObservation],
                      let topResult = results.first else {
                    continuation.resume(throwing: ClassificationError.noResultsReturned)
                    return
                }

                // Check confidence threshold
                if topResult.confidence < self.confidenceThreshold {
                    continuation.resume(throwing: ClassificationError.lowConfidence(topResult.confidence))
                    return
                }

                // Build result
                let alternatives = results.prefix(5).map { observation in
                    CategoryPrediction(
                        category: observation.identifier,
                        confidence: observation.confidence
                    )
                }

                let result = ClassificationResult(
                    primaryCategory: topResult.identifier,
                    confidence: topResult.confidence,
                    alternatives: alternatives
                )

                continuation.resume(returning: result)
            }

            // Configure request
            request.imageCropAndScaleOption = .centerCrop

            // Perform request
            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: ClassificationError.inferenceFailed(error))
            }
        }
    }

    // MARK: - Batch Classification

    /// Classify multiple images in batch (more efficient for multiple predictions)
    func classifyBatch(_ images: [CGImage]) async throws -> [ClassificationResult] {
        // For now, process sequentially
        // TODO: Optimize with batch prediction in future sprint
        var results: [ClassificationResult] = []

        for image in images {
            let result = try await classify(image)
            results.append(result)
        }

        return results
    }
}

// MARK: - Result Types

/// Result from appliance classification
struct ClassificationResult {
    /// Primary predicted category
    let primaryCategory: String

    /// Confidence score (0.0 - 1.0)
    let confidence: Float

    /// Alternative predictions with confidence scores
    let alternatives: [CategoryPrediction]

    /// Get category as enum if valid
    var applianceCategory: ApplianceCategory? {
        return ApplianceCategory(rawValue: primaryCategory)
    }
}

/// Individual category prediction with confidence
struct CategoryPrediction {
    let category: String
    let confidence: Float
}

// MARK: - Errors

enum ClassificationError: Error, LocalizedError {
    case modelNotLoaded
    case inferenceFailed(Error)
    case noResultsReturned
    case lowConfidence(Float)
    case invalidInput

    var errorDescription: String? {
        switch self {
        case .modelNotLoaded:
            return "ML model not loaded. Please ensure ApplianceClassifier.mlmodel is included in the app bundle."
        case .inferenceFailed(let error):
            return "Classification failed: \(error.localizedDescription)"
        case .noResultsReturned:
            return "No classification results returned from model"
        case .lowConfidence(let confidence):
            return "Classification confidence too low: \(String(format: "%.2f%%", confidence * 100))"
        case .invalidInput:
            return "Invalid input image for classification"
        }
    }
}

// MARK: - Model Information

extension ApplianceClassifierWrapper {

    /// Get information about the loaded model
    var modelInfo: ModelInfo {
        return ModelInfo(
            name: modelName,
            inputSize: inputSize,
            supportedCategories: ApplianceCategory.allCases.map { $0.rawValue },
            confidenceThreshold: confidenceThreshold,
            isLoaded: model != nil
        )
    }
}

struct ModelInfo {
    let name: String
    let inputSize: CGSize
    let supportedCategories: [String]
    let confidenceThreshold: Float
    let isLoaded: Bool
}
