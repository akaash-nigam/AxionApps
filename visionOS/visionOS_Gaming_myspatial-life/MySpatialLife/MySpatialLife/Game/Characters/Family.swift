import Foundation

/// Represents a family unit in the game
class Family: Identifiable, Codable {
    let id: UUID
    var familyName: String
    var generation: Int

    var memberIDs: [UUID]  // IDs of characters in this family
    var familyFunds: Int

    var homeSize: HomeSize
    var createdDate: Date
    var totalPlayTime: TimeInterval

    // Family tree
    var familyTree: FamilyTree

    init(
        id: UUID = UUID(),
        familyName: String,
        generation: Int = 1,
        memberIDs: [UUID] = [],
        familyFunds: Int = 20000,
        homeSize: HomeSize = .medium
    ) {
        self.id = id
        self.familyName = familyName
        self.generation = generation
        self.memberIDs = memberIDs
        self.familyFunds = familyFunds
        self.homeSize = homeSize
        self.createdDate = Date()
        self.totalPlayTime = 0
        self.familyTree = FamilyTree(rootFamilyID: id)
    }

    /// Add a member to the family
    func addMember(_ characterID: UUID) {
        if !memberIDs.contains(characterID) {
            memberIDs.append(characterID)
        }
    }

    /// Remove a member from the family
    func removeMember(_ characterID: UUID) {
        memberIDs.removeAll { $0 == characterID }
    }

    enum HomeSize: String, Codable {
        case small      // 2-3 members
        case medium     // 4-5 members
        case large      // 6-8 members
    }
}

/// Family tree structure tracking generational relationships
class FamilyTree: Codable {
    let rootFamilyID: UUID
    var nodes: [UUID: FamilyNode] = [:]

    init(rootFamilyID: UUID) {
        self.rootFamilyID = rootFamilyID
    }

    /// Add a character to the family tree
    func addCharacter(
        _ characterID: UUID,
        parents: [UUID] = [],
        generation: Int
    ) {
        let node = FamilyNode(
            characterID: characterID,
            parentIDs: parents,
            generation: generation
        )
        nodes[characterID] = node
    }

    /// Add a child relationship
    func addChild(_ childID: UUID, to parentID: UUID) {
        nodes[parentID]?.childIDs.append(childID)
    }

    /// Set spouse relationship
    func setSpouse(_ spouseID: UUID, for characterID: UUID) {
        nodes[characterID]?.spouseID = spouseID
    }

    /// Get all descendants of a character
    func descendants(of characterID: UUID) -> [UUID] {
        guard let node = nodes[characterID] else { return [] }

        var allDescendants = node.childIDs

        for childID in node.childIDs {
            allDescendants.append(contentsOf: descendants(of: childID))
        }

        return allDescendants
    }

    /// Get all ancestors of a character
    func ancestors(of characterID: UUID) -> [UUID] {
        guard let node = nodes[characterID] else { return [] }

        var allAncestors = node.parentIDs

        for parentID in node.parentIDs {
            allAncestors.append(contentsOf: ancestors(of: parentID))
        }

        return allAncestors
    }
}

struct FamilyNode: Codable {
    let characterID: UUID
    var parentIDs: [UUID]
    var childIDs: [UUID] = []
    var spouseID: UUID?
    let generation: Int

    init(characterID: UUID, parentIDs: [UUID], generation: Int) {
        self.characterID = characterID
        self.parentIDs = parentIDs
        self.generation = generation
    }
}
