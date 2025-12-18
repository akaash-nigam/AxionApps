// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "EscapeRoomNetwork",
    platforms: [
        .visionOS(.v2)
    ],
    products: [
        .library(
            name: "EscapeRoomNetwork",
            targets: ["EscapeRoomNetwork"]
        ),
    ],
    dependencies: [
        // Add any external dependencies here
    ],
    targets: [
        .target(
            name: "EscapeRoomNetwork",
            dependencies: [],
            path: "EscapeRoomNetwork",
            exclude: ["Tests"],
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableUpcomingFeature("ConciseMagicFile"),
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("ForwardTrailingClosures"),
                .enableUpcomingFeature("ImplicitOpenExistentials"),
                .enableUpcomingFeature("StrictConcurrency"),
            ]
        ),
        .testTarget(
            name: "EscapeRoomNetworkTests",
            dependencies: ["EscapeRoomNetwork"],
            path: "EscapeRoomNetwork/Tests"
        ),
    ]
)
