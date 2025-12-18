import Foundation
import RealityKit

/// Manages dialogue presentation and progression
@MainActor
class DialogueSystem: @unchecked Sendable {
    // MARK: - Properties
    private var currentNode: DialogueNode?
    private var isPresenting = false
    private var presentationTime: TimeInterval = 0

    // MARK: - Update
    func update(deltaTime: TimeInterval) {
        guard isPresenting else { return }

        presentationTime += deltaTime

        if let node = currentNode, node.autoAdvance {
            if presentationTime >= node.displayDuration {
                finishPresentation()
            }
        }
    }

    // MARK: - Dialogue Presentation
    func presentDialogue(_ node: DialogueNode) async {
        currentNode = node
        isPresenting = true
        presentationTime = 0

        // Create dialogue UI in 3D space
        // (Implementation would involve RealityKit entities)

        print("💬 \(node.text)")

        // Wait for auto-advance or user input
        if node.autoAdvance {
            try? await Task.sleep(for: .seconds(node.displayDuration))
            finishPresentation()
        } else {
            // Wait for user to select a response
            // Will be handled by response selection
        }
    }

    private func finishPresentation() {
        isPresenting = false
        currentNode = nil
    }

    // MARK: - Response Selection
    func selectResponse(_ response: DialogueResponse) {
        print("✓ Player selected: \(response.text)")
        finishPresentation()

        // Transition to next dialogue node if specified
        // This would be handled by the StoryManager
    }
}
