public class Promise<Value>: Messenger<Value>
{   
    public convenience init(fulfill: (Promise<Value>) -> Void)
    {
        self.init()
        fulfill(self)
    }
    
    public func fulfill(_ value: Value)
    {
        send(value)
    }
    
    public func fulfill(_ value: Value, from author: AnyAuthor)
    {
        send(value, from: author)
    }
    
    public func whenFulfilled(_ receive: @escaping (Value) -> Void)
    {
        if let value = value
        {
            receive(value)
        }
        else
        {
            observe(self, receive: receive)
        }
    }
    
    override func _send(_ message: Message, from author: AnyAuthor)
    {
        super._send(message, from: author)
        value = message
    }
    
    public private(set) var value: Value?
}
