import Dispatch

public class Promise<Value>: Messenger<Value>
{
    public static func fulfilling(_ value: Value) -> Promise
    {
        Promise
        {
            promise in DispatchQueue.main.async { promise.fulfill(value) }
        }
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
