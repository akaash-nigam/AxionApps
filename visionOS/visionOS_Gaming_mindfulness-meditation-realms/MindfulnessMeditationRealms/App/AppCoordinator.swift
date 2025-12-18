import SwiftUI
import Combine

/// Central coordinator managing app-wide state and navigation
@MainActor
class AppCoordinator: ObservableObject {

    // MARK: - Published Properties

    @Published var currentView: AppView = .mainMenu
    @Published var isImmersiveSpaceActive = false
    @Published var currentSession: MeditationSession?
    @Published var userProfile: UserProfile?

    // MARK: - Core Managers

    let sessionManager: SessionManager
    let biometricMonitor: BiometricMonitor
    let environmentManager: EnvironmentManager
    let audioEngine: SpatialAudioEngine
    let progressTracker: ProgressTracker
    let persistenceManager: PersistenceManager

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init() {
        // Initialize core managers
        self.biometricMonitor = BiometricMonitor()
        self.audioEngine = SpatialAudioEngine()
        self.persistenceManager = PersistenceManager()
        self.environmentManager = EnvironmentManager()
        self.progressTracker = ProgressTracker(persistence: persistenceManager)
        self.sessionManager = SessionManager(
            biometricMonitor: biometricMonitor,
            audioEngine: audioEngine,
            environmentManager: environmentManager
        )

        setupObservers()
        loadUserProfile()
    }

    // MARK: - Navigation

    enum AppView {
        case mainMenu
        case environmentSelection
        case meditationSession
        case progress
        case settings
    }

    func navigateTo(_ view: AppView) {
        currentView = view
    }

    func startMeditationSession(environment: MeditationEnvironment, duration: TimeInterval) async {
        do {
            // Start biometric monitoring
            await biometricMonitor.startMonitoring()

            // Start session
            let session = try await sessionManager.startSession(
                environment: environment,
                duration: duration
            )

            currentSession = session
            navigateTo(.meditationSession)
        } catch {
            print("Failed to start meditation session: \(error)")
        }
    }

    func endCurrentSession() {
        guard let session = currentSession else { return }

        let results = sessionManager.endSession()

        // Save session
        Task {
            do {
                try await persistenceManager.saveSession(session)
                try await progressTracker.recordSession(session)
            } catch {
                print("Failed to save session: \(error)")
            }
        }

        // Stop biometric monitoring
        Task {
            await biometricMonitor.stopMonitoring()
        }

        currentSession = nil
        navigateTo(.mainMenu)
    }

    func toggleImmersiveSpace() async {
        isImmersiveSpaceActive.toggle()
    }

    // MARK: - Private Methods

    private func setupObservers() {
        // Observe session state changes
        sessionManager.$sessionState
            .sink { [weak self] state in
                self?.handleSessionStateChange(state)
            }
            .store(in: &cancellables)
    }

    private func handleSessionStateChange(_ state: SessionState) {
        switch state {
        case .ended:
            endCurrentSession()
        default:
            break
        }
    }

    private func loadUserProfile() {
        Task {
            do {
                self.userProfile = try await persistenceManager.loadUserProfile()
            } catch {
                // Create new user profile
                self.userProfile = UserProfile.createNew()
                try? await persistenceManager.saveUserProfile(userProfile!)
            }
        }
    }
}
