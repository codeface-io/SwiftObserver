extension Messenger: Observable
{
    public var messenger: Messenger<Message> { self }
}

public extension Observable
{
    func send(_ message: Message, from author: AnyAuthor? = nil)
    {
        messenger._send(message, from: author ?? self)
    }
    
    var latestAuthor: AnyAuthor { messenger.latestAuthorInternal }
}

public protocol Observable: AnyAuthor
{
    var messenger: Messenger<Message> { get }
    associatedtype Message: Any
}
