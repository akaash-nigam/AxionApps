// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "DigitalTwinOrchestrator",
    platforms: [
        .visionOS(.v2),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "DigitalTwinOrchestrator",
            targets: ["DigitalTwinOrchestrator"]
        ),
    ],
    dependencies: [
        // Real-time communication
        .package(url: "https://github.com/daltoniam/Starscream", from: "4.0.0"),

        // Industrial protocols - MQTT
        .package(url: "https://github.com/emqx/CocoaMQTT", from: "2.1.0"),

        // Logging
        .package(url: "https://github.com/apple/swift-log", from: "1.5.0"),
    ],
    targets: [
        .target(
            name: "DigitalTwinOrchestrator",
            dependencies: [
                "Starscream",
                "CocoaMQTT",
                .product(name: "Logging", package: "swift-log")
            ],
            path: "DigitalTwinOrchestrator"
        )
    ]
)
