public extension Observable where UpdateType: Equatable
{
    public func select(_ default: UpdateType) -> Mapping<Self, Void>
    {
        return Mapping(self, filter: { $0 == `default` }) { _ in }
    }
}

public extension Observable
{
    public func new<MappedUpdate>() -> Mapping<Self, MappedUpdate>
        where UpdateType == Update<MappedUpdate>
    {
        return map { $0.new }
    }
    
    public func filter(_ keep: @escaping UpdateFilter) -> Mapping<Self, UpdateType>
    {
        return Mapping(self, filter: keep) { $0 }
    }
    
    public func unwrap<Unwrapped>(_ defaultUpdate: Unwrapped) -> Mapping<Self, Unwrapped>
        where Self.UpdateType == Optional<Unwrapped>
    {
        return map { $0 ?? defaultUpdate }
    }
    
    public func map<MappedUpdate>(map: @escaping (UpdateType) -> MappedUpdate) -> Mapping<Self, MappedUpdate>
    {
        return Mapping(self, map: map)
    }
}
