public func promise<Value>(_ promise: () -> SOPromise<Value>) -> SOPromise<Value>
{
    promise()
}

public extension SOPromise
{
    func then<NextValue>(_ nextPromise: @escaping (Value) -> SOPromise<NextValue>) -> SOPromise<NextValue>
    {
        SOPromise<NextValue>
        {
            promise in

            observedOnce
            {
                nextPromise($0).observedOnce(promise.fulfill(_:))
            }
        }
    }
    
    func then<NextValue>(_ nextPromise: @escaping (Value, AnyAuthor) -> SOPromise<NextValue>) -> SOPromise<NextValue>
    {
        SOPromise<NextValue>
        {
            promise in

            observedOnce
            {
                nextPromise($0, $1).observedOnce(promise.fulfill(_:as:))
            }
        }
    }
    
    func and<ConcurrentValue>(_ concurrentPromise: () -> SOPromise<ConcurrentValue>) -> SOPromise<(Value, ConcurrentValue)>
    {
        SOPromise<(Value, ConcurrentValue)>
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
