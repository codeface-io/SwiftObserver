import SwiftyToolz

class ObservationRegistry
{
    static let shared = ObservationRegistry()
    private init() {}
    
    func askRegisteredObservablesToRemove(observer: AnyObserver)
    {
        observationsByObserver1st[key(observer)]?.values.forEach {
            $0.observable?.observerWantsToBeRemoved(observer)
        }
    }
    
    func unregister(observer: Observer)
    {
        let observerKey = key(observer)
        
        observationsByObserver1st[observerKey]?.forEach { (observableKey, observation) in
            observationsByObservable1st[observableKey]?[observerKey] = nil
        }
        
        observationsByObserver1st[observerKey] = nil
    }
    
    func unregister(observable: AnyObservable)
    {
        let observableKey = key(observable)
        
        observationsByObservable1st[observableKey]?.keys.forEach { observerKey in
            observationsByObserver1st[observerKey]?[observableKey] = nil
        }
        
        observationsByObservable1st[observableKey] = nil
    }
    
    func registerThat(_ observer: AnyObserver,
                      observes observable: RegisteredObservable)
    {
        guard !isRegisteredThat(observer, observes: observable) else { return }
        
        let observation = RegisteredObservation(observer: observer, observable: observable)
        
        if observationsByObserver1st[key(observer)] == nil
        {
           observationsByObserver1st[key(observer)] = [ObservableKey: RegisteredObservation]()
        }
        
        observationsByObserver1st[key(observer)]?[key(observable)] = observation
        
        if observationsByObservable1st[key(observable)] == nil
        {
           observationsByObservable1st[key(observable)] = [ObserverKey: RegisteredObservation]()
        }

        observationsByObservable1st[key(observable)]?[key(observer)] = observation
    }
    
    func unregisterThat(_ observer: AnyObserver,
                        observes observable: RegisteredObservable)
    {
        guard isRegisteredThat(observer, observes: observable) else { return }
        
        observationsByObserver1st[key(observer)]?[key(observable)] = nil
        observationsByObservable1st[key(observable)]?[key(observer)] = nil
    }
    
    private func isRegisteredThat(_ observer: AnyObserver,
                                  observes observable: RegisteredObservable) -> Bool
    {
        guard let observation = observationsByObserver1st[key(observer)]?[key(observable)] else
        {
            return false
        }
        
        return observation.observer != nil && observation.observable != nil
    }
    
    private var observationsByObserver1st = [ObserverKey : [ObservableKey: RegisteredObservation]]()
    private var observationsByObservable1st = [ObservableKey : [ObserverKey : RegisteredObservation]]()
    
    private class RegisteredObservation
    {
        init(observer: AnyObserver, observable: RegisteredObservable)
        {
            self.observer = observer
            self.observable = observable
        }
        
        weak var observer: AnyObserver?
        weak var observable: RegisteredObservable?
    }
}

// MARK: - Basic Types

protocol RegisteredObservable: AnyObservable
{
    func observerWantsToBeRemoved(_ observer: AnyObserver)
}

func key(_ object: AnyObject) -> ObjectIdentifier { ObjectIdentifier(object) }

typealias ObserverKey = ObjectIdentifier
typealias AnyObserver = AnyObject

typealias ObservableKey = ObjectIdentifier
typealias AnyObservable = AnyObject
