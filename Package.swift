// swift-tools-version:5.6.0

import PackageDescription

let package = Package(
    name: "SwiftObserver",
    platforms: [
        .iOS(.v12), .macOS(.v10_14), .tvOS(.v12), .watchOS(.v6)
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
            exact: "0.1.0"
        )
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
        .testTarget(
            name: "CombineObserverTests",
            dependencies: ["CombineObserver", "SwiftObserver", "SwiftyToolz"]
        )
    ]
)
