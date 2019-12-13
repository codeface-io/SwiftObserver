public class Unwrapper<O: Observable, Unwrapped>: Observable, Observer
    where O.Message == Unwrapped?
{
    public init(_ observable: O)
    {
        self.observable = observable
        
        observe(observable)
        {
            [weak self] optionalMessage, author in
            
            if let unwrappedMessage = optionalMessage
            {
                self?.send(unwrappedMessage, from: author)
            }
        }
    }
    
    private let observable: O
    
    public let messenger = Messenger<Unwrapped>()
    public let receiver = Receiver()
}
