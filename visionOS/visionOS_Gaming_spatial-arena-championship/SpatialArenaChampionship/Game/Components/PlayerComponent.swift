//
//  PlayerComponent.swift
//  Spatial Arena Championship
//
//  RealityKit component for player entities
//

import Foundation
import RealityKit

// MARK: - Player Component

struct PlayerComponent: Component, Codable {
    var playerID: UUID
    var username: String
    var team: TeamColor
    var isLocalPlayer: Bool

    // Abilities
    var abilities: AbilityLoadout
    var ultimateCharge: Float = 0.0

    // Stats (runtime)
    var kills: Int = 0
    var deaths: Int = 0
    var assists: Int = 0
    var damageDealt: Float = 0.0

    init(playerID: UUID, username: String, team: TeamColor, isLocalPlayer: Bool = false) {
        self.playerID = playerID
        self.username = username
        self.team = team
        self.isLocalPlayer = isLocalPlayer
        self.abilities = AbilityLoadout()
    }
}

// MARK: - Ability Loadout

struct AbilityLoadout: Codable {
    var primary: UUID = Ability.primaryFire.id
    var secondary: UUID = Ability.shieldWall.id
    var tactical: UUID = Ability.dash.id
    var ultimate: UUID = Ability.novaBlast.id
}
