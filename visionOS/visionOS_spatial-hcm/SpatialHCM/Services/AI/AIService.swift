import Foundation
import CoreML

// MARK: - AI Service Protocol
protocol AIServiceProtocol {
    func predictAttrition(for employeeId: UUID) async throws -> AttritionPrediction
    func matchTalent(for role: JobRequirement) async throws -> [TalentMatch]
    func generateCareerPath(for employeeId: UUID) async throws -> [CareerPathOption]
    func analyzeSkills(for employeeId: UUID) async throws -> [SkillRecommendation]
}

// MARK: - AI Service
@Observable
final class AIService: AIServiceProtocol {
    // MARK: - Properties
    private var attritionModel: MLModel?

    // MARK: - State
    var isProcessing: Bool = false
    var error: Error?

    // MARK: - Initialization
    init() {
        loadModels()
    }

    // MARK: - Model Loading
    private func loadModels() {
        // In a real app, load Core ML models here
        // For now, we'll use mock predictions
        print("ℹ️ AI models would be loaded here (using mock data for now)")
    }

    // MARK: - Attrition Prediction
    func predictAttrition(for employeeId: UUID) async throws -> AttritionPrediction {
        isProcessing = true
        defer { isProcessing = false }

        // Simulate ML inference delay
        try await Task.sleep(for: .milliseconds(100))

        // Mock prediction
        let riskScore = Double.random(in: 10...85)
        var reasons: [String] = []

        if riskScore > 60 {
            reasons = ["Limited growth opportunities", "Below market compensation", "High workload"]
        } else if riskScore > 30 {
            reasons = ["Career development", "Team dynamics"]
        }

        let actions = reasons.isEmpty ? [] : [
            RetentionAction(
                type: .careerDevelopment,
                description: "Schedule career development conversation",
                priority: riskScore > 60 ? .high : .medium,
                estimatedImpact: 0.25
            ),
            RetentionAction(
                type: .compensation,
                description: "Review compensation against market",
                priority: .medium,
                estimatedImpact: 0.15
            )
        ]

        return AttritionPrediction(
            employeeId: employeeId,
            flightRisk: riskScore,
            reasons: reasons,
            recommendedActions: actions,
            confidenceScore: Double.random(in: 0.75...0.95),
            predictionDate: Date()
        )
    }

    // MARK: - Talent Matching
    func matchTalent(for role: JobRequirement) async throws -> [TalentMatch] {
        isProcessing = true
        defer { isProcessing = false }

        try await Task.sleep(for: .milliseconds(100))

        // Mock matches
        return (0..<5).map { i in
            TalentMatch(
                employeeId: UUID(),
                employeeName: "Employee \(i + 1)",
                matchScore: Double.random(in: 60...95),
                matchingSkills: ["Swift", "Leadership"],
                missingSkills: i > 2 ? ["Advanced ML"] : [],
                readinessLevel: i < 2 ? .ready : .needsDevelopment
            )
        }
    }

    // MARK: - Career Path Generation
    func generateCareerPath(for employeeId: UUID) async throws -> [CareerPathOption] {
        isProcessing = true
        defer { isProcessing = false }

        try await Task.sleep(for: .milliseconds(150))

        // Mock career paths
        return [
            CareerPathOption(
                targetRole: "Senior Engineer",
                probabilityOfSuccess: 0.85,
                estimatedTimeframe: 12, // months
                requiredSkills: ["Advanced Swift", "System Design"],
                developmentActions: ["Lead major project", "Complete architecture course"],
                similarPathsCount: 42
            ),
            CareerPathOption(
                targetRole: "Engineering Manager",
                probabilityOfSuccess: 0.65,
                estimatedTimeframe: 18,
                requiredSkills: ["People Management", "Strategic Planning"],
                developmentActions: ["Manage small team", "Leadership training"],
                similarPathsCount: 28
            )
        ]
    }

    // MARK: - Skill Analysis
    func analyzeSkills(for employeeId: UUID) async throws -> [SkillRecommendation] {
        isProcessing = true
        defer { isProcessing = false }

        try await Task.sleep(for: .milliseconds(100))

        return [
            SkillRecommendation(
                skillName: "Machine Learning",
                currentProficiency: .intermediate,
                recommendedProficiency: .advanced,
                marketDemand: 0.92,
                learningResources: ["Coursera ML Course", "Internal ML Workshop"],
                estimatedTimeToAcquire: 6 // months
            ),
            SkillRecommendation(
                skillName: "System Design",
                currentProficiency: .beginner,
                recommendedProficiency: .intermediate,
                marketDemand: 0.88,
                learningResources: ["System Design Primer", "Tech Talks"],
                estimatedTimeToAcquire: 4
            )
        ]
    }
}

// MARK: - Attrition Prediction
struct AttritionPrediction: Codable {
    let employeeId: UUID
    let flightRisk: Double // 0-100
    let reasons: [String]
    let recommendedActions: [RetentionAction]
    let confidenceScore: Double
    let predictionDate: Date
}

// MARK: - Retention Action
struct RetentionAction: Codable, Identifiable {
    let id = UUID()
    let type: RetentionActionType
    let description: String
    let priority: GoalPriority
    let estimatedImpact: Double // 0-1 (reduction in flight risk)
}

// MARK: - Retention Action Type
enum RetentionActionType: String, Codable {
    case careerDevelopment = "Career Development"
    case compensation = "Compensation Review"
    case workload = "Workload Adjustment"
    case teamChange = "Team Reassignment"
    case recognition = "Recognition & Appreciation"
    case training = "Training & Development"
}

// MARK: - Job Requirement
struct JobRequirement: Codable {
    let title: String
    let level: JobLevel
    let requiredSkills: [String]
    let preferredSkills: [String]
    let department: String
}

// MARK: - Talent Match
struct TalentMatch: Codable, Identifiable {
    let id = UUID()
    let employeeId: UUID
    let employeeName: String
    let matchScore: Double // 0-100
    let matchingSkills: [String]
    let missingSkills: [String]
    let readinessLevel: ReadinessLevel
}

// MARK: - Readiness Level
enum ReadinessLevel: String, Codable {
    case ready = "Ready Now"
    case readySoon = "Ready in 3-6 Months"
    case needsDevelopment = "Needs Development"
    case notReady = "Not Ready"
}

// MARK: - Career Path Option
struct CareerPathOption: Codable, Identifiable {
    let id = UUID()
    let targetRole: String
    let probabilityOfSuccess: Double // 0-1
    let estimatedTimeframe: Int // months
    let requiredSkills: [String]
    let developmentActions: [String]
    let similarPathsCount: Int
}

// MARK: - Skill Recommendation
struct SkillRecommendation: Codable, Identifiable {
    let id = UUID()
    let skillName: String
    let currentProficiency: ProficiencyLevel
    let recommendedProficiency: ProficiencyLevel
    let marketDemand: Double // 0-1
    let learningResources: [String]
    let estimatedTimeToAcquire: Int // months
}
