//
//  RecognitionResult.swift
//  HomeMaintenanceOracle
//
//  Created on 2025-11-24.
//

import Foundation

struct RecognitionResult {
    let category: String
    let brand: String?
    let model: String?
    let confidence: Float
    let alternatives: [Alternative]

    struct Alternative {
        let category: String
        let confidence: Float
    }

    var categoryIcon: String {
        ApplianceCategory(rawValue: category)?.icon ?? "cube.box.fill"
    }

    var isHighConfidence: Bool {
        confidence > 0.85
    }
}
