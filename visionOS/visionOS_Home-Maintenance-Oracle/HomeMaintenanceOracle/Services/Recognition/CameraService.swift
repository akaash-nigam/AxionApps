//
//  CameraService.swift
//  HomeMaintenanceOracle
//
//  Created on 2025-11-24.
//  Camera capture service for recognition
//

import Foundation
import AVFoundation
import CoreImage
import UIKit

protocol CameraServiceProtocol {
    func requestPermission() async -> Bool
    func captureImage() async throws -> CGImage
    var authorizationStatus: CameraAuthorizationStatus { get }
}

enum CameraAuthorizationStatus {
    case authorized
    case denied
    case restricted
    case notDetermined
}

enum CameraError: Error, LocalizedError {
    case permissionDenied
    case captureFailure
    case noImageCaptured
    case cameraUnavailable

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Camera permission denied. Please enable in Settings."
        case .captureFailure:
            return "Failed to capture image from camera."
        case .noImageCaptured:
            return "No image was captured."
        case .cameraUnavailable:
            return "Camera is not available on this device."
        }
    }
}

// MARK: - Implementation

class CameraService: CameraServiceProtocol {

    // MARK: - Properties

    private var captureSession: AVCaptureSession?
    private var photoOutput: AVCapturePhotoOutput?

    var authorizationStatus: CameraAuthorizationStatus {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        return status.toCameraAuthorizationStatus
    }

    // MARK: - Permission

    func requestPermission() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .authorized:
            return true

        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)

        case .denied, .restricted:
            return false

        @unknown default:
            return false
        }
    }

    // MARK: - Capture

    func captureImage() async throws -> CGImage {
        // Verify permission
        guard await requestPermission() else {
            throw CameraError.permissionDenied
        }

        #if targetEnvironment(simulator)
        // Return mock image for simulator
        return try createMockImage()
        #else
        // Real device implementation
        return try await captureFromDevice()
        #endif
    }

    // MARK: - Private Methods

    private func captureFromDevice() async throws -> CGImage {
        // Setup capture session if not already configured
        if captureSession == nil {
            try setupCaptureSession()
        }

        guard let photoOutput = photoOutput else {
            throw CameraError.captureFailure
        }

        // Capture photo
        return try await withCheckedThrowingContinuation { continuation in
            let settings = AVCapturePhotoSettings()

            let delegate = PhotoCaptureDelegate { result in
                continuation.resume(with: result)
            }

            // Store delegate to keep it alive during capture
            objc_setAssociatedObject(
                photoOutput,
                &AssociatedKeys.photoCaptureDelegate,
                delegate,
                .OBJC_ASSOCIATION_RETAIN
            )

            photoOutput.capturePhoto(with: settings, delegate: delegate)
        }
    }

    private func setupCaptureSession() throws {
        let session = AVCaptureSession()
        session.beginConfiguration()

        // Configure session preset for high quality
        if session.canSetSessionPreset(.photo) {
            session.sessionPreset = .photo
        }

        // Find default camera device
        guard let videoDevice = AVCaptureDevice.default(for: .video) else {
            throw CameraError.cameraUnavailable
        }

        // Create input
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoDevice)
        } catch {
            throw CameraError.captureFailure
        }

        // Add input to session
        guard session.canAddInput(videoInput) else {
            throw CameraError.captureFailure
        }
        session.addInput(videoInput)

        // Create and add photo output
        let output = AVCapturePhotoOutput()
        guard session.canAddOutput(output) else {
            throw CameraError.captureFailure
        }
        session.addOutput(output)

        session.commitConfiguration()

        // Start session
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }

        self.captureSession = session
        self.photoOutput = output
    }

    private func createMockImage() throws -> CGImage {
        // Create a simple mock image for testing
        let width = 640
        let height = 480
        let bitsPerComponent = 8
        let bytesPerRow = width * 4

        var pixels = [UInt8](repeating: 128, count: width * height * 4)

        // Create a simple gradient or pattern
        for y in 0..<height {
            for x in 0..<width {
                let offset = (y * width + x) * 4
                pixels[offset] = UInt8(x * 255 / width)     // R
                pixels[offset + 1] = UInt8(y * 255 / height) // G
                pixels[offset + 2] = 128                     // B
                pixels[offset + 3] = 255                     // A
            }
        }

        guard let context = CGContext(
            data: &pixels,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ),
        let cgImage = context.makeImage() else {
            throw CameraError.noImageCaptured
        }

        return cgImage
    }

    deinit {
        captureSession?.stopRunning()
    }
}

// MARK: - Photo Capture Delegate

private class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {

    private let completion: (Result<CGImage, Error>) -> Void

    init(completion: @escaping (Result<CGImage, Error>) -> Void) {
        self.completion = completion
        super.init()
    }

    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let error = error {
            completion(.failure(CameraError.captureFailure))
            return
        }

        guard let imageData = photo.fileDataRepresentation(),
              let cgImage = UIImage(data: imageData)?.cgImage else {
            completion(.failure(CameraError.noImageCaptured))
            return
        }

        completion(.success(cgImage))
    }
}

// MARK: - Associated Keys

private enum AssociatedKeys {
    static var photoCaptureDelegate = "photoCaptureDelegate"
}

// MARK: - Mock Implementation

class MockCameraService: CameraServiceProtocol {

    var shouldGrantPermission = true
    var authorizationStatus: CameraAuthorizationStatus = .notDetermined

    func requestPermission() async -> Bool {
        if shouldGrantPermission {
            authorizationStatus = .authorized
        } else {
            authorizationStatus = .denied
        }
        return shouldGrantPermission
    }

    func captureImage() async throws -> CGImage {
        guard authorizationStatus == .authorized else {
            throw CameraError.permissionDenied
        }

        // Return a mock test image
        let width = 640
        let height = 480
        var pixels = [UInt8](repeating: 200, count: width * height * 4)

        guard let context = CGContext(
            data: &pixels,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ),
        let cgImage = context.makeImage() else {
            throw CameraError.noImageCaptured
        }

        return cgImage
    }
}

// MARK: - Extensions

extension AVAuthorizationStatus {
    var toCameraAuthorizationStatus: CameraAuthorizationStatus {
        switch self {
        case .authorized:
            return .authorized
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .notDetermined
        }
    }
}
