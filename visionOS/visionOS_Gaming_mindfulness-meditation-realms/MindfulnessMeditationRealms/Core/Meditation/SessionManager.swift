import Foundation
import Combine

/// Manages meditation session lifecycle and state
@MainActor
class SessionManager: ObservableObject {

    // MARK: - Published Properties

    @Published var sessionState: SessionState = .idle
    @Published var currentSession: MeditationSession?
    @Published var elapsedTime: TimeInterval = 0
    @Published var remainingTime: TimeInterval = 0

    // MARK: - Dependencies

    private let biometricMonitor: BiometricMonitor
    private let audioEngine: SpatialAudioEngine
    private let environmentManager: EnvironmentManager

    // MARK: - Private Properties

    private var timer: Timer?
    private var sessionStartDate: Date?
    private var pausedDuration: TimeInterval = 0
    private var lastPauseDate: Date?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(
        biometricMonitor: BiometricMonitor,
        audioEngine: SpatialAudioEngine,
        environmentManager: EnvironmentManager
    ) {
        self.biometricMonitor = biometricMonitor
        self.audioEngine = audioEngine
        self.environmentManager = environmentManager

        setupObservers()
    }

    // MARK: - Public Methods

    /// Start a new meditation session
    func startSession(
        environment: MeditationEnvironment,
        duration: TimeInterval,
        technique: MeditationTechnique = .breathAwareness
    ) async throws -> MeditationSession {

        guard canTransition(to: .preparing) else {
            throw SessionError.invalidStateTransition
        }

        // Create session
        let session = MeditationSession(
            userID: UUID(), // Should come from authenticated user
            environmentID: environment.id,
            technique: technique,
            targetDuration: duration
        )

        currentSession = session
        remainingTime = duration

        // Transition to preparing
        transition(to: .preparing)

        // Load environment
        try await environmentManager.loadEnvironment(environment.id)

        // Start audio
        audioEngine.playAmbience(environment.ambientSoundscape)

        // Calibrate if first session
        if shouldCalibrate() {
            transition(to: .calibrating)
            try await performCalibration()
        }

        // Start active session
        transition(to: .active)
        sessionStartDate = Date()
        startTimer()

        return session
    }

    /// Pause the current session
    func pauseSession() {
        guard canTransition(to: .paused) else { return }

        stopTimer()
        lastPauseDate = Date()
        audioEngine.pause()
        transition(to: .paused)
    }

    /// Resume a paused session
    func resumeSession() {
        guard canTransition(to: .active) else { return }

        if let pauseDate = lastPauseDate {
            pausedDuration += Date().timeIntervalSince(pauseDate)
        }

        startTimer()
        audioEngine.resume()
        transition(to: .active)
    }

    /// End the current session
    func endSession() -> SessionResults {
        guard var session = currentSession else {
            return SessionResults.empty()
        }

        stopTimer()
        transition(to: .completing)

        // Calculate final duration
        if let startDate = sessionStartDate {
            let totalElapsed = Date().timeIntervalSince(startDate) - pausedDuration
            session.complete(with: Date())
            session.duration = totalElapsed
        }

        // Stop audio
        audioEngine.stopAll()

        // Calculate results
        let results = SessionResults(
            session: session,
            completionPercentage: session.completionPercentage,
            stressReduction: session.stressReduction ?? 0,
            calmIncrease: session.calmIncrease ?? 0,
            qualityScore: session.qualityScore
        )

        // Cleanup
        transition(to: .ended)
        reset()

        return results
    }

    /// Get remaining time in session
    func getRemainingTime() -> TimeInterval {
        return remainingTime
    }

    // MARK: - Private Methods

    private func setupObservers() {
        // Observe biometric updates
        biometricMonitor.$currentSnapshot
            .sink { [weak self] snapshot in
                self?.handleBiometricUpdate(snapshot)
            }
            .store(in: &cancellables)
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateElapsedTime()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func updateElapsedTime() {
        guard let startDate = sessionStartDate,
              var session = currentSession else { return }

        let totalElapsed = Date().timeIntervalSince(startDate) - pausedDuration
        elapsedTime = totalElapsed
        remainingTime = max(0, session.targetDuration - totalElapsed)

        session.updateDuration(totalElapsed)
        currentSession = session

        // Check for completion
        if remainingTime <= 0 {
            _ = endSession()
        }
    }

    private func handleBiometricUpdate(_ snapshot: BiometricSnapshot) {
        guard var session = currentSession,
              sessionState == .active else { return }

        session.addBiometricSnapshot(snapshot)
        currentSession = session

        // Could trigger adaptive responses here
    }

    private func shouldCalibrate() -> Bool {
        // Check if user needs calibration
        // For now, skip calibration
        return false
    }

    private func performCalibration() async throws {
        // Perform breathing calibration
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
    }

    private func transition(to newState: SessionState) {
        guard canTransition(to: newState) else {
            print("Cannot transition from \(sessionState) to \(newState)")
            return
        }

        let oldState = sessionState
        sessionState = newState

        print("Session state: \(oldState) → \(newState)")
    }

    private func canTransition(to newState: SessionState) -> Bool {
        return sessionState.canTransitionTo.contains(newState)
    }

    private func reset() {
        currentSession = nil
        elapsedTime = 0
        remainingTime = 0
        sessionStartDate = nil
        pausedDuration = 0
        lastPauseDate = nil
        sessionState = .idle
    }

    // MARK: - Deinit

    deinit {
        stopTimer()
    }
}

// MARK: - Session Results

struct SessionResults {
    let session: MeditationSession
    let completionPercentage: Double
    let stressReduction: Double
    let calmIncrease: Double
    let qualityScore: Double

    static func empty() -> SessionResults {
        let emptySession = MeditationSession(
            userID: UUID(),
            environmentID: "",
            technique: .breathAwareness,
            targetDuration: 0
        )

        return SessionResults(
            session: emptySession,
            completionPercentage: 0,
            stressReduction: 0,
            calmIncrease: 0,
            qualityScore: 0
        )
    }
}

// MARK: - Session Errors

enum SessionError: Error {
    case invalidStateTransition
    case sessionAlreadyActive
    case noActiveSession
    case environmentLoadFailed
}
