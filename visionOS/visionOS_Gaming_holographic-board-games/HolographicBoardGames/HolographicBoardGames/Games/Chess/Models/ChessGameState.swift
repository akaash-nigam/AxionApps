//
//  ChessGameState.swift
//  HolographicBoardGames
//
//  Represents the complete state of a chess game
//

import Foundation

struct ChessGameState: Codable {
    // MARK: - Properties

    let id: UUID
    var pieces: [UUID: ChessPiece]
    var board: [[UUID?]]  // 8x8 grid of piece IDs
    var currentPlayer: PlayerColor
    var moveHistory: [ChessMove]
    var capturedPieces: [ChessPiece]
    var gameStatus: GameStatus
    var enPassantTarget: BoardPosition?  // Available en passant square
    var halfMoveClock: Int  // For fifty-move rule
    var fullMoveNumber: Int

    // Castling rights
    var whiteKingsideCastle: Bool
    var whiteQueensideCastle: Bool
    var blackKingsideCastle: Bool
    var blackQueensideCastle: Bool

    // MARK: - Game Status

    enum GameStatus: Codable, Equatable {
        case inProgress
        case check(PlayerColor)
        case checkmate(winner: PlayerColor)
        case stalemate
        case draw(reason: DrawReason)
        case resigned(winner: PlayerColor)

        enum DrawReason: String, Codable {
            case fiftyMoveRule
            case threefoldRepetition
            case insufficientMaterial
            case agreement
        }
    }

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        pieces: [UUID: ChessPiece] = [:],
        board: [[UUID?]] = Array(repeating: Array(repeating: nil, count: 8), count: 8),
        currentPlayer: PlayerColor = .white,
        moveHistory: [ChessMove] = [],
        capturedPieces: [ChessPiece] = [],
        gameStatus: GameStatus = .inProgress,
        enPassantTarget: BoardPosition? = nil,
        halfMoveClock: Int = 0,
        fullMoveNumber: Int = 1,
        whiteKingsideCastle: Bool = true,
        whiteQueensideCastle: Bool = true,
        blackKingsideCastle: Bool = true,
        blackQueensideCastle: Bool = true
    ) {
        self.id = id
        self.pieces = pieces
        self.board = board
        self.currentPlayer = currentPlayer
        self.moveHistory = moveHistory
        self.capturedPieces = capturedPieces
        self.gameStatus = gameStatus
        self.enPassantTarget = enPassantTarget
        self.halfMoveClock = halfMoveClock
        self.fullMoveNumber = fullMoveNumber
        self.whiteKingsideCastle = whiteKingsideCastle
        self.whiteQueensideCastle = whiteQueensideCastle
        self.blackKingsideCastle = blackKingsideCastle
        self.blackQueensideCastle = blackQueensideCastle
    }

    // MARK: - New Game

    /// Create a new game with standard starting position
    static func newGame() -> ChessGameState {
        var state = ChessGameState()

        // Set up white pieces
        state.addPiece(.init(type: .rook, color: .white, position: BoardPosition("a1")!))
        state.addPiece(.init(type: .knight, color: .white, position: BoardPosition("b1")!))
        state.addPiece(.init(type: .bishop, color: .white, position: BoardPosition("c1")!))
        state.addPiece(.init(type: .queen, color: .white, position: BoardPosition("d1")!))
        state.addPiece(.init(type: .king, color: .white, position: BoardPosition("e1")!))
        state.addPiece(.init(type: .bishop, color: .white, position: BoardPosition("f1")!))
        state.addPiece(.init(type: .knight, color: .white, position: BoardPosition("g1")!))
        state.addPiece(.init(type: .rook, color: .white, position: BoardPosition("h1")!))

        // White pawns
        for file in 0..<8 {
            state.addPiece(.init(type: .pawn, color: .white, position: BoardPosition(file: file, rank: 1)))
        }

        // Set up black pieces
        state.addPiece(.init(type: .rook, color: .black, position: BoardPosition("a8")!))
        state.addPiece(.init(type: .knight, color: .black, position: BoardPosition("b8")!))
        state.addPiece(.init(type: .bishop, color: .black, position: BoardPosition("c8")!))
        state.addPiece(.init(type: .queen, color: .black, position: BoardPosition("d8")!))
        state.addPiece(.init(type: .king, color: .black, position: BoardPosition("e8")!))
        state.addPiece(.init(type: .bishop, color: .black, position: BoardPosition("f8")!))
        state.addPiece(.init(type: .knight, color: .black, position: BoardPosition("g8")!))
        state.addPiece(.init(type: .rook, color: .black, position: BoardPosition("h8")!))

        // Black pawns
        for file in 0..<8 {
            state.addPiece(.init(type: .pawn, color: .black, position: BoardPosition(file: file, rank: 6)))
        }

        return state
    }

    // MARK: - Board Queries

    /// Get piece at a position
    func pieceAt(_ position: BoardPosition) -> ChessPiece? {
        guard position.isValid else { return nil }
        guard let pieceId = board[position.rank][position.file] else { return nil }
        return pieces[pieceId]
    }

    /// Check if square is empty
    func isSquareEmpty(_ position: BoardPosition) -> Bool {
        guard position.isValid else { return true }
        return board[position.rank][position.file] == nil
    }

    /// Check if square has enemy piece
    func hasEnemyPiece(at position: BoardPosition, enemyOf color: PlayerColor) -> Bool {
        guard let piece = pieceAt(position) else { return false }
        return piece.color != color
    }

    /// Find king of specified color
    func findKing(color: PlayerColor) -> ChessPiece? {
        pieces.values.first { $0.type == .king && $0.color == color }
    }

    /// Get all pieces of specified color
    func getPieces(color: PlayerColor) -> [ChessPiece] {
        pieces.values.filter { $0.color == color }
    }

    // MARK: - Mutations

    /// Add a piece to the board
    mutating func addPiece(_ piece: ChessPiece) {
        pieces[piece.id] = piece
        board[piece.position.rank][piece.position.file] = piece.id
    }

    /// Remove a piece from the board
    mutating func removePiece(at position: BoardPosition) -> ChessPiece? {
        guard position.isValid else { return nil }
        guard let pieceId = board[position.rank][position.file] else { return nil }

        board[position.rank][position.file] = nil
        return pieces.removeValue(forKey: pieceId)
    }

    /// Move a piece (without validation)
    mutating func movePiece(from: BoardPosition, to: BoardPosition) -> ChessPiece? {
        guard var piece = removePiece(at: from) else { return nil }

        // Capture if piece exists at destination
        let captured = removePiece(at: to)
        if let capturedPiece = captured {
            capturedPieces.append(capturedPiece)
        }

        // Update piece position and add to new location
        piece.position = to
        piece.hasMoved = true
        addPiece(piece)

        return captured
    }

    /// Switch current player
    mutating func switchPlayer() {
        currentPlayer = currentPlayer.opposite
        if currentPlayer == .white {
            fullMoveNumber += 1
        }
    }

    // MARK: - Game State Queries

    var isGameOver: Bool {
        switch gameStatus {
        case .inProgress, .check:
            return false
        case .checkmate, .stalemate, .draw, .resigned:
            return true
        }
    }

    var winner: PlayerColor? {
        switch gameStatus {
        case .checkmate(let winner), .resigned(let winner):
            return winner
        default:
            return nil
        }
    }

    // MARK: - Material Count

    func materialCount(for color: PlayerColor) -> Int {
        getPieces(color: color).reduce(0) { $0 + $1.type.materialValue }
    }

    func materialAdvantage(for color: PlayerColor) -> Int {
        materialCount(for: color) - materialCount(for: color.opposite)
    }
}
