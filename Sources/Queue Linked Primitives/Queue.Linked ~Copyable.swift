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
public import Queue_Linked_Primitive

// MARK: - Properties (seam-generic over the column)
//
// `Element` is a carrier parameter, so these can be properties (an extension cannot introduce a
// free element parameter, but the pinned `S.Element == Node<Element, 1>` seam recovers the
// payload). The stored `_count`/`_capacity` fields are S-independent, so observability is cheap.

extension __QueueLinked where Element: ~Copyable, S: ~Copyable, S: Store.Generational.`Protocol`, S.Element == Node<Element, 1> {
    /// The current number of elements in the queue.
    @inlinable
    public var count: Index_Primitives.Index<Element>.Count { Index_Primitives.Index<Element>.Count(UInt(_buffer.count)) }

    /// Whether the queue is empty.
    @inlinable
    public var isEmpty: Bool { _buffer.isEmpty }

    /// The current node capacity of the queue.
    @inlinable
    public var capacity: Index_Primitives.Index<Element>.Count { Index_Primitives.Index<Element>.Count(UInt(_buffer.capacity)) }
}

// MARK: - Enqueue / reserve (column-pinned — growth needs the concrete allocator)

extension __QueueLinked where Element: ~Copyable, S: ~Copyable, S: Store.Generational.`Protocol`, S.Element == Node<Element, 1> {
    /// Enqueues an element at the back of the queue (move-only column; grows as needed).
    ///
    /// - Parameter element: The element to enqueue.
    /// - Complexity: O(1) amortized.
    @inlinable
    public mutating func enqueue(_ element: consuming Element)
    where S == Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, 1>> {
        if _buffer.isFull { _buffer.ensureCapacity(_buffer.count + 1) }
        do throws(Buffer<S>.Linked<1>.Error) {
            try _buffer.insertBack(element)
        } catch {
            fatalError("Queue.Linked.enqueue: insertion failed after capacity ensured: \(error)")
        }
    }

    /// Reserves capacity for at least `minimumCapacity` nodes (move-only column).
    ///
    /// - Parameter minimumCapacity: The minimum total node capacity to reserve.
    @inlinable
    public mutating func reserve(_ minimumCapacity: Int)
    where S == Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, 1>> {
        _buffer.ensureCapacity(minimumCapacity)
    }
}

// MARK: - Dequeue / clear (seam-generic; M5 Optional remove-from-empty)

extension __QueueLinked where Element: ~Copyable, S: ~Copyable, S: Store.Generational.`Protocol`, S.Element == Node<Element, 1> {
    /// Dequeues and returns the front element, or `nil` if the queue is empty.
    ///
    /// The empty path takes no gate (nothing to mutate); the buffer's own seam self-gates
    /// `unshare()` on the non-empty path (M5 remove-from-empty convention rider).
    ///
    /// - Returns: The front element, or `nil` if the queue is empty.
    /// - Complexity: O(1).
    @inlinable
    @discardableResult
    public mutating func dequeue() -> Element? { _buffer.removeFront() }

    /// Removes all elements from the queue; the node store is retained.
    ///
    /// - Complexity: O(n).
    @inlinable
    public mutating func clear() { _buffer.removeAll() }
}

// MARK: - Peek / traversal (seam-generic; closure forms support ~Copyable)

extension __QueueLinked where Element: ~Copyable, S: ~Copyable, S: Store.Generational.`Protocol`, S.Element == Node<Element, 1> {
    /// Peeks at the front element without removing it, via a borrowing closure.
    ///
    /// Uses a closure to support `~Copyable` elements; a borrow of `~Copyable` cannot be returned
    /// as an `Optional`, so this is the `~Copyable`-safe front-observation form.
    ///
    /// - Parameter body: A closure that receives a borrow of the front element.
    /// - Returns: The result of the closure, or `nil` if the queue is empty.
    /// - Complexity: O(1).
    @inlinable
    public func peek<R>(_ body: (borrowing Element) -> R) -> R? { _buffer.peekFront(body) }

    /// Calls the given closure for each element, front (oldest) to back (newest).
    ///
    /// - Parameter body: A closure that receives a borrow of each element.
    /// - Complexity: O(n).
    @inlinable
    public func forEach(_ body: (borrowing Element) -> Void) { _buffer.forEach(body) }
}
