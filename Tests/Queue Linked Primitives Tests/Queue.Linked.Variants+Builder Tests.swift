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

import Queue_Linked_Primitives_Test_Support
import Testing

@testable import Queue_Linked_Primitives

@Suite("Queue.Linked variants + Builder")
struct QueueLinkedVariantsBuilderTests {
    @Suite struct Fixed {}
}

extension QueueLinkedVariantsBuilderTests.Fixed {
    @Test
    func `Fixed within capacity`() throws {
        var q = try Queue<Int>.Linked.Fixed(capacity: 8) { 1; 2; 3 }
        #expect(q.dequeue() == 1)
    }

    @Test
    func `Fixed throws on overflow`() {
        do {
            _ = try Queue<Int>.Linked.Fixed(capacity: 2) { 1; 2; 3 }
            Issue.record("expected throw")
        } catch {
            // expected
        }
    }
}
