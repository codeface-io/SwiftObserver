import SwiftyToolz

public class ObservableObject<Update>: Observable
{
    public init()
    {
        ObservationService.register(observable: self)
    }
    
    deinit
    {
        ObservationService.unregister(observable: self)
    }
    
    public var latestUpdate: Update
    {
        fatalError("\(typeName(self)) is an abstract class. Just override `latestUpdate`.")
    }
    
    public func add(_ observer: AnyObject,
                    receive: @escaping (Update) -> Void)
    {
        observerList.add(observer, receive: receive)
    }
    
    public func remove(_ observer: AnyObject)
    {
        observerList.remove(observer)
    }
    
    public func removeObservers()
    {
        if observerList.isEmpty { return }
        
        observerList.removeAll()
    }
    
    public func removeDeadObservers()
    {
        observerList.removeNilObservers()
    }
    
    public func send(_ update: Update)
    {
        observerList.receive(update)
    }
    
    private let observerList = ObserverList<Update>()
}
