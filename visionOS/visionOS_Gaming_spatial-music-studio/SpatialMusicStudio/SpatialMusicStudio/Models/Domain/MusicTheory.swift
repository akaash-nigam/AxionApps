import Foundation

// MARK: - Musical Key

struct MusicalKey: Codable, Equatable {
    let tonic: NoteName
    let scale: Scale

    init(tonic: NoteName, scale: Scale) {
        self.tonic = tonic
        self.scale = scale
    }

    var description: String {
        "\(tonic.rawValue) \(scale.rawValue)"
    }

    var notes: [NoteName] {
        scale.intervals.map { interval in
            tonic.transpose(by: interval)
        }
    }
}

// MARK: - Note Name

enum NoteName: String, Codable, CaseIterable {
    case c = "C"
    case cSharp = "C#"
    case d = "D"
    case dSharp = "D#"
    case e = "E"
    case f = "F"
    case fSharp = "F#"
    case g = "G"
    case gSharp = "G#"
    case a = "A"
    case aSharp = "A#"
    case b = "B"

    var midiValue: Int {
        switch self {
        case .c: return 0
        case .cSharp: return 1
        case .d: return 2
        case .dSharp: return 3
        case .e: return 4
        case .f: return 5
        case .fSharp: return 6
        case .g: return 7
        case .gSharp: return 8
        case .a: return 9
        case .aSharp: return 10
        case .b: return 11
        }
    }

    func transpose(by semitones: Int) -> NoteName {
        let allNotes = NoteName.allCases
        let currentIndex = allNotes.firstIndex(of: self)!
        let newIndex = (currentIndex + semitones) % allNotes.count
        return allNotes[newIndex >= 0 ? newIndex : newIndex + allNotes.count]
    }
}

// MARK: - Scale

enum Scale: String, Codable {
    case major = "major"
    case naturalMinor = "natural minor"
    case harmonicMinor = "harmonic minor"
    case melodicMinor = "melodic minor"
    case dorian = "dorian"
    case phrygian = "phrygian"
    case lydian = "lydian"
    case mixolydian = "mixolydian"
    case aeolian = "aeolian"
    case locrian = "locrian"

    var intervals: [Int] {
        switch self {
        case .major:
            return [0, 2, 4, 5, 7, 9, 11]
        case .naturalMinor:
            return [0, 2, 3, 5, 7, 8, 10]
        case .harmonicMinor:
            return [0, 2, 3, 5, 7, 8, 11]
        case .melodicMinor:
            return [0, 2, 3, 5, 7, 9, 11]
        case .dorian:
            return [0, 2, 3, 5, 7, 9, 10]
        case .phrygian:
            return [0, 1, 3, 5, 7, 8, 10]
        case .lydian:
            return [0, 2, 4, 6, 7, 9, 11]
        case .mixolydian:
            return [0, 2, 4, 5, 7, 9, 10]
        case .aeolian:
            return [0, 2, 3, 5, 7, 8, 10]
        case .locrian:
            return [0, 1, 3, 5, 6, 8, 10]
        }
    }
}

// MARK: - Time Signature

struct TimeSignature: Codable, Equatable {
    let numerator: Int
    let denominator: Int

    static let commonTime = TimeSignature(numerator: 4, denominator: 4)
    static let cutTime = TimeSignature(numerator: 2, denominator: 2)
    static let waltzTime = TimeSignature(numerator: 3, denominator: 4)
    static let sixEight = TimeSignature(numerator: 6, denominator: 8)

    var description: String {
        "\(numerator)/\(denominator)"
    }

    var beatsPerMeasure: Int {
        numerator
    }

    var beatValue: Int {
        denominator
    }
}

// MARK: - Chord

struct Chord: Codable, Equatable {
    let root: NoteName
    let quality: ChordQuality
    let extensions: [ChordExtension]

    init(root: NoteName, quality: ChordQuality, extensions: [ChordExtension] = []) {
        self.root = root
        self.quality = quality
        self.extensions = extensions
    }

    var notes: [NoteName] {
        var chordNotes = [root]

        // Add quality intervals
        for interval in quality.intervals {
            chordNotes.append(root.transpose(by: interval))
        }

        // Add extensions
        for ext in extensions {
            chordNotes.append(root.transpose(by: ext.interval))
        }

        return chordNotes
    }

    var symbol: String {
        var symbol = root.rawValue
        symbol += quality.symbol

        for ext in extensions {
            symbol += ext.symbol
        }

        return symbol
    }
}

// MARK: - Chord Quality

enum ChordQuality: String, Codable {
    case major = "major"
    case minor = "minor"
    case diminished = "diminished"
    case augmented = "augmented"
    case dominant7 = "dominant7"
    case major7 = "major7"
    case minor7 = "minor7"
    case diminished7 = "diminished7"
    case halfDiminished7 = "halfDiminished7"

    var intervals: [Int] {
        switch self {
        case .major:
            return [4, 7]  // Major third, perfect fifth
        case .minor:
            return [3, 7]  // Minor third, perfect fifth
        case .diminished:
            return [3, 6]  // Minor third, diminished fifth
        case .augmented:
            return [4, 8]  // Major third, augmented fifth
        case .dominant7:
            return [4, 7, 10]  // Major triad + minor seventh
        case .major7:
            return [4, 7, 11]  // Major triad + major seventh
        case .minor7:
            return [3, 7, 10]  // Minor triad + minor seventh
        case .diminished7:
            return [3, 6, 9]   // Diminished triad + diminished seventh
        case .halfDiminished7:
            return [3, 6, 10]  // Diminished triad + minor seventh
        }
    }

    var symbol: String {
        switch self {
        case .major: return ""
        case .minor: return "m"
        case .diminished: return "°"
        case .augmented: return "+"
        case .dominant7: return "7"
        case .major7: return "maj7"
        case .minor7: return "m7"
        case .diminished7: return "°7"
        case .halfDiminished7: return "ø7"
        }
    }
}

// MARK: - Chord Extension

enum ChordExtension: Codable, Equatable {
    case add9
    case add11
    case add13
    case suspended2
    case suspended4

    var interval: Int {
        switch self {
        case .add9: return 14  // 9th (octave + 2)
        case .add11: return 17  // 11th (octave + 5)
        case .add13: return 21  // 13th (octave + 9)
        case .suspended2: return 2   // Major 2nd
        case .suspended4: return 5   // Perfect 4th
        }
    }

    var symbol: String {
        switch self {
        case .add9: return "add9"
        case .add11: return "add11"
        case .add13: return "add13"
        case .suspended2: return "sus2"
        case .suspended4: return "sus4"
        }
    }
}

// MARK: - Chord Progression

struct ChordProgression: Codable {
    var chords: [Chord]
    var key: MusicalKey

    init(chords: [Chord], key: MusicalKey) {
        self.chords = chords
        self.key = key
    }

    func romanNumerals() -> [String] {
        chords.map { chord in
            let degree = key.notes.firstIndex(of: chord.root) ?? 0
            return romanNumeral(for: degree, quality: chord.quality)
        }
    }

    private func romanNumeral(for degree: Int, quality: ChordQuality) -> String {
        let numerals = ["I", "II", "III", "IV", "V", "VI", "VII"]
        guard degree < numerals.count else { return "?" }

        var numeral = numerals[degree]
        if quality == .minor || quality == .minor7 {
            numeral = numeral.lowercased()
        }

        return numeral
    }
}

// MARK: - Interval

enum Interval: Int, Codable {
    case unison = 0
    case minorSecond = 1
    case majorSecond = 2
    case minorThird = 3
    case majorThird = 4
    case perfectFourth = 5
    case tritone = 6
    case perfectFifth = 7
    case minorSixth = 8
    case majorSixth = 9
    case minorSeventh = 10
    case majorSeventh = 11
    case octave = 12

    var name: String {
        switch self {
        case .unison: return "Unison"
        case .minorSecond: return "Minor 2nd"
        case .majorSecond: return "Major 2nd"
        case .minorThird: return "Minor 3rd"
        case .majorThird: return "Major 3rd"
        case .perfectFourth: return "Perfect 4th"
        case .tritone: return "Tritone"
        case .perfectFifth: return "Perfect 5th"
        case .minorSixth: return "Minor 6th"
        case .majorSixth: return "Major 6th"
        case .minorSeventh: return "Minor 7th"
        case .majorSeventh: return "Major 7th"
        case .octave: return "Octave"
        }
    }

    var semitones: Int {
        rawValue
    }
}
