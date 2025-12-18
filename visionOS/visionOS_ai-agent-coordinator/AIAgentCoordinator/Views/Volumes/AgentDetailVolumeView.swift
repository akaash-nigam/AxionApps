//
//  AgentDetailVolumeView.swift
//  AIAgentCoordinator
//
//  Created by AI Agent Coordinator on 2025-01-20.
//

import SwiftUI
import RealityKit
import Charts

/// Volumetric 3D detail view for a single agent
/// Shows metrics, connections, and internal state in 3D space
struct AgentDetailVolumeView: View {
    let agent: AIAgent

    @State private var rootEntity = Entity()
    @State private var selectedMetric: MetricType = .cpu
    @State private var metricsHistory: [TimestampedMetrics] = []

    var body: some View {
        VStack(spacing: 0) {
            // Header
            header
                .padding()
                .background(.ultraThinMaterial)

            // 3D Volume Content
            RealityView { content in
                content.add(rootEntity)
                await setupVolumeScene()

            } update: { content in
                Task {
                    await updateMetricsVisualization()
                }
            }
            .frame(depth: 600)

            // Bottom Controls
            controls
                .padding()
                .background(.ultraThinMaterial)
        }
        .onAppear {
            loadMetricsHistory()
        }
    }

    // MARK: - Header

    @ViewBuilder
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                statusIndicator
                    .frame(width: 16, height: 16)

                Text(agent.name)
                    .font(.title2.weight(.semibold))

                Spacer()

                Text(agent.platform.rawValue.uppercased())
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            Text(agent.agentDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var statusIndicator: some View {
        Circle()
            .fill(statusColor)
            .overlay {
                Circle()
                    .stroke(statusColor.opacity(0.3), lineWidth: 3)
                    .scaleEffect(1.5)
            }
    }

    private var statusColor: Color {
        switch agent.status {
        case .active: .green
        case .idle: .gray
        case .error: .red
        case .learning: .yellow
        case .optimizing: .blue
        case .paused: .orange
        case .terminated: .black
        }
    }

    // MARK: - Controls

    @ViewBuilder
    private var controls: some View {
        VStack(spacing: 12) {
            // Metric Selector
            Picker("Metric", selection: $selectedMetric) {
                Text("CPU").tag(MetricType.cpu)
                Text("Memory").tag(MetricType.memory)
                Text("Requests").tag(MetricType.requests)
                Text("Latency").tag(MetricType.latency)
            }
            .pickerStyle(.segmented)

            // Current Value
            if let metrics = agent.currentMetrics {
                currentMetricValue(metrics)
            }

            // Mini Chart
            if !metricsHistory.isEmpty {
                miniChart
                    .frame(height: 60)
            }
        }
    }

    @ViewBuilder
    private func currentMetricValue(_ metrics: AgentMetrics) -> some View {
        HStack {
            Text(selectedMetric.rawValue)
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            Text(formattedValue(for: metrics, metric: selectedMetric))
                .font(.title.monospacedDigit())
                .fontWeight(.semibold)
        }
    }

    @ViewBuilder
    private var miniChart: some View {
        Chart(metricsHistory.suffix(20), id: \.timestamp) { item in
            LineMark(
                x: .value("Time", item.timestamp),
                y: .value("Value", metricValue(from: item.metrics, type: selectedMetric))
            )
            .foregroundStyle(.blue.gradient)
        }
        .chartXAxis(.hidden)
        .chartYAxis {
            AxisMarks(position: .trailing)
        }
    }

    // MARK: - 3D Scene Setup

    @MainActor
    private func setupVolumeScene() async {
        // Create central agent sphere
        let agentSphere = createAgentSphere()
        rootEntity.addChild(agentSphere)

        // Create connection lines
        createConnectionVisualization()

        // Create metric visualization
        createMetricsVisualization()

        // Add ambient light
        let light = DirectionalLight()
        light.light.intensity = 1000
        rootEntity.addChild(light)
    }

    @MainActor
    private func createAgentSphere() -> Entity {
        let entity = Entity()

        // Create sphere mesh
        let mesh = MeshResource.generateSphere(radius: 0.15)

        // Create material based on status
        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: UIColor(statusColor))
        material.roughness = 0.3
        material.metallic = 0.7

        entity.components.set(ModelComponent(mesh: mesh, materials: [material]))
        entity.position = SIMD3(0, 0, 0)

        return entity
    }

    @MainActor
    private func createConnectionVisualization() {
        let angleStep = (2 * Float.pi) / Float(agent.connections.count)

        for (index, connection) in agent.connections.enumerated() {
            let angle = Float(index) * angleStep
            let radius: Float = 0.3

            let position = SIMD3(
                radius * cos(angle),
                0,
                radius * sin(angle)
            )

            // Create connection node
            let node = createConnectionNode(at: position, connection: connection)
            rootEntity.addChild(node)

            // Create line from center to node
            let line = createLine(from: SIMD3(0, 0, 0), to: position)
            rootEntity.addChild(line)
        }
    }

    @MainActor
    private func createConnectionNode(at position: SIMD3<Float>, connection: AgentConnection) -> Entity {
        let entity = Entity()

        let mesh = MeshResource.generateBox(size: 0.03)
        var material = UnlitMaterial()
        material.color = .init(tint: .cyan)

        entity.components.set(ModelComponent(mesh: mesh, materials: [material]))
        entity.position = position

        return entity
    }

    @MainActor
    private func createLine(from start: SIMD3<Float>, to end: SIMD3<Float>) -> Entity {
        let entity = Entity()

        let direction = end - start
        let length = simd_length(direction)
        let midpoint = (start + end) / 2

        let mesh = MeshResource.generateCylinder(height: length, radius: 0.003)
        var material = UnlitMaterial()
        material.color = .init(tint: .white.withAlphaComponent(0.3))

        entity.components.set(ModelComponent(mesh: mesh, materials: [material]))
        entity.position = midpoint

        // Orient cylinder along the line
        let up = SIMD3<Float>(0, 1, 0)
        let normalizedDir = normalize(direction)
        let rotation = simd_quatf(from: up, to: normalizedDir)
        entity.orientation = rotation

        return entity
    }

    @MainActor
    private func createMetricsVisualization() {
        guard let metrics = agent.currentMetrics else { return }

        // Create 3D bar chart above agent
        let barHeight = Float(metrics.cpuUsage) * 0.2
        let bar = createMetricBar(height: barHeight, color: .blue)
        bar.position = SIMD3(0, 0.3, 0)
        rootEntity.addChild(bar)
    }

    @MainActor
    private func createMetricBar(height: Float, color: UIColor) -> Entity {
        let entity = Entity()

        let mesh = MeshResource.generateBox(width: 0.05, height: height, depth: 0.05)
        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: color)

        entity.components.set(ModelComponent(mesh: mesh, materials: [material]))

        return entity
    }

    // MARK: - Updates

    @MainActor
    private func updateMetricsVisualization() async {
        // Update metric bars based on selected metric
        // This would update the 3D visualization in real-time
    }

    // MARK: - Data Loading

    private func loadMetricsHistory() {
        // In production, load actual history from metrics collector
        // For now, generate sample data
        var history: [TimestampedMetrics] = []
        let now = Date()

        for i in 0..<60 {
            let timestamp = now.addingTimeInterval(-Double(60 - i))
            let metrics = AgentMetrics(
                agentId: agent.id,
                timestamp: timestamp,
                requestsPerSecond: Double.random(in: 50...500),
                averageLatency: Double.random(in: 0.010...0.100), // 10-100ms in seconds
                p95Latency: Double.random(in: 0.020...0.150),
                p99Latency: Double.random(in: 0.030...0.200),
                errorRate: Double.random(in: 0...0.05),
                cpuUsage: Double.random(in: 0.3...0.8), // 30-80%
                memoryUsage: Int64.random(in: 1_000_000_000...3_000_000_000), // 1-3GB in bytes
                networkBytesIn: Int64.random(in: 10_000_000...100_000_000),
                networkBytesOut: Int64.random(in: 10_000_000...100_000_000),
                successRate: Double.random(in: 0.95...1.0),
                throughput: Double.random(in: 100...1000),
                healthScore: Double.random(in: 0.8...1.0)
            )

            history.append(TimestampedMetrics(timestamp: timestamp, metrics: metrics))
        }

        metricsHistory = history
    }

    // MARK: - Helpers

    private func formattedValue(for metrics: AgentMetrics, metric: MetricType) -> String {
        let value = metricValue(from: metrics, type: metric)

        switch metric {
        case .cpu:
            return "\(Int(value))%"
        case .memory:
            return "\(Int(value)) MB"
        case .requests:
            return String(format: "%.0f/s", value)
        case .latency:
            return "\(Int(value)) ms"
        case .errorRate:
            return String(format: "%.2f%%", value * 100)
        }
    }

    private func metricValue(from metrics: AgentMetrics, type: MetricType) -> Double {
        switch type {
        case .cpu:
            return metrics.cpuUsage * 100
        case .memory:
            return Double(metrics.memoryUsage) / (1024 * 1024)
        case .requests:
            return metrics.requestsPerSecond
        case .latency:
            return metrics.averageLatency * 1000
        case .errorRate:
            return metrics.errorRate
        }
    }
}

#Preview {
    AgentDetailVolumeView(
        agent: AIAgent(
            name: "Test Agent",
            type: .general,
            platform: .openai,
            status: .active,
            agentDescription: "Test agent for preview",
            endpoint: "https://api.example.com",
            tags: ["test"]
        )
    )
}
