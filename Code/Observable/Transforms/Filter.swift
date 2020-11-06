public final class Filter<O: Observable>: Messenger<O.Message>, Observer
{
    public init(_ origin: O,
                _ keep: @escaping (O.Message) -> Bool)
    {
        self.origin = origin
        self.keep = keep
        super.init()
        observe(origin: origin)
    }
    
    public var origin: O
    {
        willSet
        {
            stopObserving(origin)
            observe(origin: newValue)
        }
    }
    
    private func observe(origin: O)
    {
        observe(origin)
        {
            [weak self] message, author in
            
            guard let self = self else { return }
            
            if self.keep(message)
            {
                self.send(message, from: author)
            }
        }
    }
    
    internal let keep: (O.Message) -> Bool
    
    public let receiver = Receiver()
}
