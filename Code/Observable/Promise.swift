public class Promise<Value>: Messenger<Value>
{
    convenience init(fulfill: (Self) -> Void)
    {
        self.init()
        fulfill(self)
    }
    
    func fulfill(_ value: Message)
    {
        send(value)
    }
    
    func fulfill(_ value: Message, as author: AnyAuthor)
    {
        send(value, from: author)
    }
}
