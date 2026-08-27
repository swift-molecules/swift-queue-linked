public import Buffer_Linked_Primitive
public import Queue_Primitive
public import Store_Protocol

extension __Queue where S: Store.`Protocol` & ~Copyable {

    public typealias Linked =
        __QueueLinked<
            S.Element, Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<S.Element, 1>>
        >
}
