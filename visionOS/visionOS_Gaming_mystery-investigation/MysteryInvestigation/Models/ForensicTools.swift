import Foundation
import SwiftUI

/// Forensic tool types available to the detective
enum ForensicToolType: String, Codable, CaseIterable {
    case magnifyingGlass
    case fingerprintKit
    case uvLight
    case cameraEvidence
    case swabKit
    case measurementTape
    case bloodDetection
    case notepad
    case spectrometer
    case scanner3D

    var displayName: String {
        switch self {
        case .magnifyingGlass: return "Magnifying Glass"
        case .fingerprintKit: return "Fingerprint Dusting Kit"
        case .uvLight: return "UV Light"
        case .cameraEvidence: return "Evidence Camera"
        case .swabKit: return "DNA Swab Kit"
        case .measurementTape: return "Measuring Tape"
        case .bloodDetection: return "Luminol Spray"
        case .notepad: return "Detective's Notepad"
        case .spectrometer: return "Spectrometer"
        case .scanner3D: return "3D Scanner"
        }
    }

    var description: String {
        switch self {
        case .magnifyingGlass:
            return "Examine evidence in detail, revealing fine prints and markings"
        case .fingerprintKit:
            return "Dust surfaces to reveal fingerprints and identify suspects"
        case .uvLight:
            return "Reveal hidden stains, fluids, and invisible markings"
        case .cameraEvidence:
            return "Photograph evidence for documentation and analysis"
        case .swabKit:
            return "Collect DNA samples from evidence for matching"
        case .measurementTape:
            return "Measure distances and dimensions at the crime scene"
        case .bloodDetection:
            return "Spray to detect blood traces not visible to the naked eye"
        case .notepad:
            return "Record observations and connect evidence"
        case .spectrometer:
            return "Analyze chemical composition of substances"
        case .scanner3D:
            return "Create detailed 3D reconstructions of evidence"
        }
    }

    var usageDuration: TimeInterval {
        switch self {
        case .magnifyingGlass: return 0.0  // Instant
        case .fingerprintKit: return 3.0
        case .uvLight: return 1.0
        case .cameraEvidence: return 0.5
        case .swabKit: return 2.0
        case .measurementTape: return 1.5
        case .bloodDetection: return 2.5
        case .notepad: return 0.0
        case .spectrometer: return 4.0
        case .scanner3D: return 5.0
        }
    }

    var unlockRequirement: DetectiveRank {
        switch self {
        case .magnifyingGlass, .cameraEvidence, .notepad:
            return .rookie
        case .fingerprintKit, .uvLight:
            return .detective
        case .swabKit, .bloodDetection:
            return .seniorDetective
        case .measurementTape:
            return .detective
        case .spectrometer, .scanner3D:
            return .leadInvestigator
        }
    }

    var icon: String {
        switch self {
        case .magnifyingGlass: return "magnifyingglass"
        case .fingerprintKit: return "hand.raised.fill"
        case .uvLight: return "lightbulb.fill"
        case .cameraEvidence: return "camera.fill"
        case .swabKit: return "drop.fill"
        case .measurementTape: return "ruler.fill"
        case .bloodDetection: return "cross.vial.fill"
        case .notepad: return "note.text"
        case .spectrometer: return "waveform.path.ecg"
        case .scanner3D: return "cube.transparent"
        }
    }
}

/// Result of forensic analysis
struct ForensicResult: Codable {
    var findings: [Finding]
    var confidence: Float  // 0.0 - 1.0
    var additionalClues: [String]
    var visualData: String?  // Reference to texture/image

    enum Finding: Codable {
        case fingerprint(id: String, matchConfidence: Float, suspectID: UUID?)
        case dna(profile: String, matchSuspect: UUID?)
        case bloodSpatter(pattern: String, angle: Float)
        case fiber(type: String, color: String)
        case trace(description: String)
        case measurement(dimension: String, value: Float)
        case chemical(compound: String, concentration: Float)
        case noResult

        var description: String {
            switch self {
            case .fingerprint(let id, let conf, let suspect):
                if let _ = suspect {
                    return "Fingerprint match found (\(Int(conf * 100))% confidence)"
                } else {
                    return "Fingerprint detected (ID: \(id))"
                }
            case .dna(let profile, let suspect):
                if let _ = suspect {
                    return "DNA match identified: \(profile)"
                } else {
                    return "DNA profile collected: \(profile)"
                }
            case .bloodSpatter(let pattern, let angle):
                return "Blood spatter pattern: \(pattern), impact angle: \(Int(angle))°"
            case .fiber(let type, let color):
                return "Fiber found: \(color) \(type)"
            case .trace(let desc):
                return "Trace evidence: \(desc)"
            case .measurement(let dim, let val):
                return "\(dim): \(val) meters"
            case .chemical(let compound, let concentration):
                return "Chemical detected: \(compound) (\(Int(concentration * 100))% purity)"
            case .noResult:
                return "No significant findings"
            }
        }
    }

    static var noResult: ForensicResult {
        ForensicResult(findings: [.noResult], confidence: 0.0, additionalClues: [], visualData: nil)
    }
}

/// Tool usage animation state
enum ToolAnimationState {
    case idle
    case selecting
    case using
    case analyzing
    case complete
}

/// Tool interaction gesture
enum ToolGesture {
    case pinch          // Select tool
    case brush          // Dusting motion
    case point          // UV light direction
    case capture        // Camera snapshot
    case swab           // Collection motion
    case measure        // Distance marking
    case spray          // Luminol application
    case write          // Note-taking
}
