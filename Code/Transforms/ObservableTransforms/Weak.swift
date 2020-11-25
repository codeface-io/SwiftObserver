public class Weak<O: Observable>: Messenger<O.Message>, Observer
{
    public init(_ origin: O)
    {
        self.origin = origin
        super.init()
        observe(origin: origin)
    }
    
    public weak var origin: O?
    {
        willSet
        {
            stopObserving(origin)
            newValue.forSome(observe(origin:))
        }
    }
    
    private func observe(origin: O)
    {
        observe(origin)
        {
            [weak self] message, author in
            
            self?.send(message, from: author)
        }
    }
    
    public let receiver = Receiver()
}
