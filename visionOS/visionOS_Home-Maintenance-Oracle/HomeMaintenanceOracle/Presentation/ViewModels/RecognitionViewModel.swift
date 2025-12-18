//
//  RecognitionViewModel.swift
//  HomeMaintenanceOracle
//
//  Created on 2025-11-24.
//

import Foundation
import CoreGraphics

@MainActor
class RecognitionViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var isRecognizing = false
    @Published var recognitionResult: RecognitionResult?
    @Published var error: Error?
    @Published var cameraPermissionStatus: CameraAuthorizationStatus = .notDetermined

    // MARK: - Dependencies

    private let recognitionService: RecognitionServiceProtocol
    private let inventoryService: InventoryServiceProtocol
    private let cameraService: CameraServiceProtocol

    // MARK: - Initialization

    init(
        recognitionService: RecognitionServiceProtocol = AppDependencies.shared.recognitionService,
        inventoryService: InventoryServiceProtocol = AppDependencies.shared.inventoryService,
        cameraService: CameraServiceProtocol = CameraService()
    ) {
        self.recognitionService = recognitionService
        self.inventoryService = inventoryService
        self.cameraService = cameraService

        // Initialize camera permission status
        self.cameraPermissionStatus = cameraService.authorizationStatus
    }

    // MARK: - Methods

    /// Request camera permission
    func requestCameraPermission() async {
        let granted = await cameraService.requestPermission()
        cameraPermissionStatus = cameraService.authorizationStatus

        if !granted {
            error = RecognitionViewModelError.cameraPermissionDenied
        }
    }

    /// Capture image from camera and recognize appliance
    func captureAndRecognize() {
        Task {
            isRecognizing = true
            defer { isRecognizing = false }

            do {
                // Step 1: Check camera permission
                guard cameraPermissionStatus == .authorized else {
                    await requestCameraPermission()
                    guard cameraPermissionStatus == .authorized else {
                        throw RecognitionViewModelError.cameraPermissionDenied
                    }
                }

                // Step 2: Capture image from camera
                let capturedImage = try await cameraService.captureImage()

                // Step 3: Recognize appliance
                let result = try await recognitionService.recognizeAppliance(from: capturedImage)
                recognitionResult = result

            } catch {
                self.error = error
            }
        }
    }

    func saveAppliance() {
        guard let result = recognitionResult else { return }

        Task {
            let appliance = Appliance(
                brand: result.brand ?? "Unknown",
                model: result.model ?? "Unknown",
                category: ApplianceCategory(rawValue: result.category) ?? .other
            )

            do {
                try await inventoryService.addAppliance(appliance)
                reset()
            } catch {
                self.error = error
            }
        }
    }

    func reset() {
        recognitionResult = nil
        error = nil
    }
}

// MARK: - Errors

enum RecognitionViewModelError: Error, LocalizedError {
    case cameraPermissionDenied
    case cameraNotAvailable

    var errorDescription: String? {
        switch self {
        case .cameraPermissionDenied:
            return "Camera permission denied. Please enable camera access in Settings."
        case .cameraNotAvailable:
            return "Camera is not available on this device."
        }
    }
}
