extension Mapping
{
    public func new<Value>() -> Mapping<O, Value>
        where MappedUpdate == Update<Value>
    {
        return map { $0.new }
    }
    
    public func filter(_ keep: @escaping UpdateFilter) -> Mapping<O, MappedUpdate>
    {
        return map(prefilter: keep) { $0 }
    }
    
    public func unwrap<Unwrapped>(_ default: Unwrapped) -> Mapping<O, Unwrapped>
        where MappedUpdate == Optional<Unwrapped>
    {
        return map { $0 ?? `default` }
    }
    
    public func map<ComposedUpdate>(prefilter: ((MappedUpdate) -> Bool)? = nil,
                                    map: @escaping (MappedUpdate) -> ComposedUpdate) -> Mapping<O, ComposedUpdate>
    {
        let localMap = self.map
        let localPrefilter = self.prefilter
        
        let addedPrefilter: ((O.UpdateType) -> Bool)? =
        {
            guard let prefilter = prefilter else { return nil }
            
            return compose(localMap, prefilter)
        }()
        
        let composedPrefilter = combineFilters(localPrefilter, addedPrefilter)
        
        return Mapping<O, ComposedUpdate>(observable,
                                          latestMappedUpdate: map(latestUpdate),
                                          prefilter: composedPrefilter,
                                          map: compose(localMap, map))
    }
}

func combineFilters<T>(_ f1: ((T) -> Bool)?,
                       _ f2: ((T) -> Bool)?) -> ((T) -> Bool)?
{
    guard let f1 = f1 else { return f2 }
    guard let f2 = f2 else { return f1 }
    
    return and(f1, f2)
}

func and<T>(_ f1: @escaping (T) -> Bool,
            _ f2: @escaping (T) -> Bool) -> (T) -> Bool
{
    return { f1($0) && f2($0) }
}

func compose<A, B, C>(_ f1: @escaping ((A) -> B),
                      _ f2: @escaping ((B) -> C)) -> ((A) -> C)
{
    return { f2(f1($0)) }
}
