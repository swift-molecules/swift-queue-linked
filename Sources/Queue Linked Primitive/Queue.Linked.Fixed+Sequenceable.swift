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

public import Queue_Primitives
public import Buffer_Linked_Primitive
public import Buffer_Linked_Primitives

// MARK: - Sequenceable witness (consuming makeIterator)
//
// The single-pass consuming scalar iterator — the `Copyable` witness for the cold
// `Sequenceable` conformance (declared in the ops module). A public member in the type module
// per [MOD-036] refined-C: it copies the backing buffer's iterator state out of the consumed
// fixed queue. Re-uses the shared scalar `Queue.Linked.Iterator` (both `Queue.Linked` and
// `Queue.Linked.Fixed` are backed by `Buffer.Linked<1>`).

extension Queue.Linked.Fixed where Element: Copyable {

    /// A single-pass consuming iterator over the fixed queue's elements, front to back.
    /// Witness for `Sequenceable`.
    @inlinable
    public consuming func makeIterator() -> Queue<Element>.Linked.Iterator {
        Queue<Element>.Linked.Iterator(inner: _buffer.makeIterator())
    }
}
