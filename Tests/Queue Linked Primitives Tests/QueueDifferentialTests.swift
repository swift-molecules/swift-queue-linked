import Buffer_Ring_Primitive
import Index_Primitives
import Testing

@testable import Queue_Linked_Primitives

private struct SplitMix64 {
    var state: UInt64
    init(seed: UInt64) { self.state = seed }
}

extension SplitMix64 {
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

@Suite
struct `Queue.Linked — differential vs array oracle` {

    @Test
    func `600 mixed ops match a plain-array oracle (move-only column)`() {
        var rng = SplitMix64(seed: 0x5EED_1157_ADC0_FFEE)
        var queue = Queue<Int>.Linked()
        var oracle: [Int] = []

        for step in 0..<600 {
            let op = rng.next() % 5
            let value = Int(rng.next() % 10)
            switch op {
            case 0, 1, 2:
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

            let count = queue.count
            #expect(count == Index<Int>.Count(UInt(oracle.count)), "step \(step): count diverged")
            let empty = queue.isEmpty
            #expect(empty == oracle.isEmpty, "step \(step): isEmpty diverged")
        }

        var snapshot: [Int] = []
        queue.forEach { (element: borrowing Int) in snapshot.append(copy element) }
        #expect(snapshot == oracle)

        let iterated = Array(AnyIterator(queue.makeIterator()))
        #expect(iterated == oracle)
    }

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
