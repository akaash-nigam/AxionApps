import Foundation
import SwiftData

// MARK: - Innovation Idea Model
@Model
final class InnovationIdea {
    @Attribute(.unique) var id: UUID
    var title: String
    var ideaDescription: String
    var category: IdeaCategory
    var status: IdeaStatus
    var createdDate: Date
    var lastModified: Date
    var tags: [String]
    var priority: Int
    var estimatedImpact: Double
    var feasibilityScore: Double

    // Relationships
    var creator: User?
    var team: Team?
    var prototypes: [Prototype]
    var comments: [Comment]
    var attachments: [Attachment]
    var analytics: IdeaAnalytics?

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        category: IdeaCategory,
        status: IdeaStatus = .concept,
        priority: Int = 5,
        estimatedImpact: Double = 0.5,
        feasibilityScore: Double = 0.5
    ) {
        self.id = id
        self.title = title
        self.ideaDescription = description
        self.category = category
        self.status = status
        self.createdDate = Date()
        self.lastModified = Date()
        self.tags = []
        self.priority = priority
        self.estimatedImpact = estimatedImpact
        self.feasibilityScore = feasibilityScore
        self.prototypes = []
        self.comments = []
        self.attachments = []
    }
}

// MARK: - Prototype Model
@Model
final class Prototype {
    @Attribute(.unique) var id: UUID
    var name: String
    var version: String
    var modelData: Data?
    var modelURL: String?
    var status: PrototypeStatus
    var createdDate: Date
    var lastModified: Date
    var iterations: Int
    var prototypeDescription: String

    // Simulation Results
    var testResults: [TestResult]
    var simulationDataJSON: Data?

    // Relationships
    var idea: InnovationIdea?
    var collaborators: [User]

    init(
        id: UUID = UUID(),
        name: String,
        version: String = "1.0",
        description: String = "",
        status: PrototypeStatus = .draft
    ) {
        self.id = id
        self.name = name
        self.version = version
        self.prototypeDescription = description
        self.status = status
        self.createdDate = Date()
        self.lastModified = Date()
        self.iterations = 1
        self.testResults = []
        self.collaborators = []
    }
}

// MARK: - User Model
@Model
final class User {
    @Attribute(.unique) var id: UUID
    var name: String
    var email: String
    var role: UserRole
    var department: String
    var avatarURL: String?

    // Relationships
    var ideas: [InnovationIdea]
    var teams: [Team]
    var prototypes: [Prototype]

    init(
        id: UUID = UUID(),
        name: String,
        email: String,
        role: UserRole,
        department: String = ""
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.role = role
        self.department = department
        self.ideas = []
        self.teams = []
        self.prototypes = []
    }
}

// MARK: - Team Model
@Model
final class Team {
    @Attribute(.unique) var id: UUID
    var name: String
    var teamDescription: String
    var members: [User]
    var projects: [InnovationIdea]
    var workspaceConfigJSON: Data?

    init(
        id: UUID = UUID(),
        name: String,
        description: String = ""
    ) {
        self.id = id
        self.name = name
        self.teamDescription = description
        self.members = []
        self.projects = []
    }
}

// MARK: - Analytics Model
@Model
final class IdeaAnalytics {
    @Attribute(.unique) var id: UUID
    var viewCount: Int
    var collaboratorCount: Int
    var iterationCount: Int
    var successProbability: Double
    var marketPotential: Double
    var technicalFeasibility: Double
    var timeInvestedHours: Double
    var projectedTimeToMarket: Int
    var createdDate: Date

    // Relationship
    var idea: InnovationIdea?

    init(
        id: UUID = UUID(),
        successProbability: Double = 0.5,
        marketPotential: Double = 0.5,
        technicalFeasibility: Double = 0.5
    ) {
        self.id = id
        self.viewCount = 0
        self.collaboratorCount = 0
        self.iterationCount = 0
        self.successProbability = successProbability
        self.marketPotential = marketPotential
        self.technicalFeasibility = technicalFeasibility
        self.timeInvestedHours = 0
        self.projectedTimeToMarket = 180
        self.createdDate = Date()
    }
}

// MARK: - Comment Model
@Model
final class Comment {
    @Attribute(.unique) var id: UUID
    var content: String
    var createdDate: Date
    var author: User?
    var idea: InnovationIdea?

    init(
        id: UUID = UUID(),
        content: String
    ) {
        self.id = id
        self.content = content
        self.createdDate = Date()
    }
}

// MARK: - Attachment Model
@Model
final class Attachment {
    @Attribute(.unique) var id: UUID
    var fileName: String
    var fileURL: String
    var fileType: String
    var fileSize: Int64
    var uploadedDate: Date
    var idea: InnovationIdea?

    init(
        id: UUID = UUID(),
        fileName: String,
        fileURL: String,
        fileType: String,
        fileSize: Int64
    ) {
        self.id = id
        self.fileName = fileName
        self.fileURL = fileURL
        self.fileType = fileType
        self.fileSize = fileSize
        self.uploadedDate = Date()
    }
}

// MARK: - Test Result (Codable for JSON storage)
struct TestResult: Codable {
    let id: UUID
    let testName: String
    let passed: Bool
    let score: Double
    let notes: String
    let timestamp: Date

    init(
        id: UUID = UUID(),
        testName: String,
        passed: Bool,
        score: Double,
        notes: String = ""
    ) {
        self.id = id
        self.testName = testName
        self.passed = passed
        self.score = score
        self.notes = notes
        self.timestamp = Date()
    }
}

// MARK: - Enums
enum IdeaCategory: String, Codable, CaseIterable {
    case product = "Product"
    case service = "Service"
    case process = "Process"
    case technology = "Technology"
    case businessModel = "Business Model"

    var icon: String {
        switch self {
        case .product: return "cube.fill"
        case .service: return "hands.sparkles.fill"
        case .process: return "arrow.triangle.2.circlepath"
        case .technology: return "cpu.fill"
        case .businessModel: return "chart.line.uptrend.xyaxis"
        }
    }

    var color: String {
        switch self {
        case .product: return "blue"
        case .service: return "purple"
        case .process: return "green"
        case .technology: return "orange"
        case .businessModel: return "pink"
        }
    }
}

enum IdeaStatus: String, Codable, CaseIterable {
    case concept = "Concept"
    case prototyping = "Prototyping"
    case testing = "Testing"
    case validated = "Validated"
    case inDevelopment = "In Development"
    case launched = "Launched"
    case archived = "Archived"

    var icon: String {
        switch self {
        case .concept: return "lightbulb.fill"
        case .prototyping: return "hammer.fill"
        case .testing: return "flask.fill"
        case .validated: return "checkmark.seal.fill"
        case .inDevelopment: return "gear.badge"
        case .launched: return "rocket.fill"
        case .archived: return "archivebox.fill"
        }
    }

    var color: String {
        switch self {
        case .concept: return "yellow"
        case .prototyping: return "purple"
        case .testing: return "orange"
        case .validated: return "green"
        case .inDevelopment: return "blue"
        case .launched: return "pink"
        case .archived: return "gray"
        }
    }
}

enum PrototypeStatus: String, Codable, CaseIterable {
    case draft = "Draft"
    case inProgress = "In Progress"
    case testing = "Testing"
    case validated = "Validated"
    case failed = "Failed"

    var icon: String {
        switch self {
        case .draft: return "doc.text.fill"
        case .inProgress: return "gearshape.2.fill"
        case .testing: return "checkmark.circle.fill"
        case .validated: return "star.fill"
        case .failed: return "xmark.circle.fill"
        }
    }
}

enum UserRole: String, Codable, CaseIterable {
    case innovator = "Innovator"
    case facilitator = "Facilitator"
    case executive = "Executive"
    case contributor = "Contributor"

    var description: String {
        switch self {
        case .innovator: return "Full access to all innovation tools"
        case .facilitator: return "Manages teams and innovation processes"
        case .executive: return "Strategic oversight and analytics"
        case .contributor: return "Submit ideas and collaborate"
        }
    }
}

// MARK: - Collaboration Session (non-persisted)
struct CollaborationSession: Codable {
    let id: UUID
    let teamID: UUID
    var participants: [UUID]
    let startTime: Date
    var endTime: Date?
    var isActive: Bool

    init(id: UUID = UUID(), teamID: UUID) {
        self.id = id
        self.teamID = teamID
        self.participants = []
        self.startTime = Date()
        self.isActive = true
    }
}

// MARK: - Simulation Data (Codable for JSON storage)
struct SimulationData: Codable {
    let id: UUID
    let simulationType: String
    let parameters: [String: Double]
    let results: [String: Double]
    let successScore: Double
    let timestamp: Date

    init(
        id: UUID = UUID(),
        simulationType: String,
        parameters: [String: Double] = [:],
        results: [String: Double] = [:],
        successScore: Double = 0.0
    ) {
        self.id = id
        self.simulationType = simulationType
        self.parameters = parameters
        self.results = results
        self.successScore = successScore
        self.timestamp = Date()
    }
}

// MARK: - Filters
struct IdeaFilter {
    var category: IdeaCategory?
    var status: IdeaStatus?
    var minPriority: Int?
    var searchQuery: String?
    var teamID: UUID?
    var creatorID: UUID?

    var isEmpty: Bool {
        category == nil &&
        status == nil &&
        minPriority == nil &&
        (searchQuery?.isEmpty ?? true) &&
        teamID == nil &&
        creatorID == nil
    }
}
