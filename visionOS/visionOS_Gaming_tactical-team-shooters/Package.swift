// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TacticalTeamShooters",
    platforms: [
        .visionOS(.v2)
    ],
    products: [
        .library(
            name: "TacticalTeamShooters",
            targets: ["TacticalTeamShooters"]
        ),
    ],
    dependencies: [
        // No external dependencies - using Apple frameworks only
    ],
    targets: [
        .target(
            name: "TacticalTeamShooters",
            dependencies: [],
            path: "TacticalTeamShooters",
            exclude: ["Tests", "Resources/Info.plist", "Systems/NetworkManager.swift"],
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .testTarget(
            name: "TacticalTeamShootersTests",
            dependencies: ["TacticalTeamShooters"],
            path: "TacticalTeamShooters/Tests"
        ),
    ]
)
