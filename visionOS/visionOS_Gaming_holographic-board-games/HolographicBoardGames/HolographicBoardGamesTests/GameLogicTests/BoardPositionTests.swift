//
//  BoardPositionTests.swift
//  HolographicBoardGamesTests
//
//  Unit tests for BoardPosition
//

import XCTest
@testable import HolographicBoardGames

final class BoardPositionTests: XCTestCase {

    // MARK: - Initialization Tests

    func testInitWithFileAndRank() {
        let position = BoardPosition(file: 4, rank: 3)
        XCTAssertEqual(position.file, 4)
        XCTAssertEqual(position.rank, 3)
    }

    func testInitWithAlgebraicNotation() {
        let position = BoardPosition("e4")
        XCTAssertNotNil(position)
        XCTAssertEqual(position?.file, 4)
        XCTAssertEqual(position?.rank, 3)
    }

    func testInitWithInvalidAlgebraicNotation() {
        XCTAssertNil(BoardPosition("z9"))
        XCTAssertNil(BoardPosition("e"))
        XCTAssertNil(BoardPosition(""))
        XCTAssertNil(BoardPosition("e10"))
    }

    func testAlgebraicNotationAllSquares() {
        let files = ["a", "b", "c", "d", "e", "f", "g", "h"]

        for file in 0..<8 {
            for rank in 0..<8 {
                let position = BoardPosition(file: file, rank: rank)
                let expected = "\(files[file])\(rank + 1)"
                XCTAssertEqual(position.algebraic, expected)
            }
        }
    }

    // MARK: - Validation Tests

    func testIsValid() {
        XCTAssertTrue(BoardPosition(file: 0, rank: 0).isValid)
        XCTAssertTrue(BoardPosition(file: 7, rank: 7).isValid)
        XCTAssertTrue(BoardPosition(file: 3, rank: 4).isValid)

        XCTAssertFalse(BoardPosition(file: -1, rank: 0).isValid)
        XCTAssertFalse(BoardPosition(file: 0, rank: -1).isValid)
        XCTAssertFalse(BoardPosition(file: 8, rank: 0).isValid)
        XCTAssertFalse(BoardPosition(file: 0, rank: 8).isValid)
        XCTAssertFalse(BoardPosition(file: -1, rank: -1).isValid)
        XCTAssertFalse(BoardPosition(file: 10, rank: 10).isValid)
    }

    // MARK: - Offset Tests

    func testOffset() {
        let start = BoardPosition(file: 4, rank: 3)  // e4

        let oneUp = start.offset(file: 0, rank: 1)
        XCTAssertEqual(oneUp.algebraic, "e5")

        let oneRight = start.offset(file: 1, rank: 0)
        XCTAssertEqual(oneRight.algebraic, "f4")

        let diagonal = start.offset(file: 1, rank: 1)
        XCTAssertEqual(diagonal.algebraic, "f5")

        let knightMove = start.offset(file: 2, rank: 1)
        XCTAssertEqual(knightMove.algebraic, "g5")
    }

    // MARK: - Distance Tests

    func testManhattanDistance() {
        let e4 = BoardPosition("e4")!
        let e5 = BoardPosition("e5")!
        let f5 = BoardPosition("f5")!
        let a1 = BoardPosition("a1")!

        XCTAssertEqual(e4.distance(to: e5), 1)
        XCTAssertEqual(e4.distance(to: f5), 2)
        XCTAssertEqual(e4.distance(to: a1), 7)
        XCTAssertEqual(e4.distance(to: e4), 0)
    }

    func testChebyshevDistance() {
        let e4 = BoardPosition("e4")!
        let e5 = BoardPosition("e5")!
        let f5 = BoardPosition("f5")!
        let a1 = BoardPosition("a1")!
        let h1 = BoardPosition("h1")!

        XCTAssertEqual(e4.chebyshevDistance(to: e5), 1)
        XCTAssertEqual(e4.chebyshevDistance(to: f5), 1)
        XCTAssertEqual(e4.chebyshevDistance(to: a1), 4)
        XCTAssertEqual(e4.chebyshevDistance(to: h1), 3)
        XCTAssertEqual(e4.chebyshevDistance(to: e4), 0)
    }

    // MARK: - Equality Tests

    func testEquality() {
        let pos1 = BoardPosition(file: 4, rank: 3)
        let pos2 = BoardPosition(file: 4, rank: 3)
        let pos3 = BoardPosition(file: 4, rank: 4)

        XCTAssertEqual(pos1, pos2)
        XCTAssertNotEqual(pos1, pos3)
    }

    func testHashable() {
        let pos1 = BoardPosition(file: 4, rank: 3)
        let pos2 = BoardPosition(file: 4, rank: 3)
        let pos3 = BoardPosition(file: 4, rank: 4)

        var set: Set<BoardPosition> = []
        set.insert(pos1)
        set.insert(pos2)
        set.insert(pos3)

        XCTAssertEqual(set.count, 2)  // pos1 and pos2 are the same
        XCTAssertTrue(set.contains(pos1))
        XCTAssertTrue(set.contains(pos3))
    }

    // MARK: - Codable Tests

    func testCodable() throws {
        let position = BoardPosition(file: 4, rank: 3)

        let encoder = JSONEncoder()
        let data = try encoder.encode(position)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(BoardPosition.self, from: data)

        XCTAssertEqual(position, decoded)
    }
}
