import Foundation

/// Base protocol for all ECS components
/// Components are pure data containers attached to entities
public protocol Component: Sendable {
    /// The entity this component is attached to
    var entityID: UUID { get }
}

/// Type-erased component for heterogeneous collections
public struct AnyComponent: Sendable {
    private let _component: any Component

    public init(_ component: any Component) {
        self._component = component
    }

    public func `as`<T: Component>(_ type: T.Type) -> T? {
        return _component as? T
    }

    public var entityID: UUID {
        return _component.entityID
    }
}
