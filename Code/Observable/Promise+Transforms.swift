public extension SOPromise
{
    func map<Mapped>(_ map: @escaping (Value) -> Mapped) -> SOPromise<Mapped>
    {
        SOPromise<Mapped>
        {
            promise in

            observedOnce
            {
                promise.fulfill(map($0), as: $1)
            }
        }
    }
    
    func unwrap<Wrapped>(_ defaultValue: Wrapped) -> SOPromise<Wrapped>
        where Value == Wrapped?
    {
        SOPromise<Wrapped>
        {
            promise in

            observedOnce
            {
                promise.fulfill($0 ?? defaultValue, as: $1)
            }
        }
    }
    
    func new<UpdateValue>() -> SOPromise<UpdateValue>
        where Value == Update<UpdateValue>
    {
        SOPromise<UpdateValue>
        {
            promise in

            observedOnce
            {
                promise.fulfill($0.new, as: $1)
            }
        }
    }
}
