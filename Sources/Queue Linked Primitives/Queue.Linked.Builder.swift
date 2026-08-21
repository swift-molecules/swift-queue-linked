public import Buffer_Linked_Primitive
public import Buffer_Ring_Primitive
public import Queue_Linked_Primitive

extension __QueueLinked where Element: ~Copyable, S: ~Copyable {

    @resultBuilder
    public enum Builder {

        @inlinable
        public static func buildExpression(
            _ expression: consuming Element
        ) -> Queue<Element>.Linked {
            var result = Queue<Element>.Linked()
            result.enqueue(consume expression)
            return result
        }

        @inlinable
        public static func buildExpression(
            _ expression: consuming Queue<Element>.Linked
        ) -> Queue<Element>.Linked {
            consume expression
        }

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

        @inlinable
        public static func buildPartialBlock(
            first: consuming Queue<Element>.Linked
        ) -> Queue<Element>.Linked {
            consume first
        }

        @inlinable
        public static func buildPartialBlock(
            first: Void
        ) -> Queue<Element>.Linked {
            Queue<Element>.Linked()
        }

        @inlinable
        public static func buildPartialBlock(
            first: Never
        ) -> Queue<Element>.Linked {}

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

        @inlinable
        public static func buildBlock() -> Queue<Element>.Linked {
            Queue<Element>.Linked()
        }

        @inlinable
        public static func buildOptional(
            _ component: consuming Queue<Element>.Linked?
        ) -> Queue<Element>.Linked {
            if let result = consume component {
                return consume result
            }
            return Queue<Element>.Linked()
        }

        @inlinable
        public static func buildEither(
            first: consuming Queue<Element>.Linked
        ) -> Queue<Element>.Linked {
            consume first
        }

        @inlinable
        public static func buildEither(
            second: consuming Queue<Element>.Linked
        ) -> Queue<Element>.Linked {
            consume second
        }

        @inlinable
        public static func buildLimitedAvailability(
            _ component: consuming Queue<Element>.Linked
        ) -> Queue<Element>.Linked {
            consume component
        }
    }
}

extension __QueueLinked where Element: ~Copyable, S: ~Copyable {

    @inlinable
    public init(@Queue<Element>.Linked.Builder _ builder: () -> Queue<Element>.Linked)
    where S == Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, 1>> {
        self = builder()
    }
}

extension __QueueLinked.Builder where Element: Copyable, S: ~Copyable {

    @inlinable
    public static func buildExpression<Seq: Swift.Sequence>(
        _ expression: Seq
    ) -> Queue<Element>.Linked
    where Seq.Element == Element {
        var result = Queue<Element>.Linked()
        for value in expression {
            result.enqueue(value)
        }
        return result
    }
}
