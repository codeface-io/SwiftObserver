public func first<First: Observable>(firstObservable: () -> First) -> First
{
    firstObservable()
}

public extension Observable
{
    func then<Next: Observable>(_ nextObservable: @escaping (Message) -> Next) -> Promise<Next.Message>
    {
        Promise
        {
            promise in
        
            observedOnce
            {
                nextObservable($0).observedOnce(promise.fulfill(_:))
            }
        }
    }
    
    func then<Next: Observable>(_ nextObservable: @escaping (Message, AnyAuthor) -> Next) -> Promise<Next.Message>
    {
        Promise
        {
            promise in
    
            observedOnce
            {
                nextObservable($0, $1).observedOnce(promise.fulfill(_:as:))
            }
        }
    }
}

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
