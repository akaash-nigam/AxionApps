// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HolographicBoardGames",
    platforms: [
        .visionOS(.v1)
    ],
    products: [
        .executable(
            name: "HolographicBoardGames",
            targets: ["HolographicBoardGames"]
        )
    ],
    targets: [
        .executableTarget(
            name: "HolographicBoardGames",
            path: "HolographicBoardGames"
        )
    ]
)
