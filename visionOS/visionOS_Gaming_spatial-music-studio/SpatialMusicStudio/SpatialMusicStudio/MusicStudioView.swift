import SwiftUI
import RealityKit

struct MusicStudioView: View {
    @State private var isRecording = false
    @State private var recordingTime: TimeInterval = 0
    @State private var tracks: [SimpleTrack] = []
    @State private var bpm: Int = 120

    var body: some View {
        RealityView { content in
            // Create studio environment
            let studio = createStudio()
            content.add(studio)

            // Add instruments in 3D space
            let piano = createInstrument(type: SimpleInstrumentType.piano)
            piano.position = [-2, 1, -2]
            content.add(piano)

            let drums = createInstrument(type: SimpleInstrumentType.drums)
            drums.position = [2, 1, -2]
            content.add(drums)

            let guitar = createInstrument(type: SimpleInstrumentType.guitar)
            guitar.position = [0, 1.5, -1.5]
            content.add(guitar)

            // Add mixer console
            let mixer = createMixer()
            mixer.position = [0, 1, -3]
            content.add(mixer)

            // Add speakers
            let leftSpeaker = createSpeaker()
            leftSpeaker.position = [-3, 2, -3]
            content.add(leftSpeaker)

            let rightSpeaker = createSpeaker()
            rightSpeaker.position = [3, 2, -3]
            content.add(rightSpeaker)
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    playInstrument(value.entity)
                }
        )
        .overlay(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 15) {
                Text("Recording Studio")
                    .font(.title)
                    .fontWeight(.bold)

                HStack(spacing: 20) {
                    // Recording indicator
                    HStack {
                        Circle()
                            .fill(isRecording ? Color.red : Color.gray)
                            .frame(width: 15, height: 15)
                        Text(isRecording ? "REC" : "READY")
                            .font(.headline)
                            .foregroundStyle(isRecording ? .red : .secondary)
                    }

                    // Time display
                    Text(formatTime(recordingTime))
                        .font(.title3)
                        .fontDesign(.monospaced)
                }

                Divider()

                // Track list
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tracks (\(tracks.count))")
                        .font(.headline)

                    ForEach(tracks) { track in
                        TrackRow(track: track)
                    }
                }

                Divider()

                // Studio controls
                HStack(spacing: 15) {
                    StudioButton(icon: "circle.fill", label: "Record", color: .red, isActive: isRecording)
                    StudioButton(icon: "play.fill", label: "Play", color: .green, isActive: false)
                    StudioButton(icon: "stop.fill", label: "Stop", color: .orange, isActive: false)
                    StudioButton(icon: "music.note", label: "BPM: \(bpm)", color: .blue, isActive: false)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(15)
            .padding()
        }
    }

    private func createStudio() -> Entity {
        let studio = Entity()

        // Floor
        let floor = ModelEntity(
            mesh: .generatePlane(width: 8, depth: 6),
            materials: [SimpleMaterial(color: .init(white: 0.2, alpha: 1), isMetallic: false)]
        )
        floor.position.y = -0.5
        studio.addChild(floor)

        return studio
    }

    private func createInstrument(type: SimpleInstrumentType) -> ModelEntity {
        let color: UIColor = {
            switch type {
            case .piano: return .systemPink
            case .drums: return .systemPurple
            case .guitar: return .systemOrange
            }
        }()

        let instrument = ModelEntity(
            mesh: .generateBox(width: 0.4, height: 0.3, depth: 0.2),
            materials: [SimpleMaterial(color: color, isMetallic: true)]
        )

        instrument.components.set(CollisionComponent(shapes: [.generateBox(width: 0.4, height: 0.3, depth: 0.2)]))
        instrument.components.set(InputTargetComponent())
        instrument.name = type.rawValue

        return instrument
    }

    private func createMixer() -> ModelEntity {
        let mixer = ModelEntity(
            mesh: .generateBox(width: 1.2, height: 0.1, depth: 0.6),
            materials: [SimpleMaterial(color: .darkGray, isMetallic: true)]
        )

        return mixer
    }

    private func createSpeaker() -> ModelEntity {
        let speaker = ModelEntity(
            mesh: .generateCylinder(height: 0.8, radius: 0.2),
            materials: [SimpleMaterial(color: .black, isMetallic: true)]
        )

        return speaker
    }

    private func playInstrument(_ entity: Entity) {
        let instrumentName = entity.name
        if !instrumentName.isEmpty {
            // Add new track
            let newTrack = SimpleTrack(name: instrumentName, duration: Double.random(in: 2...5))
            tracks.append(newTrack)

            // Visual feedback
            entity.scale *= 1.2
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                entity.scale /= 1.2
            }
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
}

private struct TrackRow: View {
    let track: SimpleTrack

    var body: some View {
        HStack {
            Image(systemName: "waveform")
                .foregroundStyle(.purple)
            Text(track.name)
                .font(.caption)
            Spacer()
            Text(String(format: "%.1fs", track.duration))
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct StudioButton: View {
    let icon: String
    let label: String
    let color: Color
    let isActive: Bool

    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.title3)
            Text(label)
                .font(.caption2)
        }
        .frame(width: 70, height: 60)
        .foregroundStyle(isActive ? .white : color)
        .background(isActive ? color : color.opacity(0.2))
        .cornerRadius(10)
    }
}

// Use InstrumentType and Track from Domain models
private enum SimpleInstrumentType: String {
    case piano, drums, guitar

    var toInstrumentType: String {
        rawValue
    }
}

private struct SimpleTrack: Identifiable {
    let id = UUID()
    let name: String
    let duration: TimeInterval
}

#Preview {
    MusicStudioView()
}
