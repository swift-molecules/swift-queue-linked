// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-queue-linked",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27)
    ],
    products: [

        .library(name: "Queue Linked Primitive", targets: ["Queue Linked Primitive"]),

        .library(name: "Queue Linked", targets: ["Queue Linked"]),
        .library(name: "Queue Linked Test Support", targets: ["Queue Linked Test Support"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-molecules/swift-queue.git", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-buffer-linked.git", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-index.git", branch: "main"),

        .package(url: "https://github.com/swift-molecules/swift-storage.git", branch: "main"),

        .package(url: "https://github.com/swift-molecules/swift-buffer-ring.git", branch: "main"),
    ],
    targets: [

        .target(
            name: "Queue Linked Primitive",
            dependencies: [
                .product(name: "Queue Primitive", package: "swift-queue"),
                .product(name: "Queue", package: "swift-queue"),
                .product(name: "Buffer Linked Primitive", package: "swift-buffer-linked"),
                .product(name: "Index", package: "swift-index"),
                .product(name: "Store Protocol", package: "swift-storage"),
            ]
        ),

        .target(
            name: "Queue Linked",
            dependencies: [
                "Queue Linked Primitive",
                .product(name: "Queue", package: "swift-queue"),
                .product(name: "Buffer Linked Primitive", package: "swift-buffer-linked"),
                .product(name: "Index", package: "swift-index"),

                .product(name: "Buffer Ring Primitive", package: "swift-buffer-ring"),
            ]
        ),

        .target(
            name: "Queue Linked Test Support",
            dependencies: [
                "Queue Linked",
                .product(name: "Index Test Support", package: "swift-index"),
            ],
            path: "Tests/Support"
        ),

        .testTarget(
            name: "Queue Linked Tests",
            dependencies: [
                "Queue Linked",
                "Queue Linked Test Support",

                .product(name: "Buffer Ring Primitive", package: "swift-buffer-ring"),
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
