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
    func send(_ message: Message)
    {
        messenger.send(message)
    }
    
    internal func add(_ observer: AnyObject, receive: @escaping (Message) -> Void)
    {
        messenger.add(observer, receive: receive)
    }
    
    internal func remove(_ observer: AnyObject)
    {
        messenger.remove(observer)
    }
}

public protocol Observable: AnyObject
{
    var messenger: Messenger<Message> { get }
    associatedtype Message: Any
}
