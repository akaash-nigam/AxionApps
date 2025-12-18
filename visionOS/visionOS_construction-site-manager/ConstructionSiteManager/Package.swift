// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ConstructionSiteManager",
    platforms: [
        .visionOS(.v2)
    ],
    products: [
        .library(
            name: "ConstructionSiteManager",
            targets: ["ConstructionSiteManager"]
        )
    ],
    dependencies: [
        // Swift Protobuf for efficient serialization
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.25.0"),

        // Swift Numerics for spatial math
        .package(url: "https://github.com/apple/swift-numerics.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "ConstructionSiteManager",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                .product(name: "Numerics", package: "swift-numerics"),
            ],
            path: ".",
            exclude: ["Tests", "UITests"]
        ),
        .testTarget(
            name: "ConstructionSiteManagerTests",
            dependencies: ["ConstructionSiteManager"],
            path: "Tests"
        ),
    ]
)
