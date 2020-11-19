public class SOPromise<Value>: Messenger<Value>
{
    public convenience init(fulfill: (Self) -> Void)
    {
        self.init()
        fulfill(self)
    }
    
    public func fulfill(_ value: Value)
    {
        send(value)
    }
    
    public func fulfill(_ value: Value, as author: AnyAuthor)
    {
        send(value, from: author)
    }
}
