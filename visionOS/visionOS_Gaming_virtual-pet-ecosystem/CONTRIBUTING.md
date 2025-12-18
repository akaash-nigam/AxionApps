# Contributing to Virtual Pet Ecosystem

Thank you for your interest in contributing to Virtual Pet Ecosystem! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Commit Messages](#commit-messages)
- [Pull Request Process](#pull-request-process)
- [Architecture Guidelines](#architecture-guidelines)
- [Documentation](#documentation)

---

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive experience for everyone. We expect all participants to:

- Be respectful and considerate
- Welcome newcomers and help them learn
- Focus on what is best for the community
- Show empathy towards other community members
- Be open to constructive feedback

### Unacceptable Behavior

- Harassment, discrimination, or trolling
- Personal attacks or inflammatory comments
- Publishing others' private information
- Spam or off-topic content
- Any conduct that would be inappropriate in a professional setting

---

## Getting Started

### Prerequisites

Before contributing, ensure you have:

- **macOS 14.0+** (required for visionOS development)
- **Xcode 16.0+** with visionOS SDK
- **Swift 6.0** (included with Xcode 16.0+)
- **Git** for version control
- Basic understanding of Swift and SwiftUI
- Familiarity with visionOS/spatial computing (helpful but not required)

### Familiarize Yourself with the Project

1. Read the [README.md](README.md) for project overview
2. Review [ARCHITECTURE.md](ARCHITECTURE.md) for technical architecture
3. Check [TECHNICAL_SPEC.md](TECHNICAL_SPEC.md) for implementation details
4. Browse existing code in `VirtualPetEcosystem/Sources/`
5. Look at tests in `VirtualPetEcosystem/Tests/` for examples

---

## Development Setup

### 1. Fork and Clone

```bash
# Fork the repository on GitHub, then clone your fork
git clone https://github.com/YOUR_USERNAME/visionOS_Gaming_virtual-pet-ecosystem.git
cd visionOS_Gaming_virtual-pet-ecosystem

# Add upstream remote
git remote add upstream https://github.com/ORIGINAL_OWNER/visionOS_Gaming_virtual-pet-ecosystem.git
```

### 2. Install Dependencies

```bash
# Navigate to the Swift package
cd VirtualPetEcosystem

# Resolve package dependencies (if any)
swift package resolve

# Verify your setup
swift build
swift test
```

### 3. Open in Xcode

```bash
# Open the package in Xcode
open Package.swift
```

---

## Development Workflow

### 1. Create a Feature Branch

```bash
# Sync with upstream
git fetch upstream
git checkout main
git merge upstream/main

# Create a feature branch
git checkout -b feature/your-feature-name
```

### Branch Naming Conventions

- `feature/` - New features (e.g., `feature/spatial-audio`)
- `fix/` - Bug fixes (e.g., `fix/pet-hunger-calculation`)
- `docs/` - Documentation updates (e.g., `docs/improve-readme`)
- `test/` - Test additions/improvements (e.g., `test/breeding-edge-cases`)
- `refactor/` - Code refactoring (e.g., `refactor/personality-system`)
- `perf/` - Performance improvements (e.g., `perf/optimize-genetics`)

### 2. Make Your Changes

Follow the [Test-Driven Development](#test-driven-development) approach:

1. Write failing tests first
2. Implement the minimum code to make tests pass
3. Refactor while keeping tests green
4. Add documentation

### 3. Test Your Changes

```bash
cd VirtualPetEcosystem

# Run all tests
swift test

# Run with verbose output
swift test --verbose

# Run specific test
swift test --filter YourTestName

# Check code coverage
swift test --enable-code-coverage
```

### 4. Commit Your Changes

Follow the [Commit Message Guidelines](#commit-messages):

```bash
git add .
git commit -m "feat: Add spatial audio system for pets"
```

### 5. Push and Create Pull Request

```bash
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub.

---

## Coding Standards

### Swift 6.0 Best Practices

#### 1. Strict Concurrency

All code must comply with Swift 6.0 strict concurrency:

```swift
// ✅ Good: Sendable type
public struct Pet: Codable, Sendable {
    public let id: UUID
    public var name: String
}

// ✅ Good: Actor for mutable state
public actor BreedingSystem {
    private var breedingHistory: [UUID: Date] = [:]

    public func breed(_ parent1: Pet, _ parent2: Pet) async -> Result<Pet, BreedingError> {
        // Thread-safe implementation
    }
}

// ✅ Good: @MainActor for UI
@MainActor
public class PetManager: ObservableObject {
    @Published public private(set) var pets: [Pet] = []
}

// ❌ Bad: Mutable class without actor or @MainActor
public class PetManager {  // Unsafe!
    public var pets: [Pet] = []
}
```

#### 2. Type Safety

```swift
// ✅ Good: Strong typing
public enum PetSpecies: String, Codable, CaseIterable, Sendable {
    case luminos, fluffkins, crystalites
}

// ❌ Bad: Stringly-typed
public func getPet(species: String) { }  // Unsafe!
```

#### 3. Error Handling

```swift
// ✅ Good: Typed errors
public enum BreedingError: Error, Sendable {
    case parentNotReady(String)
    case speciesMismatch
    case insufficientHealth(String, Float)
}

public func breed() -> Result<Pet, BreedingError> {
    // Implementation
}

// ❌ Bad: Generic errors
public func breed() throws -> Pet {  // Less specific
    throw NSError(domain: "breeding", code: 1)
}
```

#### 4. Access Control

```swift
// ✅ Good: Minimal public API
public struct Pet {
    public let id: UUID
    public var name: String
    public private(set) var health: Float  // Public read, private write

    private var internalState: Int  // Completely private
}
```

### Code Style

#### Naming Conventions

```swift
// Types: UpperCamelCase
struct Pet { }
class PetManager { }
enum PetSpecies { }

// Variables, functions: lowerCamelCase
var healthPoints: Float
func calculateHappiness() -> Float

// Constants: lowerCamelCase
let maxHealth: Float = 1.0
let defaultSpecies: PetSpecies = .luminos

// Enums: lowerCamelCase cases
enum LifeStage {
    case baby, youth, adult, elder
}
```

#### Documentation

Every public API must have documentation:

```swift
/// Represents a virtual pet with personality, genetics, and life simulation.
///
/// Pets are the core entities in the ecosystem. Each pet has:
/// - Unique personality traits that evolve over time
/// - Genetic data inherited from parents
/// - Life simulation with health, happiness, and needs
///
/// Example:
/// ```swift
/// var pet = Pet(name: "Sparky", species: .luminos)
/// pet.feed(food: .premiumFood)
/// print(pet.happiness)  // 0.95
/// ```
public struct Pet: Codable, Identifiable, Sendable {
    /// The unique identifier for this pet.
    public let id: UUID

    /// The pet's name, chosen by the player.
    public var name: String

    /// Feeds the pet with the specified food type.
    ///
    /// Feeding affects multiple stats:
    /// - Increases hunger satisfaction
    /// - Adds happiness based on food quality
    /// - Awards experience points
    /// - Evolves personality traits
    ///
    /// - Parameter food: The type of food to feed the pet
    public mutating func feed(food: FoodType) {
        // Implementation
    }
}
```

#### Code Organization

```swift
// MARK: - Type Definition
public struct Pet: Codable, Sendable {
    // MARK: - Properties
    public let id: UUID
    public var name: String

    // MARK: - Initialization
    public init(name: String, species: PetSpecies) {
        // Implementation
    }

    // MARK: - Public Methods
    public mutating func feed(food: FoodType) {
        // Implementation
    }

    // MARK: - Private Methods
    private mutating func updateEmotionalState() {
        // Implementation
    }

    // MARK: - Helper Methods
    private static func clamp(_ value: Float, min: Float = 0, max: Float = 1) -> Float {
        // Implementation
    }
}
```

---

## Testing Guidelines

### Test-Driven Development

We follow **TDD** strictly:

1. **Write the test first** - Think about the API and expected behavior
2. **Watch it fail** - Confirm the test catches the missing functionality
3. **Implement** - Write minimal code to make the test pass
4. **Refactor** - Improve code quality while keeping tests green

### Test Organization

```
Tests/VirtualPetEcosystemTests/
├── ModelTests/
│   ├── PetTests.swift
│   ├── PetPersonalityTests.swift
│   └── GeneticDataTests.swift
├── SystemTests/
│   └── BreedingSystemTests.swift
└── ServiceTests/
    ├── PersistenceManagerTests.swift
    └── PetManagerTests.swift
```

### Writing Good Tests

```swift
import XCTest
@testable import VirtualPetEcosystem

final class PetTests: XCTestCase {
    // MARK: - Properties
    var sut: Pet!  // System Under Test

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        sut = Pet(name: "TestPet", species: .luminos)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Tests

    /// Test that feeding increases hunger satisfaction
    func testFeeding_IncreasesHunger() {
        // Given
        sut.hunger = 0.3
        let initialHunger = sut.hunger

        // When
        sut.feed(food: .premiumFood)

        // Then
        XCTAssertGreaterThan(sut.hunger, initialHunger)
        XCTAssertLessThanOrEqual(sut.hunger, 1.0)
    }

    /// Test that neglected pets lose health over time
    func testNeglect_DecreasesHealth() {
        // Given
        sut.health = 1.0
        sut.hunger = 0.1  // Very hungry

        // When
        sut.updateNeeds(deltaTime: 3600)  // 1 hour

        // Then
        XCTAssertLessThan(sut.health, 1.0, "Health should decrease when needs are unmet")
    }

    /// Test breeding validation with async actor
    func testBreeding_WithInvalidParents_ReturnsError() async {
        // Given
        let breedingSystem = BreedingSystem()
        let babyPet = Pet(name: "Baby", species: .luminos)  // Can't breed
        let adultPet = createAdultPet()

        // When
        let result = await breedingSystem.breed(babyPet, adultPet)

        // Then
        switch result {
        case .success:
            XCTFail("Breeding should fail with baby pet")
        case .failure(let error):
            if case .wrongLifeStage(let name, let stage) = error {
                XCTAssertEqual(name, "Baby")
                XCTAssertEqual(stage, .baby)
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        }
    }

    // MARK: - Helper Methods
    private func createAdultPet() -> Pet {
        let birthDate = Date().addingTimeInterval(-86400 * 120)  // 120 days old
        var pet = Pet(name: "Adult", species: .luminos, birthDate: birthDate)
        pet.updateLifeStage()
        return pet
    }
}
```

### Test Categories

1. **Unit Tests** - Test individual functions/methods
2. **Integration Tests** - Test interaction between components
3. **Statistical Tests** - Test probabilistic systems (genetics, mutations)
4. **Edge Case Tests** - Test boundary conditions
5. **Performance Tests** - Test efficiency (if needed)

### Coverage Requirements

- **Minimum 90% code coverage** for new code
- **All public APIs must have tests**
- **Critical paths require 100% coverage** (e.g., persistence, breeding)

---

## Commit Messages

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation changes
- `test` - Adding or updating tests
- `refactor` - Code refactoring
- `perf` - Performance improvements
- `style` - Code style changes (formatting, semicolons, etc.)
- `chore` - Maintenance tasks (dependencies, build, etc.)

### Examples

```bash
# Simple feature
git commit -m "feat: Add spatial audio system for pet sounds"

# Bug fix with scope
git commit -m "fix(genetics): Correct mutation probability calculation"

# With body and footer
git commit -m "feat(breeding): Add offspring prediction system

Implements a prediction system that calculates probable traits
for offspring based on parent genetics. Uses Mendelian inheritance
rules to determine dominant/recessive trait probabilities.

Closes #42"

# Breaking change
git commit -m "feat(api): Change Pet initialization API

BREAKING CHANGE: Pet initializer now requires species parameter.
Update all Pet() calls to include species: .luminos (or other species)."
```

---

## Pull Request Process

### Before Submitting

1. ✅ All tests pass (`swift test`)
2. ✅ Code coverage meets requirements (90%+)
3. ✅ No build warnings
4. ✅ Code follows style guidelines
5. ✅ Documentation is updated
6. ✅ Commit messages follow conventions
7. ✅ Branch is up-to-date with main

### PR Template

```markdown
## Description
Brief description of what this PR does.

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing
- [ ] All existing tests pass
- [ ] Added new tests for this change
- [ ] Test coverage is 90%+

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] No new warnings introduced
- [ ] Related issues linked

## Screenshots (if applicable)
Add screenshots or videos for UI changes.

## Additional Notes
Any additional context, concerns, or discussion points.
```

### Review Process

1. **Automated Checks** - CI runs tests automatically
2. **Code Review** - At least one maintainer reviews
3. **Discussion** - Address feedback and comments
4. **Approval** - Get approval from maintainer
5. **Merge** - Maintainer merges your PR

### Addressing Feedback

```bash
# Make changes based on feedback
git add .
git commit -m "refactor: Apply review feedback"
git push origin feature/your-feature-name
```

---

## Architecture Guidelines

### Project Structure

Follow the existing architecture:

```
Sources/VirtualPetEcosystem/
├── Models/          # Data structures (Sendable, Codable)
├── Systems/         # Game systems (Actors for thread safety)
├── Services/        # Support services (Persistence, etc.)
└── Views/           # SwiftUI views (future)
```

### Adding New Features

#### Example: Adding a New Pet Attribute

**1. Update Model (`Pet.swift`):**

```swift
public struct Pet {
    // Add new property
    public var cleanliness: Float = 1.0

    // Add care method
    public mutating func bathe(quality: Float) {
        cleanliness = min(1.0, cleanliness + quality)
        happiness += 0.1
        experience += 5
    }
}
```

**2. Write Tests (`PetTests.swift`):**

```swift
func testBathing_IncreasesCleanliness() {
    sut.cleanliness = 0.5
    sut.bathe(quality: 0.3)
    XCTAssertEqual(sut.cleanliness, 0.8, accuracy: 0.01)
}

func testBathing_AddsExperience() {
    let initialXP = sut.experience
    sut.bathe(quality: 1.0)
    XCTAssertEqual(sut.experience, initialXP + 5)
}
```

**3. Update Documentation:**

- Add cleanliness to Pet documentation
- Update care mechanics in README
- Add to TECHNICAL_SPEC if significant

---

## Documentation

### Required Documentation

1. **Code Comments** - For complex logic
2. **DocStrings** - For all public APIs (see examples above)
3. **README Updates** - For new features
4. **Architecture Docs** - For significant changes

### Documentation Style

```swift
/// <One-line summary>
///
/// <Detailed description with multiple paragraphs if needed>
///
/// Example:
/// ```swift
/// <code example>
/// ```
///
/// - Parameters:
///   - param1: Description
///   - param2: Description
/// - Returns: Description
/// - Throws: Description of errors
///
/// - Note: Additional notes
/// - Warning: Important warnings
/// - SeeAlso: Related APIs
public func myFunction(param1: Int, param2: String) -> Bool {
    // Implementation
}
```

---

## Questions or Need Help?

- 📖 Check existing [Documentation](ARCHITECTURE.md)
- 💬 Open a [Discussion](https://github.com/yourusername/visionOS_Gaming_virtual-pet-ecosystem/discussions)
- 🐛 Report [Issues](https://github.com/yourusername/visionOS_Gaming_virtual-pet-ecosystem/issues)
- 📧 Email: support@example.com

---

## Recognition

Contributors will be recognized in:
- README.md acknowledgments
- Release notes
- Project documentation

Thank you for contributing to Virtual Pet Ecosystem! 🐾✨
