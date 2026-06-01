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

public import Queue_Linked_Primitive
public import Queue_Primitives
public import Sequence_Primitives

// MARK: - Sequenceable (single-pass, consuming)
//
// Re-uses the scalar node-walk `Queue.Linked.Iterator` (shared with `Queue.Linked`; both backed
// by `Buffer.Linked<1>`). The consuming `makeIterator()` witness is a public member in the type
// module (Queue.Linked.Fixed+Sequenceable.swift) per [MOD-036] refined-C; this conformance is
// thin and splits the `Iterator` associated-type binding from `Iterable`'s via `@_implements`.
// The per-type `Swift.Sequence` conformance is dropped to match the exemplar (deferred
// stdlib-interop axis).

extension Queue.Linked.Fixed: Sequenceable where Element: Copyable {
    @_implements(Sequenceable, Iterator)
    public typealias SequenceableIterator = Queue<Element>.Linked.Iterator

    /// Returns the count as the underestimated count since we know the exact size.
    @inlinable
    public var underestimatedCount: Int { Int(bitPattern: count) }
}
