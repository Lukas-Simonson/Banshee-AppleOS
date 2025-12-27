// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Business",
    platforms: [
        .iOS(.v18), .macOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Business",
            targets: ["Business"]
        ),
    ],
    dependencies: [
        .package(path: "../Core"),
        .package(url: "https://github.com/Lukas-Simonson/Overflow", from: "1.1.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Business",
            dependencies: [
                .product(name: "Core", package: "Core"),
                .product(name: "Overflow", package: "Overflow"),
            ]
        ),
        .testTarget(
            name: "BusinessTests",
            dependencies: ["Business"]
        ),
    ]
)
