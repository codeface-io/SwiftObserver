extension Messenger: ObservableObject
{
    public var messenger: Messenger<Message> { self }
}

public extension ObservableObject
{
    /**
     Send a ``Message`` to all ``Observer``s. Optionally identify a message author.
     */
    func send(_ message: Message, from author: AnyAuthor? = nil)
    {
        messenger._send(message, from: author ?? self)
    }
    
    internal var latestAuthor: AnyAuthor { messenger._latestAuthor }
}

/**
 An object that can be observed by multiple ``Observer``s
 
 ``Observer``s are responsible for starting an observation. Technically, observation means the observable object sends ``ObservableObject/Message``s to its observers via its ``ObservableObject/messenger``.
 */
public protocol ObservableObject: AnyAuthor
{
    /**
     The ``Messenger`` that the `ObservableObject` uses to send ``Message``s to its ``Observer``s
     */
    var messenger: Messenger<Message> { get }
    
    /**
     The type of message that the observable object can send to its ``Observer``s
     */
    associatedtype Message: Any
}
