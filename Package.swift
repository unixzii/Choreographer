// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Choreographer",
    platforms: [.macOS(.v10_13), .iOS(.v12), .tvOS(.v12)],
    products: [
        .library(
            name: "Choreographer",
            targets: ["Choreographer"]),
    ],
    targets: [
        .target(
            name: "Choreographer"),
        .testTarget(
            name: "ChoreographerTests",
            dependencies: ["Choreographer"]
        ),
    ]
)
