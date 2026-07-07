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
public import Buffer_Ring_Primitive
public import Queue_Linked_Primitive

extension __QueueLinked where Element: ~Copyable, S: ~Copyable {
    /// A result builder for declaratively constructing linked queues.
    ///
    /// **FIFO semantics.** Declaration order is enqueue order, which is
    /// also dequeue order:
    ///
    /// ```swift
    /// var queue = Queue<Int>.Linked {
    ///     1
    ///     2
    ///     3
    /// }
    /// queue.dequeue()  // 1 — first enqueued
    /// queue.dequeue()  // 2
    /// queue.dequeue()  // 3 — last enqueued
    /// ```
    ///
    /// Supports `~Copyable` elements via consuming enqueue. The builder always produces the
    /// default move-only front-door column `Queue<Element>.Linked`.
    ///
    /// ## `for` Loops Not Supported
    ///
    /// `buildArray` is omitted because Swift's result-builder transform's
    /// buildArray step uses `Swift.Array<Component>`, which currently
    /// requires `Component: Copyable`. The component here is the
    /// ~Copyable `Queue<Element>.Linked`.
    @resultBuilder
    public enum Builder {

        // MARK: - Expression Building

        /// Wraps a single element expression into a one-element queue.
        @inlinable
        public static func buildExpression(
            _ expression: consuming Element
        ) -> Queue<Element>.Linked {
            var result = Queue<Element>.Linked()
            result.enqueue(consume expression)
            return result
        }

        /// Passes an already-built queue component through unchanged.
        @inlinable
        public static func buildExpression(
            _ expression: consuming Queue<Element>.Linked
        ) -> Queue<Element>.Linked {
            consume expression
        }

        /// Wraps an optional element expression, producing an empty queue when it is `nil`.
        @inlinable
        public static func buildExpression(
            _ expression: consuming Element?
        ) -> Queue<Element>.Linked {
            var result = Queue<Element>.Linked()
            if let value = consume expression {
                result.enqueue(consume value)
            }
            return result
        }

        // MARK: - Partial Block Building

        /// Begins a partial block with the first queue component, passed through unchanged.
        @inlinable
        public static func buildPartialBlock(
            first: consuming Queue<Element>.Linked
        ) -> Queue<Element>.Linked {
            consume first
        }

        /// Begins a partial block from an empty first statement, producing an empty queue.
        @inlinable
        public static func buildPartialBlock(
            first: Void
        ) -> Queue<Element>.Linked {
            Queue<Element>.Linked()
        }

        /// Begins a partial block whose first component is statically unreachable.
        @inlinable
        public static func buildPartialBlock(
            first: Never
        ) -> Queue<Element>.Linked {}

        /// Merges an accumulated partial block with the next component, preserving FIFO order.
        @inlinable
        public static func buildPartialBlock(
            accumulated: consuming Queue<Element>.Linked,
            next: consuming Queue<Element>.Linked
        ) -> Queue<Element>.Linked {
            var result = consume accumulated
            var rest = consume next
            while let element = rest.dequeue() {
                result.enqueue(consume element)
            }
            return result
        }

        // MARK: - Block Building

        /// Builds an empty queue for a block with no components.
        @inlinable
        public static func buildBlock() -> Queue<Element>.Linked {
            Queue<Element>.Linked()
        }

        // MARK: - Control Flow

        /// Builds from an optional `if`-branch component, producing an empty queue when untaken.
        @inlinable
        public static func buildOptional(
            _ component: consuming Queue<Element>.Linked?
        ) -> Queue<Element>.Linked {
            if let result = consume component {
                return consume result
            }
            return Queue<Element>.Linked()
        }

        /// Builds the first branch of an `if`-`else` block.
        @inlinable
        public static func buildEither(
            first: consuming Queue<Element>.Linked
        ) -> Queue<Element>.Linked {
            consume first
        }

        /// Builds the second branch of an `if`-`else` block.
        @inlinable
        public static func buildEither(
            second: consuming Queue<Element>.Linked
        ) -> Queue<Element>.Linked {
            consume second
        }

        // buildArray omitted: see DocC above.

        /// Passes a component through unchanged for an availability-gated (`if #available`) branch.
        @inlinable
        public static func buildLimitedAvailability(
            _ component: consuming Queue<Element>.Linked
        ) -> Queue<Element>.Linked {
            consume component
        }
    }
}

// MARK: - Convenience Init (column-pinned to the front-door move-only column)

extension __QueueLinked where Element: ~Copyable, S: ~Copyable {
    /// Constructs a linked queue from a result-builder closure.
    ///
    /// FIFO: declaration order = enqueue order = dequeue order.
    @inlinable
    public init(@Queue<Element>.Linked.Builder _ builder: () -> Queue<Element>.Linked)
    where S == Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, 1>> {
        self = builder()
    }
}

// MARK: - Sequence Bulk-Add (Copyable Element only)

extension __QueueLinked.Builder where Element: Copyable, S: ~Copyable {
    /// Bulk-enqueue a `Swift.Sequence` without per-iteration allocation.
    ///
    /// FIFO: iteration order = enqueue order.
    @inlinable
    public static func buildExpression<Seq: Swift.Sequence>(_ expression: Seq) -> Queue<Element>.Linked
    where Seq.Element == Element {
        var result = Queue<Element>.Linked()
        for value in expression {
            result.enqueue(value)
        }
        return result
    }
}
