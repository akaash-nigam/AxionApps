//
//  ServiceContainer.swift
//  SmartAgriculture
//
//  Created by Claude Code
//  Copyright © 2025 Smart Agriculture. All rights reserved.
//

import Foundation
import Observation

// MARK: - Service Container

@Observable
final class ServiceContainer {
    // MARK: - Core Services

    let healthAnalysisService: HealthAnalysisService
    let yieldPredictionService: YieldPredictionService
    let recommendationService: RecommendationService

    // MARK: - Advanced Algorithm Services

    let weatherImpactService: WeatherImpactService
    let droughtRiskService: DroughtRiskService
    let plantingDateService: PlantingDateService
    let harvestTimingService: HarvestTimingService
    let cropRotationService: CropRotationService

    // MARK: - Initialization

    init() {
        // Initialize core services
        self.healthAnalysisService = HealthAnalysisService()
        self.yieldPredictionService = YieldPredictionService()
        self.recommendationService = RecommendationService()

        // Initialize advanced algorithm services
        self.weatherImpactService = WeatherImpactService()
        self.droughtRiskService = DroughtRiskService()
        self.plantingDateService = PlantingDateService()
        self.harvestTimingService = HarvestTimingService()
        self.cropRotationService = CropRotationService()
    }
}
