//
//  Configuration.swift
//  HomeMaintenanceOracle
//
//  Created on 2025-11-24.
//

import Foundation

enum Configuration {

    // MARK: - API

    static var apiBaseURL: URL {
        #if DEBUG
        return URL(string: "http://localhost:5000/api/v1")!
        #else
        return URL(string: "https://api.homemaintenanceoracle.com/v1")!
        #endif
    }

    // MARK: - App Info

    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    static var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    // MARK: - Feature Flags

    static var useMockServices: Bool {
        #if DEBUG
        return ProcessInfo.processInfo.environment["USE_MOCK_SERVICES"] == "1"
        #else
        return false
        #endif
    }

    // MARK: - ML Models

    static var recognitionModelName: String {
        "ApplianceClassifier"
    }

    static var confidenceThreshold: Float {
        0.85
    }
}
