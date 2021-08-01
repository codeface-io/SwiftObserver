// swift-tools-version:5.4.0

import PackageDescription

let package = Package(
    name: "SwiftObserver",
    platforms: [
        .iOS(.v13), .macOS(.v10_15), .tvOS(.v13), .watchOS(.v6)
    ],
    products: [
        .library(
            name: "SwiftObserver",
            targets: ["SwiftObserver"]
        ),
        .library(
            name: "CombineObserver",
            targets: ["CombineObserver"]
        ),
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
            path: "Code/SwiftObserver"
        ),
        .target(
            name: "CombineObserver",
            dependencies: ["SwiftObserver", "SwiftyToolz"],
            path: "Code/CombineObserver"
        ),
        .testTarget(
            name: "SwiftObserverTests",
            dependencies: ["SwiftObserver", "SwiftyToolz"]
        ),
    ]
)
