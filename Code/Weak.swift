public class Weak<O: Observable>: Observer, Observable
{
    // MARK: - Life Cycle
    
    public init(_ observable: O)
    {
        self.observable = observable
        self.latestStoredUpdate = observable.latestUpdate
        
        observe(observable) { [weak self] in self?.send($0) }
    }
    
    deinit
    {
        if let observable = observable
        {
            stopObserving(observable)
        }
        else
        {
            stopObservingDeadObservables()
        }
        
        removeObservers()
    }
    
    // MARK: - Latest Update
    
    public var latestUpdate: O.UpdateType
    {
        refreshLatestStoredUpdate()
        
        return latestStoredUpdate
    }
    
    private func refreshLatestStoredUpdate()
    {
        if let latestOriginalUpdate = observable?.latestUpdate
        {
            latestStoredUpdate = latestOriginalUpdate
        }
    }
    
    private var latestStoredUpdate: O.UpdateType
    
    // MARK: - Observable
    
    public private(set) weak var observable: O?
}
