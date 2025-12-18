//
//  ServiceContainer.swift
//  Molecular Design Platform
//
//  Dependency injection container for all services
//

import Foundation
import SwiftData

// MARK: - Service Container

@Observable
class ServiceContainer {
    // MARK: - Core Services

    let molecularService: MolecularService
    let projectService: ProjectService

    // MARK: - Chemistry Services

    let chemistryEngine: ChemistryEngine
    let propertyCalculator: PropertyCalculator
    let conformationGenerator: ConformationGenerator

    // MARK: - Simulation Services

    let simulationEngine: SimulationEngine
    let molecularDynamicsService: MolecularDynamicsService
    let dockingService: DockingService

    // MARK: - AI Services

    let propertyPredictionService: PropertyPredictionService

    // MARK: - Visualization

    let molecularRenderer: MolecularRenderer

    // MARK: - File Services

    let fileService: FileService

    // MARK: - Initialization

    init(modelContext: ModelContext) {
        // Initialize chemistry services
        self.chemistryEngine = ChemistryEngine()
        self.propertyCalculator = PropertyCalculator(engine: chemistryEngine)
        self.conformationGenerator = ConformationGenerator()

        // Initialize core services
        self.molecularService = MolecularService(
            modelContext: modelContext,
            chemistryEngine: chemistryEngine
        )
        self.projectService = ProjectService(modelContext: modelContext)

        // Initialize simulation services
        self.molecularDynamicsService = MolecularDynamicsService()
        self.dockingService = DockingService()
        self.simulationEngine = SimulationEngine(
            mdService: molecularDynamicsService,
            dockingService: dockingService
        )

        // Initialize AI services
        self.propertyPredictionService = PropertyPredictionService()

        // Initialize visualization
        self.molecularRenderer = MolecularRenderer()

        // Initialize file service
        self.fileService = FileService(molecularService: molecularService)
    }
}
