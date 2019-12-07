public final class AuthorFilter<O: Observable>: Observable, Observer
{
    public init(_ observable: O,
                _ keep: @escaping (AnyAuthor) -> Bool)
    {
        self.observable = observable
        
        observe(observable)
        {
            [weak self] in
            
            if keep($1)
            {
                self?.send($0, author: $1)
            }
        }
    }
    
    private let observable: O
    
    public let messenger = Messenger<O.Message>()
    public let receiver = Receiver()
}
