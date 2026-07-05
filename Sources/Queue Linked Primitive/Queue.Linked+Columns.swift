// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-primitives open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import Buffer_Linked_Primitive
public import Index_Primitives

// MARK: - Construction (per column)
//
// Construction pins the move-only generational column (the default queue column). It cannot ride
// the handle seam (the seam carries no concrete-allocator capability by design), so it appears as
// a `where S ==` clause on the initializer. Forwards to the `Buffer<S>.Linked<1>` constructor.
// The CoW (`Shared`) column construction is deferred to the consumer-pull that surfaces the
// value-semantic front door.

extension __QueueLinked where Element: ~Copyable, S: ~Copyable {
    /// Creates an empty linked queue (move-only column), reserving capacity for 4 nodes.
    @inlinable
    public init()
    where S == Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, 1>> {
        self.init(_buffer: Buffer<S>.Linked<1>(minimumCapacity: Index_Primitives.Index<Element>.Count(UInt(4))))
    }

    /// Creates an empty linked queue reserving capacity for `capacity` nodes (move-only column).
    ///
    /// - Parameter capacity: Number of nodes to reserve space for; must be positive.
    @inlinable
    public init(reservingCapacity capacity: Int)
    where S == Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, 1>> {
        precondition(capacity > 0, "capacity must be positive")
        self.init(_buffer: Buffer<S>.Linked<1>(minimumCapacity: Index_Primitives.Index<Element>.Count(UInt(capacity))))
    }
}
