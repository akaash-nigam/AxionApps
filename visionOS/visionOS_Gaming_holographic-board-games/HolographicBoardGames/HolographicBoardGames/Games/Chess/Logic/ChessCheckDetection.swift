//
//  ChessCheckDetection.swift
//  HolographicBoardGames
//
//  Check, checkmate, and stalemate detection
//

import Foundation

extension ChessRulesEngine {

    // MARK: - Check Detection

    /// Determine if the specified color's king is in check
    func isKingInCheck(color: PlayerColor, in gameState: ChessGameState) -> Bool {
        guard let king = gameState.findKing(color: color) else {
            // King not found - should never happen in valid game
            return false
        }

        let kingPosition = king.position

        // Check if any opponent piece can attack the king
        let opponentPieces = gameState.getPieces(color: color.opposite)

        for piece in opponentPieces {
            if canPieceAttack(piece: piece, target: kingPosition, in: gameState) {
                return true
            }
        }

        return false
    }

    /// Check if a piece can attack a target position
    private func canPieceAttack(piece: ChessPiece, target: BoardPosition, in gameState: ChessGameState) -> Bool {
        switch piece.type {
        case .pawn:
            return canPawnAttack(piece: piece, target: target)
        case .knight:
            return isValidKnightMove(from: piece.position, to: target)
        case .bishop:
            return isValidBishopMove(from: piece.position, to: target) &&
                   isPathClear(from: piece.position, to: target, in: gameState)
        case .rook:
            return isValidRookMove(from: piece.position, to: target) &&
                   isPathClear(from: piece.position, to: target, in: gameState)
        case .queen:
            return isValidQueenMove(from: piece.position, to: target) &&
                   isPathClear(from: piece.position, to: target, in: gameState)
        case .king:
            let fileDiff = abs(target.file - piece.position.file)
            let rankDiff = abs(target.rank - piece.position.rank)
            return fileDiff <= 1 && rankDiff <= 1
        }
    }

    /// Check if pawn can attack a target (diagonal only)
    private func canPawnAttack(piece: ChessPiece, target: BoardPosition) -> Bool {
        let direction = piece.color == .white ? 1 : -1
        let fileDiff = abs(target.file - piece.position.file)
        let rankDiff = target.rank - piece.position.rank

        return fileDiff == 1 && rankDiff == direction
    }

    // MARK: - Move Validation with Check

    /// Validate if a move would leave the king in check
    func wouldMoveLeaveKingInCheck(_ move: ChessMove, in gameState: ChessGameState) -> Bool {
        // Simulate the move
        var tempState = gameState
        _ = tempState.movePiece(from: move.from, to: move.to)

        // Check if current player's king is in check after the move
        return isKingInCheck(color: gameState.currentPlayer, in: tempState)
    }

    /// Validate if a move is legal (including check rules)
    func isLegalMove(_ move: ChessMove, in gameState: ChessGameState) -> Bool {
        // First check basic move validity
        guard isValidMove(move, in: gameState) else { return false }

        // Then check if it would leave king in check
        return !wouldMoveLeaveKingInCheck(move, in: gameState)
    }

    /// Generate all truly legal moves (excluding moves that leave king in check)
    func allLegalMovesWithCheckValidation(in gameState: ChessGameState) -> [ChessMove] {
        let candidateMoves = allLegalMoves(in: gameState)
        return candidateMoves.filter { !wouldMoveLeaveKingInCheck($0, in: gameState) }
    }

    // MARK: - Checkmate Detection

    /// Determine if the current player is in checkmate
    func isCheckmate(in gameState: ChessGameState) -> Bool {
        // Must be in check
        guard isKingInCheck(color: gameState.currentPlayer, in: gameState) else {
            return false
        }

        // No legal moves available
        return allLegalMovesWithCheckValidation(in: gameState).isEmpty
    }

    /// Determine if the current player is in stalemate
    func isStalemate(in gameState: ChessGameState) -> Bool {
        // Must NOT be in check
        guard !isKingInCheck(color: gameState.currentPlayer, in: gameState) else {
            return false
        }

        // No legal moves available
        return allLegalMovesWithCheckValidation(in: gameState).isEmpty
    }

    // MARK: - Game State Analysis

    /// Analyze the current game state and return appropriate status
    func analyzeGameState(_ gameState: ChessGameState) -> ChessGameState.GameStatus {
        let currentPlayerInCheck = isKingInCheck(color: gameState.currentPlayer, in: gameState)
        let hasLegalMoves = !allLegalMovesWithCheckValidation(in: gameState).isEmpty

        if !hasLegalMoves {
            if currentPlayerInCheck {
                // Checkmate - opponent wins
                return .checkmate(winner: gameState.currentPlayer.opposite)
            } else {
                // Stalemate - draw
                return .stalemate
            }
        }

        if currentPlayerInCheck {
            return .check(gameState.currentPlayer)
        }

        // Check for draw by insufficient material
        if hasInsufficientMaterial(in: gameState) {
            return .draw(reason: .insufficientMaterial)
        }

        // Check for fifty-move rule
        if gameState.halfMoveClock >= 100 { // 50 moves = 100 half-moves
            return .draw(reason: .fiftyMoveRule)
        }

        return .inProgress
    }

    // MARK: - Draw Detection

    /// Check if there is insufficient material to checkmate
    func hasInsufficientMaterial(in gameState: ChessGameState) -> Bool {
        let whitePieces = gameState.getPieces(color: .white)
        let blackPieces = gameState.getPieces(color: .black)

        // King vs King
        if whitePieces.count == 1 && blackPieces.count == 1 {
            return true
        }

        // King and Bishop/Knight vs King
        if (whitePieces.count == 2 && blackPieces.count == 1) ||
           (whitePieces.count == 1 && blackPieces.count == 2) {
            let allPieces = whitePieces + blackPieces
            let nonKingPieces = allPieces.filter { $0.type != .king }

            if nonKingPieces.count == 1 {
                let piece = nonKingPieces[0]
                if piece.type == .bishop || piece.type == .knight {
                    return true
                }
            }
        }

        // King and Bishop vs King and Bishop (same color squares)
        if whitePieces.count == 2 && blackPieces.count == 2 {
            let whiteBishops = whitePieces.filter { $0.type == .bishop }
            let blackBishops = blackPieces.filter { $0.type == .bishop }

            if whiteBishops.count == 1 && blackBishops.count == 1 {
                let whiteSquareColor = (whiteBishops[0].position.file + whiteBishops[0].position.rank) % 2
                let blackSquareColor = (blackBishops[0].position.file + blackBishops[0].position.rank) % 2

                if whiteSquareColor == blackSquareColor {
                    return true
                }
            }
        }

        return false
    }

    // MARK: - Attack Detection Helpers

    /// Get all squares attacked by a specific color
    func attackedSquares(by color: PlayerColor, in gameState: ChessGameState) -> Set<BoardPosition> {
        var attacked = Set<BoardPosition>()
        let pieces = gameState.getPieces(color: color)

        for piece in pieces {
            for file in 0..<8 {
                for rank in 0..<8 {
                    let position = BoardPosition(file: file, rank: rank)
                    if canPieceAttack(piece: piece, target: position, in: gameState) {
                        attacked.insert(position)
                    }
                }
            }
        }

        return attacked
    }

    /// Check if a square is under attack by the specified color
    func isSquareUnderAttack(_ position: BoardPosition, by color: PlayerColor, in gameState: ChessGameState) -> Bool {
        let pieces = gameState.getPieces(color: color)

        for piece in pieces {
            if canPieceAttack(piece: piece, target: position, in: gameState) {
                return true
            }
        }

        return false
    }

    /// Validate castling doesn't move through check
    func isCastlingLegal(_ move: ChessMove, in gameState: ChessGameState) -> Bool {
        guard let piece = gameState.pieceAt(move.from),
              piece.type == .king else { return false }

        // King cannot be in check
        if isKingInCheck(color: piece.color, in: gameState) {
            return false
        }

        let isKingside = move.to.file > move.from.file
        let direction = isKingside ? 1 : -1

        // King cannot pass through or land on attacked square
        for i in 0...2 {
            let checkPosition = BoardPosition(file: move.from.file + (i * direction), rank: move.from.rank)
            if isSquareUnderAttack(checkPosition, by: piece.color.opposite, in: gameState) {
                return false
            }
        }

        return true
    }
}
