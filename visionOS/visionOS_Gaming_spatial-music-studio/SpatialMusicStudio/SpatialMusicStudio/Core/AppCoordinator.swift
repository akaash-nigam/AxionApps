import Foundation
import SwiftUI
import Observation

enum ImmersionPreference: String, CaseIterable, Hashable {
    case mixed = "Mixed Reality"
    case progressive = "Progressive"
    case full = "Full Immersion"
}

@Observable
@MainActor
class AppCoordinator: ObservableObject {
    var currentComposition: Composition?
    var isLearningMode: Bool = false
    var isCollaborating: Bool = false
    var immersionPreference: ImmersionPreference = .progressive

    func createNewComposition() {
        // Create a new empty composition
        currentComposition = Composition(
            title: "Untitled Composition",
            tempo: 120,
            timeSignature: TimeSignature.commonTime,
            key: MusicalKey(tonic: .c, scale: .major)
        )
        isLearningMode = false
        isCollaborating = false
    }

    func startLearning() {
        isLearningMode = true
        isCollaborating = false
        currentComposition = nil
    }

    func startCollaboration() async {
        isCollaborating = true
        isLearningMode = false
        // Create a new composition for collaboration
        currentComposition = Composition(
            title: "Collaborative Session",
            tempo: 120,
            timeSignature: TimeSignature.commonTime,
            key: MusicalKey(tonic: .c, scale: .major)
        )
    }
}
