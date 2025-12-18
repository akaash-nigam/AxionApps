// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SpatialCodeReviewer",
    platforms: [
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "SpatialCodeReviewer",
            targets: ["SpatialCodeReviewer"]
        ),
    ],
    dependencies: [
        // Tree-sitter for code parsing
        .package(url: "https://github.com/ChimeHQ/SwiftTreeSitter", from: "0.8.0"),
    ],
    targets: [
        .target(
            name: "SpatialCodeReviewer",
            dependencies: [
                .product(name: "SwiftTreeSitter", package: "SwiftTreeSitter"),
            ]
        ),
        .testTarget(
            name: "SpatialCodeReviewerTests",
            dependencies: ["SpatialCodeReviewer"]
        ),
    ]
)
