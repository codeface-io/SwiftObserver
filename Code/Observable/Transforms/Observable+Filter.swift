public extension Observable
{
    func filter(_ keep: @escaping (Message) -> Bool) -> Filter<Self>
    {
        Filter(self, keep)
    }
}

public final class Filter<O: Observable>: Observable, Observer
{
    public init(_ observable: O,
                _ keep: @escaping (O.Message) -> Bool)
    {
        self.observable = observable
        
        observe(observable)
        {
            [weak self] in
            
            if keep($0)
            {
                self?.send($0, author: $1)
            }
        }
    }
    
    private let observable: O
    public let messenger = Messenger<O.Message>()
    public let receiver = Receiver()
}
