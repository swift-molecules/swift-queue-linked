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
public import Queue_Linked_Primitive

// MARK: - Copyable-element conveniences (peek-by-value, drain, snapshot iteration)
//
// These require a `Copyable` ELEMENT (not a `Copyable` column): they lift boundary elements out by
// value through the buffer's safe peek/snapshot surface. Value-semantic conformances (Equatable /
// Hashable / Swift.Sequence) require a `Copyable` COLUMN (the CoW `Shared` box) — deferred to the
// consumer-pull that surfaces the value-semantic front door, exactly as the ring queue's `Shared`
// value surface is.

extension __QueueLinked where Element: Copyable, S: ~Copyable, S: Store.Generational.`Protocol`, S.Element == Node<Element, 1> {
    /// Returns the front element without removing it, or `nil` if the queue is empty.
    ///
    /// This is a convenience for `Copyable` elements. For `~Copyable` elements use ``peek(_:)``
    /// with a borrowing closure.
    ///
    /// - Returns: A copy of the front element, or `nil` if the queue is empty.
    /// - Complexity: O(1).
    @inlinable
    public func peek() -> Element? { _buffer.first() }

    /// Drains elements front-to-back while `predicate` holds, passing each to `body` with ownership.
    ///
    /// - Complexity: O(k) where k is the number of drained elements.
    @inlinable
    public mutating func drain(
        while predicate: (borrowing Element) -> Bool,
        _ body: (consuming Element) -> Void
    ) {
        while let front = peek(), predicate(front) {
            guard let next = dequeue() else { break }
            body(next)
        }
    }

    /// A forward iterator over a snapshot of the elements, front (oldest) to back (newest).
    ///
    /// A linked queue has no contiguous span to vend a borrowing span-iterator over, so this
    /// snapshots the live elements through the safe `forEach` node-walk and hands back a stdlib
    /// iterator over that snapshot (a true snapshot — a later mutation of the source does not
    /// disturb it). Holding the live column in a value-type iterator and reading it through the
    /// seam's coroutine subscript miscompiles on Apple Swift 6.3.2 (SIGSEGV), so the snapshot path
    /// is the sound one.
    @inlinable
    public func makeIterator() -> [Element].Iterator { _buffer.makeIterator() }
}
