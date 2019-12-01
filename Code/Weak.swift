public class Weak<O: Observable>: Observable, Observer
{
    public init(_ observable: O)
    {
        self.observable = observable
        observe(observable) { [weak self] in self?.send($0, author: $1) }
    }
    
    deinit { stopObserving(observable) }
    
    public private(set) weak var observable: O?
    
    public let messenger = Messenger<O.Message>()
}
