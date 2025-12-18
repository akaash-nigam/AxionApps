import Foundation
import LocalAuthentication

// MARK: - Authentication Service
@Observable
final class AuthenticationService {
    // MARK: - State
    var currentUser: User?
    var isAuthenticated: Bool = false
    var isAuthenticating: Bool = false
    var error: Error?

    // MARK: - Initialization
    init() {
        // Auto-login for development
        if Configuration.enableMockData {
            autoLoginMockUser()
        }
    }

    // MARK: - Authentication Methods
    func authenticate(email: String, password: String) async throws {
        isAuthenticating = true
        defer { isAuthenticating = false }

        // Simulate network delay
        try await Task.sleep(for: .seconds(1))

        // Mock authentication
        let user = User(
            id: UUID(),
            employeeId: UUID(),
            email: email,
            firstName: "Sarah",
            lastName: "Johnson",
            role: .hrBusinessPartner,
            permissions: [
                .viewAllEmployees,
                .viewAnalytics,
                .editEmployeeData,
                .viewCompensation
            ]
        )

        currentUser = user
        isAuthenticated = true
    }

    func authenticateWithBiometrics() async throws {
        isAuthenticating = true
        defer { isAuthenticating = false }

        let context = LAContext()
        var authError: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) else {
            throw AuthError.biometricsUnavailable
        }

        let reason = "Authenticate to access Spatial HCM"

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )

            if success {
                // Load user after biometric auth
                autoLoginMockUser()
            }
        } catch {
            throw AuthError.biometricsFailed
        }
    }

    func logout() {
        currentUser = nil
        isAuthenticated = false
    }

    // MARK: - Permission Checking
    func hasPermission(_ permission: Permission) -> Bool {
        guard let user = currentUser else { return false }
        return user.permissions.contains(permission)
    }

    func canViewEmployee(_ employee: Employee) -> Bool {
        guard let user = currentUser else { return false }

        if hasPermission(.viewAllEmployees) {
            return true
        }

        if hasPermission(.viewTeamMembers) {
            // Check if employee is in same team
            return employee.id == user.employeeId
        }

        // Can only view own profile
        return employee.id == user.employeeId
    }

    // MARK: - Private Helpers
    private func autoLoginMockUser() {
        currentUser = User(
            id: UUID(),
            employeeId: UUID(),
            email: "sarah.johnson@company.com",
            firstName: "Sarah",
            lastName: "Johnson",
            role: .hrBusinessPartner,
            permissions: Set(Permission.allCases)
        )
        isAuthenticated = true
    }
}

// MARK: - Auth Error
enum AuthError: Error, LocalizedError {
    case invalidCredentials
    case biometricsUnavailable
    case biometricsFailed
    case networkError
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .biometricsUnavailable:
            return "Biometric authentication is not available on this device"
        case .biometricsFailed:
            return "Biometric authentication failed"
        case .networkError:
            return "Network error during authentication"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

// MARK: - Permission Extension
extension Permission: CaseIterable {
    static var allCases: [Permission] {
        [
            .viewOwnProfile,
            .viewTeamMembers,
            .viewAllEmployees,
            .editEmployeeData,
            .viewCompensation,
            .editCompensation,
            .viewAnalytics,
            .manageOrganization,
            .systemConfiguration
        ]
    }
}
