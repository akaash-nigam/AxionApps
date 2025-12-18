//
//  CircularBuffer.swift
//  AIAgentCoordinator
//
//  Efficient circular buffer implementation for fixed-size collections
//  Provides O(1) insertion and removal at both ends
//  Created by AI Agent Coordinator on 2025-01-20.
//

import Foundation

/// A fixed-size circular buffer that efficiently manages a sliding window of elements
/// When the buffer is full, new elements automatically overwrite the oldest elements
struct CircularBuffer<Element>: Sendable where Element: Sendable {

    // MARK: - Properties

    /// Internal storage array
    private var storage: [Element?]

    /// Index of the head (oldest element)
    private var headIndex: Int = 0

    /// Index of the tail (next write position)
    private var tailIndex: Int = 0

    /// Current number of elements in the buffer
    private(set) var count: Int = 0

    /// Maximum capacity of the buffer
    let capacity: Int

    /// Whether the buffer is empty
    var isEmpty: Bool { count == 0 }

    /// Whether the buffer is full
    var isFull: Bool { count == capacity }

    // MARK: - Initialization

    /// Initialize a circular buffer with the specified capacity
    /// - Parameter capacity: Maximum number of elements the buffer can hold
    init(capacity: Int) {
        precondition(capacity > 0, "Capacity must be greater than 0")
        self.capacity = capacity
        self.storage = Array(repeating: nil, count: capacity)
    }

    // MARK: - Element Access

    /// Access element at the given index (0 = oldest element)
    /// Returns nil if index is out of bounds
    func element(at index: Int) -> Element? {
        guard index >= 0 && index < count else { return nil }
        let actualIndex = (headIndex + index) % capacity
        return storage[actualIndex]
    }

    /// The oldest element in the buffer
    var first: Element? {
        isEmpty ? nil : storage[headIndex]
    }

    /// The newest element in the buffer
    var last: Element? {
        guard !isEmpty else { return nil }
        let lastIndex = (tailIndex - 1 + capacity) % capacity
        return storage[lastIndex]
    }

    // MARK: - Modification

    /// Append an element to the buffer
    /// If the buffer is full, the oldest element is overwritten
    /// - Parameter element: Element to append
    /// - Returns: The element that was overwritten (if any)
    @discardableResult
    mutating func append(_ element: Element) -> Element? {
        let overwritten = isFull ? storage[tailIndex] : nil

        storage[tailIndex] = element
        tailIndex = (tailIndex + 1) % capacity

        if isFull {
            // Move head forward when overwriting
            headIndex = (headIndex + 1) % capacity
        } else {
            count += 1
        }

        return overwritten
    }

    /// Remove and return the oldest element
    /// - Returns: The removed element, or nil if empty
    @discardableResult
    mutating func removeFirst() -> Element? {
        guard !isEmpty else { return nil }

        let element = storage[headIndex]
        storage[headIndex] = nil
        headIndex = (headIndex + 1) % capacity
        count -= 1

        return element
    }

    /// Remove all elements from the buffer
    mutating func removeAll() {
        storage = Array(repeating: nil, count: capacity)
        headIndex = 0
        tailIndex = 0
        count = 0
    }

    // MARK: - Collection Access

    /// Return all elements as an array (oldest first)
    func toArray() -> [Element] {
        var result: [Element] = []
        result.reserveCapacity(count)

        for i in 0..<count {
            let index = (headIndex + i) % capacity
            if let element = storage[index] {
                result.append(element)
            }
        }

        return result
    }

    /// Return elements within a time range (for timestamped elements)
    func elements<T: Comparable>(where keyPath: KeyPath<Element, T>, greaterThanOrEqualTo minValue: T) -> [Element] {
        var result: [Element] = []

        for i in 0..<count {
            let index = (headIndex + i) % capacity
            if let element = storage[index], element[keyPath: keyPath] >= minValue {
                result.append(element)
            }
        }

        return result
    }

}

// MARK: - Sequence Conformance

extension CircularBuffer: Sequence {
    func makeIterator() -> CircularBufferIterator<Element> {
        CircularBufferIterator(buffer: self)
    }
}

struct CircularBufferIterator<Element>: IteratorProtocol where Element: Sendable {
    private let buffer: CircularBuffer<Element>
    private var currentIndex: Int = 0

    init(buffer: CircularBuffer<Element>) {
        self.buffer = buffer
    }

    mutating func next() -> Element? {
        guard currentIndex < buffer.count else { return nil }
        defer { currentIndex += 1 }
        return buffer.element(at: currentIndex)
    }
}

// MARK: - Collection Conformance

extension CircularBuffer: Collection {
    typealias Index = Int

    var startIndex: Int { 0 }
    var endIndex: Int { count }

    // Collection-conforming subscript must return non-optional
    subscript(position: Int) -> Element {
        precondition(position >= 0 && position < count, "Index out of bounds")
        let actualIndex = (headIndex + position) % capacity
        return storage[actualIndex]!
    }

    func index(after i: Int) -> Int {
        i + 1
    }
}

// MARK: - Codable Support

extension CircularBuffer: Codable where Element: Codable {
    enum CodingKeys: String, CodingKey {
        case elements
        case capacity
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let capacity = try container.decode(Int.self, forKey: .capacity)
        let elements = try container.decode([Element].self, forKey: .elements)

        self.init(capacity: capacity)
        for element in elements {
            self.append(element)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(capacity, forKey: .capacity)
        try container.encode(toArray(), forKey: .elements)
    }
}

// MARK: - Equatable Support

extension CircularBuffer: Equatable where Element: Equatable {
    static func == (lhs: CircularBuffer<Element>, rhs: CircularBuffer<Element>) -> Bool {
        guard lhs.count == rhs.count && lhs.capacity == rhs.capacity else {
            return false
        }
        return lhs.toArray() == rhs.toArray()
    }
}
