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

public import Queue_Primitives_Core
public import Buffer_Linked_Primitive
public import Buffer_Linked_Primitives
public import Iterable
public import Iterator_Primitive
public import Iterator_Chunk_Primitives

// MARK: - Iterable (multipass, borrowing) — via materialising adapter
//
// `Queue.Linked.Fixed` is pointer-chained (Buffer.Linked-backed): no contiguous element span,
// so it produces its bulk iterator by wrapping the scalar node-walk `Iterator` (shared with
// `Queue.Linked`, both backed by `Buffer.Linked<1>`) in `Iterator.Materializing` and does NOT
// conform `Memory.Contiguous.Protocol`. `@_implements` splits the unified `Iterator` associated
// type: `Iterable.Iterator` binds the materialising bulk iterator here; `Sequenceable.Iterator`
// binds the scalar `Iterator` (Queue.Linked.Fixed+Sequenceable.swift).

extension Queue.Linked.Fixed: Iterable where Element: Copyable {
    @_implements(Iterable, Iterator)
    public typealias IterableIterator = Iterator_Primitive.Iterator.Materializing<Queue<Element>.Linked.Iterator>

    /// Iterable's bulk span witness: wraps the scalar node-walk iterator in the generator
    /// materialise adapter.
    @inlinable
    @_lifetime(borrow self)
    @_implements(Iterable, makeIterator())
    public borrowing func iterableMakeIterator() -> Iterator_Primitive.Iterator.Materializing<Queue<Element>.Linked.Iterator> {
        Iterator_Primitive.Iterator.Materializing(Queue<Element>.Linked.Iterator(inner: _buffer.makeIterator()))
    }
}
