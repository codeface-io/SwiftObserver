public extension Observable
{
    func send() { send(latestMessage) }
}

public protocol Observable: AnyObject
{
    // for internal use by Observer
    
    func add(_ observer: AnyObject, receive: @escaping Receiver)
    func remove(_ observer: AnyObject)
    
    // for external use by clients
    
    func stopObservations()
    func stopAbandonedObservations()
    
    func send(_ message: Message)
    var latestMessage: Message { get }
    
    // types
    
    typealias Filter = (Message) -> Bool
    typealias Receiver = (Message) -> Void
    associatedtype Message: Any
}
