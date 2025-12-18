// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "CorporateUniversityPlatform",
    platforms: [
        .visionOS(.v2),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "CorporateUniversityPlatform",
            targets: ["CorporateUniversityPlatform"]),
    ],
    dependencies: [
        // Add package dependencies here
    ],
    targets: [
        .target(
            name: "CorporateUniversityPlatform",
            dependencies: [],
            path: "CorporateUniversity",
            exclude: ["Tests"],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]),
        .testTarget(
            name: "CorporateUniversityPlatformTests",
            dependencies: ["CorporateUniversityPlatform"],
            path: "CorporateUniversity/Tests"),
    ]
)
