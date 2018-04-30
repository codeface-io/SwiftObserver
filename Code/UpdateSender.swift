public protocol UpdateSender: ObservableProtocol
{
    func send(_ update: UpdateType)
}

public protocol ObservableProtocol: ObserverRemover
{
    func add(_ observer: AnyObject,
             _ handleUpdate: @escaping UpdateReceiver)
    
    var update: UpdateType { get }
    
    typealias UpdateReceiver = (_ update: UpdateType) -> ()
    associatedtype UpdateType: Any
}

public protocol ObserverRemover: AnyObject
{
    func remove(_ observer: AnyObject)
    func removeAllObservers()
    func removeNilObservers()
}
