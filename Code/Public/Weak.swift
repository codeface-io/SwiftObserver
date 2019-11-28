public class Weak<O: Observable>: Observable, Observer
{
    // MARK: - Life Cycle
    
    public init(_ observable: O)
    {
        self.observable = observable
        observe(observable) { [weak self] in self?.send($0) }
    }
    
    deinit { stopObserving(observable) }
    
    // MARK: - Wrapped Observable
    
    public private(set) weak var observable: O?
    
    // MARK: - Observable
    
    public let messenger = Messenger<O.Message>()
}
