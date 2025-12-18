// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SupplyChainControlTower",
    platforms: [
        .visionOS(.v2)
    ],
    products: [
        .library(
            name: "SupplyChainControlTower",
            targets: ["SupplyChainControlTower"]
        )
    ],
    dependencies: [
        // Add any external dependencies here
        // Example:
        // .package(url: "https://github.com/example/package.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "SupplyChainControlTower",
            dependencies: [],
            path: ".",
            exclude: [
                "Tests",
                "UITests",
                "Resources/Preview Content",
                "README.md",
                "TESTING.md",
                ".swiftlint.yml"
            ],
            sources: [
                "App",
                "Models",
                "Views",
                "ViewModels",
                "Services",
                "Utilities"
            ],
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "SupplyChainControlTowerTests",
            dependencies: ["SupplyChainControlTower"],
            path: "Tests",
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableExperimentalFeature("StrictConcurrency")
            ]
        )
    ],
    swiftLanguageVersions: [.v6]
)
