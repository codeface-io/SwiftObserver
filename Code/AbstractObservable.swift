import SwiftyToolz

public class AbstractObservable<ObservedUpdate>: ObserverUpdater
{
    // MARK: Life Cycle
    
    init(_ update: ObservedUpdate)
    {
        self.update = update
    }
    
    deinit { removeAllObservers() }
    
    // MARK: ObserverUpdater
    
    public func add(_ observer: AnyObject,
                    _ handleUpdate: @escaping UpdateHandler)
    {
        removeNilObservers()
        
        if observerList.isEmpty
        {
            observedObjects[hash(self)] = WeakObservedObject(observed: self)
        }
        
        observerList.add(observer, handleUpdate)
    }
    
    public func remove(_ observer: AnyObject)
    {
        removeNilObservers()
        
        observerList.remove(observer)
        
        if observerList.isEmpty
        {
            observedObjects[hash(self)] = nil
        }
    }
    
    public func removeAllObservers()
    {
        observerList.removeAll()
        
        observedObjects[hash(self)] = nil
    }
    
    public func updateObservers(_ update: ObservedUpdate)
    {
        removeNilObservers()
        
        observerList.update(update)
    }
    
    public func removeNilObservers()
    {
        observerList.removeNilObservers()
        
        if observerList.isEmpty
        {
            observedObjects[hash(self)] = nil
        }
    }
    
    // MARK: Managing Observers
    
    private let observerList = ObserverList<ObservedUpdate>()
    
    public var update: ObservedUpdate
    
    public typealias UpdateType = ObservedUpdate
}

// MARK: - Registering Observed Objects

var observedObjects = [HashValue: WeakObservedObject]()

struct WeakObservedObject
{
    weak var observed: ObserverRemover?
}
