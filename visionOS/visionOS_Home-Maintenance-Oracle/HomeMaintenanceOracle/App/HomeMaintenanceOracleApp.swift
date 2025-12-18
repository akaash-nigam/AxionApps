//
//  HomeMaintenanceOracleApp.swift
//  HomeMaintenanceOracle
//
//  Created on 2025-11-24.
//

import SwiftUI
import SwiftData

@main
struct HomeMaintenanceOracleApp: App {
    // MARK: - Properties

    let persistenceController = PersistenceController.shared
    let appDependencies = AppDependencies.shared

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }

        #if os(visionOS)
        ImmersiveSpace(id: "recognition-space") {
            RecognitionImmersiveView()
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
        #endif
    }

    // MARK: - Initialization

    init() {
        print("🏠 Home Maintenance Oracle Starting...")
        print("📱 Platform: visionOS")
        print("🔧 Core Data: \(persistenceController.container.name)")
    }
}
