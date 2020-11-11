public class Promise<Value>: Messenger<Value>
{
    convenience init(fulfill: (Self) -> Void)
    {
        self.init()
        fulfill(self)
    }
    
    func fulfill(_ value: Value)
    {
        send(value)
    }
    
    func fulfill(_ value: Value, as author: AnyAuthor)
    {
        send(value, from: author)
    }
}
