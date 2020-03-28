// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "Differ",
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
