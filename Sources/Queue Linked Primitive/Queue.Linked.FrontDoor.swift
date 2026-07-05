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
public import Queue_Primitive
public import Store_Protocol_Primitives

// MARK: - Queue<E>.Linked — the sibling NEST alias ([DS-028], D4.1 sense (b))

extension __Queue where S: Store.`Protocol` & ~Copyable {

    /// An arena-backed singly-linked FIFO queue over the default move-only column.
    ///
    /// This is a **nest alias** (D4.1 sense (b), [DS-028]): it NAMES the hoisted `__QueueLinked`
    /// sibling carrier under the `Queue` family namespace, so consumers spell
    /// `Queue<Element>.Linked`. The linked queue is a distinct discipline sibling ([DS-027].2, its
    /// own package/carrier — O(1) middle-removal is a contract difference, D4.1), not a variant of
    /// `__Queue`; only its nest alias lives here.
    ///
    /// The default column is the **zero-cost move-only** generational store — mirroring the ring
    /// `Queue<E>` (move-only default) and `List<E>.Singly`. The value-semantic (CoW) `Shared`
    /// column is deferred to consumer-pull (none exist today), exactly as the ring queue's
    /// `Shared` variant is. The fixed-capacity `.Bounded` alias is **W3-blocked**: the generational
    /// seam vends neither `Store.Direct` nor a `Bounded` capacity-twin (W1.5 conformed
    /// `Buffer.Linear` + `Buffer.Ring` only; linked op generalization is wave W3). The `Fixed` hand
    /// variant was deleted in the Round M coda, so no residual bounded surface remains to keep.
    public typealias Linked =
        __QueueLinked<S.Element, Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<S.Element, 1>>>
}
