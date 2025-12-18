// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CityBuilderTabletop",
    platforms: [
        .visionOS(.v2)
    ],
    products: [
        .library(
            name: "CityBuilderTabletop",
            targets: ["CityBuilderTabletop"]
        ),
    ],
    dependencies: [
        // No external dependencies - using native frameworks only
    ],
    targets: [
        .target(
            name: "CityBuilderTabletop",
            dependencies: [],
            path: ".",
            exclude: [
                "Tests",
                "Resources",
                "README.md",
                "Package.swift"
            ],
            sources: [
                "App",
                "Game",
                "Models",
                "Scenes",
                "Systems",
                "Utilities",
                "Views"
            ]
        ),
        .testTarget(
            name: "CityBuilderTabletopTests",
            dependencies: ["CityBuilderTabletop"],
            path: "Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)
