public class Filter<O: Observable>: Observable, Observer
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
}

public class Unwrapper<O: Observable, Unwrapped>: Observable, Observer
    where O.Message == Unwrapped?
{
    public init(_ observable: O)
    {
        self.observable = observable
        
        observe(observable)
        {
            [weak self] in
            
            if let unwrapped = $0
            {
                self?.send(unwrapped, author: $1)
            }
        }
    }
    
    private let observable: O
    public let messenger = Messenger<Unwrapped>()
}

extension Mapper: BufferedObservable where O: BufferedObservable
{
    public var latestMessage: Mapped
    {
        map(observable.latestMessage)
    }
}

public class Mapper<O: Observable, Mapped>: Observable, Observer
{
    public init(_ observable: O,
                _ map: @escaping (O.Message) -> Mapped)
    {
        self.observable = observable
        self.map = map
        
        observe(observable)
        {
            [weak self] in
            
            self?.send(map($0), author: $1)
        }
    }
    
    private let map: (O.Message) -> Mapped
    private let observable: O
    
    public let messenger = Messenger<Mapped>()
}
