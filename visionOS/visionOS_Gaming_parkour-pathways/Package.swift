// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ParkourPathways",
    platforms: [
        .visionOS(.v2)
    ],
    products: [
        .library(
            name: "ParkourPathways",
            targets: ["ParkourPathways"]
        )
    ],
    dependencies: [
        // Add any third-party dependencies here if needed
        // For now, using only Apple frameworks
    ],
    targets: [
        .target(
            name: "ParkourPathways",
            dependencies: [],
            path: "ParkourPathways",
            exclude: ["Tests"],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "ParkourPathwaysTests",
            dependencies: ["ParkourPathways"],
            path: "ParkourPathways/Tests"
        )
    ]
)
