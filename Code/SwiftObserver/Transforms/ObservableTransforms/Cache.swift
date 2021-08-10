public final class Cache<O: ObservableObject, Unwrapped>:
    Messenger<Unwrapped?>,
    ObservableCache,
    Observer
    where O.Message == Unwrapped
{
    public init(_ origin: O)
    {
        self.origin = origin
        super.init()
        observe(origin: origin)
    }
    
    override func _send(_ message: Unwrapped?, from author: AnyAuthor)
    {
        latestMessage = message
        super._send(message, from: author)
    }
    
    public var latestMessage: Unwrapped?
    
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
            
            self?._send(message, from: author)
        }
    }
    
    public let receiver = Receiver()
}
