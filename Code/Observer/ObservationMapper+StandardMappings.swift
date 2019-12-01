public extension ObservationMapper where T: Equatable
{
    // MARK: - Select
    
    func select(_ message: T) -> ObservationMapper
    {
        filter { $0 == message }
    }
    
    func select(_ message: T, receive: @escaping () -> Void)
    {
        self.receive { if $0 == message { receive() } }
    }
    
    func select(_ message: T, receive: @escaping (AnyAuthor) -> Void)
    {
        self.receive { if $0 == message { receive($1) } }
    }
}

public extension ObservationMapper
{
    // MARK: - Unwrap Without Default
    
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
    
    func unwrap<Wrapped>(receive: @escaping (Wrapped, AnyAuthor) -> Void)
        where T == Wrapped?
    {
        let localMap = map
        
        let localFilter = filter
        let composedFilter = combineFilters(localFilter, { localMap($0) != nil })
        
        observable.add(observer)
        {
            if composedFilter($0) { receive(localMap($0)!, $1) }
        }
    }
    
    // MARK: - Pure Filter
    
    func filter(_ filter: @escaping (T) -> Bool) -> ObservationMapper
    {
        let localMap = map
        let localFilter = self.filter
        
        let composedFilter = combineFilters(localFilter, { filter(localMap($0)) })
        
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
        
        let composedFilter = combineFilters(localFilter, { filter(localMap($0)) })
        
        observable.add(observer)
        {
            if composedFilter($0) { receive(localMap($0)) }
        }
    }
    
    func filter(_ filter: @escaping (T) -> Bool,
                receive: @escaping (T, AnyAuthor) -> Void)
    {
        let localMap = map
        let localFilter = self.filter
        
        let composedFilter = combineFilters(localFilter, { filter(localMap($0)) })
        
        observable.add(observer)
        {
            if composedFilter($0) { receive(localMap($0), $1) }
        }
    }
    
    // MARK: - Unwrap with Default
    
    func unwrap<Wrapped>(_ default: Wrapped) -> ObservationMapper<O, Wrapped>
        where T == Wrapped?
    {
        map { $0 ?? `default` }
    }
    
    func unwrap<Wrapped>(_ default: Wrapped,
                         receive: @escaping (Wrapped) -> Void)
        where T == Wrapped?
    {
        unwrap(`default`).receive(receive)
    }
    
    func unwrap<Wrapped>(_ default: Wrapped,
                         receive: @escaping (Wrapped, AnyAuthor) -> Void)
        where T == Wrapped?
    {
        unwrap(`default`).receive(receive)
    }
    
    // MARK: - Map Onto New Value
    
    func new<Value>() -> ObservationMapper<O, Value>
        where T == Change<Value>
    {
        map { $0.new }
    }
    
    func new<Value>(receive: @escaping (Value) -> Void)
        where T == Change<Value>
    {
        new().receive(receive)
    }
    
    func new<Value>(receive: @escaping (Value, AnyAuthor) -> Void)
        where T == Change<Value>
    {
        new().receive(receive)
    }
    
    // MARK: - Pure Mapping
    
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
    
    func map<U>(_ map: @escaping (T) -> U, receive: @escaping (U, AnyAuthor) -> Void)
    {
        let localMap = self.map
        let localFilter = self.filter
        
        observable.add(observer)
        {
            if localFilter?($0) ?? true { receive(map(localMap($0)), $1) }
        }
    }
}
