public extension BufferedObservable
{
    func send() { send(latestMessage) }
}

public protocol BufferedObservable: Observable
{
    var latestMessage: Message { get }
}

extension Messenger: Observable
{
    public var messenger: Messenger<Message> { self }
}

public extension Observable
{
    func send(_ message: Message, author: AnyAuthor? = nil)
    {
        messenger.send(message, author: author ?? self)
    }
}

public protocol Observable: AnyAuthor
{
    var messenger: Messenger<Message> { get }
    associatedtype Message: Any
}
