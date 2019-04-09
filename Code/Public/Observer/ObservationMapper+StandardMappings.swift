public extension ObservationMapper where T: Equatable
{
    // MARK: - Select
    
    func select(_ message: T, receive: @escaping () -> Void)
    {
        self.receive { if $0 == message { receive() } }
    }
    
    func select(_ message: T) -> ObservationMapper
    {
        return filter { $0 == message }
    }
}

public extension ObservationMapper
{
    // MARK: - Filter
    
    func filter(_ filter: @escaping (T) -> Bool) -> ObservationMapper
    {
        let localMap = map
        let localFilter = self.filter
        
        let composedFilter = combineFilters(localFilter,
                                            { filter(localMap($0)) })
        
        return ObservationMapper(observer: observer,
                                 observable: observable,
                                 map: map,
                                 filter: composedFilter)
    }
    
    func filter(_ filter: @escaping (T) -> Bool,
                receive: @escaping (T) -> Void)
    {
        let localMap = map
        let localFilter = self.filter
        
        let composedFilter = combineFilters(localFilter,
                                            { filter(localMap($0)) })
        
        observable.add(observer)
        {
            if composedFilter?($0) ?? true { receive(localMap($0)) }
        }
    }
    
    // MARK: - Map
    
    func unwrap<Unwrapped>(_ default: Unwrapped,
                           receive: @escaping (Unwrapped) -> Void)
        where T == Optional<Unwrapped>
    {
        unwrap(`default`).receive(receive)
    }
    
    func unwrap<Unwrapped>(_ default: Unwrapped) -> ObservationMapper<O, Unwrapped>
        where T == Optional<Unwrapped>
    {
        return map {$0 ?? `default`}
    }
    
    func new<Value>(receive: @escaping (Value) -> Void)
        where T == Change<Value>
    {
        new().receive(receive)
    }
    
    func new<Value>() -> ObservationMapper<O, Value>
        where T == Change<Value>
    {
        return map { $0.new }
    }
    
    func map<U>(_ map: @escaping (T) -> U) -> ObservationMapper<O, U>
    {
        let localMap = self.map
        
        return ObservationMapper<O, U>(observer: observer,
                                        observable: observable,
                                        map: { map(localMap($0)) },
                                        filter: filter)
    }
    
    func map<U>(_ map: @escaping (T) -> U, receive: @escaping (U) -> Void)
    {
        let localMap = self.map
        let localFilter = self.filter
        
        observable.add(observer)
        {
            if localFilter?($0) ?? true { receive(map(localMap($0))) }
        }
    }
}
