//
//  ChessGameStateTests.swift
//  HolographicBoardGamesTests
//
//  Unit tests for ChessGameState
//

import XCTest
@testable import HolographicBoardGames

final class ChessGameStateTests: XCTestCase {

    // MARK: - Initialization Tests

    func testNewGameHas32Pieces() {
        let state = ChessGameState.newGame()

        XCTAssertEqual(state.pieces.count, 32)
    }

    func testNewGameHas16WhitePieces() {
        let state = ChessGameState.newGame()
        let whitePieces = state.getPieces(color: .white)

        XCTAssertEqual(whitePieces.count, 16)
    }

    func testNewGameHas16BlackPieces() {
        let state = ChessGameState.newGame()
        let blackPieces = state.getPieces(color: .black)

        XCTAssertEqual(blackPieces.count, 16)
    }

    func testNewGameWhiteStarts() {
        let state = ChessGameState.newGame()

        XCTAssertEqual(state.currentPlayer, .white)
    }

    func testNewGameStatusIsInProgress() {
        let state = ChessGameState.newGame()

        XCTAssertEqual(state.gameStatus, .inProgress)
    }

    // MARK: - Starting Position Tests

    func testWhiteKingStartsOnE1() {
        let state = ChessGameState.newGame()
        let piece = state.pieceAt(BoardPosition("e1")!)

        XCTAssertNotNil(piece)
        XCTAssertEqual(piece?.type, .king)
        XCTAssertEqual(piece?.color, .white)
    }

    func testBlackQueenStartsOnD8() {
        let state = ChessGameState.newGame()
        let piece = state.pieceAt(BoardPosition("d8")!)

        XCTAssertNotNil(piece)
        XCTAssertEqual(piece?.type, .queen)
        XCTAssertEqual(piece?.color, .black)
    }

    func testWhitePawnsOnRank2() {
        let state = ChessGameState.newGame()

        for file in 0..<8 {
            let position = BoardPosition(file: file, rank: 1)
            let piece = state.pieceAt(position)

            XCTAssertNotNil(piece)
            XCTAssertEqual(piece?.type, .pawn)
            XCTAssertEqual(piece?.color, .white)
        }
    }

    func testBlackPawnsOnRank7() {
        let state = ChessGameState.newGame()

        for file in 0..<8 {
            let position = BoardPosition(file: file, rank: 6)
            let piece = state.pieceAt(position)

            XCTAssertNotNil(piece)
            XCTAssertEqual(piece?.type, .pawn)
            XCTAssertEqual(piece?.color, .black)
        }
    }

    func testCenterSquaresAreEmpty() {
        let state = ChessGameState.newGame()

        let emptySquares = [
            "e4", "e5", "d4", "d5",
            "c3", "c4", "c5", "c6",
            "f3", "f4", "f5", "f6"
        ]

        for square in emptySquares {
            let position = BoardPosition(square)!
            XCTAssertTrue(state.isSquareEmpty(position), "Square \(square) should be empty")
        }
    }

    // MARK: - Board Query Tests

    func testPieceAtPosition() {
        let state = ChessGameState.newGame()

        let rook = state.pieceAt(BoardPosition("a1")!)
        XCTAssertEqual(rook?.type, .rook)
        XCTAssertEqual(rook?.color, .white)

        let empty = state.pieceAt(BoardPosition("e4")!)
        XCTAssertNil(empty)
    }

    func testIsSquareEmpty() {
        let state = ChessGameState.newGame()

        XCTAssertTrue(state.isSquareEmpty(BoardPosition("e4")!))
        XCTAssertFalse(state.isSquareEmpty(BoardPosition("e1")!))
    }

    func testHasEnemyPiece() {
        let state = ChessGameState.newGame()

        // White pawn vs black pawn
        XCTAssertTrue(state.hasEnemyPiece(at: BoardPosition("e7")!, enemyOf: .white))
        XCTAssertFalse(state.hasEnemyPiece(at: BoardPosition("e2")!, enemyOf: .white))
        XCTAssertFalse(state.hasEnemyPiece(at: BoardPosition("e4")!, enemyOf: .white))
    }

    func testFindKing() {
        let state = ChessGameState.newGame()

        let whiteKing = state.findKing(color: .white)
        XCTAssertNotNil(whiteKing)
        XCTAssertEqual(whiteKing?.position, BoardPosition("e1")!)

        let blackKing = state.findKing(color: .black)
        XCTAssertNotNil(blackKing)
        XCTAssertEqual(blackKing?.position, BoardPosition("e8")!)
    }

    // MARK: - Mutation Tests

    func testAddPiece() {
        var state = ChessGameState()
        let position = BoardPosition("e4")!
        let piece = ChessPiece(type: .queen, color: .white, position: position)

        state.addPiece(piece)

        XCTAssertEqual(state.pieces.count, 1)
        XCTAssertEqual(state.pieceAt(position)?.id, piece.id)
    }

    func testRemovePiece() {
        var state = ChessGameState.newGame()
        let position = BoardPosition("e2")!

        let removed = state.removePiece(at: position)

        XCTAssertNotNil(removed)
        XCTAssertEqual(removed?.type, .pawn)
        XCTAssertTrue(state.isSquareEmpty(position))
        XCTAssertEqual(state.pieces.count, 31)
    }

    func testMovePiece() {
        var state = ChessGameState.newGame()
        let from = BoardPosition("e2")!
        let to = BoardPosition("e4")!

        let captured = state.movePiece(from: from, to: to)

        XCTAssertNil(captured)  // No capture
        XCTAssertTrue(state.isSquareEmpty(from))
        XCTAssertFalse(state.isSquareEmpty(to))

        let movedPiece = state.pieceAt(to)
        XCTAssertEqual(movedPiece?.type, .pawn)
        XCTAssertTrue(movedPiece?.hasMoved ?? false)
    }

    func testMovePieceWithCapture() {
        var state = ChessGameState()

        // Place white pawn on e4
        let whitePawn = ChessPiece(type: .pawn, color: .white, position: BoardPosition("e4")!)
        state.addPiece(whitePawn)

        // Place black pawn on d5
        let blackPawn = ChessPiece(type: .pawn, color: .black, position: BoardPosition("d5")!)
        state.addPiece(blackPawn)

        // Move white pawn to capture black pawn
        let captured = state.movePiece(from: BoardPosition("e4")!, to: BoardPosition("d5")!)

        XCTAssertNotNil(captured)
        XCTAssertEqual(captured?.color, .black)
        XCTAssertEqual(state.pieces.count, 1)  // Only white pawn remains
    }

    func testSwitchPlayer() {
        var state = ChessGameState.newGame()

        XCTAssertEqual(state.currentPlayer, .white)
        XCTAssertEqual(state.fullMoveNumber, 1)

        state.switchPlayer()
        XCTAssertEqual(state.currentPlayer, .black)
        XCTAssertEqual(state.fullMoveNumber, 1)  // Same move number

        state.switchPlayer()
        XCTAssertEqual(state.currentPlayer, .white)
        XCTAssertEqual(state.fullMoveNumber, 2)  // Increments on white's turn
    }

    // MARK: - Material Tests

    func testInitialMaterialCount() {
        let state = ChessGameState.newGame()

        let whiteMaterial = state.materialCount(for: .white)
        let blackMaterial = state.materialCount(for: .black)

        // 8 pawns + 2 knights + 2 bishops + 2 rooks + 1 queen
        // = 8*1 + 2*3 + 2*3 + 2*5 + 1*9 = 8 + 6 + 6 + 10 + 9 = 39
        XCTAssertEqual(whiteMaterial, 39)
        XCTAssertEqual(blackMaterial, 39)
    }

    func testMaterialAdvantage() {
        let state = ChessGameState.newGame()

        let whiteAdvantage = state.materialAdvantage(for: .white)
        let blackAdvantage = state.materialAdvantage(for: .black)

        XCTAssertEqual(whiteAdvantage, 0)
        XCTAssertEqual(blackAdvantage, 0)
    }

    func testMaterialAdvantageAfterCapture() {
        var state = ChessGameState()

        // White has queen
        state.addPiece(ChessPiece(type: .queen, color: .white, position: BoardPosition("d1")!))

        // Black has only pawns
        state.addPiece(ChessPiece(type: .pawn, color: .black, position: BoardPosition("e7")!))

        let whiteAdvantage = state.materialAdvantage(for: .white)
        XCTAssertEqual(whiteAdvantage, 8)  // 9 - 1
    }

    // MARK: - Game State Tests

    func testIsGameOver() {
        var state = ChessGameState.newGame()

        XCTAssertFalse(state.isGameOver)

        state.gameStatus = .checkmate(winner: .white)
        XCTAssertTrue(state.isGameOver)

        state.gameStatus = .stalemate
        XCTAssertTrue(state.isGameOver)

        state.gameStatus = .draw(reason: .fiftyMoveRule)
        XCTAssertTrue(state.isGameOver)
    }

    func testWinner() {
        var state = ChessGameState.newGame()

        XCTAssertNil(state.winner)

        state.gameStatus = .checkmate(winner: .white)
        XCTAssertEqual(state.winner, .white)

        state.gameStatus = .stalemate
        XCTAssertNil(state.winner)
    }

    // MARK: - Castling Rights Tests

    func testInitialCastlingRights() {
        let state = ChessGameState.newGame()

        XCTAssertTrue(state.whiteKingsideCastle)
        XCTAssertTrue(state.whiteQueensideCastle)
        XCTAssertTrue(state.blackKingsideCastle)
        XCTAssertTrue(state.blackQueensideCastle)
    }

    // MARK: - Codable Tests

    func testCodable() throws {
        let state = ChessGameState.newGame()

        let encoder = JSONEncoder()
        let data = try encoder.encode(state)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ChessGameState.self, from: data)

        XCTAssertEqual(state.pieces.count, decoded.pieces.count)
        XCTAssertEqual(state.currentPlayer, decoded.currentPlayer)
        XCTAssertEqual(state.gameStatus, decoded.gameStatus)
    }
}
