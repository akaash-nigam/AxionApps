// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HealthcareOrchestrator",
    platforms: [
        .visionOS(.v1)
    ],
    products: [
        .executable(
            name: "HealthcareOrchestrator",
            targets: ["HealthcareOrchestrator"]
        )
    ],
    targets: [
        .executableTarget(
            name: "HealthcareOrchestrator",
            path: "HealthcareOrchestrator"
        )
    ]
)
