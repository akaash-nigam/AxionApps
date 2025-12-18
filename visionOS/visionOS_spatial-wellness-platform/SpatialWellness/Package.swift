// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SpatialWellness",
    platforms: [
        .visionOS(.v1)
    ],
    products: [
        .executable(
            name: "SpatialWellness",
            targets: ["SpatialWellness"]
        )
    ],
    targets: [
        .executableTarget(
            name: "SpatialWellness",
            path: "SpatialWellness"
        )
    ]
)
