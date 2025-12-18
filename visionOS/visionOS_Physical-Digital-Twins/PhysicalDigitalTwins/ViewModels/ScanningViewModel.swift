//
//  ScanningViewModel.swift
//  PhysicalDigitalTwins
//
//  View model for barcode scanning
//

import Foundation
import AVFoundation
import CoreImage
import Observation

@Observable
@MainActor
class ScanningViewModel {
    // Dependencies
    private let visionService: VisionService
    private let twinFactory: TwinFactory
    private let storageService: StorageService

    // State
    var isScanning = false
    var isProcessing = false
    var recognizedBarcode: BarcodeResult?
    var currentError: AppError?
    var createdItem: InventoryItem?

    // Camera session
    var captureSession: AVCaptureSession?

    init(visionService: VisionService, twinFactory: TwinFactory, storageService: StorageService) {
        self.visionService = visionService
        self.twinFactory = twinFactory
        self.storageService = storageService
    }

    // MARK: - Camera Setup

    func setupCamera() async throws {
        let session = AVCaptureSession()
        session.sessionPreset = .high

        // Get camera device
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            throw RecognitionError.cameraPermissionDenied
        }

        // Add input
        let videoInput = try AVCaptureDeviceInput(device: videoDevice)
        guard session.canAddInput(videoInput) else {
            throw RecognitionError.cameraPermissionDenied
        }
        session.addInput(videoInput)

        // Add output
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        guard session.canAddOutput(videoOutput) else {
            throw RecognitionError.cameraPermissionDenied
        }
        session.addOutput(videoOutput)

        self.captureSession = session
    }

    func startScanning() {
        guard let session = captureSession else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
        isScanning = true
    }

    func stopScanning() {
        captureSession?.stopRunning()
        isScanning = false
    }

    // MARK: - Barcode Processing

    func processSampleBuffer(_ sampleBuffer: CMSampleBuffer) async {
        guard !isProcessing else { return }
        isProcessing = true

        defer {
            Task { @MainActor in
                self.isProcessing = false
            }
        }

        // Convert to CIImage
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)

        // Scan for barcode
        do {
            if let barcode = try await visionService.scanBarcode(from: ciImage) {
                await handleBarcodeDetected(barcode)
            }
        } catch {
            print("Barcode scanning error: \(error)")
        }
    }

    private func handleBarcodeDetected(_ barcode: BarcodeResult) async {
        // Stop scanning
        stopScanning()
        recognizedBarcode = barcode

        // Haptic feedback for scan detection
        HapticManager.shared.itemScanned()

        // Create twin from barcode
        do {
            let twin = try await twinFactory.createTwin(from: barcode)
            let item = InventoryItem(digitalTwin: twin)

            // Save to storage
            try await storageService.saveItem(item)

            createdItem = item
            HapticManager.shared.success()
        } catch {
            currentError = AppError(from: error)
            HapticManager.shared.error()
        }
    }

    func reset() {
        recognizedBarcode = nil
        currentError = nil
        createdItem = nil
        isProcessing = false
    }

    func retryScanning() {
        reset()
        startScanning()
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension ScanningViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        Task { @MainActor in
            await processSampleBuffer(sampleBuffer)
        }
    }
}
