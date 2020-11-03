public final class Buffer<O: Observable>: Messenger<O.Message?>, BufferedObservable, Observer
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
    
    override func _send(_ message: O.Message?, from author: AnyAuthor)
    {
        latestMessage = message
        super._send(message, from: author)
    }
    
    public var latestMessage: O.Message?
    internal let observable: O
    
    public let receiver = Receiver()
}
