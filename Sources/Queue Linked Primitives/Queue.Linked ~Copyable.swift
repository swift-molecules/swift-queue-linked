public import Buffer_Linked_Primitive
public import Index_Primitives
public import Queue_Linked_Primitive

extension __QueueLinked
where
    Element: ~Copyable, S: ~Copyable, S: Store.Generational.`Protocol`,
    S.Element == Node<Element, 1>
{

    @inlinable
    public var count: Index_Primitives.Index<Element>.Count {
        Index_Primitives.Index<Element>.Count(UInt(_buffer.count))
    }

    @inlinable
    public var isEmpty: Bool { _buffer.isEmpty }

    @inlinable
    public var capacity: Index_Primitives.Index<Element>.Count {
        Index_Primitives.Index<Element>.Count(UInt(_buffer.capacity))
    }
}

extension __QueueLinked
where
    Element: ~Copyable, S: ~Copyable, S: Store.Generational.`Protocol`,
    S.Element == Node<Element, 1>
{

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

    @inlinable
    public mutating func reserve(_ minimumCapacity: Int)
    where S == Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, 1>> {
        _buffer.ensureCapacity(minimumCapacity)
    }
}

extension __QueueLinked
where
    Element: ~Copyable, S: ~Copyable, S: Store.Generational.`Protocol`,
    S.Element == Node<Element, 1>
{

    @inlinable
    @discardableResult
    public mutating func dequeue() -> Element? { _buffer.removeFront() }

    @inlinable
    public mutating func clear() { _buffer.removeAll() }
}

extension __QueueLinked
where
    Element: ~Copyable, S: ~Copyable, S: Store.Generational.`Protocol`,
    S.Element == Node<Element, 1>
{

    @inlinable
    public func peek<R>(_ body: (borrowing Element) -> R) -> R? { _buffer.peekFront(body) }

    @inlinable
    public func forEach(_ body: (borrowing Element) -> Void) { _buffer.forEach(body) }
}
