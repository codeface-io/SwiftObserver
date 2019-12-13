public final class Filter<O: Observable>: Observable, Observer
{
    public init(_ observable: O,
                _ keep: @escaping (O.Message) -> Bool)
    {
        self.observable = observable
        self.keep = keep
        
        observe(observable)
        {
            [weak self] message, author in
            
            if keep(message)
            {
                self?.send(message, from: author)
            }
        }
    }
    
    internal let keep: (O.Message) -> Bool
    internal let observable: O
    
    public let messenger = Messenger<O.Message>()
    public let receiver = Receiver()
}
