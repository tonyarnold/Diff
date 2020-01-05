// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Differ",
    products: [
        .library(name: "Differ", targets: ["Differ"]),
    ],
    targets: [
        .target(name: "Differ"),
        .testTarget(name: "DifferTests", dependencies: ["Differ"]),
    ]
)
