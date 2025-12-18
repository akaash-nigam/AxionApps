//
//  ARRepairView.swift
//  FieldServiceAR
//
//  Immersive AR repair guidance view
//

import SwiftUI
import RealityKit

struct ARRepairView: View {
    @Environment(\.appState) private var appState
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    @State private var viewModel: ARRepairViewModel?
    @State private var currentStep: ProcedureStep?
    @State private var showControls = true

    var body: some View {
        ZStack {
            // RealityView for AR content
            RealityView { content in
                // Setup AR scene
                await setupARScene(content: content)
            } update: { content in
                // Update AR overlays based on current step
                await updateAROverlays(content: content, step: currentStep)
            }

            // Floating UI Controls
            VStack {
                // Top bar: Progress and info
                topBarView
                    .opacity(showControls ? 1 : 0)

                Spacer()

                // Bottom controls: Actions
                bottomControlsView
                    .opacity(showControls ? 1 : 0)
            }
            .animation(.easeInOut, value: showControls)
        }
        .task {
            await initializeAR()
        }
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { _ in
                    showControls.toggle()
                }
        )
    }

    // MARK: - Top Bar

    private var topBarView: some View {
        HStack {
            // Progress
            if let procedure = appState.selectedJob?.procedures.first {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Step \(currentStep?.sequenceNumber ?? 1) of \(procedure.steps.count)")
                        .font(.headline)

                    ProgressView(value: Double(procedure.completedStepsCount), total: Double(procedure.steps.count))
                        .frame(width: 200)
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Spacer()

            // Timer
            TimerView()
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
    }

    // MARK: - Bottom Controls

    private var bottomControlsView: some View {
        VStack(spacing: 16) {
            // Current step instruction
            if let step = currentStep {
                Text(step.instruction)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .frame(maxWidth: 600)
            }

            // Action buttons
            HStack(spacing: 16) {
                Button {
                    Task {
                        await previousStep()
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }
                .buttonStyle(.bordered)
                .disabled(currentStep?.sequenceNumber == 1)

                Button {
                    // Capture photo
                } label: {
                    Image(systemName: "camera.fill")
                        .font(.title2)
                }
                .buttonStyle(.bordered)

                Button {
                    Task {
                        await completeStep()
                    }
                } label: {
                    Label("Complete Step", systemImage: "checkmark")
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button {
                    // Call expert
                } label: {
                    Image(systemName: "phone.fill")
                        .font(.title2)
                }
                .buttonStyle(.bordered)

                Button {
                    Task {
                        await exitARMode()
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.title2)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }

    // MARK: - AR Setup

    private func setupARScene(content: RealityViewContent) async {
        // Initialize AR session
        // Load equipment model
        // Setup spatial anchors
        // Add initial overlays
    }

    private func updateAROverlays(content: RealityViewContent, step: ProcedureStep?) async {
        guard let step = step else { return }

        // Clear previous overlays
        // Add new overlays for current step
        // Position based on step configuration
    }

    private func initializeAR() async {
        guard let job = appState.selectedJob else { return }

        // Load first procedure
        if let procedure = job.procedures.first {
            currentStep = procedure.steps.first
        }

        // Start AR tracking
        appState.isARActive = true
    }

    // MARK: - Step Navigation

    private func completeStep() async {
        guard let step = currentStep,
              let job = appState.selectedJob,
              let procedure = job.procedures.first else { return }

        // Mark step complete
        if let techId = appState.currentUser?.id {
            step.complete(by: techId)
        }

        // Move to next step
        if let nextIndex = procedure.steps.firstIndex(where: { $0.id == step.id }),
           nextIndex + 1 < procedure.steps.count {
            currentStep = procedure.steps[nextIndex + 1]
        } else {
            // All steps complete
            await completeJob()
        }
    }

    private func previousStep() async {
        guard let step = currentStep,
              let job = appState.selectedJob,
              let procedure = job.procedures.first else { return }

        if let currentIndex = procedure.steps.firstIndex(where: { $0.id == step.id }),
           currentIndex > 0 {
            currentStep = procedure.steps[currentIndex - 1]
        }
    }

    private func completeJob() async {
        // Show completion summary
        // Upload job completion
        await exitARMode()
    }

    private func exitARMode() async {
        appState.isARActive = false
        await dismissImmersiveSpace()
    }
}

// MARK: - Timer View

struct TimerView: View {
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "clock.fill")
            Text(formatTime(elapsedTime))
                .monospacedDigit()
        }
        .font(.subheadline)
        .onAppear {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                elapsedTime += 1
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        let seconds = Int(time) % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

#Preview {
    ARRepairView()
}
