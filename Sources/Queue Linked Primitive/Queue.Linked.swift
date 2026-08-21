public import Buffer_Linked_Primitive

@_documentation(visibility: public)
@frozen
public struct __QueueLinked<Element: ~Copyable, S: ~Copyable>: ~Copyable {

    @usableFromInline
    package var _buffer: Buffer<S>.Linked<1>

    @inlinable
    package init(_buffer: consuming Buffer<S>.Linked<1>) {
        self._buffer = _buffer
    }
}

extension __QueueLinked: Copyable where S: Copyable, Element: ~Copyable {}

extension __QueueLinked: @unsafe @unchecked Sendable
where S: Sendable, S: ~Copyable, Element: ~Copyable {}
