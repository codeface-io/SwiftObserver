public extension BufferedObservable
{
    func send() { send(latestMessage) }
}

public protocol BufferedObservable: Observable
{
    var latestMessage: Message { get }
}

public protocol Observable: AnyObject
{
    // for internal use by Observer
    
    func add(_ observer: AnyObject, receive: @escaping Receiver)
    func remove(_ observer: AnyObject)
    
    func send(_ message: Message)
    
    // types
    
    typealias Filter = (Message) -> Bool
    typealias Receiver = (Message) -> Void
    associatedtype Message: Any
}
