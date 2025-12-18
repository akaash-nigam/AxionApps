//
//  Song.swift
//  RhythmFlow
//
//  Data model for songs
//

import Foundation

struct Song: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let artist: String
    let album: String?
    let duration: TimeInterval
    let bpm: Double
    let key: MusicalKey
    let genre: Genre

    // Audio
    let audioFileName: String
    let previewFileName: String?
    var audioURL: URL {
        Bundle.main.url(forResource: audioFileName, withExtension: "m4a") ??
        Bundle.main.url(forResource: audioFileName, withExtension: "mp3")!
    }

    // Beat Maps
    let beatMapFileNames: [Difficulty: String]

    // Metadata
    let releaseDate: Date
    let artworkName: String
    let explicit: Bool

    // Statistics (mutable)
    var playCount: Int = 0
    var averageScore: Double = 0
    var completionRate: Double = 0
    var personalBestScore: Int = 0

    init(
        id: UUID = UUID(),
        title: String,
        artist: String,
        album: String? = nil,
        duration: TimeInterval,
        bpm: Double,
        key: MusicalKey = .cMajor,
        genre: Genre,
        audioFileName: String,
        previewFileName: String? = nil,
        beatMapFileNames: [Difficulty: String],
        releaseDate: Date = Date(),
        artworkName: String,
        explicit: Bool = false
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.duration = duration
        self.bpm = bpm
        self.key = key
        self.genre = genre
        self.audioFileName = audioFileName
        self.previewFileName = previewFileName
        self.beatMapFileNames = beatMapFileNames
        self.releaseDate = releaseDate
        self.artworkName = artworkName
        self.explicit = explicit
    }
}

// MARK: - Supporting Types

enum Difficulty: String, Codable, CaseIterable {
    case easy = "Easy"
    case normal = "Normal"
    case hard = "Hard"
    case expert = "Expert"
    case expertPlus = "Expert+"

    var multiplier: Float {
        switch self {
        case .easy: return 0.7
        case .normal: return 1.0
        case .hard: return 1.3
        case .expert: return 1.6
        case .expertPlus: return 2.0
        }
    }

    var color: String {
        switch self {
        case .easy: return "green"
        case .normal: return "blue"
        case .hard: return "orange"
        case .expert: return "red"
        case .expertPlus: return "purple"
        }
    }
}

enum MusicalKey: String, Codable {
    case cMajor = "C Major"
    case dMajor = "D Major"
    case eMajor = "E Major"
    case fMajor = "F Major"
    case gMajor = "G Major"
    case aMajor = "A Major"
    case bMajor = "B Major"
    case aMinor = "A Minor"
    case bMinor = "B Minor"
    case cMinor = "C Minor"
    case dMinor = "D Minor"
    case eMinor = "E Minor"
    case fMinor = "F Minor"
    case gMinor = "G Minor"
}

enum Genre: String, Codable, CaseIterable {
    case pop = "Pop"
    case rock = "Rock"
    case edm = "EDM"
    case hiphop = "Hip-Hop"
    case classical = "Classical"
    case jazz = "Jazz"
    case metal = "Metal"
    case indie = "Indie"
    case electronic = "Electronic"
    case kpop = "K-Pop"
}

// MARK: - Sample Data

extension Song {
    static let sampleSong = Song(
        title: "Electric Dreams",
        artist: "Neon Pulse",
        duration: 180.0,
        bpm: 128.0,
        genre: .edm,
        audioFileName: "electric_dreams",
        beatMapFileNames: [
            .easy: "electric_dreams_easy",
            .normal: "electric_dreams_normal",
            .hard: "electric_dreams_hard"
        ],
        artworkName: "electric_dreams_art"
    )

    static let sampleLibrary: [Song] = [
        sampleSong,
        Song(
            title: "Rhythm of the Night",
            artist: "Beat Masters",
            duration: 195.0,
            bpm: 132.0,
            genre: .pop,
            audioFileName: "rhythm_night",
            beatMapFileNames: [
                .easy: "rhythm_night_easy",
                .normal: "rhythm_night_normal"
            ],
            artworkName: "rhythm_night_art"
        )
    ]
}
