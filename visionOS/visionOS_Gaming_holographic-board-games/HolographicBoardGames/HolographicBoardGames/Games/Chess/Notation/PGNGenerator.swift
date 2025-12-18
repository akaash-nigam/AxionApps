//
//  PGNGenerator.swift
//  HolographicBoardGames
//
//  Portable Game Notation (PGN) generator for chess moves
//

import Foundation

/// PGN move notation generator
struct PGNGenerator {

    // MARK: - Move Notation

    /// Generate algebraic notation for a move
    static func notation(for move: ChessMove, in gameState: ChessGameState, checkState: CheckState = .none) -> String {
        guard let piece = gameState.pieceAt(move.from) else { return "" }

        var notation = ""

        // Castling notation
        if move.isCastle {
            let isKingside = move.to.file > move.from.file
            return isKingside ? "O-O" : "O-O-O"
        }

        // Piece prefix (except pawns)
        if piece.type != .pawn {
            notation += piece.type.pgnSymbol
        }

        // Disambiguation (if multiple pieces of same type can move to same square)
        notation += disambiguationString(for: piece, move: move, in: gameState)

        // Capture notation
        if move.capturedPieceId != nil || gameState.pieceAt(move.to) != nil {
            if piece.type == .pawn {
                notation += move.from.algebraic.prefix(1) // File of pawn
            }
            notation += "x"
        }

        // Destination square
        notation += move.to.algebraic

        // Promotion
        if let promotion = move.promotionType {
            notation += "=\(promotion.pgnSymbol)"
        }

        // Check/Checkmate notation
        switch checkState {
        case .check:
            notation += "+"
        case .checkmate:
            notation += "#"
        case .none:
            break
        }

        return notation
    }

    /// Generate disambiguation string for move
    private static func disambiguationString(for piece: ChessPiece, move: ChessMove, in gameState: ChessGameState) -> String {
        // Only for non-pawns
        guard piece.type != .pawn else { return "" }

        // Find other pieces of same type and color that can move to same square
        let samePieces = gameState.getPieces(color: piece.color).filter {
            $0.type == piece.type && $0.id != piece.id
        }

        let rulesEngine = ChessRulesEngine()
        let ambiguousPieces = samePieces.filter { otherPiece in
            let testMove = ChessMove(pieceId: otherPiece.id, from: otherPiece.position, to: move.to)
            return rulesEngine.isValidMove(testMove, in: gameState)
        }

        guard !ambiguousPieces.isEmpty else { return "" }

        // Check if file is enough to disambiguate
        let sameFile = ambiguousPieces.contains { $0.position.file == piece.position.file }
        let sameRank = ambiguousPieces.contains { $0.position.rank == piece.position.rank }

        if !sameFile {
            return String(move.from.algebraic.prefix(1)) // File
        } else if !sameRank {
            return String(move.from.algebraic.suffix(1)) // Rank
        } else {
            return move.from.algebraic // Full square
        }
    }

    // MARK: - Game Notation

    /// Generate full PGN game notation
    static func generatePGN(
        moves: [ChessMove],
        gameStates: [ChessGameState],
        metadata: PGNMetadata = PGNMetadata()
    ) -> String {
        var pgn = ""

        // Add metadata tags
        pgn += metadata.pgnTags

        // Add moves
        var moveNumber = 1
        for (index, move) in moves.enumerated() {
            guard index < gameStates.count else { break }

            let gameState = gameStates[index]
            let color = gameState.currentPlayer

            // Add move number for white
            if color == .white {
                pgn += "\(moveNumber). "
            }

            // Generate notation with check state
            var nextState = gameState
            _ = nextState.movePiece(from: move.from, to: move.to)

            let rulesEngine = ChessRulesEngine()
            let checkState: CheckState
            if rulesEngine.isCheckmate(in: nextState) {
                checkState = .checkmate
            } else if rulesEngine.isKingInCheck(color: nextState.currentPlayer, in: nextState) {
                checkState = .check
            } else {
                checkState = .none
            }

            pgn += notation(for: move, in: gameState, checkState: checkState)
            pgn += " "

            // Increment move number after black's move
            if color == .black {
                moveNumber += 1
            }
        }

        // Add result
        pgn += metadata.result.pgnString

        return pgn.trimmingCharacters(in: .whitespaces)
    }
}

// MARK: - Check State

enum CheckState {
    case none
    case check
    case checkmate
}

// MARK: - PGN Metadata

struct PGNMetadata {
    var event: String = "Casual Game"
    var site: String = "visionOS"
    var date: String = "????.??.??"
    var round: String = "?"
    var white: String = "White"
    var black: String = "Black"
    var result: GameResult = .ongoing

    var pgnTags: String {
        """
        [Event "\(event)"]
        [Site "\(site)"]
        [Date "\(date)"]
        [Round "\(round)"]
        [White "\(white)"]
        [Black "\(black)"]
        [Result "\(result.pgnString)"]

        """
    }

    init(
        event: String = "Casual Game",
        site: String = "visionOS",
        date: String? = nil,
        round: String = "?",
        white: String = "White",
        black: String = "Black",
        result: GameResult = .ongoing
    ) {
        self.event = event
        self.site = site
        self.date = date ?? Self.currentDate()
        self.round = round
        self.white = white
        self.black = black
        self.result = result
    }

    private static func currentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: Date())
    }
}

enum GameResult {
    case whiteWins
    case blackWins
    case draw
    case ongoing

    var pgnString: String {
        switch self {
        case .whiteWins: return "1-0"
        case .blackWins: return "0-1"
        case .draw: return "1/2-1/2"
        case .ongoing: return "*"
        }
    }
}

// MARK: - ChessPieceType Extension

extension ChessPieceType {
    /// PGN symbol for piece type
    var pgnSymbol: String {
        switch self {
        case .king: return "K"
        case .queen: return "Q"
        case .rook: return "R"
        case .bishop: return "B"
        case .knight: return "N"
        case .pawn: return ""
        }
    }
}

// MARK: - ChessMove Extension

extension ChessMove {
    /// Simple algebraic notation (e.g., "e2e4")
    var simpleNotation: String {
        from.algebraic + to.algebraic
    }

    /// Long algebraic notation (e.g., "Ng1-f3")
    func longNotation(piece: ChessPieceType) -> String {
        let pieceSymbol = piece == .pawn ? "" : piece.pgnSymbol
        let separator = capturedPieceId != nil ? "x" : "-"
        return "\(pieceSymbol)\(from.algebraic)\(separator)\(to.algebraic)"
    }
}
