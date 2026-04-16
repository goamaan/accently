// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "Accently",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "Accently", targets: ["Accently"])
    ],
    targets: [
        .executableTarget(
            name: "Accently"
        ),
        .testTarget(
            name: "AccentlyTests",
            dependencies: ["Accently"]
        )
    ]
)
