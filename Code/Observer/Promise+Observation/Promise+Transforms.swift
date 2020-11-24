public extension Promise
{
    func map<Mapped>(_ map: @escaping (Value) -> Mapped) -> Promise<Mapped>
    {
        Promise<Mapped>
        {
            promise in

            whenFulfilled
            {
                promise.fulfill(map($0))
            }
        }
    }
    
    func unwrap<Wrapped>(_ defaultValue: Wrapped) -> Promise<Wrapped>
        where Value == Wrapped?
    {
        Promise<Wrapped>
        {
            promise in

            whenFulfilled
            {
                promise.fulfill($0 ?? defaultValue)
            }
        }
    }
    
    func new<UpdateValue>() -> Promise<UpdateValue>
        where Value == Update<UpdateValue>
    {
        Promise<UpdateValue>
        {
            promise in

            whenFulfilled
            {
                promise.fulfill($0.new)
            }
        }
    }
}
