import XCTest
@testable import SpatialMusicStudio

// MARK: - Music Theory Tests

class MusicTheoryTests: XCTestCase {

    // MARK: - Note Name Tests

    func testNoteTransposition() {
        let cNote = NoteName.c
        let transposedNote = cNote.transpose(by: 7)
        XCTAssertEqual(transposedNote, NoteName.g, "C transposed by 7 semitones should be G")
    }

    func testNoteTranspositionWrapAround() {
        let bNote = NoteName.b
        let transposedNote = bNote.transpose(by: 2)
        XCTAssertEqual(transposedNote, NoteName.cSharp, "B transposed by 2 semitones should wrap to C#")
    }

    func testNoteMidiValue() {
        XCTAssertEqual(NoteName.c.midiValue, 0)
        XCTAssertEqual(NoteName.cSharp.midiValue, 1)
        XCTAssertEqual(NoteName.b.midiValue, 11)
    }

    // MARK: - Scale Tests

    func testMajorScaleIntervals() {
        let majorIntervals = Scale.major.intervals
        XCTAssertEqual(majorIntervals, [0, 2, 4, 5, 7, 9, 11], "Major scale intervals should be correct")
    }

    func testMinorScaleIntervals() {
        let minorIntervals = Scale.naturalMinor.intervals
        XCTAssertEqual(minorIntervals, [0, 2, 3, 5, 7, 8, 10], "Natural minor scale intervals should be correct")
    }

    func testMusicalKeyNotes() {
        let cMajor = MusicalKey(tonic: .c, scale: .major)
        let notes = cMajor.notes

        XCTAssertEqual(notes.count, 7, "Major scale should have 7 notes")
        XCTAssertEqual(notes[0], .c, "First note should be C")
        XCTAssertEqual(notes[4], .g, "Fifth note should be G")
    }

    // MARK: - Chord Tests

    func testMajorChordNotes() {
        let cMajor = Chord(root: .c, quality: .major)
        let notes = cMajor.notes

        XCTAssertEqual(notes.count, 3, "Major chord should have 3 notes")
        XCTAssertEqual(notes[0], .c, "Root should be C")
        XCTAssertEqual(notes[1], .e, "Third should be E")
        XCTAssertEqual(notes[2], .g, "Fifth should be G")
    }

    func testMinorChordNotes() {
        let aMinor = Chord(root: .a, quality: .minor)
        let notes = aMinor.notes

        XCTAssertEqual(notes.count, 3, "Minor chord should have 3 notes")
        XCTAssertEqual(notes[0], .a, "Root should be A")
    }

    func testDominant7ChordNotes() {
        let g7 = Chord(root: .g, quality: .dominant7)
        let notes = g7.notes

        XCTAssertEqual(notes.count, 4, "Dominant 7 chord should have 4 notes")
    }

    func testChordSymbol() {
        let cMajor = Chord(root: .c, quality: .major)
        XCTAssertEqual(cMajor.symbol, "C", "C major symbol should be 'C'")

        let dMinor = Chord(root: .d, quality: .minor)
        XCTAssertEqual(dMinor.symbol, "Dm", "D minor symbol should be 'Dm'")

        let g7 = Chord(root: .g, quality: .dominant7)
        XCTAssertEqual(g7.symbol, "G7", "G dominant 7 symbol should be 'G7'")
    }

    // MARK: - Time Signature Tests

    func testTimeSignatureCommonTime() {
        let commonTime = TimeSignature.commonTime
        XCTAssertEqual(commonTime.numerator, 4)
        XCTAssertEqual(commonTime.denominator, 4)
        XCTAssertEqual(commonTime.beatsPerMeasure, 4)
    }

    func testTimeSignatureWaltz() {
        let waltz = TimeSignature.waltzTime
        XCTAssertEqual(waltz.numerator, 3)
        XCTAssertEqual(waltz.denominator, 4)
        XCTAssertEqual(waltz.beatsPerMeasure, 3)
    }

    // MARK: - Chord Progression Tests

    func testChordProgressionRomanNumerals() {
        let cMajorKey = MusicalKey(tonic: .c, scale: .major)
        let chords = [
            Chord(root: .c, quality: .major),
            Chord(root: .f, quality: .major),
            Chord(root: .g, quality: .major),
            Chord(root: .c, quality: .major)
        ]

        let progression = ChordProgression(chords: chords, key: cMajorKey)
        let numerals = progression.romanNumerals()

        XCTAssertEqual(numerals.count, 4, "Should have 4 roman numerals")
        XCTAssertEqual(numerals[0], "I", "First chord should be I")
        XCTAssertEqual(numerals[1], "IV", "Second chord should be IV")
        XCTAssertEqual(numerals[2], "V", "Third chord should be V")
    }

    // MARK: - Interval Tests

    func testIntervalSemitones() {
        XCTAssertEqual(Interval.unison.semitones, 0)
        XCTAssertEqual(Interval.perfectFifth.semitones, 7)
        XCTAssertEqual(Interval.octave.semitones, 12)
    }

    func testIntervalNames() {
        XCTAssertEqual(Interval.majorThird.name, "Major 3rd")
        XCTAssertEqual(Interval.perfectFourth.name, "Perfect 4th")
    }
}

// MARK: - Composition Model Tests

class CompositionTests: XCTestCase {

    var composition: Composition!

    override func setUp() {
        super.setUp()
        composition = Composition(
            title: "Test Composition",
            tempo: 120,
            timeSignature: .commonTime,
            key: MusicalKey(tonic: .c, scale: .major)
        )
    }

    override func tearDown() {
        composition = nil
        super.tearDown()
    }

    func testCompositionCreation() {
        XCTAssertEqual(composition.title, "Test Composition")
        XCTAssertEqual(composition.tempo, 120)
        XCTAssertEqual(composition.timeSignature, TimeSignature.commonTime)
        XCTAssertEqual(composition.tracks.count, 0, "New composition should have no tracks")
    }

    func testAddTrack() {
        let track = Track(
            name: "Piano Track",
            instrument: .piano,
            position: SIMD3<Float>(0, 1, -2)
        )

        composition.addTrack(track)

        XCTAssertEqual(composition.tracks.count, 1, "Should have one track")
        XCTAssertEqual(composition.tracks.first?.name, "Piano Track")
    }

    func testRemoveTrack() {
        let track = Track(name: "Piano Track", instrument: .piano)
        composition.addTrack(track)

        XCTAssertEqual(composition.tracks.count, 1)

        composition.removeTrack(track.id)

        XCTAssertEqual(composition.tracks.count, 0, "Track should be removed")
    }

    func testUpdateTrack() {
        var track = Track(name: "Original Name", instrument: .piano)
        composition.addTrack(track)

        track.name = "Updated Name"
        composition.updateTrack(track)

        XCTAssertEqual(composition.tracks.first?.name, "Updated Name")
    }

    func testCompositionModifiedDate() {
        let originalModified = composition.modified

        // Add a small delay
        Thread.sleep(forTimeInterval: 0.01)

        let track = Track(name: "Test", instrument: .piano)
        composition.addTrack(track)

        XCTAssertGreaterThan(composition.modified, originalModified, "Modified date should update")
    }
}

// MARK: - Track Tests

class TrackTests: XCTestCase {

    func testTrackCreation() {
        let track = Track(
            name: "Piano Track",
            instrument: .piano,
            position: SIMD3<Float>(1, 2, 3)
        )

        XCTAssertEqual(track.name, "Piano Track")
        XCTAssertEqual(track.instrument, .piano)
        XCTAssertEqual(track.position.x, 1)
        XCTAssertEqual(track.position.y, 2)
        XCTAssertEqual(track.position.z, 3)
        XCTAssertEqual(track.volume, 1.0, "Default volume should be 1.0")
        XCTAssertEqual(track.pan, 0.0, "Default pan should be 0.0")
        XCTAssertFalse(track.isMuted, "Track should not be muted by default")
        XCTAssertFalse(track.isSolo, "Track should not be solo by default")
    }

    func testAddNote() {
        var track = Track(name: "Test", instrument: .piano)

        let note1 = MIDINote(note: 60, velocity: 100, startTime: 0.0, duration: 1.0)
        let note2 = MIDINote(note: 64, velocity: 100, startTime: 1.0, duration: 1.0)

        track.addNote(note1)
        track.addNote(note2)

        XCTAssertEqual(track.midiNotes.count, 2)
    }

    func testNoteSorting() {
        var track = Track(name: "Test", instrument: .piano)

        let note1 = MIDINote(note: 60, velocity: 100, startTime: 2.0, duration: 1.0)
        let note2 = MIDINote(note: 64, velocity: 100, startTime: 1.0, duration: 1.0)
        let note3 = MIDINote(note: 67, velocity: 100, startTime: 0.0, duration: 1.0)

        track.addNote(note1)
        track.addNote(note2)
        track.addNote(note3)

        XCTAssertEqual(track.midiNotes[0].startTime, 0.0, "Notes should be sorted by start time")
        XCTAssertEqual(track.midiNotes[1].startTime, 1.0)
        XCTAssertEqual(track.midiNotes[2].startTime, 2.0)
    }

    func testRemoveNote() {
        var track = Track(name: "Test", instrument: .piano)
        let note = MIDINote(note: 60, velocity: 100, startTime: 0.0, duration: 1.0)

        track.addNote(note)
        XCTAssertEqual(track.midiNotes.count, 1)

        track.removeNote(note.id)
        XCTAssertEqual(track.midiNotes.count, 0)
    }
}

// MARK: - MIDI Note Tests

class MIDINoteTests: XCTestCase {

    func testMIDINoteCreation() {
        let note = MIDINote(
            note: 60,  // Middle C
            velocity: 100,
            startTime: 1.5,
            duration: 2.0,
            channel: 0
        )

        XCTAssertEqual(note.note, 60)
        XCTAssertEqual(note.velocity, 100)
        XCTAssertEqual(note.startTime, 1.5)
        XCTAssertEqual(note.duration, 2.0)
        XCTAssertEqual(note.channel, 0)
    }

    func testMIDINoteRange() {
        // Test valid MIDI note range (0-127)
        let validNote = MIDINote(note: 127, velocity: 127, startTime: 0, duration: 1)
        XCTAssertEqual(validNote.note, 127)
        XCTAssertEqual(validNote.velocity, 127)
    }
}

// MARK: - Instrument Tests

class InstrumentTests: XCTestCase {

    func testInstrumentCreation() {
        let instrument = Instrument(
            type: .piano,
            name: "Grand Piano",
            position: SIMD3<Float>(0, 1, -2)
        )

        XCTAssertEqual(instrument.type, .piano)
        XCTAssertEqual(instrument.name, "Grand Piano")
        XCTAssertEqual(instrument.position.y, 1)
    }

    func testInstrumentDefaultName() {
        let instrument = Instrument(type: .guitar)
        XCTAssertEqual(instrument.name, "Acoustic Guitar", "Should use default name")
    }

    func testInstrumentCategory() {
        XCTAssertEqual(InstrumentType.piano.category, .keyboard)
        XCTAssertEqual(InstrumentType.guitar.category, .strings)
        XCTAssertEqual(InstrumentType.drums.category, .percussion)
        XCTAssertEqual(InstrumentType.trumpet.category, .wind)
    }

    func testInstrumentConfiguration() {
        let instrument = Instrument(type: .piano)

        XCTAssertEqual(instrument.configuration.type, .piano)
        XCTAssertEqual(instrument.configuration.tuning, .standard)
        XCTAssertEqual(instrument.configuration.sensitivity, 1.0)
        XCTAssertTrue(instrument.configuration.sustainEnabled, "Piano should have sustain enabled by default")
    }
}

// MARK: - Spatial Arrangement Tests

class SpatialArrangementTests: XCTestCase {

    func testSpatialArrangementCreation() {
        let arrangement = SpatialArrangement()

        XCTAssertEqual(arrangement.instrumentPositions.count, 0)
        XCTAssertEqual(arrangement.listenerPosition, SIMD3<Float>(0, 0, 0))
    }

    func testSetInstrumentPosition() {
        var arrangement = SpatialArrangement()
        let instrumentId = UUID()
        let position = SIMD3<Float>(1, 2, 3)

        arrangement.setInstrumentPosition(instrumentId, position: position)

        XCTAssertEqual(arrangement.instrumentPositions[instrumentId], position)
    }

    func testRoomConfiguration() {
        let config = RoomConfiguration()

        XCTAssertEqual(config.dimensions, SIMD3<Float>(5, 3, 5), "Default room should be 5x3x5 meters")
        XCTAssertEqual(config.acousticTreatment, .neutral)
        XCTAssertEqual(config.environmentType, .intimateStudio)
    }
}

// MARK: - Codable Tests

class CodableTests: XCTestCase {

    func testCompositionCodable() throws {
        let original = Composition(
            title: "Test Song",
            tempo: 140,
            timeSignature: .commonTime,
            key: MusicalKey(tonic: .c, scale: .major)
        )

        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        // Decode
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Composition.self, from: data)

        XCTAssertEqual(decoded.title, original.title)
        XCTAssertEqual(decoded.tempo, original.tempo)
        XCTAssertEqual(decoded.timeSignature, original.timeSignature)
    }

    func testTrackCodable() throws {
        let original = Track(
            name: "Piano Track",
            instrument: .piano,
            position: SIMD3<Float>(1, 2, 3)
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Track.self, from: data)

        XCTAssertEqual(decoded.name, original.name)
        XCTAssertEqual(decoded.instrument, original.instrument)
        XCTAssertEqual(decoded.position, original.position)
    }

    func testMIDINoteCodable() throws {
        let original = MIDINote(note: 60, velocity: 100, startTime: 1.0, duration: 2.0)

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(MIDINote.self, from: data)

        XCTAssertEqual(decoded.note, original.note)
        XCTAssertEqual(decoded.velocity, original.velocity)
        XCTAssertEqual(decoded.startTime, original.startTime)
        XCTAssertEqual(decoded.duration, original.duration)
    }
}

// MARK: - Edge Case Tests

class EdgeCaseTests: XCTestCase {

    func testEmptyComposition() {
        let composition = Composition(
            title: "",
            tempo: 120,
            timeSignature: .commonTime,
            key: MusicalKey(tonic: .c, scale: .major)
        )

        XCTAssertEqual(composition.title, "")
        XCTAssertEqual(composition.tracks.count, 0)
        XCTAssertEqual(composition.duration, 0)
    }

    func testExtremeTempos() {
        let slowTempo = Composition(
            title: "Slow",
            tempo: 40,
            timeSignature: .commonTime,
            key: MusicalKey(tonic: .c, scale: .major)
        )
        XCTAssertEqual(slowTempo.tempo, 40)

        let fastTempo = Composition(
            title: "Fast",
            tempo: 240,
            timeSignature: .commonTime,
            key: MusicalKey(tonic: .c, scale: .major)
        )
        XCTAssertEqual(fastTempo.tempo, 240)
    }

    func testNegativePosition() {
        let instrument = Instrument(
            type: .piano,
            position: SIMD3<Float>(-5, -2, -10)
        )

        XCTAssertEqual(instrument.position.x, -5)
        XCTAssertEqual(instrument.position.y, -2)
        XCTAssertEqual(instrument.position.z, -10)
    }

    func testZeroDurationNote() {
        let note = MIDINote(note: 60, velocity: 100, startTime: 0, duration: 0)
        XCTAssertEqual(note.duration, 0, "Should support zero duration notes")
    }
}
