//
//  EvidenceManager.swift
//  Mystery Investigation
//
//  Manages evidence discovery, collection, and analysis
//

import Foundation
import RealityKit

@Observable
class EvidenceManager {
    // MARK: - Evidence State
    private(set) var discoveredEvidence: [UUID: Evidence] = [:]
    private(set) var examinedEvidence: Set<UUID> = []
    private var evidenceEntities: [UUID: EvidenceEntity] = [:]

    // MARK: - Discovery
    func discoverEvidence(_ evidence: Evidence) {
        guard discoveredEvidence[evidence.id] == nil else { return }

        discoveredEvidence[evidence.id] = evidence

        // Trigger discovery notification
        NotificationCenter.default.post(
            name: .evidenceDiscovered,
            object: evidence
        )
    }

    func examineEvidence(_ evidenceID: UUID) {
        examinedEvidence.insert(evidenceID)
    }

    // MARK: - Evidence Queries
    func getEvidence(byID id: UUID) -> Evidence? {
        return discoveredEvidence[id]
    }

    func getAllEvidence() -> [Evidence] {
        return Array(discoveredEvidence.values)
    }

    func getEvidenceByType(_ type: Evidence.EvidenceType) -> [Evidence] {
        return getAllEvidence().filter { $0.type == type }
    }

    func getRelatedEvidence(for suspectID: UUID) -> [Evidence] {
        return getAllEvidence().filter { $0.relatedSuspects.contains(suspectID) }
    }

    // MARK: - Evidence Entity Management
    func registerEntity(_ entity: EvidenceEntity, for evidenceID: UUID) {
        evidenceEntities[evidenceID] = entity
    }

    func getEntity(for evidenceID: UUID) -> EvidenceEntity? {
        return evidenceEntities[evidenceID]
    }

    // MARK: - Forensic Analysis
    func performForensicAnalysis(on evidenceID: UUID, with tool: ForensicTool) -> ForensicData? {
        guard let evidence = discoveredEvidence[evidenceID],
              evidence.requiresTool == tool else {
            return nil
        }

        return evidence.forensicData
    }

    // MARK: - Reset
    func reset() {
        discoveredEvidence.removeAll()
        examinedEvidence.removeAll()
        evidenceEntities.removeAll()
    }
}

// MARK: - Notifications
extension Notification.Name {
    static let evidenceDiscovered = Notification.Name("evidenceDiscovered")
    static let evidenceExamined = Notification.Name("evidenceExamined")
}
