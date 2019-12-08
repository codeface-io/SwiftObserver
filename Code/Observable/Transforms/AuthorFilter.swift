public final class AuthorFilter<O: Observable>: Observable, Observer
{
    public init(_ observable: O,
                _ keep: @escaping (AnyAuthor) -> Bool)
    {
        self.observable = observable
        
        observe(observable)
        {
            [weak self] message, author in
            
            if keep(author)
            {
                self?.send(message, from: author)
            }
        }
    }
    
    private let observable: O
    
    public let messenger = Messenger<O.Message>()
    public let receiver = Receiver()
}
