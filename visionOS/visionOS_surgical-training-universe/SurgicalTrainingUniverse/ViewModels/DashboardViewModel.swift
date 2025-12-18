//
//  DashboardViewModel.swift
//  SurgicalTrainingUniverse
//
//  ViewModel for Dashboard view - handles business logic and data formatting
//

import Foundation
import SwiftData
import Observation

@Observable
final class DashboardViewModel {

    // MARK: - Dependencies

    private let procedureService: ProcedureService
    private let analyticsService: AnalyticsService
    private let modelContext: ModelContext

    // MARK: - Published State

    var currentUser: SurgeonProfile?
    var recentSessions: [ProcedureSession] = []
    var performanceMetrics: PerformanceMetrics?
    var isLoading = false
    var errorMessage: String?
    var selectedProcedure: ProcedureType?

    // MARK: - Computed Properties

    var hasRecentActivity: Bool {
        !recentSessions.isEmpty
    }

    var canStartProcedure: Bool {
        currentUser != nil && !isLoading
    }

    var formattedAccuracy: String {
        guard let accuracy = performanceMetrics?.averageAccuracy else {
            return "--"
        }
        return String(format: "%.1f%%", accuracy)
    }

    var formattedEfficiency: String {
        guard let efficiency = performanceMetrics?.averageEfficiency else {
            return "--"
        }
        return String(format: "%.1f%%", efficiency)
    }

    var formattedSafety: String {
        guard let safety = performanceMetrics?.averageSafety else {
            return "--"
        }
        return String(format: "%.1f%%", safety)
    }

    var totalProceduresText: String {
        guard let total = currentUser?.totalProcedures else {
            return "0"
        }
        return "\(total)"
    }

    // MARK: - Available Procedures

    let availableProcedures: [ProcedureInfo] = [
        ProcedureInfo(
            type: .appendectomy,
            name: "Appendectomy",
            description: "Removal of the appendix",
            difficulty: .beginner,
            estimatedDuration: 45
        ),
        ProcedureInfo(
            type: .cholecystectomy,
            name: "Cholecystectomy",
            description: "Gallbladder removal",
            difficulty: .intermediate,
            estimatedDuration: 60
        ),
        ProcedureInfo(
            type: .laparoscopicSurgery,
            name: "Laparoscopic Surgery",
            description: "Minimally invasive procedure",
            difficulty: .intermediate,
            estimatedDuration: 90
        ),
        ProcedureInfo(
            type: .herniorrhaphy,
            name: "Hernia Repair",
            description: "Hernia repair surgery",
            difficulty: .beginner,
            estimatedDuration: 30
        ),
        ProcedureInfo(
            type: .colonoscopy,
            name: "Colonoscopy",
            description: "Colon examination",
            difficulty: .beginner,
            estimatedDuration: 20
        )
    ]

    // MARK: - Initialization

    init(
        procedureService: ProcedureService,
        analyticsService: AnalyticsService,
        modelContext: ModelContext,
        currentUser: SurgeonProfile? = nil
    ) {
        self.procedureService = procedureService
        self.analyticsService = analyticsService
        self.modelContext = modelContext
        self.currentUser = currentUser
    }

    // MARK: - Public Methods

    /// Load dashboard data including recent sessions and performance metrics
    @MainActor
    func loadDashboardData() async {
        guard let user = currentUser else {
            errorMessage = "No user logged in"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            // Load recent sessions
            recentSessions = try await procedureService.getRecentSessions(
                for: user,
                limit: 10
            )

            // Calculate performance metrics
            if !recentSessions.isEmpty {
                performanceMetrics = calculatePerformanceMetrics(from: recentSessions)
            }

        } catch {
            errorMessage = "Failed to load dashboard data: \(error.localizedDescription)"
        }

        isLoading = false
    }

    /// Start a new procedure
    @MainActor
    func startProcedure(_ procedureType: ProcedureType) async {
        guard let user = currentUser else {
            errorMessage = "No user logged in"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let session = try await procedureService.startProcedure(
                type: procedureType,
                surgeon: user
            )

            // Session started successfully
            selectedProcedure = procedureType

        } catch {
            errorMessage = "Failed to start procedure: \(error.localizedDescription)"
        }

        isLoading = false
    }

    /// Refresh dashboard data
    @MainActor
    func refresh() async {
        await loadDashboardData()
    }

    /// Get procedure info by type
    func getProcedureInfo(for type: ProcedureType) -> ProcedureInfo? {
        availableProcedures.first { $0.type == type }
    }

    /// Format session duration
    func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    /// Format date for display
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    /// Get relative time (e.g., "2 hours ago")
    func relativeTime(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    // MARK: - Private Methods

    private func calculatePerformanceMetrics(from sessions: [ProcedureSession]) -> PerformanceMetrics {
        let (avgAccuracy, avgEfficiency, avgSafety) = analyticsService.calculateAverageScores(sessions: sessions)

        return PerformanceMetrics(
            averageAccuracy: avgAccuracy,
            averageEfficiency: avgEfficiency,
            averageSafety: avgSafety,
            totalSessions: sessions.count
        )
    }
}

// MARK: - Supporting Types

struct ProcedureInfo: Identifiable {
    let id = UUID()
    let type: ProcedureType
    let name: String
    let description: String
    let difficulty: DifficultyLevel
    let estimatedDuration: Int // in minutes

    var difficultyColor: String {
        switch difficulty {
        case .beginner: return "green"
        case .intermediate: return "orange"
        case .advanced: return "red"
        case .expert: return "purple"
        }
    }

    var difficultyText: String {
        switch difficulty {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        case .expert: return "Expert"
        }
    }
}

enum DifficultyLevel {
    case beginner
    case intermediate
    case advanced
    case expert
}

struct PerformanceMetrics {
    let averageAccuracy: Double
    let averageEfficiency: Double
    let averageSafety: Double
    let totalSessions: Int

    var overallScore: Double {
        (averageAccuracy + averageEfficiency + averageSafety) / 3.0
    }

    var performanceGrade: String {
        switch overallScore {
        case 90...: return "A"
        case 80..<90: return "B"
        case 70..<80: return "C"
        case 60..<70: return "D"
        default: return "F"
        }
    }
}
