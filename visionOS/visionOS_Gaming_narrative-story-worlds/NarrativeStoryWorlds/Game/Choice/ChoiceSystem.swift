import Foundation
import RealityKit

/// Manages choice presentation and player selection
@MainActor
class ChoiceSystem: @unchecked Sendable {
    // MARK: - Properties
    private var currentChoice: Choice?
    private var choiceEntities: [ChoiceEntity] = []
    private var selectionContinuation: CheckedContinuation<ChoiceOption, Never>?

    // MARK: - Choice Presentation
    func presentChoice(_ choice: Choice) async -> ChoiceOption {
        currentChoice = choice

        return await withCheckedContinuation { continuation in
            selectionContinuation = continuation

            // Create choice entities in 3D space
            createChoiceEntities(for: choice)

            // Layout choices spatially
            layoutChoices(choice.options)

            print("🔀 Choice: \(choice.prompt)")
            for (index, option) in choice.options.enumerated() {
                print("  \(index + 1). \(option.text)")
            }

            // If there's a time limit, start timer
            if let timeLimit = choice.timeLimit {
                Task {
                    try? await Task.sleep(for: .seconds(timeLimit))
                    await handleTimeout()
                }
            }
        }
    }

    // MARK: - Choice Creation & Layout
    private func createChoiceEntities(for choice: Choice) {
        // Create RealityKit entities for each choice option
        // This would involve creating 3D UI elements

        for option in choice.options {
            let entity = ChoiceEntity(option: option)
            choiceEntities.append(entity)
        }
    }

    private func layoutChoices(_ options: [ChoiceOption]) {
        // Position choices in 3D space
        // Radial layout around player

        let radius: Float = 0.5
        let arcAngle = Float.pi / 2 // 90 degrees
        let angleStep = arcAngle / Float(max(options.count - 1, 1))

        for (index, entity) in choiceEntities.enumerated() {
            let angle = -arcAngle / 2 + Float(index) * angleStep
            let x = radius * sin(angle)
            let z = -radius * cos(angle)

            entity.position = SIMD3(x, 1.5, z) // Eye level
        }
    }

    // MARK: - Selection Handling
    func selectOption(_ option: ChoiceOption) {
        guard let continuation = selectionContinuation else { return }

        print("✓ Selected: \(option.text)")

        // Animate selection
        animateSelection(for: option)

        // Remove unselected options
        removeUnselectedOptions(except: option)

        // Resume the continuation
        continuation.resume(returning: option)
        selectionContinuation = nil
        currentChoice = nil
    }

    private func handleTimeout() async {
        // Auto-select first option or a default
        if let firstOption = currentChoice?.options.first {
            print("⏱️ Choice timed out, auto-selecting: \(firstOption.text)")
            selectOption(firstOption)
        }
    }

    // MARK: - Animations
    private func animateSelection(for option: ChoiceOption) {
        // Animate selected choice moving toward character or disappearing
        // Would use RealityKit animations
    }

    private func removeUnselectedOptions(except selectedOption: ChoiceOption) {
        // Fade out and remove unselected choice entities
        choiceEntities.removeAll { entity in
            entity.choiceOption.id != selectedOption.id
        }
    }
}

// MARK: - Choice Entity
class ChoiceEntity: Entity {
    let choiceOption: ChoiceOption

    init(option: ChoiceOption) {
        self.choiceOption = option
        super.init()

        // Set up visual representation
        // This would involve creating a 3D UI element with text, background, etc.
    }

    required init() {
        fatalError("Use init(option:) instead")
    }
}
