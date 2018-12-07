// MARK: - Observer+ObservationMapper

public extension Observer
{
    public func observe<O>(_ observable: O) -> ObservationMapper<O, O.UpdateType>
    {
        return ObservationMapper(observer: self,
                                 observable: observable,
                                 map: { $0 },
                                 filter: nil)
    }
}

// MARK: - Select

extension ObservationMapper where T: Equatable
{
    public func select(_ update: T, receive: @escaping () -> Void)
    {
        self.receive { if $0 == update { receive() } }
    }
    
    public func select(_ update: T) -> ObservationMapper
    {
        return filter { $0 == update }
    }
}

// MARK: - ObservationMapper

public struct ObservationMapper<O: Observable, T>
{
    // MARK: - Filter
    
    public func filter(_ filter: @escaping (T) -> Bool) -> ObservationMapper
    {
        let localMap = map
        let localFilter = self.filter
        
        let composedFilter = combineFilters(localFilter, { filter(localMap($0)) })
        
        return ObservationMapper(observer: observer,
                                  observable: observable,
                                  map: map,
                                  filter: composedFilter)
    }
    
    public func filter(_ filter: @escaping (T) -> Bool,
                       receive: @escaping (T) -> Void)
    {
        let localMap = map
        let localFilter = self.filter
        
        let composedFilter = combineFilters(localFilter, { filter(localMap($0)) })
        
        observable.add(observer)
        {
            if composedFilter?($0) ?? true { receive(localMap($0)) }
        }
    }
    
    // MARK: - Map
    
    public func unwrap<Unwrapped>(_ default: Unwrapped,
                                  receive: @escaping (Unwrapped) -> Void)
        where T == Optional<Unwrapped>
    {
        unwrap(`default`).receive(receive)
    }
    
    public func unwrap<Unwrapped>(_ default: Unwrapped) -> ObservationMapper<O, Unwrapped>
        where T == Optional<Unwrapped>
    {
        return map {$0 ?? `default`}
    }
    
    public func new<Value>(receive: @escaping (Value) -> Void)
        where T == Update<Value>
    {
        new().receive(receive)
    }
    
    public func new<Value>() -> ObservationMapper<O, Value>
        where T == Update<Value>
    {
        return map { $0.new }
    }
    
    public func map<U>(_ map: @escaping (T) -> U) -> ObservationMapper<O, U>
    {
        let localMap = self.map
        
        return ObservationMapper<O, U>(observer: observer,
                                        observable: observable,
                                        map: { map(localMap($0)) },
                                        filter: filter)
    }
    
    public func map<U>(_ map: @escaping (T) -> U,
                       receive: @escaping (U) -> Void)
    {
        let localMap = self.map
        let localFilter = self.filter
        
        observable.add(observer)
        {
            if localFilter?($0) ?? true { receive(map(localMap($0))) }
        }
    }
    
    // MARK: - Basics
    
    public func receive(_ receive: @escaping (T) -> Void)
    {
        let localMap = self.map
        let localFilter = self.filter
        
        observable.add(observer)
        {
            if localFilter?($0) ?? true { receive(localMap($0)) }
        }
    }

    fileprivate let observer: AnyObject
    fileprivate let observable: O
    fileprivate let map: (O.UpdateType) -> T
    fileprivate let filter: ((O.UpdateType) -> Bool)?
}
