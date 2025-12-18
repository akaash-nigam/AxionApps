//
//  VisionService.swift
//  PhysicalDigitalTwins
//
//  Vision framework for barcode scanning
//

import Foundation
import Vision
import CoreImage

// MARK: - Protocol

protocol VisionService: Sendable {
    func scanBarcode(from image: CIImage) async throws -> BarcodeResult?
}

// MARK: - Barcode Result

struct BarcodeResult: Sendable {
    let type: VNBarcodeSymbology
    let value: String
    let confidence: Float
    let boundingBox: CGRect
}

// MARK: - Implementation

class VisionServiceImpl: VisionService {
    func scanBarcode(from image: CIImage) async throws -> BarcodeResult? {
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectBarcodesRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let results = request.results as? [VNBarcodeObservation],
                      let first = results.first,
                      let payload = first.payloadStringValue else {
                    continuation.resume(returning: nil)
                    return
                }

                let result = BarcodeResult(
                    type: first.symbology,
                    value: payload,
                    confidence: first.confidence,
                    boundingBox: first.boundingBox
                )
                continuation.resume(returning: result)
            }

            // Set supported barcode types
            request.symbologies = [
                .ean8, .ean13,      // European Article Numbers
                .upce,              // Universal Product Codes
                .qr,                // QR codes
                .code128, .code39,  // General barcodes
                .itf14              // Additional formats
            ]

            let handler = VNImageRequestHandler(ciImage: image, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
