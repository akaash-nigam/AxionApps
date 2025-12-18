import Foundation

/// Genetics system for inheritance of traits from parents to children
struct Genetics: Codable, Equatable {
    // Genetic encoding of Big Five traits
    var opennessGene: Float
    var conscientiousnessGene: Float
    var extraversionGene: Float
    var agreeablenessGene: Float
    var neuroticismGene: Float

    // Physical trait genes
    var hairColorGene: String
    var eyeColorGene: String
    var skinToneGene: String

    init(
        opennessGene: Float,
        conscientiousnessGene: Float,
        extraversionGene: Float,
        agreeablenessGene: Float,
        neuroticismGene: Float,
        hairColorGene: String = "brown",
        eyeColorGene: String = "brown",
        skinToneGene: String = "medium"
    ) {
        self.opennessGene = opennessGene
        self.conscientiousnessGene = conscientiousnessGene
        self.extraversionGene = extraversionGene
        self.agreeablenessGene = agreeablenessGene
        self.neuroticismGene = neuroticismGene
        self.hairColorGene = hairColorGene
        self.eyeColorGene = eyeColorGene
        self.skinToneGene = skinToneGene
    }

    /// Create genetics from personality
    static func fromPersonality(_ personality: Personality) -> Genetics {
        return Genetics(
            opennessGene: personality.openness,
            conscientiousnessGene: personality.conscientiousness,
            extraversionGene: personality.extraversion,
            agreeablenessGene: personality.agreeableness,
            neuroticismGene: personality.neuroticism
        )
    }

    /// Combine two parent genetics to create child genetics
    static func combine(parent1: Genetics, parent2: Genetics) -> Genetics {
        // Each trait has 50% chance from each parent, plus small random mutation
        func inherit(_ gene1: Float, _ gene2: Float) -> Float {
            let base = Bool.random() ? gene1 : gene2
            let mutation = Float.random(in: -0.1...0.1)
            return max(0.0, min(1.0, base + mutation))
        }

        return Genetics(
            opennessGene: inherit(parent1.opennessGene, parent2.opennessGene),
            conscientiousnessGene: inherit(parent1.conscientiousnessGene, parent2.conscientiousnessGene),
            extraversionGene: inherit(parent1.extraversionGene, parent2.extraversionGene),
            agreeablenessGene: inherit(parent1.agreeablenessGene, parent2.agreeablenessGene),
            neuroticismGene: inherit(parent1.neuroticismGene, parent2.neuroticismGene),
            hairColorGene: Bool.random() ? parent1.hairColorGene : parent2.hairColorGene,
            eyeColorGene: Bool.random() ? parent1.eyeColorGene : parent2.eyeColorGene,
            skinToneGene: blendSkinTone(parent1.skinToneGene, parent2.skinToneGene)
        )
    }

    /// Create personality from genetics
    func toPersonality() -> Personality {
        return Personality(
            openness: opennessGene,
            conscientiousness: conscientiousnessGene,
            extraversion: extraversionGene,
            agreeableness: agreeablenessGene,
            neuroticism: neuroticismGene
        )
    }

    /// Blend skin tones (simplified)
    private static func blendSkinTone(_ tone1: String, _ tone2: String) -> String {
        let tones = ["fair", "light", "medium", "tan", "dark"]
        guard let index1 = tones.firstIndex(of: tone1),
              let index2 = tones.firstIndex(of: tone2) else {
            return "medium"
        }
        let avgIndex = (index1 + index2) / 2
        return tones[avgIndex]
    }
}
