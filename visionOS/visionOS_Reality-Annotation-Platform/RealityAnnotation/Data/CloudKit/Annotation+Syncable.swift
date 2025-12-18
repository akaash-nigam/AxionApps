//
//  Annotation+Syncable.swift
//  Reality Annotation Platform
//
//  CloudKit sync support for Annotation model
//

import Foundation
import CloudKit

// MARK: - Annotation Syncable Conformance

extension Annotation: Syncable {
    static var recordType: String {
        return "Annotation"
    }

    func toCKRecord() throws -> CKRecord {
        let recordID = CKRecord.ID(recordName: id.uuidString)
        let record = CKRecord(recordType: Self.recordType, recordID: recordID)

        // Basic fields
        record["type"] = type.rawValue
        record["title"] = title
        record["contentText"] = contentText

        // Position (store as separate fields)
        record["positionX"] = positionX as CKRecordValue
        record["positionY"] = positionY as CKRecordValue
        record["positionZ"] = positionZ as CKRecordValue

        // Orientation (store as separate fields)
        record["orientationW"] = orientationW as CKRecordValue
        record["orientationX"] = orientationX as CKRecordValue
        record["orientationY"] = orientationY as CKRecordValue
        record["orientationZ"] = orientationZ as CKRecordValue

        // Scale
        record["scale"] = scale as CKRecordValue

        // Layer reference
        record["layerID"] = layerID.uuidString

        // Owner
        record["ownerID"] = ownerID

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
        guard let typeString = record.getString("type"),
              let annotationType = AnnotationType(rawValue: typeString) else {
            throw SyncableError.missingRequiredField("type")
        }
        self.type = annotationType

        self.title = record.getString("title")
        self.contentText = record.getString("contentText")

        // Position
        guard let posX = record.getDouble("positionX"),
              let posY = record.getDouble("positionY"),
              let posZ = record.getDouble("positionZ") else {
            throw SyncableError.missingRequiredField("position")
        }
        self.positionX = Float(posX)
        self.positionY = Float(posY)
        self.positionZ = Float(posZ)

        // Orientation
        guard let oriW = record.getDouble("orientationW"),
              let oriX = record.getDouble("orientationX"),
              let oriY = record.getDouble("orientationY"),
              let oriZ = record.getDouble("orientationZ") else {
            throw SyncableError.missingRequiredField("orientation")
        }
        self.orientationW = Float(oriW)
        self.orientationX = Float(oriX)
        self.orientationY = Float(oriY)
        self.orientationZ = Float(oriZ)

        // Scale
        if let scaleValue = record.getDouble("scale") {
            self.scale = Float(scaleValue)
        }

        // Layer reference
        guard let layerIDString = record.getString("layerID"),
              let parsedLayerID = UUID(uuidString: layerIDString) else {
            throw SyncableError.missingRequiredField("layerID")
        }
        self.layerID = parsedLayerID

        // Owner
        guard let owner = record.getString("ownerID") else {
            throw SyncableError.missingRequiredField("ownerID")
        }
        self.ownerID = owner

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
