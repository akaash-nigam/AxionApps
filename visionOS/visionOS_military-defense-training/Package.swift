// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MilitaryDefenseTraining",
    platforms: [
        .visionOS(.v2)
    ],
    products: [
        .library(
            name: "MilitaryDefenseTraining",
            targets: ["MilitaryDefenseTraining"]
        ),
    ],
    dependencies: [
        // Swift Collections for optimized data structures
        .package(
            url: "https://github.com/apple/swift-collections",
            from: "1.0.0"
        ),
        // Swift Algorithms for performance
        .package(
            url: "https://github.com/apple/swift-algorithms",
            from: "1.0.0"
        ),
        // Numerics for ballistics calculations
        .package(
            url: "https://github.com/apple/swift-numerics",
            from: "1.0.0"
        )
    ],
    targets: [
        .target(
            name: "MilitaryDefenseTraining",
            dependencies: [
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Numerics", package: "swift-numerics"),
            ]
        ),
        .testTarget(
            name: "MilitaryDefenseTrainingTests",
            dependencies: ["MilitaryDefenseTraining"]
        ),
    ]
)
