// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "IndustrialCADCAM",
    platforms: [
        .visionOS(.v2)
    ],
    products: [
        .library(
            name: "IndustrialCADCAM",
            targets: ["IndustrialCADCAM"]
        ),
    ],
    dependencies: [
        // Add Swift Package Dependencies here
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "IndustrialCADCAM",
            dependencies: [
                .product(name: "Numerics", package: "swift-numerics"),
            ],
            path: "IndustrialCADCAM",
            exclude: ["Tests"]
        ),
        .testTarget(
            name: "IndustrialCADCAMTests",
            dependencies: ["IndustrialCADCAM"],
            path: "IndustrialCADCAM/Tests"
        ),
    ]
)
