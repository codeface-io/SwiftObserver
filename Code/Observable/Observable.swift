public extension BufferedObservable
{
    func send() { send(latestMessage) }
}

public protocol BufferedObservable: Observable
{
    var latestMessage: Message { get }
}

public extension Observable
{
    func send(_ message: Message, sender: AnySender? = nil)
    {
        messenger.send(message, sender: sender ?? self)
    }
    
    internal func add(_ observer: AnyReceiver, receive: @escaping (Message, AnySender) -> Void)
    {
        messenger.add(observer, receive: receive)
    }
    
    internal func add(_ observer: AnyReceiver, receive: @escaping (Message) -> Void)
    {
        messenger.add(observer) { message, _ in receive(message) }
    }
    
    internal func remove(_ observer: AnyReceiver)
    {
        messenger.remove(observer)
    }
}

// TODO: unit test that this lil trick works
extension Messenger: Observable
{
    public var messenger: Messenger<Message> { self }
}

public protocol Observable: AnySender
{
    var messenger: Messenger<Message> { get }
    associatedtype Message: Any
}
