# Queue Linked Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

The **linked-queue FIFO discipline** over the `Queue` namespace: arena-backed, linked-list storage with O(1) enqueue and dequeue, growable and supporting noncopyable (`~Copyable`) elements.

---

## Quick Start

```swift
import Queue_Linked_Primitives

// Growable linked queue — enqueue events, drain in arrival order.
var events = Queue<String>.Linked {
    "connection-opened"
    "request-received"
    "response-sent"
}
events.enqueue("connection-closed")

while let event = events.dequeue() {
    print(event)  // connection-opened, request-received, response-sent, connection-closed
}

// Move-only elements — queue transfers ownership of each handle.
struct FileHandle: ~Copyable {
    let descriptor: Int
}

var handles = Queue<FileHandle>.Linked()
handles.enqueue(FileHandle(descriptor: 3))
handles.enqueue(FileHandle(descriptor: 4))

while let handle = handles.dequeue() {
    // `handle` is consumed here; queue never retains a copy.
    _ = consume handle
}

// Reserve capacity up front to avoid incremental growth.
var reserved = Queue<Int>.Linked(reservingCapacity: 8)
reserved.enqueue(1)
reserved.enqueue(2)
reserved.enqueue(3)
let front = reserved.dequeue()  // Optional(1)
```

---

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-primitives/swift-queue-linked-primitives.git", branch: "main")
]
```

```swift
.target(
    name: "App",
    dependencies: [
        // The umbrella — the whole package.
        .product(name: "Queue Linked Primitives", package: "swift-queue-linked-primitives"),
    ]
)
```

The package is pre-1.0 — depend on `branch: "main"` until `0.1.0` is tagged. Requires Swift 6.3
and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the matching Linux toolchain).

---

## Variants

| Type              | Storage        | Reach for it when                                  |
|-------------------|----------------|-----------------------------------------------------|
| `Queue<E>.Linked` | heap, growable | the queue size is unbounded or not known up front   |

`Queue<E>.Linked` is generic over `Element` and supports noncopyable (`~Copyable`) element types. Use `init(reservingCapacity:)` to pre-size the backing storage when an approximate upper bound is known ahead of time.

---

## Architecture

`Queue<E>.Linked` ships as two modules: a lean type module (`Queue Linked Primitive`) containing the value type and its storage operations, and a conformances module (`Queue Linked Primitives`) containing `Sequence`, `Collection`, and protocol conformances — kept separate so they never constrain noncopyable use. Importing `Queue Linked Primitives` (the umbrella) brings in the whole package; importing `Queue Linked Primitive` brings in the type alone, without the Copyable-requiring conformances.

---

## License

Apache License 2.0. See [LICENSE](LICENSE.md) for details.
