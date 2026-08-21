public import Buffer_Linked_Primitive
public import Queue_Linked_Primitive

extension __QueueLinked
where
    Element: Copyable, S: ~Copyable, S: Store.Generational.`Protocol`, S.Element == Node<Element, 1>
{

    @inlinable
    public func peek() -> Element? { _buffer.first() }

    @inlinable
    public mutating func drain(
        while predicate: (borrowing Element) -> Bool,
        _ body: (consuming Element) -> Void
    ) {
        while let front = peek(), predicate(front) {
            guard let next = dequeue() else { break }
            body(next)
        }
    }

    @inlinable
    public func makeIterator() -> [Element].Iterator { _buffer.makeIterator() }
}
