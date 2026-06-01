// swift-tools-version: 6.3.1

import PackageDescription

let package = Package(
    name: "swift-queue-linked-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        // MARK: - Type module (lean ~Copyable types; Copyable-requiring conformances live in the ops module per [MOD-004])
        .library(name: "Queue Linked Primitive", targets: ["Queue Linked Primitive"]),
        // MARK: - Ops module; `Queue Linked Primitives` doubles as the [MOD-005] umbrella
        .library(name: "Queue Linked Primitives", targets: ["Queue Linked Primitives"]),
        .library(name: "Queue Linked Primitives Test Support", targets: ["Queue Linked Primitives Test Support"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-primitives/swift-queue-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-buffer-linked-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-list-linked-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-index-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-iterator-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-sequence-primitives.git", branch: "main"),
    ],
    targets: [

        // MARK: - Type module — lean ~Copyable Queue.Linked + nested variants/errors + iteration witnesses ([MOD-036])
        .target(
            name: "Queue Linked Primitive",
            dependencies: [
                .product(name: "Queue Primitives", package: "swift-queue-primitives"),
                .product(name: "Buffer Linked Primitive", package: "swift-buffer-linked-primitives"),
                .product(name: "Buffer Linked Primitives", package: "swift-buffer-linked-primitives"),
                .product(name: "List Linked Primitives", package: "swift-list-linked-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
                .product(name: "Iterator Primitive", package: "swift-iterator-primitives"),
                .product(name: "Iterator Protocol", package: "swift-iterator-primitives"),
                .product(name: "Iterable", package: "swift-iterator-primitives"),
                .product(name: "Iterator Chunk Primitives", package: "swift-iterator-primitives"),
            ]
        ),

        // MARK: - Ops module + umbrella — Copyable conformances + ops, re-exports the type module
        .target(
            name: "Queue Linked Primitives",
            dependencies: [
                "Queue Linked Primitive",
                .product(name: "Queue Primitives", package: "swift-queue-primitives"),
                .product(name: "Buffer Linked Primitive", package: "swift-buffer-linked-primitives"),
                .product(name: "Buffer Linked Primitives", package: "swift-buffer-linked-primitives"),
                .product(name: "List Linked Primitives", package: "swift-list-linked-primitives"),
                .product(name: "Iterator Primitive", package: "swift-iterator-primitives"),
                .product(name: "Iterator Protocol", package: "swift-iterator-primitives"),
                .product(name: "Iterable", package: "swift-iterator-primitives"),
                .product(name: "Iterator Chunk Primitives", package: "swift-iterator-primitives"),
                .product(name: "Sequence Primitives", package: "swift-sequence-primitives"),
            ]
        ),

        // MARK: - Test Support
        .target(
            name: "Queue Linked Primitives Test Support",
            dependencies: [
                "Queue Linked Primitives",
                .product(name: "Index Primitives Test Support", package: "swift-index-primitives"),
            ],
            path: "Tests/Support"
        ),

        // MARK: - Tests
        .testTarget(
            name: "Queue Linked Primitives Tests",
            dependencies: [
                "Queue Linked Primitives",
                "Queue Linked Primitives Test Support",
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
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
