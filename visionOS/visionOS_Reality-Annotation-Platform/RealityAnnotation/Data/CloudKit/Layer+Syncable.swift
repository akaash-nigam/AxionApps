//
//  Layer+Syncable.swift
//  Reality Annotation Platform
//
//  CloudKit sync support for Layer model
//

import Foundation
import CloudKit

// MARK: - Layer Syncable Conformance

extension Layer: Syncable {
    static var recordType: String {
        return "Layer"
    }

    func toCKRecord() throws -> CKRecord {
        let recordID = CKRecord.ID(recordName: id.uuidString)
        let record = CKRecord(recordType: Self.recordType, recordID: recordID)

        // Basic fields
        record["name"] = name
        record["icon"] = icon
        record["colorHex"] = colorHex

        // Owner
        record["ownerID"] = ownerID

        // Parent layer (optional)
        if let parent = parentLayerID {
            record["parentLayerID"] = parent.uuidString
        }

        // Display order
        record["displayOrder"] = displayOrder as CKRecordValue

        // Visibility
        record["isVisible"] = isVisible as CKRecordValue

        // Timestamps
        record["createdAt"] = createdAt as CKRecordValue
        record["updatedAt"] = updatedAt as CKRecordValue

        // Sync metadata
        record["isPendingSync"] = isPendingSync as CKRecordValue
        record["lastSyncedAt"] = lastSyncedAt as CKRecordValue?

        // Soft delete
        record["isDeleted"] = isDeleted as CKRecordValue

        return record
    }

    mutating func updateFrom(record: CKRecord) throws {
        // Validate record type
        guard record.recordType == Self.recordType else {
            throw SyncableError.invalidRecordType
        }

        // Basic fields
        guard let layerName = record.getString("name") else {
            throw SyncableError.missingRequiredField("name")
        }
        self.name = layerName

        guard let layerIcon = record.getString("icon") else {
            throw SyncableError.missingRequiredField("icon")
        }
        self.icon = layerIcon

        guard let layerColorHex = record.getString("colorHex") else {
            throw SyncableError.missingRequiredField("colorHex")
        }
        self.colorHex = layerColorHex

        // Owner
        guard let owner = record.getString("ownerID") else {
            throw SyncableError.missingRequiredField("ownerID")
        }
        self.ownerID = owner

        // Parent layer (optional)
        if let parentIDString = record.getString("parentLayerID"),
           let parentUUID = UUID(uuidString: parentIDString) {
            self.parentLayerID = parentUUID
        }

        // Display order
        if let order = record.getInt("displayOrder") {
            self.displayOrder = order
        }

        // Visibility
        if let visible = record.getBool("isVisible") {
            self.isVisible = visible
        }

        // Timestamps
        if let createdDate = record.getDate("createdAt") {
            self.createdAt = createdDate
        }
        if let updatedDate = record.getDate("updatedAt") {
            self.updatedAt = updatedDate
        }

        // Sync metadata
        if let pending = record.getBool("isPendingSync") {
            self.isPendingSync = pending
        }
        self.lastSyncedAt = record.getDate("lastSyncedAt")

        // Soft delete
        if let deleted = record.getBool("isDeleted") {
            self.isDeleted = deleted
        }
    }
}
