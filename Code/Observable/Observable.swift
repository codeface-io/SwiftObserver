extension Messenger: Observable
{
    public var messenger: Messenger<Message> { self }
}

public extension Observable
{
    func send(_ message: Message, from author: AnyAuthor? = nil)
    {
        messenger.send(message, from: author ?? self)
    }
}

public protocol Observable: AnyAuthor
{
    var messenger: Messenger<Message> { get }
    associatedtype Message: Any
}
