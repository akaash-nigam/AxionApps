//
//  ChessRulesEngine.swift
//  HolographicBoardGames
//
//  Chess rules validation and move generation engine
//

import Foundation

/// Engine for validating chess moves and generating legal moves
final class ChessRulesEngine {

    // MARK: - Move Validation

    /// Validate if a move is legal according to chess rules
    func isValidMove(_ move: ChessMove, in gameState: ChessGameState) -> Bool {
        guard let piece = gameState.pieceAt(move.from) else { return false }
        guard piece.color == gameState.currentPlayer else { return false }
        guard move.from != move.to else { return false }

        // Check if move follows piece movement rules
        guard isPieceMoveValid(piece: piece, move: move, in: gameState) else { return false }

        // Check if path is clear for sliding pieces
        if piece.type.isSliding {
            guard isPathClear(from: move.from, to: move.to, in: gameState) else { return false }
        }

        // Cannot capture own pieces
        if let targetPiece = gameState.pieceAt(move.to) {
            guard targetPiece.color != piece.color else { return false }
        }

        // TODO: Verify move doesn't leave king in check
        // This will be implemented in the check detection phase

        return true
    }

    /// Check if piece movement rules are followed
    private func isPieceMoveValid(piece: ChessPiece, move: ChessMove, in gameState: ChessGameState) -> Bool {
        switch piece.type {
        case .pawn:
            return isValidPawnMove(piece: piece, move: move, in: gameState)
        case .knight:
            return isValidKnightMove(from: move.from, to: move.to)
        case .bishop:
            return isValidBishopMove(from: move.from, to: move.to)
        case .rook:
            return isValidRookMove(from: move.from, to: move.to)
        case .queen:
            return isValidQueenMove(from: move.from, to: move.to)
        case .king:
            return isValidKingMove(piece: piece, move: move, in: gameState)
        }
    }

    // MARK: - Pawn Movement

    private func isValidPawnMove(piece: ChessPiece, move: ChessMove, in gameState: ChessGameState) -> Bool {
        let direction = piece.color == .white ? 1 : -1
        let startRank = piece.color == .white ? 1 : 6
        let fileDiff = move.to.file - move.from.file
        let rankDiff = move.to.rank - move.from.rank

        // Forward movement
        if fileDiff == 0 {
            // Single square forward
            if rankDiff == direction {
                return gameState.isSquareEmpty(move.to)
            }

            // Double square forward from starting position
            if rankDiff == direction * 2 && move.from.rank == startRank {
                let intermediatePos = BoardPosition(file: move.from.file, rank: move.from.rank + direction)
                return gameState.isSquareEmpty(intermediatePos) && gameState.isSquareEmpty(move.to)
            }

            return false
        }

        // Diagonal capture
        if abs(fileDiff) == 1 && rankDiff == direction {
            // Regular capture
            if gameState.hasEnemyPiece(at: move.to, enemyOf: piece.color) {
                return true
            }

            // En passant capture
            if let enPassantTarget = gameState.enPassantTarget,
               enPassantTarget == move.to {
                return true
            }

            return false
        }

        return false
    }

    // MARK: - Knight Movement

    func isValidKnightMove(from: BoardPosition, to: BoardPosition) -> Bool {
        let fileDiff = abs(to.file - from.file)
        let rankDiff = abs(to.rank - from.rank)

        return (fileDiff == 2 && rankDiff == 1) || (fileDiff == 1 && rankDiff == 2)
    }

    // MARK: - Bishop Movement

    func isValidBishopMove(from: BoardPosition, to: BoardPosition) -> Bool {
        let fileDiff = abs(to.file - from.file)
        let rankDiff = abs(to.rank - from.rank)

        return fileDiff == rankDiff && fileDiff > 0
    }

    // MARK: - Rook Movement

    func isValidRookMove(from: BoardPosition, to: BoardPosition) -> Bool {
        let fileDiff = abs(to.file - from.file)
        let rankDiff = abs(to.rank - from.rank)

        return (fileDiff == 0 && rankDiff > 0) || (rankDiff == 0 && fileDiff > 0)
    }

    // MARK: - Queen Movement

    func isValidQueenMove(from: BoardPosition, to: BoardPosition) -> Bool {
        return isValidRookMove(from: from, to: to) || isValidBishopMove(from: from, to: to)
    }

    // MARK: - King Movement

    private func isValidKingMove(piece: ChessPiece, move: ChessMove, in gameState: ChessGameState) -> Bool {
        let fileDiff = abs(move.to.file - move.from.file)
        let rankDiff = abs(move.to.rank - move.from.rank)

        // Regular king move (one square in any direction)
        if fileDiff <= 1 && rankDiff <= 1 {
            return true
        }

        // Castling
        if rankDiff == 0 && fileDiff == 2 && !piece.hasMoved {
            return isValidCastling(piece: piece, move: move, in: gameState)
        }

        return false
    }

    private func isValidCastling(piece: ChessPiece, move: ChessMove, in gameState: ChessGameState) -> Bool {
        guard !piece.hasMoved else { return false }

        let isKingside = move.to.file > move.from.file
        let rookFile = isKingside ? 7 : 0
        let rookPosition = BoardPosition(file: rookFile, rank: move.from.rank)

        // Check castling rights
        if piece.color == .white {
            if isKingside && !gameState.whiteKingsideCastle { return false }
            if !isKingside && !gameState.whiteQueensideCastle { return false }
        } else {
            if isKingside && !gameState.blackKingsideCastle { return false }
            if !isKingside && !gameState.blackQueensideCastle { return false }
        }

        // Check if rook is present and hasn't moved
        guard let rook = gameState.pieceAt(rookPosition),
              rook.type == .rook,
              !rook.hasMoved else { return false }

        // Check if squares between king and rook are empty
        let direction = isKingside ? 1 : -1
        let squaresToCheck = isKingside ? 2 : 3

        for i in 1...squaresToCheck {
            let checkPos = BoardPosition(file: move.from.file + (i * direction), rank: move.from.rank)
            if !gameState.isSquareEmpty(checkPos) { return false }
        }

        // TODO: Check that king doesn't pass through check
        // This will be implemented with check detection

        return true
    }

    // MARK: - Path Validation

    /// Check if path is clear for sliding pieces (bishop, rook, queen)
    func isPathClear(from: BoardPosition, to: BoardPosition, in gameState: ChessGameState) -> Bool {
        let fileDiff = to.file - from.file
        let rankDiff = to.rank - from.rank

        let fileStep = fileDiff == 0 ? 0 : (fileDiff > 0 ? 1 : -1)
        let rankStep = rankDiff == 0 ? 0 : (rankDiff > 0 ? 1 : -1)

        var currentFile = from.file + fileStep
        var currentRank = from.rank + rankStep

        while currentFile != to.file || currentRank != to.rank {
            let position = BoardPosition(file: currentFile, rank: currentRank)
            if !gameState.isSquareEmpty(position) {
                return false
            }
            currentFile += fileStep
            currentRank += rankStep
        }

        return true
    }

    // MARK: - Legal Move Generation

    /// Generate all legal moves for a piece
    func legalMoves(for piece: ChessPiece, in gameState: ChessGameState) -> [ChessMove] {
        let candidateMoves = generateCandidateMoves(for: piece, in: gameState)
        return candidateMoves.filter { isValidMove($0, in: gameState) }
    }

    /// Generate all legal moves for the current player
    func allLegalMoves(in gameState: ChessGameState) -> [ChessMove] {
        let playerPieces = gameState.getPieces(color: gameState.currentPlayer)
        return playerPieces.flatMap { legalMoves(for: $0, in: gameState) }
    }

    /// Generate candidate moves (before validation)
    private func generateCandidateMoves(for piece: ChessPiece, in gameState: ChessGameState) -> [ChessMove] {
        var moves: [ChessMove] = []

        switch piece.type {
        case .pawn:
            moves.append(contentsOf: generatePawnMoves(for: piece, in: gameState))
        case .knight:
            moves.append(contentsOf: generateKnightMoves(for: piece))
        case .bishop:
            moves.append(contentsOf: generateBishopMoves(for: piece, in: gameState))
        case .rook:
            moves.append(contentsOf: generateRookMoves(for: piece, in: gameState))
        case .queen:
            moves.append(contentsOf: generateQueenMoves(for: piece, in: gameState))
        case .king:
            moves.append(contentsOf: generateKingMoves(for: piece, in: gameState))
        }

        return moves
    }

    private func generatePawnMoves(for piece: ChessPiece, in gameState: ChessGameState) -> [ChessMove] {
        var moves: [ChessMove] = []
        let direction = piece.color == .white ? 1 : -1

        // Forward moves
        let oneForward = piece.position.offset(file: 0, rank: direction)
        if oneForward.isValid && gameState.isSquareEmpty(oneForward) {
            moves.append(ChessMove(pieceId: piece.id, from: piece.position, to: oneForward))

            // Double forward from start
            if !piece.hasMoved {
                let twoForward = piece.position.offset(file: 0, rank: direction * 2)
                if twoForward.isValid && gameState.isSquareEmpty(twoForward) {
                    moves.append(ChessMove(pieceId: piece.id, from: piece.position, to: twoForward))
                }
            }
        }

        // Diagonal captures
        for fileDelta in [-1, 1] {
            let capturePos = piece.position.offset(file: fileDelta, rank: direction)
            if capturePos.isValid {
                if let capturedPiece = gameState.pieceAt(capturePos), capturedPiece.color != piece.color {
                    moves.append(ChessMove(pieceId: piece.id, from: piece.position, to: capturePos, capturedPieceId: capturedPiece.id))
                } else if gameState.enPassantTarget == capturePos {
                    moves.append(ChessMove(pieceId: piece.id, from: piece.position, to: capturePos, isEnPassant: true))
                }
            }
        }

        return moves
    }

    private func generateKnightMoves(for piece: ChessPiece) -> [ChessMove] {
        let offsets = [
            (2, 1), (2, -1), (-2, 1), (-2, -1),
            (1, 2), (1, -2), (-1, 2), (-1, -2)
        ]

        return offsets.compactMap { (fileDelta, rankDelta) in
            let to = piece.position.offset(file: fileDelta, rank: rankDelta)
            guard to.isValid else { return nil }
            return ChessMove(pieceId: piece.id, from: piece.position, to: to)
        }
    }

    private func generateBishopMoves(for piece: ChessPiece, in gameState: ChessGameState) -> [ChessMove] {
        return generateSlidingMoves(for: piece, directions: [(1, 1), (1, -1), (-1, 1), (-1, -1)], in: gameState)
    }

    private func generateRookMoves(for piece: ChessPiece, in gameState: ChessGameState) -> [ChessMove] {
        return generateSlidingMoves(for: piece, directions: [(0, 1), (0, -1), (1, 0), (-1, 0)], in: gameState)
    }

    private func generateQueenMoves(for piece: ChessPiece, in gameState: ChessGameState) -> [ChessMove] {
        let directions = [(0, 1), (0, -1), (1, 0), (-1, 0), (1, 1), (1, -1), (-1, 1), (-1, -1)]
        return generateSlidingMoves(for: piece, directions: directions, in: gameState)
    }

    private func generateKingMoves(for piece: ChessPiece, in gameState: ChessGameState) -> [ChessMove] {
        var moves: [ChessMove] = []

        // Regular moves (one square in any direction)
        for fileDelta in -1...1 {
            for rankDelta in -1...1 {
                if fileDelta == 0 && rankDelta == 0 { continue }
                let to = piece.position.offset(file: fileDelta, rank: rankDelta)
                if to.isValid {
                    moves.append(ChessMove(pieceId: piece.id, from: piece.position, to: to))
                }
            }
        }

        // Castling
        if !piece.hasMoved {
            // Kingside
            let kingsideTo = piece.position.offset(file: 2, rank: 0)
            if kingsideTo.isValid {
                moves.append(ChessMove(pieceId: piece.id, from: piece.position, to: kingsideTo, isCastle: true))
            }

            // Queenside
            let queensideTo = piece.position.offset(file: -2, rank: 0)
            if queensideTo.isValid {
                moves.append(ChessMove(pieceId: piece.id, from: piece.position, to: queensideTo, isCastle: true))
            }
        }

        return moves
    }

    private func generateSlidingMoves(for piece: ChessPiece, directions: [(Int, Int)], in gameState: ChessGameState) -> [ChessMove] {
        var moves: [ChessMove] = []

        for (fileDelta, rankDelta) in directions {
            var distance = 1
            while true {
                let to = piece.position.offset(file: fileDelta * distance, rank: rankDelta * distance)
                guard to.isValid else { break }

                if gameState.isSquareEmpty(to) {
                    moves.append(ChessMove(pieceId: piece.id, from: piece.position, to: to))
                    distance += 1
                } else {
                    // Blocked by piece - can capture if enemy
                    if let capturedPiece = gameState.pieceAt(to), capturedPiece.color != piece.color {
                        moves.append(ChessMove(pieceId: piece.id, from: piece.position, to: to, capturedPieceId: capturedPiece.id))
                    }
                    break
                }
            }
        }

        return moves
    }
}

// MARK: - ChessPieceType Extensions

extension ChessPieceType {
    /// Whether this piece type slides across multiple squares
    var isSliding: Bool {
        switch self {
        case .bishop, .rook, .queen:
            return true
        case .pawn, .knight, .king:
            return false
        }
    }
}
