import SwiftyToolz

internal class ObservationService
{
    // MARK: Add Observers
    
    static func add(_ observer: AnyObject,
                    of observed: AnyObject,
                    with handleUpdate: @escaping (Any?) -> ())
    {
        removeAbandonedObservings()
        
        let observerInfo = ObserverInfo(observer: observer,
                                        handleUpdate: handleUpdate)
        
        mapping(of: observed).observerInfos[hash(observer)] = observerInfo
    }
    
    private static func mapping(of observed: AnyObject) -> Mapping
    {
        return mappings[hash(observed)] ?? createAndAddMapping(of: observed)
    }
    
    private static func createAndAddMapping(of observed: AnyObject) -> Mapping
    {
        let mapping = Mapping()
        
        mapping.observed = observed
        
        mappings[hash(observed)] = mapping
        
        return mapping
    }
    
    // MARK: Remove Observers
    
    static func remove(_ observer: AnyObject, of observed: AnyObject)
    {
        removeAbandonedObservings()
        
        guard let mapping = mappings[hash(observed)] else { return }
        
        mapping.observerInfos[hash(observer)] = nil
        
        if mapping.observerInfos.isEmpty
        {
            mappings[hash(observed)] = nil
        }
    }
    
    static func removeAllObservers(of observed: AnyObject)
    {
        removeAbandonedObservings()
        
        mappings[hash(observed)] = nil
    }
    
    static func removeObserverFromAllObservables(_ observer: AnyObject)
    {
        for mapping in mappings.values
        {
            mapping.observerInfos[hash(observer)] = nil
        }
        
        removeAbandonedObservings()
    }
    
    // MARK: Send Events to Observers
    
    static func updateObservers(of observed: AnyObject, with event: Any?)
    {
        removeAbandonedObservings()
        
        guard let mapping = mappings[hash(observed)] else { return }
        
        for observer in mapping.observerInfos.values
        {
            observer.handleUpdate?(event)
        }
    }
    
    static func removeAbandonedObservings()
    {
        for mapping in mappings.values
        {
            mapping.observerInfos.remove
                {
                    $0.observer == nil || $0.handleUpdate == nil
            }
        }
        
        mappings.remove { $0.observed == nil || $0.observerInfos.isEmpty }
    }
    
    // MARK: Private State
    
    private static var mappings = [HashValue: Mapping]()
    
    private class Mapping
    {
        weak var observed: AnyObject?
        
        var observerInfos = [HashValue: ObserverInfo]()
    }
    
    private class ObserverInfo
    {
        init(observer: AnyObject, handleUpdate: @escaping (Any?) -> ())
        {
            self.observer = observer
            self.handleUpdate = handleUpdate
        }
        
        weak var observer: AnyObject?
        var handleUpdate: ((Any?) -> ())?
    }
}
