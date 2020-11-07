public func first<First: Observable>(_ firstObservable: () -> First) -> First
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
