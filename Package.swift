// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUIEx",
    platforms: [
        .macOS(.v11), .iOS(.v14)
    ],
    products: [
        .library(
            name: "SwiftUIEx",
            targets: ["SwiftUIEx"]
        )
    ],
    dependencies: [
        .package(name: "CombineEx", url: "https://github.com/RocketLaunchpad/CombineEx.git", .branch("main"))
    ],
    targets: [
        .target(
            name: "SwiftUIEx",
            dependencies: ["CombineEx"],
            swiftSettings: [.unsafeFlags([
                "-Xfrontend",
                "-warn-long-function-bodies=100",
                "-Xfrontend",
                "-warn-long-expression-type-checking=100"
            ])]
        )
    ]
)
