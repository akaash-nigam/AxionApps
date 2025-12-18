import SwiftUI
import SwiftData

struct DashboardView: View {
    // Environment
    @Environment(NavigationState.self) private var navigationState
    @Environment(AlertState.self) private var alertState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow
    @Environment(\.services) private var services

    // Data queries
    @Query private var twins: [DigitalTwin]
    @Query private var predictions: [Prediction]

    // View state
    @State private var loadingState: ViewState<Void> = .idle
    @State private var inlineError: ViewError?
    @State private var isRefreshing = false

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            mainContent
        }
        .navigationTitle("Digital Twin Orchestrator")
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                if isRefreshing {
                    ProgressView()
                        .controlSize(.small)
                }

                Button {
                    openWindow(id: "asset-browser")
                } label: {
                    Label("Assets", systemImage: "square.grid.2x2")
                }

                Button {
                    openWindow(id: "analytics")
                } label: {
                    Label("Analytics", systemImage: "chart.bar")
                }

                Button {
                    Task { await refreshData() }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .disabled(isRefreshing)
            }
        }
        .errorBanner($inlineError)
        .task {
            await initializeData()
        }
    }

    // MARK: - Sidebar

    @ViewBuilder
    private var sidebar: some View {
        @Bindable var navState = navigationState

        List(selection: $navState.selectedTwin) {
            Section("Active Digital Twins") {
                if twins.isEmpty {
                    ContentUnavailableView(
                        "No Digital Twins",
                        systemImage: "gearshape.2",
                        description: Text("Add assets to monitor them")
                    )
                } else {
                    ForEach(twins) { twin in
                        TwinListItem(twin: twin)
                            .tag(twin)
                    }
                }
            }
        }
        .navigationTitle("Twins")
        .overlay {
            if case .loading = loadingState {
                LoadingView("Loading twins...")
            }
        }
    }

    // MARK: - Main Content

    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Connection status banner
                connectionStatusBanner

                // Metrics Overview
                metricsSection

                // Active Predictions
                predictionsSection

                // Recent Alerts
                alertsSection
            }
            .padding()
        }
        .refreshable {
            await refreshData()
        }
    }

    @ViewBuilder
    private var connectionStatusBanner: some View {
        if let networkService = services.networkService, !networkService.isOnline {
            HStack {
                Image(systemName: "wifi.slash")
                Text("Offline Mode - Some features may be unavailable")
                Spacer()
            }
            .font(.caption)
            .padding(12)
            .background(.orange.opacity(0.2), in: RoundedRectangle(cornerRadius: 8))
            .foregroundStyle(.orange)
        }
    }

    private var metricsSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 20) {
            MetricCard(
                title: "Facility Health",
                value: String(format: "%.0f%%", averageHealth),
                systemImage: "heart.fill",
                color: HealthThresholds.color(for: averageHealth)
            )

            MetricCard(
                title: "Active Twins",
                value: "\(twins.count)",
                systemImage: "gearshape.2.fill",
                color: .blue
            )

            MetricCard(
                title: "Critical Alerts",
                value: "\(criticalAlertsCount)",
                systemImage: "exclamationmark.triangle.fill",
                color: criticalAlertsCount > 0 ? .red : .green
            )
        }
    }

    private var predictionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Active Predictions")
                    .font(.title2)
                    .bold()

                Spacer()

                if !predictions.isEmpty {
                    Text("\(predictions.count) total")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if predictions.isEmpty {
                ContentUnavailableView(
                    "No Active Predictions",
                    systemImage: "checkmark.seal.fill",
                    description: Text("All systems are operating normally")
                )
                .frame(minHeight: 200)
            } else {
                ForEach(predictions.sorted(by: { $0.severity.priority > $1.severity.priority }).prefix(5)) { prediction in
                    PredictionCard(prediction: prediction)
                }

                if predictions.count > 5 {
                    Button("View All Predictions") {
                        openWindow(id: "analytics")
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private var alertsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Activity")
                    .font(.title2)
                    .bold()

                Spacer()

                if alertState.unreadCount > 0 {
                    Text("\(alertState.unreadCount) unread")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.red, in: Capsule())
                        .foregroundStyle(.white)
                }
            }

            if alertState.activeAlerts.isEmpty {
                ContentUnavailableView(
                    "No Recent Activity",
                    systemImage: "bell.slash",
                    description: Text("Alerts will appear here")
                )
                .frame(minHeight: 100)
            } else {
                ForEach(alertState.activeAlerts.prefix(5)) { alert in
                    AlertRow(alert: alert)
                }
            }
        }
    }

    // MARK: - Computed Properties

    private var averageHealth: Double {
        guard !twins.isEmpty else { return 0 }
        return twins.map { $0.healthScore }.reduce(0, +) / Double(twins.count)
    }

    private var criticalAlertsCount: Int {
        predictions.filter { $0.severity == .critical }.count
    }

    // MARK: - Methods

    private func initializeData() async {
        loadingState = .loading

        // Load sample data if database is empty
        if twins.isEmpty {
            await loadSampleData()
        }

        loadingState = .loaded(())
    }

    private func refreshData() async {
        isRefreshing = true
        defer { isRefreshing = false }

        do {
            // Attempt to sync with backend if available
            if let twinService = services.digitalTwinService {
                try await twinService.syncAllToBackend()
            }
        } catch {
            inlineError = .network(error) {
                await refreshData()
            }
        }
    }

    @MainActor
    private func loadSampleData() async {
        let sampleTwins = DigitalTwin.sampleTwins()
        for twin in sampleTwins {
            modelContext.insert(twin)

            // Add sample predictions
            if Bool.random() {
                let prediction = Prediction.sample(
                    type: .failure,
                    daysAhead: Int.random(in: 1...30),
                    severity: .critical
                )
                prediction.digitalTwin = twin
                twin.predictions.append(prediction)
                modelContext.insert(prediction)
            }
        }

        do {
            try modelContext.save()
        } catch {
            inlineError = ViewError(
                title: "Save Failed",
                message: "Could not save sample data",
                underlyingError: error
            )
        }
    }
}

// MARK: - Supporting Views

struct TwinListItem: View {
    let twin: DigitalTwin

    var body: some View {
        HStack {
            Image(systemName: twin.assetType.iconName)
                .foregroundStyle(Color(twin.statusColor))

            VStack(alignment: .leading) {
                Text(twin.name)
                    .font(.headline)

                Text(twin.assetType.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(Int(twin.healthScore))%")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let systemImage: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: systemImage)
                    .foregroundStyle(color)
                Spacer()
            }

            Text(value)
                .font(.largeTitle)
                .bold()

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct PredictionCard: View {
    let prediction: Prediction

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: prediction.predictionType.iconName)
                .foregroundStyle(Color(prediction.severityColor))
                .font(.title2)

            VStack(alignment: .leading, spacing: 4) {
                Text(prediction.title)
                    .font(.headline)

                Text(prediction.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                HStack {
                    Label(prediction.timeUntilPredicted, systemImage: "clock")
                    Text("•")
                    Label(prediction.confidencePercentage, systemImage: "chart.bar.fill")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Button("View") {
                // Open prediction detail
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct AlertRow: View {
    let alert: Alert

    var body: some View {
        HStack {
            Image(systemName: "bell.fill")
                .foregroundStyle(.orange)

            Text("Sample Alert")
                .font(.subheadline)

            Spacer()

            Text("Just now")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview("Dashboard") {
    DashboardView()
        .frame(width: 1400, height: 900)
        .glassBackgroundEffect()
}
