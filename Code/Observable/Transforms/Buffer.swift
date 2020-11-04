public final class BufferForNonOptionalMessage<O: Observable, Unwrapped>:
    Messenger<Unwrapped?>,
    BufferedObservable,
    Observer
    where O.Message == Unwrapped
{
    public init(_ observable: O)
    {
        self.observable = observable
        
        super.init()
        
        observe(observable)
        {
            [weak self] message, author in
            
            self?._send(message, from: author)
        }
    }
    
    override func _send(_ message: Unwrapped?, from author: AnyAuthor)
    {
        latestMessage = message
        super._send(message, from: author)
    }
    
    public var latestMessage: Unwrapped?
    internal let observable: O
    
    public let receiver = Receiver()
}

public final class BufferForOptionalMessage<O: Observable, Unwrapped>:
    Messenger<Unwrapped?>,
    BufferedObservable,
    Observer
    where O.Message == Unwrapped?
{
    public init(_ observable: O)
    {
        self.observable = observable
        
        super.init()
        
        observe(observable)
        {
            [weak self] message, author in
            
            self?._send(message, from: author)
        }
    }
    
    override func _send(_ message: Unwrapped?, from author: AnyAuthor)
    {
        latestMessage = message
        super._send(message, from: author)
    }
    
    public var latestMessage: Unwrapped?
    internal let observable: O
    
    public let receiver = Receiver()
}
