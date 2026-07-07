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

import Buffer_Ring_Primitive
import Index_Primitives
import Testing

@testable import Queue_Linked_Primitives

// MARK: - Deterministic RNG (SplitMix64 — no seeding nondeterminism in CI)

private struct SplitMix64 {
    var state: UInt64
    init(seed: UInt64) { self.state = seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

// MARK: - Differential vs a plain-array oracle (the W2 test floor, §9.3 convention rider)
//
// [DS-024] note: the generational-seam column is OUTSIDE the Store-tier Seam.Ledger (ruled), so
// there is no Seam.Ledger violations fixture here. A queue has no middle-removal, so the
// stable-order "-style" law is FIFO-order preservation across growth/reallocations — which this
// differential test asserts step-by-step against the oracle. It IS the [DS-024]-style law test.

@Suite("Queue.Linked — differential vs array oracle")
struct QueueLinkedDifferentialTests {

    /// ≥500 mixed ops against a plain-`[Int]` oracle over the move-only default column
    /// (`Queue<Int>.Linked`): duplicates (values drawn from 0..<10), interleaved
    /// enqueue/dequeue/peek, growth across reallocations (initial node capacity is 4; the enqueue
    /// bias grows the queue well past it), step-by-step match, plus a final full-order check.
    @Test
    func `600 mixed ops match a plain-array oracle (move-only column)`() {
        var rng = SplitMix64(seed: 0x5EED_1157_ADC0_FFEE)
        var queue = Queue<Int>.Linked()
        var oracle: [Int] = []

        for step in 0..<600 {
            let op = rng.next() % 5
            let value = Int(rng.next() % 10)  // small range -> duplicates guaranteed
            switch op {
            case 0, 1, 2:  // enqueue bias (3/5 enqueue vs 1/5 dequeue) -> growth across reallocations
                queue.enqueue(value)
                oracle.append(value)

            case 3:
                let got = queue.dequeue()
                let want = oracle.isEmpty ? nil : oracle.removeFirst()
                #expect(got == want, "step \(step): dequeue diverged")

            default:
                let front = queue.peek()
                #expect(front == oracle.first, "step \(step): peek diverged")
            }

            // Step-by-step invariants (bound to locals -- move-only #expect capture discipline).
            let count = queue.count
            #expect(count == Index<Int>.Count(UInt(oracle.count)), "step \(step): count diverged")
            let empty = queue.isEmpty
            #expect(empty == oracle.isEmpty, "step \(step): isEmpty diverged")
        }

        // Final full-order check, front (oldest) to back (newest).
        var snapshot: [Int] = []
        queue.forEach { (element: borrowing Int) in snapshot.append(copy element) }
        #expect(snapshot == oracle)

        // Snapshot iterator agrees with the forEach walk.
        let iterated = Array(AnyIterator(queue.makeIterator()))
        #expect(iterated == oracle)
    }

    /// A move-only element fixture drained FIFO matches the enqueue order (the ~Copyable path).
    @Test
    func `move-only elements drain in FIFO order`() {
        struct Token: ~Copyable { let value: Int }
        var queue = Queue<Token>.Linked()
        for value in 0..<200 { queue.enqueue(Token(value: value)) }

        var drained: [Int] = []
        while let token = queue.dequeue() {
            drained.append(token.value)
        }
        #expect(drained == Array(0..<200))
        let empty = queue.isEmpty
        #expect(empty)
    }
}
