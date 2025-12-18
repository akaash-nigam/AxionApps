// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LivingBuildingSystem",
    platforms: [
        .visionOS(.v2)
    ],
    products: [
        .executable(
            name: "LivingBuildingSystem",
            targets: ["LivingBuildingSystem"]
        )
    ],
    dependencies: [
        // Add any external dependencies here
    ],
    targets: [
        .executableTarget(
            name: "LivingBuildingSystem",
            dependencies: [],
            path: "Sources/LivingBuildingSystem",
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "LivingBuildingSystemTests",
            dependencies: ["LivingBuildingSystem"],
            path: "Tests/LivingBuildingSystemTests"
        )
    ]
)
