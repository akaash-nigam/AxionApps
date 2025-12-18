// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MysteryInvestigation",
    platforms: [
        .visionOS(.v1)
    ],
    products: [
        .executable(
            name: "MysteryInvestigation",
            targets: ["MysteryInvestigation"]
        )
    ],
    targets: [
        .executableTarget(
            name: "MysteryInvestigation",
            path: "MysteryInvestigation"
        )
    ]
)
