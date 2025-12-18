// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SpatialCRM",
    platforms: [
        .visionOS(.v2)
    ],
    products: [
        .library(
            name: "SpatialCRM",
            targets: ["SpatialCRM"]
        ),
    ],
    dependencies: [
        // Add external dependencies here if needed
        // .package(url: "https://github.com/example/package.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "SpatialCRM",
            dependencies: [],
            path: "SpatialCRM"
        ),
        .testTarget(
            name: "SpatialCRMTests",
            dependencies: ["SpatialCRM"],
            path: "SpatialCRM/Tests"
        ),
    ]
)
