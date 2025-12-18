import SwiftUI
import RealityKit

struct MusicStudioImmersiveView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var audioEngine: SpatialAudioEngine
    @State private var scene: SpatialMusicScene?

    var body: some View {
        RealityView { content in
            // Create spatial music scene
            scene = SpatialMusicScene()

            if let scene = scene {
                // Setup the scene
                await scene.setupScene(in: content)

                // Load default environment
                await loadStudioEnvironment()
            }
        } update: { content in
            // Update scene based on app state
            if let scene = scene {
                updateSceneForCurrentMode()
            }
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    handleEntityTap(value.entity)
                }
        )
        .gesture(
            DragGesture()
                .targetedToAnyEntity()
                .onChanged { value in
                    handleEntityDrag(value)
                }
        )
        .overlay(alignment: .top) {
            HUDView()
        }
        .overlay(alignment: .bottomLeading) {
            InstrumentLibraryButton()
        }
        .task {
            // Start hand tracking and gesture recognition
            await startGestureRecognition()
        }
    }

    // MARK: - Scene Management

    private func loadStudioEnvironment() async {
        guard let scene = scene else { return }

        // Load environment based on current configuration
        let environment = appCoordinator.currentComposition?.arrangement.roomConfiguration.environmentType
                         ?? .intimateStudio

        await scene.loadEnvironment(environment)

        // Position instruments from composition
        if let composition = appCoordinator.currentComposition {
            for track in composition.tracks {
                let instrument = Instrument(
                    type: track.instrument,
                    position: track.position
                )
                // Add instrument to scene
                _ = scene.placeInstrument(instrument, at: track.position)
                // Add audio source
                _ = audioEngine.addInstrument(instrument, at: track.position)
            }
        }
    }

    private func updateSceneForCurrentMode() {
        guard let scene = scene else { return }

        // Set mode based on AppCoordinator state
        if appCoordinator.isLearningMode {
            scene.setMode(.learning)
        } else if appCoordinator.isCollaborating {
            scene.setMode(.collaboration)
        } else if appCoordinator.currentComposition != nil {
            scene.setMode(.composition)
        } else {
            scene.setMode(.composition)
        }
    }

    // MARK: - Gesture Handling

    private func handleEntityTap(_ entity: Entity) {
        // Check if entity is an instrument
        if let instrumentEntity = entity as? InstrumentEntity {
            // Activate instrument
            activateInstrument(instrumentEntity)
        }
    }

    private func handleEntityDrag(_ value: EntityTargetValue<DragGesture.Value>) {
        // Handle dragging instruments to reposition them
        if let instrumentEntity = value.entity as? InstrumentEntity {
            let translation = value.convert(value.translation3D, from: .local, to: .scene)
            instrumentEntity.position += translation

            // Update audio position
            audioEngine.updateInstrumentPosition(
                instrumentEntity.instrument.id,
                position: instrumentEntity.position
            )
        }
    }

    private func activateInstrument(_ instrumentEntity: InstrumentEntity) {
        // Implementation for activating an instrument
        print("Activated instrument: \(instrumentEntity.instrument.name)")
    }

    private func startGestureRecognition() async {
        // Start gesture recognition system
        // This would integrate with ARKit hand tracking
    }
}

// MARK: - HUD View

struct HUDView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator

    var body: some View {
        VStack {
            HStack(spacing: 20) {
                // Transport controls
                HStack(spacing: 10) {
                    Button(action: {}) {
                        Image(systemName: "play.fill")
                    }
                    .buttonStyle(.borderless)

                    Button(action: {}) {
                        Image(systemName: "pause.fill")
                    }
                    .buttonStyle(.borderless)

                    Button(action: {}) {
                        Image(systemName: "stop.fill")
                    }
                    .buttonStyle(.borderless)

                    Button(action: {}) {
                        Image(systemName: "record.circle.fill")
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.borderless)
                }

                Spacer()

                // Composition info
                if let composition = appCoordinator.currentComposition {
                    HStack(spacing: 15) {
                        Text("♩ = \(composition.tempo) BPM")
                        Text(composition.timeSignature.description)
                        Text("Key: \(composition.key.description)")
                    }
                    .font(.caption)
                }

                Spacer()

                // Quick settings
                HStack(spacing: 10) {
                    Button(action: {}) {
                        Image(systemName: "speaker.wave.2.fill")
                    }
                    .buttonStyle(.borderless)

                    Button(action: {}) {
                        Image(systemName: "gearshape.fill")
                    }
                    .buttonStyle(.borderless)
                }
            }
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .padding()
    }
}

// MARK: - Instrument Library Button

struct InstrumentLibraryButton: View {
    @State private var showingLibrary = false

    var body: some View {
        Button(action: {
            showingLibrary.toggle()
        }) {
            Label("Instrument Library", systemImage: "music.note.list")
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .padding()
        .sheet(isPresented: $showingLibrary) {
            InstrumentLibraryView()
        }
    }
}

// MARK: - Instrument Library View

struct InstrumentLibraryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appCoordinator: AppCoordinator

    let instruments = InstrumentType.allCases

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    ForEach(instruments, id: \.self) { type in
                        InstrumentCard(type: type) {
                            // Create new track in composition
                            if appCoordinator.currentComposition != nil {
                                let track = Track(
                                    name: type.defaultName,
                                    instrument: type,
                                    position: SIMD3<Float>(0, 1, -2)
                                )
                                appCoordinator.currentComposition?.addTrack(track)
                            }
                            dismiss()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Instrument Library")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Instrument Card

struct InstrumentCard: View {
    let type: InstrumentType
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: iconForInstrument(type))
                    .font(.system(size: 40))
                    .foregroundStyle(.blue)
                    .frame(height: 60)

                Text(type.defaultName)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private func iconForInstrument(_ type: InstrumentType) -> String {
        switch type {
        case .piano: return "pianokeys"
        case .guitar, .electricGuitar: return "guitars"
        case .drums: return "circle.grid.3x3.fill"
        case .violin, .cello: return "music.note"
        case .trumpet, .saxophone, .flute: return "wind"
        case .synthesizer: return "waveform"
        case .bass, .electricBass: return "guitars.fill"
        }
    }
}

#Preview {
    MusicStudioImmersiveView()
        .environmentObject(AppCoordinator())
        .environmentObject(SpatialAudioEngine.shared)
}
