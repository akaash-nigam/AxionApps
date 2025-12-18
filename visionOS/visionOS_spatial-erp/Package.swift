// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SpatialERP",
    defaultLocalization: "en",
    platforms: [
        .visionOS(.v2)
    ],
    products: [
        .library(
            name: "SpatialERP",
            targets: ["SpatialERP"]
        )
    ],
    dependencies: [
        // GraphQL Client
        .package(
            url: "https://github.com/apollographql/apollo-ios.git",
            from: "1.9.0"
        ),
        // Networking
        .package(
            url: "https://github.com/Alamofire/Alamofire.git",
            from: "5.8.0"
        ),
        // WebSocket
        .package(
            url: "https://github.com/daltoniam/Starscream.git",
            from: "4.0.0"
        ),
        // Keychain
        .package(
            url: "https://github.com/evgenyneu/keychain-swift.git",
            from: "20.0.0"
        )
    ],
    targets: [
        .target(
            name: "SpatialERP",
            dependencies: [
                .product(name: "Apollo", package: "apollo-ios"),
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "Starscream", package: "Starscream"),
                .product(name: "KeychainSwift", package: "keychain-swift")
            ],
            path: "SpatialERP",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "SpatialERPTests",
            dependencies: ["SpatialERP"],
            path: "SpatialERPTests"
        )
    ]
)
