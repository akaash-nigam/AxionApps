//
//  ChessMove.swift
//  HolographicBoardGames
//
//  Represents a chess move
//

import Foundation

struct ChessMove: Codable, Identifiable, Equatable {
    let id: UUID
    let pieceId: UUID
    let from: BoardPosition
    let to: BoardPosition
    let capturedPieceId: UUID?
    let isCheck: Bool
    let isCheckmate: Bool
    let isCastle: Bool
    let isEnPassant: Bool
    let promotionType: ChessPieceType?
    let timestamp: Date

    init(
        id: UUID = UUID(),
        pieceId: UUID,
        from: BoardPosition,
        to: BoardPosition,
        capturedPieceId: UUID? = nil,
        isCheck: Bool = false,
        isCheckmate: Bool = false,
        isCastle: Bool = false,
        isEnPassant: Bool = false,
        promotionType: ChessPieceType? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.pieceId = pieceId
        self.from = from
        self.to = to
        self.capturedPieceId = capturedPieceId
        self.isCheck = isCheck
        self.isCheckmate = isCheckmate
        self.isCastle = isCastle
        self.isEnPassant = isEnPassant
        self.promotionType = promotionType
        self.timestamp = timestamp
    }

    /// Algebraic notation (simplified)
    var algebraicNotation: String {
        var notation = ""

        // Piece notation (empty for pawn)
        // notation += pieceNotation

        // Starting square (for disambiguation)
        notation += from.algebraic

        // Capture indicator
        if capturedPieceId != nil {
            notation += "x"
        } else {
            notation += "-"
        }

        // Destination square
        notation += to.algebraic

        // Special moves
        if isCastle {
            notation = to.file > from.file ? "O-O" : "O-O-O"
        }

        if let promotion = promotionType {
            notation += "=\(pieceSymbol(promotion))"
        }

        // Check/Checkmate
        if isCheckmate {
            notation += "#"
        } else if isCheck {
            notation += "+"
        }

        return notation
    }

    private func pieceSymbol(_ type: ChessPieceType) -> String {
        switch type {
        case .pawn: return ""
        case .knight: return "N"
        case .bishop: return "B"
        case .rook: return "R"
        case .queen: return "Q"
        case .king: return "K"
        }
    }
}
