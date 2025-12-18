import Foundation

/// Catalog of all available meditation environments
class EnvironmentCatalog {

    // MARK: - Private Properties

    private var environments: [String: MeditationEnvironment] = [:]

    // MARK: - Initialization

    init() {
        loadEnvironments()
    }

    // MARK: - Public Methods

    func getAllEnvironments() -> [MeditationEnvironment] {
        return Array(environments.values).sorted { $0.name < $1.name }
    }

    func getEnvironment(by id: String) -> MeditationEnvironment? {
        return environments[id]
    }

    func getEnvironments(by category: EnvironmentCategory) -> [MeditationEnvironment] {
        return environments.values.filter { $0.category == category }
    }

    func getStarterEnvironments() -> [MeditationEnvironment] {
        return environments.values.filter { !$0.isPremium }
    }

    func getPremiumEnvironments() -> [MeditationEnvironment] {
        return environments.values.filter { $0.isPremium }
    }

    // MARK: - Private Methods

    private func loadEnvironments() {
        // STARTER ENVIRONMENTS (Free)

        environments["ZenGarden"] = MeditationEnvironment(
            id: "ZenGarden",
            name: "Zen Garden",
            description: "A peaceful Japanese garden with raked sand, smooth stones, and gentle bamboo swaying in the breeze.",
            category: .nature,
            assetPath: "Environments/ZenGarden",
            isPremium: false,
            unlockLevel: nil,
            visualTheme: VisualTheme(
                primaryColor: .init(red: 0.7, green: 0.8, blue: 0.7, alpha: 1.0),
                secondaryColor: .init(red: 0.9, green: 0.9, blue: 0.85, alpha: 1.0),
                particleEffects: ["FallingPetals", "GentleWind"],
                animationStyle: .gentle
            ),
            audioProfile: AudioProfile(
                ambientSoundscape: "zen_garden_ambient",
                primarySounds: ["bamboo_wind", "water_trickle"],
                secondarySounds: ["distant_chimes"],
                spatialAudio: true
            ),
            recommendedTechniques: [.breathAwareness, .mindfulObservation]
        )

        environments["ForestGrove"] = MeditationEnvironment(
            id: "ForestGrove",
            name: "Forest Grove",
            description: "A sunlit forest clearing with towering trees, dappled light, and the sounds of nature.",
            category: .nature,
            assetPath: "Environments/ForestGrove",
            isPremium: false,
            unlockLevel: nil,
            visualTheme: VisualTheme(
                primaryColor: .init(red: 0.3, green: 0.6, blue: 0.3, alpha: 1.0),
                secondaryColor: .init(red: 0.5, green: 0.7, blue: 0.4, alpha: 1.0),
                particleEffects: ["SunRays", "FloatingLeaves"],
                animationStyle: .flowing
            ),
            audioProfile: AudioProfile(
                ambientSoundscape: "forest_ambient",
                primarySounds: ["birds_chirping", "leaves_rustling"],
                secondarySounds: ["distant_stream", "wind_through_trees"],
                spatialAudio: true
            ),
            recommendedTechniques: [.bodyScan, .mindfulObservation, .walkingMeditation]
        )

        environments["OceanDepths"] = MeditationEnvironment(
            id: "OceanDepths",
            name: "Ocean Depths",
            description: "Beneath gentle waves, surrounded by coral and marine life in crystal-clear blue waters.",
            category: .water,
            assetPath: "Environments/OceanDepths",
            isPremium: false,
            unlockLevel: nil,
            visualTheme: VisualTheme(
                primaryColor: .init(red: 0.2, green: 0.4, blue: 0.7, alpha: 1.0),
                secondaryColor: .init(red: 0.4, green: 0.6, blue: 0.8, alpha: 1.0),
                particleEffects: ["Bubbles", "LightRays", "FloatingPlankton"],
                animationStyle: .flowing
            ),
            audioProfile: AudioProfile(
                ambientSoundscape: "underwater_ambient",
                primarySounds: ["whale_songs", "gentle_currents"],
                secondarySounds: ["bubbles"],
                spatialAudio: true
            ),
            recommendedTechniques: [.breathAwareness, .soundMeditation]
        )

        // PREMIUM ENVIRONMENTS

        environments["MountainPeak"] = MeditationEnvironment(
            id: "MountainPeak",
            name: "Mountain Peak",
            description: "Stand atop a serene mountain with panoramic views of clouds and distant peaks.",
            category: .nature,
            assetPath: "Environments/MountainPeak",
            isPremium: true,
            unlockLevel: 3,
            visualTheme: VisualTheme(
                primaryColor: .init(red: 0.8, green: 0.85, blue: 0.9, alpha: 1.0),
                secondaryColor: .init(red: 0.6, green: 0.65, blue: 0.75, alpha: 1.0),
                particleEffects: ["DriftingClouds", "SoftSnow"],
                animationStyle: .still
            ),
            audioProfile: AudioProfile(
                ambientSoundscape: "mountain_ambient",
                primarySounds: ["wind", "distant_eagle"],
                secondarySounds: ["prayer_flags"],
                spatialAudio: true
            ),
            recommendedTechniques: [.breathAwareness, .visualization]
        )

        environments["CosmicNebula"] = MeditationEnvironment(
            id: "CosmicNebula",
            name: "Cosmic Nebula",
            description: "Float among swirling cosmic clouds and distant stars in the vastness of space.",
            category: .cosmic,
            assetPath: "Environments/CosmicNebula",
            isPremium: true,
            unlockLevel: 5,
            visualTheme: VisualTheme(
                primaryColor: .init(red: 0.3, green: 0.2, blue: 0.5, alpha: 1.0),
                secondaryColor: .init(red: 0.6, green: 0.3, blue: 0.7, alpha: 1.0),
                particleEffects: ["Stars", "CosmicDust", "NebulaClouds"],
                animationStyle: .gentle
            ),
            audioProfile: AudioProfile(
                ambientSoundscape: "cosmic_ambient",
                primarySounds: ["deep_space_hum", "ethereal_tones"],
                secondarySounds: ["pulsar_rhythm"],
                spatialAudio: true
            ),
            recommendedTechniques: [.mindfulObservation, .visualization]
        )

        environments["CrystalCavern"] = MeditationEnvironment(
            id: "CrystalCavern",
            name: "Crystal Cavern",
            description: "A luminescent cave filled with glowing crystals and underground pools.",
            category: .mystical,
            assetPath: "Environments/CrystalCavern",
            isPremium: true,
            unlockLevel: 7,
            visualTheme: VisualTheme(
                primaryColor: .init(red: 0.4, green: 0.6, blue: 0.8, alpha: 1.0),
                secondaryColor: .init(red: 0.6, green: 0.4, blue: 0.9, alpha: 1.0),
                particleEffects: ["GlowingMotes", "CrystalShimmer"],
                animationStyle: .pulsing
            ),
            audioProfile: AudioProfile(
                ambientSoundscape: "cavern_ambient",
                primarySounds: ["crystal_resonance", "dripping_water"],
                secondarySounds: ["echo_tones"],
                spatialAudio: true
            ),
            recommendedTechniques: [.soundMeditation, .mantraRepetition]
        )

        environments["SakuraTemple"] = MeditationEnvironment(
            id: "SakuraTemple",
            name: "Sakura Temple",
            description: "A traditional temple courtyard during cherry blossom season with petals gently falling.",
            category: .sacred,
            assetPath: "Environments/SakuraTemple",
            isPremium: true,
            unlockLevel: 8,
            visualTheme: VisualTheme(
                primaryColor: .init(red: 0.9, green: 0.7, blue: 0.8, alpha: 1.0),
                secondaryColor: .init(red: 0.95, green: 0.85, blue: 0.8, alpha: 1.0),
                particleEffects: ["CherryBlossomPetals", "Incense"],
                animationStyle: .gentle
            ),
            audioProfile: AudioProfile(
                ambientSoundscape: "temple_ambient",
                primarySounds: ["temple_bells", "wind_chimes"],
                secondarySounds: ["monks_chanting"],
                spatialAudio: true
            ),
            recommendedTechniques: [.breathAwareness, .lovingKindness, .mantraRepetition]
        )

        environments["AuroraPlains"] = MeditationEnvironment(
            id: "AuroraPlains",
            name: "Aurora Plains",
            description: "Vast northern plains under dancing northern lights and starry skies.",
            category: .celestial,
            assetPath: "Environments/AuroraPlains",
            isPremium: true,
            unlockLevel: 10,
            visualTheme: VisualTheme(
                primaryColor: .init(red: 0.2, green: 0.8, blue: 0.6, alpha: 1.0),
                secondaryColor: .init(red: 0.3, green: 0.4, blue: 0.7, alpha: 1.0),
                particleEffects: ["AuroraBorealis", "FallingSnow", "Stars"],
                animationStyle: .flowing
            ),
            audioProfile: AudioProfile(
                ambientSoundscape: "arctic_ambient",
                primarySounds: ["aurora_hum", "gentle_wind"],
                secondarySounds: ["ice_crackle"],
                spatialAudio: true
            ),
            recommendedTechniques: [.mindfulObservation, .visualization]
        )

        environments["DesertDunes"] = MeditationEnvironment(
            id: "DesertDunes",
            name: "Desert Dunes",
            description: "Endless sand dunes under a vast sky, with the warmth of the setting sun.",
            category: .nature,
            assetPath: "Environments/DesertDunes",
            isPremium: true,
            unlockLevel: 6,
            visualTheme: VisualTheme(
                primaryColor: .init(red: 0.9, green: 0.7, blue: 0.5, alpha: 1.0),
                secondaryColor: .init(red: 0.95, green: 0.6, blue: 0.3, alpha: 1.0),
                particleEffects: ["HeatShimmer", "SandDust"],
                animationStyle: .still
            ),
            audioProfile: AudioProfile(
                ambientSoundscape: "desert_ambient",
                primarySounds: ["wind_over_sand", "distant_bells"],
                secondarySounds: ["night_insects"],
                spatialAudio: true
            ),
            recommendedTechniques: [.breathAwareness, .visualization]
        )

        environments["RainforestCanopy"] = MeditationEnvironment(
            id: "RainforestCanopy",
            name: "Rainforest Canopy",
            description: "High in the rainforest canopy with tropical birds and gentle rainfall.",
            category: .nature,
            assetPath: "Environments/RainforestCanopy",
            isPremium: true,
            unlockLevel: 4,
            visualTheme: VisualTheme(
                primaryColor: .init(red: 0.2, green: 0.6, blue: 0.3, alpha: 1.0),
                secondaryColor: .init(red: 0.4, green: 0.7, blue: 0.4, alpha: 1.0),
                particleEffects: ["Rainfall", "MistRising", "FloatingSeeds"],
                animationStyle: .flowing
            ),
            audioProfile: AudioProfile(
                ambientSoundscape: "rainforest_ambient",
                primarySounds: ["rain_on_leaves", "tropical_birds", "howler_monkeys"],
                secondarySounds: ["tree_frogs", "insects"],
                spatialAudio: true
            ),
            recommendedTechniques: [.soundMeditation, .mindfulObservation]
        )

        environments["FloatingLanterns"] = MeditationEnvironment(
            id: "FloatingLanterns",
            name: "Floating Lanterns",
            description: "A twilight river festival with thousands of glowing lanterns floating skyward.",
            category: .sacred,
            assetPath: "Environments/FloatingLanterns",
            isPremium: true,
            unlockLevel: 9,
            visualTheme: VisualTheme(
                primaryColor: .init(red: 0.9, green: 0.6, blue: 0.3, alpha: 1.0),
                secondaryColor: .init(red: 0.3, green: 0.3, blue: 0.6, alpha: 1.0),
                particleEffects: ["FloatingLanterns", "Fireflies", "WaterReflections"],
                animationStyle: .gentle
            ),
            audioProfile: AudioProfile(
                ambientSoundscape: "festival_ambient",
                primarySounds: ["gentle_music", "water_lapping"],
                secondarySounds: ["distant_celebration", "bells"],
                spatialAudio: true
            ),
            recommendedTechniques: [.lovingKindness, .visualization]
        )

        environments["BambooForest"] = MeditationEnvironment(
            id: "BambooForest",
            name: "Bamboo Forest",
            description: "Walk among towering bamboo stalks swaying gently in the mountain breeze.",
            category: .nature,
            assetPath: "Environments/BambooForest",
            isPremium: true,
            unlockLevel: 3,
            visualTheme: VisualTheme(
                primaryColor: .init(red: 0.4, green: 0.7, blue: 0.4, alpha: 1.0),
                secondaryColor: .init(red: 0.6, green: 0.8, blue: 0.5, alpha: 1.0),
                particleEffects: ["SunlightBeams", "FloatingLeaves"],
                animationStyle: .swaying
            ),
            audioProfile: AudioProfile(
                ambientSoundscape: "bamboo_forest_ambient",
                primarySounds: ["bamboo_creaking", "wind_through_stalks"],
                secondarySounds: ["birds", "insects"],
                spatialAudio: true
            ),
            recommendedTechniques: [.walkingMeditation, .breathAwareness]
        )

        environments["StarlitMeadow"] = MeditationEnvironment(
            id: "StarlitMeadow",
            name: "Starlit Meadow",
            description: "A peaceful meadow under a brilliant night sky filled with stars and the Milky Way.",
            category: .celestial,
            assetPath: "Environments/StarlitMeadow",
            isPremium: true,
            unlockLevel: 5,
            visualTheme: VisualTheme(
                primaryColor: .init(red: 0.2, green: 0.2, blue: 0.4, alpha: 1.0),
                secondaryColor: .init(red: 0.4, green: 0.5, blue: 0.3, alpha: 1.0),
                particleEffects: ["Stars", "Fireflies", "ShootingStars"],
                animationStyle: .still
            ),
            audioProfile: AudioProfile(
                ambientSoundscape: "night_meadow_ambient",
                primarySounds: ["crickets", "gentle_breeze"],
                secondarySounds: ["owl_hoots", "rustling_grass"],
                spatialAudio: true
            ),
            recommendedTechniques: [.mindfulObservation, .lovingKindness]
        )

        environments["WaterfallGrove"] = MeditationEnvironment(
            id: "WaterfallGrove",
            name: "Waterfall Grove",
            description: "A hidden waterfall cascading into a clear pool surrounded by lush vegetation.",
            category: .water,
            assetPath: "Environments/WaterfallGrove",
            isPremium: true,
            unlockLevel: 4,
            visualTheme: VisualTheme(
                primaryColor: .init(red: 0.3, green: 0.6, blue: 0.7, alpha: 1.0),
                secondaryColor: .init(red: 0.4, green: 0.7, blue: 0.5, alpha: 1.0),
                particleEffects: ["WaterMist", "Spray", "FloatingLeaves"],
                animationStyle: .flowing
            ),
            audioProfile: AudioProfile(
                ambientSoundscape: "waterfall_ambient",
                primarySounds: ["waterfall", "flowing_stream"],
                secondarySounds: ["birds", "insects"],
                spatialAudio: true
            ),
            recommendedTechniques: [.soundMeditation, .bodyScan]
        )
    }

    // MARK: - Search & Filter

    func searchEnvironments(query: String) -> [MeditationEnvironment] {
        let lowercaseQuery = query.lowercased()
        return environments.values.filter { environment in
            environment.name.lowercased().contains(lowercaseQuery) ||
            environment.description.lowercased().contains(lowercaseQuery)
        }
    }

    func getEnvironmentCount() -> Int {
        return environments.count
    }

    func getEnvironmentCount(category: EnvironmentCategory) -> Int {
        return environments.values.filter { $0.category == category }.count
    }
}
