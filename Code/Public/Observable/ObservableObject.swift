import SwiftyToolz

extension ObservableObject: RegisteredObservable
{
    func removeFromRegisteredObservables(_ observer: AnyObject)
    {
        observerList.remove(observer)
    }
    
    func removeDeadObserversFromRegisteredObservables()
    {
        observerList.removeNilObservers()
    }
}

public class ObservableObject<Update>: Observable
{
    deinit
    {
        ObservationService.willDeinit(self, with: observerList.hashValues)
    }
    
    public var latestUpdate: Update
    {
        fatalError("\(typeName(self)) is an abstract class. Just override `latestUpdate`.")
    }
    
    public func add(_ observer: AnyObject,
                    receive: @escaping (Update) -> Void)
    {
        observerList.add(observer, receive: receive)
        ObservationService.didAdd(observer: observer, to: self)
    }
    
    public func remove(_ observer: AnyObject)
    {
        observerList.remove(observer)
        ObservationService.didRemove(observers: [hashValue(observer)], from: self)
    }
    
    public func removeObservers()
    {
        if observerList.isEmpty { return }
        
        let observers = observerList.hashValues
        observerList.removeAll()
        ObservationService.didRemove(observers: observers, from: self)
    }
    
    public func removeDeadObservers()
    {
        let observers = observerList.hashValuesOfNilObservers
        observerList.removeNilObservers()
        ObservationService.didRemove(observers: observers, from: self)
    }
    
    public func send(_ update: Update)
    {
        observerList.receive(update)
    }
    
    private let observerList = ObserverList<Update>()
}
