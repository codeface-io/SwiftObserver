public extension Promise
{
    func unwrap<Wrapped>(_ defaultValue: Wrapped) -> Promise<Wrapped>
        where Value == Wrapped?
    {
        map { $0 ?? defaultValue }
    }
    
    func new<UpdateValue>() -> Promise<UpdateValue>
        where Value == Update<UpdateValue>
    {
        map { $0.new }
    }
    
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
}
