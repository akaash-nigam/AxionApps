// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AIAgentCoordinator",
    platforms: [
        .visionOS(.v2),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "AIAgentCoordinator",
            targets: ["AIAgentCoordinator"]
        ),
    ],
    dependencies: [
        // Add any external dependencies here
    ],
    targets: [
        .target(
            name: "AIAgentCoordinator",
            dependencies: [],
            path: "AIAgentCoordinator",
            exclude: ["Tests"],
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "AIAgentCoordinatorTests",
            dependencies: ["AIAgentCoordinator"],
            path: "AIAgentCoordinator/Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)
