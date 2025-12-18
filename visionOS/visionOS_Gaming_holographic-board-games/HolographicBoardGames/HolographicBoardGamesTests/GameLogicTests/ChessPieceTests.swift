//
//  ChessPieceTests.swift
//  HolographicBoardGamesTests
//
//  Unit tests for ChessPiece
//

import XCTest
@testable import HolographicBoardGames

final class ChessPieceTests: XCTestCase {

    // MARK: - Initialization Tests

    func testInitWithParameters() {
        let position = BoardPosition(file: 4, rank: 3)
        let piece = ChessPiece(
            type: .pawn,
            color: .white,
            position: position,
            hasMoved: false
        )

        XCTAssertEqual(piece.type, .pawn)
        XCTAssertEqual(piece.color, .white)
        XCTAssertEqual(piece.position, position)
        XCTAssertFalse(piece.hasMoved)
    }

    func testInitWithNotation() {
        let position = BoardPosition("e4")!

        let whitePawn = ChessPiece(notation: "wP", position: position)
        XCTAssertNotNil(whitePawn)
        XCTAssertEqual(whitePawn?.type, .pawn)
        XCTAssertEqual(whitePawn?.color, .white)

        let blackKnight = ChessPiece(notation: "bN", position: position)
        XCTAssertNotNil(blackKnight)
        XCTAssertEqual(blackKnight?.type, .knight)
        XCTAssertEqual(blackKnight?.color, .black)

        let whiteQueen = ChessPiece(notation: "wQ", position: position)
        XCTAssertNotNil(whiteQueen)
        XCTAssertEqual(whiteQueen?.type, .queen)
        XCTAssertEqual(whiteQueen?.color, .white)
    }

    func testInitWithInvalidNotation() {
        let position = BoardPosition("e4")!

        XCTAssertNil(ChessPiece(notation: "xx", position: position))
        XCTAssertNil(ChessPiece(notation: "w", position: position))
        XCTAssertNil(ChessPiece(notation: "", position: position))
        XCTAssertNil(ChessPiece(notation: "wX", position: position))
    }

    // MARK: - Notation Tests

    func testNotationGeneration() {
        let position = BoardPosition("e4")!

        let pieces: [(ChessPieceType, PlayerColor, String)] = [
            (.pawn, .white, "wP"),
            (.knight, .white, "wN"),
            (.bishop, .white, "wB"),
            (.rook, .white, "wR"),
            (.queen, .white, "wQ"),
            (.king, .white, "wK"),
            (.pawn, .black, "bP"),
            (.knight, .black, "bN"),
            (.bishop, .black, "bB"),
            (.rook, .black, "bR"),
            (.queen, .black, "bQ"),
            (.king, .black, "bK")
        ]

        for (type, color, expectedNotation) in pieces {
            let piece = ChessPiece(type: type, color: color, position: position)
            XCTAssertEqual(piece.notation, expectedNotation)
        }
    }

    // MARK: - Material Value Tests

    func testMaterialValues() {
        XCTAssertEqual(ChessPieceType.pawn.materialValue, 1)
        XCTAssertEqual(ChessPieceType.knight.materialValue, 3)
        XCTAssertEqual(ChessPieceType.bishop.materialValue, 3)
        XCTAssertEqual(ChessPieceType.rook.materialValue, 5)
        XCTAssertEqual(ChessPieceType.queen.materialValue, 9)
        XCTAssertEqual(ChessPieceType.king.materialValue, 0)
    }

    // MARK: - PlayerColor Tests

    func testOppositeColor() {
        XCTAssertEqual(PlayerColor.white.opposite, .black)
        XCTAssertEqual(PlayerColor.black.opposite, .white)
    }

    // MARK: - Equality Tests

    func testEquality() {
        let position = BoardPosition("e4")!
        let id = UUID()

        let piece1 = ChessPiece(id: id, type: .pawn, color: .white, position: position)
        let piece2 = ChessPiece(id: id, type: .pawn, color: .white, position: position)
        let piece3 = ChessPiece(type: .pawn, color: .white, position: position)

        XCTAssertEqual(piece1, piece2)
        XCTAssertNotEqual(piece1, piece3)  // Different IDs
    }

    // MARK: - Codable Tests

    func testCodable() throws {
        let position = BoardPosition("e4")!
        let piece = ChessPiece(type: .queen, color: .white, position: position, hasMoved: true)

        let encoder = JSONEncoder()
        let data = try encoder.encode(piece)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ChessPiece.self, from: data)

        XCTAssertEqual(piece.id, decoded.id)
        XCTAssertEqual(piece.type, decoded.type)
        XCTAssertEqual(piece.color, decoded.color)
        XCTAssertEqual(piece.position, decoded.position)
        XCTAssertEqual(piece.hasMoved, decoded.hasMoved)
    }
}
