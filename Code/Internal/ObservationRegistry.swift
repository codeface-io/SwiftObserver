import SwiftyToolz

class ObservationRegistry
{
    static let shared = ObservationRegistry()
    private init() {}
    
    func askRegisteredObservablesToRemove(observer: AnyObserver)
    {
        observationsByObserver1st[key(observer)]?.values.forEach {
            $0.messenger?.receiverWantsToBeRemoved(observer)
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
    
    func unregister(messenger: AnyObject)
    {
        let messengerKey = key(messenger)
        
        observationsByObservable1st[messengerKey]?.keys.forEach { observerKey in
            observationsByObserver1st[observerKey]?[messengerKey] = nil
        }
        
        observationsByObservable1st[messengerKey] = nil
    }
    
    func registerThat(_ observer: AnyObserver,
                      observes observable: RegisteredMessenger)
    {
        guard !isRegisteredThat(observer, observes: observable) else { return }
        
        let observation = RegisteredObservation(observer: observer, messenger: observable)
        
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
                        observes observable: RegisteredMessenger)
    {
        guard isRegisteredThat(observer, observes: observable) else { return }
        
        observationsByObserver1st[key(observer)]?[key(observable)] = nil
        observationsByObservable1st[key(observable)]?[key(observer)] = nil
    }
    
    private func isRegisteredThat(_ observer: AnyObserver,
                                  observes observable: RegisteredMessenger) -> Bool
    {
        guard let observation = observationsByObserver1st[key(observer)]?[key(observable)] else
        {
            return false
        }
        
        return observation.observer != nil && observation.messenger != nil
    }
    
    private var observationsByObserver1st = [ObserverKey : [ObservableKey: RegisteredObservation]]()
    private var observationsByObservable1st = [ObservableKey : [ObserverKey : RegisteredObservation]]()
    
    private class RegisteredObservation
    {
        init(observer: AnyObserver, messenger: RegisteredMessenger)
        {
            self.observer = observer
            self.messenger = messenger
        }
        
        weak var observer: AnyObserver?
        weak var messenger: RegisteredMessenger?
    }
}

// MARK: - Basic Types

protocol RegisteredMessenger: AnyObject
{
    func receiverWantsToBeRemoved(_ receiver: AnyObject)
}

typealias ObserverKey = ObjectIdentifier
typealias AnyObserver = AnyObject

typealias ObservableKey = ObjectIdentifier
typealias AnyObservable = AnyObject

func key(_ object: AnyObject) -> ObjectIdentifier { ObjectIdentifier(object) }
