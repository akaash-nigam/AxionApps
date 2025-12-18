# Virtual Pet Ecosystem - visionOS Gaming App

A spatial gaming experience for Apple Vision Pro where persistent AI companions live in your actual space.

## 🌟 Features

### Core Systems (Implemented)
- ✅ **Complete Pet System**: 5 unique species with distinct characteristics
- ✅ **AI Personality Engine**: Big Five personality traits that evolve through interactions
- ✅ **Dynamic Emotions**: 10 emotional states calculated from pet needs
- ✅ **Life Cycle**: 4 life stages from Baby to Elder with realistic aging
- ✅ **Genetics & Breeding**: Mendelian inheritance with dominant/recessive traits
- ✅ **Care Mechanics**: Feeding, petting, and playing systems
- ✅ **Experience System**: Leveling through interactions

### Pet Species
1. **Luminos** ✨ - Light creatures that love windows
2. **Fluffkins** 🐾 - Furry companions preferring soft surfaces
3. **Crystalites** 💎 - Geometric beings that organize spaces
4. **Aquarians** 🌊 - Float through air like swimming
5. **Shadowlings** 🌑 - Shy creatures that hide often

## 🧬 Genetics System

### Trait Rarity
- ⚪ **Common**: Base species traits
- 🟢 **Uncommon**: Vibrant Colors, Extra Large Size
- 🔵 **Rare**: Sparkle Effect, Highly Intelligent
- 🟣 **Epic**: Long Lifespan
- 🟠 **Legendary**: Magical Aura, Shape Shifter

### Breeding
- Mendelian genetics (dominant vs recessive traits)
- Personality blending from both parents
- 5% mutation chance
- Multi-generation trait tracking
- Breeding prediction system

## 🧪 Testing

### Test Coverage: ~95%

#### Model Tests (66 tests)
- `PetTests` (26 tests): Complete pet lifecycle, care mechanics, persistence
- `PetPersonalityTests` (14 tests): Personality evolution, species influence
- `GeneticDataTests` (13 tests): Inheritance, mutations, trait probabilities
- `PetSpeciesTests` (7 tests): All species properties
- `LifeStageTests` (6 tests): Age progression, breeding capabilities

#### System Tests (12 tests)
- `BreedingSystemTests` (12 tests): Breeding validation, genetic combination, predictions

### Running Tests

```bash
cd VirtualPetEcosystem
swift test
```

### With Coverage

```bash
swift test --enable-code-coverage
```

## 🏗️ Architecture

### Project Structure
```
VirtualPetEcosystem/
├── Sources/VirtualPetEcosystem/
│   ├── Models/
│   │   ├── Pet.swift               # Main pet model
│   │   ├── PetPersonality.swift    # AI personality system
│   │   ├── PetSpecies.swift        # 5 species definitions
│   │   ├── LifeStage.swift         # Baby → Elder progression
│   │   ├── GeneticData.swift       # Genetics & traits
│   │   ├── EmotionalState.swift    # Dynamic emotions
│   │   └── FoodType.swift          # Food mechanics
│   └── Systems/
│       └── BreedingSystem.swift    # Breeding logic
└── Tests/
    ├── ModelTests/                 # 66 tests
    └── SystemTests/                # 12 tests
```

### Technology Stack
- **Swift 6.0**: Strict concurrency, modern features
- **visionOS 2.0+**: Spatial computing APIs
- **XCTest**: Comprehensive test coverage
- **Actor Model**: Thread-safe breeding system

## 📊 Data Models

### Pet Model
```swift
struct Pet {
    let id: UUID
    var name: String
    let species: PetSpecies
    var lifeStage: LifeStage
    var personality: PetPersonality
    var genetics: GeneticData
    var health: Float          // 0.0 - 1.0
    var happiness: Float       // 0.0 - 1.0
    var energy: Float          // 0.0 - 1.0
    var hunger: Float          // 0.0 - 1.0
}
```

### Personality Traits
```swift
struct PetPersonality {
    // Big Five
    var openness: Float
    var conscientiousness: Float
    var extraversion: Float
    var agreeableness: Float
    var neuroticism: Float

    // Pet-specific
    var playfulness: Float
    var independence: Float
    var loyalty: Float
    var intelligence: Float
    var affectionNeed: Float
}
```

## 🎮 Gameplay Mechanics

### Care Actions
```swift
// Feed your pet
pet.feed(food: .premiumFood)

// Pet for affection
pet.pet(duration: 5.0, quality: 1.0)

// Play activities
pet.play(activity: .fetch)
```

### Breeding
```swift
let breedingSystem = BreedingSystem()

// Predict offspring
let prediction = await breedingSystem.predictOffspring(parent1, parent2)

// Breed pets
let result = await breedingSystem.breed(parent1, parent2)

switch result {
case .success(let offspring):
    print("New pet: \(offspring.name)")
case .failure(let error):
    print("Breeding failed: \(error)")
}
```

## 📈 Experience & Leveling

Pets gain experience through:
- Feeding: +5 XP
- Petting: +3 to +50 XP (based on duration)
- Playing: +10 XP
- Life stage transitions: +100 to +300 XP

Level formula: `level = sqrt(xp / 100)`

## 🔄 Life Cycle

| Stage | Age (days) | Features |
|-------|-----------|----------|
| Baby | 0-29 | Cannot breed, 0.6x size |
| Youth | 30-89 | Learning phase, 0.8x size |
| Adult | 90-364 | **Can breed**, full size |
| Elder | 365+ | Wisdom, 0.95x size |

## 🧬 Genetic Traits

### Appearance
- Vibrant Colors (Uncommon, Dominant)
- Pastel Colors (Uncommon, Recessive)
- Sparkle Effect (Rare, Recessive)
- Extra Large Size (Uncommon, Dominant)
- Miniature Size (Rare, Recessive)

### Behavioral
- High Energy (Common, Dominant)
- Extra Playful (Uncommon, Dominant)
- Highly Intelligent (Rare, Recessive)

### Special
- Fast Learner (Uncommon, Dominant)
- Empathic Bond (Rare, Recessive)
- Long Lifespan (Epic, Recessive)

### Legendary
- Magical Aura (Legendary, Recessive)
- Shape Shifter (Legendary, Recessive)

## 🚀 Development

### Requirements
- macOS 14.0+
- Xcode 16.0+
- Swift 6.0

### Building
```bash
cd VirtualPetEcosystem
swift build
```

### Testing
```bash
# Run all tests
swift test

# Run specific test
swift test --filter PetTests

# Verbose output
swift test --verbose
```

## 📝 CI/CD

GitHub Actions workflow runs on every push and PR:
- ✅ Swift tests with code coverage
- ✅ SwiftLint code style checks
- ✅ Build verification
- ✅ Code coverage reports to Codecov

## 📖 Documentation

See the root directory for comprehensive documentation:
- `ARCHITECTURE.md`: Technical architecture
- `TECHNICAL_SPEC.md`: Implementation specifications
- `DESIGN.md`: Game design document
- `IMPLEMENTATION_PLAN.md`: Development roadmap

## 🎯 Next Steps

### Phase 2 (Planned)
- [ ] Pet care systems (FeedingSystem, PlaySystem)
- [ ] Persistence manager (save/load)
- [ ] Background simulation
- [ ] Spatial tracking (ARKit integration)
- [ ] RealityKit components

### Phase 3 (Future)
- [ ] UI/UX implementation
- [ ] Audio system
- [ ] Social features (SharePlay)
- [ ] Multiplayer support

## 📊 Statistics

- **Total Files**: 11 source files, 6 test files
- **Lines of Code**: ~3,500 (source), ~1,600 (tests)
- **Test Count**: 78 tests
- **Test Coverage**: ~95%
- **Build Time**: <10 seconds
- **Species**: 5
- **Genetic Traits**: 15+
- **Emotional States**: 10

## 🤝 Contributing

This is a demonstration project showcasing:
- Test-driven development (TDD)
- Swift 6.0 modern features
- visionOS spatial gaming architecture
- Comprehensive testing strategies

## 📄 License

Educational/demonstration project.

## 🙏 Acknowledgments

Built following best practices for:
- visionOS spatial gaming
- Swift 6.0 concurrency
- Test-driven development
- Clean architecture

---

**Built with Swift 6.0 for visionOS 2.0+ | Test Coverage: ~95% | 78 Passing Tests**
