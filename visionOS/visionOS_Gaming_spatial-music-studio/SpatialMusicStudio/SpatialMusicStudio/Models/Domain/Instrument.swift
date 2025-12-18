import Foundation

// MARK: - Instrument

struct Instrument: Identifiable, Codable {
    let id: UUID
    let type: InstrumentType
    var name: String
    var position: SIMD3<Float>
    var configuration: InstrumentConfiguration

    init(id: UUID = UUID(),
         type: InstrumentType,
         name: String? = nil,
         position: SIMD3<Float> = .zero) {
        self.id = id
        self.type = type
        self.name = name ?? type.defaultName
        self.position = position
        self.configuration = InstrumentConfiguration(type: type)
    }
}

// MARK: - Instrument Type

enum InstrumentType: String, Codable, CaseIterable {
    case piano = "piano"
    case guitar = "guitar"
    case bass = "bass"
    case drums = "drums"
    case violin = "violin"
    case cello = "cello"
    case trumpet = "trumpet"
    case saxophone = "saxophone"
    case flute = "flute"
    case synthesizer = "synthesizer"
    case electricGuitar = "electric_guitar"
    case electricBass = "electric_bass"

    var defaultName: String {
        switch self {
        case .piano: return "Grand Piano"
        case .guitar: return "Acoustic Guitar"
        case .bass: return "Upright Bass"
        case .drums: return "Drum Kit"
        case .violin: return "Violin"
        case .cello: return "Cello"
        case .trumpet: return "Trumpet"
        case .saxophone: return "Saxophone"
        case .flute: return "Flute"
        case .synthesizer: return "Synthesizer"
        case .electricGuitar: return "Electric Guitar"
        case .electricBass: return "Electric Bass"
        }
    }

    var category: InstrumentCategory {
        switch self {
        case .piano, .synthesizer:
            return .keyboard
        case .guitar, .electricGuitar, .bass, .electricBass, .violin, .cello:
            return .strings
        case .drums:
            return .percussion
        case .trumpet, .saxophone, .flute:
            return .wind
        }
    }

    var modelName: String {
        "\(rawValue)_model"
    }
}

// MARK: - Instrument Category

enum InstrumentCategory: String, Codable {
    case keyboard = "keyboard"
    case strings = "strings"
    case percussion = "percussion"
    case wind = "wind"
    case electronic = "electronic"
}

// MARK: - Instrument Configuration

struct InstrumentConfiguration: Codable {
    var type: InstrumentType
    var tuning: Tuning
    var sensitivity: Float
    var responseCharacteristic: ResponseCharacteristic
    var sustainEnabled: Bool

    init(type: InstrumentType) {
        self.type = type
        self.tuning = Tuning.standard
        self.sensitivity = 1.0
        self.responseCharacteristic = .linear
        self.sustainEnabled = type.category == .keyboard
    }
}

// MARK: - Tuning

enum Tuning: String, Codable {
    case standard = "standard"
    case dropD = "drop_d"
    case openG = "open_g"
    case dadgad = "dadgad"
    case custom = "custom"

    var description: String {
        switch self {
        case .standard: return "Standard"
        case .dropD: return "Drop D"
        case .openG: return "Open G"
        case .dadgad: return "DADGAD"
        case .custom: return "Custom"
        }
    }
}

// MARK: - Response Characteristic

enum ResponseCharacteristic: String, Codable {
    case linear = "linear"
    case exponential = "exponential"
    case logarithmic = "logarithmic"

    var description: String {
        switch self {
        case .linear: return "Linear"
        case .exponential: return "Exponential"
        case .logarithmic: return "Logarithmic"
        }
    }
}

// MARK: - Gesture Types

struct KeyPress {
    let key: Int
    let velocity: Float
    let timestamp: TimeInterval

    init(key: Int, velocity: Float, timestamp: TimeInterval = Date().timeIntervalSince1970) {
        self.key = key
        self.velocity = velocity
        self.timestamp = timestamp
    }
}

struct StrumGesture {
    let strings: [Int]
    let velocity: Float
    let direction: StrumDirection
    let timestamp: TimeInterval

    enum StrumDirection {
        case up, down
    }
}

struct DrumHit {
    let drum: DrumType
    let velocity: Float
    let timestamp: TimeInterval

    enum DrumType {
        case kick, snare, hiHat, tom1, tom2, tom3, crash, ride
    }
}

struct ConductingGesture {
    let pattern: BeatPattern
    let tempo: Float
    let dynamics: Float
    let timestamp: TimeInterval

    enum BeatPattern {
        case twoFour, threeFour, fourFour, sixEight
    }
}

// MARK: - Musical Gesture

enum MusicalGesture {
    case keyPress(KeyPress)
    case strum(StrumGesture)
    case drumHit(DrumHit)
    case conducting(ConductingGesture)
}

// MARK: - Audio Effect

protocol AudioEffect: Identifiable {
    var id: UUID { get }
    var type: EffectType { get }
    var parameters: [String: Float] { get set }
    var isEnabled: Bool { get set }
}

struct ReverbEffect: AudioEffect {
    let id: UUID
    let type: EffectType = .reverb
    var parameters: [String: Float]
    var isEnabled: Bool

    init(id: UUID = UUID(), roomSize: Float = 0.5, damping: Float = 0.5, wetDryMix: Float = 0.3) {
        self.id = id
        self.parameters = [
            "roomSize": roomSize,
            "damping": damping,
            "wetDryMix": wetDryMix
        ]
        self.isEnabled = true
    }
}

struct DelayEffect: AudioEffect {
    let id: UUID
    let type: EffectType = .delay
    var parameters: [String: Float]
    var isEnabled: Bool

    init(id: UUID = UUID(), delayTime: Float = 0.5, feedback: Float = 0.3, wetDryMix: Float = 0.25) {
        self.id = id
        self.parameters = [
            "delayTime": delayTime,
            "feedback": feedback,
            "wetDryMix": wetDryMix
        ]
        self.isEnabled = true
    }
}

struct EQEffect: AudioEffect {
    let id: UUID
    let type: EffectType = .eq
    var parameters: [String: Float]
    var isEnabled: Bool

    init(id: UUID = UUID(), bands: [Float] = Array(repeating: 0, count: 10)) {
        self.id = id
        var params: [String: Float] = [:]
        for (index, gain) in bands.enumerated() {
            params["band\(index)"] = gain
        }
        self.parameters = params
        self.isEnabled = true
    }
}
