//
//  ChessPiece.swift
//  HolographicBoardGames
//
//  Represents a chess piece
//

import Foundation

enum PlayerColor: String, Codable {
    case white
    case black

    var opposite: PlayerColor {
        self == .white ? .black : .white
    }
}

enum ChessPieceType: String, Codable, CaseIterable {
    case pawn
    case knight
    case bishop
    case rook
    case queen
    case king

    /// Material value for evaluation
    var materialValue: Int {
        switch self {
        case .pawn: return 1
        case .knight, .bishop: return 3
        case .rook: return 5
        case .queen: return 9
        case .king: return 0  // Infinite (game ends if captured)
        }
    }
}

struct ChessPiece: Codable, Identifiable, Equatable {
    let id: UUID
    let type: ChessPieceType
    let color: PlayerColor
    var position: BoardPosition
    var hasMoved: Bool

    init(
        id: UUID = UUID(),
        type: ChessPieceType,
        color: PlayerColor,
        position: BoardPosition,
        hasMoved: Bool = false
    ) {
        self.id = id
        self.type = type
        self.color = color
        self.position = position
        self.hasMoved = hasMoved
    }

    /// Create a piece from algebraic notation
    /// Example: "wP" = white pawn, "bK" = black king
    init?(notation: String, position: BoardPosition) {
        guard notation.count == 2 else { return nil }

        let chars = Array(notation)
        let colorChar = chars[0]
        let typeChar = chars[1]

        // Parse color
        switch colorChar {
        case "w": self.color = .white
        case "b": self.color = .black
        default: return nil
        }

        // Parse type
        switch typeChar {
        case "P": self.type = .pawn
        case "N": self.type = .knight
        case "B": self.type = .bishop
        case "R": self.type = .rook
        case "Q": self.type = .queen
        case "K": self.type = .king
        default: return nil
        }

        self.id = UUID()
        self.position = position
        self.hasMoved = false
    }

    /// Notation string (e.g., "wP", "bK")
    var notation: String {
        let colorChar = color == .white ? "w" : "b"
        let typeChar: String = {
            switch type {
            case .pawn: return "P"
            case .knight: return "N"
            case .bishop: return "B"
            case .rook: return "R"
            case .queen: return "Q"
            case .king: return "K"
            }
        }()
        return "\(colorChar)\(typeChar)"
    }
}
