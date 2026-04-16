// swift-tools-version: 6.2

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
