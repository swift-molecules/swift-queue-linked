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
        // MARK: - Type module (lean ~Copyable types; Copyable-requiring conformances live in the ops module per [MOD-004])
        .library(name: "Queue Linked Primitive", targets: ["Queue Linked Primitive"]),
        // MARK: - Ops module; `Queue Linked Primitives` doubles as the [MOD-005] umbrella
        .library(name: "Queue Linked Primitives", targets: ["Queue Linked Primitives"]),
        .library(name: "Queue Linked Primitives Test Support", targets: ["Queue Linked Primitives Test Support"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-primitives/swift-queue-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-buffer-linked-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-index-primitives.git", branch: "main"),
        // Store.`Protocol` for the `__Queue` front-door nest alias (S.Element projection).
        .package(url: "https://github.com/swift-primitives/swift-storage-primitives.git", branch: "main"),
        // The ring column backs `Queue<E>` (the namespace `Queue<E>.Linked` nests on); spelling
        // the front door requires the ring's Store.`Protocol` conformance visible (exports-narrowing).
        .package(url: "https://github.com/swift-primitives/swift-buffer-ring-primitives.git", branch: "main"),
    ],
    targets: [

        // MARK: - Type module — lean ~Copyable Queue.Linked carrier + front door + error ([MOD-036])
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

        // MARK: - Ops module + umbrella — operations over the linked-queue types, re-exports the type module
        .target(
            name: "Queue Linked Primitives",
            dependencies: [
                "Queue Linked Primitive",
                .product(name: "Queue Primitives", package: "swift-queue-primitives"),
                .product(name: "Buffer Linked Primitive", package: "swift-buffer-linked-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
                // The builder + convenience init spell the front door `Queue<E>.Linked` (ring-backed namespace).
                .product(name: "Buffer Ring Primitive", package: "swift-buffer-ring-primitives"),
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
                // Tests spell the front door `Queue<E>.Linked` (ring-backed namespace).
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
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
