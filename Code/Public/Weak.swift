public class Weak<O: Observable>: ObservableObject<O.UpdateType>, Observer
{
    // MARK: - Life Cycle
    
    public init(_ observable: O)
    {
        self.observable = observable
        self.latestStoredUpdate = observable.latestUpdate
        
        super.init()
        
        observe(observable) { [weak self] in self?.send($0) }
    }
    
    deinit
    {
        if observable != nil
        {
            stopObserving(observable)
        }
        else
        {
            stopObservingDeadObservables()
        }
    }
    
    // MARK: - Latest Update
    
    public override var latestUpdate: O.UpdateType
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
