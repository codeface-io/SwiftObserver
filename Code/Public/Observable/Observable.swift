public extension Observable
{
    func send() { send(latestUpdate) }
}

public protocol Observable: AnyObject
{
    func add(_ observer: AnyObject, receive: @escaping UpdateReceiver)
    
    func remove(_ observer: AnyObject)
    func removeObservers()
    func removeDeadObservers()
    
    func send(_ update: UpdateType)
    var latestUpdate: UpdateType { get }
    
    typealias UpdateFilter = (UpdateType) -> Bool
    typealias UpdateReceiver = (UpdateType) -> Void
    associatedtype UpdateType: Any
}
