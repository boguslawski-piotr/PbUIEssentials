// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PbUIEssentials",
    platforms: [.macOS(.v12), .iOS(.v15), .tvOS(.v15), .watchOS(.v8)],
    products: [
        .library(
            name: "PbUIEssentials",
            targets: ["PbUIEssentials"]),
    ],
    dependencies: [
        .package(path: "../PbEssentials")
    ],
    targets: [
        .target(
            name: "PbUIEssentials",
            dependencies: ["PbEssentials"]),
    ]
)
