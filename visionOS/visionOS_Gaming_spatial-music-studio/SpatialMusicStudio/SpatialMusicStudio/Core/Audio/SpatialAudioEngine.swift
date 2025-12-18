import AVFoundation
import Spatial
import Observation

@Observable
@MainActor
class SpatialAudioEngine: ObservableObject {
    static let shared = SpatialAudioEngine()

    // MARK: - Properties
    var isInitialized: Bool = false
    var isRunning: Bool = false
    var masterVolume: Float = 0.75

    // AVAudioEngine for low-level audio
    private let audioEngine = AVAudioEngine()

    // Spatial audio session
    private let audioSession = AVAudioSession.sharedInstance()

    // Audio sources (instruments)
    private var audioSources: [UUID: AudioSource] = [:]

    // Spatial mixer
    private let spatialMixer = AVAudioEnvironmentNode()

    // Effects processors
    private var effectsChain: [UUID: [AudioEffect]] = [:]

    // Recording
    private var recordingBuffer: AVAudioPCMBuffer?
    private var recordingFile: AVAudioFile?
    private var isRecording: Bool = false

    // Configuration
    private let sampleRate: Double = AudioConfiguration.sampleRate
    private let bitDepth: Int = AudioConfiguration.bitDepth
    private let maxLatency: TimeInterval = AudioConfiguration.targetLatency

    // MARK: - Initialization
    private init() {}

    // MARK: - Public Methods

    func initialize() async throws {
        guard !isInitialized else { return }

        // Configure audio session for spatial audio
        try audioSession.setCategory(.playAndRecord,
                                     mode: .default,
                                     options: [.mixWithOthers,
                                              .allowBluetooth])

        // Setup spatial audio processing
        audioEngine.attach(spatialMixer)

        // Configure environment node for room acoustics
        spatialMixer.listenerPosition = AVAudio3DPoint(x: 0, y: 0, z: 0)
        spatialMixer.listenerAngularOrientation = AVAudio3DAngularOrientation(
            yaw: 0, pitch: 0, roll: 0
        )

        // Connect spatial mixer to main output
        audioEngine.connect(
            spatialMixer,
            to: audioEngine.mainMixerNode,
            format: audioEngine.outputNode.outputFormat(forBus: 0)
        )

        // Configure low-latency mode
        try audioSession.setPreferredIOBufferDuration(maxLatency)

        // Start engine
        try audioEngine.start()

        isInitialized = true
        isRunning = true
    }

    func stop() async {
        audioEngine.stop()
        isRunning = false
    }

    // MARK: - Instrument Management

    func addInstrument(_ instrument: Instrument, at position: SIMD3<Float>) -> UUID {
        let source = AudioSource(instrument: instrument)
        source.position = position

        let id = instrument.id
        audioSources[id] = source

        // Attach to audio engine
        audioEngine.attach(source.playerNode)

        // Configure format
        let format = AVAudioFormat(
            standardFormatWithSampleRate: sampleRate,
            channels: 2
        )!

        // Connect to spatial mixer
        audioEngine.connect(
            source.playerNode,
            to: spatialMixer,
            format: format
        )

        // Update spatial position
        source.playerNode.position = AVAudio3DPoint(
            x: position.x,
            y: position.y,
            z: position.z
        )

        // Load instrument samples
        Task {
            await loadInstrumentSamples(for: id, instrument: instrument)
        }

        return id
    }

    func removeInstrument(_ id: UUID) {
        guard let source = audioSources[id] else { return }

        source.playerNode.stop()
        audioEngine.detach(source.playerNode)
        audioSources.removeValue(forKey: id)
    }

    func updateInstrumentPosition(_ id: UUID, position: SIMD3<Float>) {
        guard let source = audioSources[id] else { return }

        source.position = position
        source.playerNode.position = AVAudio3DPoint(
            x: position.x,
            y: position.y,
            z: position.z
        )
    }

    // MARK: - Playback

    func playNote(_ keyPress: KeyPress) {
        // Find appropriate instrument
        guard let activeInstrument = audioSources.values.first else { return }

        // Schedule note
        activeInstrument.scheduleNote(
            note: UInt8(keyPress.key),
            velocity: UInt8(keyPress.velocity * 127),
            at: keyPress.timestamp
        )
    }

    func playStrum(_ strum: StrumGesture) {
        // Implementation for guitar strumming
    }

    func playDrumHit(_ hit: DrumHit) {
        // Implementation for drum hits
    }

    // MARK: - Recording

    func startRecording() throws {
        guard !isRecording else { return }

        let documentsPath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]

        let fileURL = documentsPath.appendingPathComponent("recording_\(Date().timeIntervalSince1970).caf")

        let format = AVAudioFormat(
            standardFormatWithSampleRate: sampleRate,
            channels: 2
        )!

        recordingFile = try AVAudioFile(
            forWriting: fileURL,
            settings: format.settings
        )

        // Install tap on main mixer
        audioEngine.mainMixerNode.installTap(
            onBus: 0,
            bufferSize: 4096,
            format: format
        ) { [weak self] buffer, time in
            try? self?.recordingFile?.write(from: buffer)
        }

        isRecording = true
    }

    func stopRecording() -> URL? {
        guard isRecording else { return nil }

        audioEngine.mainMixerNode.removeTap(onBus: 0)
        isRecording = false

        return recordingFile?.url
    }

    // MARK: - Effects

    func addEffect(_ effect: AudioEffect, to instrumentId: UUID) {
        if effectsChain[instrumentId] == nil {
            effectsChain[instrumentId] = []
        }
        effectsChain[instrumentId]?.append(effect)

        // Reconnect audio graph with effect
        reconnectAudioGraph(for: instrumentId)
    }

    func removeEffect(_ effect: AudioEffect, from instrumentId: UUID) {
        effectsChain[instrumentId]?.removeAll { $0.id == effect.id }
        reconnectAudioGraph(for: instrumentId)
    }

    // MARK: - Room Acoustics

    func updateRoomAcoustics(dimensions: SIMD3<Float>, materials: [WallMaterial]) {
        // Calculate reverb parameters based on room
        let volume = dimensions.x * dimensions.y * dimensions.z
        let avgAbsorption = materials.map { $0.absorptionCoefficient }.reduce(0, +)
                          / Float(materials.count)

        // Update spatial mixer reverb
        spatialMixer.reverbParameters.enable = true
        spatialMixer.reverbParameters.level = calculateReverbLevel(
            volume: volume,
            absorption: avgAbsorption
        )

        let reverbTime = calculateReverbTime(volume: volume, absorption: avgAbsorption)
        spatialMixer.reverbParameters.filterParameters.bandwidth = reverbTime
    }

    // MARK: - Private Methods

    private func loadInstrumentSamples(for id: UUID, instrument: Instrument) async {
        guard let source = audioSources[id] else { return }

        // Load instrument sample library
        // This would load actual audio samples for the instrument
        // For now, we'll use a placeholder implementation

        source.synthesizer = try? AVAudioUnitSampler()

        if let synthesizer = source.synthesizer {
            audioEngine.attach(synthesizer)

            // Try to load soundfont
            if let soundfontURL = Bundle.main.url(
                forResource: instrument.type.soundfontName,
                withExtension: "sf2"
            ) {
                try? await synthesizer.loadSoundBankInstrument(
                    at: soundfontURL,
                    program: instrument.type.midiProgram,
                    bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                    bankLSB: UInt8(kAUSampler_DefaultBankLSB)
                )
            }
        }
    }

    private func reconnectAudioGraph(for instrumentId: UUID) {
        guard let source = audioSources[instrumentId] else { return }

        // Disconnect existing connections
        audioEngine.disconnectNodeOutput(source.playerNode)

        // Apply effects chain
        var currentNode: AVAudioNode = source.playerNode

        if let effects = effectsChain[instrumentId] {
            for effect in effects {
                // Connect effect in chain
                // This would require actual effect AU nodes
            }
        }

        // Connect final node to spatial mixer
        let format = AVAudioFormat(
            standardFormatWithSampleRate: sampleRate,
            channels: 2
        )!

        audioEngine.connect(currentNode, to: spatialMixer, format: format)
    }

    private func calculateReverbLevel(volume: Float, absorption: Float) -> Float {
        // Simple reverb calculation based on room characteristics
        let baseLevel: Float = 0.3
        let volumeFactor = log10(volume) / 10.0
        let absorptionFactor = 1.0 - absorption

        return baseLevel * volumeFactor * absorptionFactor
    }

    private func calculateReverbTime(volume: Float, absorption: Float) -> Float {
        // Sabine's formula approximation
        let rt60 = (0.161 * volume) / (absorption * volume)
        return min(max(rt60, 0.1), 4.0)  // Clamp between 0.1 and 4 seconds
    }
}

// MARK: - Supporting Types

class AudioSource {
    let instrument: Instrument
    let playerNode: AVAudioPlayerNode
    var position: SIMD3<Float>
    var velocity: SIMD3<Float> = .zero

    var synthesizer: AVAudioUnitSampler?
    var sampleBuffer: AVAudioPCMBuffer?

    init(instrument: Instrument) {
        self.instrument = instrument
        self.playerNode = AVAudioPlayerNode()
        self.position = .zero
    }

    func scheduleNote(note: UInt8, velocity: UInt8, at timestamp: TimeInterval) {
        synthesizer?.startNote(note, withVelocity: velocity, onChannel: 0)

        // Schedule note off after duration (if applicable)
        // This would be based on the instrument's characteristics
    }

    func stopNote(note: UInt8) {
        synthesizer?.stopNote(note, onChannel: 0)
    }
}

struct WallMaterial {
    let type: MaterialType
    let absorptionCoefficient: Float

    enum MaterialType {
        case drywall, wood, glass, concrete, carpet

        var defaultAbsorption: Float {
            switch self {
            case .drywall: return 0.05
            case .wood: return 0.10
            case .glass: return 0.03
            case .concrete: return 0.02
            case .carpet: return 0.30
            }
        }
    }
}

// MARK: - Extensions

extension InstrumentType {
    var soundfontName: String {
        switch self {
        case .piano: return "piano"
        case .guitar: return "guitar"
        case .bass: return "bass"
        case .drums: return "drums"
        case .violin: return "violin"
        case .cello: return "cello"
        case .trumpet: return "trumpet"
        case .saxophone: return "saxophone"
        case .flute: return "flute"
        case .synthesizer: return "synth"
        case .electricGuitar: return "electric_guitar"
        case .electricBass: return "electric_bass"
        }
    }

    var midiProgram: UInt8 {
        switch self {
        case .piano: return 0
        case .guitar: return 24
        case .bass: return 32
        case .drums: return 0  // Drums use channel 10
        case .violin: return 40
        case .cello: return 42
        case .trumpet: return 56
        case .saxophone: return 64
        case .flute: return 73
        case .synthesizer: return 80
        case .electricGuitar: return 27  // Clean electric guitar
        case .electricBass: return 33  // Fingered electric bass
        }
    }
}
