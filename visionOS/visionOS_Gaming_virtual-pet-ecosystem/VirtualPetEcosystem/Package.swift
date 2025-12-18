// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VirtualPetEcosystem",
    platforms: [
        .visionOS(.v2),
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "VirtualPetEcosystem",
            targets: ["VirtualPetEcosystem"]),
    ],
    dependencies: [
        // Add external dependencies here if needed
    ],
    targets: [
        .target(
            name: "VirtualPetEcosystem",
            dependencies: [],
            path: "Sources/VirtualPetEcosystem",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "VirtualPetEcosystemTests",
            dependencies: ["VirtualPetEcosystem"],
            path: "Tests/VirtualPetEcosystemTests"
        ),
    ],
    swiftLanguageModes: [.v6]
)
