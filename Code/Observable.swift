public extension Observable
{
    func add(_ observer: AnyObject,
             filter: @escaping UpdateFilter = { _ in true },
             receive: @escaping UpdateReceiver)
    {
        ObservationService.add(observer,
                               of: self,
                               filter: filter,
                               receive: receive)
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
    
    func send()
    {
        send(latestUpdate)
    }
    
    func send(_ update: UpdateType)
    {
        ObservationService.send(update, toObserversOf: self)
    }
}

public protocol Observable: class
{
    func add(_ observer: AnyObject,
             filter: @escaping UpdateFilter,
             receive: @escaping UpdateReceiver)
    
    func remove(_ observer: AnyObject)
    func removeAllObservers()
    func removeNilObservers()
    
    func send()
    func send(_ update: UpdateType)
    
    var latestUpdate: UpdateType { get }
    
    typealias UpdateFilter = (UpdateType) -> Bool
    typealias UpdateReceiver = (UpdateType) -> Void
    associatedtype UpdateType: Any
}
