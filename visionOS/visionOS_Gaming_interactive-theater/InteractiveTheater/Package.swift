// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "InteractiveTheater",
    platforms: [
        .visionOS(.v2)
    ],
    products: [
        .library(
            name: "InteractiveTheater",
            targets: ["InteractiveTheater"]
        ),
    ],
    dependencies: [
        // Add external dependencies here if needed
    ],
    targets: [
        .target(
            name: "InteractiveTheater",
            dependencies: [],
            path: "InteractiveTheater",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "InteractiveTheaterTests",
            dependencies: ["InteractiveTheater"],
            path: "InteractiveTheaterTests"
        ),
    ]
)
