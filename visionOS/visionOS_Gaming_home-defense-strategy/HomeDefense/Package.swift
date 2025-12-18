// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HomeDefense",
    platforms: [
        .visionOS(.v1)
    ],
    products: [
        .executable(
            name: "HomeDefense",
            targets: ["HomeDefense"]
        )
    ],
    targets: [
        .executableTarget(
            name: "HomeDefense",
            path: "HomeDefense"
        )
    ]
)
