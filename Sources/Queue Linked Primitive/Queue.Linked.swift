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

// MARK: - __QueueLinked (the hoisted ADT carrier — generic over the storage COLUMN)
//
// The ratified column-generic design (mirrors `__ListLinked`, `Research/adt-tower.md` §9.3
// Queue.Linked row): `__QueueLinked` is a thin FIFO discipline over a `Buffer<S>.Linked<1>`,
// generic over the storage column `S`, and **copyability flows from the column** — the bare
// move-only generational store is the zero-cost move-only column; the `Shared` box over it is
// the value-semantic (CoW) column (deferred to consumer-pull, like the ring queue's `Shared`).
//
// A queue is inherently SINGLY-linked (FIFO needs only front-remove + back-insert, both O(1)
// with head/tail cursors), so the per-node link count is fixed at `N == 1` — unlike `List.Linked`
// which parameterizes `N` (singly vs doubly). The carrier therefore drops the `N` parameter.
//
// `Element` rides the carrier (unlike the contiguous families, where the user element IS
// `S.Element`): the linked store's element is the NODE (`S.Element == Node<Element, 1>`), and the
// seam bound is deliberately kept OFF the type (see the type doc below), so `S.Element` is not
// projectable at the type level — the payload type must be a carrier parameter. This is the
// §A13/[API-IMPL-009] phantom-generic hoist mechanic (the List.Linked W2 batch-1 refinement): the
// §9.3 carrier spelling `__QueueLinked<S>` elides this parameter, which the enclosing
// `Queue<Element>` namespace supplied before the hoist.
//
// The public spelling is the front-door NEST alias `Queue<Element>.Linked` (D4.1 sense (b),
// [DS-028]) — declared in `Queue.Linked.FrontDoor.swift`.

/// A linked-list based FIFO queue over an explicit storage column.
///
/// `Queue.Linked` is a thin FIFO discipline over a singly-linked `Buffer<S>.Linked<1>`: enqueue
/// links a fresh tail node and dequeue unlinks the head, both O(1). Nodes live in a generational
/// slot store and reference each other by handle.
///
/// Prefer the front-door alias `Queue<Element>.Linked` over spelling the column `S` directly.
///
/// ## Example
///
/// ```swift
/// var queue = Queue<Int>.Linked()
/// queue.enqueue(1)
/// queue.enqueue(2)
/// queue.dequeue()     // Optional(1)
/// queue.peek()        // Optional(2)
/// ```
///
/// ## Move-Only Support
///
/// Both the queue and its elements can be `~Copyable`:
///
/// ```swift
/// struct FileHandle: ~Copyable { ... }
/// var handles = Queue<FileHandle>.Linked()
/// handles.enqueue(FileHandle())
/// ```
///
/// - Important: The storage-capability constraint (`S: Store.Generational.`Protocol``,
///   `S.Element == Node<Element, 1>`) is deliberately NOT on the type — it lives on the operation
///   extensions, exactly as `Buffer.Linked` and `__ListLinked` do it. Putting it on the type forces
///   the column's conformance into the (deeply-nested) type metadata, which miscompiles
///   cross-package on Apple Swift 6.3.2 (SIGSEGV on bare construction). Keeping the type bound to
///   `S: ~Copyable` only, and constraining at the call sites, avoids embedding that conformance in
///   the metadata.
@_documentation(visibility: public)
@frozen
public struct __QueueLinked<Element: ~Copyable, S: ~Copyable>: ~Copyable {

    /// The backing singly-linked buffer over the storage column.
    @usableFromInline
    package var _buffer: Buffer<S>.Linked<1>

    @inlinable
    package init(_buffer: consuming Buffer<S>.Linked<1>) {
        self._buffer = _buffer
    }
}

// MARK: - Conditional Conformances (co-located per [COPY-FIX-004])

/// `__QueueLinked` is `Copyable` exactly when its column is — the S5 chain through `Shared`.
/// `Element: ~Copyable` is restated per [MEM-COPY-004] (copyability flows from `S`, not the element).
extension __QueueLinked: Copyable where S: Copyable, Element: ~Copyable {}

/// Sendable via the column's own discipline (single-owner move-only, or CoW-restored `Shared`).
/// `S: ~Copyable` is restated (M1/[MEM-COPY-004]) so the conformance reaches the move-only column.
extension __QueueLinked: @unsafe @unchecked Sendable where S: Sendable, S: ~Copyable, Element: ~Copyable {}
