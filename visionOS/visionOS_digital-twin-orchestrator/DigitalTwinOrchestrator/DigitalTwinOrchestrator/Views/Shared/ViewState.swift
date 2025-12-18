import SwiftUI

// MARK: - View State

/// Represents the loading state of a view
enum ViewState<T> {
    case idle
    case loading
    case loaded(T)
    case error(ViewError)

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var data: T? {
        if case .loaded(let data) = self { return data }
        return nil
    }

    var error: ViewError? {
        if case .error(let error) = self { return error }
        return nil
    }
}

/// Standardized view error with retry capability
struct ViewError: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let underlyingError: Error?
    let retryAction: (() async -> Void)?
    let isRecoverable: Bool

    init(
        title: String,
        message: String,
        underlyingError: Error? = nil,
        isRecoverable: Bool = true,
        retryAction: (() async -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.underlyingError = underlyingError
        self.isRecoverable = isRecoverable
        self.retryAction = retryAction
    }

    static func network(_ error: Error, retryAction: (() async -> Void)? = nil) -> ViewError {
        ViewError(
            title: "Connection Error",
            message: "Unable to connect to the server. Please check your network connection.",
            underlyingError: error,
            isRecoverable: true,
            retryAction: retryAction
        )
    }

    static func loading(_ error: Error, retryAction: (() async -> Void)? = nil) -> ViewError {
        ViewError(
            title: "Loading Failed",
            message: "Failed to load data. Please try again.",
            underlyingError: error,
            isRecoverable: true,
            retryAction: retryAction
        )
    }

    static func notFound(itemType: String) -> ViewError {
        ViewError(
            title: "Not Found",
            message: "The requested \(itemType) could not be found.",
            isRecoverable: false
        )
    }

    static func unauthorized(retryAction: (() async -> Void)? = nil) -> ViewError {
        ViewError(
            title: "Authentication Required",
            message: "Please sign in to access this content.",
            isRecoverable: true,
            retryAction: retryAction
        )
    }
}

// MARK: - Loading View

/// Standard loading view with optional message
struct LoadingView: View {
    let message: String

    init(_ message: String = "Loading...") {
        self.message = message
    }

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Error View

/// Standard error view with retry capability
struct ErrorView: View {
    let error: ViewError
    @State private var isRetrying = false

    var body: some View {
        ContentUnavailableView {
            Label(error.title, systemImage: errorIcon)
        } description: {
            Text(error.message)
        } actions: {
            if error.isRecoverable, let retryAction = error.retryAction {
                Button {
                    Task {
                        isRetrying = true
                        await retryAction()
                        isRetrying = false
                    }
                } label: {
                    if isRetrying {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Label("Try Again", systemImage: "arrow.clockwise")
                    }
                }
                .buttonStyle(.bordered)
                .disabled(isRetrying)
            }
        }
    }

    private var errorIcon: String {
        if error.title.contains("Connection") || error.title.contains("Network") {
            return "wifi.slash"
        } else if error.title.contains("Authentication") {
            return "lock.fill"
        } else if error.title.contains("Not Found") {
            return "magnifyingglass"
        } else {
            return "exclamationmark.triangle.fill"
        }
    }
}

// MARK: - Async Content View

/// A view that handles async loading states automatically
struct AsyncContentView<T, Content: View, LoadingContent: View>: View {
    @Binding var state: ViewState<T>
    let loadingMessage: String
    @ViewBuilder let content: (T) -> Content
    @ViewBuilder let loadingView: () -> LoadingContent

    init(
        state: Binding<ViewState<T>>,
        loadingMessage: String = "Loading...",
        @ViewBuilder content: @escaping (T) -> Content,
        @ViewBuilder loadingView: @escaping () -> LoadingContent = { LoadingView() }
    ) {
        self._state = state
        self.loadingMessage = loadingMessage
        self.content = content
        self.loadingView = loadingView
    }

    var body: some View {
        switch state {
        case .idle:
            Color.clear

        case .loading:
            loadingView()

        case .loaded(let data):
            content(data)

        case .error(let error):
            ErrorView(error: error)
        }
    }
}

// Default loading view when not specified
extension AsyncContentView where LoadingContent == LoadingView {
    init(
        state: Binding<ViewState<T>>,
        loadingMessage: String = "Loading...",
        @ViewBuilder content: @escaping (T) -> Content
    ) {
        self._state = state
        self.loadingMessage = loadingMessage
        self.content = content
        self.loadingView = { LoadingView(loadingMessage) }
    }
}

// MARK: - Inline Error Banner

/// A dismissible error banner for non-fatal errors
struct ErrorBanner: View {
    let error: ViewError
    let onDismiss: () -> Void
    @State private var isRetrying = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 2) {
                Text(error.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(error.message)
                    .font(.caption)
                    .opacity(0.9)
            }
            .foregroundStyle(.white)

            Spacer()

            if error.isRecoverable, let retryAction = error.retryAction {
                Button {
                    Task {
                        isRetrying = true
                        await retryAction()
                        isRetrying = false
                    }
                } label: {
                    if isRetrying {
                        ProgressView()
                            .controlSize(.small)
                            .tint(.white)
                    } else {
                        Text("Retry")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
                .buttonStyle(.bordered)
                .tint(.white)
                .disabled(isRetrying)
            }

            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.caption)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white.opacity(0.8))
        }
        .padding()
        .background(.red.gradient, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Toast Notification

/// A toast notification for brief messages
struct ToastView: View {
    enum ToastType {
        case success
        case error
        case warning
        case info

        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .info: return "info.circle.fill"
            }
        }

        var color: Color {
            switch self {
            case .success: return .green
            case .error: return .red
            case .warning: return .orange
            case .info: return .blue
            }
        }
    }

    let message: String
    let type: ToastType

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: type.icon)
                .foregroundStyle(type.color)

            Text(message)
                .font(.subheadline)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.regularMaterial, in: Capsule())
    }
}

// MARK: - View Modifier for Error Handling

struct ErrorHandlingModifier: ViewModifier {
    @Binding var error: ViewError?
    let position: VerticalAlignment

    func body(content: Content) -> some View {
        ZStack(alignment: position == .top ? .top : .bottom) {
            content

            if let error = error {
                ErrorBanner(error: error) {
                    self.error = nil
                }
                .padding()
                .transition(.move(edge: position == .top ? .top : .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.3), value: error?.id)
    }
}

extension View {
    /// Adds an error banner overlay to the view
    func errorBanner(_ error: Binding<ViewError?>, position: VerticalAlignment = .top) -> some View {
        modifier(ErrorHandlingModifier(error: error, position: position))
    }
}

// MARK: - Preview

#Preview("Loading View") {
    LoadingView("Loading digital twins...")
}

#Preview("Error View") {
    ErrorView(error: .network(NSError(domain: "", code: -1)))
}

#Preview("Toast") {
    VStack(spacing: 20) {
        ToastView(message: "Changes saved successfully", type: .success)
        ToastView(message: "Failed to sync", type: .error)
        ToastView(message: "Low battery", type: .warning)
        ToastView(message: "New update available", type: .info)
    }
    .padding()
}
