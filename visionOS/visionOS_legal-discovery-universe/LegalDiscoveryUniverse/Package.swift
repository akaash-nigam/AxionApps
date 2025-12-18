// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LegalDiscoveryUniverse",
    platforms: [
        .visionOS(.v2)
    ],
    products: [
        .library(
            name: "LegalDiscoveryUniverse",
            targets: ["LegalDiscoveryUniverse"]
        )
    ],
    dependencies: [
        // No external dependencies for MVP
        // Future dependencies could include:
        // .package(url: "https://github.com/Alamofire/Alamofire", from: "5.8.0"),
        // .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", from: "4.2.0"),
    ],
    targets: [
        .target(
            name: "LegalDiscoveryUniverse",
            dependencies: []
        ),
        .testTarget(
            name: "LegalDiscoveryUniverseTests",
            dependencies: ["LegalDiscoveryUniverse"]
        )
    ]
)
