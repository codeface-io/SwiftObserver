public func firstly<First: Observable>(firstObservable: () -> First) -> First
{
    firstObservable()
}

public extension Observable
{
    func then<Next: Observable>(_ nextObservable: @escaping (Message) -> Next) -> Promise<Next.Message>
    {
        let promise = Promise<Next.Message>()
        
        let observer = AdhocObserver()
        
        observer.observe(self) {
            observer.stopObserving()
            observer.observe(nextObservable($0)) {
                observer.stopObserving()
                promise.fulfill($0)
            }
        }
        
        return promise
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
