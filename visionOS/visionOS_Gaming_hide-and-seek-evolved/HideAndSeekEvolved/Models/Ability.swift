import Foundation

// MARK: - Ability
enum Ability: Codable, Equatable {
    case camouflage(opacity: Float)
    case sizeManipulation(scale: Float)
    case thermalVision(range: Float)
    case clueDetection(sensitivity: Float)
    case soundMasking(effectiveness: Float)

    var cooldownDuration: TimeInterval {
        switch self {
        case .camouflage:
            return 30
        case .sizeManipulation:
            return 45
        case .thermalVision:
            return 20
        case .clueDetection:
            return 15
        case .soundMasking:
            return 25
        }
    }

    var displayName: String {
        switch self {
        case .camouflage:
            return "Camouflage"
        case .sizeManipulation:
            return "Size Manipulation"
        case .thermalVision:
            return "Thermal Vision"
        case .clueDetection:
            return "Clue Detection"
        case .soundMasking:
            return "Sound Masking"
        }
    }

    var description: String {
        switch self {
        case .camouflage(let opacity):
            return "Become \(Int((1.0 - opacity) * 100))% invisible"
        case .sizeManipulation(let scale):
            return "Change size to \(Int(scale * 100))%"
        case .thermalVision(let range):
            return "Detect heat signatures within \(Int(range))m"
        case .clueDetection(let sensitivity):
            return "Enhanced clue detection (x\(String(format: "%.1f", sensitivity)))"
        case .soundMasking(let effectiveness):
            return "Reduce footstep sounds by \(Int(effectiveness * 100))%"
        }
    }

    var icon: String {
        switch self {
        case .camouflage:
            return "eye.slash"
        case .sizeManipulation:
            return "arrow.up.and.down"
        case .thermalVision:
            return "eye"
        case .clueDetection:
            return "magnifyingglass"
        case .soundMasking:
            return "speaker.slash"
        }
    }
}

// MARK: - Achievement
enum Achievement: String, Codable {
    // Stealth Master
    case ghost = "Ghost"
    case invisible = "Invisible"
    case tinyTitan = "Tiny Titan"
    case perfectHiding = "Perfect Hiding"

    // Seeking Expert
    case eagleEye = "Eagle Eye"
    case detective = "Detective"
    case speedDemon = "Speed Demon"
    case heatSeeker = "Heat Seeker"

    // Family Fun
    case familyNight = "Family Night"
    case marathon = "Marathon"
    case everyoneWins = "Everyone Wins"
    case helpful = "Helpful"

    // Creative
    case innovator = "Innovator"
    case comboMaster = "Combo Master"
    case trickster = "Trickster"
    case architect = "Architect"

    // Social
    case partyHost = "Party Host"
    case coach = "Coach"
    case goodSport = "Good Sport"
    case encouraging = "Encouraging"

    var description: String {
        switch self {
        case .ghost:
            return "Never found in 5 consecutive rounds"
        case .invisible:
            return "Win using only camouflage 10 times"
        case .tinyTitan:
            return "Win while at minimum size"
        case .perfectHiding:
            return "Achieve 100% concealment score"
        case .eagleEye:
            return "Find all hiders in under 60 seconds"
        case .detective:
            return "Win using only clues (no special vision)"
        case .speedDemon:
            return "Find hider within 10 seconds"
        case .heatSeeker:
            return "50 finds using thermal vision"
        case .familyNight:
            return "Play with 3+ generations"
        case .marathon:
            return "Play 20 rounds in one session"
        case .everyoneWins:
            return "Rotate so everyone wins at least once"
        case .helpful:
            return "Give 100 hints to other players"
        case .innovator:
            return "Use 50 unique hiding spots"
        case .comboMaster:
            return "Use 3+ abilities in one hiding session"
        case .trickster:
            return "Use decoys successfully 20 times"
        case .architect:
            return "Rearrange environment 10 times"
        case .partyHost:
            return "Play with 8 different people"
        case .coach:
            return "Help new players through tutorial"
        case .goodSport:
            return "Complete 50 rounds without complaints"
        case .encouraging:
            return "Give thumbs up to all players 25 times"
        }
    }

    var icon: String {
        switch self {
        case .ghost, .invisible, .perfectHiding:
            return "eye.slash.fill"
        case .tinyTitan:
            return "ant.fill"
        case .eagleEye, .detective, .speedDemon:
            return "eye.fill"
        case .heatSeeker:
            return "flame.fill"
        case .familyNight:
            return "figure.2.and.child.holdinghands"
        case .marathon:
            return "stopwatch.fill"
        case .everyoneWins:
            return "trophy.fill"
        case .helpful:
            return "hand.raised.fill"
        case .innovator:
            return "lightbulb.fill"
        case .comboMaster:
            return "sparkles"
        case .trickster:
            return "theatermasks.fill"
        case .architect:
            return "building.2.fill"
        case .partyHost:
            return "person.3.fill"
        case .coach:
            return "person.fill.checkmark"
        case .goodSport:
            return "hands.clap.fill"
        case .encouraging:
            return "heart.fill"
        }
    }
}
