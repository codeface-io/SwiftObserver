public extension Promise
{
    func map<Mapped>(_ map: @escaping (Value) -> Mapped) -> Promise<Mapped>
    {
        Promise<Mapped>
        {
            promise in

            observedOnce
            {
                promise.fulfill(map($0), as: $1)
            }
        }
    }
    
    func unwrap<Wrapped>(_ defaultValue: Wrapped) -> Promise<Wrapped>
        where Value == Wrapped?
    {
        Promise<Wrapped>
        {
            promise in

            observedOnce
            {
                promise.fulfill($0 ?? defaultValue, as: $1)
            }
        }
    }
    
    func new<UpdateValue>() -> Promise<UpdateValue>
        where Value == Update<UpdateValue>
    {
        Promise<UpdateValue>
        {
            promise in

            observedOnce
            {
                promise.fulfill($0.new, as: $1)
            }
        }
    }
}
