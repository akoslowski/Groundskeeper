// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Groundskeeper",
    platforms: [.macOS(.v10_11)],
    products: [
        .library(
            name: "Groundskeeper",
            targets: ["Groundskeeper"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            from: "0.0.1"
        ),
        .package(
            url: "https://github.com/MaxDesiatov/XMLCoder.git",
            from: "0.13.1"
        )
    ],
    targets: [
        .target(
            name: "playground",
            dependencies: [
                "Groundskeeper",
                .product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser"
                )
            ]
        ),
        .target(
            name: "Groundskeeper",
            dependencies: [
                .product(name: "XMLCoder", package: "XMLCoder", condition: nil)
            ]
        ),
        .testTarget(
            name: "GroundskeeperTests",
            dependencies: ["Groundskeeper"]
        ),
    ]
)
