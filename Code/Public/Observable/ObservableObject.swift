import SwiftyToolz

extension ObservableObject: RegisteredObservable
{
    func observationServiceWillRemove(_ observer: AnyObject)
    {
        observerList.remove(observer)
    }
    
    func observationServiceWillRemoveDeadObservers()
    {
        observerList.removeDeadObservers()
    }
}

public class ObservableObject<Update>: Observable
{
    // MARK: - Register in Observation Service
    
    init() { ObservationService.register(observable: self) }
    
    deinit { ObservationService.unregister(observable: self) }
   
    // MARK: - Observable
    
    public var latestUpdate: Update
    {
        fatalError("\(typeName(self)) is an abstract class. Just override `latestUpdate`.")
    }
    
    public func add(_ observer: AnyObject,
                    receive: @escaping (Update) -> Void)
    {
        observerList.add(observer, receive: receive)
        
        ObservationService.didAdd(observer, to: self)
    }
    
    public func remove(_ observer: AnyObject)
    {
        if observerList.remove(observer)
        {
            ObservationService.didRemove([hashValue(observer)], from: self)
        }
    }
    
    public func removeObservers()
    {
        let observerHashs = observerList.hashValues
        
        guard !observerHashs.isEmpty else { return }
        
        observerList.removeAll()
        
        ObservationService.didRemove(observerHashs, from: self)
    }
    
    public func removeDeadObservers()
    {
        let observerHashs = observerList.hashValuesOfNilObservers
        
        guard !observerHashs.isEmpty else { return }
        
        observerList.removeDeadObservers()
        
        ObservationService.didRemove(observerHashs, from: self)
    }
    
    public func send(_ update: Update)
    {
        observerList.receive(update)
    }
    
    private let observerList = ObserverList<Update>()
}
