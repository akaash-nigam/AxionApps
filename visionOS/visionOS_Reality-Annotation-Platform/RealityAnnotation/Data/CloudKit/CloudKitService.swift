//
//  CloudKitService.swift
//  Reality Annotation Platform
//
//  CloudKit service for uploading and downloading data
//

import Foundation
import CloudKit

// MARK: - CloudKit Service Protocol

protocol CloudKitService {
    /// Upload record to CloudKit
    func upload<T: Syncable>(_ item: T) async throws -> CKRecord

    /// Fetch changes since date
    func fetchChanges(recordType: String, since: Date?) async throws -> [CloudKitChange]

    /// Delete record
    func delete(_ recordID: CKRecord.ID) async throws

    /// Fetch specific record
    func fetch(_ recordID: CKRecord.ID) async throws -> CKRecord

    /// Upload batch of records
    func uploadBatch<T: Syncable>(_ items: [T]) async throws -> [CKRecord]

    /// Check CloudKit availability
    func checkAccountStatus() async throws -> CKAccountStatus
}

// MARK: - Default CloudKit Service

@MainActor
class DefaultCloudKitService: CloudKitService {
    private let container: CKContainer
    private let database: CKDatabase

    init(containerIdentifier: String? = nil, scope: CKDatabase.Scope = .private) {
        if let identifier = containerIdentifier {
            self.container = CKContainer(identifier: identifier)
        } else {
            self.container = CKContainer.default()
        }
        self.database = container.database(with: scope)
    }

    // MARK: - Account Status

    func checkAccountStatus() async throws -> CKAccountStatus {
        return try await container.accountStatus()
    }

    // MARK: - Upload

    func upload<T: Syncable>(_ item: T) async throws -> CKRecord {
        // Convert to CKRecord
        let record = try item.toCKRecord()

        // Save to CloudKit
        let savedRecord = try await database.save(record)

        print("✅ CloudKit: Uploaded \(savedRecord.recordType) - \(savedRecord.recordID.recordName)")
        return savedRecord
    }

    func uploadBatch<T: Syncable>(_ items: [T]) async throws -> [CKRecord] {
        guard !items.isEmpty else { return [] }

        // Convert to records
        let records = try items.map { try $0.toCKRecord() }

        // CloudKit batch limit: 400 records
        let batches = records.chunked(into: 400)
        var allSavedRecords: [CKRecord] = []

        for batch in batches {
            let operation = CKModifyRecordsOperation(recordsToSave: batch)
            operation.savePolicy = .changedKeys // Only save changed fields
            operation.qualityOfService = .utility

            let savedRecords = try await withCheckedThrowingContinuation { continuation in
                var saved: [CKRecord] = []

                operation.perRecordSaveBlock = { recordID, result in
                    switch result {
                    case .success(let record):
                        saved.append(record)
                    case .failure(let error):
                        print("⚠️ Failed to save record \(recordID): \(error)")
                    }
                }

                operation.modifyRecordsResultBlock = { result in
                    switch result {
                    case .success:
                        continuation.resume(returning: saved)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }

                database.add(operation)
            }

            allSavedRecords.append(contentsOf: savedRecords)
        }

        print("✅ CloudKit: Batch uploaded \(allSavedRecords.count)/\(items.count) records")
        return allSavedRecords
    }

    // MARK: - Download

    func fetchChanges(recordType: String, since: Date?) async throws -> [CloudKitChange] {
        var changes: [CloudKitChange] = []

        // Build query predicate
        let predicate: NSPredicate
        if let since = since {
            predicate = NSPredicate(
                format: "modificationDate > %@",
                since as NSDate
            )
        } else {
            predicate = NSPredicate(value: true) // All records
        }

        let query = CKQuery(recordType: recordType, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "modificationDate", ascending: false)]

        // Use CKQueryOperation for better control
        let operation = CKQueryOperation(query: query)
        operation.resultsLimit = 100 // Fetch in batches
        operation.qualityOfService = .utility

        let fetchedChanges = try await withCheckedThrowingContinuation { continuation in
            var fetchedRecords: [CKRecord] = []

            operation.recordMatchedBlock = { recordID, result in
                switch result {
                case .success(let record):
                    fetchedRecords.append(record)
                case .failure(let error):
                    print("⚠️ Error fetching record \(recordID): \(error)")
                }
            }

            operation.queryResultBlock = { result in
                switch result {
                case .success:
                    continuation.resume(returning: fetchedRecords)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }

            database.add(operation)
        }

        // Categorize changes
        for record in fetchedChanges {
            if let creationDate = record.creationDate,
               since == nil || creationDate > since! {
                changes.append(.created(record))
            } else {
                changes.append(.updated(record))
            }
        }

        print("📥 CloudKit: Fetched \(changes.count) changes")
        return changes
    }

    func fetch(_ recordID: CKRecord.ID) async throws -> CKRecord {
        let record = try await database.record(for: recordID)
        return record
    }

    // MARK: - Delete

    func delete(_ recordID: CKRecord.ID) async throws {
        _ = try await database.deleteRecord(withID: recordID)
        print("🗑️ CloudKit: Deleted \(recordID.recordName)")
    }

    // MARK: - Error Handling

    func handleError(_ error: Error) -> Bool {
        guard let ckError = error as? CKError else {
            return false
        }

        switch ckError.code {
        case .networkUnavailable, .networkFailure:
            print("⚠️ CloudKit: Network unavailable")
            return true // Recoverable - retry later
        case .notAuthenticated:
            print("⚠️ CloudKit: User not signed in")
            return false // Not recoverable
        case .quotaExceeded:
            print("⚠️ CloudKit: Quota exceeded")
            return false // Not recoverable
        case .serverRecordChanged:
            print("⚠️ CloudKit: Conflict detected")
            return true // Recoverable - handle conflict
        default:
            print("⚠️ CloudKit Error: \(ckError.localizedDescription)")
            return false
        }
    }
}
