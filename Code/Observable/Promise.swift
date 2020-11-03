public class Promise<Value>: Messenger<Value>
{   
    public convenience init(fulfill: (Self) -> Void)
    {
        self.init()
        fulfill(self)
    }
    
    func fulfill(_ value: Value, as author: AnyAuthor)
    {
        send(value, from: author)
    }
    
    func fulfill(_ value: Value)
    {
        send(value)
    }
    
    override func _send(_ message: Message, from author: AnyAuthor)
    {
        super._send(message, from: author)
        disconnectAllReceivers()
    }
}
