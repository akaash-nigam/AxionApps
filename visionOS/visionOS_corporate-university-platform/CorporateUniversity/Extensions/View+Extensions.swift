//
//  View+Extensions.swift
//  CorporateUniversity
//
//  Utility view modifiers for consistent styling and common UI patterns
//

import SwiftUI

extension View {
    // MARK: - Glass Effects

    /// Apply glass card styling with material background
    func glassCard(cornerRadius: CGFloat = 16, padding: CGFloat = 20) -> some View {
        self
            .padding(padding)
            .background(.regularMaterial)
            .cornerRadius(cornerRadius)
    }

    /// Apply glass card with shadow
    func glassCardWithShadow(cornerRadius: CGFloat = 16, padding: CGFloat = 20, shadowRadius: CGFloat = 8) -> some View {
        self
            .padding(padding)
            .background(.regularMaterial)
            .cornerRadius(cornerRadius)
            .shadow(color: .black.opacity(0.1), radius: shadowRadius, x: 0, y: 4)
    }

    // MARK: - Buttons

    /// Primary button style
    func primaryButton(backgroundColor: Color = .blue, foregroundColor: Color = .white) -> some View {
        self
            .font(.headline)
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(backgroundColor)
            .cornerRadius(12)
    }

    /// Secondary button style
    func secondaryButton(borderColor: Color = .blue, foregroundColor: Color = .blue) -> some View {
        self
            .font(.headline)
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 2)
            )
    }

    /// Pill button style
    func pillButton(backgroundColor: Color = .blue, foregroundColor: Color = .white) -> some View {
        self
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(backgroundColor)
            .cornerRadius(20)
    }

    // MARK: - Loading States

    /// Show loading overlay with progress indicator
    func loadingOverlay(isLoading: Bool, message: String? = nil) -> some View {
        ZStack {
            self

            if isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)

                    if let message = message {
                        Text(message)
                            .foregroundStyle(.white)
                            .font(.subheadline)
                    }
                }
                .padding(32)
                .background(.regularMaterial)
                .cornerRadius(16)
            }
        }
    }

    /// Skeleton loading effect
    func skeleton(isLoading: Bool, animation: Animation = .easeInOut(duration: 1.5).repeatForever(autoreverses: true)) -> some View {
        self
            .redacted(reason: isLoading ? .placeholder : [])
            .overlay(
                Group {
                    if isLoading {
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.3), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .animation(animation, value: isLoading)
                    }
                }
            )
    }

    // MARK: - Conditional Modifiers

    /// Apply modifier conditionally
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Apply modifier if value is not nil
    @ViewBuilder
    func ifLet<Value, Transform: View>(_ value: Value?, transform: (Self, Value) -> Transform) -> some View {
        if let value = value {
            transform(self, value)
        } else {
            self
        }
    }

    // MARK: - Badges

    /// Add badge overlay (e.g., notification count)
    func badge(_ count: Int, color: Color = .red, position: BadgePosition = .topTrailing) -> some View {
        self
            .overlay(
                Group {
                    if count > 0 {
                        Text("\(min(count, 99))\(count > 99 ? "+" : "")")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(4)
                            .background(color)
                            .clipShape(Circle())
                            .offset(
                                x: position.xOffset,
                                y: position.yOffset
                            )
                    }
                },
                alignment: position.alignment
            )
    }

    /// Add text badge
    func badge(_ text: String, color: Color = .red, position: BadgePosition = .topTrailing) -> some View {
        self
            .overlay(
                Text(text)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(color)
                    .cornerRadius(8)
                    .offset(
                        x: position.xOffset,
                        y: position.yOffset
                    ),
                alignment: position.alignment
            )
    }

    // MARK: - Cards and Containers

    /// Standard card container
    func card(padding: CGFloat = 16, backgroundColor: Color = .secondary.opacity(0.1), cornerRadius: CGFloat = 12) -> some View {
        self
            .padding(padding)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
    }

    /// Bordered container
    func bordered(color: Color = .gray, width: CGFloat = 1, cornerRadius: CGFloat = 8) -> some View {
        self
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(color, lineWidth: width)
            )
    }

    // MARK: - Animations

    /// Shake animation
    func shake(isShaking: Bool) -> some View {
        self
            .modifier(ShakeEffect(shakes: isShaking ? 3 : 0))
    }

    /// Pulse animation
    func pulse(isPulsing: Bool, scale: CGFloat = 1.05) -> some View {
        self
            .scaleEffect(isPulsing ? scale : 1.0)
            .animation(
                isPulsing ? .easeInOut(duration: 1.0).repeatForever(autoreverses: true) : .default,
                value: isPulsing
            )
    }

    /// Shimmer effect
    func shimmer(isShimmering: Bool) -> some View {
        self
            .modifier(ShimmerEffect(isShimmering: isShimmering))
    }

    // MARK: - Empty States

    /// Show empty state view when condition is met
    @ViewBuilder
    func emptyState(_ isEmpty: Bool, @ViewBuilder emptyContent: () -> some View) -> some View {
        if isEmpty {
            emptyContent()
        } else {
            self
        }
    }

    // MARK: - Error States

    /// Show error banner
    func errorBanner(error: String?, isPresented: Binding<Bool>) -> some View {
        ZStack(alignment: .top) {
            self

            if isPresented.wrappedValue, let error = error {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.white)

                    Text(error)
                        .foregroundStyle(.white)
                        .font(.subheadline)

                    Spacer()

                    Button {
                        isPresented.wrappedValue = false
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.white)
                    }
                }
                .padding()
                .background(Color.red)
                .cornerRadius(12)
                .padding()
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    // MARK: - Haptics

    /// Trigger haptic feedback on tap
    /// Note: Haptic feedback is not available on visionOS
    func hapticFeedback() -> some View {
        self
    }

    // MARK: - Navigation

    /// Hidden navigation bar
    func hideNavigationBar() -> some View {
        self
            .navigationBarHidden(true)
            .navigationBarTitle("", displayMode: .inline)
    }

    // MARK: - Readability

    /// Apply reading width for better text readability
    func readableWidth(maxWidth: CGFloat = 700) -> some View {
        self
            .frame(maxWidth: maxWidth)
    }

    // MARK: - Accessibility

    /// Add accessibility label and hint
    func accessible(label: String, hint: String? = nil, traits: AccessibilityTraits = []) -> some View {
        self
            .accessibilityLabel(label)
            .if(hint != nil) { view in
                view.accessibilityHint(hint!)
            }
            .accessibilityAddTraits(traits)
    }

    // MARK: - Debugging

    /// Print view size for debugging
    func printSize() -> some View {
        self
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            print("View size: \(geometry.size)")
                        }
                }
            )
    }

    /// Add colored border for debugging layout
    func debugBorder(_ color: Color = .red, width: CGFloat = 2) -> some View {
        self
            .border(color, width: width)
    }
}

// MARK: - Supporting Types

enum BadgePosition {
    case topLeading
    case topTrailing
    case bottomLeading
    case bottomTrailing

    var alignment: Alignment {
        switch self {
        case .topLeading: return .topLeading
        case .topTrailing: return .topTrailing
        case .bottomLeading: return .bottomLeading
        case .bottomTrailing: return .bottomTrailing
        }
    }

    var xOffset: CGFloat {
        switch self {
        case .topLeading, .bottomLeading: return -8
        case .topTrailing, .bottomTrailing: return 8
        }
    }

    var yOffset: CGFloat {
        switch self {
        case .topLeading, .topTrailing: return -8
        case .bottomLeading, .bottomTrailing: return 8
        }
    }
}

// MARK: - Effect Modifiers

struct ShakeEffect: GeometryEffect {
    var shakes: CGFloat

    var animatableData: CGFloat {
        get { shakes }
        set { shakes = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(translationX: 10 * sin(shakes * .pi * 2), y: 0)
        )
    }
}

struct ShimmerEffect: ViewModifier {
    var isShimmering: Bool
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if isShimmering {
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.5), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .offset(x: phase)
                        .onAppear {
                            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                                phase = 300
                            }
                        }
                    }
                }
            )
            .mask(content)
    }
}

// MARK: - visionOS Specific Extensions

#if os(visionOS)
extension View {
    /// Apply ornament with standard positioning
    func standardOrnament<Content: View>(
        visibility: Visibility = .visible,
        @ViewBuilder content: () -> Content
    ) -> some View {
        self
            .ornament(
                visibility: visibility,
                attachmentAnchor: .scene(.bottom)
            ) {
                content()
            }
    }

    /// Apply hover effect for spatial interaction
    func spatialHover() -> some View {
        self
            .hoverEffect()
    }
}
#endif
