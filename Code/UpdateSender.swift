public protocol UpdateSender: ObservableProtocol
{
    func send(_ update: UpdateType)
}

public protocol ObservableProtocol: ObserverRemover
{
    func add(_ observer: AnyObject,
             _ receive: @escaping UpdateReceiver)
    
    var latestUpdate: UpdateType { get }
    
    typealias UpdateReceiver = (_ update: UpdateType) -> Void
    associatedtype UpdateType: Any
}

public protocol ObserverRemover: AnyObject
{
    func remove(_ observer: AnyObject)
    func removeAllObservers()
    func removeNilObservers()
}
