//
//  Syncable.swift
//  Reality Annotation Platform
//
//  Protocol for models that can sync with CloudKit
//

import Foundation
import CloudKit

// MARK: - Syncable Protocol

protocol Syncable: Identifiable {
    /// Convert model to CloudKit record
    func toCKRecord() throws -> CKRecord

    /// Update model from CloudKit record
    mutating func updateFrom(record: CKRecord) throws

    /// CloudKit record type name
    static var recordType: String { get }

    /// Sync metadata
    var isPendingSync: Bool { get set }
    var lastSyncedAt: Date? { get set }
    var updatedAt: Date { get set }
}

// MARK: - Syncable Errors

enum SyncableError: Error {
    case invalidRecordType
    case missingRequiredField(String)
    case conversionFailed(String)
    case recordNotFound

    var localizedDescription: String {
        switch self {
        case .invalidRecordType:
            return "Invalid CloudKit record type"
        case .missingRequiredField(let field):
            return "Missing required field: \(field)"
        case .conversionFailed(let message):
            return "Conversion failed: \(message)"
        case .recordNotFound:
            return "CloudKit record not found"
        }
    }
}

// MARK: - CloudKit Change

enum CloudKitChange {
    case created(CKRecord)
    case updated(CKRecord)
    case deleted(CKRecord.ID)
}

// MARK: - CloudKit Extensions

extension CKRecord {
    /// Helper to safely get string value
    func getString(_ key: String) -> String? {
        return self[key] as? String
    }

    /// Helper to safely get int value
    func getInt(_ key: String) -> Int? {
        return self[key] as? Int
    }

    /// Helper to safely get double value
    func getDouble(_ key: String) -> Double? {
        return self[key] as? Double
    }

    /// Helper to safely get date value
    func getDate(_ key: String) -> Date? {
        return self[key] as? Date
    }

    /// Helper to safely get bool value
    func getBool(_ key: String) -> Bool? {
        return self[key] as? Bool
    }

    /// Helper to safely get data value
    func getData(_ key: String) -> Data? {
        return self[key] as? Data
    }
}

// MARK: - Array Extensions

extension Array {
    /// Split array into chunks
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
