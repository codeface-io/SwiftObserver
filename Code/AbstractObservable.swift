import SwiftyToolz

public class AbstractObservable<Update>: UpdateSender
{
    // MARK: Life Cycle
    
    init(_ latest: Update)
    {
        self.latestUpdate = latest
    }
    
    deinit { removeAllObservers() }
    
    // MARK: ObserverUpdater
    
    public func add(_ observer: AnyObject,
                    _ receive: @escaping UpdateReceiver)
    {
        removeNilObservers()
        
        if observerList.isEmpty
        {
            observedObjects[hash(self)] = WeakObservedObject(observed: self)
        }
        
        observerList.add(observer, receive)
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
    
    public func send(_ update: Update)
    {
        removeNilObservers()
        
        observerList.receive(update)
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
    
    private let observerList = ObserverList<Update>()
    
    public var latestUpdate: Update
    
    public typealias UpdateType = Update
}

// MARK: - Registering Observed Objects

var observedObjects = [HashValue: WeakObservedObject]()

struct WeakObservedObject
{
    weak var observed: ObserverRemover?
}
