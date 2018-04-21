public protocol ObservableProtocol: ObserverRemover
{
    func add(_ observer: AnyObject,
             _ handleUpdate: @escaping UpdateHandler)
    func removeAllObservers()
    
    var update: UpdateType { get }
    
    typealias UpdateHandler = (_ update: UpdateType) -> ()
    associatedtype UpdateType: Any
}

public protocol ObserverRemover: AnyObject
{
    func remove(_ observer: AnyObject)
}
