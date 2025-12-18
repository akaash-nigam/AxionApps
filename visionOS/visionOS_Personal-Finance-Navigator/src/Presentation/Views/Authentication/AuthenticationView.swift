// AuthenticationView.swift
// Personal Finance Navigator
// Biometric authentication screen

import SwiftUI
import LocalAuthentication

struct AuthenticationView: View {
    // MARK: - Properties
    let sessionManager: SessionManager

    @State private var isAuthenticating = false
    @State private var errorMessage: String?
    @State private var showError = false

    // MARK: - Body
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // App icon/logo
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue.gradient)
                    .symbolEffect(.pulse)

                // Title
                VStack(spacing: 12) {
                    Text("Personal Finance Navigator")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Your financial data is protected")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Authentication button
                if isAuthenticating {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.blue)
                } else {
                    VStack(spacing: 20) {
                        Button {
                            Task {
                                await authenticate()
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: biometricIcon)
                                    .font(.title3)

                                Text("Unlock with Biometrics")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue.gradient)
                            .foregroundStyle(.white)
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)

                        // Alternative: Use passcode
                        Button {
                            Task {
                                await authenticateWithPasscode()
                            }
                        } label: {
                            Text("Use Passcode")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Spacer()

                // Privacy notice
                Text("This app uses biometric authentication to protect your financial data. Your biometric information is stored securely on your device and never shared.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .padding()
        }
        .alert("Authentication Failed", isPresented: $showError) {
            Button("Try Again") {
                Task {
                    await authenticate()
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            if let errorMessage {
                Text(errorMessage)
            }
        }
        .task {
            // Automatically attempt authentication when view appears
            await authenticate()
        }
    }

    // MARK: - Private Methods
    private func authenticate() async {
        isAuthenticating = true
        errorMessage = nil

        do {
            try await sessionManager.authenticate()

            // Success
            await MainActor.run {
                isAuthenticating = false
            }
        } catch {
            await MainActor.run {
                isAuthenticating = false
                handleAuthenticationError(error)
            }
        }
    }

    private func authenticateWithPasscode() async {
        // BiometricAuthManager will automatically fall back to passcode
        await authenticate()
    }

    private func handleAuthenticationError(_ error: Error) {
        if let authError = error as? BiometricAuthManager.AuthenticationError {
            switch authError {
            case .userCancelled:
                // User cancelled, don't show error
                break

            case .biometryLockout:
                errorMessage = "Too many failed attempts. Please wait before trying again."
                showError = true

            case .notAvailable:
                errorMessage = "Biometric authentication is not available. Please enable Face ID in Settings."
                showError = true

            case .passcodeNotSet:
                errorMessage = "Please set up a device passcode to use this app."
                showError = true

            case .failed(let underlyingError):
                errorMessage = underlyingError.localizedDescription
                showError = true
            }
        } else {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    private var biometricIcon: String {
        // For visionOS, default to face/optic ID icon
        return "faceid"
    }
}

// MARK: - Preview
#Preview {
    AuthenticationView(sessionManager: SessionManager())
}
