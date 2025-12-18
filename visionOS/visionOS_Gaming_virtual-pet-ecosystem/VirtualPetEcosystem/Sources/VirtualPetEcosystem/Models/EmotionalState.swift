import Foundation

/// Represents the current emotional state of a pet
public struct EmotionalState: Codable, Sendable {
    /// Primary emotion
    public var primaryEmotion: Emotion

    /// Intensity of the emotion (0.0 - 1.0)
    public var intensity: Float

    /// Timestamp when this state began
    public var since: Date

    public init(primaryEmotion: Emotion = .calm, intensity: Float = 0.5, since: Date = Date()) {
        self.primaryEmotion = primaryEmotion
        self.intensity = max(0.0, min(1.0, intensity))
        self.since = since
    }

    /// The different emotions a pet can experience
    public enum Emotion: String, Codable, CaseIterable, Sendable {
        case happy = "Happy"
        case sad = "Sad"
        case excited = "Excited"
        case calm = "Calm"
        case anxious = "Anxious"
        case playful = "Playful"
        case tired = "Tired"
        case hungry = "Hungry"
        case content = "Content"
        case lonely = "Lonely"

        /// Emoji representation
        public var emoji: String {
            switch self {
            case .happy:
                return "😊"
            case .sad:
                return "😢"
            case .excited:
                return "🤩"
            case .calm:
                return "😌"
            case .anxious:
                return "😰"
            case .playful:
                return "😜"
            case .tired:
                return "😴"
            case .hungry:
                return "🤤"
            case .content:
                return "😇"
            case .lonely:
                return "🥺"
            }
        }

        /// Color associated with this emotion
        public var colorHex: String {
            switch self {
            case .happy:
                return "#FFD700" // Gold
            case .sad:
                return "#4169E1" // Royal Blue
            case .excited:
                return "#FF69B4" // Hot Pink
            case .calm:
                return "#98FB98" // Pale Green
            case .anxious:
                return "#FF6347" // Tomato
            case .playful:
                return "#FF8C00" // Dark Orange
            case .tired:
                return "#9370DB" // Medium Purple
            case .hungry:
                return "#FFA500" // Orange
            case .content:
                return "#87CEEB" // Sky Blue
            case .lonely:
                return "#C0C0C0" // Silver
            }
        }
    }

    /// Calculate emotional state based on pet's needs and conditions
    public static func calculate(
        hunger: Float,
        happiness: Float,
        energy: Float,
        health: Float,
        lastInteractionTime: Date?
    ) -> EmotionalState {
        // Determine primary emotion based on needs
        let emotion: Emotion
        let intensity: Float

        // Hunger is critical
        if hunger < 0.3 {
            emotion = .hungry
            intensity = 1.0 - hunger
        }
        // Energy is very low
        else if energy < 0.2 {
            emotion = .tired
            intensity = 0.8
        }
        // Haven't been interacted with recently
        else if let lastInteraction = lastInteractionTime,
                Date().timeIntervalSince(lastInteraction) > 14400 { // 4 hours
            emotion = .lonely
            intensity = 0.7
        }
        // Health is low
        else if health < 0.4 {
            emotion = .sad
            intensity = 0.6
        }
        // Everything is good
        else if happiness > 0.8 && energy > 0.6 {
            emotion = .happy
            intensity = happiness
        }
        // Moderate energy and happiness
        else if energy > 0.7 {
            emotion = .playful
            intensity = 0.7
        }
        // Default to content
        else {
            emotion = .content
            intensity = (happiness + energy) / 2.0
        }

        return EmotionalState(primaryEmotion: emotion, intensity: intensity, since: Date())
    }
}
