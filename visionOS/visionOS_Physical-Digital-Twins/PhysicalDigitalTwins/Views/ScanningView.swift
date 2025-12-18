//
//  ScanningView.swift
//  PhysicalDigitalTwins
//
//  Camera-based barcode scanning view
//

import SwiftUI
import AVFoundation

struct ScanningView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: ScanningViewModel?
    @State private var cameraPermissionGranted = false
    @State private var showingPermissionAlert = false

    var body: some View {
        ZStack {
            // Camera preview
            if cameraPermissionGranted, let viewModel = viewModel {
                CameraPreviewView(session: viewModel.captureSession)
                    .edgesIgnoringSafeArea(.all)
            } else {
                Color.black
                    .edgesIgnoringSafeArea(.all)
            }

            // Overlay UI
            VStack {
                // Top bar
                HStack {
                    Button("Cancel") {
                        viewModel?.stopScanning()
                        dismiss()
                    }
                    .buttonStyle(.bordered)

                    Spacer()
                }
                .padding()

                Spacer()

                // Scanning indicator
                if viewModel?.isProcessing == true {
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Scanning...")
                            .font(.headline)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                }

                // Success state
                if let item = viewModel?.createdItem {
                    SuccessView(item: item) {
                        Task {
                            await appState.loadInventory()
                        }
                        dismiss()
                    }
                }

                // Error state
                if let error = viewModel?.currentError {
                    ErrorView(error: error) {
                        viewModel?.retryScanning()
                    }
                }

                Spacer()

                // Instructions
                if viewModel?.isScanning == true && viewModel?.isProcessing == false {
                    Text("Point camera at a barcode")
                        .font(.headline)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .padding()
                }
            }
        }
        .task {
            // Initialize viewModel with appState's dependencies
            if viewModel == nil {
                viewModel = ScanningViewModel(
                    visionService: appState.dependencies.visionService,
                    twinFactory: appState.dependencies.twinFactory,
                    storageService: appState.dependencies.storageService
                )
            }
            await checkCameraPermission()
        }
        .alert("Camera Permission Required", isPresented: $showingPermissionAlert) {
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("Camera access is required to scan barcodes. Please enable it in Settings.")
        }
    }

    private func checkCameraPermission() async {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraPermissionGranted = true
            await setupAndStartScanning()

        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            cameraPermissionGranted = granted
            if granted {
                await setupAndStartScanning()
            } else {
                showingPermissionAlert = true
            }

        case .denied, .restricted:
            showingPermissionAlert = true

        @unknown default:
            showingPermissionAlert = true
        }
    }

    private func setupAndStartScanning() async {
        do {
            try await viewModel.setupCamera()
            viewModel.startScanning()
        } catch {
            viewModel.currentError = AppError(from: error)
        }
    }
}

// MARK: - Camera Preview View

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession?

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black

        if let session = session {
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = view.bounds
            view.layer.addSublayer(previewLayer)

            // Store layer for updates
            context.coordinator.previewLayer = previewLayer
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let layer = context.coordinator.previewLayer {
            layer.frame = uiView.bounds
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}

// MARK: - Success View

struct SuccessView: View {
    let item: InventoryItem
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)

            Text("Item Added!")
                .font(.title2)
                .fontWeight(.bold)

            Text(item.digitalTwin.displayName)
                .font(.headline)
                .multilineTextAlignment(.center)

            Button("Done") {
                onDismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .padding()
    }
}

// MARK: - Error View

struct ErrorView: View {
    let error: AppError
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundStyle(.orange)

            Text(error.localizedDescription)
                .font(.headline)
                .multilineTextAlignment(.center)

            if let suggestion = error.recoverySuggestion {
                Text(suggestion)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button("Try Again") {
                onRetry()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .padding()
    }
}

#Preview {
    ScanningView()
        .environment(AppState(dependencies: AppDependencies()))
}
