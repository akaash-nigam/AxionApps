import Foundation
import Observation

@Observable
class AppState {
    // User session
    var currentUser: User?
    var isAuthenticated: Bool = false

    // Navigation state
    var selectedView: ViewIdentifier = .dashboard
    var isPresentingImmersiveSpace: Bool = false
    var activeImmersiveSpace: String?

    // Feature states
    var financialState: FinancialState
    var operationsState: OperationsState
    var supplyChainState: SupplyChainState

    // UI state
    var isLoading: Bool = false
    var errorMessage: String?
    var notifications: [AppNotification] = []
    var alerts: [Alert] = []

    // Settings
    var selectedPeriod: FiscalPeriod = .current
    var selectedDepartment: Department?

    init() {
        self.financialState = FinancialState()
        self.operationsState = OperationsState()
        self.supplyChainState = SupplyChainState()
    }

    func addNotification(_ notification: AppNotification) {
        notifications.append(notification)
    }

    func clearNotifications() {
        notifications.removeAll()
    }

    func addAlert(_ alert: Alert) {
        alerts.insert(alert, at: 0)
    }

    func removeAlert(_ alert: Alert) {
        alerts.removeAll { $0.id == alert.id }
    }
}

// MARK: - View Identifier
enum ViewIdentifier {
    case dashboard
    case financial
    case operations
    case supplyChain
    case settings
}

// MARK: - Feature States
@Observable
class FinancialState {
    var selectedPeriod: FiscalPeriod = .current
    var generalLedger: [GeneralLedgerEntry] = []
    var costCenters: [CostCenter] = []
    var budgetAnalysis: BudgetAnalysis?
    var isRefreshing: Bool = false

    func refresh() async {
        isRefreshing = true
        defer { isRefreshing = false }
        // Refresh logic will be implemented in services
    }
}

@Observable
class OperationsState {
    var productionOrders: [ProductionOrder] = []
    var workCenters: [WorkCenter] = []
    var selectedWorkCenter: WorkCenter?
    var schedulingView: SchedulingViewMode = .timeline
    var equipment: [Equipment] = []

    var activeOrders: [ProductionOrder] {
        productionOrders.filter { $0.status == .inProgress }
    }

    var efficiency: Double {
        guard !workCenters.isEmpty else { return 0 }
        return workCenters.reduce(0.0) { $0 + $1.efficiency } / Double(workCenters.count)
    }
}

@Observable
class SupplyChainState {
    var inventory: [Inventory] = []
    var suppliers: [Supplier] = []
    var purchaseOrders: [PurchaseOrder] = []
    var selectedSupplier: Supplier?

    var lowStockItems: [Inventory] {
        inventory.filter { $0.availableQuantity < $0.reorderPoint }
    }

    var averageSupplierRating: Double {
        guard !suppliers.isEmpty else { return 0 }
        return suppliers.reduce(0.0) { $0 + $1.rating } / Double(suppliers.count)
    }
}

enum SchedulingViewMode {
    case timeline
    case gantt
    case calendar
}

// MARK: - Supporting Types
struct AppNotification: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let message: String
    let timestamp: Date
    let type: NotificationType

    enum NotificationType {
        case info
        case success
        case warning
        case error
    }
}

struct Alert: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let message: String
    let severity: AlertSeverity
    let timestamp: Date
    let source: String
    var isAcknowledged: Bool = false

    enum AlertSeverity {
        case critical
        case warning
        case info
    }
}

struct User: Codable {
    let id: String
    let name: String
    let email: String
    let role: UserRole
    let department: String?

    enum UserRole: String, Codable {
        case executive
        case manager
        case analyst
        case operator
    }
}

enum FiscalPeriod: String, Codable, CaseIterable {
    case Q12024 = "Q1 2024"
    case Q22024 = "Q2 2024"
    case Q32024 = "Q3 2024"
    case Q42024 = "Q4 2024"
    case FY2024 = "FY 2024"

    static var current: FiscalPeriod {
        .Q42024
    }
}
