import Foundation

// MARK: - Composition

struct Composition: Codable, Identifiable {
    let id: UUID
    var title: String
    var tempo: Int
    var timeSignature: TimeSignature
    var key: MusicalKey

    var tracks: [Track]
    var arrangement: SpatialArrangement

    var created: Date
    var modified: Date
    var duration: TimeInterval

    init(id: UUID = UUID(),
         title: String,
         tempo: Int,
         timeSignature: TimeSignature,
         key: MusicalKey) {
        self.id = id
        self.title = title
        self.tempo = tempo
        self.timeSignature = timeSignature
        self.key = key
        self.tracks = []
        self.arrangement = SpatialArrangement()
        self.created = Date()
        self.modified = Date()
        self.duration = 0
    }

    mutating func addTrack(_ track: Track) {
        tracks.append(track)
        modified = Date()
    }

    mutating func removeTrack(_ trackId: UUID) {
        tracks.removeAll { $0.id == trackId }
        modified = Date()
    }

    mutating func updateTrack(_ track: Track) {
        if let index = tracks.firstIndex(where: { $0.id == track.id }) {
            tracks[index] = track
            modified = Date()
        }
    }
}

// MARK: - Track

struct Track: Codable, Identifiable {
    let id: UUID
    var name: String
    var instrument: InstrumentType
    var midiNotes: [MIDINote]
    var audioRecording: URL?

    // Spatial properties
    var position: SIMD3<Float>
    var effects: [EffectConfiguration]
    var volume: Float
    var pan: Float
    var isMuted: Bool
    var isSolo: Bool

    init(id: UUID = UUID(),
         name: String,
         instrument: InstrumentType,
         position: SIMD3<Float> = .zero) {
        self.id = id
        self.name = name
        self.instrument = instrument
        self.midiNotes = []
        self.position = position
        self.effects = []
        self.volume = 1.0
        self.pan = 0.0
        self.isMuted = false
        self.isSolo = false
    }

    mutating func addNote(_ note: MIDINote) {
        midiNotes.append(note)
        midiNotes.sort { $0.startTime < $1.startTime }
    }

    mutating func removeNote(_ noteId: UUID) {
        midiNotes.removeAll { $0.id == noteId }
    }
}

// MARK: - MIDI Note

struct MIDINote: Codable, Identifiable {
    let id: UUID
    let note: UInt8
    let velocity: UInt8
    let startTime: TimeInterval
    let duration: TimeInterval
    let channel: UInt8

    init(id: UUID = UUID(),
         note: UInt8,
         velocity: UInt8,
         startTime: TimeInterval,
         duration: TimeInterval,
         channel: UInt8 = 0) {
        self.id = id
        self.note = note
        self.velocity = velocity
        self.startTime = startTime
        self.duration = duration
        self.channel = channel
    }
}

// MARK: - Spatial Arrangement

struct SpatialArrangement: Codable {
    var instrumentPositions: [UUID: SIMD3<Float>]
    var listenerPosition: SIMD3<Float>
    var roomConfiguration: RoomConfiguration

    init() {
        self.instrumentPositions = [:]
        self.listenerPosition = .zero
        self.roomConfiguration = RoomConfiguration()
    }

    mutating func setInstrumentPosition(_ instrumentId: UUID, position: SIMD3<Float>) {
        instrumentPositions[instrumentId] = position
    }
}

// MARK: - Room Configuration

struct RoomConfiguration: Codable {
    var dimensions: SIMD3<Float>
    var acousticTreatment: AcousticTreatment
    var environmentType: EnvironmentType

    init() {
        self.dimensions = [5, 3, 5]  // Default 5m x 3m x 5m room
        self.acousticTreatment = .neutral
        self.environmentType = .intimateStudio
    }
}

enum AcousticTreatment: String, Codable {
    case dead = "dead"  // Heavily dampened
    case neutral = "neutral"  // Balanced
    case live = "live"  // Highly reverberant
}

enum EnvironmentType: String, Codable {
    case intimateStudio = "intimate_studio"
    case professionalStudio = "professional_studio"
    case concertHall = "concert_hall"
    case outdoor = "outdoor"
    case abstract = "abstract"
}

// MARK: - Effect Configuration

struct EffectConfiguration: Codable, Identifiable {
    let id: UUID
    var type: EffectType
    var parameters: [String: Float]
    var isEnabled: Bool

    init(id: UUID = UUID(),
         type: EffectType,
         parameters: [String: Float] = [:],
         isEnabled: Bool = true) {
        self.id = id
        self.type = type
        self.parameters = parameters
        self.isEnabled = isEnabled
    }
}

enum EffectType: String, Codable {
    case reverb = "reverb"
    case delay = "delay"
    case eq = "eq"
    case compression = "compression"
    case distortion = "distortion"
    case chorus = "chorus"
    case flanger = "flanger"
    case phaser = "phaser"
}

// MARK: - SIMD3 Codable Extension

extension SIMD3: Codable where Scalar: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let x = try container.decode(Scalar.self)
        let y = try container.decode(Scalar.self)
        let z = try container.decode(Scalar.self)
        self.init(x, y, z)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(x)
        try container.encode(y)
        try container.encode(z)
    }
}
