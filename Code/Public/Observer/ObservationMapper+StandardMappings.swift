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
    // MARK: - Unwrap (Filter + Mapping)
    
    func unwrap<Wrapped>() -> ObservationMapper<O, Wrapped>
        where T == Wrapped?
    {
        let localMap = map
        
        let localFilter = filter
        let composedFilter = combineFilters(localFilter, { localMap($0) != nil })
        
        return ObservationMapper<O, Wrapped>(observer: observer,
                                             observable: observable,
                                             map: { localMap($0)! },
                                             filter: composedFilter)
    }
    
    func unwrap<Wrapped>(receive: @escaping (Wrapped) -> Void)
        where T == Wrapped?
    {
        let localMap = map
        
        let localFilter = filter
        let composedFilter = combineFilters(localFilter, { localMap($0) != nil })
        
        observable.add(observer)
        {
            if composedFilter($0) { receive(localMap($0)!) }
        }
    }
    
    // MARK: - Pure Filter
    
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
            if composedFilter($0) { receive(localMap($0)) }
        }
    }
    
    // MARK: - Pure Mappings
    
    func unwrap<Wrapped>(_ default: Wrapped,
                           receive: @escaping (Wrapped) -> Void)
        where T == Wrapped?
    {
        unwrap(`default`).receive(receive)
    }
    
    func unwrap<Wrapped>(_ default: Wrapped) -> ObservationMapper<O, Wrapped>
        where T == Wrapped?
    {
        return map { $0 ?? `default` }
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
