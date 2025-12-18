import SwiftUI

@main
struct RetailOptimizerApp: App {
    var body: some Scene {
        WindowGroup {
            StoreControlView()
        }

        ImmersiveSpace(id: "RetailSpace") {
            RetailSpaceView()
        }
    }
}
