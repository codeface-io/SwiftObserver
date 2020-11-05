public class Unwrapper<O: Observable, Unwrapped>: Observable, Observer
    where O.Message == Unwrapped?
{
    public init(_ origin: O)
    {
        self.origin = origin
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
            [weak self] optionalMessage, author in
            
            guard let self = self else { return }
            
            if let unwrappedMessage = optionalMessage
            {
                self.send(unwrappedMessage, from: author)
            }
        }
    }
    
    public let messenger = Messenger<Unwrapped>()
    public let receiver = Receiver()
}
