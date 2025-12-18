//
//  AppCoordinator.swift
//  Parkour Pathways
//
//  Coordinates app-level state and navigation
//

import SwiftUI
import Combine

@MainActor
class AppCoordinator: ObservableObject {
    // Published state
    @Published var currentSpace: AppSpace = .window
    @Published var isImmersiveSpaceActive = false
    @Published var selectedCourse: CourseData?

    // Dependencies
    private let dependencyContainer = DependencyContainer()

    // Cancellables
    private var cancellables = Set<AnyCancellable>()

    enum AppSpace {
        case window
        case immersive
    }

    init() {
        setupBindings()
    }

    private func setupBindings() {
        // Observe immersive space state
        $isImmersiveSpaceActive
            .sink { [weak self] isActive in
                self?.currentSpace = isActive ? .immersive : .window
            }
            .store(in: &cancellables)
    }

    // MARK: - Navigation

    func startCourse(_ course: CourseData) async throws {
        selectedCourse = course
        try await openImmersiveSpace()
    }

    func openImmersiveSpace() async throws {
        guard !isImmersiveSpaceActive else { return }
        isImmersiveSpaceActive = true
    }

    func closeImmersiveSpace() async {
        guard isImmersiveSpaceActive else { return }
        isImmersiveSpaceActive = false
        selectedCourse = nil
    }

    // MARK: - Dependency Access

    var spatialMappingSystem: SpatialMappingSystem {
        dependencyContainer.spatialMappingSystem
    }

    var audioSystem: SpatialAudioSystem {
        dependencyContainer.audioSystem
    }

    func makeCourseGenerator() -> AICourseGenerator {
        dependencyContainer.makeCourseGenerator()
    }
}

// MARK: - Dependency Container

class DependencyContainer {
    // Singletons
    lazy var spatialMappingSystem = SpatialMappingSystem()
    lazy var audioSystem = SpatialAudioSystem()

    // Factories
    func makeCourseGenerator() -> AICourseGenerator {
        AICourseGenerator(
            difficultyEngine: DifficultyEngine(),
            spatialOptimizer: SpatialOptimizer(),
            safetyValidator: SafetyValidator()
        )
    }

    func makeMultiplayerManager() -> MultiplayerManager {
        MultiplayerManager(
            syncManager: SynchronizationManager()
        )
    }
}
