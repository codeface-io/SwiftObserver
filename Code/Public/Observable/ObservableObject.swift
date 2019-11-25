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

public class ObservableObject<Message>: Observable
{
    // MARK: - Register in Observation Service
    
    public init() { ObservationService.register(observable: self) }
    
    deinit { ObservationService.unregister(observable: self,
                                           with: observerList.hashValues) }
   
    // MARK: - Observable
    
    public func add(_ observer: AnyObject,
                    receive: @escaping (Message) -> Void)
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
    
    public func stopObservations()
    {
        let observerHashs = observerList.hashValues
        
        guard !observerHashs.isEmpty else { return }
        
        observerList.removeAll()
        
        ObservationService.didRemove(observerHashs, from: self)
    }
    
    public func stopAbandonedObservations()
    {
        let observerHashs = observerList.hashValuesOfNilObservers
        
        guard !observerHashs.isEmpty else { return }
        
        observerList.removeDeadObservers()
        
        ObservationService.didRemove(observerHashs, from: self)
    }
    
    public func send(_ message: Message)
    {
        observerList.receive(message)
    }
    
    private let observerList = ObserverList<Message>()
}
