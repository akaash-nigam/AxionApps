//
//  RecognitionService.swift
//  HomeMaintenanceOracle
//
//  Created on 2025-11-24.
//

import Foundation
import CoreGraphics

// MARK: - Protocol

protocol RecognitionServiceProtocol {
    func recognizeAppliance(from image: CGImage) async throws -> RecognitionResult
}

// MARK: - Implementation

class RecognitionService: RecognitionServiceProtocol {

    // MARK: - Properties

    private let preprocessor: ImagePreprocessorProtocol
    private let classifier: ApplianceClassifierWrapper

    // MARK: - Initialization

    init(
        preprocessor: ImagePreprocessorProtocol = ImagePreprocessor(),
        classifier: ApplianceClassifierWrapper = ApplianceClassifierWrapper()
    ) {
        self.preprocessor = preprocessor
        self.classifier = classifier
    }

    // MARK: - Recognition

    func recognizeAppliance(from image: CGImage) async throws -> RecognitionResult {
        // Step 1: Validate image quality
        let qualityCheck = preprocessor.isImageSuitable(image)
        guard qualityCheck.suitable else {
            throw RecognitionError.imageProcessingFailed
        }

        // Step 2: Preprocess image for ML model
        guard let preprocessedImage = preprocessor.preprocess(
            image,
            targetSize: classifier.inputSize
        ) else {
            throw RecognitionError.imageProcessingFailed
        }

        // Step 3: Classify appliance
        do {
            let classificationResult = try await classifier.classify(preprocessedImage)

            // Step 4: Map to RecognitionResult
            let result = RecognitionResult(
                category: classificationResult.primaryCategory,
                brand: nil, // Brand detection comes from separate model (Epic 1, Story 1.5)
                model: nil,
                confidence: classificationResult.confidence,
                alternatives: classificationResult.alternatives.map { prediction in
                    RecognitionAlternative(
                        category: prediction.category,
                        confidence: prediction.confidence
                    )
                }
            )

            return result

        } catch let error as ClassificationError {
            // Map classification errors to recognition errors
            switch error {
            case .modelNotLoaded:
                throw RecognitionError.modelLoadFailed
            case .lowConfidence(let confidence):
                throw RecognitionError.lowConfidence(confidence)
            case .noResultsReturned:
                throw RecognitionError.noApplianceDetected
            case .inferenceFailed, .invalidInput:
                throw RecognitionError.imageProcessingFailed
            }
        }
    }
}

// MARK: - Mock Implementation

class MockRecognitionService: RecognitionServiceProtocol {

    var mockResult: RecognitionResult?
    var shouldThrowError = false

    func recognizeAppliance(from image: CGImage) async throws -> RecognitionResult {
        if shouldThrowError {
            throw RecognitionError.noApplianceDetected
        }

        return mockResult ?? RecognitionResult(
            category: "refrigerator",
            brand: "Mock Brand",
            model: "MOCK123",
            confidence: 0.95,
            alternatives: []
        )
    }
}

// MARK: - Errors

enum RecognitionError: Error, LocalizedError {
    case noApplianceDetected
    case lowConfidence(Float)
    case modelLoadFailed
    case imageProcessingFailed

    var errorDescription: String? {
        switch self {
        case .noApplianceDetected:
            return "No appliance detected in the image"
        case .lowConfidence(let confidence):
            return "Low confidence: \(Int(confidence * 100))%"
        case .modelLoadFailed:
            return "Failed to load ML model"
        case .imageProcessingFailed:
            return "Failed to process image"
        }
    }
}
