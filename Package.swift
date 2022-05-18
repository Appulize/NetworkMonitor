// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkMonitor",
    defaultLocalization: LanguageTag("en"),
    platforms: [
        .iOS(.v13),
        .macOS(.v10_14),
        .tvOS(.v12),
        .watchOS(.v5)
    ],
    products: [
        .library(
            name: "NetworkMonitor",
            targets: ["NetworkMonitor"]),
    ],
    targets: [
        .target(
            name: "NetworkMonitor",
            resources: [
                .process("Resources"),
            ]),
    ]
)
