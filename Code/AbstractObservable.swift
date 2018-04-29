import SwiftyToolz

public class AbstractObservable<ObservedUpdate>: ObservableProtocol
{
    // MARK: Life Cycle
    
    init(_ update: ObservedUpdate)
    {
        self.update = update
    }
    
    deinit { removeAllObservers() }
    
    // MARK: ObservableProtocol
    
    public func add(_ observer: AnyObject,
                    _ handleUpdate: @escaping UpdateHandler)
    {
        removeNilObservers()
        
        let observerInfo = ObserverInfo(observer: observer,
                                        handleUpdate: handleUpdate)
        
        observerInfos[hash(observer)] = observerInfo
        
        if observerInfos.count == 1
        {
            observedObjects[hash(self)] = WeakObservedObject(observed: self)
        }
    }
    
    public func remove(_ observer: AnyObject)
    {
        removeNilObservers()
        
        observerInfos[hash(observer)] = nil
        
        if observerInfos.count == 0
        {
            observedObjects[hash(self)] = nil
        }
    }
    
    public func removeAllObservers()
    {
        observerInfos.removeAll()
        
        observedObjects[hash(self)] = nil
    }
    
    // MARK: Updating Observers
    
    public func updateObservers(_ update: ObservedUpdate)
    {
        removeNilObservers()
        
        for observerInfo in observerInfos.values
        {
            observerInfo.handleUpdate?(update)
        }
    }
    
    // MARK: Managing Observers
    
    public func removeNilObservers()
    {
        observerInfos.remove { $0.observer == nil || $0.handleUpdate == nil}
        
        if observerInfos.count == 0
        {
            observedObjects[hash(self)] = nil
        }
    }
    
    private var observerInfos = [HashValue: ObserverInfo]()
    
    private struct ObserverInfo
    {
        weak var observer: AnyObject?
        var handleUpdate: UpdateHandler?
    }
    
    public var update: ObservedUpdate
    
    public typealias UpdateType = ObservedUpdate
}

// MARK: - Registering Observed Objects

var observedObjects = [HashValue: WeakObservedObject]()

struct WeakObservedObject
{
    weak var observed: ObserverRemover?
}
