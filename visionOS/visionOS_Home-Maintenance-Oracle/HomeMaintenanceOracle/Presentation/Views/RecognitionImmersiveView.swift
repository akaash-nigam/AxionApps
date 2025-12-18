//
//  RecognitionImmersiveView.swift
//  HomeMaintenanceOracle
//
//  Created on 2025-11-24.
//  Immersive space for appliance recognition
//

import SwiftUI
import RealityKit

struct RecognitionImmersiveView: View {

    // MARK: - Properties

    @StateObject private var viewModel = RecognitionViewModel()
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @State private var showManualEntry = false

    // MARK: - Body

    var body: some View {
        RealityView { content in
            // Create anchor entity positioned relative to camera
            let anchor = AnchorEntity(.head)

            // Add visual feedback sphere for targeting
            let targetSphere = ModelEntity(
                mesh: .generateSphere(radius: 0.02),
                materials: [SimpleMaterial(color: .blue.withAlphaComponent(0.5), isMetallic: false)]
            )
            targetSphere.position = [0, 0, -1.0] // 1 meter in front of user
            anchor.addChild(targetSphere)

            content.add(anchor)
        }
        .overlay(alignment: .top) {
            recognitionOverlay
        }
        .task {
            // Request camera permission on appear
            if viewModel.cameraPermissionStatus == .notDetermined {
                await viewModel.requestCameraPermission()
            }
        }
        .sheet(isPresented: $showManualEntry) {
            ManualEntryView()
        }
    }

    // MARK: - View Components

    private var recognitionOverlay: some View {
        VStack(spacing: 20) {
            // Camera permission check
            if viewModel.cameraPermissionStatus == .denied || viewModel.cameraPermissionStatus == .restricted {
                cameraPermissionDeniedCard
            } else if viewModel.isRecognizing {
                ProgressView("Recognizing...")
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            } else if let error = viewModel.error {
                errorCard(error)
            } else if let result = viewModel.recognitionResult {
                recognitionResultCard(result)
            } else {
                instructionsCard
            }

            Button("Close") {
                Task {
                    await dismissImmersiveSpace()
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }

    private var cameraPermissionDeniedCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "camera.fill.badge.exclamationmark")
                .font(.largeTitle)
                .foregroundStyle(.orange)

            Text("Camera Access Required")
                .font(.headline)

            Text("Please enable camera access in Settings to use recognition.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(width: 300)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func errorCard(_ error: Error) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundStyle(.red)

            Text("Recognition Failed")
                .font(.headline)

            Text(error.localizedDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 12) {
                Button("Try Again") {
                    viewModel.reset()
                }
                .buttonStyle(.bordered)

                Button("Manual Entry") {
                    showManualEntry = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: 320)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var instructionsCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "viewfinder")
                .font(.largeTitle)
                .foregroundStyle(.blue)

            Text("Point at an appliance")
                .font(.headline)

            Text("Center the appliance in your view")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button("Capture") {
                viewModel.captureAndRecognize()
            }
            .buttonStyle(.borderedProminent)

            Button("Manual Entry") {
                showManualEntry = true
            }
            .buttonStyle(.bordered)
            .font(.caption)
        }
        .padding()
        .frame(width: 300)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func recognitionResultCard(_ result: RecognitionResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: result.categoryIcon)
                    .font(.title)
                    .foregroundStyle(.blue)

                VStack(alignment: .leading) {
                    Text(result.category)
                        .font(.headline)

                    if let brand = result.brand {
                        Text(brand)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Text("\(Int(result.confidence * 100))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()

            HStack(spacing: 12) {
                Button("Save") {
                    viewModel.saveAppliance()
                }
                .buttonStyle(.borderedProminent)

                Button("Try Again") {
                    viewModel.reset()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .frame(width: 350)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Preview

#Preview {
    RecognitionImmersiveView()
}
