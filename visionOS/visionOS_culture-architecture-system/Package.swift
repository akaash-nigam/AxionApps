// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CultureArchitectureSystem",
    platforms: [
        .visionOS(.v2),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "CultureArchitectureSystem",
            targets: ["CultureArchitectureSystem"]
        )
    ],
    targets: [
        .target(
            name: "CultureArchitectureSystem",
            path: "CultureArchitectureSystem",
            exclude: [
                "Tests",
                "README.md"
            ],
            sources: [
                "App",
                "Models",
                "Networking",
                "Services",
                "Utilities",
                "ViewModels",
                "Views"
            ]
        ),
        .testTarget(
            name: "CultureArchitectureSystemTests",
            dependencies: ["CultureArchitectureSystem"],
            path: "CultureArchitectureSystem/Tests"
        )
    ]
)
