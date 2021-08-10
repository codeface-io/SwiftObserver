extension Messenger: ObservableObject
{
    public var messenger: Messenger<Message> { self }
}

public extension ObservableObject
{
    func send(_ message: Message, from author: AnyAuthor? = nil)
    {
        messenger._send(message, from: author ?? self)
    }
    
    internal var latestAuthor: AnyAuthor { messenger._latestAuthor }
}

public protocol ObservableObject: AnyAuthor
{
    var messenger: Messenger<Message> { get }
    associatedtype Message: Any
}
