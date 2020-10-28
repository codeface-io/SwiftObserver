public class Promise<Result>: Messenger<Result>
{
    public init(_ result: Result? = nil)
    {
        self.result = result
    }
    
    override func _send(_ message: Message, from author: AnyAuthor)
    {
        super._send(message, from: author)
        // TODO: stop observations
        result = message
    }
    
    public func done(_ receive: @escaping (Message) -> Void)
    {
        if let result = result
        {
            receive(result)
        }
        else
        {
            observe(self, receive: receive)
        }
    }
    
    public private(set) var result: Result?
}
