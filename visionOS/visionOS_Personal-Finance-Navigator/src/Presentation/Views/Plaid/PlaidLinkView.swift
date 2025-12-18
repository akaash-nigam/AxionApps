// PlaidLinkView.swift
// Personal Finance Navigator
// SwiftUI wrapper for Plaid Link integration

import SwiftUI

/// SwiftUI view that presents Plaid Link for bank connections
struct PlaidLinkView: View {
    @Bindable var linkManager: PlaidLinkManager
    @Environment(\.dismiss) var dismiss

    let onSuccess: (String) -> Void

    var body: some View {
        ZStack {
            if linkManager.isLoading {
                loadingView
            } else if let errorMessage = linkManager.errorMessage {
                errorView(message: errorMessage)
            } else if linkManager.isPresented, let linkToken = linkManager.linkToken {
                // Placeholder for actual Plaid Link integration
                plaidLinkPlaceholder(linkToken: linkToken)
            }
        }
        .navigationTitle("Connect Bank")
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Preparing bank connection...")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial)
    }

    // MARK: - Error View

    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)

            Text("Connection Error")
                .font(.title)
                .fontWeight(.bold)

            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: {
                dismiss()
            }) {
                Text("Close")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial)
    }

    // MARK: - Plaid Link Placeholder

    /// Placeholder UI for Plaid Link
    /// When the actual Plaid SDK is integrated, this will be replaced with the native Plaid Link UI
    private func plaidLinkPlaceholder(linkToken: String) -> some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("Connect Your Bank")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Securely link your bank account with Plaid")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)

            Spacer()

            // Security badges
            VStack(spacing: 16) {
                SecurityBadge(
                    icon: "lock.shield.fill",
                    title: "Bank-Level Encryption",
                    description: "256-bit encryption protects your data"
                )

                SecurityBadge(
                    icon: "eye.slash.fill",
                    title: "Read-Only Access",
                    description: "We can only view, never move money"
                )

                SecurityBadge(
                    icon: "checkmark.seal.fill",
                    title: "Trusted by Millions",
                    description: "Used by thousands of financial apps"
                )
            }
            .padding(.horizontal)

            Spacer()

            // Action buttons
            VStack(spacing: 12) {
                // In production, this would launch the actual Plaid Link SDK
                Button(action: {
                    // Placeholder: Simulate successful connection
                    // In production: Launch Plaid Link with linkToken
                    simulatePlaidConnection()
                }) {
                    HStack {
                        Image(systemName: "link")
                        Text("Connect with Plaid")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button(action: {
                    linkManager.handleExit(error: nil)
                }) {
                    Text("Cancel")
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial)
    }

    // MARK: - Simulation (For Development)

    /// Simulates a successful Plaid connection
    /// In production, this would be replaced with actual Plaid SDK callback
    private func simulatePlaidConnection() {
        // Simulate a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // In production, this would be the real public token from Plaid
            let mockPublicToken = "public-sandbox-\(UUID().uuidString)"

            linkManager.handleSuccess(
                publicToken: mockPublicToken,
                metadata: LinkSuccessMetadata(
                    institutionName: "Sandbox Institution",
                    institutionId: "ins_sandbox",
                    accountIds: [],
                    linkSessionId: nil
                )
            )

            onSuccess(mockPublicToken)
        }
    }
}

// MARK: - Security Badge

struct SecurityBadge: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.blue)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Integration Notes

/*
 PRODUCTION INTEGRATION INSTRUCTIONS:

 1. Install Plaid Link SDK:
    - Add to Package.swift or use CocoaPods
    - Import LinkKit framework

 2. Replace plaidLinkPlaceholder with actual Plaid Link:

    ```swift
    import LinkKit

    struct PlaidLinkView: UIViewControllerRepresentable {
        let linkToken: String
        let onSuccess: (String) -> Void
        let onExit: () -> Void

        func makeUIViewController(context: Context) -> UIViewController {
            let config = LinkTokenConfiguration(
                token: linkToken,
                onSuccess: { publicToken, metadata in
                    onSuccess(publicToken)
                },
                onExit: { error, metadata in
                    onExit()
                }
            )

            let handler = Plaid.create(config)
            let viewController = UIViewController()
            handler.open(presentUsing: .viewController(viewController))
            return viewController
        }

        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    }
    ```

 3. Handle callbacks:
    - onSuccess: Exchange public token for access token via PlaidService
    - onExit: Handle user cancellation
    - onEvent: Track user progress through Link flow

 4. Test in Sandbox mode:
    - Use Plaid sandbox credentials
    - Test various bank connection scenarios
    - Verify transaction syncing

 5. Enable webhooks:
    - Configure webhook URL in Plaid Dashboard
    - Handle webhook events (transactions available, login required, etc.)

 For more information, see: https://plaid.com/docs/link/
 */

// MARK: - Preview

#Preview {
    let linkManager = PlaidLinkManager(
        plaidService: PlaidService(
            apiClient: PlaidAPIClient(clientId: "test", secret: "test"),
            accountRepository: MockAccountRepository(),
            transactionRepository: MockTransactionRepository(),
            keychainManager: KeychainManager()
        )
    )

    return PlaidLinkView(linkManager: linkManager) { publicToken in
        print("Success: \(publicToken)")
    }
}

// MARK: - Mock Repositories (for preview)

class MockAccountRepository: AccountRepository {
    func fetchAll() async throws -> [Account] { [] }
    func fetch(by id: UUID) async throws -> Account? { nil }
    func save(_ account: Account) async throws {}
    func delete(_ account: Account) async throws {}
    func updateBalance(accountId: UUID, newBalance: Decimal) async throws {}
}

class MockTransactionRepository: TransactionRepository {
    func fetchAll() async throws -> [Transaction] { [] }
    func fetch(by id: UUID) async throws -> Transaction? { nil }
    func fetchTransactions(from startDate: Date, to endDate: Date) async throws -> [Transaction] { [] }
    func save(_ transaction: Transaction) async throws {}
    func delete(_ transaction: Transaction) async throws {}
    func search(query: String) async throws -> [Transaction] { [] }
}
