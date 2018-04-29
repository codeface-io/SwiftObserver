public protocol ObserverUpdater: ObservableProtocol
{
    func updateObservers(_ update: UpdateType)
}

public protocol ObservableProtocol: ObserverRemover
{
    func add(_ observer: AnyObject,
             _ handleUpdate: @escaping UpdateHandler)
    
    var update: UpdateType { get }
    
    typealias UpdateHandler = (_ update: UpdateType) -> ()
    associatedtype UpdateType: Any
}

public protocol ObserverRemover: AnyObject
{
    func remove(_ observer: AnyObject)
    func removeAllObservers()
    func removeNilObservers()
}
