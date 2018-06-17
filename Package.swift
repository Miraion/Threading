// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Threading",
    products: [
        .library(name: "Threading", targets: ["Threading"]),
    ],
    dependencies: [
        
    ],
    targets: [
        .target(name: "Threading", dependencies: []),
        .testTarget(name: "ThreadingTests", dependencies: ["Threading"]),
    ]
)
