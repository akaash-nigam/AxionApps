//
//  Extensions.swift
//  AIAgentCoordinator
//
//  Created by AI Agent Coordinator on 2025-01-20.
//

import Foundation
import simd

// MARK: - Date Extensions

extension Date {
    /// Relative time string (e.g., "2 minutes ago")
    var relativeTimeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    /// Short date string
    var shortDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}

// MARK: - Double Extensions

extension Double {
    /// Format as percentage string
    var percentageString: String {
        String(format: "%.1f%%", self * 100)
    }

    /// Format as memory size (KB, MB, GB)
    var memoryString: String {
        let bytes = self
        if bytes < 1024 {
            return String(format: "%.0f B", bytes)
        } else if bytes < 1024 * 1024 {
            return String(format: "%.1f KB", bytes / 1024)
        } else if bytes < 1024 * 1024 * 1024 {
            return String(format: "%.1f MB", bytes / (1024 * 1024))
        } else {
            return String(format: "%.2f GB", bytes / (1024 * 1024 * 1024))
        }
    }
}

// MARK: - SIMD Extensions

extension SIMD3 where Scalar == Float {
    /// Distance between two points
    func distance(to other: SIMD3<Float>) -> Float {
        simd_distance(self, other)
    }

    /// Linear interpolation
    func lerp(to other: SIMD3<Float>, t: Float) -> SIMD3<Float> {
        self + (other - self) * t
    }

    /// Check if vector is approximately equal to another
    func isApproximatelyEqual(to other: SIMD3<Float>, tolerance: Float = 0.0001) -> Bool {
        distance(to: other) < tolerance
    }
}

// MARK: - Collection Extensions

extension Collection {
    /// Safe subscript access
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

extension Array {
    /// Chunk array into groups of size
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

// MARK: - UUID Extensions

extension UUID {
    /// Short string representation (first 8 characters)
    var shortString: String {
        String(uuidString.prefix(8))
    }
}

// MARK: - String Extensions

extension String {
    /// Truncate string to length
    func truncated(to length: Int, trailing: String = "...") -> String {
        if count > length {
            return String(prefix(length)) + trailing
        }
        return self
    }

    /// Validate email format
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }

    /// Validate URL format
    var isValidURL: Bool {
        URL(string: self) != nil
    }
}
