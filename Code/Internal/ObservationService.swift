import SwiftyToolz

class ObservationService
{
    // MARK: - For Clients to Reach Observables
    
    static func remove(observer: AnyObject)
    {
        let observerHash = hashValue(observer)
        
        observations[observerHash]?.observables.forEach
        {
            $0.observable?.removeFromRegisteredObservables(observer)
        }
        
        observations[observerHash] = nil
    }

    static func removeDeadObservers()
    {
        observations.values.forEach
        {
            if $0.observer == nil
            {
                $0.observables.forEach
                {
                    $0.observable?.removeDeadObserversFromRegisteredObservables()
                }
            }
        }
        
        observations.remove { $0.observer == nil }
    }
    
    // MARK: - For Observables
    
    static func willDeinit(_ observable: RegisteredObservable,
                           with observers: [HashValue])
    {
        unregister(observers: observers, of: observable)
    }
    
    static func didAdd(observer: AnyObject,
                       to observable: RegisteredObservable)
    {
        register(observer: observer, of: observable)
    }
    
    static func didRemove(observers: [HashValue],
                          from observable: RegisteredObservable)
    {
        unregister(observers: observers, of: observable)
    }
    
    // MARK: - Private
    
    static func register(observer: AnyObject, of observable: RegisteredObservable)
    {
        let observerHash = hashValue(observer)
        
        let weakObservable = WeakObservable(observable: observable)
        
        let observation = observations[observerHash]
        
        if observation == nil || observation?.observer == nil
        {
            observations[observerHash] = Observation(observer: observer,
                                                     observables: [weakObservable])
        }
        else
        {
            observations[observerHash]?.observables.append(weakObservable)
        }
    }
    
    static func unregister(observers: [HashValue], of observable: RegisteredObservable)
    {
        observers.forEach
        {
            observations[$0]?.observables.remove { $0.observable === observable }
            
            if observations[$0]?.observables.isEmpty ?? true
            {
                observations[$0] = nil
            }
        }
    }
    
    private static var observations = [HashValue : Observation]()
    
    private struct Observation
    {
        weak var observer: AnyObject?
        
        var observables = [WeakObservable]()
    }
    
    private struct WeakObservable
    {
        weak var observable: RegisteredObservable?
    }
}

protocol RegisteredObservable: AnyObject
{
    func removeFromRegisteredObservables(_ observer: AnyObject)
    func removeDeadObserversFromRegisteredObservables()
}
