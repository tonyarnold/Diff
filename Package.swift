// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "Differ",
    platforms: [
        .iOS(.v9),
        .macOS(.v10_12),
        .tvOS(.v9),
        .watchOS(.v4)
    ],
    products: [
        .library(name: "Differ", targets: ["Differ"]),
    ],
    targets: [
        .target(name: "Differ"),
        .testTarget(name: "DifferTests", dependencies: [
            .target(name: "Differ")
        ]),
    ]
)
