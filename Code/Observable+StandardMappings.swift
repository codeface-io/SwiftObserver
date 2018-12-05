public extension Observable
{
    public func new<MappedUpdate>() -> Mapping<Self, MappedUpdate>
        where UpdateType == Update<MappedUpdate>
    {
        return map { $0.new }
    }
    
    public func filter(_ keep: @escaping UpdateFilter) -> Mapping<Self, UpdateType>
    {
        return map(prefilter: keep) { $0 }
    }
    
    public func unwrap<Unwrapped>(_ defaultUpdate: Unwrapped) -> Mapping<Self, Unwrapped>
        where Self.UpdateType == Optional<Unwrapped>
    {
        return map { $0 ?? defaultUpdate }
    }
    
    public func map<MappedUpdate>(prefilter: UpdateFilter? = nil,
                                  map: @escaping (UpdateType) -> MappedUpdate) -> Mapping<Self, MappedUpdate>
    {
        return Mapping(self, prefilter: prefilter, map: map)
    }
}
