public extension Observable
{
    func unwrap<Wrapped>() -> Unwrapper<Self, Wrapped>
        where Message == Wrapped?
    {
        Unwrapper(self)
    }
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
    public let receiver = Receiver()
}
