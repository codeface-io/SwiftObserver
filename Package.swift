// swift-tools-version:5.1

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
            .upToNextMajor(from: "1.5.2")
        ),
    ],
    targets: [
        .target(name: "SwiftObserver",
                dependencies: ["SwiftyToolz"],
                path: "Code"),
    ]
)
