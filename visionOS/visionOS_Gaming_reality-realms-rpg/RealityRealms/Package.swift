// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "RealityRealms",
    platforms: [
        .visionOS(.v1)
    ],
    products: [
        .executable(
            name: "RealityRealms",
            targets: ["RealityRealms"]
        )
    ],
    targets: [
        .executableTarget(
            name: "RealityRealms",
            path: "RealityRealms"
        )
    ]
)
