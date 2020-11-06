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
