import SwiftyToolz

class ObservationService
{
    // MARK: Add Observers
    
    static func add(_ observer: AnyObject,
                    of observed: AnyObject,
                    with receive: @escaping (Any?) -> Void)
    {
        removeAbandonedObservations()

        observation(of: observed).observerList.add(observer, receive)
    }
    
    private static func observation(of observed: AnyObject) -> Observation
    {
        return observations[hash(observed)] ?? createAndAddObservation(of: observed)
    }
    
    private static func createAndAddObservation(of observed: AnyObject) -> Observation
    {
        let observation = Observation()
        
        observation.observed = observed
        
        observations[hash(observed)] = observation
        
        return observation
    }
    
    // MARK: Remove Observers
    
    static func remove(_ observer: AnyObject, of observed: AnyObject)
    {
        removeAbandonedObservations()
        
        guard let observation = observations[hash(observed)] else { return }
        
        observation.observerList.remove(observer)
        
        if observation.observerList.isEmpty
        {
            observations[hash(observed)] = nil
        }
    }
    
    static func removeAllObservers(of observed: AnyObject)
    {
        removeAbandonedObservations()
        
        observations[hash(observed)] = nil
    }
    
    static func removeObserverFromAllObservables(_ observer: AnyObject)
    {
        for observation in observations.values
        {
            observation.observerList.remove(observer)
        }
        
        removeAbandonedObservations()
    }
    
    static func removeNilObservers(of observed: AnyObject)
    {
        observations[hash(observed)]?.observerList.removeNilObservers()
    }
    
    // MARK: Send Events to Observers
    
    static func send(_ event: Any?, toObserversOf observed: AnyObject)
    {
        removeAbandonedObservations()
        
        observations[hash(observed)]?.observerList.receive(event)
    }
    
    // MARK: Private State
    
    private static func removeAbandonedObservations()
    {
        for observation in observations.values
        {
            observation.observerList.removeNilObservers()
        }
        
        observations.remove { $0.observed == nil || $0.observerList.isEmpty }
    }
    
    private static var observations = [HashValue: Observation]()
    
    private class Observation
    {
        weak var observed: AnyObject?
        let observerList = ObserverList<Any?>()
    }
}
