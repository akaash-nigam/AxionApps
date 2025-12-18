import Foundation

/// Protocol for energy monitoring service integration
protocol EnergyServiceProtocol: Actor {
    /// Connect to energy meter API
    func connect(apiIdentifier: String) async throws

    /// Disconnect from energy meter
    func disconnect() async

    /// Check if currently connected
    func isConnected() async -> Bool

    /// Start real-time monitoring
    func startMonitoring() async throws

    /// Stop real-time monitoring
    func stopMonitoring() async

    /// Get current energy reading
    func getCurrentReading(type: EnergyType) async throws -> EnergyReading

    /// Get historical readings for a time range
    func getHistoricalReadings(
        type: EnergyType,
        startDate: Date,
        endDate: Date
    ) async throws -> [EnergyReading]

    /// Set handler for real-time updates
    func setUpdateHandler(_ handler: @escaping (EnergyReading) -> Void) async

    /// Detect anomalies based on usage patterns
    func detectAnomalies(
        readings: [EnergyReading],
        configuration: EnergyConfiguration
    ) async throws -> [EnergyAnomaly]
}
