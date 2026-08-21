@_documentation(visibility: public)
public enum __QueueLinkedError: Swift.Error, Sendable, Equatable {

    case invalidCapacity
}

extension __QueueLinked where Element: ~Copyable, S: ~Copyable {

    public typealias Error = __QueueLinkedError
}
