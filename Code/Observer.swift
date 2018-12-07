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
 
public struct ObservationMapping<O: Observable, T>
{
    public func unwrap<Unwrapped>(_ default: Unwrapped) -> ObservationMapping<O, Unwrapped>
        where T == Optional<Unwrapped>
    {
        return map {$0 ?? `default`}
    }
    
    public func unwrap<Unwrapped>(_ default: Unwrapped,
                                  receive: @escaping (Unwrapped) -> Void)
        where T == Optional<Unwrapped>
    {
        map {$0 ?? `default`}.receive(receive)
    }
    
    public func new<Value>() -> ObservationMapping<O, Value>
        where T == Update<Value>
    {
        return map { $0.new }
    }
    
    public func new<Value>(receive: @escaping (Value) -> Void)
        where T == Update<Value>
    {
        map {$0.new}.receive(receive)
    }

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
    
    public func map<U>(_ map: @escaping (T) -> U) -> ObservationMapping<O, U>
    {
        let localMap = self.map
        
        return ObservationMapping<O, U>(observer: observer,
                                        observable: observable,
                                        map: { map(localMap($0)) },
                                        filter: filter)
    }
    
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

public extension Observer
{
    func observe<O: Observable>(_ observable: O,
                                select update: O.UpdateType,
                                receive: @escaping () -> Void)
        where O.UpdateType: Equatable
    {
        observable.add(self, filter: { $0 == update }) { _ in receive() }
    }
    
    func observe<O: Observable>(_ observable: O,
                                filter keep: ((O.UpdateType) -> Bool)? = nil,
                                receive: @escaping (O.UpdateType) -> Void)
    {
        observable.add(self, filter: keep, receive: receive)
    }
    
    func observe<O1: Observable, O2: Observable>(
        _ observable1: O1,
        _ observable2: O2,
        _ receive: @escaping (O1.UpdateType, O2.UpdateType) -> Void)
    {
        observable1.add(self, filter: nil)
        {
            [weak observable2] in
            
            guard let o2 = observable2 else { return }
            
            receive($0, o2.latestUpdate)
        }
        
        observable2.add(self, filter: nil)
        {
            [weak observable1] in
            
            guard let o1 = observable1 else { return }
            
            receive(o1.latestUpdate, $0)
        }
    }
    
    func observe<O1: Observable, O2: Observable, O3: Observable>(
        _ observable1: O1,
        _ observable2: O2,
        _ observable3: O3,
        _ receive: @escaping (O1.UpdateType, O2.UpdateType, O3.UpdateType) -> Void)
    {
        observable1.add(self, filter: nil)
        {
            [weak observable2, weak observable3] in
            
            guard let o2 = observable2, let o3 = observable3 else { return }
            
            receive($0, o2.latestUpdate, o3.latestUpdate)
        }
        
        observable2.add(self, filter: nil)
        {
            [weak observable1, weak observable3] in
            
            guard let o1 = observable1, let o3 = observable3 else { return }
            
            receive(o1.latestUpdate, $0, o3.latestUpdate)
        }
        
        observable3.add(self, filter: nil)
        {
            [weak observable1, weak observable2] in
            
            guard let o1 = observable1, let o2 = observable2 else { return }
            
            receive(o1.latestUpdate, o2.latestUpdate, $0)
        }
    }
    
    func stopObserving<O: Observable>(_ observable: O?)
    {
        observable?.remove(self)
    }
    
    func stopObservingDeadObservables()
    {
        ObservationService.removeObservationsOfDeadObservables()
    }
    
    func stopObserving()
    {
        ObservationService.removeObserver(self)
    }
}

public protocol Observer: AnyObject {}
