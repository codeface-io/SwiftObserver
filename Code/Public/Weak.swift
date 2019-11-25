public class Weak<O: Observable>: ObservableObject<O.Message>, Observer
{
    // MARK: - Life Cycle
    
    public init(_ observable: O)
    {
        self.observable = observable
        
        super.init()
        
        observe(observable) { [weak self] in self?.send($0) }
    }
    
    deinit { stopObserving(observable) }
    
    // MARK: - Observable
    
    public private(set) weak var observable: O?
}
