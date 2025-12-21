// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Data",
    platforms: [
        .iOS(.v18), .macOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Data",
            targets: ["Data"]
        ),
    ],
    dependencies: [
        .package(path: "../Business"),
        .package(url: "https://github.com/Lukas-Simonson/Swift-Cobweb", from: "1.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Data",
            dependencies: [
                .product(name: "Business", package: "Business"),
                .product(name: "Cobweb", package: "Swift-Cobweb")
            ]
        ),
        .testTarget(
            name: "DataTests",
            dependencies: ["Data"]
        ),
    ]
)
