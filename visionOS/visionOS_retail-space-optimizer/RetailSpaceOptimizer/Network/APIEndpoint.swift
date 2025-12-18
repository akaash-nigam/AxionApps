import Foundation

/// API endpoint definitions
enum APIEndpoint {
    case getStores
    case getStore(id: UUID)
    case createStore(Store)
    case updateStore(Store)
    case deleteStore(id: UUID)

    case getAnalytics(storeID: UUID, dateRange: DateInterval)
    case generateHeatmap(storeID: UUID, type: HeatmapType)
    case getCustomerJourneys(storeID: UUID, limit: Int?)

    case generateSuggestions(storeID: UUID, parameters: OptimizationParameters?)
    case simulateChanges(storeID: UUID, changes: [LayoutChange])
    case getSuggestionHistory(storeID: UUID)
    case updateSuggestionStatus(suggestionID: UUID, status: SuggestionStatus)

    var path: String {
        switch self {
        case .getStores:
            return "/stores"
        case .getStore(let id):
            return "/stores/\(id.uuidString)"
        case .createStore:
            return "/stores"
        case .updateStore(let store):
            return "/stores/\(store.id.uuidString)"
        case .deleteStore(let id):
            return "/stores/\(id.uuidString)"

        case .getAnalytics(let storeID, _):
            return "/stores/\(storeID.uuidString)/analytics"
        case .generateHeatmap(let storeID, let type):
            return "/stores/\(storeID.uuidString)/heatmap/\(type.rawValue)"
        case .getCustomerJourneys(let storeID, _):
            return "/stores/\(storeID.uuidString)/journeys"

        case .generateSuggestions(let storeID, _):
            return "/stores/\(storeID.uuidString)/suggestions"
        case .simulateChanges(let storeID, _):
            return "/stores/\(storeID.uuidString)/simulate"
        case .getSuggestionHistory(let storeID):
            return "/stores/\(storeID.uuidString)/suggestions/history"
        case .updateSuggestionStatus(let suggestionID, _):
            return "/suggestions/\(suggestionID.uuidString)/status"
        }
    }

    var method: String {
        switch self {
        case .getStores, .getStore, .getAnalytics, .getCustomerJourneys, .getSuggestionHistory:
            return "GET"
        case .createStore, .generateHeatmap, .generateSuggestions, .simulateChanges:
            return "POST"
        case .updateStore, .updateSuggestionStatus:
            return "PUT"
        case .deleteStore:
            return "DELETE"
        }
    }

    var body: Encodable? {
        switch self {
        case .createStore(let store), .updateStore(let store):
            return store
        case .generateSuggestions(_, let parameters):
            return parameters
        case .simulateChanges(_, let changes):
            return changes
        case .updateSuggestionStatus(_, let status):
            return ["status": status.rawValue]
        default:
            return nil
        }
    }
}
