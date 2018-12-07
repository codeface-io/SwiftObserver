public extension Observer
{
    public func observe<O>(_ observable: O) -> ObservationMapping<O, O.UpdateType>
    {
        return ObservationMapping(observer: self,
                                  observable: observable,
                                  map: { $0 },
                                  filter: nil)
    }
}

extension ObservationMapping where T: Equatable
{
    public func select(_ update: T, receive: @escaping () -> Void)
    {
        self.receive { if $0 == update { receive() } }
    }
    
    public func select(_ update: T) -> ObservationMapping
    {
        return filter { $0 == update }
    }
}

public struct ObservationMapping<O: Observable, T>
{
    // MARK: - Filter
    
    public func filter(_ filter: @escaping (T) -> Bool) -> ObservationMapping
    {
        let localMap = map
        let localFilter = self.filter
        
        let composedFilter = combineFilters(localFilter, { filter(localMap($0)) })
        
        return ObservationMapping(observer: observer,
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
        
        observable.add(observer, filter: nil)
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
    
    public func unwrap<Unwrapped>(_ default: Unwrapped) -> ObservationMapping<O, Unwrapped>
        where T == Optional<Unwrapped>
    {
        return map {$0 ?? `default`}
    }
    
    public func new<Value>(receive: @escaping (Value) -> Void)
        where T == Update<Value>
    {
        new().receive(receive)
    }
    
    public func new<Value>() -> ObservationMapping<O, Value>
        where T == Update<Value>
    {
        return map { $0.new }
    }
    
    public func map<U>(_ map: @escaping (T) -> U) -> ObservationMapping<O, U>
    {
        let localMap = self.map
        
        return ObservationMapping<O, U>(observer: observer,
                                        observable: observable,
                                        map: { map(localMap($0)) },
                                        filter: filter)
    }
    
    public func map<U>(_ map: @escaping (T) -> U,
                       receive: @escaping (U) -> Void)
    {
        let localMap = self.map
        let localFilter = self.filter
        
        observable.add(observer, filter: nil)
        {
            if localFilter?($0) ?? true { receive(map(localMap($0))) }
        }
    }
    
    // MARK: - Basics
    
    public func receive(_ receive: @escaping (T) -> Void)
    {
        let localMap = self.map
        let localFilter = self.filter
        
        observable.add(observer, filter: nil)
        {
            if localFilter?($0) ?? true { receive(localMap($0)) }
        }
    }

    let observer: AnyObject
    let observable: O
    let map: (O.UpdateType) -> T
    let filter: ((O.UpdateType) -> Bool)?
}
