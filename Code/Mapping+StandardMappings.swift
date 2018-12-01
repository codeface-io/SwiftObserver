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
    
    public func unwrap<Unwrapped>(_ defaultUpdate: Unwrapped) -> Mapping<O, Unwrapped>
        where MappedUpdate == Optional<Unwrapped>
    {
        return map { $0 ?? defaultUpdate }
    }
    
    public func map<CombinedUpdate>(prefilter: MappedFilter? = nil,
                                    map: @escaping (MappedUpdate) -> CombinedUpdate) -> Mapping<O, CombinedUpdate>
    {
        let myMap = self.map
        let myPrefilter = self.prefilter
        
        let combinedPrefilter: O.UpdateFilter? =
        {
            if let prefilter = prefilter
            {
                if let myPrefilter = myPrefilter
                {
                    return { myPrefilter($0) && prefilter(myMap($0)) }
                }
                else { return { prefilter(myMap($0)) } }
            }
            else { return myPrefilter }
        }()
        
        let combinedMap: (O.UpdateType) -> CombinedUpdate =
        {
            map(myMap($0))
        }
        
        return Mapping<O, CombinedUpdate>(observable,
                                          latestMappedUpdate: map(latestUpdate),
                                          prefilter: combinedPrefilter,
                                          map: combinedMap)
    }
    
    public typealias MappedFilter = (MappedUpdate) -> Bool
}
