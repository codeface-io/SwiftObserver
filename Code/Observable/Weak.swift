public final class Weak<O: Observable>: Observable, Observer
{
    public init(_ observable: O)
    {
        self.observable = observable
        
        observe(observable)
        {
            [weak self] message, author in self?.send(message, from: author)
        }
    }
    
    deinit { stopObserving(observable) }
    
    public private(set) weak var observable: O?
    
    public let messenger = Messenger<O.Message>()
    public let receiver = Receiver()
}
