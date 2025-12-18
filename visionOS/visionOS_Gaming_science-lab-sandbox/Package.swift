// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ScienceLabSandbox",
    platforms: [
        .visionOS(.v2)
    ],
    products: [
        .library(
            name: "ScienceLabSandbox",
            targets: ["ScienceLabSandbox"]
        ),
    ],
    dependencies: [
        // No external dependencies - using only system frameworks
    ],
    targets: [
        .target(
            name: "ScienceLabSandbox",
            dependencies: [],
            path: "ScienceLabSandbox",
            exclude: ["Tests", "Resources/Info.plist"],
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "ScienceLabSandboxTests",
            dependencies: ["ScienceLabSandbox"],
            path: "ScienceLabSandbox/Tests"
        )
    ],
    swiftLanguageVersions: [.v6]
)
