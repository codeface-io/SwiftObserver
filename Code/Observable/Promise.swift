public class Promise<Result>: Messenger<Result>
{
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
    
    private var result: Result?
}
