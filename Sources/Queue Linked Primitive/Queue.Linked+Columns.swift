public import Buffer_Linked_Primitive
public import Index_Primitives

extension __QueueLinked where Element: ~Copyable, S: ~Copyable {

    @inlinable
    public init()
    where S == Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, 1>> {
        self.init(
            _buffer: Buffer<S>.Linked<1>(
                minimumCapacity: Index_Primitives.Index<Element>.Count(UInt(4))
            )
        )
    }

    @inlinable
    public init(reservingCapacity capacity: Int)
    where S == Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, 1>> {
        precondition(capacity > 0, "capacity must be positive")
        self.init(
            _buffer: Buffer<S>.Linked<1>(
                minimumCapacity: Index_Primitives.Index<Element>.Count(UInt(capacity))
            )
        )
    }
}
