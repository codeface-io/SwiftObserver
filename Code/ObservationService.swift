import SwiftyToolz

public class ObservationService
{
    // MARK: Add Observers
    
    public static func add<O: Observable>(_ observer: AnyObject,
                                          of observable: O,
                                          _ receive: @escaping (O.UpdateType) -> Void)
    {
        removeAbandonedObservations()
        
        observation(of: observable).observerList.add(observer)
        {
            guard let update = $0 as? O.UpdateType else
            {
                fatalError("Impossible error: Update of observable is not of the observable's update type.")
            }
            
            receive(update)
        }
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
    
    public static func remove(_ observer: AnyObject, from observed: AnyObject)
    {
        removeAbandonedObservations()
        
        guard let observation = observations[hash(observed)] else { return }
        
        observation.observerList.remove(observer)
        
        if observation.observerList.isEmpty
        {
            observations[hash(observed)] = nil
        }
    }
    
    public static func removeAllObservers(of observed: AnyObject)
    {
        removeAbandonedObservations()
        
        observations[hash(observed)] = nil
    }
    
    public static func removeObserverFromAllObservables(_ observer: AnyObject)
    {
        for observation in observations.values
        {
            observation.observerList.remove(observer)
        }
        
        removeAbandonedObservations()
    }
    
    public static func removeNilObservers(of observed: AnyObject)
    {
        observations[hash(observed)]?.observerList.removeNilObservers()
    }
    
    // MARK: Send Events to Observers
    
    public static func send(_ event: Any?, toObserversOf observed: AnyObject)
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
