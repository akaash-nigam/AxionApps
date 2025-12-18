//
//  GameEvents.swift
//  HolographicBoardGames
//
//  Common game events
//

import Foundation

// MARK: - Entity Events

struct EntityCreatedEvent: GameEvent {
    let timestamp = Date()
    let entity: Entity
}

struct EntityDestroyedEvent: GameEvent {
    let timestamp = Date()
    let entity: Entity
}

struct EntityGrabbedEvent: GameEvent {
    let timestamp = Date()
    let entity: Entity
}

struct EntityReleasedEvent: GameEvent {
    let timestamp = Date()
    let entity: Entity
}

struct EntityDraggedEvent: GameEvent {
    let timestamp = Date()
    let entity: Entity
    let position: SIMD3<Float>
}

struct EntityHoverEvent: GameEvent {
    let timestamp = Date()
    let entity: Entity
}

struct EntityGazedEvent: GameEvent {
    let timestamp = Date()
    let entity: Entity
}

// MARK: - Physics Events

struct CollisionEvent: GameEvent {
    let timestamp = Date()
    let entityA: Entity
    let entityB: Entity
    let contactPoint: SIMD3<Float>
    let normal: SIMD3<Float>

    init(entityA: Entity, entityB: Entity, contactPoint: SIMD3<Float> = .zero, normal: SIMD3<Float> = .zero) {
        self.entityA = entityA
        self.entityB = entityB
        self.contactPoint = contactPoint
        self.normal = normal
    }
}

// MARK: - Game State Events

struct GameStartedEvent: GameEvent {
    let timestamp = Date()
    let gameType: GameType
}

struct GamePausedEvent: GameEvent {
    let timestamp = Date()
}

struct GameResumedEvent: GameEvent {
    let timestamp = Date()
}

struct GameEndedEvent: GameEvent {
    let timestamp = Date()
    let winner: UUID?
    let reason: EndReason

    enum EndReason {
        case checkmate
        case resignation
        case timeout
        case draw
        case stalemate
    }
}

// MARK: - Chess Events

struct PieceMoveEvent: GameEvent {
    let timestamp = Date()
    let piece: Entity
    let fromPosition: BoardPosition
    let toPosition: BoardPosition
}

struct PieceCaptureEvent: GameEvent {
    let timestamp = Date()
    let attacker: Entity
    let defender: Entity
    let position: BoardPosition
}

struct CheckEvent: GameEvent {
    let timestamp = Date()
    let kingEntity: Entity
    let threateningEntity: Entity
}

struct CheckmateEvent: GameEvent {
    let timestamp = Date()
    let winner: PlayerColor
    let loser: PlayerColor
}

struct CastlingEvent: GameEvent {
    let timestamp = Date()
    let king: Entity
    let rook: Entity
    let side: CastleSide

    enum CastleSide {
        case kingside
        case queenside
    }
}

struct PawnPromotionEvent: GameEvent {
    let timestamp = Date()
    let pawn: Entity
    let promotedTo: ChessPieceType
    let position: BoardPosition
}

// MARK: - UI Events

struct ButtonClickedEvent: GameEvent {
    let timestamp = Date()
    let buttonId: String
}

struct MenuOpenedEvent: GameEvent {
    let timestamp = Date()
    let menuId: String
}

struct MenuClosedEvent: GameEvent {
    let timestamp = Date()
    let menuId: String
}

// MARK: - Game Type

enum GameType: String, Codable {
    case chess
    case checkers
    case go
    case backgammon
}
