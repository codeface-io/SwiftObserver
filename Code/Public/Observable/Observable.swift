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
    func add(_ observer: AnyObject, receive: @escaping Receiver)
    {
        messenger.add(observer, receive: receive)
    }
    
    func remove(_ observer: AnyObject)
    {
        messenger.remove(observer)
    }
    
    func send(_ message: Message)
    {
        messenger.send(message)
    }
}

public protocol Observable: AnyObject
{
    var messenger: Messenger<Message> { get }
    typealias Filter = (Message) -> Bool
    typealias Receiver = (Message) -> Void
    associatedtype Message: Any
}
