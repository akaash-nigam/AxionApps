//
//  BoardPosition.swift
//  HolographicBoardGames
//
//  Represents a position on the chess board
//

import Foundation

struct BoardPosition: Hashable, Codable, CustomStringConvertible {
    let file: Int  // 0-7 (a-h)
    let rank: Int  // 0-7 (1-8)

    init(file: Int, rank: Int) {
        self.file = file
        self.rank = rank
    }

    /// Initialize from algebraic notation (e.g., "e4")
    init?(_ algebraic: String) {
        guard algebraic.count == 2 else { return nil }

        let chars = Array(algebraic.lowercased())
        guard let fileChar = chars.first,
              let rankChar = chars.last,
              let file = "abcdefgh".firstIndex(of: fileChar),
              let rank = Int(String(rankChar)) else {
            return nil
        }

        self.file = "abcdefgh".distance(from: "abcdefgh".startIndex, to: file)
        self.rank = rank - 1
    }

    /// Algebraic notation (e.g., "e4")
    var algebraic: String {
        let files = ["a", "b", "c", "d", "e", "f", "g", "h"]
        guard file >= 0 && file < 8 && rank >= 0 && rank < 8 else {
            return "??"
        }
        return "\(files[file])\(rank + 1)"
    }

    /// Check if position is within valid board bounds
    var isValid: Bool {
        file >= 0 && file < 8 && rank >= 0 && rank < 8
    }

    /// Get adjacent position by offset
    func offset(file fileOffset: Int, rank rankOffset: Int) -> BoardPosition {
        BoardPosition(file: file + fileOffset, rank: rank + rankOffset)
    }

    /// Calculate Manhattan distance to another position
    func distance(to other: BoardPosition) -> Int {
        abs(file - other.file) + abs(rank - other.rank)
    }

    /// Calculate Chebyshev distance (king moves) to another position
    func chebyshevDistance(to other: BoardPosition) -> Int {
        max(abs(file - other.file), abs(rank - other.rank))
    }

    // MARK: - CustomStringConvertible

    var description: String {
        algebraic
    }
}
