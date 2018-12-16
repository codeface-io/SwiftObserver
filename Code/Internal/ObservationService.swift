import SwiftyToolz

class ObservationService
{
    // MARK: - Globally Remove Observers
    
    static func remove(observer: AnyObject)
    {
        let observerKey = hashValue(observer)
        
        observableLists[observerKey]?.observables.forEach
        {
            $0.value.obserbable?.observationServiceWillRemove(observer)
        }
        
        observableLists[observerKey] = nil
    }

    static func removeDeadObservers()
    {
        observables.forEach
        {
            $0.value.obserbable?.observationServiceWillRemoveDeadObservers()
        }
        
        observableLists.remove { $0.observer == nil }
    }
    
    // MARK: - Register/Unregister Observables
    
    static func register(observable: RegisteredObservable)
    {
        observables[hashValue(observable)] = WeakObservable(observable)
    }
    
    static func unregister(observable: RegisteredObservable,
                           with observers: [HashValue])
    {
        didRemove(observers, from: observable)
        
        observables[hashValue(observable)] = nil
    }
    
    // MARK: - Track Observations (Observers)
    
    static func didAdd(_ observer: AnyObject,
                       to observable: RegisteredObservable)
    {
        let observableKey = hashValue(observable)
        
        let list = observableList(for: observer)
        
        list.observables[observableKey] = WeakObservable(observable)
    }
    
    static func didRemove(_ observers: [HashValue],
                          from observable: RegisteredObservable)
    {
        let observableKey = hashValue(observable)
        
        observers.forEach
        {
            let list = observableLists[$0]
                
            list?.observables[observableKey] = nil
            
            if list?.observables.isEmpty ?? false
            {
                observableLists[$0] = nil
            }
        }
    }
    
    private static func observableList(for observer: AnyObject) -> ObservableList
    {
        let observerHash = hashValue(observer)
        
        if let list = observableLists[observerHash], list.observer != nil
        {
            return list
        }
        else
        {
            let newList = ObservableList(observer: observer)
            
            observableLists[observerHash] = newList
            
            return newList
        }
    }
    
    private static var observableLists = [HashValue : ObservableList]()
    
    private class ObservableList
    {
        init(observer: AnyObject)
        {
            self.observer = observer
        }
        
        weak var observer: AnyObject?
        
        var observables = [HashValue : WeakObservable]()
    }
    
    // MARK: - Registered Observables
    
    private static var observables = [HashValue : WeakObservable]()
    
    private struct WeakObservable
    {
        init(_ observable: RegisteredObservable)
        {
            self.obserbable = observable
        }
        
        weak var obserbable: RegisteredObservable?
    }
}

protocol RegisteredObservable: AnyObject
{
    func observationServiceWillRemove(_ observer: AnyObject)
    func observationServiceWillRemoveDeadObservers()
}
