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
public import List_Linked_Primitives
public import Iterator_Primitive
public import Iterator_Protocol

// MARK: - Scalar node-walk iterator (Small, snapshot)
//
// `Queue.Linked.Small` is unconditionally `~Copyable` (inline-plus-spill `@_rawLayout` storage):
// it cannot back a `Copyable` stdlib iterator and a pointer cursor cannot survive the
// `consuming` `Sequenceable.makeIterator()`. So — like dict-ordered's / list-linked's `Small` —
// the scalar iterator SNAPSHOTS the elements (via the backing list's `~Copyable`-safe `forEach`
// node-walk) into an owned `[Element]` and walks that. Snapshot is gated on `Element: Copyable`.
// The queue still does NOT conform `Memory.Contiguous.Protocol` (no element span exists).
//
// In the type module per [MOD-036]: `_snapshotIterator()` names the backing list's forEach window.

extension Queue.Linked.Small where Element: Copyable {
    /// A single-pass scalar iterator over a snapshot of the small queue's elements, front to back.
    ///
    /// Built by node-walking the inline/spilled storage into an owned array (avoids pointer-escape
    /// from the inline `@_rawLayout` storage). Scalar source for both the materialising `Iterable`
    /// face and the consuming `Sequenceable` face.
    public struct Iterator: Iterator_Primitive.Iterator.`Protocol`, IteratorProtocol {
        @usableFromInline
        let _snapshot: [Element]

        @usableFromInline
        var _position: Int

        @inlinable
        init(snapshot: consuming [Element]) {
            self._snapshot = snapshot
            self._position = 0
        }

        @inlinable
        public mutating func next() -> Element? {
            guard _position < _snapshot.count else { return nil }
            defer { _position += 1 }
            return _snapshot[_position]
        }
    }

    /// Builds an owned snapshot of the inline/spilled storage by node-walking the backing list.
    @inlinable
    func _snapshotIterator() -> Iterator {
        var snapshot: [Element] = []
        _storage.forEach { snapshot.append($0) }
        return Iterator(snapshot: snapshot)
    }
}
