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
public import Memory_Heap_Primitives
public import Storage_Contiguous_Primitives
public import Buffer_Linked_Primitives
public import Index_Primitives
public import Queue_Primitives

extension Queue where Element: ~Copyable {

    /// A linked-list based FIFO queue supporting move-only elements.
    ///
    /// `Queue.Linked` uses arena-based linked list storage where nodes are stored
    /// contiguously and reference each other by index. This provides O(1) enqueue
    /// and dequeue with efficient memory locality.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var queue = Queue<Int>.Linked()
    /// queue.enqueue(1)
    /// queue.enqueue(2)
    /// queue.dequeue()     // Optional(1)
    /// queue.peek { $0 }   // Optional(2)
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
    /// ## Copy-on-Write
    ///
    /// When `Element` is `Copyable`, `Queue.Linked` uses copy-on-write semantics:
    /// copies share storage until mutation.
    // SAFETY: Safe by construction — backing storage uses only stdlib
    // SAFETY: safe types; `@safe` documents that this type performs no
    // SAFETY: unsafe operations.
    @safe
    public struct Linked: ~Copyable {

        @usableFromInline
        package var _buffer: Buffer<Storage<Element>.Contiguous<Memory.Heap<Element>>>.Linked<1>

        /// Creates an empty linked queue.
        @inlinable
        public init() {
            self._buffer = try! .create(capacity: 4)
        }

        /// Creates a queue with reserved capacity.
        ///
        /// - Parameter capacity: Number of elements to reserve space for.
        /// - Throws: ``Linked/Error/invalidCapacity`` if capacity is negative.
        @inlinable
        public init(reservingCapacity capacity: Int) throws(Queue<Element>.Linked.Error) {
            guard capacity >= 0 else {
                throw .invalidCapacity
            }
            self._buffer = try! .create(capacity: Swift.max(capacity, 4))
        }

    }
}

// MARK: - Conditional Conformances

/// `Queue.Linked` is `Copyable` when its elements are `Copyable`.
///
/// This enables value semantics with copy-on-write optimization:
/// copies share storage until mutation.
extension Queue.Linked: Copyable where Element: Copyable {}

