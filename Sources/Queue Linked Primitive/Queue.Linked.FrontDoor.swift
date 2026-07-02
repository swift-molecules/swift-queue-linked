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

public import Queue_Primitive
public import Store_Protocol_Primitives

// MARK: - Queue<E>.Linked — the sibling NEST alias ([DS-028], D4.1 sense (b))

extension __Queue where S: Store.`Protocol` & ~Copyable {

    /// An arena-backed linked FIFO queue keyed on the family's element.
    ///
    /// This is a **nest alias** (D4.1 sense (b), [DS-028]): it merely NAMES the
    /// `__QueueLinked` sibling carrier under the `Queue` family namespace, so
    /// consumers spell `Queue<Element>.Linked`. The linked queue is a distinct
    /// discipline sibling ([DS-027].2, its own package/carrier — O(1) middle-removal
    /// is a contract difference), not a variant of `__Queue`; only its nest alias
    /// lives here. This W1 alias is UNBREAK-ONLY; the carrier's full column-generic
    /// disposition (`__QueueLinked<S>` over Linked columns + a `.Bounded` alias) is
    /// wave W2.
    public typealias Linked = __QueueLinked<S.Element>
}
