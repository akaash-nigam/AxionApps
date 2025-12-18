// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MySpatialLife",
    platforms: [
        .visionOS(.v2)
    ],
    products: [
        .library(
            name: "MySpatialLifeCore",
            targets: ["Core"]
        ),
        .library(
            name: "MySpatialLifeAI",
            targets: ["AI"]
        ),
        .library(
            name: "MySpatialLifeSpatial",
            targets: ["Spatial"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-collections", from: "1.1.0"),
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "Core",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Collections", package: "swift-collections")
            ],
            path: "MySpatialLife/Core"
        ),
        .target(
            name: "AI",
            dependencies: [
                "Core",
                .product(name: "Numerics", package: "swift-numerics")
            ],
            path: "MySpatialLife/AI"
        ),
        .target(
            name: "Spatial",
            dependencies: ["Core"],
            path: "MySpatialLife/Spatial"
        ),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"],
            path: "MySpatialLifeTests/UnitTests"
        ),
        .testTarget(
            name: "AITests",
            dependencies: ["AI"],
            path: "MySpatialLifeTests/UnitTests"
        )
    ]
)
