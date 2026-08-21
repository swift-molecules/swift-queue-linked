// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-queue-linked-primitives",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27)
    ],
    products: [

        .library(name: "Queue Linked Primitive", targets: ["Queue Linked Primitive"]),

        .library(name: "Queue Linked Primitives", targets: ["Queue Linked Primitives"]),
        .library(name: "Queue Linked Primitives Test Support", targets: ["Queue Linked Primitives Test Support"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-primitives/swift-queue-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-buffer-linked-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-index-primitives.git", branch: "main"),

        .package(url: "https://github.com/swift-primitives/swift-storage-primitives.git", branch: "main"),

        .package(url: "https://github.com/swift-primitives/swift-buffer-ring-primitives.git", branch: "main"),
    ],
    targets: [

        .target(
            name: "Queue Linked Primitive",
            dependencies: [
                .product(name: "Queue Primitive", package: "swift-queue-primitives"),
                .product(name: "Queue Primitives", package: "swift-queue-primitives"),
                .product(name: "Buffer Linked Primitive", package: "swift-buffer-linked-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
                .product(name: "Store Protocol Primitives", package: "swift-storage-primitives"),
            ]
        ),

        .target(
            name: "Queue Linked Primitives",
            dependencies: [
                "Queue Linked Primitive",
                .product(name: "Queue Primitives", package: "swift-queue-primitives"),
                .product(name: "Buffer Linked Primitive", package: "swift-buffer-linked-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),

                .product(name: "Buffer Ring Primitive", package: "swift-buffer-ring-primitives"),
            ]
        ),

        .target(
            name: "Queue Linked Primitives Test Support",
            dependencies: [
                "Queue Linked Primitives",
                .product(name: "Index Primitives Test Support", package: "swift-index-primitives"),
            ],
            path: "Tests/Support"
        ),

        .testTarget(
            name: "Queue Linked Primitives Tests",
            dependencies: [
                "Queue Linked Primitives",
                "Queue Linked Primitives Test Support",

                .product(name: "Buffer Ring Primitive", package: "swift-buffer-ring-primitives"),
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
