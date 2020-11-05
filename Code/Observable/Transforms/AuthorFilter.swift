public final class AuthorFilter<O: Observable>: Observable, Observer
{
    public init(_ origin: O,
                _ keep: @escaping (AnyAuthor) -> Bool)
    {
        self.origin = origin
        self.keep = keep
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
            
            if self.keep(author)
            {
                self.send(message, from: author)
            }
        }
    }
    
    private let keep: (AnyAuthor) -> Bool
    
    public let messenger = Messenger<O.Message>()
    public let receiver = Receiver()
}
