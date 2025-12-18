//
//  DashboardView.swift
//  BusinessOperatingSystem
//
//  Created by BOS Team on 2025-01-20.
//

import SwiftUI

struct DashboardView: View {
    @Environment(\.appState) private var appState
    @Environment(\.services) private var services
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    @State private var kpis: [KPI] = []
    @State private var isLoading = false
    @State private var showingErrorAlert = false
    @State private var currentError: ErrorAlertConfig?
    @State private var showingStorageWarning = false

    // Optional initialization error from app startup
    var initializationError: Error?

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 24) {
                        // Offline banner
                        OfflineBanner(connectivity: services.connectivity)

                        // Storage warning banner if using fallback
                        if appState.isUsingFallbackStorage {
                            storageFallbackBanner
                        }

                        // Header
                        headerSection

                        // KPI Cards
                        kpiSection

                        // Department Grid
                        departmentSection

                        // Recent Activity
                        activitySection
                    }
                    .padding(24)
                }

                // Loading overlay
                if isLoading {
                    loadingOverlay
                }
            }
            .background(.ultraThinMaterial)
            .navigationTitle("Business Dashboard")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await openImmersiveSpace(id: "business-universe")
                        }
                    } label: {
                        Label("Enter Business Universe", systemImage: "cube.fill")
                    }

                    Button {
                        appState.showingSettings = true
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
            }
            .task {
                await loadDashboardData()
            }
            .onChange(of: appState.lastError) { _, newError in
                if let error = newError {
                    currentError = error
                    showingErrorAlert = true
                }
            }
            .alert(
                currentError?.title ?? "Error",
                isPresented: $showingErrorAlert,
                presenting: currentError
            ) { error in
                ForEach(error.actions, id: \.title) { action in
                    Button(action.title) {
                        handleErrorAction(action)
                    }
                }
            } message: { error in
                Text(error.message)
            }
            .onAppear {
                // Show initialization error if present
                if let error = initializationError {
                    currentError = ErrorAlertConfig(
                        title: "Storage Warning",
                        message: "Failed to initialize persistent storage. Your data will not be saved between sessions. Error: \(error.localizedDescription)",
                        actions: [.cancel]
                    )
                    showingErrorAlert = true
                    appState.isUsingFallbackStorage = true
                }
            }
        }
    }

    // MARK: - Storage Warning Banner

    private var storageFallbackBanner: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.yellow)
            Text("Running in temporary storage mode. Data will not persist.")
                .font(.caption)
            Spacer()
            Button("Dismiss") {
                appState.isUsingFallbackStorage = false
            }
            .font(.caption)
        }
        .padding(12)
        .background(.orange.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Loading Overlay

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                Text("Loading...")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            .padding(32)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .ignoresSafeArea()
    }

    // MARK: - Error Action Handler

    private func handleErrorAction(_ action: ErrorRecoveryAction) {
        switch action {
        case .retry:
            Task {
                await loadDashboardData()
            }
        case .cancel:
            appState.clearError()
        case .useCache:
            // Load from cache would be implemented here
            appState.clearError()
        case .skip:
            appState.clearError()
        case .custom(_, let handler):
            Task {
                await handler()
                appState.clearError()
            }
        }
        currentError = nil
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome, \(appState.user?.name ?? "User")")
                .font(.largeTitle.bold())

            Text(appState.organization?.name ?? "Your Organization")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var kpiSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Key Metrics")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 250))], spacing: 16) {
                ForEach(kpis.prefix(4)) { kpi in
                    KPICard(kpi: kpi)
                        .onTapGesture {
                            // Open KPI detail
                        }
                }
            }
        }
    }

    private var departmentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Departments")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))], spacing: 16) {
                if let departments = appState.organization?.departments {
                    ForEach(departments) { dept in
                        DepartmentCard(department: dept)
                            .onTapGesture {
                                openWindow(id: "department", value: dept.id)
                            }
                    }
                }
            }
        }
    }

    private var activitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.headline)

            VStack(spacing: 12) {
                ActivityRow(icon: "checkmark.circle.fill", title: "Q4 Budget Approved", color: .green)
                ActivityRow(icon: "person.fill", title: "New Hire: Engineering", color: .blue)
                ActivityRow(icon: "dollarsign.circle.fill", title: "Deal Closed: $500K", color: .green)
            }
        }
    }

    // MARK: - Data Loading

    private func loadDashboardData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let depts = try await services.repository.fetchDepartments()

            // Get KPIs from first department for demo
            if let firstDept = depts.first {
                let fetchedKPIs = try await services.repository.fetchKPIs(for: firstDept.id)
                kpis = fetchedKPIs
            }

            // Track successful load
            await services.analytics.trackScreenView("dashboard")
        } catch is CancellationError {
            // Task was cancelled (e.g., view disappeared), don't show error
            return
        } catch {
            // Show error to user with recovery options
            currentError = ErrorAlertConfig.from(error: error)
            showingErrorAlert = true

            // Track error for monitoring
            await services.analytics.trackEvent(.errorOccurred(error))
        }
    }
}

// MARK: - Supporting Views

struct KPICard: View {
    let kpi: KPI

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(kpi.name)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                Image(systemName: trendIcon)
                    .foregroundStyle(trendColor)
            }

            Text(kpi.value, format: .number)
                .font(.system(size: 36, weight: .medium, design: .rounded))
                .monospacedDigit()

            Text("Target: \(kpi.target, format: .number)")
                .font(.caption)
                .foregroundStyle(.secondary)

            ProgressView(value: kpi.performance)
                .tint(performanceColor)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var trendIcon: String {
        switch kpi.trend.direction {
        case .up: return "arrow.up.right"
        case .down: return "arrow.down.right"
        case .flat: return "arrow.right"
        }
    }

    private var trendColor: Color {
        switch kpi.trend.direction {
        case .up: return .green
        case .down: return .red
        case .flat: return .blue
        }
    }

    private var performanceColor: Color {
        switch kpi.performanceStatus {
        case .exceeding: return .green
        case .onTrack: return .blue
        case .belowTarget: return .orange
        case .critical: return .red
        }
    }
}

struct DepartmentCard: View {
    let department: Department

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: departmentIcon)
                    .foregroundStyle(Color(hex: department.type.defaultColor))

                Text(department.name)
                    .font(.headline)

                Spacer()
            }

            Text("\(department.headcount) employees")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("Budget: \(department.budget.utilizationPercent, specifier: "%.0f")% used")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var departmentIcon: String {
        switch department.type {
        case .engineering: return "wrench.and.screwdriver"
        case .sales: return "chart.line.uptrend.xyaxis"
        case .marketing: return "megaphone"
        case .finance: return "dollarsign.circle"
        case .operations: return "gearshape.2"
        case .hr: return "person.2"
        default: return "building.2"
        }
    }
}

struct ActivityRow: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.title3)

            Text(title)
                .font(.body)

            Spacer()

            Text("Today")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    DashboardView(initializationError: nil)
        .environment(\.appState, AppState())
        .environment(\.services, ServiceContainer())
}
