import SwiftyToolz

public class ObservationService
{
    // MARK: - Add Observers
    
    public static func add<O: Observable>(_ observer: AnyObject,
                                          of observable: O,
                                          filter keep: ((O.UpdateType) -> Bool)? = nil,
                                          receive: @escaping (O.UpdateType) -> Void)
    {
        observation(of: observable).observerList.add(observer)
        {
            guard let update = $0 as? O.UpdateType else
            {
                log(error: "Impossible: Update from observable is not of the observable's update type \(O.UpdateType.self).")
                
                return
            }
            
            if keep?(update) ?? true { receive(update) }
        }
    }

    private static func observation(of observed: AnyObject) -> Observation
    {
        guard let observation = observations[hashValue(observed)] else
        {
            return createAndAddObservation(of: observed)
        }
        
        guard observation.observed != nil else
        {
            log(warning: "Will replace observation of dead observable (which had the same memory address, i.e. hash value).")
            
            return createAndAddObservation(of: observed)
        }
        
        return observation
    }
    
    private static func createAndAddObservation(of observed: AnyObject) -> Observation
    {
        let observation = Observation()
        observation.observed = observed
        
        observations[hashValue(observed)] = observation
        
        return observation
    }
    
    // MARK: - Remove Observers
    
    public static func remove(_ observer: AnyObject, of observed: AnyObject)
    {
        guard let observation = observations[hashValue(observed)] else { return }
        
        observation.observerList.remove(observer)
        
        if observation.observerList.isEmpty
        {
            observations[hashValue(observed)] = nil
        }
    }
    
    public static func removeObservers(of observed: AnyObject)
    {
        observations[hashValue(observed)] = nil
    }
    
    public static func removeObserver(_ observer: AnyObject)
    {
        observations.values.forEach { $0.observerList.remove(observer) }
        observations.remove { $0.observerList.isEmpty }
    }
    
    public static func removeObservationsOfDeadObservables()
    {
        observations.remove { $0.observed == nil }
    }
    
    public static func removeDeadObservers(of observed: AnyObject)
    {
        guard let observerList = observations[hashValue(observed)]?.observerList else
        {
            return
        }
        
        observerList.removeNilObservers()
        
        if observerList.isEmpty { observations[hashValue(observed)] = nil }
    }
    
    // MARK: - Send Updates to Observers
    
    public static func send(_ update: Any?, toObserversOf observed: AnyObject)
    {
        let observableHash = hashValue(observed)
        
        guard let observation = observations[observableHash] else { return }
        
        guard observation.observed != nil else
        {
            log(warning: "Will remove observation of dead observable.")
            observations.removeValue(forKey: observableHash)
            return
        }
            
        observation.observerList.receive(update)
    }
    
    // MARK: - Global Clean Up
    
    public static func removeAbandonedObservations()
    {
        observations.values.forEach { $0.observerList.removeNilObservers() }
        observations.remove { $0.observed == nil || $0.observerList.isEmpty }
        
        removeDeadObserversFromExternalObservables()
    }
    
    // MARK: - Observations
    
    private static var observations = [HashValue: Observation]()
    
    private class Observation
    {
        weak var observed: AnyObject?
        let observerList = ObserverList<Any?>()
    }
    
    // MARK: - External Observables
    
    static func removeDeadObserversFromExternalObservables()
    {
        externalObservables.remove { $0.observable == nil }
        externalObservables.values.forEach { $0.observable?.removeDeadObservers() }
    }
    
    static func register<O: Observable>(observable: O)
    {
        let weakObservable = WeakObservable(observable: observable)
        externalObservables[hashValue(observable)] = weakObservable
    }
    
    static func unregister<O: Observable>(observable: O)
    {
        externalObservables[hashValue(observable)] = nil
    }
    
    private static var externalObservables = [HashValue : WeakObservable]()
    
    private struct WeakObservable
    {
        weak var observable: ObserverRemover?
    }
}
