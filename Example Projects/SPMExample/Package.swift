// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "SPMExample",
    dependencies: [
        .package(url: "https://github.com/flowtoolz/SwiftObserver.git",
                 .upToNextMajor(from: "5.1.1"))
//        .package(path: "../../../SwiftObserver")
    ],
    targets: [
        .target(name: "SPMExample",
                dependencies: ["SwiftObserver"])
    ],
    swiftLanguageVersions: [.version("5.1")]
)
