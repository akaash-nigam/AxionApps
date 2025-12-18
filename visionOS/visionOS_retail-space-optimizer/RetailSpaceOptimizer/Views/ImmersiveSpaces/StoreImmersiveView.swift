import SwiftUI
import RealityKit

/// Immersive full-scale store walkthrough view
struct StoreImmersiveView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    @State private var showControls = true
    @State private var isPlaying = false

    var body: some View {
        ZStack {
            // 3D Immersive Scene
            RealityView { content in
                await setupImmersiveScene(content: content)
            } update: { content in
                updateImmersiveScene(content: content)
            }

            // Minimal Controls Overlay
            VStack {
                Spacer()

                if showControls {
                    ImmersiveControls(
                        isPlaying: $isPlaying,
                        onExit: { Task { await dismissImmersiveSpace() } }
                    )
                    .padding(.bottom, 40)
                }
            }
        }
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { _ in
                    showControls.toggle()
                }
        )
    }

    // MARK: - Scene Setup

    private func setupImmersiveScene(content: RealityViewContent) async {
        // Create life-size store environment
        // In a real implementation, would:
        // 1. Load store 3D model at 1:1 scale
        // 2. Position user at store entrance
        // 3. Add ambient audio
        // 4. Load customer journey visualizations

        // Add ambient lighting
        let ambient = AmbientLight()
        ambient.light.intensity = 5000
        content.add(ambient)

        // Add directional sunlight
        let sun = DirectionalLight()
        sun.light.intensity = 50000
        sun.position = [10, 20, 10]
        sun.look(at: [0, 0, 0], from: sun.position, relativeTo: nil)
        content.add(sun)
    }

    private func updateImmersiveScene(content: RealityViewContent) {
        // Update scene based on state
        if isPlaying {
            // Start automated tour
        } else {
            // Stop tour
        }
    }
}

// MARK: - Immersive Controls

struct ImmersiveControls: View {
    @Binding var isPlaying: Bool
    let onExit: () -> Void

    var body: some View {
        HStack(spacing: 24) {
            Button(action: { isPlaying.toggle() }) {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.title2)
            }
            .buttonStyle(.bordered)

            Button(action: {}) {
                Image(systemName: "arrow.clockwise")
                    .font(.title2)
            }
            .buttonStyle(.bordered)

            Spacer()
                .frame(width: 40)

            Button(action: onExit) {
                Image(systemName: "xmark")
                    .font(.title2)
            }
            .buttonStyle(.bordered)
            .tint(.red)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 8)
    }
}

#Preview {
    StoreImmersiveView()
        .environment(AppModel())
}
