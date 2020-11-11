// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "SwiftObserver",
    products: [
        .library(
            name: "SwiftObserver",
            targets: ["SwiftObserver"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/flowtoolz/SwiftyToolz.git",
            .branch("master")
        ),
    ],
    targets: [
        .target(
            name: "SwiftObserver",
            dependencies: ["SwiftyToolz"],
            path: "Code"),
        .testTarget(
            name: "SwiftObserverTests",
            dependencies: ["SwiftObserver", "SwiftyToolz"]),
    ]
)
