public extension Observable
{
    func add(_ observer: AnyObject,
             receive: @escaping UpdateReceiver)
    {
        ObservationService.add(observer,
                               of: self,
                               filter: nil,
                               receive: receive)
    }
    
    func remove(_ observer: AnyObject)
    {
        ObservationService.remove(observer, of: self)
    }
    
    func removeObservers()
    {
        ObservationService.removeObservers(of: self)
    }
    
    func removeDeadObservers()
    {
        ObservationService.removeDeadObservers(of: self)
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

public protocol Observable: ObserverRemover
{
    func add(_ observer: AnyObject,
             receive: @escaping UpdateReceiver)
    
    func send()
    func send(_ update: UpdateType)
    
    var latestUpdate: UpdateType { get }
    
    typealias UpdateFilter = (UpdateType) -> Bool
    typealias UpdateReceiver = (UpdateType) -> Void
    associatedtype UpdateType: Any
}

public protocol ObserverRemover: class
{
    func remove(_ observer: AnyObject)
    func removeObservers()
    func removeDeadObservers()
}
