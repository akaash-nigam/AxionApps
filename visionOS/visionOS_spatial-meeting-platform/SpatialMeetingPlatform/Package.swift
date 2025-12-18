// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SpatialMeetingPlatform",
    platforms: [
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "SpatialMeetingPlatform",
            targets: ["SpatialMeetingPlatform"]
        ),
    ],
    dependencies: [
        // Add third-party dependencies here when implementing
        // Commented out as they're not available in this environment
        // .package(url: "https://github.com/Alamofire/Alamofire", from: "5.9.0"),
        // .package(url: "https://github.com/daltoniam/Starscream", from: "4.0.0"),
    ],
    targets: [
        .target(
            name: "SpatialMeetingPlatform",
            dependencies: [
                // Dependencies would go here
            ],
            path: "SpatialMeetingPlatform"
        ),
        .testTarget(
            name: "SpatialMeetingPlatformTests",
            dependencies: ["SpatialMeetingPlatform"],
            path: "Tests"
        ),
    ]
)
