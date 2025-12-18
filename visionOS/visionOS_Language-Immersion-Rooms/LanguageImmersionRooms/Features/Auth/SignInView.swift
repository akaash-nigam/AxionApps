//
//  SignInView.swift
//  Language Immersion Rooms
//
//  Sign in with Apple authentication
//

import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @EnvironmentObject var appState: AppState
    @State private var isSigningIn = false

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Logo/Icon
            Text("🌍")
                .font(.system(size: 100))

            // Title
            VStack(spacing: 15) {
                Text("Language Immersion Rooms")
                    .font(.system(size: 48, weight: .bold))

                Text("Sign in to start learning")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Sign in button
            SignInWithAppleButton(
                onRequest: { request in
                    configureRequest(request)
                },
                onCompletion: { result in
                    handleSignInResult(result)
                }
            )
            .signInWithAppleButtonStyle(.white)
            .frame(width: 300, height: 50)
            .cornerRadius(10)
            .disabled(isSigningIn)

            if isSigningIn {
                ProgressView()
                    .padding()
            }

            Spacer()

            // Privacy note
            Text("We respect your privacy. Your data stays on your device.")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 60)
        }
        .padding(60)
    }

    private func configureRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.email, .fullName]
    }

    private func handleSignInResult(_ result: Result<ASAuthorization, Error>) {
        isSigningIn = true

        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                // Create user profile
                let userID = appleIDCredential.user
                let email = appleIDCredential.email ?? "user@example.com"
                let givenName = appleIDCredential.fullName?.givenName ?? "User"

                let user = UserProfile(
                    id: UUID(),
                    username: givenName,
                    email: email,
                    nativeLanguage: .english,
                    targetLanguage: .spanish
                )

                // Sign in
                appState.signIn(user: user)

                print("✅ Sign in successful: \(user.username)")
            }

        case .failure(let error):
            print("❌ Sign in failed: \(error.localizedDescription)")
        }

        isSigningIn = false
    }
}

// MARK: - Preview

#Preview {
    SignInView()
        .environmentObject(AppState())
}
