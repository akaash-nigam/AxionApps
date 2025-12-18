// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BusinessOperatingSystem",
    platforms: [
        .visionOS(.v2),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "BusinessOperatingSystem",
            targets: ["BusinessOperatingSystem"])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "BusinessOperatingSystem",
            dependencies: [],
            path: "BusinessOperatingSystem",
            exclude: [
                "Tests",
                "Resources"
            ],
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableUpcomingFeature("ConciseMagicFile"),
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("ForwardTrailingClosures"),
                .enableUpcomingFeature("ImplicitOpenExistentials"),
                .enableUpcomingFeature("StrictConcurrency"),
                .unsafeFlags(["-enable-actor-data-race-checks"])
            ]
        ),
        .testTarget(
            name: "BusinessOperatingSystemTests",
            dependencies: ["BusinessOperatingSystem"],
            path: "BusinessOperatingSystem/Tests"
        )
    ],
    swiftLanguageModes: [.v6]
)
