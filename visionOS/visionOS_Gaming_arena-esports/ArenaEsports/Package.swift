// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ArenaEsports",
    platforms: [
        .visionOS(.v2)
    ],
    products: [
        .library(
            name: "ArenaEsports",
            targets: ["ArenaEsports"]
        ),
    ],
    dependencies: [
        // Add external dependencies here if needed
    ],
    targets: [
        .target(
            name: "ArenaEsports",
            dependencies: [],
            path: ".",
            exclude: ["Tests"],
            sources: [
                "App",
                "Game",
                "Systems",
                "Scenes",
                "Views",
                "Models"
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .enableUpcomingFeature("BareSlashRegexLiterals"),
            ]
        ),
        .testTarget(
            name: "ArenaEsportsTests",
            dependencies: ["ArenaEsports"],
            path: "Tests",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
