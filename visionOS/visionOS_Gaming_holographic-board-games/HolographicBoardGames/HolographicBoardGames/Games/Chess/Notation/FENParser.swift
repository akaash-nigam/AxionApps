//
//  FENParser.swift
//  HolographicBoardGames
//
//  Forsyth–Edwards Notation (FEN) parser and generator
//

import Foundation

/// FEN parser for chess positions
/// Format: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
struct FENParser {

    // MARK: - Parsing

    /// Parse FEN string into a ChessGameState
    static func parse(_ fen: String) throws -> ChessGameState {
        let components = fen.split(separator: " ").map(String.init)

        guard components.count == 6 else {
            throw FENError.invalidFormat("Expected 6 components, got \(components.count)")
        }

        let boardString = components[0]
        let activeColor = components[1]
        let castlingRights = components[2]
        let enPassantSquare = components[3]
        let halfMoveClock = components[4]
        let fullMoveNumber = components[5]

        // Parse board position
        let pieces = try parseBoard(boardString)

        // Parse active color
        guard let currentPlayer = parseActiveColor(activeColor) else {
            throw FENError.invalidActiveColor(activeColor)
        }

        // Parse castling rights
        let castling = parseCastlingRights(castlingRights)

        // Parse en passant target
        let enPassantTarget = parseEnPassantTarget(enPassantSquare)

        // Parse move clocks
        guard let halfMove = Int(halfMoveClock),
              let fullMove = Int(fullMoveNumber) else {
            throw FENError.invalidMoveClock
        }

        // Build game state
        var gameState = ChessGameState(
            currentPlayer: currentPlayer,
            enPassantTarget: enPassantTarget,
            halfMoveClock: halfMove,
            fullMoveNumber: fullMove,
            whiteKingsideCastle: castling.whiteKingside,
            whiteQueensideCastle: castling.whiteQueenside,
            blackKingsideCastle: castling.blackKingside,
            blackQueensideCastle: castling.blackQueenside
        )

        // Add pieces to board
        for piece in pieces {
            gameState.addPiece(piece)
        }

        return gameState
    }

    /// Parse board section of FEN
    private static func parseBoard(_ boardString: String) throws -> [ChessPiece] {
        var pieces: [ChessPiece] = []
        let ranks = boardString.split(separator: "/")

        guard ranks.count == 8 else {
            throw FENError.invalidBoardFormat("Expected 8 ranks, got \(ranks.count)")
        }

        for (rankIndex, rankString) in ranks.enumerated() {
            let rank = 7 - rankIndex // FEN starts from rank 8
            var file = 0

            for char in rankString {
                if let emptySquares = char.wholeNumberValue {
                    file += emptySquares
                } else {
                    guard let piece = parsePiece(char, at: BoardPosition(file: file, rank: rank)) else {
                        throw FENError.invalidPieceCharacter(String(char))
                    }
                    pieces.append(piece)
                    file += 1
                }
            }

            guard file == 8 else {
                throw FENError.invalidBoardFormat("Rank \(8 - rankIndex) has \(file) squares")
            }
        }

        return pieces
    }

    /// Parse a piece from FEN character
    private static func parsePiece(_ char: Character, at position: BoardPosition) -> ChessPiece? {
        let color: PlayerColor = char.isUppercase ? .white : .black

        let type: ChessPieceType?
        switch char.lowercased() {
        case "p": type = .pawn
        case "n": type = .knight
        case "b": type = .bishop
        case "r": type = .rook
        case "q": type = .queen
        case "k": type = .king
        default: type = nil
        }

        guard let pieceType = type else { return nil }

        return ChessPiece(type: pieceType, color: color, position: position)
    }

    /// Parse active color
    private static func parseActiveColor(_ colorString: String) -> PlayerColor? {
        switch colorString {
        case "w": return .white
        case "b": return .black
        default: return nil
        }
    }

    /// Parse castling rights
    private static func parseCastlingRights(_ rights: String) -> (whiteKingside: Bool, whiteQueenside: Bool, blackKingside: Bool, blackQueenside: Bool) {
        if rights == "-" {
            return (false, false, false, false)
        }

        return (
            whiteKingside: rights.contains("K"),
            whiteQueenside: rights.contains("Q"),
            blackKingside: rights.contains("k"),
            blackQueenside: rights.contains("q")
        )
    }

    /// Parse en passant target square
    private static func parseEnPassantTarget(_ square: String) -> BoardPosition? {
        guard square != "-" else { return nil }
        return BoardPosition(square)
    }

    // MARK: - Generation

    /// Generate FEN string from ChessGameState
    static func generate(from gameState: ChessGameState) -> String {
        let boardString = generateBoardString(from: gameState)
        let activeColor = gameState.currentPlayer == .white ? "w" : "b"
        let castlingRights = generateCastlingRights(from: gameState)
        let enPassantSquare = gameState.enPassantTarget?.algebraic ?? "-"
        let halfMoveClock = String(gameState.halfMoveClock)
        let fullMoveNumber = String(gameState.fullMoveNumber)

        return "\(boardString) \(activeColor) \(castlingRights) \(enPassantSquare) \(halfMoveClock) \(fullMoveNumber)"
    }

    /// Generate board section of FEN
    private static func generateBoardString(from gameState: ChessGameState) -> String {
        var ranks: [String] = []

        for rank in (0..<8).reversed() {
            var rankString = ""
            var emptyCount = 0

            for file in 0..<8 {
                let position = BoardPosition(file: file, rank: rank)

                if let piece = gameState.pieceAt(position) {
                    if emptyCount > 0 {
                        rankString += String(emptyCount)
                        emptyCount = 0
                    }
                    rankString += pieceToFENChar(piece)
                } else {
                    emptyCount += 1
                }
            }

            if emptyCount > 0 {
                rankString += String(emptyCount)
            }

            ranks.append(rankString)
        }

        return ranks.joined(separator: "/")
    }

    /// Convert piece to FEN character
    private static func pieceToFENChar(_ piece: ChessPiece) -> String {
        let char: String
        switch piece.type {
        case .pawn: char = "p"
        case .knight: char = "n"
        case .bishop: char = "b"
        case .rook: char = "r"
        case .queen: char = "q"
        case .king: char = "k"
        }

        return piece.color == .white ? char.uppercased() : char
    }

    /// Generate castling rights string
    private static func generateCastlingRights(from gameState: ChessGameState) -> String {
        var rights = ""

        if gameState.whiteKingsideCastle { rights += "K" }
        if gameState.whiteQueensideCastle { rights += "Q" }
        if gameState.blackKingsideCastle { rights += "k" }
        if gameState.blackQueensideCastle { rights += "q" }

        return rights.isEmpty ? "-" : rights
    }
}

// MARK: - FEN Constants

extension FENParser {
    /// Standard starting position FEN
    static let startingPosition = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

    /// Common test positions
    enum TestPosition {
        static let empty = "8/8/8/8/8/8/8/8 w - - 0 1"
        static let kingsOnly = "4k3/8/8/8/8/8/8/4K3 w - - 0 1"
        static let foolsMate = "rnb1kbnr/pppp1ppp/8/4p3/6Pq/5P2/PPPPP2P/RNBQKBNR w KQkq - 1 3"
        static let scholarsMate = "r1bqkb1r/pppp1Qpp/2n2n2/4p3/2B1P3/8/PPPP1PPP/RNB1K1NR b KQkq - 0 4"
    }
}

// MARK: - Errors

enum FENError: Error, LocalizedError {
    case invalidFormat(String)
    case invalidBoardFormat(String)
    case invalidPieceCharacter(String)
    case invalidActiveColor(String)
    case invalidMoveClock

    var errorDescription: String? {
        switch self {
        case .invalidFormat(let msg):
            return "Invalid FEN format: \(msg)"
        case .invalidBoardFormat(let msg):
            return "Invalid board format: \(msg)"
        case .invalidPieceCharacter(let char):
            return "Invalid piece character: \(char)"
        case .invalidActiveColor(let color):
            return "Invalid active color: \(color)"
        case .invalidMoveClock:
            return "Invalid move clock values"
        }
    }
}

// MARK: - ChessGameState Extension

extension ChessGameState {
    /// Create game state from FEN string
    init(fen: String) throws {
        self = try FENParser.parse(fen)
    }

    /// Generate FEN string from this game state
    var fen: String {
        FENParser.generate(from: self)
    }

    /// Create new game from standard starting position
    static func fromStartingPosition() -> ChessGameState {
        try! ChessGameState(fen: FENParser.startingPosition)
    }
}
