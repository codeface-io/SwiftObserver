// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "SwiftObserver",
    products: [
        .library(name: "SwiftObserver",
                 targets: ["SwiftObserver"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/flowtoolz/SwiftyToolz.git",
            .upToNextMajor(from: "1.5.0")
        ),
    ],
    targets: [
        .target(name: "SwiftObserver",
                dependencies: ["SwiftyToolz"],
                path: "Code"),
    ]
)
