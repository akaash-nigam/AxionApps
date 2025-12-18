import SwiftUI

enum ImmersiveSpaceError: Error {
    case failedToOpen
    case unknown
}

@MainActor
class ImmersiveSpaceManager: ObservableObject {
    @Published private(set) var isImmersiveSpaceActive = false

    private let immersiveSpaceID = "GameplaySpace"

    func enterImmersiveSpace(
        using openImmersiveSpace: OpenImmersiveSpaceAction
    ) async throws {
        switch await openImmersiveSpace(id: immersiveSpaceID) {
        case .opened:
            isImmersiveSpaceActive = true
        case .error:
            throw ImmersiveSpaceError.failedToOpen
        case .userCancelled:
            throw ImmersiveSpaceError.failedToOpen
        @unknown default:
            throw ImmersiveSpaceError.unknown
        }
    }

    func exitImmersiveSpace(
        using dismissImmersiveSpace: DismissImmersiveSpaceAction
    ) async {
        await dismissImmersiveSpace()
        isImmersiveSpaceActive = false
    }
}
