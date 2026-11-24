// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-acoustics-resonator",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(name: "Acoustics Resonator", targets: ["Acoustics Resonator"])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-molecules/swift-acoustics.git", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-acoustics-striker.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-decay.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-energy.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-force.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-frequency.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-numeric.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-space.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-velocity.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Acoustics Resonator",
            dependencies: [
                .product(name: "Acoustics", package: "swift-acoustics"),
                .product(name: "Acoustics Striker", package: "swift-acoustics-striker"),
                .product(name: "Decay", package: "swift-decay"),
                .product(name: "Energy", package: "swift-energy"),
                .product(name: "Force", package: "swift-force"),
                .product(name: "Frequency", package: "swift-frequency"),
                .product(name: "Numeric", package: "swift-numeric"),
                .product(name: "Space", package: "swift-space"),
                .product(name: "Velocity", package: "swift-velocity"),
            ]
        ),
        .testTarget(
            name: "Acoustics Resonator Tests",
            dependencies: [
                .target(name: "Acoustics Resonator")
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    target.swiftSettings =
        (target.swiftSettings ?? []) + [
            .strictMemorySafety(),
            .enableUpcomingFeature("ExistentialAny"),
            .enableUpcomingFeature("InternalImportsByDefault"),
            .enableUpcomingFeature("MemberImportVisibility"),
            .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
            .enableUpcomingFeature("InferIsolatedConformances"),
            .enableExperimentalFeature("Lifetimes"),
            .treatAllWarnings(as: .error),
        ]
}
