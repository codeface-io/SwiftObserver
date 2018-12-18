public extension Observable
{
    func send() { send(latestMessage) }
}

public protocol Observable: AnyObject
{
    func add(_ observer: AnyObject, receive: @escaping Receiver)
    
    func remove(_ observer: AnyObject)
    func removeObservers()
    func removeDeadObservers()
    
    func send(_ message: Message)
    var latestMessage: Message { get }
    
    typealias Filter = (Message) -> Bool
    typealias Receiver = (Message) -> Void
    associatedtype Message: Any
}
