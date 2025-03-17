// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CropVideo",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CropVideo",
            targets: ["CropVideo"]),
    ],
    targets: [
        .target(name: "CropVideo", path: "Sources"),
    ],
    swiftLanguageVersions: [.v5]
)
