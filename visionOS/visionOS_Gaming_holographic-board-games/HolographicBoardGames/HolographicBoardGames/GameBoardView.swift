import SwiftUI
import RealityKit

struct GameBoardView: View {
    @State private var currentPlayer = 1
    @State private var moveCount = 0

    var body: some View {
        RealityView { content in
            // Create chess board
            let board = createChessBoard()
            board.position = [0, 1, -1.5]
            content.add(board)

            // Add chess pieces
            let pieces = createChessPieces()
            pieces.position = [0, 1, -1.5]
            content.add(pieces)
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    handlePieceSelection(value.entity)
                }
        )
        .overlay(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Holographic Chess")
                    .font(.title)
                    .fontWeight(.bold)

                HStack {
                    Circle()
                        .fill(currentPlayer == 1 ? Color.white : Color.black)
                        .frame(width: 30, height: 30)
                    Text("Player \(currentPlayer)")
                        .font(.title3)
                }

                Text("Moves: \(moveCount)")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(15)
            .padding()
        }
    }

    private func createChessBoard() -> RealityKit.Entity {
        let board = RealityKit.Entity()

        let boardSize: Float = 0.8
        let squareSize = boardSize / 8

        for row in 0..<8 {
            for col in 0..<8 {
                let isLight = (row + col) % 2 == 0
                let color = isLight ? UIColor.white : UIColor.darkGray

                let square = ModelEntity(
                    mesh: .generateBox(width: squareSize, height: 0.02, depth: squareSize),
                    materials: [SimpleMaterial(color: color, isMetallic: false)]
                )

                let x = Float(col) * squareSize - boardSize / 2 + squareSize / 2
                let z = Float(row) * squareSize - boardSize / 2 + squareSize / 2
                square.position = [x, 0, z]

                board.addChild(square)
            }
        }

        return board
    }

    private func createChessPieces() -> RealityKit.Entity {
        let pieces = RealityKit.Entity()

        let boardSize: Float = 0.8
        let squareSize = boardSize / 8

        // Create pawns
        for col in 0..<8 {
            // White pawns
            let whitePawn = createPiece(color: .white, type: .pawn)
            let x = Float(col) * squareSize - boardSize / 2 + squareSize / 2
            whitePawn.position = [x, 0.05, -boardSize / 2 + squareSize * 1.5]
            pieces.addChild(whitePawn)

            // Black pawns
            let blackPawn = createPiece(color: .black, type: .pawn)
            blackPawn.position = [x, 0.05, boardSize / 2 - squareSize * 1.5]
            pieces.addChild(blackPawn)
        }

        // Add major pieces (rooks, knights, bishops, queen, king)
        let majorPiecePositions: [(Int, PieceType)] = [
            (0, .rook), (1, .knight), (2, .bishop), (3, .queen),
            (4, .king), (5, .bishop), (6, .knight), (7, .rook)
        ]

        for (col, pieceType) in majorPiecePositions {
            let x = Float(col) * squareSize - boardSize / 2 + squareSize / 2

            // White pieces
            let whitePiece = createPiece(color: .white, type: pieceType)
            whitePiece.position = [x, 0.05, -boardSize / 2 + squareSize * 0.5]
            pieces.addChild(whitePiece)

            // Black pieces
            let blackPiece = createPiece(color: .black, type: pieceType)
            blackPiece.position = [x, 0.05, boardSize / 2 - squareSize * 0.5]
            pieces.addChild(blackPiece)
        }

        return pieces
    }

    private func createPiece(color: UIColor, type: PieceType) -> ModelEntity {
        let height: Float = type == .pawn ? 0.06 : 0.08
        let radius: Float = 0.02

        let piece = ModelEntity(
            mesh: .generateCylinder(height: height, radius: radius),
            materials: [SimpleMaterial(color: color, isMetallic: true)]
        )

        // Add top sphere for better visibility
        let top = ModelEntity(
            mesh: .generateSphere(radius: radius * 1.2),
            materials: [SimpleMaterial(color: color, isMetallic: true)]
        )
        top.position.y = height / 2
        piece.addChild(top)

        piece.components.set(CollisionComponent(shapes: [.generateBox(size: [radius * 2, height, radius * 2])]))
        piece.components.set(InputTargetComponent())
        piece.name = "\(color == .white ? "white" : "black")-\(type.rawValue)"

        return piece
    }

    private func handlePieceSelection(_ entity: RealityKit.Entity) {
        let name = entity.name
        if !name.isEmpty && (name.contains("white") || name.contains("black")) {
            // Highlight selected piece
            entity.scale *= 1.1
            moveCount += 1
            currentPlayer = currentPlayer == 1 ? 2 : 1

            // Reset scale after a moment
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                entity.scale /= 1.1
            }
        }
    }
}

enum PieceType: String {
    case pawn, rook, knight, bishop, queen, king
}

#Preview {
    GameBoardView()
}
