public protocol UpdateSender: ObservableProtocol
{
    func send(_ update: UpdateType)
}

public protocol ObservableProtocol: class
{
    func add(_ observer: AnyObject,
             _ receive: @escaping UpdateReceiver)
    
    func remove(_ observer: AnyObject)
    func removeAllObservers()
    func removeNilObservers()
    
    var latestUpdate: UpdateType { get }
    
    typealias UpdateReceiver = (_ update: UpdateType) -> Void
    associatedtype UpdateType: Any
}
