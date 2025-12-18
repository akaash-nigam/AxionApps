//
//  CollaborationSession.swift
//  Molecular Design Platform
//
//  SharePlay collaboration for molecular design
//

import Foundation
import GroupActivities

// MARK: - Molecular Design Activity

struct MolecularDesignActivity: GroupActivity {
    static let activityIdentifier = "com.molecular.design.collaboration"

    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = "Molecular Design Session"
        metadata.type = .generic
        return metadata
    }

    var projectID: UUID
}

// MARK: - Collaboration Session

@Observable
class CollaborationSession {
    // Placeholder for SharePlay integration
    var isActive: Bool = false
    var participants: [Researcher] = []

    func startSession(project: Project) async throws {
        // Placeholder
        isActive = true
    }

    func endSession() async {
        isActive = false
        participants.removeAll()
    }
}
