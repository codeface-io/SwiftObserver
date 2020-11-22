public class Promise<Value>: Messenger<Value>
{
    public static func fulfilled(_ value: Value) -> Promise
    {
        Promise { $0.fulfill(value) }
    }
    
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
