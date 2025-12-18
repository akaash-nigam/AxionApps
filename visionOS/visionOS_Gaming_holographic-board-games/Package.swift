// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HolographicBoardGames",
    platforms: [
        .visionOS(.v1),
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "HolographicBoardGames",
            targets: ["HolographicBoardGames"]
        ),
    ],
    dependencies: [
        // Add external dependencies here if needed
        // Example: .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "HolographicBoardGames",
            dependencies: [],
            path: "HolographicBoardGames/HolographicBoardGames",
            exclude: [
                "Info.plist"
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .testTarget(
            name: "HolographicBoardGamesTests",
            dependencies: ["HolographicBoardGames"],
            path: "HolographicBoardGames/HolographicBoardGamesTests",
            exclude: [
                "Info.plist"
            ]
        ),
    ]
)
