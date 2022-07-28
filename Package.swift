// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "safe-decodable",
    products: [
        
        .library(
            name: "safe-decodable",
            targets: ["safe-decodable"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "safe-decodable",
            dependencies: []),
        .testTarget(
            name: "safe-decodableTests",
            dependencies: ["safe-decodable"]),
    ]
)
