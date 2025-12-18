// swift-tools-version: 5.9
//
//  Package.swift
//  HomeMaintenanceOracle
//
//  Created on 2025-11-24.
//

import PackageDescription

let package = Package(
    name: "HomeMaintenanceOracle",
    platforms: [
        .visionOS(.v1),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "HomeMaintenanceOracle",
            targets: ["HomeMaintenanceOracle"]
        )
    ],
    dependencies: [
        // Add external dependencies here if needed
        // Example:
        // .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0"),
    ],
    targets: [
        .target(
            name: "HomeMaintenanceOracle",
            dependencies: [],
            path: "HomeMaintenanceOracle"
        ),
        .testTarget(
            name: "HomeMaintenanceOracleTests",
            dependencies: ["HomeMaintenanceOracle"],
            path: "HomeMaintenanceOracleTests"
        )
    ]
)
