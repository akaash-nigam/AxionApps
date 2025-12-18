// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SpatialMusicStudio",
    platforms: [
        .visionOS(.v1)
    ],
    products: [
        .executable(
            name: "SpatialMusicStudio",
            targets: ["SpatialMusicStudio"]
        )
    ],
    targets: [
        .executableTarget(
            name: "SpatialMusicStudio",
            path: "SpatialMusicStudio"
        )
    ]
)
