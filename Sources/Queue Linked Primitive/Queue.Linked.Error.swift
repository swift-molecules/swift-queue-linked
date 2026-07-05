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

// MARK: - Hoisted Error Type (Module Level)
//
// Swift does not allow nested types inside generic types to carry a clean public path, so the
// error type is hoisted to module level and exposed via a typealias to provide the expected
// Nest.Name API (`Queue<Element>.Linked.Error`). This is the [API-IMPL-009]/[PKG-NAME-006]
// hoisted-type idiom, and it discharges the W1.75 [API-ERR-007] finding: the pre-hoist throws
// clause spelled `throws(__QueueLinked<Element>.Error)` (a non-public, wrong-arity path); the
// public path is now the module-level `__QueueLinkedError` with a nested typealias.
//
// The enum is currently UNTHROWN: growable construction validates capacity via `precondition`
// (Queue.Linked+Columns.swift) and dequeue-class removes return `Optional` on empty (the M5
// convention rider). It is KEPT as the recorded W3 residual — the one-carrier-Error house shape
// the linked op-generalization consolidates onto when W3 lands the linked capacity twin (mirrors
// the List.Linked W2 batch-1 disposition of its now-unthrown unbounded `Error`).

/// Hoisted implementation of ``Queue/Linked/Error``.
///
/// - Note: Use ``Queue/Linked/Error`` in your code, not this type directly.
@_documentation(visibility: public)
public enum __QueueLinkedError: Swift.Error, Sendable, Equatable {
    /// The requested capacity is invalid (non-positive).
    case invalidCapacity
}

// MARK: - Typealias (Nest.Name API)
//
// The extension restates `Element: ~Copyable` and `S: ~Copyable` per [MEM-COPY-004] so the alias
// is reachable from move-only elements and move-only columns alike.

extension __QueueLinked where Element: ~Copyable, S: ~Copyable {
    /// Errors that can occur during linked queue operations.
    ///
    /// ## Cases
    ///
    /// - ``Error/invalidCapacity``: The requested capacity is invalid (non-positive).
    public typealias Error = __QueueLinkedError
}
