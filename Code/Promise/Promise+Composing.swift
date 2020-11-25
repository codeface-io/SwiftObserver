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

            whenFulfilled
            {
                nextPromise($0).whenFulfilled(promise.fulfill(_:))
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

            whenFulfilled
            {
                value = $0
                fulfillPromiseIfValuesPresent()
            }

            concurrentPromise().whenFulfilled
            {
                concurrentValue = $0
                fulfillPromiseIfValuesPresent()
            }
        }
    }
}
