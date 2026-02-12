// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LogGobbler",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "LogGobbler",
            targets: ["LogGobbler"]
        )
    ],
    dependencies: [
        // No external dependencies - keep SDK lightweight
    ],
    targets: [
        .target(
            name: "LogGobbler",
            dependencies: [],
            path: "Sources/LogGobbler",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "LogGobblerTests",
            dependencies: ["LogGobbler"],
            path: "Tests/LogGobblerTests"
        )
    ],
    swiftLanguageModes: [.v6]
)
