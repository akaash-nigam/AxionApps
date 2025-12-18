//
//  ErrorStateView.swift
//  Reality Annotation Platform
//
//  Reusable error and empty state views
//

import SwiftUI

// MARK: - Error State View

struct ErrorStateView: View {
    let error: Error
    let title: String?
    let retryAction: (() -> Void)?

    init(
        error: Error,
        title: String? = nil,
        retryAction: (() -> Void)? = nil
    ) {
        self.error = error
        self.title = title
        self.retryAction = retryAction
    }

    var body: some View {
        VStack(spacing: 24) {
            // Error Icon
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.orange)

            // Error Message
            VStack(spacing: 12) {
                Text(title ?? "Something Went Wrong")
                    .font(.title2)
                    .bold()

                Text(errorMessage)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 400)
            }

            // Retry Button
            if let retryAction = retryAction {
                Button {
                    retryAction()
                } label: {
                    Label("Try Again", systemImage: "arrow.clockwise")
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
        .padding(40)
    }

    private var errorMessage: String {
        if let annotationError = error as? AnnotationError {
            return annotationError.userMessage
        } else if let layerError = error as? LayerError {
            return layerError.userMessage
        } else if let syncError = error as? SyncableError {
            return syncError.localizedDescription
        } else {
            return error.localizedDescription
        }
    }
}

// MARK: - Empty State View

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: 24) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundStyle(.blue.gradient)

            // Content
            VStack(spacing: 12) {
                Text(title)
                    .font(.title2)
                    .bold()

                Text(message)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 400)
            }

            // Action Button
            if let actionTitle = actionTitle, let action = action {
                Button {
                    action()
                } label: {
                    Label(actionTitle, systemImage: "plus.circle.fill")
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
        .padding(40)
    }
}

// MARK: - Loading State View

struct LoadingStateView: View {
    let message: String

    init(message: String = "Loading...") {
        self.message = message
    }

    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)

            Text(message)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .padding(40)
    }
}

// MARK: - Error Extensions

extension AnnotationError {
    var userMessage: String {
        switch self {
        case .notFound:
            return "This annotation couldn't be found. It may have been deleted."
        case .emptyContent:
            return "Please enter some content for your annotation."
        case .invalidPosition:
            return "The annotation position is invalid. Try placing it again."
        case .permissionDenied:
            return "You don't have permission to modify this annotation."
        case .syncFailed:
            return "Failed to sync this annotation. Check your internet connection."
        }
    }
}

extension LayerError {
    var userMessage: String {
        switch self {
        case .notFound:
            return "This layer couldn't be found."
        case .nameEmpty:
            return "Please enter a name for your layer."
        case .duplicateName:
            return "A layer with this name already exists."
        case .maxLayersReached:
            return "You've reached the maximum number of layers for your plan."
        case .hasAnnotations:
            return "This layer contains annotations. Please remove them first."
        case .permissionDenied:
            return "You don't have permission to modify this layer."
        }
    }
}

// MARK: - Retry View Modifier

struct RetryViewModifier: ViewModifier {
    @Binding var error: Error?
    let retryAction: () -> Void

    func body(content: Content) -> some View {
        content
            .alert("Error", isPresented: .constant(error != nil)) {
                Button("Dismiss", role: .cancel) {
                    error = nil
                }
                Button("Try Again") {
                    error = nil
                    retryAction()
                }
            } message: {
                if let error = error {
                    Text(error.localizedDescription)
                }
            }
    }
}

extension View {
    func retryOnError(error: Binding<Error?>, retryAction: @escaping () -> Void) -> some View {
        modifier(RetryViewModifier(error: error, retryAction: retryAction))
    }
}

// MARK: - Preview

#Preview("Error State") {
    ErrorStateView(
        error: AnnotationError.emptyContent,
        title: "Failed to Save",
        retryAction: {}
    )
}

#Preview("Empty State") {
    EmptyStateView(
        icon: "note.text",
        title: "No Annotations Yet",
        message: "Create your first annotation by entering AR mode and tapping in space.",
        actionTitle: "Enter AR Mode",
        action: {}
    )
}

#Preview("Loading State") {
    LoadingStateView(message: "Loading annotations...")
}
