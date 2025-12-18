import Foundation

// MARK: - Analytics Event
enum AnalyticsEvent {
    case ideaCreated(ideaID: UUID)
    case ideaUpdated(ideaID: UUID)
    case ideaDeleted(ideaID: UUID)
    case prototypeCreated(prototypeID: UUID)
    case prototypeUpdated(prototypeID: UUID)
    case simulationRun(prototypeID: UUID, success: Bool)
    case collaborationStarted(sessionID: UUID)
    case collaborationEnded(sessionID: UUID)
    case userAction(action: String, context: [String: Any])

    var name: String {
        switch self {
        case .ideaCreated: return "idea_created"
        case .ideaUpdated: return "idea_updated"
        case .ideaDeleted: return "idea_deleted"
        case .prototypeCreated: return "prototype_created"
        case .prototypeUpdated: return "prototype_updated"
        case .simulationRun: return "simulation_run"
        case .collaborationStarted: return "collaboration_started"
        case .collaborationEnded: return "collaboration_ended"
        case .userAction: return "user_action"
        }
    }
}

// MARK: - Analytics Service
actor AnalyticsService {
    static let shared = AnalyticsService()

    private var events: [AnalyticsEvent] = []
    private var metrics: InnovationMetrics = InnovationMetrics()

    private init() {}

    func trackEvent(_ event: AnalyticsEvent) {
        events.append(event)
        updateMetrics(for: event)

        // In production, send to analytics backend
        print("📊 Analytics: \\(event.name)")
    }

    func getMetrics() -> InnovationMetrics {
        return metrics
    }

    func generateReport(for period: DateInterval) -> AnalyticsReport {
        let filteredEvents = events // Filter by period in production

        return AnalyticsReport(
            period: period,
            totalIdeas: metrics.totalIdeas,
            totalPrototypes: metrics.totalPrototypes,
            activeCollaborations: metrics.activeCollaborations,
            successRate: metrics.successRate,
            averageTimeToPrototype: metrics.averageTimeToPrototype
        )
    }

    private func updateMetrics(for event: AnalyticsEvent) {
        switch event {
        case .ideaCreated:
            metrics.totalIdeas += 1
        case .prototypeCreated:
            metrics.totalPrototypes += 1
        case .collaborationStarted:
            metrics.activeCollaborations += 1
        case .collaborationEnded:
            metrics.activeCollaborations = max(0, metrics.activeCollaborations - 1)
        case .simulationRun(_, let success):
            if success {
                metrics.successfulSimulations += 1
            }
        default:
            break
        }
    }
}

// MARK: - Innovation Metrics
struct InnovationMetrics {
    var totalIdeas: Int = 0
    var totalPrototypes: Int = 0
    var activeCollaborations: Int = 0
    var successRate: Double = 0.0
    var averageTimeToPrototype: Double = 0.0
    var successfulSimulations: Int = 0
}

// MARK: - Analytics Report
struct AnalyticsReport {
    let period: DateInterval
    let totalIdeas: Int
    let totalPrototypes: Int
    let activeCollaborations: Int
    let successRate: Double
    let averageTimeToPrototype: Double
    var generatedDate: Date = Date()
}
