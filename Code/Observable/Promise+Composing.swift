public func promise<Value>(_ promise: () -> Promise<Value>) -> Promise<Value>
{
    promise()
}

public extension Promise
{
    func then<NextValue>(_ nextPromise: @escaping (Value) -> Promise<NextValue>) -> Promise<NextValue>
    {
        Promise<NextValue>
        {
            promise in

            observedOnce
            {
                nextPromise($0).observedOnce(promise.fulfill(_:))
            }
        }
    }
    
    func then<NextValue>(_ nextPromise: @escaping (Value, AnyAuthor) -> Promise<NextValue>) -> Promise<NextValue>
    {
        Promise<NextValue>
        {
            promise in

            observedOnce
            {
                nextPromise($0, $1).observedOnce(promise.fulfill(_:as:))
            }
        }
    }
    
    func and<ConcurrentValue>(_ concurrentPromise: () -> Promise<ConcurrentValue>) -> Promise<(Value, ConcurrentValue)>
    {
        Promise<(Value, ConcurrentValue)>
        {
            promise in

            var value: Value?
            var concurrentValue: ConcurrentValue?

            func fulfillPromiseIfValuesPresent()
            {
                guard let value = value,
                      let concurrentValue = concurrentValue else { return }

                promise.fulfill((value, concurrentValue))
            }

            observedOnce
            {
                value = $0
                fulfillPromiseIfValuesPresent()
            }

            concurrentPromise().observedOnce
            {
                concurrentValue = $0
                fulfillPromiseIfValuesPresent()
            }
        }
    }
}
