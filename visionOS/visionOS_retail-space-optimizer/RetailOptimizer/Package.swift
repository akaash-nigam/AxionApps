// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "RetailOptimizer",
    platforms: [
        .visionOS(.v1)
    ],
    products: [
        .executable(
            name: "RetailOptimizer",
            targets: ["RetailOptimizer"]
        )
    ],
    targets: [
        .executableTarget(
            name: "RetailOptimizer",
            path: "RetailOptimizer"
        )
    ]
)
