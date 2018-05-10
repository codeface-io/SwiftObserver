public extension Observable
{
    func add(_ observer: AnyObject,
             _ receive: @escaping UpdateReceiver)
    {
        ObservationService.add(observer, of: self, receive)
    }
    
    func send(_ update: UpdateType)
    {
        ObservationService.send(update, toObserversOf: self)
    }
    
    func remove(_ observer: AnyObject)
    {
        ObservationService.remove(observer, from: self)
    }
    
    func removeAllObservers()
    {
        ObservationService.removeAllObservers(of: self)
    }
    
    func removeNilObservers()
    {
        ObservationService.removeNilObservers(of: self)
    }
}

public protocol Observable: class
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
